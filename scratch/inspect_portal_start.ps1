$matches = Select-String -Path 'index.html' -Pattern 'openPortalPinModal|btn-start-exam|startExamFromPortal' -Context 2,10
$matches | Select-Object -First 3 | ForEach-Object {
    "Line $($_.LineNumber): $($_.Line)"
    $_.Context.PostContext | ForEach-Object { "  $_" }
}
