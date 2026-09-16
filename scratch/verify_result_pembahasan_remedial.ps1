# ==============================================================================
# VERIFIKASI: PEMBATASAN PEMBAHASAN SOAL SISWA & INTEGRASI REMEDIAL DI HASIL UJIAN
# ==============================================================================

Write-Host "`n=== [TEST SUITE] MEMULAI VALIDASI PEMBATASAN PEMBAHASAN & REMEDIAL HASIL UJIAN ===" -ForegroundColor Cyan

$kodeGsPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\Kode.gs.txt"
$indexHtmlPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\index.html"

$testsPassed = 0
$testsFailed = 0

function Assert-Test {
    param(
        [string]$Name,
        [bool]$Condition,
        [string]$FailMsg = ""
    )
    if ($Condition) {
        Write-Host " [PASS] $Name" -ForegroundColor Green
        $script:testsPassed++
    } else {
        Write-Host " [FAIL] $Name - $FailMsg" -ForegroundColor Red
        $script:testsFailed++
    }
}

$kodeGsContent = Get-Content -Path $kodeGsPath -Raw
$indexHtmlContent = Get-Content -Path $indexHtmlPath -Raw

# ------------------------------------------------------------------------------
# 1. VALIDASI BACKEND (Kode.gs.txt)
# ------------------------------------------------------------------------------
Write-Host "`n--- 1. Backend: Sensor Kunci untuk Siswa & Metadata Remedial (Kode.gs.txt) ---" -ForegroundColor Yellow

# Test 1.1: Signature getStudentAnswerDetails menerima requestorRole
Assert-Test -Name "Backend: getStudentAnswerDetails() mendukung parameter requestorRole" `
    -Condition ($kodeGsContent -match "function getStudentAnswerDetails\(responseId,\s*studentId,\s*targetExamIdParam,\s*requestorRole\)") `
    -FailMsg "Signature getStudentAnswerDetails tidak memiliki parameter requestorRole"

# Test 1.2: getMyExamResult meneruskan userRole ke getStudentAnswerDetails
Assert-Test -Name "Backend: getMyExamResult() mengekstrak userRole dan meneruskannya ke getStudentAnswerDetails()" `
    -Condition ($kodeGsContent -match "getStudentAnswerDetails\(cleanResponseId,\s*userID,\s*examId,\s*userRole\)") `
    -FailMsg "getMyExamResult tidak meneruskan userRole ke getStudentAnswerDetails"

# Test 1.3: Redaksi kunci jawaban khusus Siswa
Assert-Test -Name "Backend: Kunci jawaban disensor (dikosongkan) jika peninjau adalah Siswa" `
    -Condition ($kodeGsContent -match 'key:\s*isStudentViewer\s*\?\s*""\s*:\s*displayKey') `
    -FailMsg "Kunci jawaban tidak diredaksi dengan kondisi isStudentViewer"

# Test 1.4: Ekstraksi metadata remedial dan rekalkulasi perbaikan butir soal
Assert-Test -Name "Backend: Ekstraksi status remedial (isRemedialApproved & isRemedialCompleted)" `
    -Condition ($kodeGsContent -match "isRemedialCompleted\s*=\s*\(remStatus === 'COMPLETED'\)" -and $kodeGsContent -match "isRemedialApproved\s*=\s*\(remStatus === 'APPROVED' \|\| remStatus === 'ACTIVE'\)") `
    -FailMsg "Ekstraksi isRemedialCompleted / isRemedialApproved tidak ditemukan"

Assert-Test -Name "Backend: Rekalkulasi poin dan status butir soal terkoreksi pasca-remedial" `
    -Condition ($kodeGsContent -match "isRemedialImproved\s*=\s*true;" -and $kodeGsContent -match "Tuntas \(Remedial\)") `
    -FailMsg "Pembaruan poin butir soal pasca-remedial tidak ditemukan di getStudentAnswerDetails"

Assert-Test -Name "Backend: Objek kembalian memuat metrik lengkap (finalScore, initialScore, remedialScore, kktp, userRole)" `
    -Condition ($kodeGsContent -match "isRemedialApproved:\s*isRemedialApproved" -and $kodeGsContent -match "remedialScore:\s*remedialScore" -and $kodeGsContent -match "kktp:\s*examKKTP") `
    -FailMsg "Objek return getStudentAnswerDetails tidak memuat metrik remedial lengkap"

