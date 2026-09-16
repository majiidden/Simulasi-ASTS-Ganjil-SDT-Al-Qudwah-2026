$matches = Select-String -Path @('Kode.gs.txt', 'index.html') -Pattern 'resetSession|unlock|buka kunci|reset sesi'
if ($matches) {
    $matches | Select-Object -First 10 | ForEach-Object { "$($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
} else {
    Write-Host "No resetSession or unlock found"
}
