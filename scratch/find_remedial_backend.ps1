$matches = Select-String -Path 'Kode.gs.txt' -Pattern 'function startRemedialExam' -Context 0,20
$matches | ForEach-Object {
    "Line $($_.LineNumber): $($_.Line)"
    $_.Context.PostContext | ForEach-Object { "  $_" }
}
