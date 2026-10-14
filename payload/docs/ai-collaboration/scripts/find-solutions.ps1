[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
    [Parameter(Mandatory = $true)][string]$Query,
    [ValidateRange(1, 100)][int]$Limit = 10
)
# Read-only local search of docs/solutions/*.md. It writes no file, starts no host or installer,
# makes no network request and keeps no index. Terms are literal: whitespace separates terms, each
# term must occur in the title, tags or body (combined), and regular-expression syntax is never
# interpreted. A hit is evidence to revalidate, never an authority or an applied decision.
# Exit 0 means the search completed (including no hit or an empty library). Exit 1 means invalid
# input, an unsafe reparse point, or any unreadable or malformed entry; the search is then
# incomplete and no result list is reported. Reparse points are reported and never followed.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$script:problems = New-Object 'Collections.Generic.List[string]'
$script:root = ''
$maxTerms = 16

function Stop-Search([string]$Message) {
    Write-Output "PROBLEM: $Message"
    Write-Output 'search incomplete; no result list is reported as complete'
    exit 1
}

function Get-Relative([string]$FullPath) {
    return $FullPath.Substring($script:root.Length + 1).Replace('\', '/')
}

# Any reparse point on the path chain (the path itself or an ancestor) is unsafe and is not followed.
function Test-ReparseChain([string]$Path) {
    $cursor = [IO.Path]::GetFullPath($Path)
    while ($cursor) {
        $item = Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($null -ne $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $true }
        $parent = Split-Path -Parent $cursor
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $cursor) { break }
        $cursor = $parent
    }
    return $false
}

function Get-Unquoted([string]$Value) {
    $text = $Value.Trim()
    if ($text.Length -ge 2 -and (($text.StartsWith('"') -and $text.EndsWith('"')) -or ($text.StartsWith("'") -and $text.EndsWith("'")))) {
        return $text.Substring(1, $text.Length - 2).Trim()
    }
    return $text
}

# Quote-aware split for inline bracket tag lists: commas inside single or double quotes stay literal.
function Split-InlineList([string]$Inner) {
    $parts = New-Object 'Collections.Generic.List[string]'
    $current = New-Object Text.StringBuilder
    [char]$quote = [char]0
    for ($k = 0; $k -lt $Inner.Length; $k++) {
        [char]$c = $Inner[$k]
        if ($quote -ne [char]0) {
            [void]$current.Append($c)
            if ($c -eq $quote) { $quote = [char]0 }
        }
        elseif ($c -eq [char]'"' -or $c -eq [char]"'") {
            $quote = $c
            [void]$current.Append($c)
        }
        elseif ($c -eq [char]',') {
            $parts.Add($current.ToString())
            $current.Length = 0
        }
        else {
            [void]$current.Append($c)
        }
    }
    $parts.Add($current.ToString())
    return $parts.ToArray()
}

