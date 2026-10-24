[CmdletBinding()]
param(
    [string]$PackageRoot = '',
    [ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version = '1.10.0',
    [switch]$ForRelease
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$started = [Diagnostics.Stopwatch]::StartNew()
if ([string]::IsNullOrWhiteSpace($PackageRoot)) { $PackageRoot = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent }

function Get-FullPath([string]$Path) {
    return [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
}

function Assert-NoReparsePath([string]$Path) {
    $cursor = Get-FullPath $Path
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Reparse point in package ancestry: $cursor"
            }
        }
        $parent = Split-Path -Parent $cursor
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $cursor) { break }
        $cursor = $parent
    }
}

function Get-Sha256([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Test-ReleaseExcludedFile([string]$Name) {
    $lower = $Name.ToLowerInvariant()
    if ($lower -eq '.env' -or ($lower.StartsWith('.env.') -and $lower -ne '.env.example')) { return $true }
    return $lower -match '(^credentials(\.|$)|(^|[._-])(secret|token|password|passwd)([._-]|$)|\.(pem|key|pfx|p12|log|tmp|bak|backup|old|orig|swp|swo)$|~$|^(thumbs\.db|\.ds_store)$)'
}

function Get-Inventory([string]$Root) {
    # Development mode follows the manager's existing .git/.ai exclusion. ForRelease
    # is the curated export boundary: it rejects private/tool trees and sensitive
    # filename patterns; it is a gate, not an exhaustive secret scanner.
    $privateNames = @(
        '.agents', '.agent', '.claude', '.codex', '.cursor', '.gemini', '.iflow', '.opencode', '.qwen', '.trae',
        '.vscode', '.idea', '.omo', '.codebase-memory', '.ai-collaboration-install', '.local', '.playwright-mcp',
        '.openspec', '.cache', 'node_modules', 'dist', 'bin', 'obj', 'source-reference', 'archive', 'archives', 'tmp', 'temp'
    )
    $files = New-Object 'Collections.Generic.List[object]'
    $pending = New-Object 'Collections.Generic.Stack[string]'
    $pending.Push($Root)
    while ($pending.Count -gt 0) {
        $directory = $pending.Pop()
        foreach ($entryPath in [IO.Directory]::GetFileSystemEntries($directory)) {
            $entry = Get-Item -LiteralPath $entryPath -Force
            if (($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "Reparse point in package tree: $entryPath"
            }
            if ($entry.PSIsContainer) {
                $name = [IO.Path]::GetFileName($entry.FullName)
                if ($name -ceq '.git' -or $name -ceq '.ai') {
                    if ($ForRelease) { throw "Release package cannot contain private directory: $($entry.FullName)" }
                    continue
                }
                if ($ForRelease -and $privateNames -contains $name.ToLowerInvariant()) {
                    throw "Private or tool directory is not publishable: $($entry.FullName)"
                }
                $pending.Push($entry.FullName)
                continue
            }
            $relative = $entry.FullName.Substring($Root.Length + 1).Replace('\', '/')
            if ($relative -ceq 'snapshot.json') { continue }
            if ($ForRelease -and (Test-ReleaseExcludedFile ([IO.Path]::GetFileName($entry.FullName)))) {
                throw "Release package contains a credential, environment, backup, log, or temporary file: $($entry.FullName)"
            }
            $bytes = [IO.File]::ReadAllBytes($entry.FullName)
            $files.Add([pscustomobject]([ordered]@{
                path = $relative
                bytes = [int64]$bytes.Length
                sha256 = Get-Sha256 $bytes
            }))
        }
    }
    $items = @($files.ToArray())
    $paths = [string[]]@($items | ForEach-Object { [string]$_.path })
    [Array]::Sort($paths, [StringComparer]::Ordinal)
    $byPath = @{}
    foreach ($item in $items) { $byPath[[string]$item.path] = $item }
    return @($paths | ForEach-Object { $byPath[$_] })
}

$root = Get-FullPath $PackageRoot
if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw "Package root is missing: $root" }
Assert-NoReparsePath $root
$rootItem = Get-Item -LiteralPath $root -Force
if (($rootItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Package root is a reparse point: $root" }

$inventory = @(Get-Inventory $root)
# A package carrying Lite must carry its entire fixed source projection. This is
# separate from the selected deployment: both profiles remain in one inventory.
$litePrefix = 'payload/docs/ai-collaboration/lite/'
$liteFiles = @($inventory | Where-Object { $_.path.StartsWith($litePrefix,[StringComparison]::Ordinal) })
if ($liteFiles.Count) {
    $requiredLite = @('RULES.md','README.md','README.zh-CN.md','LICENSE','agent-rules.md','templates/project-config.md','templates/queue.md','templates/task.md','templates/handoff.md','scripts/validate-state.ps1','scripts/doctor.ps1')
    $actualLite = @($liteFiles | ForEach-Object { $_.path.Substring($litePrefix.Length) })
    if ($actualLite.Count -ne $requiredLite.Count -or @($requiredLite | Where-Object { $actualLite -cnotcontains $_ }).Count) { throw 'Incomplete or unknown Lite source projection; retain both complete profiles before generating inventory' }
}
$snapshot = [ordered]@{
    schemaVersion = 1
    packageVersion = $Version
    files = $inventory
}
$snapshotPath = Join-Path $root 'snapshot.json'
$json = $snapshot | ConvertTo-Json -Depth 8 -Compress
[IO.File]::WriteAllText($snapshotPath, $json, $utf8)
$started.Stop()
$totalBytes = [int64](($inventory | Measure-Object -Property bytes -Sum).Sum)
$summary = [ordered]@{
    mode = if ($ForRelease) { 'release' } else { 'development' }
    packageRoot = if ($ForRelease) { '<package-root>' } else { $root }
    packageVersion = $Version
    files = $inventory.Count
    bytes = $totalBytes
    elapsedMs = [int64]$started.Elapsed.TotalMilliseconds
}
Write-Output ($summary | ConvertTo-Json -Compress)
