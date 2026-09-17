# Verification script for Precision Excel Export (Leger Nilai & Rapor Siswa)
$htmlFile = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\index.html"
$htmlContent = Get-Content -Path $htmlFile -Raw -Encoding UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFIKASI FITUR EKSPOR EXCEL PRESISI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$checks = @(
    @{ Name = "Function buildStudentReportAOA exists"; Pattern = "function\s+buildStudentReportAOA\s*\(" },
    @{ Name = "Function downloadSingleStudentReportExcel exists"; Pattern = "function\s+downloadSingleStudentReportExcel\s*\(" },
    @{ Name = "Function downloadAllStudentReportsExcel exists"; Pattern = "function\s+downloadAllStudentReportsExcel\s*\(" },
    @{ Name = "Function downloadLegerExcel exists"; Pattern = "function\s+downloadLegerExcel\s*\(" },
    @{ Name = "Button btn-download-leger-excel exists"; Pattern = "id=[""']btn-download-leger-excel[""']" },
    @{ Name = "Button btn-download-all-student-reports exists"; Pattern = "id=[""']btn-download-all-student-reports[""']" },
    @{ Name = "Button btn-download-single-student-excel exists"; Pattern = "id=[""']btn-download-single-student-excel[""']" },
    @{ Name = "Button btn-print-student-card exists"; Pattern = "id=[""']btn-print-student-card[""']" },
    @{ Name = "A4 Landscape pageSetup for Leger"; Pattern = "orientation:\s*['""]landscape['""],\s*paperSize:\s*9" },
    @{ Name = "A4 Portrait pageSetup for Student Report"; Pattern = "orientation:\s*['""]portrait['""],\s*paperSize:\s*9" },
    @{ Name = "Excel showGridLines enabled"; Pattern = "showGridLines:\s*true" },
    @{ Name = "Signature block for Headmaster and Teacher in Leger"; Pattern = "Kepala SD Terpadu Al-Qudwah" },
    @{ Name = "Signature block for Parents and Teacher in Student Report"; Pattern = "Orang Tua / Wali Siswa" },
    @{ Name = "Student Card Banner has Excel download button"; Pattern = "downloadSingleStudentReportExcel\('\$\{st\.studentId\}'\)" }
)

$passed = 0
$failed = 0

foreach ($c in $checks) {
    if ($htmlContent -match $c.Pattern) {
        Write-Host "[PASS] $($c.Name)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "[FAIL] $($c.Name)" -ForegroundColor Red
        $failed++
    }
}

Write-Host "----------------------------------------"
$color = if ($failed -eq 0) { "Green" } else { "Red" }
Write-Host "Hasil: $passed PASS, $failed FAIL" -ForegroundColor $color

if ($failed -gt 0) {
    exit 1
} else {
    Write-Host "Semua verifikasi fitur ekspor excel presisi BERHASIL!" -ForegroundColor Green
}

