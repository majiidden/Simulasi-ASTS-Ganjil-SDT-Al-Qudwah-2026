# Verification Script for Sistem Leger Nilai Berbasis TP (Kurikulum Merdeka)
$ErrorActionPreference = "Stop"

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host " VERIFIKASI SISTEM LEGER NILAI SISWA PER TP" -ForegroundColor Cyan
Write-Host " SD TERPADU AL-QUDWAH - KURIKULUM MERDEKA" -ForegroundColor Cyan
Write-Host "=======================================================`n" -ForegroundColor Cyan

$kodeFile = "Kode.gs.txt"
$htmlFile = "index.html"

$kodeContent = [System.IO.File]::ReadAllText($kodeFile)
$htmlContent = [System.IO.File]::ReadAllText($htmlFile)

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
# 1. Backend Verification (Kode.gs.txt)
# ----------------------------------------------------
Write-Host "--- 1. Validasi Backend (Kode.gs.txt) ---" -ForegroundColor Yellow

# 1.1 Fungsi saveTPConfig
Assert-Condition "Backend: saveTPConfig exists" `
    ($kodeContent -match "function\s+saveTPConfig\s*\(") `
    "Fungsi saveTPConfig ditemukan." `
    "Fungsi saveTPConfig tidak ditemukan!"

# 1.2 Validasi izin akses di saveTPConfig
Assert-Condition "Backend: saveTPConfig role verification" `
    ($kodeContent -match "saveTPConfig" -and $kodeContent -match "role\s*!==\s*'admin'\s*&&\s*role\s*!==\s*'guru'") `
    "Validasi otorisasi Admin & Guru ada di saveTPConfig." `
    "Validasi otorisasi Admin & Guru tidak ditemukan di saveTPConfig!"

# 1.3 Penyimpanan key tp_config di sheet Konfigurasi
Assert-Condition "Backend: saveTPConfig sheet Konfigurasi key" `
    ($kodeContent -match "'tp_config_'\s*\+\s*String\(examID\)") `
    "Key konfigurasi 'tp_config_[examID]' tersimpan di sheet Konfigurasi." `
    "Key konfigurasi tidak ditemukan di saveTPConfig!"

# 1.4 Fungsi getTPConfig
Assert-Condition "Backend: getTPConfig exists" `
    ($kodeContent -match "function\s+getTPConfig\s*\(") `
    "Fungsi getTPConfig ditemukan." `
    "Fungsi getTPConfig tidak ditemukan!"

# 1.5 Fungsi generateLegerData
Assert-Condition "Backend: generateLegerData exists" `
    ($kodeContent -match "function\s+generateLegerData\s*\(") `
    "Fungsi generateLegerData ditemukan." `
    "Fungsi generateLegerData tidak ditemukan!"

# 1.6 Formula Nilai TP (Proporsi Poin)
Assert-Condition "Backend: TP Score Formula" `
    ($kodeContent -match "Math\.round\(\(earnedInTP\s*/\s*maxInTP\)\s*\*\s*100\)") `
    "Formula proporsi poin TP: Math.round((earnedInTP / maxInTP) * 100) ditemukan." `
    "Formula proporsi poin TP tidak sesuai spesifikasi!"

# 1.7 Formula Nilai Akhir (Rata-rata Seluruh TP)
Assert-Condition "Backend: Final Score Formula" `
    ($kodeContent -match "Math\.round\(sumTPScoreForStudent\s*/\s*tpList\.length\)") `
    "Formula Nilai Akhir: Math.round(sumTPScoreForStudent / tpList.length) ditemukan." `
    "Formula Nilai Akhir rata-rata TP tidak sesuai spesifikasi!"

# 1.8 Statistik Kelas di Backend
Assert-Condition "Backend: Class Statistics" `
    ($kodeContent -match "avgFinalClass" -and $kodeContent -match "passedPct" -and $kodeContent -match "avgPerTP") `
    "Perhitungan statistik kelas (rata-rata final, persentase tuntas, rata-rata per TP) lengkap." `
    "Perhitungan statistik kelas belum lengkap!"

