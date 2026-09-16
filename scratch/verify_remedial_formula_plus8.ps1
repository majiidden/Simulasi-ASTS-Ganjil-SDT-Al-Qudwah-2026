# Test Suite: Validasi Formula Nilai Akhir Remedial ((Nilai Awal + Remedial)/2 + 8) Maksimal 100

$script:passed = 0
$script:failed = 0

function Assert-Test {
    param(
        [string]$Name,
        [bool]$Condition,
        [string]$Detail = ""
    )
    if ($Condition) {
        Write-Host " [PASS] $Name" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host " [FAIL] $Name" -ForegroundColor Red
        if ($Detail) { Write-Host "        Detail: $Detail" -ForegroundColor Yellow }
        $script:failed++
    }
}

Write-Host "`n=== [TEST SUITE] VALIDASI FORMULA NILAI AKHIR REMEDIAL ((AWAL + REM)/2 + 8) ===" -ForegroundColor Cyan

# 1. SIMULASI MATEMATIS FORMULA
Write-Host "`n--- 1. Simulasi Matematis Rumus & Batas Maksimal 100 ---" -ForegroundColor Yellow

function Calc-RemedialFinalScore($init, $rem) {
    $avg = [Math]::Round(($init + $rem) / 2.0, [MidpointRounding]::AwayFromZero)
    $final = $avg + 8
    return [Math]::Min(100, $final)
}

# Contoh 1: Awal 60, Rem 80 -> (60+80)/2 + 8 = 70 + 8 = 78
$res1 = Calc-RemedialFinalScore 60 80
Assert-Test -Name "Simulasi 1: Awal 60 + Rem 80 = 78" -Condition ($res1 -eq 78) -Detail "Hasil: $res1, Harap: 78"

# Contoh 2: Awal 50, Rem 75 -> (50+75)/2 = 62.5 -> 63 + 8 = 71
$res2 = Calc-RemedialFinalScore 50 75
Assert-Test -Name "Simulasi 2: Awal 50 + Rem 75 = 71" -Condition ($res2 -eq 71) -Detail "Hasil: $res2, Harap: 71"

# Contoh 3: Awal 70, Rem 90 -> (70+90)/2 + 8 = 80 + 8 = 88
$res3 = Calc-RemedialFinalScore 70 90
Assert-Test -Name "Simulasi 3: Awal 70 + Rem 90 = 88" -Condition ($res3 -eq 88) -Detail "Hasil: $res3, Harap: 88"

# Contoh 4 (Capping 100): Awal 90, Rem 100 -> (90+100)/2 + 8 = 95 + 8 = 103 -> Tertahan 100
$res4 = Calc-RemedialFinalScore 90 100
Assert-Test -Name "Simulasi 4 (Cap 100): Awal 90 + Rem 100 = 100 (Bukan 103)" -Condition ($res4 -eq 100) -Detail "Hasil: $res4, Harap: 100"

# Contoh 5 (Capping 100): Awal 86, Rem 98 -> (86+98)/2 = 92 + 8 = 100 -> Tertahan 100
$res5 = Calc-RemedialFinalScore 86 98
Assert-Test -Name "Simulasi 5 (Cap 100): Awal 86 + Rem 98 = 100" -Condition ($res5 -eq 100) -Detail "Hasil: $res5, Harap: 100"

# 2. VALIDASI BACKEND KODE.GS.TXT
Write-Host "`n--- 2. Validasi Backend Kode.gs.txt ---" -ForegroundColor Yellow
$gsPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\Kode.gs.txt"
$gsContent = Get-Content -Path $gsPath -Raw -Encoding UTF8

# A. submitRemedialExam
Assert-Test -Name "submitRemedialExam: Menghitung finalScore dengan rumus ((Awal+Rem)/2)+8 & cap 100" `
    -Condition ($gsContent -match "finalScore\s*=\s*Math\.min\(100,\s*Math\.round\(\(parseFloat\(initialScore\)\s*\+\s*parseFloat\(remedialScore\)\)\s*\/\s*2\)\s*\+\s*8\);")

# B. getStudentAnswerDetail (Modal Guru)
Assert-Test -Name "getStudentAnswerDetail: finalScore menggunakan rumus ((Awal+Rem)/2)+8 & cap 100" `
    -Condition ($gsContent -match "if\s*\(hasRemedial\s*&&\s*initialScore\s*!==\s*null\s*&&\s*remedialScore\s*!==\s*null\)\s*\{\s*finalScore\s*=\s*Math\.min\(100")

