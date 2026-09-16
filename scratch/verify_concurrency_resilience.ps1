# ==============================================================================
# VERIFICATION SUITE: CONCURRENCY RESILIENCE & PROCTOR BULK CBT IMPORT
# ==============================================================================

Write-Host "`n=== [TEST SUITE] MEMULAI VALIDASI KETAHANAN CONCURRENCY & BULK CBT ===" -ForegroundColor Cyan

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
Write-Host "`n--- 1. Backend: Caching & Lock Optimization (Kode.gs.txt) ---" -ForegroundColor Yellow

# Test 1.1: getCachedExamQuestions function exists and uses CacheService
Assert-Test -Name "Backend: getCachedExamQuestions() diimplementasikan" `
    -Condition ($kodeGsContent -match "function getCachedExamQuestions\(examID\)") `
    -FailMsg "Fungsi getCachedExamQuestions tidak ditemukan di Kode.gs.txt"

Assert-Test -Name "Backend: CacheService.getScriptCache() digunakan untuk caching soal" `
    -Condition ($kodeGsContent -match "CacheService\.getScriptCache\(\)") `
    -FailMsg "CacheService.getScriptCache() tidak ditemukan"

# Test 1.2: evaluateStudentAnswers pure in-memory grading function exists
Assert-Test -Name "Backend: evaluateStudentAnswers() grading modular in-memory" `
    -Condition ($kodeGsContent -match "function evaluateStudentAnswers\(examID,\s*answers\)") `
    -FailMsg "Fungsi evaluateStudentAnswers tidak ditemukan"

# Test 1.3: submitExam evaluates outside lock & optimizes lock acquisition
Assert-Test -Name "Backend: submitExam() mengevaluasi jawaban di luar LockService" `
    -Condition ($kodeGsContent -match "const evalResult = evaluateStudentAnswers\(examID,\s*answers\);[\s\S]*?LockService\.getScriptLock\(\);") `
    -FailMsg "evaluateStudentAnswers harus dipanggil sebelum LockService.getScriptLock()"

Assert-Test -Name "Backend: submitExam() menggunakan waitLock dengan toleransi terukur (12s)" `
    -Condition ($kodeGsContent -match "lock\.waitLock\(12000\)") `
    -FailMsg "lock.waitLock(12000) tidak ditemukan"

Assert-Test -Name "Backend: submitExam() merespons busy queue secara anggun saat lock timeout" `
    -Condition ($kodeGsContent -match "BUSY_QUEUE" -and $kodeGsContent -match "isBusy:\s*true") `
    -FailMsg "Respons BUSY_QUEUE / isBusy tidak ditemukan saat lock gagal didapat"

Assert-Test -Name "Backend: submitExam() memastikan lock.releaseLock() selalu dieksekusi di finally" `
    -Condition ($kodeGsContent -match "finally\s*\{[\s\S]*?lock\.releaseLock\(\);") `
    -FailMsg "lock.releaseLock() harus ada dalam blok finally"

# Test 1.4: uploadBulkCbtResponses exists
Assert-Test -Name "Backend: uploadBulkCbtResponses() diimplementasikan untuk Proctor Bulk Import" `
    -Condition ($kodeGsContent -match "function uploadBulkCbtResponses\(examID,\s*cbtPackages,\s*requestorID,\s*requestorToken\)") `
    -FailMsg "Fungsi uploadBulkCbtResponses tidak ditemukan"

Assert-Test -Name "Backend: uploadBulkCbtResponses() memverifikasi hak akses Guru/Admin" `
    -Condition ($kodeGsContent -match "role !== 'admin' && role !== 'guru'") `
    -FailMsg "Verifikasi hak akses Admin/Guru di uploadBulkCbtResponses tidak ditemukan"

# ------------------------------------------------------------------------------
# 2. VALIDASI FRONTEND (index.html)
# ------------------------------------------------------------------------------
Write-Host "`n--- 2. Frontend: Modal Antrean & Smart Retry Queue (index.html) ---" -ForegroundColor Yellow

# Test 2.1: Modal submission queue UI
Assert-Test -Name "Frontend: Modal #modal-submission-queue tersedia di DOM" `
    -Condition ($indexHtmlContent -match 'id="modal-submission-queue"') `
    -FailMsg "Elemen #modal-submission-queue tidak ditemukan"

