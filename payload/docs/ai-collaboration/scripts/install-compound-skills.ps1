[CmdletBinding()]
param(
    [ValidateSet(
        'all',
        'agents',
        'codex',
        'claude',
        'cursor',
        'opencode',
        'antigravity',
        'gemini',
        'iflow',
        'qwen'
    )]
    [string[]]$Target = @('all'),

    [string]$WorkspaceRoot,

    [string]$ManifestPath,

    [switch]$Check,

    [switch]$DisableOverlappingLifecycleSkills
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
}
if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
    $ManifestPath = Join-Path $PSScriptRoot '..\compound-skills.manifest.json'
}

$resolvedWorkspaceRoot = [System.IO.Path]::GetFullPath($WorkspaceRoot)
$workspaceRootPrefix = $resolvedWorkspaceRoot.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar
$resolvedManifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
$packageRoot = Split-Path -Parent $resolvedManifestPath
$sourceRoot = Join-Path $packageRoot 'skills'
$manifest = Get-Content -Raw -LiteralPath $resolvedManifestPath | ConvertFrom-Json

if ($manifest.schemaVersion -ne 1) {
    throw "Unsupported compound Skill manifest schema: $($manifest.schemaVersion)"
}

$knownTargets = @($manifest.targets.PSObject.Properties.Name)
$selectedTargets = if ($Target -contains 'all') {
    $knownTargets
}
else {
    @($Target | Select-Object -Unique)
}

$failures = [System.Collections.Generic.List[string]]::new()
$checkedFiles = 0

foreach ($targetName in $selectedTargets) {
    if ($targetName -notin $knownTargets) {
        throw "Target '$targetName' is not present in the manifest."
    }

    $relativeTargetRoot = $manifest.targets.PSObject.Properties[$targetName].Value
    $targetRoot = [System.IO.Path]::GetFullPath(
        (Join-Path $resolvedWorkspaceRoot $relativeTargetRoot)
    )

    if (
        $targetRoot -ne $resolvedWorkspaceRoot -and
        -not $targetRoot.StartsWith($workspaceRootPrefix, [System.StringComparison]::OrdinalIgnoreCase)
    ) {
        throw "Resolved target escapes workspace root: $targetRoot"
    }

    # Check mode is verification-only and must not quarantine directories.
    if ($DisableOverlappingLifecycleSkills -and -not $Check) {
        $disabledRoot = [System.IO.Path]::GetFullPath(
            (Join-Path (Split-Path -Parent $targetRoot) 'skills_disabled')
        )
        if (
            $disabledRoot -ne $resolvedWorkspaceRoot -and
            -not $disabledRoot.StartsWith($workspaceRootPrefix, [System.StringComparison]::OrdinalIgnoreCase)
        ) {
            throw "Resolved disabled-Skill target escapes workspace root: $disabledRoot"
        }

        foreach ($overlappingSkill in $manifest.overlappingLifecycleSkills) {
            $activeSkill = Join-Path $targetRoot $overlappingSkill
            $disabledSkill = Join-Path $disabledRoot $overlappingSkill
            if (-not (Test-Path -LiteralPath $activeSkill -PathType Container)) {
                continue
            }
            if (Test-Path -LiteralPath $disabledSkill) {
                throw "Cannot quarantine '$activeSkill': destination already exists at '$disabledSkill'."
            }

            New-Item -ItemType Directory -Force -Path $disabledRoot | Out-Null
            Move-Item -LiteralPath $activeSkill -Destination $disabledSkill
            Write-Host "Disabled overlapping lifecycle Skill [$targetName]: $overlappingSkill"
        }
    }

    foreach ($skillName in $manifest.skills) {
        $sourceFile = Join-Path $sourceRoot "$skillName\SKILL.md"
        $targetDirectory = Join-Path $targetRoot $skillName
        $targetFile = Join-Path $targetDirectory 'SKILL.md'

        if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
            throw "Canonical Skill is missing: $sourceFile"
        }

        if ($Check) {
            if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) {
                $failures.Add("Missing [$targetName] $targetFile")
                continue
            }

            $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourceFile).Hash
            $targetHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $targetFile).Hash
            if ($sourceHash -ne $targetHash) {
                $failures.Add("Out of sync [$targetName] $targetFile")
                continue
            }
        }
        else {
            New-Item -ItemType Directory -Force -Path $targetDirectory | Out-Null
            Copy-Item -Force -LiteralPath $sourceFile -Destination $targetFile
        }

        $checkedFiles++
    }
}

if ($failures.Count -gt 0) {
    $details = $failures -join [Environment]::NewLine
    throw "Compound Skill deployment check failed:$([Environment]::NewLine)$details"
}

$verb = if ($Check) { 'verified' } else { 'installed' }
Write-Host "Compound Skills ${verb}: $checkedFiles files across $($selectedTargets.Count) targets."
