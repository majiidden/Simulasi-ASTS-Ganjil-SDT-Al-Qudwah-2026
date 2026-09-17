$bytes = [System.IO.File]::ReadAllBytes('Logo CBT Web App.jpeg')
$b64 = [System.Convert]::ToBase64String($bytes)
[System.IO.File]::WriteAllText('scratch/logo_base64.txt', $b64)
Write-Host "Done, length: $($b64.Length)"
