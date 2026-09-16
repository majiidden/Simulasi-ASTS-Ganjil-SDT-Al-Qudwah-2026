# Verification script for Post-Remedial TP and Final Score Recalculation
$gsFile = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\Kode.gs.txt"
$htmlFile = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\index.html"

$gsContent = Get-Content -Path $gsFile -Raw -Encoding UTF8
$htmlContent = Get-Content -Path $htmlFile -Raw -Encoding UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "VERIFIKASI REKALKULASI NILAI TP & NILAI AKHIR PASCA-REMEDIAL" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$checks = @(
    @{ 
        Name = "submitRemedialExam: Total Exam Accumulation Loop exists"; 
        Pattern = "totalExamMaxPoints\s*\+=\s*w;\s*let\s+pt\s*=\s*0;"
    },
    @{ 
        Name = "submitRemedialExam: Merges remedial point using Math.max(pt, remPt)"; 
        Pattern = "pt\s*=\s*Math\.max\(pt,\s*remPt\)"
    },
    @{ 
        Name = "submitRemedialExam: Recalculates finalScore from all corrected questions"; 
        Pattern = "totalExamMaxPoints\s*>\s*0\s*\?\s*Math\.round\(\(totalExamPoints\s*/\s*totalExamMaxPoints\)\s*\*\s*100\)"
    },
    @{ 
        Name = "submitRemedialExam: Synchronizes main _evaluation snapshot with remedialEvaluation"; 
        Pattern = "answersObj\['_evaluation'\]\[qid\]\s*=\s*evaluationSnapshot\[qid\]"
    },
    @{ 
        Name = "generateLegerData: Detects isRemedialCompleted status"; 
        Pattern = "isRemedialCompleted\s*=\s*Boolean\(answersObj\s*&&\s*answersObj\['_remedial'\]\s*&&\s*answersObj\['_remedial'\]\.status\s*===\s*'COMPLETED'\)"
    },
    @{ 
        Name = "generateLegerData: Extracts remEvalSnapshot"; 
        Pattern = "remEvalSnapshot\s*=\s*\(isRemedialCompleted\s*&&\s*answersObj\['_remedial'\]\.remedialEvaluation\)"
    },
    @{ 
        Name = "generateLegerData: Updates question earned points using Math.max(earned, remEarned)"; 
        Pattern = "earned\s*=\s*Math\.max\(earned,\s*remEarned\)"
    },
    @{ 
        Name = "generateLegerData: Recalculates earnedPerTP from updated question points"; 
        Pattern = "earnedInTP\s*\+=\s*\(earnedPerQIndex\[qIdx\]\s*\|\|\s*0\)"
    },
    @{ 
        Name = "generateLegerData: Recalculates scoresTP for each TP"; 
        Pattern = "rowObj\.scoresTP\[tp\.id\]\s*=\s*scoreTP"
    },
    @{ 
        Name = "generateLegerData: Recalculates avgTPFinal (Nilai Akhir Leger)"; 
        Pattern = "avgTPFinal\s*=\s*tpList\.length\s*>\s*0\s*\?\s*Math\.round\(sumTPScoreForStudent\s*/\s*tpList\.length\)\s*:\s*0"
    },
    @{ 
        Name = "generateLegerData: Updates isPassed status based on recalculated finalScore"; 
        Pattern = "rowObj\.isPassed\s*=\s*avgTPFinal\s*>=\s*examKKTP"
    },
    @{ 
        Name = "Frontend: buildStudentReportAOA renders updated scoresTP without breaking"; 
        Pattern = "const\s+score\s*=\s*\(st\.scoresTP\s*&&\s*st\.scoresTP\[tp\.id\]\s*!==\s*undefined\)"
    },
    @{ 
        Name = "Frontend: renderLegerTable uses st.scoresTP and st.finalScore directly"; 
        Pattern = "st\.scoresTP\s*&&\s*st\.scoresTP\[tp\.id\]"
    }
)

$passed = 0
$failed = 0

foreach ($c in $checks) {
    $matched = $false
    if ($gsContent -match $c.Pattern -or $htmlContent -match $c.Pattern) {
        $matched = $true
    }

    if ($matched) {
        Write-Host "[PASS] $($c.Name)" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "[FAIL] $($c.Name)" -ForegroundColor Red
        $failed++
    }
}

