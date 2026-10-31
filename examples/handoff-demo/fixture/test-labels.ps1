# Behavior checks for Normalize-DemoLabels. Do not weaken these expectations.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'labels.ps1')

$cases = @(
    @{ Name = 'empty array'; Input = @(); Expected = @() },
    @{ Name = 'case-insensitive duplicates'; Input = @(' Alpha ', 'alpha', 'BETA', 'beta'); Expected = @('Alpha', 'BETA') },
    @{ Name = 'blank values are ignored'; Input = @(' ', '', ' a '); Expected = @('a') },
    @{ Name = 'first spelling kept in order'; Input = @('b', 'A', 'b', 'c'); Expected = @('b', 'A', 'c') }
)

$failures = 0
foreach ($case in $cases) {
    # Capture the call result directly. Do not wrap it in @(): that would hide whether the
    # function returned a real array or an unrolled scalar, empty value or $null.
    $actual = Normalize-DemoLabels -Labels $case.Input
    $expected = @($case.Expected)

    if ($actual -isnot [System.Array]) {
        $failures++
        $kind = if ($null -eq $actual) { '$null' } else { $actual.GetType().Name }
        Write-Output "FAIL $($case.Name): result is $kind, not an array"
        continue
    }

    $same = $actual.Count -eq $expected.Count
    if ($same) {
        for ($i = 0; $i -lt $expected.Count; $i++) {
            if (-not ($actual[$i] -ceq $expected[$i])) {
                $same = $false
                break
            }
        }
    }

    if ($same) {
        Write-Output "PASS $($case.Name)"
    } else {
        $failures++
        Write-Output ("FAIL {0}: expected [{1}] actual [{2}]" -f $case.Name, ($expected -join ', '), ($actual -join ', '))
    }
}

if ($failures -gt 0) {
    Write-Output "$failures of $($cases.Count) checks failed"
    exit 1
}
Write-Output "All $($cases.Count) checks passed"
exit 0
