try {
    $r1 = Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js' -Method Head -UseBasicParsing
    Write-Host "JSZip status: $($r1.StatusCode)"
} catch {
    Write-Host "JSZip error: $_"
}

try {
    $r2 = Invoke-WebRequest -Uri 'https://cdn.jsdelivr.net/npm/docx@8.5.0/build/index.umd.js' -Method Head -UseBasicParsing
    Write-Host "Docx status: $($r2.StatusCode)"
} catch {
    Write-Host "Docx error: $_"
}