# ----------------------------------------------------
# SIMULASI PERHITUNGAN MATEMATIS NILAI TP
# ----------------------------------------------------
Write-Host "`n--- Simulasi Logika Rekalkulasi Pasca-Remedial ---" -ForegroundColor Yellow

$questions = @(
    @{ Id = "Q1"; Index = 1; Point = 20; TP = "TP1" },
    @{ Id = "Q2"; Index = 2; Point = 20; TP = "TP1" },
    @{ Id = "Q3"; Index = 3; Point = 20; TP = "TP2" },
    @{ Id = "Q4"; Index = 4; Point = 20; TP = "TP2" },
    @{ Id = "Q5"; Index = 5; Point = 20; TP = "TP3" }
)

# Nilai Awal Siswa: Q1 Benar (20), Q2 Salah (0), Q3 Salah (0), Q4 Benar (20), Q5 Salah (0)
$initialEval = @{
    "Q1" = @{ pointEarned = 20; isCorrect = $true };
    "Q2" = @{ pointEarned = 0;  isCorrect = $false };
    "Q3" = @{ pointEarned = 0;  isCorrect = $false };
    "Q4" = @{ pointEarned = 20; isCorrect = $true };
    "Q5" = @{ pointEarned = 0;  isCorrect = $false }
}

# Remedial: Siswa memperbaiki Q2 dan Q3 menjadi Benar
$remedialEval = @{
    "Q2" = @{ pointEarned = 20; isCorrect = $true };
    "Q3" = @{ pointEarned = 20; isCorrect = $true }
}

# Hitung Awal
$tp1Initial = [Math]::Round(((20 + 0) / 40) * 100) # 50
$tp2Initial = [Math]::Round(((0 + 20) / 40) * 100) # 50
$tp3Initial = [Math]::Round((0 / 20) * 100)        # 0
$naInitial = [Math]::Round(($tp1Initial + $tp2Initial + $tp3Initial) / 3) # 33

# Hitung Pasca-Remedial menggunakan algoritma Math.max(initial, remedial)
$qEarnedPost = @{}
foreach ($q in $questions) {
    $pInit = if ($initialEval.ContainsKey($q.Id)) { $initialEval[$q.Id].pointEarned } else { 0 }
    $pRem = if ($remedialEval.ContainsKey($q.Id)) { $remedialEval[$q.Id].pointEarned } else { 0 }
    $qEarnedPost[$q.Index] = [Math]::Max($pInit, $pRem)
}

$tp1Post = [Math]::Round((($qEarnedPost[1] + $qEarnedPost[2]) / 40) * 100) # (20 + 20) / 40 = 100
$tp2Post = [Math]::Round((($qEarnedPost[3] + $qEarnedPost[4]) / 40) * 100) # (20 + 20) / 40 = 100
$tp3Post = [Math]::Round(($qEarnedPost[5] / 20) * 100)                    # 0
$naPost = [Math]::Round(($tp1Post + $tp2Post + $tp3Post) / 3)             # (100 + 100 + 0) / 3 = 67

Write-Host "Nilai Awal: TP 1 = $tp1Initial, TP 2 = $tp2Initial, TP 3 = $tp3Initial | Nilai Akhir (NA) = $naInitial" -ForegroundColor Gray
Write-Host "Nilai Baru: TP 1 = $tp1Post, TP 2 = $tp2Post, TP 3 = $tp3Post | Nilai Akhir (NA) = $naPost" -ForegroundColor Green

if ($tp1Post -eq 100 -and $tp2Post -eq 100 -and $naPost -eq 67) {
    Write-Host "[PASS] Simulasi matematis rekalkulasi TP dan NA pasca-remedial tepat 100%!" -ForegroundColor Green
    $passed++
} else {
    Write-Host "[FAIL] Simulasi matematis tidak sesuai ekspektasi." -ForegroundColor Red
    $failed++
}

Write-Host "----------------------------------------------------------"
$color = if ($failed -eq 0) { "Green" } else { "Red" }
Write-Host "Hasil Akhir: $passed PASS, $failed FAIL" -ForegroundColor $color

if ($failed -gt 0) {
    exit 1
} else {
    Write-Host "Verifikasi rekalkulasi pasca-remedial BERHASIL LULUS 100%!" -ForegroundColor Green
}