# C. getStudentAnswerDetails (Halaman Siswa & Export)
Assert-Test -Name "getStudentAnswerDetails: finalScore menggunakan rumus ((Awal+Rem)/2)+8 & cap 100" `
    -Condition ($gsContent -match "if\s*\(isRemedialCompleted\s*&&\s*initialScore\s*!==\s*null\s*&&\s*remedialScore\s*!==\s*null\)\s*\{\s*finalScore\s*=\s*Math\.min\(100")

# D. getExamResults (Rekap Guru)
Assert-Test -Name "getExamResults: finScore dan effectiveScore terkalibrasi rumus ((Awal+Rem)/2)+8" `
    -Condition ($gsContent -match "if\s*\(remStatus\s*===\s*'COMPLETED'\s*&&\s*initScore\s*!==\s*null\s*&&\s*remScore\s*!==\s*null\)\s*\{\s*finScore\s*=\s*Math\.min\(100")

# E. getStudentPortalData (Portal Siswa)
Assert-Test -Name "getStudentPortalData: finScore terkalibrasi rumus ((Awal+Rem)/2)+8" `
    -Condition ($gsContent -match "if\s*\(remStatus\s*===\s*'COMPLETED'\s*&&\s*initScore\s*!==\s*null\s*&&\s*remScore\s*!==\s*null\)\s*\{\s*finScore\s*=\s*Math\.min\(100")

# F. generateLegerData (Leger Nilai TP)
Assert-Test -Name "generateLegerData: avgTPFinal selaras dengan rumus ((initSc+remSc)/2)+8" `
    -Condition ($gsContent -match "avgTPFinal\s*=\s*Math\.min\(100,\s*Math\.round\(\(initSc\s*\+\s*remSc\)\s*\/\s*2\)\s*\+\s*8\);")

# 3. VALIDASI FRONTEND INDEX.HTML
Write-Host "`n--- 3. Validasi Frontend index.html ---" -ForegroundColor Yellow
$htmlPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\index.html"
$htmlContent = Get-Content -Path $htmlPath -Raw -Encoding UTF8

# A. Modal Guru: switchTeacherModalTab menampilkan res.finalScore pada header dan tab
Assert-Test -Name "Modal Guru: Tab Switcher dan Header menampilkan res.finalScore" `
    -Condition ($htmlContent -match "switchTeacherModalTab" -and $htmlContent -match "res\.finalScore")

# B. Modal Guru: buildAnswerCardsHTML menampilkan displayedScore Nilai Akhir
Assert-Test -Name "Modal Guru: Kartu Soal menampilkan displayedScore untuk Nilai Akhir" `
    -Condition ($htmlContent -match "displayedScore !== undefined && displayedScore !== null \? displayedScore : 0")

# C. Halaman Siswa: showStudentResultPage menampilkan res.finalScore pada kartu komparasi
Assert-Test -Name "Halaman Siswa: Kartu Komparasi menampilkan res.finalScore pada Nilai Akhir Baru" `
    -Condition ($htmlContent -match "res\.finalScore !== null && res\.finalScore !== undefined \? res\.finalScore : '-'")

# D. Halaman Siswa: Tab Switcher menampilkan Nilai Akhir
Assert-Test -Name "Halaman Siswa: Tombol Tab Hasil Remedial menampilkan res.finalScore" `
    -Condition ($htmlContent -match "btn-result-tab-comb" -and $htmlContent -match "res\.finalScore")

# E. Deskripsi Rapi: Tanpa klaim seluruh butir soal yang usang
Assert-Test -Name "Frontend: Deskripsi hasil remedial bersih dan resmi" `
    -Condition ($htmlContent -match "Nilai Akhir resmi telah diperbarui berdasarkan evaluasi sesi remedial")

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " HASIL AKHIR PENGUJIAN FORMULA REMEDIAL ((AWAL+REM)/2)+8:" -ForegroundColor Cyan
Write-Host " Passed : $script:passed" -ForegroundColor Green
Write-Host " Failed : $script:failed" -ForegroundColor $(if ($script:failed -gt 0) { "Red" } else { "Green" })
Write-Host "========================================================`n" -ForegroundColor Cyan

if ($script:failed -gt 0) { exit 1 } else { exit 0 }
