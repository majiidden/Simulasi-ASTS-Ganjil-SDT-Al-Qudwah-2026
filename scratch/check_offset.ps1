$html = [System.IO.File]::ReadAllText("index.html")
$idx1 = $html.IndexOf("<script>")
$start = $html.IndexOf("<script>", $idx1 + 8) + 8
$sub = $html.Substring(0, $start + 174542)
$lines = $sub -split "`r?`n"
Write-Host "Target Line number: $($lines.Length)"

$allLines = $html -split "`r?`n"
$startL = [Math]::Max(0, $lines.Length - 10)
$endL = [Math]::Min($allLines.Length - 1, $lines.Length + 10)

for ($j = $startL; $j -le $endL; $j++) {
    Write-Host "$($j+1): $($allLines[$j])"
}
