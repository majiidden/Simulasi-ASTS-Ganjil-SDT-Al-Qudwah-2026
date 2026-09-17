$matches = Select-String -Path 'Kode.gs.txt' -Pattern 'validateExamPIN|pinSesi|without.*pin' -Context 2,8
$matches | Select-Object -First 5 | ForEach-Object {
    "Line $($_.LineNumber): $($_.Line)"
    $_.Context.PostContext | ForEach-Object { "  $_" }
}