# Reads one entry as strict UTF-8 (optional BOM). Legacy entries without frontmatter are accepted;
# their title comes from the first level-one heading and they have no tags.
function Get-Entry([string]$Path, [string]$Relative) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -ge 2 -and (($bytes[0] -eq 255 -and $bytes[1] -eq 254) -or ($bytes[0] -eq 254 -and $bytes[1] -eq 255))) {
        throw 'UTF-16 is unsupported'
    }
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) { $offset = 3 }
    $text = $utf8.GetString($bytes, $offset, $bytes.Length - $offset)
    $lines = @(($text -replace "`r`n", "`n") -split "`n")
    $title = ''
    $tags = New-Object 'Collections.Generic.List[string]'
    $bodyStart = 0
    if ($lines.Count -gt 0 -and $lines[0].TrimEnd() -eq '---') {
        $close = -1
        for ($i = 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i].TrimEnd() -eq '---') { $close = $i; break }
        }
        # A leading thematic rule is only a metadata header when the region holds
        # readable title/tags fields. Ordinary legacy Markdown (no later delimiter,
        # or no metadata field before it) is searched as body instead of failing
        # the whole library or discarding its title/body.
        if ($close -ge 0) {
            $hasMeta = $false
              $inFence = $false
              $fenceChar = ''
              $fenceLength = 0
            for ($m = 1; $m -lt $close; $m++) {
                  if ($lines[$m] -match '^\s*(`{3,}|~{3,})(.*)$') {
                      $marker = [string]$Matches[1]
                      $suffix = [string]$Matches[2]
                      if (-not $inFence) {
                          $inFence = $true
                          $fenceChar = $marker.Substring(0, 1)
                          $fenceLength = $marker.Length
                      }
                      elseif ($suffix -match '^\s*$' -and $marker.Substring(0, 1) -eq $fenceChar -and $marker.Length -ge $fenceLength) {
                          $inFence = $false
                          $fenceChar = ''
                          $fenceLength = 0
                      }
                      continue
                  }
                  if ($inFence) { continue }
                if ($lines[$m] -match '^\s*(title|tags)\s*:') { $hasMeta = $true; break }
            }
            if (-not $hasMeta) { $close = -1 }
        }
        if ($close -ge 0) {
        $inTags = $false
          $inFence = $false
          $fenceChar = ''
          $fenceLength = 0
        for ($i = 1; $i -lt $close; $i++) {
            $line = $lines[$i]
              if ($line -match '^\s*(`{3,}|~{3,})(.*)$') {
                  $marker = [string]$Matches[1]
                  $suffix = [string]$Matches[2]
                  if (-not $inFence) {
                      $inFence = $true
                      $fenceChar = $marker.Substring(0, 1)
                      $fenceLength = $marker.Length
                  }
                  elseif ($suffix -match '^\s*$' -and $marker.Substring(0, 1) -eq $fenceChar -and $marker.Length -ge $fenceLength) {
                      $inFence = $false
                      $fenceChar = ''
                      $fenceLength = 0
                  }
                  continue
              }
              if ($inFence) { continue }
            if ($line -match '^title:\s*(.*)$') {
                $rawTitle = $Matches[1].Trim()
                if ($rawTitle -match '^[>|][+-]?$') {
                    $folded = New-Object 'Collections.Generic.List[string]'
                    for ($j = ($i + 1); $j -lt $close; $j++) {
                        if ($lines[$j] -match '^\s*$') { continue }
                        if ($lines[$j] -match '^\s+\S') { $folded.Add($lines[$j].Trim()); $i = $j }
                        else { break }
                    }
                    if ($folded.Count -gt 0) {
                        if ($rawTitle.StartsWith('|')) { $title = ($folded -join "`n") }
                        else { $title = ($folded -join ' ') }
                    }
                    else { $title = '' }
                }
                else {
                    $title = Get-Unquoted $Matches[1]
                }
                $inTags = $false
            }
            elseif ($line -match '^tags:\s*(.*)$') {
                $value = $Matches[1].Trim()
                $inTags = ($value -eq '')
                if ($value.StartsWith('[') -and $value.EndsWith(']')) {
                    foreach ($part in (Split-InlineList $value.Substring(1, $value.Length - 2))) {
                        $tag = Get-Unquoted $part
                        if ($tag -ne '') { $tags.Add($tag) }
                    }
                }
                elseif ($value -ne '') {
                    $tags.Add((Get-Unquoted $value))
                }
            }
            elseif ($inTags -and $line -match '^\s*-\s*(.*)$') {
                $tag = Get-Unquoted $Matches[1]
                if ($tag -ne '') { $tags.Add($tag) }
            }
            elseif ($line -match '^\S') {
                $inTags = $false
            }
        }
        $bodyStart = $close + 1
        }
    }
    $bodyLines = New-Object 'Collections.Generic.List[string]'
    for ($i = $bodyStart; $i -lt $lines.Count; $i++) { $bodyLines.Add($lines[$i]) }
    if ($title -eq '') {
        foreach ($line in $bodyLines) {
            if ($line -match '^#\s+(.+)$') { $title = $Matches[1].Trim(); break }
        }
    }
    if ($title -eq '') { $title = [IO.Path]::GetFileNameWithoutExtension($Relative) }
    return [pscustomobject]@{ Relative = $Relative; Title = $title; Tags = $tags.ToArray(); BodyLines = $bodyLines.ToArray() }
}

