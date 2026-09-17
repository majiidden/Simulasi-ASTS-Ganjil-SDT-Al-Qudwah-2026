# Verification script for Student & Parent Monitoring Portal (Tahap 5)
$htmlPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\index.html"
$gsPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\Kode.gs.txt"

$html = Get-Content -Path $htmlPath -Raw
$gs = Get-Content -Path $gsPath -Raw

Write-Host "=== VERIFYING STUDENT & PARENT MONITORING PORTAL (TAHAP 5) ===" -ForegroundColor Cyan

$checks = @(
    @{ Name = "HTML: #page-student-portal exists"; Condition = $html.Contains('id="page-student-portal"') },
    @{ Name = "HTML: Modal PIN Sesi exists (#modal-portal-pin)"; Condition = $html.Contains('id="modal-portal-pin"') },
    @{ Name = "HTML: Print Card exists (#print-student-card)"; Condition = $html.Contains('id="print-student-card"') },
    @{ Name = "HTML: Tab buttons exist (btn-tab-portal-active, btn-tab-portal-history, btn-tab-portal-guide)"; Condition = $html.Contains('btn-tab-portal-active') -and $html.Contains('btn-tab-portal-history') -and $html.Contains('btn-tab-portal-guide') },
    @{ Name = "HTML: JS Controller openStudentPortal exists"; Condition = $html.Contains('function openStudentPortal(') },
    @{ Name = "HTML: JS Controller renderStudentPortal exists"; Condition = $html.Contains('function renderStudentPortal(') },
    @{ Name = "HTML: JS Controller switchStudentPortalTab exists"; Condition = $html.Contains('function switchStudentPortalTab(') },
    @{ Name = "HTML: JS Controller openPortalPinModal exists"; Condition = $html.Contains('function openPortalPinModal(') },
    @{ Name = "HTML: JS Controller handlePortalPinSubmit exists"; Condition = $html.Contains('function handlePortalPinSubmit(') },
    @{ Name = "HTML: JS Controller printStudentReportCard exists"; Condition = $html.Contains('function printStudentReportCard(') },
    @{ Name = "GS: loginUser PIN-less portal redirection"; Condition = $gs.Contains('openStudentPortal: true') },
    @{ Name = "GS: getStudentPortalData function exists"; Condition = $gs.Contains('function getStudentPortalData(') },
    @{ Name = "GS: startExamFromPortal function exists"; Condition = $gs.Contains('function startExamFromPortal(') }
)

$allPassed = $true
foreach ($chk in $checks) {
    if ($chk.Condition) {
        Write-Host "[PASS] $($chk.Name)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $($chk.Name)" -ForegroundColor Red
        $allPassed = $false
    }
}

if ($allPassed) {
    Write-Host "`nAll verification checks passed successfully!" -ForegroundColor Green
} else {
    Write-Host "`nSome checks failed!" -ForegroundColor Red
    exit 1
}
