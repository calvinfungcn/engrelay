$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$installer = Join-Path $scriptRoot 'install-compound-skills.ps1'
$manifestPath = Join-Path $scriptRoot '..\compound-skills.manifest.json'
$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$systemTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$testRoot = [System.IO.Path]::GetFullPath(
    (Join-Path $systemTemp "wm-compound-skills-$([guid]::NewGuid())")
)

if (-not $testRoot.StartsWith($systemTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Test path escapes the system temporary directory: $testRoot"
}

try {
    New-Item -ItemType Directory -Path $testRoot | Out-Null

    & $installer -Target all -WorkspaceRoot $testRoot -ManifestPath $manifestPath
    & $installer -Target all -WorkspaceRoot $testRoot -ManifestPath $manifestPath -Check

    $expectedCount = @($manifest.skills).Count * @($manifest.targets.PSObject.Properties).Count
    $actualCount = @(
        Get-ChildItem -LiteralPath $testRoot -Recurse -Filter 'SKILL.md' -File
    ).Count
    if ($actualCount -ne $expectedCount) {
        throw "Expected $expectedCount installed Skills, found $actualCount."
    }
    Write-Host 'PASS: installs every canonical Skill into every target'

    $firstTarget = @($manifest.targets.PSObject.Properties)[0].Value

    $testRootLeaf = Split-Path -Leaf $testRoot
    $siblingPrefixManifestPath = Join-Path $testRoot 'sibling-prefix.manifest.json'
    $siblingPrefixManifest = [ordered]@{
        schemaVersion = 1
        packageVersion = 'test'
        skills = @($manifest.skills)
        overlappingLifecycleSkills = @()
        targets = [ordered]@{
            agents = '..\' + $testRootLeaf + '-evil\skills'
        }
    }
    $siblingPrefixManifest |
        ConvertTo-Json -Depth 5 |
        Set-Content -LiteralPath $siblingPrefixManifestPath

    $siblingEscapeRefused = $false
    try {
        & $installer -Target agents -WorkspaceRoot $testRoot -ManifestPath $siblingPrefixManifestPath
    }
    catch {
        $siblingEscapeRefused = $_.Exception.Message -match 'escapes workspace root'
    }
    if (-not $siblingEscapeRefused) {
        throw 'The installer accepted a sibling-prefix target escape.'
    }
    Write-Host 'PASS: refuses sibling-prefix workspace escape'

    $checkOnlySkill = @($manifest.overlappingLifecycleSkills)[2]
    $checkOnlyActive = Join-Path (Join-Path $testRoot $firstTarget) $checkOnlySkill
    $checkOnlyDisabledRoot = Join-Path $testRoot (
        (Split-Path -Parent $firstTarget) + '\skills_disabled'
    )
    $checkOnlyDisabled = Join-Path $checkOnlyDisabledRoot $checkOnlySkill
    New-Item -ItemType Directory -Force -Path $checkOnlyActive | Out-Null
    Set-Content -LiteralPath (Join-Path $checkOnlyActive 'SKILL.md') -Value '# check-only fixture'
    & $installer -Target agents -WorkspaceRoot $testRoot -ManifestPath $manifestPath -Check -DisableOverlappingLifecycleSkills
    if (-not (Test-Path -LiteralPath $checkOnlyActive -PathType Container) -or
        (Test-Path -LiteralPath $checkOnlyDisabled)) {
        throw 'Check mode moved or quarantined an overlapping lifecycle Skill.'
    }
    Write-Host 'PASS: check mode does not quarantine overlapping lifecycle Skills'

    $activeOverlap = Join-Path $testRoot "$firstTarget\using-superpowers"
    $disabledOverlap = Join-Path $testRoot (
        (Split-Path -Parent $firstTarget) + '\skills_disabled\using-superpowers'
    )
    New-Item -ItemType Directory -Force -Path $activeOverlap | Out-Null
    Set-Content -LiteralPath (Join-Path $activeOverlap 'SKILL.md') -Value '# fixture'
    & $installer -Target agents -WorkspaceRoot $testRoot -ManifestPath $manifestPath `
        -DisableOverlappingLifecycleSkills
    if ((Test-Path -LiteralPath $activeOverlap) -or
        -not (Test-Path -LiteralPath $disabledOverlap -PathType Container)) {
        throw 'The installer did not quarantine an overlapping lifecycle Skill.'
    }
    Write-Host 'PASS: quarantines overlapping lifecycle Skills without deleting them'

    $conflictSkill = @($manifest.overlappingLifecycleSkills)[1]
    $conflictActive = Join-Path (Join-Path $testRoot $firstTarget) $conflictSkill
    $conflictDisabledRoot = Join-Path $testRoot (
        (Split-Path -Parent $firstTarget) + '\skills_disabled'
    )
    $conflictDisabled = Join-Path $conflictDisabledRoot $conflictSkill
    New-Item -ItemType Directory -Force -Path $conflictActive | Out-Null
    Set-Content -LiteralPath (Join-Path $conflictActive 'SKILL.md') -Value '# active conflict fixture'
    New-Item -ItemType Directory -Force -Path $conflictDisabled | Out-Null
    Set-Content -LiteralPath (Join-Path $conflictDisabled 'SKILL.md') -Value '# preserved destination fixture'

    $conflictThrows = $false
    try {
        & $installer -Target agents -WorkspaceRoot $testRoot -ManifestPath $manifestPath -DisableOverlappingLifecycleSkills
    }
    catch {
        $conflictThrows = $_.Exception.Message -match 'destination already exists'
    }
    if (-not $conflictThrows) {
        throw 'The installer did not refuse a conflicting disabled-Skill destination.'
    }
    if (-not (Test-Path -LiteralPath $conflictActive -PathType Container) -or
        -not (Test-Path -LiteralPath $conflictDisabled -PathType Container)) {
        throw 'A conflicting quarantine attempt removed an active or destination Skill.'
    }
    Write-Host 'PASS: preserves active Skill when disabled destination conflicts'

    $firstSkill = $manifest.skills[0]
    $corruptFile = Join-Path $testRoot "$firstTarget\$firstSkill\SKILL.md"
    Add-Content -LiteralPath $corruptFile -Value '# stale generated copy'

    $detectedMismatch = $false
    try {
        & $installer -Target all -WorkspaceRoot $testRoot -ManifestPath $manifestPath -Check
    }
    catch {
        $detectedMismatch = $_.Exception.Message -match 'Out of sync'
    }

    if (-not $detectedMismatch) {
        throw 'The deployment check did not detect a modified generated Skill.'
    }
    Write-Host 'PASS: detects an out-of-sync generated Skill'

    & $installer -Target all -WorkspaceRoot $testRoot -ManifestPath $manifestPath
    & $installer -Target all -WorkspaceRoot $testRoot -ManifestPath $manifestPath -Check
    Write-Host 'PASS: reinstall repairs generated Skill drift'
    Write-Host 'All Compound Skill installer tests passed.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        $resolvedTestRoot = (Resolve-Path -LiteralPath $testRoot).Path
        if (-not $resolvedTestRoot.StartsWith($systemTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove path outside the system temporary directory: $resolvedTestRoot"
        }
        Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
    }
}
