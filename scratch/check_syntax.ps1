$content = Get-Content 'index.html' -Raw
$marker = '<script>'
$idx1 = $content.IndexOf($marker, 2500)
if ($idx1 -ge 0) {
    $idx1 += $marker.Length
    $idx2 = $content.LastIndexOf('</script>')
    $js = $content.Substring($idx1, $idx2 - $idx1)
    [System.IO.File]::WriteAllText('scratch/temp_check.js', $js, [System.Text.Encoding]::UTF8)
    Write-Host "Extracted JS length: $($js.Length) chars"
    $check = node --check scratch/temp_check.js 2>&1
    Write-Host "Node check result: $check"
} else {
    Write-Host "Marker not found"
}
