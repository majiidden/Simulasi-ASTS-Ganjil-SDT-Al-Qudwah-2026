# ============================================================
# VERIFIKASI FITUR KOMBINASI HASIL UJIAN & REMEDIAL (SISWA & GURU)
# ============================================================
$ErrorActionPreference = "Stop"

$kodeGsPath = ".\Kode.gs.txt"
$indexPath = ".\index.html"

if (-not (Test-Path $kodeGsPath)) {
    Write-Error "File Kode.gs.txt tidak ditemukan!"
    exit 1
}
if (-not (Test-Path $indexPath)) {
    Write-Error "File index.html tidak ditemukan!"
    exit 1
}

$kodeGsContent = Get-Content -Path $kodeGsPath -Raw -Encoding UTF8
$indexContent = Get-Content -Path $indexPath -Raw -Encoding UTF8

$passedTests = 0
$failedTests = 0

function Assert-Test([string]$testName, [bool]$condition, [string]$failMsg = "") {
    if ($condition) {
        Write-Host " [PASS] $testName" -ForegroundColor Green
        $global:passedTests++
    } else {
        Write-Host " [FAIL] $testName" -ForegroundColor Red
        if ($failMsg) {
            Write-Host "        Detail: $failMsg" -ForegroundColor Yellow
        }
        $global:failedTests++
    }
}

Write-Host "`n=== [TEST SUITE] VALIDASI KOMBINASI HASIL UJIAN & REMEDIAL ===" -ForegroundColor Cyan

# ── 1. Backend: submitRemedialExam & Penyimpanan Snapshot Awal ─────────────────
Write-Host "`n--- 1. Backend: Preservasi Snapshot Awal pada submitRemedialExam ---" -ForegroundColor Yellow
Assert-Test "submitRemedialExam menyimpan initialEvaluation snapshot ke _remedial" `
    ($kodeGsContent -match "answersObj\['_remedial'\]\.initialEvaluation\s*=\s*JSON\.parse")

Assert-Test "submitRemedialExam tetap menyimpan remedialAnswers dan finalScore" `
    ($kodeGsContent -match "answersObj\['_remedial'\]\.remedialAnswers\s*=\s*remedialAnswers" -and `
     $kodeGsContent -match "answersObj\['_remedial'\]\.finalScore\s*=\s*finalScore")

# ── 2. Backend: getStudentAnswerDetail (Modal Guru / Admin) ────────────────────
Write-Host "`n--- 2. Backend: getStudentAnswerDetail (Guru/Admin) ---" -ForegroundColor Yellow
Assert-Test "getStudentAnswerDetail mengekstrak metadata _remedial" `
    ($kodeGsContent -match "function getStudentAnswerDetail" -and `
     $kodeGsContent -match "const remMeta\s*=\s*\(studentAnswers && studentAnswers\['_remedial'\]\)")

Assert-Test "getStudentAnswerDetail menghasilkan array initialDetail dan detail (terkombinasi)" `
    ($kodeGsContent -match "initialDetail\.push\(\{" -and $kodeGsContent -match "detail\.push\(\{")

Assert-Test "getStudentAnswerDetail menandai butir remedial dengan isRemedialItem dan remedialStatus" `
    ($kodeGsContent -match "isRemedialItem:\s*isItemRetakenInRemedial" -and `
     $kodeGsContent -match "remedialStatus:\s*isItemRetakenInRemedial")

Assert-Test "getStudentAnswerDetail mengembalikan data (terkombinasi), initialData, dan hasRemedial" `
    ($kodeGsContent -match "data:\s*detail" -and `
     $kodeGsContent -match "initialData:\s*hasRemedial \? initialDetail : detail" -and `
     $kodeGsContent -match "hasRemedial:\s*hasRemedial")

# ── 3. Backend: getStudentAnswerDetails (Excel / PDF / Siswa Result) ───────────
Write-Host "`n--- 3. Backend: getStudentAnswerDetails (Siswa Result & Export) ---" -ForegroundColor Yellow
Assert-Test "getStudentAnswerDetails mengekstrak remAnswers, remEval, dan initEval" `
    ($kodeGsContent -match "remAnswers\s*=\s*\(isRemedialCompleted && remMeta\.remedialAnswers\)" -and `
     $kodeGsContent -match "remEval\s*=\s*\(isRemedialCompleted && remMeta\.remedialEvaluation\)")