# ------------------------------------------------------------------------------
# 2. VALIDASI FRONTEND (index.html)
# ------------------------------------------------------------------------------
Write-Host "`n--- 2. Frontend: Halaman Hasil Ujian & Pembatasan Kunci (index.html) ---" -ForegroundColor Yellow

# Test 2.1: Elemen DOM th-result-key, banner, dan comparison
Assert-Test -Name "Frontend: Kolom header tabel memiliki id 'th-result-key'" `
    -Condition ($indexHtmlContent -match 'id="th-result-key"') `
    -FailMsg "Elemen #th-result-key tidak ditemukan"

Assert-Test -Name "Frontend: Container banner remedial (#result-remedial-banner) tersedia di DOM" `
    -Condition ($indexHtmlContent -match 'id="result-remedial-banner"') `
    -FailMsg "Elemen #result-remedial-banner tidak ditemukan"

Assert-Test -Name "Frontend: Container komparasi skor (#result-remedial-comparison) tersedia di DOM" `
    -Condition ($indexHtmlContent -match 'id="result-remedial-comparison"') `
    -FailMsg "Elemen #result-remedial-comparison tidak ditemukan"

# Test 2.2: Logika JavaScript showStudentResultPage
Assert-Test -Name "Frontend: showStudentResultPage menyembunyikan kolom th-result-key untuk Siswa" `
    -Condition ($indexHtmlContent -match "thKey\.classList\.add\('hidden'\)" -and $indexHtmlContent -match "isStudentViewer") `
    -FailMsg "Penyembunyian th-result-key untuk Siswa tidak ditemukan"

Assert-Test -Name "Frontend: Sel kunci jawaban tidak dirender pada baris tabel untuk Siswa" `
    -Condition ($indexHtmlContent -match "keyCellHtml\s*=\s*isStudentViewer\s*\?\s*''") `
    -FailMsg "Pengabaian sel kunci jawaban untuk Siswa tidak ditemukan"

Assert-Test -Name "Frontend: Banner Rekomendasi Remedial memuat tombol pemicu openPortalRemedialPinModal" `
    -Condition ($indexHtmlContent -match "openPortalRemedialPinModal" -and $indexHtmlContent -match "Ikuti Remedial Sekarang") `
    -FailMsg "Tombol Ikuti Remedial Sekarang yang memanggil openPortalRemedialPinModal tidak ditemukan"

Assert-Test -Name "Frontend: Kartu komparasi menampilkan Nilai Awal, Nilai Remedial, dan Nilai Akhir Baru" `
    -Condition ($indexHtmlContent -match "Nilai Awal" -and $indexHtmlContent -match "Nilai Remedial" -and $indexHtmlContent -match "Nilai Akhir Baru") `
    -FailMsg "Kartu komparasi remedial tidak ditemukan"

Assert-Test -Name "Frontend: Butir soal terkoreksi diberi badge khusus 'Tuntas (Remedial)'" `
    -Condition ($indexHtmlContent -match "item\.isRemedialImproved" -and $indexHtmlContent -match "Tuntas \(Remedial\)") `
    -FailMsg "Badge Tuntas (Remedial) pada butir soal terkoreksi tidak ditemukan"

# Test 2.3: Pembaruan label tombol
Assert-Test -Name "Frontend: Tombol selesai ujian diubah dari 'Lihat Pembahasan' menjadi 'Lihat Hasil Ujian'" `
    -Condition ($indexHtmlContent -match "Lihat Hasil Ujian") `
    -FailMsg "Label 'Lihat Hasil Ujian' pada tombol selesai ujian tidak ditemukan"

Assert-Test -Name "Frontend: Tombol portal riwayat diubah dari 'Pembahasan' menjadi 'Lihat Hasil'" `
    -Condition ($indexHtmlContent -match "Lihat Hasil") `
    -FailMsg "Label 'Lihat Hasil' pada tabel riwayat siswa tidak ditemukan"

# ------------------------------------------------------------------------------
# HASIL AKHIR
# ------------------------------------------------------------------------------
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " HASIL AKHIR VALIDASI PEMBATASAN PEMBAHASAN & REMEDIAL:" -ForegroundColor Cyan
Write-Host " Passed : $testsPassed" -ForegroundColor Green
Write-Host " Failed : $testsFailed" -ForegroundColor $(if ($testsFailed -gt 0) { "Red" } else { "Green" })
Write-Host "========================================================`n" -ForegroundColor Cyan

if ($testsFailed -eq 0) {
    exit 0
} else {
    exit 1
}
