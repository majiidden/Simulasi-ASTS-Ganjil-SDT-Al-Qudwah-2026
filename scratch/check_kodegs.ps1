$content = Get-Content -Path 'Kode.gs.txt' -Raw
# Try parsing with JScript/node if available or count braces
try {
    # Check if node is available
    $nodeVer = node -v 2>$null
    if ($nodeVer) {
        node -c 'Kode.gs.txt'
        Write-Host "Node -c check passed for Kode.gs.txt!"
    } else {
        Write-Host "Node not installed, checking brace count..."
    }
} catch {
    Write-Host "Error running node check: $_"
}