Assert-Test "getStudentAnswerDetails memformat jawaban remedial siswa untuk butir remedial" `
    ($kodeGsContent -match "combDisplayAns = formatAnsForDisplay\(remAnsRaw\)")

Assert-Test "getStudentAnswerDetails menghasilkan initialDetails untuk ujian awal" `
    ($kodeGsContent -match "initialDetails\.push\(\{" -and `
     $kodeGsContent -match "answer:\s*initialDisplayAns")

Assert-Test "getStudentAnswerDetails menyensor kunci pada kedua dataset jika Siswa" `
    ($kodeGsContent -match 'initialDetails\.push\(\{[\s\S]*?key:\s*isStudentViewer \? "" : displayKey' -and `
     $kodeGsContent -match 'details\.push\(\{[\s\S]*?key:\s*isStudentViewer \? "" : displayKey')

Assert-Test "getStudentAnswerDetails mengembalikan data dan initialData" `
    ($kodeGsContent -match "data:\s*details" -and `
     $kodeGsContent -match "initialData:\s*isRemedialCompleted \? initialDetails : details")

# ── 4. Backend: generateStudentDetailPDF ───────────────────────────────────────
Write-Host "`n--- 4. Backend: generateStudentDetailPDF ---" -ForegroundColor Yellow
Assert-Test "generateStudentDetailPDF mendeteksi _remedial yang COMPLETED" `
    ($kodeGsContent -match "function generateStudentDetailPDF" -and `
     $kodeGsContent -match "isRemedialCompleted\s*=\s*\(String\(remMeta\.status \|\| ''\)\.toUpperCase\(\) === 'COMPLETED'\)")

Assert-Test "generateStudentDetailPDF menggunakan remedialAnswers jika ada" `
    ($kodeGsContent -match "sAnsRaw\s*=\s*\(remAnswers\[qId\] !== undefined\)")

# ── 5. Frontend: Modal Guru / Admin (viewStudentAnswers) ───────────────────────
Write-Host "`n--- 5. Frontend: Modal Guru / Admin (viewStudentAnswers) ---" -ForegroundColor Yellow
Assert-Test "Modal memiliki Tab Switcher (#btn-modal-tab-comb & #btn-modal-tab-init)" `
    ($indexContent -match "id=""btn-modal-tab-comb""" -and $indexContent -match "id=""btn-modal-tab-init""")

Assert-Test "Modal memiliki fungsi switchTeacherModalTab untuk beralih antar tab" `
    ($indexContent -match "window\.switchTeacherModalTab\s*=\s*function\(tab\)")

Assert-Test "Modal menampilkan badge Tuntas (Remedial) pada tab terkombinasi" `
    ($indexContent -match "Tuntas \(Remedial\)" -and $indexContent -match "item\.isRemedialItem")

# ── 6. Frontend: Halaman Hasil Siswa (showStudentResultPage) ──────────────────
Write-Host "`n--- 6. Frontend: Halaman Hasil Siswa (showStudentResultPage) ---" -ForegroundColor Yellow
Assert-Test "DOM memuat kontainer #result-tab-switch-container" `
    ($indexContent -match "id=""result-tab-switch-container""")

Assert-Test "showStudentResultPage merender Tab Switch (#btn-result-tab-comb & #btn-result-tab-init)" `
    ($indexContent -match "id=""btn-result-tab-comb""" -and $indexContent -match "id=""btn-result-tab-init""")

Assert-Test "showStudentResultPage memiliki fungsi switchStudentResultTab" `
    ($indexContent -match "window\.switchStudentResultTab\s*=\s*function\(targetTab\)")

Assert-Test "showStudentResultPage memisahkan renderStudentResultTable untuk toggle instan" `
    ($indexContent -match "function renderStudentResultTable\(itemsList, currentScore, isCombinedView\)")

Assert-Test "showStudentResultPage mempertahankan sensor kunci jawaban pada SEMUA tab" `
    ($indexContent -match "const keyCellHtml\s*=\s*isStudentViewer \? '' :")

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " HASIL AKHIR VALIDASI FITUR KOMBINASI JAWABAN & REMEDIAL:" -ForegroundColor Cyan
Write-Host " Passed : $passedTests" -ForegroundColor Green
Write-Host " Failed : $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "========================================================`n" -ForegroundColor Cyan

if ($failedTests -gt 0) {
    exit 1
}
