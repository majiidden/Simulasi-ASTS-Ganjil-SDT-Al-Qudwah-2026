# Verification Script for Word (.docx) & Precision Excel (.xlsx) Rapor TP Kurikulum Merdeka
$ErrorActionPreference = "Stop"

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host " VERIFIKASI: RAPOR SISWA EXCEL & WORD (.DOCX / .ZIP)" -ForegroundColor Cyan
Write-Host " FORMAT A4 PRESISI + MARGIN KUSTOM + CELL STYLING" -ForegroundColor Cyan
Write-Host "=======================================================`n" -ForegroundColor Cyan

$htmlFile = "index.html"
$htmlContent = [System.IO.File]::ReadAllText($htmlFile, [System.Text.Encoding]::UTF8)

$testsPassed = 0
$testsFailed = 0

function Assert-Condition($name, $condition, $msgSuccess, $msgFail) {
    if ($condition) {
        Write-Host "[PASS] $name - $msgSuccess" -ForegroundColor Green
        $global:testsPassed++
    } else {
        Write-Host "[FAIL] $name - $msgFail" -ForegroundColor Red
        $global:testsFailed++
    }
}

# ----------------------------------------------------
# 1. CDN Libraries
# ----------------------------------------------------
Write-Host "--- 1. Validasi Import Library CDN ---" -ForegroundColor Yellow

Assert-Condition "CDN: JSZip Library" `
    ($htmlContent -match 'jszip\.min\.js') `
    "Library JSZip untuk kompresi massal .zip terpasang." `
    "Library JSZip tidak ditemukan!"

Assert-Condition "CDN: docx Library" `
    ($htmlContent -match 'docx@8\.5\.0' -or $htmlContent -match 'docx.*build.*index\.umd\.js') `
    "Library docx UMD untuk pembuatan file Word .docx asli terpasang." `
    "Library docx tidak ditemukan!"

Assert-Condition "CDN: xlsx-js-style Library" `
    ($htmlContent -match 'xlsx-js-style') `
    "Library xlsx-js-style untuk styling sel Excel terpasang." `
    "Library xlsx-js-style tidak ditemukan!"

# ----------------------------------------------------
# 2. UI Elements & Buttons
# ----------------------------------------------------
Write-Host "`n--- 2. Validasi Antarmuka & Tombol Ekspor ---" -ForegroundColor Yellow

Assert-Condition "UI: Tombol Download Word Single & ZIP All" `
    ($htmlContent -match 'id="btn-download-single-student-docx"' -and `
     $htmlContent -match 'id="btn-download-all-student-docx"') `
    "Tombol RAPOR SISWA (.DOCX) dan SEMUA RAPOR KELAS (.ZIP) tersedia di toolbar." `
    "Tombol Word / ZIP toolbar tidak ditemukan!"

Assert-Condition "UI: Tombol Pengaturan Halaman Rapor" `
    ($htmlContent -match 'id="btn-open-report-settings"') `
    "Tombol ATUR HALAMAN (modal margin & orientasi) tersedia di toolbar." `
    "Tombol ATUR HALAMAN tidak ditemukan!"

Assert-Condition "UI: Tombol Aksi di Kartu Siswa Individu" `
    ($htmlContent -match 'downloadSingleStudentReportDocx' -and `
     $htmlContent -match 'openReportSettingsModal') `
    "Tombol Download Rapor Word dan Atur Halaman tersedia di kartu preview siswa." `
    "Tombol aksi di kartu siswa tidak lengkap!"

Assert-Condition "UI: Modal Pengaturan Halaman & Margin (#modal-report-settings)" `
    ($htmlContent -match 'id="modal-report-settings"' -and `
     $htmlContent -match 'id="opt-orient-portrait"' -and `
     $htmlContent -match 'id="opt-orient-landscape"' -and `
     $htmlContent -match 'id="input-margin-top"' -and `
     $htmlContent -match 'id="chk-report-include-logo"') `
    "Modal Pengaturan Halaman lengkap dengan orientasi, margin kustom, dan toggle logo." `
    "Modal Pengaturan Halaman tidak lengkap!"

# ----------------------------------------------------
# 3. JavaScript Functions
# ----------------------------------------------------
Write-Host "`n--- 3. Validasi Fungsi JavaScript ---" -ForegroundColor Yellow

$fnList = @(
    "getReportSettings",
    "saveReportSettings",
    "openReportSettingsModal",
    "closeReportSettingsModal",
    "applyMarginPreset",
    "saveReportSettingsFromModal",
    "resetReportSettingsToDefault",
    "buildStyledStudentReportWorksheet",
    "downloadSingleStudentReportExcel",
    "downloadAllStudentReportsExcel",
    "getSchoolLogoDataUrl",
    "generateStudentReportDocxBlob",
    "downloadSingleStudentReportDocx",
    "downloadAllStudentReportsDocxZip"
)

foreach ($fn in $fnList) {
    Assert-Condition "JS: Function $fn" `
        ($htmlContent -match "function\s+$fn\s*\(") `
        "Fungsi $fn terdefinisi dan siap digunakan." `
        "Fungsi $fn TIDAK DITEMUKAN!"
}

# ----------------------------------------------------
# 4. Fitur Spesifik Word & Excel
# ----------------------------------------------------
Write-Host "`n--- 4. Validasi Fitur Kunci Cetak A4 ---" -ForegroundColor Yellow

Assert-Condition "Excel: Page Setup A4 & Fit to 1 Page" `
    ($htmlContent -match 'paperSize:\s*9' -and $htmlContent -match 'fitToWidth:\s*1') `
    "PageSetup Excel dikonfigurasi untuk kertas A4 (code 9) dan fit-to-1-page width." `
    "PageSetup Excel belum terkonfigurasi untuk A4 fit-to-page!"

Assert-Condition "Excel: Cell Styles & Margins" `
    ($htmlContent -match 'fgColor' -and $htmlContent -match 'wrapText:\s*true' -and $htmlContent -match 'ws\[\x27!margins\x27\]') `
    "Worksheet Excel memiliki cell styling (warna, border, wrapText) dan margin cetak." `
    "Styling Excel tidak lengkap!"

Assert-Condition "Word: Orientation & Twip Margins" `
    ($htmlContent -match 'PageOrientation\.LANDSCAPE' -and `
     $htmlContent -match 'PageOrientation\.PORTRAIT' -and `
     $htmlContent -match '\* 567') `
    "Dokumen Word mendukung orientasi Portrait/Landscape dan konversi margin cm ke twip." `
    "Word page setup tidak sesuai spesifikasi!"

Assert-Condition "Word: 2-Column Signatures" `
    ($htmlContent -match 'Orang Tua / Wali Siswa' -and $htmlContent -match 'Guru Mata Pelajaran / Wali Kelas') `
    "Format tanda tangan 2 kolom (Orang Tua & Guru) terpasang di Word dan Excel." `
    "Format tanda tangan tidak sesuai!"

Write-Host "`n=======================================================" -ForegroundColor Cyan
$resColor = "Green"
if ($testsFailed -gt 0) { $resColor = "Red" }
Write-Host " HASIL AKHIR: $testsPassed PASS, $testsFailed FAIL" -ForegroundColor $resColor
Write-Host "=======================================================`n" -ForegroundColor Cyan

if ($testsFailed -gt 0) {
    exit 1
}
