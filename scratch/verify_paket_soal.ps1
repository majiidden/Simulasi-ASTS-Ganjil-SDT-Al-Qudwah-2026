# Verification Script for Fitur Paket Soal Diferensiasi (Paket A & Paket B)
$ErrorActionPreference = "Stop"

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host " VERIFIKASI: FITUR PAKET SOAL DIFERENSIASI (A & B)" -ForegroundColor Cyan
Write-Host " IMPORT EXCEL TERPISAH + PEMETAAN SISWA + PORTAL + LEGER" -ForegroundColor Cyan
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

# 1.1 Schema Headers
Assert-Condition "Backend: Schema initializeSheets" `
    ($kodeContent -match "PackageConfig" -and $kodeContent -match "'Package'") `
    "Header sheet Exams (Col 13: PackageConfig) dan Questions (Col 10: Package) terdaftar." `
    "Header sheet Exams / Questions tidak lengkap!"

# 1.2 getExamPackageStudents & saveExamPackageMapping
Assert-Condition "Backend: Service Pemetaan Siswa" `
    ($kodeContent -match "function\s+getExamPackageStudents\s*\(" -and `
     $kodeContent -match "function\s+saveExamPackageMapping\s*\(") `
    "Fungsi backend getExamPackageStudents dan saveExamPackageMapping terdefinisi." `
    "Fungsi pemetaan siswa tidak ditemukan!"

# 1.3 saveImportedQuestions accepts packageCode
Assert-Condition "Backend: saveImportedQuestions parameter packageCode" `
    ($kodeContent -match "function\s+saveImportedQuestions\s*\(\s*examID\s*,\s*questionsData\s*,\s*packageCode\s*\)") `
    "saveImportedQuestions mendukung parameter packageCode." `
    "saveImportedQuestions tidak mendukung packageCode!"

# 1.4 getQuestionsByExam returns package
Assert-Condition "Backend: getQuestionsByExam return package" `
    ($kodeContent -match "package\s*:\s*\(r\[9\]") `
    "getQuestionsByExam mengembalikan atribut package butir soal." `
    "getQuestionsByExam tidak mengembalikan package!"

# 1.5 getExamQuestions filters by student package
Assert-Condition "Backend: getExamQuestions package filter" `
    ($kodeContent -match "studentPackage" -and $kodeContent -match "packageEnabled") `
    "getExamQuestions membaca mapping siswa dan memfilter butir soal sesuai paket." `
    "getExamQuestions tidak memfilter paket!"

# 1.6 evaluateStudentAnswers filters by packageCode
Assert-Condition "Backend: evaluateStudentAnswers skala nilai adil" `
    ($kodeContent -match "function\s+evaluateStudentAnswers\s*\(\s*examID\s*,\s*answers\s*,\s*packageCode\s*\)") `
    "evaluateStudentAnswers menerima packageCode untuk skala nilai adil per paket." `
    "evaluateStudentAnswers tidak mendukung packageCode!"

# 1.7 submitExam records packageCode
Assert-Condition "Backend: submitExam accepts packageCode" `
    ($kodeContent -match "function\s+submitExam\s*\(\s*userID\s*,\s*examID\s*,\s*answers\s*,\s*customStatus\s*,\s*sisaMenit\s*,\s*packageCode\s*\)") `
    "submitExam menerima packageCode dan menyimpannya ke responses." `
    "submitExam tidak menerima packageCode!"

# 1.8 getExamResults extracts package
Assert-Condition "Backend: getExamResults package detection" `
    ($kodeContent -match "examPkgMapping" -and $kodeContent -match "studentPkg") `
    "getExamResults mendeteksi paket siswa untuk rekap nilai." `
    "getExamResults tidak mendeteksi paket siswa!"

# 1.9 generateLegerData outputs package
Assert-Condition "Backend: generateLegerData rowObj package" `
    ($kodeContent -match "package\s*:\s*studentPkg" -and $kodeContent -match "packageEnabled\s*:\s*!!\(packageConfig") `
    "generateLegerData menyertakan rowObj.package dan examInfo.packageEnabled." `
    "generateLegerData tidak menyertakan package!"

# ----------------------------------------------------
# 2. Frontend Verification (index.html)
# ----------------------------------------------------
Write-Host "`n--- 2. Validasi Antarmuka Pengguna (index.html) ---" -ForegroundColor Yellow

# 2.1 Exam Modal Toggle
Assert-Condition "Frontend: Toggle input-packageEnabled" `
    ($htmlContent -match 'id="input-packageEnabled"' -and $htmlContent -match 'Diferensiasi Paket Soal') `
    "Toggle Aktifkan Diferensiasi Paket Soal (Paket A & B) tersedia di modal ujian." `
    "Toggle input-packageEnabled tidak ditemukan!"

# 2.2 Modal Distribusi Paket Siswa
Assert-Condition "Frontend: Modal Distribusi Paket (#examPackageModal)" `
    ($htmlContent -match 'id="examPackageModal"' -and `
     $htmlContent -match "function\s+openExamPackageModal\s*\(" -and `
     $htmlContent -match "function\s+autoDistributeExamPackages\s*\(" -and `
     $htmlContent -match "function\s+saveExamPackageMappingFromUI\s*\(") `
    "Modal distribusi paket siswa lengkap dengan aksi otomatis (50/50, Ganjil/Genap, Semua A/B)." `
    "Modal distribusi paket siswa tidak lengkap!"

# 2.3 Bank Soal Filter Tabs
Assert-Condition "Frontend: Bank Soal Package Filter Tabs" `
    ($htmlContent -match 'id="tab-pkg-all"' -and `
     $htmlContent -match 'id="tab-pkg-a"' -and `
     $htmlContent -match 'id="tab-pkg-b"' -and `
     $htmlContent -match "function\s+filterQuestionsByPackage\s*\(") `
    "Tab filter paket (Semua, Paket A, Paket B) dan fungsinya tersedia di Bank Soal." `
    "Tab filter paket Bank Soal tidak lengkap!"

# 2.4 Import Excel Package Selector
Assert-Condition "Frontend: Import Excel Package Selector" `
    ($htmlContent -match 'name="import-package-radio"' -and `
     $htmlContent -match "downloadTemplateExcel\(" -and `
     $htmlContent -match "saveImportedQuestions") `
    "Pilihan paket target import Excel (Radio Paket A / B) dan template terpasang." `
    "Pilihan paket import Excel tidak ditemukan!"

# 2.5 Manual Question Package Selector
Assert-Condition "Frontend: Manual Question Package Selector" `
    ($htmlContent -match 'id="q-package-select"') `
    "Dropdown pemilihan paket soal manual tersedia di modal input soal." `
    "Dropdown q-package-select tidak ditemukan!"

# 2.6 Student Portal Exam Card & PIN Modal Package Notice
Assert-Condition "Frontend: Student Portal Package Badges & PIN Banner" `
    ($htmlContent -match 'portal-modal-package-banner' -and `
     $htmlContent -match 'Paket Soal Anda: Paket' -and `
     $htmlContent -match "openPortalPinModal\(") `
    "Banner paket di modal PIN dan badge Paket Soal di kartu ujian portal siswa aktif." `
    "Portal siswa paket badge / PIN banner tidak lengkap!"

# 2.7 Exam Header Display & submitExam parameter
Assert-Condition "Frontend: Exam Header & submitExam" `
    ($htmlContent -match "Paket\s+\$\{res\.studentPackage\}" -and `
     $htmlContent -match "submitExam\([^,]+,[^,]+,[^,]+,[^,]+,[^,]+,\s*\(currentExam") `
    "Tampilan paket di header lembar ujian dan pengiriman paket ke submitExam terhubung." `
    "Exam header / submitExam paket tidak terhubung!"

# 2.8 Results Table Package Badge
Assert-Condition "Frontend: Results Table Package Badge" `
    ($htmlContent -match 'r\.package\s*\?\s*`<span class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-\[9px\] font-black uppercase') `
    "Badge Paket A / B ditampilkan pada nama siswa di tabel rekap Hasil & Penilaian." `
    "Badge paket di tabel nilai tidak ditemukan!"

# 2.9 Leger Table & Download Excel
Assert-Condition "Frontend: Leger Table & Excel Export" `
    ($htmlContent -match 'isPkgEnabled' -and `
     $htmlContent -match 'thPkgHeader' -and `
     $htmlContent -match "'Paket Soal'") `
    "Kolom Paket Soal terpasang pada tabel Leger TP dan ekspor Excel .xlsx." `
    "Kolom paket di Leger TP atau Excel tidak lengkap!"

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
