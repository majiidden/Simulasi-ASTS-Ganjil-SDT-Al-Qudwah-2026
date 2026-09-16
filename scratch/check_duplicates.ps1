$lines = Get-Content "index.html"
$vars = @{}
for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^(let|const)\s+([a-zA-Z0-9_$]+)\s*(=|;)') {
        $name = $matches[2]
        $lineNum = $i + 1
        if ($vars.ContainsKey($name)) {
            Write-Host "DUPLICATE FOUND: $name at line $lineNum, previously at line $($vars[$name])" -ForegroundColor Red
        } else {
            $vars[$name] = $lineNum
        }
    }
}
Write-Host "Scan completed." -ForegroundColor Cyan
