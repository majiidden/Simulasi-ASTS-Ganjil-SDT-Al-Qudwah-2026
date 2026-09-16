$matches = Select-String -Path @('Kode.gs.txt', 'index.html') -Pattern 'geolocation|coords|latitude|longitude'
if ($matches) {
    $matches | Select-Object -First 10 | ForEach-Object { "$($_.Filename): $($_.Line.Trim())" }
} else {
    Write-Host "No geolocation code found"
}
