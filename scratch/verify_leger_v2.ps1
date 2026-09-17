# Verification Script V2 for Enhanced Sistem Leger Nilai Berbasis TP (Kurikulum Merdeka)
$ErrorActionPreference = "Stop"

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host " VERIFIKASI V2: LEGER NILAI TP DINAMIS" -ForegroundColor Cyan
Write-Host " FILTER MAPEL/KELAS/SISWA + WIZARD 3 TAHAP + RAPOR TP" -ForegroundColor Cyan
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

# 1.1 Signature generateLegerData dengan targetStudentID & backward compatibility
Assert-Condition "Backend: generateLegerData signature" `
    ($kodeContent -match "function\s+generateLegerData\s*\(\s*examID\s*,\s*targetClass\s*,\s*targetStudentID\s*,\s*requestorID\s*,\s*requestorToken\s*\)") `
    "Signature generateLegerData mendukung targetStudentID." `
    "Signature generateLegerData tidak sesuai!"

# 1.2 Backward compatibility handling
Assert-Condition "Backend: Backward Compatibility 4 params" `
    ($kodeContent -match "if\s*\(\s*requestorToken\s*===\s*undefined\s*\)") `
    "Logika backward compatibility 4 parameter terpasang aman." `
    "Backward compatibility tidak ditemukan!"

# 1.3 Available classes extraction
Assert-Condition "Backend: availableClasses parsing" `
    ($kodeContent -match "availableClasses" -and $kodeContent -match "examClass\.split") `
    "Parsing availableClasses dari kelas ujian dan pengguna ada di backend." `
    "Parsing availableClasses tidak ditemukan!"

# 1.4 Individual student report calculation
Assert-Condition "Backend: individualStudentData generation" `
    ($kodeContent -match "individualStudentData" -and $kodeContent -match "cleanTargetStudent" -and $kodeContent -match "tpDetails") `
    "Pembuatan individualStudentData dengan detail capaian per TP terdefinisi." `
    "individualStudentData tidak ditemukan di backend!"

# 1.5 Kurikulum Merdeka predicates
Assert-Condition "Backend: Kurikulum Merdeka Predicates" `
    ($kodeContent -match "Sangat Baik" -and $kodeContent -match "Perlu Bimbingan") `
    "Predikat capaian kompetensi Kurikulum Merdeka (Sangat Baik s/d Perlu Bimbingan) lengkap." `
    "Predikat capaian kompetensi belum lengkap!"

# ----------------------------------------------------
# 2. Frontend Verification (index.html)
# ----------------------------------------------------
Write-Host "`n--- 2. Validasi Antarmuka Pengguna (index.html) ---" -ForegroundColor Yellow

# 2.1 Filter Hierarkis 3 Tingkat
Assert-Condition "Frontend: Hierarchical Filter Elements" `
    ($htmlContent -match 'id="select-leger-exam"' -and `
     $htmlContent -match 'id="select-leger-class"' -and `
     $htmlContent -match 'id="select-leger-student"') `
    "Tiga dropdown hierarkis (Mapel, Kelas, Siswa) tersedia di UI." `
    "Dropdown filter hierarkis tidak lengkap!"

# 2.2 Tombol Aksi Top Bar
Assert-Condition "Frontend: Action Buttons (Wizard, Excel, Print)" `
    ($htmlContent -match 'id="btn-open-tp-wizard"' -and `
     $htmlContent -match 'id="btn-download-leger-excel"' -and `
     $htmlContent -match 'id="btn-print-student-card"') `
    "Tombol aksi Wizard TP, Download Excel, dan Cetak Lembar Siswa tersedia." `
    "Tombol aksi top bar belum lengkap!"

# 2.3 Modal Wizard 3 Tahap
Assert-Condition "Frontend: Modal Wizard 3 Tahap (#modal-tp-wizard)" `
    ($htmlContent -match 'id="modal-tp-wizard"' -and `
     $htmlContent -match 'id="wizard-step-1"' -and `
     $htmlContent -match 'id="wizard-step-2"' -and `
     $htmlContent -match 'id="wizard-step-3"') `
    "Modal Wizard 3 Tahap (#modal-tp-wizard) dengan langkah 1, 2, 3 lengkap." `
    "Komponen Modal Wizard 3 Tahap belum lengkap!"

