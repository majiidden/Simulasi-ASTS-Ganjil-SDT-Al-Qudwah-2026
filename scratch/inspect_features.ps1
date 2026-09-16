$lines = Get-Content -Path 'index.html'
$inSidebar = $false
$count = 0
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'id="admin-sidebar"') {
        $inSidebar = $true
    }
    if ($inSidebar) {
        if ($lines[$i] -match '<button|<a|onclick|switchTab') {
            $lines[$i].Trim()
            $count++
            if ($count -gt 35) { break }
        }
        if ($lines[$i] -match '</aside>|</div>' -and $count -gt 25) {
            # continue
        }
    }
}


