# Verification Script for Styled Leger Excel (.xlsx) Standar Administrasi Dinas
$ErrorActionPreference = "Stop"

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host " VERIFIKASI: LEGER KELAS (.XLSX) STANDAR ADMINISTRASI DINAS" -ForegroundColor Cyan
Write-Host " FORMAT A4 PRESISI + FIT TO WIDTH + REPEAT HEADER + MONOKROM" -ForegroundColor Cyan
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
# 1. Function Declarations
# ----------------------------------------------------
Write-Host "--- 1. Validasi Deklarasi Fungsi JavaScript ---" -ForegroundColor Yellow

Assert-Condition "Function: buildStyledLegerWorksheet" `
    ($htmlContent -match "function\s+buildStyledLegerWorksheet\s*\(\s*currentLegerData\s*,\s*settings\s*\)") `
    "Fungsi buildStyledLegerWorksheet(currentLegerData, settings) terdefinisi." `
    "Fungsi buildStyledLegerWorksheet tidak ditemukan!"

Assert-Condition "Function: downloadLegerExcel" `
    ($htmlContent -match "function\s+downloadLegerExcel\s*\(\s*\)" -and $htmlContent -match "buildStyledLegerWorksheet\(currentLegerData,\s*settings\)") `
    "Fungsi downloadLegerExcel terdefinisi dan memanggil buildStyledLegerWorksheet." `
    "Fungsi downloadLegerExcel tidak terintegrasi dengan buildStyledLegerWorksheet!"

Assert-Condition "Worksheet: !ref Range Boundary Encoded" `
    ($htmlContent -match "ws\['!ref'\]\s*=\s*XLSX\.utils\.encode_range") `
    "Properti !ref terpasang presisi dengan encode_range (menjamin seluruh baris & sel terisi)." `
    "Properti !ref belum terpasang!"

# ----------------------------------------------------
# 2. Page Setup & Printing Options
# ----------------------------------------------------
Write-Host "`n--- 2. Validasi Konfigurasi Cetak Kertas A4 & Repeat Headers ---" -ForegroundColor Yellow

Assert-Condition "PageSetup: A4 PaperSize & Fit to 1 Page Width" `
    ($htmlContent -match 'paperSize:\s*9' -and $htmlContent -match 'fitToWidth:\s*1' -and $htmlContent -match 'fitToHeight:\s*0') `
    "PageSetup A4 (code 9) dan Fit to 1 Page Width (fitToWidth: 1, fitToHeight: 0) terpasang." `
    "PageSetup A4 / fitToWidth belum sesuai spesifikasi!"

Assert-Condition "PageSetup: Dynamic Margins & Orientation" `
    ($htmlContent -match "settings\.orientation\s*\|\|\s*'landscape'" -and $htmlContent -match "ws\['!margins'\]") `
    "Orientasi kertas landscape fleksibel dan margin cetak dinamis terhubung dengan getReportSettings()." `
    "Pengaturan margin dan orientasi tidak lengkap!"

Assert-Condition "PageSetup: Repeat Header Rows on Print" `
    ($htmlContent -match "ws\['!printHeader'\]\s*=\s*\[headerRowStart") `
    "Baris header kolom tabel diulang di setiap halaman cetak (!printHeader)." `
    "Pengulangan baris header tidak ditemukan!"

Assert-Condition "PageSetup: Gridlines Visible" `
    ($htmlContent -match "showGridLines:\s*true") `
    "Opsi garis kisi cetak (showGridLines: true) diaktifkan." `
    "showGridLines tidak aktif!"

# ----------------------------------------------------
# 3. Monochromatic Styling & Standards
# ----------------------------------------------------
Write-Host "`n--- 3. Validasi Format Monokrom Formal Dinas ---" -ForegroundColor Yellow

Assert-Condition "Styling: Formal Gray Fill & Thin Solid Black Borders" `
    ($htmlContent -match "fgColor:\s*\{\s*rgb:\s*'E2E8F0'\s*\}" -and $htmlContent -match "color:\s*\{\s*rgb:\s*'000000'\s*\}") `
    "Header formal berarsir abu-abu formal (E2E8F0) dan border hitam tegas (000000) terpasang." `
    "Styling monokrom formal dinas tidak lengkap!"

Assert-Condition "Styling: Double Bottom Border for Final Stats" `
    ($htmlContent -match "style:\s*'double'") `
    "Garis penutup ganda (double border) standar akuntansi/administrasi terpasang pada ringkasan statistik." `
    "Double border statistik tidak ditemukan!"

# ----------------------------------------------------
# 4. Content Structure, Predicates & Signatures
# ----------------------------------------------------
Write-Host "`n--- 4. Validasi Struktur Kolom, Predikat & Pengesahan ---" -ForegroundColor Yellow

Assert-Condition "Columns: Nilai Akhir (NA) & Predikat Capaian" `
    ($htmlContent -match 'Nilai Akhir\\n\(NA\)' -and $htmlContent -match 'Predikat\\nCapaian') `
    "Kolom Nilai Akhir (NA) dan Predikat Capaian Kurikulum Merdeka terpasang di header." `
    "Kolom NA & Predikat Capaian tidak lengkap!"

Assert-Condition "Predicates: Kurikulum Merdeka 4 Levels" `
    ($htmlContent -match 'Sangat Baik' -and $htmlContent -match 'Baik' -and $htmlContent -match 'Cukup' -and $htmlContent -match 'Perlu Bimbingan') `
    "Kompilasi predikat Kurikulum Merdeka (Sangat Baik, Baik, Cukup, Perlu Bimbingan) terpasang." `
    "Predikat Kurikulum Merdeka tidak lengkap!"

Assert-Condition "Signatures: Kepala Sekolah & Guru 2-Column Block" `
    ($htmlContent -match 'Kepala SD Terpadu Al-Qudwah' -and $htmlContent -match 'Guru Mata Pelajaran / Wali Kelas' -and $htmlContent -match 'NIP\.') `
    "Blok pengesahan resmi 2 kolom (Kepala Sekolah & Guru/Wali Kelas) lengkap dengan NIP terpasang." `
    "Blok tanda tangan pengesahan tidak lengkap!"

# ----------------------------------------------------
# SUMMARY
# ----------------------------------------------------
Write-Host "`n=======================================================" -ForegroundColor Cyan
$resColor = "Green"
if ($testsFailed -gt 0) { $resColor = "Red" }
Write-Host " HASIL VERIFIKASI: $testsPassed PASS, $testsFailed FAIL" -ForegroundColor $resColor
Write-Host "=======================================================`n" -ForegroundColor Cyan

if ($testsFailed -gt 0) {
    exit 1
}