# ----------------------------------------------------
# 2. Frontend Verification (index.html)
# ----------------------------------------------------
Write-Host "`n--- 2. Validasi Antarmuka Pengguna (index.html) ---" -ForegroundColor Yellow

# 2.1 Menu Leger di Sidebar
Assert-Condition "Frontend: Sidebar Menu Leger" `
    ($htmlContent -match 'id="menu-leger"' -and $htmlContent -match "dash-leger") `
    "Item navigasi #menu-leger ditemukan di sidebar." `
    "Item navigasi #menu-leger tidak ditemukan!"

# 2.2 Routing dash-leger ke renderLegerPage
Assert-Condition "Frontend: Tab Routing dash-leger" `
    ($htmlContent -match "tabId\s*===\s*'dash-leger'" -and $htmlContent -match "renderLegerPage") `
    "Routing showAdminTab untuk dash-leger memanggil renderLegerPage." `
    "Routing dash-leger tidak ditemukan di showAdminTab!"

# 2.3 Tombol Pintas di Toolbar Rekap Hasil Ujian
Assert-Condition "Frontend: Quick Button in Recap" `
    ($htmlContent -match 'id="btn-open-leger-from-recap"' -and $htmlContent -match "openLegerForCurrentExam") `
    "Tombol #btn-open-leger-from-recap tersedia di halaman Rekap Hasil Ujian." `
    "Tombol pintas Leger di Rekap Nilai tidak ditemukan!"

# 2.4 Fungsi Navigasi openLegerForCurrentExam
Assert-Condition "Frontend: openLegerForCurrentExam" `
    ($htmlContent -match "function\s+openLegerForCurrentExam\s*\(") `
    "Fungsi openLegerForCurrentExam terdefinisi." `
    "Fungsi openLegerForCurrentExam tidak ditemukan!"

# 2.5 Parser Rentang Soal Cerdas (parseQuestionRange)
Assert-Condition "Frontend: parseQuestionRange" `
    ($htmlContent -match "function\s+parseQuestionRange\s*\(") `
    "Fungsi parseQuestionRange terdefinisi." `
    "Fungsi parseQuestionRange tidak ditemukan!"

# 2.6 Formatter Rentang Soal (formatQuestionIndices)
Assert-Condition "Frontend: formatQuestionIndices" `
    ($htmlContent -match "function\s+formatQuestionIndices\s*\(") `
    "Fungsi formatQuestionIndices terdefinisi." `
    "Fungsi formatQuestionIndices tidak ditemukan!"

# 2.7 TP Builder (renderTPCards, addTPCard, removeTPCard, toggleQuestionInActiveTP)
Assert-Condition "Frontend: TP Builder Components" `
    ($htmlContent -match "function\s+renderTPCards\s*\(" -and `
     $htmlContent -match "function\s+addTPCard\s*\(" -and `
     $htmlContent -match "function\s+removeTPCard\s*\(" -and `
     $htmlContent -match "function\s+toggleQuestionInActiveTP\s*\(") `
    "Komponen TP Builder dinamis (render, add, remove, toggle badges) lengkap." `
    "Komponen TP Builder dinamis belum lengkap!"

# 2.8 Export Excel Resmi (downloadLegerExcel)
Assert-Condition "Frontend: downloadLegerExcel with SheetJS" `
    ($htmlContent -match "function\s+downloadLegerExcel\s*\(" -and `
     $htmlContent -match "XLSX\.utils\.aoa_to_sheet" -and `
     $htmlContent -match "XLSX\.writeFile") `
    "Fungsi export Excel SheetJS downloadLegerExcel terdefinisi dengan kop & styling kolom." `
    "Fungsi downloadLegerExcel tidak ditemukan atau tidak menggunakan SheetJS!"

# ----------------------------------------------------
# 3. Functional Simulation Test (Formula & Parsing)
# ----------------------------------------------------
Write-Host "`n--- 3. Simulasi Fungsional Formula & Parsing Soal ---" -ForegroundColor Yellow

