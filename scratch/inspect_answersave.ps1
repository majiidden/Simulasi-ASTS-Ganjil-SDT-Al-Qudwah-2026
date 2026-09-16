$matches = Select-String -Path @('Kode.gs.txt', 'index.html') -Pattern 'saveStudentAnswer|submitExam|saveAnswer'
if ($matches) {
    $matches | Select-Object -First 10 | ForEach-Object { "$($_.Filename):$($_.LineNumber): $($_.Line.Trim())" }
}