Assert-Test -Name "Frontend: Indikator badge & progress bar antrean ada di modal" `
    -Condition ($indexHtmlContent -match 'id="queue-retry-badge"' -and $indexHtmlContent -match 'id="queue-retry-bar"') `
    -FailMsg "Elemen #queue-retry-badge atau #queue-retry-bar tidak ditemukan"

# Test 2.2: Staggered Jitter submission logic
Assert-Test -Name "Frontend: Randomized Jitter (0-2500ms) diterapkan saat submit ujian" `
    -Condition ($indexHtmlContent -match "const jitterMs = Math\.floor\(Math\.random\(\) \* 2500\);" -or $indexHtmlContent -match "Math\.random\(\) \* 2500") `
    -FailMsg "Randomized jitter delay tidak ditemukan pada executeSubmission"

# Test 2.3: sendExamSubmissionWithQueue logic (5 attempts exponential backoff)
Assert-Test -Name "Frontend: sendExamSubmissionWithQueue() diimplementasikan" `
    -Condition ($indexHtmlContent -match "function sendExamSubmissionWithQueue\(") `
    -FailMsg "Fungsi sendExamSubmissionWithQueue tidak ditemukan"

Assert-Test -Name "Frontend: Retry queue mendukung hingga 5 percobaan dengan backoff" `
    -Condition ($indexHtmlContent -match "maxAttempts = maxAttempts \|\| 5;" -and $indexHtmlContent -match "backoffDelays = \[2000,\s*3500,\s*5000,\s*7000,\s*10000\]") `
    -FailMsg "Konfigurasi maxAttempts=5 atau backoffDelays [2000, 3500, 5000, 7000, 10000] tidak ditemukan"

Assert-Test -Name "Frontend: Fallback darurat unduh .cbt otomatis jika 5 percobaan gagal" `
    -Condition ($indexHtmlContent -match "handleOfflineSubmission\(forced,\s*statusLabel,\s*sisaMenitTerakhir\)") `
    -FailMsg "Fallback handleOfflineSubmission saat retry habis tidak ditemukan"

# ------------------------------------------------------------------------------
# 3. VALIDASI FITUR PROCTOR BULK CBT IMPORT (index.html)
# ------------------------------------------------------------------------------
Write-Host "`n--- 3. Proctor Bulk CBT Import: Drag & Drop & Batch Upload ---" -ForegroundColor Yellow

Assert-Test -Name "Frontend: Input berkas CBT mendukung atribut 'multiple'" `
    -Condition ($indexHtmlContent -match 'id="input-cbt-file"[^>]*multiple') `
    -FailMsg "Input #input-cbt-file tidak memiliki atribut multiple"

Assert-Test -Name "Frontend: Area Drag-and-Drop CBT (#cbt-drop-zone) tersedia" `
    -Condition ($indexHtmlContent -match 'id="cbt-drop-zone"') `
    -FailMsg "Elemen #cbt-drop-zone tidak ditemukan"

Assert-Test -Name "Frontend: Handler Drag & Drop terpasang (dragover, dragleave, drop)" `
    -Condition ($indexHtmlContent -match "function handleCbtDragOver" -and $indexHtmlContent -match "function handleCbtDrop") `
    -FailMsg "Fungsi handleCbtDragOver / handleCbtDrop tidak ditemukan"

Assert-Test -Name "Frontend: Tabel daftar berkas massal (#cbt-batch-table-container) ada di DOM" `
    -Condition ($indexHtmlContent -match 'id="cbt-batch-table-container"') `
    -FailMsg "Elemen #cbt-batch-table-container tidak ditemukan"

Assert-Test -Name "Frontend: submitImportedCbtBatch() memanggil uploadBulkCbtResponses" `
    -Condition ($indexHtmlContent -match "function submitImportedCbtBatch" -and $indexHtmlContent -match "uploadBulkCbtResponses") `
    -FailMsg "submitImportedCbtBatch tidak memanggil uploadBulkCbtResponses"

# ------------------------------------------------------------------------------
# HASIL AKHIR
# ------------------------------------------------------------------------------
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " HASIL AKHIR VALIDASI CONCURRENCY & BULK CBT:" -ForegroundColor Cyan
Write-Host " Passed : $testsPassed" -ForegroundColor Green
Write-Host " Failed : $testsFailed" -ForegroundColor $(if ($testsFailed -gt 0) { "Red" } else { "Green" })
Write-Host "========================================================`n" -ForegroundColor Cyan

if ($testsFailed -eq 0) {
    exit 0
} else {
    exit 1
}
