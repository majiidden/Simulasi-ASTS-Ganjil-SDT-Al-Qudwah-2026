$raw = [System.IO.File]::ReadAllText('Kode.gs.txt', [System.Text.Encoding]::UTF8)
$c1 = 0
$c2 = 0
foreach ($ch in $raw.ToCharArray()) {
    if ($ch -eq '{') { $c1++ }
    elseif ($ch -eq '}') { $c2++ }
}
Write-Host "Open braces: $c1, Close braces: $c2"
if ($c1 -eq $c2) {
    Write-Host "BRACES BALANCED PERFECTLY!"
} else {
    Write-Host "MISMATCH: diff = $($c1 - $c2)"
}

$funcs = @('ensureResponsesDeviceColumns', 'loginUser', 'startExamFromPortal', 'getExamQuestions', 'syncAnswers', 'unlockStudentExam', 'resetStudentDevice', 'bulkUnlockStudents', 'getExamMonitorData')
foreach ($f in $funcs) {
    if ($raw.Contains($f)) {
        Write-Host "Function found: $f"
    } else {
        Write-Host "MISSING FUNCTION: $f"
    }
}
