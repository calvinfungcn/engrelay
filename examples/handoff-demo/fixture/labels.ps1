# Demo label helper for the normalize-demo-labels change.
function Normalize-DemoLabels {
    param(
        [AllowEmptyCollection()]
        [string[]]$Labels
    )

    $seen = @{}
    $result = @()
    foreach ($label in $Labels) {
        $value = $label.Trim()
        if ($seen.ContainsKey($value)) {
            continue
        }
        $seen[$value] = $true
        $result += $value
    }
    return $result
}
