$matches = Select-String -Path 'index.html' -Pattern 'startExamFromPortal|startRemedialExam'
$matches | ForEach-Object { "$($_.LineNumber): $($_.Line.Trim())" }
