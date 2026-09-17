# Verification Script for Luxury Icon Toolbar in Leger Nilai TP
$ErrorActionPreference = "Stop"

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host " VERIFIKASI: LUXURY SVG ICON TOOLBAR & FLOATING TOOLTIPS" -ForegroundColor Cyan
Write-Host " MENU LEGER NILAI TP KURIKULUM MERDEKA" -ForegroundColor Cyan
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
# 1. Container & Responsive Layout
# ----------------------------------------------------
Write-Host "--- 1. Validasi Kontainer Toolbar & Responsivitas Mobile ---" -ForegroundColor Yellow

Assert-Condition "Toolbar Container ID & Classes" `
    ($htmlContent -match 'id="leger-action-toolbar"' -and $htmlContent -match 'overflow-visible') `
    "Kontainer toolbar (#leger-action-toolbar) terpasang dengan overflow-visible." `
    "Kontainer toolbar tidak sesuai spesifikasi!"

Assert-Condition "Functional Dividers" `
    ($htmlContent -match 'id="divider-leger-1"' -and $htmlContent -match 'id="divider-leger-2"') `
    "Dua garis pemisah kluster fungsional (#divider-leger-1 & #divider-leger-2) terpasang." `
    "Garis pemisah kluster tidak ditemukan!"

# ----------------------------------------------------
# 2. All 8 Action Buttons & Squircle Luxury Styling
# ----------------------------------------------------
Write-Host "`n--- 2. Validasi 8 Tombol Ikon & Squircle Styling ---" -ForegroundColor Yellow

$btnList = @(
    @{ id = "btn-open-tp-wizard"; name = "Atur TP Wizard"; grad = "from-purple-600" },
    @{ id = "btn-download-leger-excel"; name = "Leger Kelas Excel"; grad = "from-emerald-600" },
    @{ id = "btn-download-all-student-reports"; name = "Semua Rapor XLSX"; grad = "from-teal-600" },
    @{ id = "btn-download-all-student-docx"; name = "Semua Rapor ZIP"; grad = "from-indigo-600" },
    @{ id = "btn-download-single-student-docx"; name = "Rapor Siswa Word"; grad = "from-blue-600" },
    @{ id = "btn-download-single-student-excel"; name = "Rapor Siswa Excel"; grad = "from-emerald-500" },
    @{ id = "btn-open-report-settings"; name = "Atur Halaman Rapor"; grad = "from-slate-800" },
    @{ id = "btn-print-student-card"; name = "Cetak Browser"; grad = "from-slate-600" }
)

foreach ($btn in $btnList) {
    $btnId = $btn.id
    $btnName = $btn.name
    $grad = $btn.grad
    $hasBtn = $htmlContent -match "id=`"$btnId`""
    $hasStyle = $htmlContent -match "(?s)$btnId.*?w-11 h-11 rounded-2xl.*?$grad"
    Assert-Condition "Button: $btnName (#$btnId)" `
        ($hasBtn -and $hasStyle) `
        "Tombol $btnName terpasang sebagai squircle w-11 h-11 rounded-2xl dengan gradien $grad." `
        "Tombol $btnName (#$btnId) belum sesuai spesifikasi!"
}

# ----------------------------------------------------
# 3. Tooltip 2 Baris Presisi
# ----------------------------------------------------
Write-Host "`n--- 3. Validasi Floating Dark-Glass Tooltip 2 Baris ---" -ForegroundColor Yellow

$tooltips = @(
    "ATUR TP (WIZARD)",
    "LEGER KELAS (.XLSX)",
    "SEMUA RAPOR KELAS (.XLSX)",
    "SEMUA RAPOR KELAS (.ZIP)",
    "RAPOR SISWA (.DOCX)",
    "RAPOR SISWA (.XLSX)",
    "ATUR HALAMAN",
    "CETAK BROWSER"
)

foreach ($tt in $tooltips) {
    Assert-Condition "Tooltip: $tt" `
        ($htmlContent.Contains($tt)) `
        "Judul tooltip '$tt' tersedia di markup." `
        "Tooltip '$tt' TIDAK DITEMUKAN!"
}

Assert-Condition "Tooltip Styling & Caret Triangle" `
    ($htmlContent -match 'bg-slate-900/95 backdrop-blur-md' -and $htmlContent -match 'rotate-45 absolute -top-1') `
    "Tooltip dilengkapi styling dark-glass, border halus, dan segitiga penunjuk mikro (caret)." `
    "Styling dark-glass tooltip / caret tidak lengkap!"

# ----------------------------------------------------
# 4. JavaScript Divider & Visibility Handlers
# ----------------------------------------------------
Write-Host "`n--- 4. Validasi Logika Sinkronisasi Divider di JS ---" -ForegroundColor Yellow

Assert-Condition "JS: onLegerExamChange unhide dividers" `
    ($htmlContent -match "(?s)onLegerExamChange.*?divider-leger-1.*?div1\.classList\.remove\('hidden'\)") `
    "onLegerExamChange membuka pembatas kluster ketika ujian dipilih." `
    "Logika unhide divider pada onLegerExamChange tidak ditemukan!"

Assert-Condition "JS: onLegerExamChange hide dividers on reset" `
    ($htmlContent -match "(?s)onLegerExamChange.*?divider-leger-1.*?div1\.classList\.add\('hidden'\)") `
    "onLegerExamChange menyembunyikan pembatas kluster jika reset ujian." `
    "Logika hide divider pada onLegerExamChange tidak ditemukan!"

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