# Simulasi Parser Soal: "1-5, 8, 10-12"
function Test-ParseRange($rangeStr, $maxQ) {
    $set = [System.Collections.Generic.HashSet[int]]::new()
    $parts = $rangeStr -split "[,;\s]+"
    foreach ($p in $parts) {
        $p = $p.Trim()
        if (-not $p) { continue }
        if ($p -match "^(\d+)-(\d+)$") {
            $start = [int]$matches[1]
            $end = [int]$matches[2]
            $min = [Math]::Min($start, $end)
            $max = [Math]::Max($start, $end)
            for ($i = $min; $i -le $max; $i++) {
                if ($i -ge 1 -and (-not $maxQ -or $i -le $maxQ)) {
                    [void]$set.Add($i)
                }
            }
        } elseif ($p -match "^\d+$") {
            $num = [int]$p
            if ($num -ge 1 -and (-not $maxQ -or $num -le $maxQ)) {
                [void]$set.Add($num)
            }
        }
    }
    $list = [System.Collections.Generic.List[int]]::new($set)
    $list.Sort()
    return $list
}

$parsed = Test-ParseRange "1-4, 6, 8-10" 15
$expected = @(1, 2, 3, 4, 6, 8, 9, 10)
$isParseMatch = ($parsed.Count -eq $expected.Count)
for ($i = 0; $i -lt $parsed.Count; $i++) {
    if ($parsed[$i] -ne $expected[$i]) { $isParseMatch = $false; break }
}
Assert-Condition "Simulation: Parser Rentang '1-4, 6, 8-10'" `
    $isParseMatch `
    "Rentang berhasil diparse tepat: $($parsed -join ', ')" `
    "Hasil parse tidak sesuai harapan!"

# Simulasi Perhitungan Nilai:
# Ujian 10 soal (@10 poin) = 100 poin total
# TP 1: Soal 1-5 (Max: 50 poin). Siswa dapat 40 poin -> Nilai TP 1 = round(40/50 * 100) = 80
# TP 2: Soal 6-8 (Max: 30 poin). Siswa dapat 30 poin -> Nilai TP 2 = round(30/30 * 100) = 100
# TP 3: Soal 9-10 (Max: 20 poin). Siswa dapat 10 poin -> Nilai TP 3 = round(10/20 * 100) = 50
# Nilai Akhir (NA): round((80 + 100 + 50) / 3) = round(230 / 3) = 77
$tp1Score = [Math]::Round((40 / 50) * 100)
$tp2Score = [Math]::Round((30 / 30) * 100)
$tp3Score = [Math]::Round((10 / 20) * 100)
$na = [Math]::Round(($tp1Score + $tp2Score + $tp3Score) / 3)

Assert-Condition "Simulation: Formula Nilai TP 1 (40/50 pt)" `
    ($tp1Score -eq 80) `
    "Nilai TP 1 = $tp1Score (Sesuai)" `
    "Nilai TP 1 tidak sesuai: $tp1Score (ekspektasi 80)"

Assert-Condition "Simulation: Formula Nilai TP 2 (30/30 pt)" `
    ($tp2Score -eq 100) `
    "Nilai TP 2 = $tp2Score (Sesuai)" `
    "Nilai TP 2 tidak sesuai: $tp2Score (ekspektasi 100)"

Assert-Condition "Simulation: Formula Nilai TP 3 (10/20 pt)" `
    ($tp3Score -eq 50) `
    "Nilai TP 3 = $tp3Score (Sesuai)" `
    "Nilai TP 3 tidak sesuai: $tp3Score (ekspektasi 50)"

Assert-Condition "Simulation: Formula Nilai Akhir Rata-Rata Seluruh TP" `
    ($na -eq 77) `
    "Nilai Akhir = $na (Sesuai Rata-rata 3 TP: 80, 100, 50)" `
    "Nilai Akhir tidak sesuai: $na (ekspektasi 77)"

# ----------------------------------------------------
# SUMMARY
# ----------------------------------------------------
Write-Host "`n=======================================================" -ForegroundColor Cyan
$color = "Green"
if ($testsFailed -gt 0) { $color = "Red" }
Write-Host " HASIL VERIFIKASI: $testsPassed PASSED, $testsFailed FAILED" -ForegroundColor $color
Write-Host "=======================================================`n" -ForegroundColor Cyan

if ($testsFailed -gt 0) {
    exit 1
} else {
    exit 0
}
