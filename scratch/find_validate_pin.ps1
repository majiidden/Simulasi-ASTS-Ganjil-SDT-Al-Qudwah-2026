$matches = Select-String -Path 'Kode.gs.txt' -Pattern 'function validateExamPIN' -Context 0,40
$matches | ForEach-Object {
    "Line $($_.LineNumber): $($_.Line)"
    $_.Context.PostContext | ForEach-Object { "  $_" }
}