function Get-Snippet([string]$Line, [int]$Index) {
    $start = [Math]::Max(0, $Index - 60)
    $length = [Math]::Min(160, $Line.Length - $start)
    $text = $Line.Substring($start, $length).Replace("`t", ' ').Trim()
    if ($start -gt 0) { $text = '...' + $text }
    if ($start + $length -lt $Line.Length) { $text = $text + '...' }
    return $text
}

function Join-Terms([object[]]$List) {
    if (@($List).Count -eq 0) { return '-' }
    return (@($List) -join ', ')
}

$terms = @(([string]$Query).Trim() -split '\s+' | Where-Object { $_ -ne '' })
if ($terms.Count -eq 0) { Stop-Search 'invalid argument: Query must contain at least one literal term' }
if ($terms.Count -gt $maxTerms) { Stop-Search "invalid argument: at most $maxTerms terms are accepted" }
if (-not ($WorkspaceRoot -match '^([A-Za-z]:[\\/]|\\\\)') -or -not (Test-Path -LiteralPath $WorkspaceRoot -PathType Container)) {
    Stop-Search 'invalid argument: WorkspaceRoot must be an existing absolute directory'
}
$script:root = [IO.Path]::GetFullPath($WorkspaceRoot).TrimEnd('\')
$docs = Join-Path $script:root 'docs'
$library = Join-Path $docs 'solutions'
if (Test-ReparseChain $docs) { Stop-Search 'unsafe: reparse point on the docs path; not followed' }
if (-not (Test-Path -LiteralPath $docs)) {
    Write-Output 'ai-collaboration solution search (read-only; literal terms; no files written)'
    Write-Output 'library: docs/solutions is absent; entries inspected: 0'
    Write-Output 'no hits: a no-hit search needs no artifact'
    exit 0
}
if (-not (Test-Path -LiteralPath $docs -PathType Container)) { Stop-Search 'docs is not a directory' }
if (Test-ReparseChain $library) { Stop-Search 'unsafe: reparse point on the docs/solutions path; not followed' }
if (-not (Test-Path -LiteralPath $library)) {
    Write-Output 'ai-collaboration solution search (read-only; literal terms; no files written)'
    Write-Output 'library: docs/solutions is absent; entries inspected: 0'
    Write-Output 'no hits: a no-hit search needs no artifact'
    exit 0
}
if (-not (Test-Path -LiteralPath $library -PathType Container)) { Stop-Search 'docs/solutions is not a directory' }

$skipped = 0
$candidates = New-Object 'Collections.Generic.List[string]'
$pending = New-Object 'Collections.Generic.Stack[string]'
$pending.Push($library)
while ($pending.Count -gt 0) {
    $directory = $pending.Pop()
    try { $items = @(Get-ChildItem -LiteralPath $directory -Force) }
    catch { $script:problems.Add("unreadable directory: $(Get-Relative $directory)"); continue }
    foreach ($item in $items) {
        $relative = Get-Relative $item.FullName
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { $script:problems.Add("reparse point, not followed: $relative"); continue }
        if ($item.PSIsContainer) { $pending.Push($item.FullName); continue }
        if ([string]$item.Extension -ine '.md') { continue }
        if ($item.Name -ieq 'README.md' -or $item.Name -ieq 'solution.template.md') { $skipped++; continue }
        $candidates.Add($item.FullName)
    }
}

$entries = New-Object 'Collections.Generic.List[object]'
foreach ($path in $candidates) {
    $relative = Get-Relative $path
    try { $entries.Add((Get-Entry $path $relative)) }
    catch { $script:problems.Add("unreadable or malformed entry: $relative ($($_.Exception.Message))") }
}
if ($script:problems.Count -gt 0) {
    foreach ($problem in $script:problems) { Write-Output "PROBLEM: $problem" }
    Stop-Search "library read is incomplete: $($script:problems.Count) problem(s) listed above"
}

$hits = New-Object 'Collections.Generic.List[object]'
foreach ($entry in $entries) {
    $titleTerms = New-Object 'Collections.Generic.List[string]'
    $tagTerms = New-Object 'Collections.Generic.List[string]'
    $bodyTerms = New-Object 'Collections.Generic.List[string]'
    $tagText = $entry.Tags -join "`n"
    $bodyText = $entry.BodyLines -join "`n"
    $covered = $true
    foreach ($term in $terms) {
        $inTitle = $entry.Title.IndexOf($term, [StringComparison]::OrdinalIgnoreCase) -ge 0
        $inTag = $tagText.IndexOf($term, [StringComparison]::OrdinalIgnoreCase) -ge 0
        $inBody = $bodyText.IndexOf($term, [StringComparison]::OrdinalIgnoreCase) -ge 0
        if ($inTitle) { $titleTerms.Add($term) }
        if ($inTag) { $tagTerms.Add($term) }
        if ($inBody) { $bodyTerms.Add($term) }
        if (-not ($inTitle -or $inTag -or $inBody)) { $covered = $false }
    }
    if (-not $covered) { continue }
    $snippet = ''
    if ($bodyTerms.Count -gt 0) {
        foreach ($line in $entry.BodyLines) {
            $index = $line.IndexOf($bodyTerms[0], [StringComparison]::OrdinalIgnoreCase)
            if ($index -ge 0) { $snippet = Get-Snippet $line $index; break }
        }
    }
    # Order: title matches, then tag matches, then body matches (more first), then stable ordinal path.
    $key = ('{0:D3}' -f (999 - $titleTerms.Count)) + '|' + ('{0:D3}' -f (999 - $tagTerms.Count)) + '|' + ('{0:D3}' -f (999 - $bodyTerms.Count)) + '|' + $entry.Relative
    $hits.Add([pscustomobject]@{ Key = $key; Entry = $entry; TitleTerms = $titleTerms.ToArray(); TagTerms = $tagTerms.ToArray(); BodyTerms = $bodyTerms.ToArray(); Snippet = $snippet })
}
# Ordinal dictionary: distinct paths differing only in case stay separate hits.
$byKey = New-Object 'Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
foreach ($hit in $hits) { $byKey[[string]$hit.Key] = $hit }
$keys = [string[]]@($byKey.Keys)
[Array]::Sort($keys, [StringComparer]::Ordinal)
$sorted = @($keys | ForEach-Object { $byKey[$_] })

Write-Output 'ai-collaboration solution search (read-only; literal terms; no files written)'
Write-Output "library: docs/solutions; entries inspected: $($entries.Count); README/template skipped: $skipped"
Write-Output ('terms: ' + ($terms -join ' | '))
if ($entries.Count -eq 0) { Write-Output 'no hits: the library has no entries'; exit 0 }
if ($sorted.Count -eq 0) { Write-Output 'no hits: a no-hit search needs no artifact'; exit 0 }
$shown = [Math]::Min($Limit, $sorted.Count)
Write-Output "hits: $($sorted.Count); shown: $shown (limit $Limit)"
for ($i = 0; $i -lt $shown; $i++) {
    $hit = $sorted[$i]
    Write-Output ('[' + ($i + 1) + '] ' + $hit.Entry.Relative)
    Write-Output ('    title: ' + $hit.Entry.Title)
    Write-Output ('    matched: title=' + (Join-Terms $hit.TitleTerms) + '; tags=' + (Join-Terms $hit.TagTerms) + '; body=' + (Join-Terms $hit.BodyTerms))
    if ($hit.Snippet -ne '') { Write-Output ('    snippet: ' + $hit.Snippet) }
}
Write-Output 'Each hit is evidence, not authority: read Context, Verification and Revalidation, then check them against the current repository before applying (docs/ai-collaboration/compound-engineering.md#retrieve-and-reuse).'
exit 0
