# PowerShell Verification Script for Sistem Remedial Berbasis KKTP
$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  VERIFIKASI FITUR REMEDIAL BERBASIS KKTP " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$gsPath = ".\Kode.gs.txt"
$htmlPath = ".\index.html"

$gsContent = Get-Content -Raw -Path $gsPath
$htmlContent = Get-Content -Raw -Path $htmlPath

$testsPassed = 0
$testsFailed = 0

function Assert-Contains {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$TestName
    )
    if ($Content -match $Pattern) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
        $script:testsPassed++
    } else {
        Write-Host "  [FAIL] $TestName (Pattern: $Pattern)" -ForegroundColor Red
        $script:testsFailed++
    }
}

Write-Host "`n1. Verifikasi Backend (Kode.gs.txt):" -ForegroundColor Yellow
Assert-Contains $gsContent 'function ensureResponsesRemedialColumns' "ensureResponsesRemedialColumns exists"
Assert-Contains $gsContent 'function approveRemedial' "approveRemedial exists"
Assert-Contains $gsContent 'function startRemedialExam' "startRemedialExam exists"
Assert-Contains $gsContent 'function submitRemedialExam' "submitRemedialExam exists"
Assert-Contains $gsContent 'Math\.round\(\(initialScore \+ remedialScore\) / 2\)' "Remedial average formula (Nilai Awal + Remedial)/2 exists"
Assert-Contains $gsContent 'hasApprovedRemedial' "getStudentPortalData returns hasApprovedRemedial"
Assert-Contains $gsContent 'isRemedialApproved' "getStudentPortalData formats isRemedialApproved"
Assert-Contains $gsContent 'kktp: examKKTP' "getExamResults returns KKTP"
Assert-Contains $gsContent 'const targetID = String\(examID \|\| ''''\)\.trim\(\);' "targetID safely initialized in getExamResults"

Write-Host "`n2. Verifikasi Frontend UI & Modal (index.html):" -ForegroundColor Yellow
Assert-Contains $htmlContent 'id="input-kktp"' "Exam modal has input-kktp"
Assert-Contains $htmlContent 'id="modal-approve-remedial"' "Teacher approval modal modal-approve-remedial exists"
Assert-Contains $htmlContent 'id="approve-remedial-pin-input"' "Approve modal has PIN input"
Assert-Contains $htmlContent 'id="approve-remedial-duration-input"' "Approve modal has duration input"
Assert-Contains $htmlContent 'id="btn-mass-remedial"' "Results page has btn-mass-remedial"
Assert-Contains $htmlContent 'id="portal-remedial-banner"' "Student portal has portal-remedial-banner"
Assert-Contains $htmlContent 'id="modal-portal-remedial-pin"' "Student portal has modal-portal-remedial-pin"
Assert-Contains $htmlContent 'id="portal-remedial-pin-input"' "Student modal has portal-remedial-pin-input"

Write-Host "`n3. Verifikasi Logika Frontend JS (index.html):" -ForegroundColor Yellow
Assert-Contains $htmlContent 'function openApproveRemedialModal' "openApproveRemedialModal exists"
Assert-Contains $htmlContent 'function openMassRemedialModal' "openMassRemedialModal exists"
Assert-Contains $htmlContent 'function handleApproveRemedialSubmit' "handleApproveRemedialSubmit exists"
Assert-Contains $htmlContent 'function openPortalRemedialPinModal' "openPortalRemedialPinModal exists"
Assert-Contains $htmlContent 'function handlePortalRemedialPinSubmit' "handlePortalRemedialPinSubmit exists"
Assert-Contains $htmlContent 'startRemedialExam\(selectedPortalRemedialExamID' "Client calls startRemedialExam with PIN"
Assert-Contains $htmlContent 'submitRemedialExam\(currentUser\.userID' "Client calls submitRemedialExam"
Assert-Contains $htmlContent 'isRemedial = Boolean\(examData && examData\.isRemedial\)' "initStudentExam detects isRemedial"
Assert-Contains $htmlContent 'SESI REMEDIAL UJIAN' "initStudentExam displays friendly Remedial prompt"
Assert-Contains $htmlContent 'TUNTAS \(REMEDIAL\)' "renderInternalTable displays Tuntas (Remedial)"
Assert-Contains $htmlContent 'Ikuti Remedial' "renderStudentPortal displays Ikuti Remedial button"

Write-Host "`n-----------------------------------------" -ForegroundColor Cyan
Write-Host "HASIL VERIFIKASI: $testsPassed PASSED, $testsFailed FAILED" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host "-----------------------------------------" -ForegroundColor Cyan

if ($testsFailed -gt 0) {
    exit 1
}
