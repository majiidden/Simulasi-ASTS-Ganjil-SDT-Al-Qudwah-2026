$matches = Select-String -Path 'index.html' -Pattern 'login-pin|pin.*sesi|placeholder=".*PIN' -Context 2,4
$matches | Select-Object -First 3 | ForEach-Object {
    "Line $($_.LineNumber): $($_.Line)"
    $_.Context.PostContext | ForEach-Object { "  $_" }
}
