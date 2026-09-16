$matches = Select-String -Path 'index.html' -Pattern 'openPortalRemedialPinModal' -Context 2,5
$matches | Select-Object -First 3 | ForEach-Object {
    "Line $($_.LineNumber): $($_.Line)"
    $_.Context.PostContext | ForEach-Object { "  $_" }
}
