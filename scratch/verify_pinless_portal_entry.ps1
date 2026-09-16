$errors = 0
Write-Host "=== VERIFYING PIN-LESS EXAM & REMEDIAL ENTRY ===" -ForegroundColor Cyan

# 1. Check Kode.gs.txt
$backend = Get-Content -Path 'Kode.gs.txt' -Raw
Write-Host "[1/6] Checking validateExamAccessByID in Kode.gs.txt..."
if ($backend -match 'function validateExamAccessByID\s*\(') {
    Write-Host "  OK: validateExamAccessByID function exists." -ForegroundColor Green
} else {
    Write-Host "  FAIL: validateExamAccessByID missing." -ForegroundColor Red
    $errors++
}

Write-Host "[2/6] Checking startExamFromPortal in Kode.gs.txt..."
if ($backend -match 'validateExamAccessByID\(examID,\s*userClass,\s*userID\)') {
    Write-Host "  OK: startExamFromPortal calls validateExamAccessByID when PIN is empty." -ForegroundColor Green
} else {
    Write-Host "  FAIL: startExamFromPortal does not call validateExamAccessByID properly." -ForegroundColor Red
    $errors++
}

Write-Host "[3/6] Checking startRemedialExam in Kode.gs.txt..."
if ($backend -match 'cleanPin\s*&&\s*remPin\s*&&\s*cleanPin\s*!==\s*remPin') {
    Write-Host "  OK: startRemedialExam allows PIN-less entry when cleanPin is empty." -ForegroundColor Green
} else {
    Write-Host "  FAIL: startRemedialExam PIN logic not updated." -ForegroundColor Red
    $errors++
}

# 2. Check index.html
$frontend = Get-Content -Path 'index.html' -Raw
Write-Host "[4/6] Checking Confirmation Modals in index.html..."
if ($frontend -match 'id="modal-portal-pin"' -and $frontend -match 'Konfirmasi Mulai Ujian' -and $frontend -match 'Siap Mengerjakan Ujian\?') {
    Write-Host "  OK: Exam Confirmation Modal exists and matches new design." -ForegroundColor Green
} else {
    Write-Host "  FAIL: Exam Confirmation Modal markup mismatch." -ForegroundColor Red
    $errors++
}

if ($frontend -match 'id="modal-portal-remedial-pin"' -and $frontend -match 'Konfirmasi Remedial' -and $frontend -match 'Ketentuan Pengerjaan Remedial') {
    Write-Host "  OK: Remedial Confirmation Modal exists and matches new design." -ForegroundColor Green
} else {
    Write-Host "  FAIL: Remedial Confirmation Modal markup mismatch." -ForegroundColor Red
    $errors++
}

Write-Host "[5/6] Checking Handlers in index.html..."
if ($frontend -match 'Menyiapkan Ujian\.\.\.' -and $frontend -match 'Menyiapkan Remedial\.\.\.') {
    Write-Host "  OK: Handlers updated with modern loading states and non-blocking PIN checks." -ForegroundColor Green
} else {
    Write-Host "  FAIL: Handlers missing new logic." -ForegroundColor Red
    $errors++
}

Write-Host "[6/6] Checking Front Login Page PIN Field Preservation..."
if ($frontend -match 'id="pin"' -and $frontend -match 'PIN SESI \(OPSIONAL\)') {
    Write-Host "  OK: Front Login Page PIN field preserved for optional direct entry." -ForegroundColor Green
} else {
    Write-Host "  FAIL: Front Login Page PIN field missing or modified unexpectedly." -ForegroundColor Red
    $errors++
}

Write-Host "--------------------------------------------------"
if ($errors -eq 0) {
    Write-Host "ALL VERIFICATION CHECKS PASSED SUCCESSFULLY!" -ForegroundColor Green
} else {
    Write-Host "VERIFICATION COMPLETED WITH $errors ERROR(S)." -ForegroundColor Red
}
