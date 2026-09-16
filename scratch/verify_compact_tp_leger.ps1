# Verification Script for Compact TP Columns & Mini Reference Table in Leger Excel
$ErrorActionPreference = "Stop"

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host " VERIFIKASI: PERAMPINGAN KOLOM TP (TP 1, TP 2...)" -ForegroundColor Cyan
Write-Host " & TABEL REFERENSI BUNYI CAPAIAN TP (LEGER EXCEL)" -ForegroundColor Cyan
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
# 1. Compact TP Column Headers
# ----------------------------------------------------
Write-Host "--- 1. Validasi Header Kolom TP Ramping (1 Baris) ---" -ForegroundColor Yellow

Assert-Condition "TP Header: Kode Ringkas TP 1, TP 2..." `
    ($htmlContent -match 'setCell\(curRow,\s*colIdx,\s*`TP \$\{idx \+ 1\}`,\s*thStyle\)') `
    "Header kolom TP berupa kode ringkas 'TP 1', 'TP 2', dst." `
    "Header kolom TP tidak diringkas!"

Assert-Condition "TP Columns Width: wch 8 (Super Hemat)" `
    ($htmlContent -match "cols\.push\(\{\s*wch:\s*8\s*\}\)") `
    "Lebar kolom per TP disetel wch 8 (super hemat ruang horizontal)." `
    "Lebar kolom TP wch 8 tidak ditemukan!"

# ----------------------------------------------------
# 2. Mini Reference Table for TP Descriptions
# ----------------------------------------------------
Write-Host "`n--- 2. Validasi Tabel Mini Referensi Bunyi TP ---" -ForegroundColor Yellow

Assert-Condition "Section Title: Keterangan Capaian TP" `
    ($htmlContent -match 'KETERANGAN CAPAIAN TUJUAN PEMBELAJARAN \(TP\):') `
    "Judul seksi 'KETERANGAN CAPAIAN TUJUAN PEMBELAJARAN (TP):' tersedia di bawah tabel." `
    "Judul seksi referensi TP tidak ditemukan!"

Assert-Condition "Reference Table Header: 3 Kolom Formal" `
    ($htmlContent -match "'Kode TP'" -and `
     $htmlContent -match "'Deskripsi / Bunyi Tujuan Pembelajaran \(TP\)'" -and `
     $htmlContent -match "'Cakupan Soal & Bobot Poin'") `
    "Header tabel referensi TP (Kode TP | Deskripsi Bunyi TP | Cakupan Soal & Poin) terpasang." `
    "Header tabel referensi TP tidak lengkap!"

Assert-Condition "Reference Table Rows: Data TP & Soal" `
    ($htmlContent -match '`TP \$\{tIdx \+ 1\}`' -and `
     $htmlContent -match "descText" -and `
     $htmlContent -match "scopeText") `
    "Baris tabel referensi memuat kode TP, kalimat bunyi lengkap, dan nomor soal beserta bobot poin." `
    "Baris tabel referensi TP tidak lengkap!"

# ----------------------------------------------------
# 3. Sheet Boundary & Print Titles
# ----------------------------------------------------
Write-Host "`n--- 3. Validasi Batas Rentang Sel & Repeat Headers ---" -ForegroundColor Yellow

Assert-Condition "Worksheet: !ref Range Boundary Encoded" `
    ($htmlContent -match "ws\['!ref'\]\s*=\s*XLSX\.utils\.encode_range") `
    "Properti !ref terpasang presisi mencakup tabel data dan tabel referensi." `
    "Properti !ref tidak ditemukan!"

Assert-Condition "PageSetup: Single-Row Header Repeat" `
    ($htmlContent -match "ws\['!headerRowStart'\]\s*=\s*headerRowStart" -and `
     $htmlContent -match "ws\['!headerRowEnd'\]\s*=\s*headerRowStart") `
    "Pengulangan baris header diatur untuk 1 baris header terpadu." `
    "Pengulangan baris header tidak sesuai!"

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
