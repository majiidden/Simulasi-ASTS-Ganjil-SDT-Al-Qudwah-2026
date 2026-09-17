$lines = Get-Content -Path 'Kode.gs.txt'
$sessionMatches = $lines | Select-String -Pattern 'SessionToken|loginUser|verifySession' -Context 2,5
$sessionMatches | Select-Object -First 10 | ForEach-Object {
    "Line $($_.LineNumber): $($_.Line)"
    $_.Context.PostContext | ForEach-Object { "  $_" }
}
