$raw = [System.IO.File]::ReadAllText('index.html', [System.Text.Encoding]::UTF8)

$items = @(
    'getOrInitDeviceIdentifier',
    'handleResetDevice',
    'resetStudentDevice',
    'isDeviceBlocked',
    'btnResetDevice',
    'cbt_device_id'
)

$allFound = $true
foreach ($it in $items) {
    if ($raw.Contains($it)) {
        Write-Host "Found in index.html: $it"
    } else {
        Write-Host "MISSING in index.html: $it"
        $allFound = $false
    }
}

if ($allFound) {
    Write-Host "ALL FRONTEND DEVICE BINDING FEATURES ARE PRESENT!"
} else {
    Write-Host "SOME ITEMS MISSING!"
}