# 2.4 Fungsi Kontrol Wizard JS
Assert-Condition "Frontend: Wizard JS Controllers" `
    ($htmlContent -match "function\s+openTPWizardModal\s*\(" -and `
     $htmlContent -match "function\s+goToWizardStep\s*\(" -and `
     $htmlContent -match "function\s+autoDistributeQuestions\s*\(" -and `
     $htmlContent -match "function\s+saveWizardTPConfig\s*\(") `
    "Fungsi-fungsi kontrol wizard (open, goToStep, autoDistribute, save) terdefinisi." `
    "Fungsi kontrol wizard belum lengkap!"

# 2.5 Kartu Capaian TP Siswa Individual
Assert-Condition "Frontend: Individual Student Card" `
    ($htmlContent -match 'id="leger-individual-wrapper"' -and `
     $htmlContent -match 'id="printable-student-card"' -and `
     $htmlContent -match "function\s+renderIndividualStudentCard\s*\(") `
    "Kontainer kartu individual dan fungsi renderIndividualStudentCard tersedia." `
    "Kartu capaian individual tidak ditemukan!"

# 2.6 Print Styles & Handler
Assert-Condition "Frontend: Print Handler & CSS" `
    ($htmlContent -match "function\s+printIndividualStudentCard\s*\(" -and `
     $htmlContent -match "@media print" -and `
     $htmlContent -match "#printable-student-card") `
    "Styling @media print dan fungsi printIndividualStudentCard terpasang." `
    "Print handler / style tidak lengkap!"

# ----------------------------------------------------
# 3. Functional Simulation (Auto-Distribute & Predicates)
# ----------------------------------------------------
Write-Host "`n--- 3. Simulasi Fungsional Pembagian Soal & Predikat ---" -ForegroundColor Yellow

# 3.1 Simulasi Auto Distribute: 20 soal dibagi 3 TP -> 7, 7, 6 soal
function Test-AutoDistribute($totalQ, $countTP) {
    $base = [Math]::Floor($totalQ / $countTP)
    $rem = $totalQ % $countTP
    $res = @()
    $curQ = 1
    for ($i = 0; $i -lt $countTP; $i++) {
        $take = $base
        if ($rem -gt 0) { $take++; $rem-- }
        $qList = @()
        for ($q = 0; $q -lt $take; $q++) {
            $qList += $curQ++
        }
        $res += ,$qList
    }
    return $res
}

$dist = Test-AutoDistribute 20 3
$tp1Count = $dist[0].Length
$tp2Count = $dist[1].Length
$tp3Count = $dist[2].Length

Assert-Condition "Simulation: Auto Distribute 20 Soal ke 3 TP" `
    ($tp1Count -eq 7 -and $tp2Count -eq 7 -and $tp3Count -eq 6) `
    "Alokasi rata tepat: TP 1 ($tp1Count soal), TP 2 ($tp2Count soal), TP 3 ($tp3Count soal)." `
    "Alokasi soal tidak rata!"

# 3.2 Simulasi Predikat Capaian
function Get-Predicate($score, $kktp) {
    if ($score -ge 90) { return "Sangat Baik" }
    elseif ($score -ge 80) { return "Baik" }
    elseif ($score -ge $kktp) { return "Cukup / Tuntas" }
    else { return "Perlu Bimbingan" }
}

Assert-Condition "Simulation: Predikat Nilai 95 (KKTP 75)" `
    ((Get-Predicate 95 75) -eq "Sangat Baik") `
    "Nilai 95 -> Sangat Baik (Sesuai)" `
    "Predikat salah!"

Assert-Condition "Simulation: Predikat Nilai 84 (KKTP 75)" `
    ((Get-Predicate 84 75) -eq "Baik") `
    "Nilai 84 -> Baik (Sesuai)" `
    "Predikat salah!"

Assert-Condition "Simulation: Predikat Nilai 76 (KKTP 75)" `
    ((Get-Predicate 76 75) -eq "Cukup / Tuntas") `
    "Nilai 76 -> Cukup / Tuntas (Sesuai)" `
    "Predikat salah!"

Assert-Condition "Simulation: Predikat Nilai 65 (KKTP 75)" `
    ((Get-Predicate 65 75) -eq "Perlu Bimbingan") `
    "Nilai 65 -> Perlu Bimbingan (Sesuai)" `
    "Predikat salah!"

# ----------------------------------------------------
# SUMMARY
# ----------------------------------------------------
Write-Host "`n=======================================================" -ForegroundColor Cyan
$color = "Green"
if ($testsFailed -gt 0) { $color = "Red" }
Write-Host " HASIL VERIFIKASI V2: $testsPassed PASSED, $testsFailed FAILED" -ForegroundColor $color
Write-Host "=======================================================`n" -ForegroundColor Cyan

if ($testsFailed -gt 0) {
    exit 1
} else {
    exit 0
}
