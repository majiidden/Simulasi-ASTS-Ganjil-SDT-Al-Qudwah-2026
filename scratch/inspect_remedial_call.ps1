$matches = Select-String -Path 'index.html' -Pattern 'openPortalRemedialPinModal|modal-portal-remedial-pin' -Context 5,25
$matches | Select-Object -First 1 | ForEach-Object {
    "Line $($_.LineNumber): $($_.Line)"
    $_.Context.PostContext | ForEach-Object { "  $_" }
}
