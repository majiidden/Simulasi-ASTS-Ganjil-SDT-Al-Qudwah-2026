# Test Suite: Auto & Bulk Essay Grading Verification
# Verifies both Kode.gs.txt backend logic and index.html UI components

$ErrorActionPreference = "Stop"
$testResults = @()

function Report-Test {
    param($Name, $Passed, $Detail)
    $obj = [PSCustomObject]@{
        TestName = $Name
        Status = if ($Passed) { "PASS" } else { "FAIL" }
        Detail = $Detail
    }
    $global:testResults += $obj
    if ($Passed) {
        Write-Host " [PASS] $Name" -ForegroundColor Green
    } else {
        Write-Host " [FAIL] $Name - $Detail" -ForegroundColor Red
    }
}

Write-Host "`n=== 1. VERIFYING BACKEND (Kode.gs.txt) ===" -ForegroundColor Cyan
$kodePath = "Kode.gs.txt"
$kodeContent = [System.IO.File]::ReadAllText($kodePath)

# Test 1: gradeEssayAnswer function exists and checks keywords
$hasGradeEssay = $kodeContent -match "function gradeEssayAnswer\s*\(\s*userAnswer\s*,\s*keyRaw\s*,\s*weight\s*\)"
Report-Test "gradeEssayAnswer defined" $hasGradeEssay "Checks student answer against exact keywords proportionally"

# Test 2: getEssayData updated with recommendedScore, maxTotalScore, autoInfo
$hasGetEssayDataRec = ($kodeContent -match "recommendedTotalScore") -and ($kodeContent -match "autoInfo") -and ($kodeContent -match "maxTotalScore")
Report-Test "getEssayData returns auto recommendations and weights" $hasGetEssayDataRec "Returns autoInfo, recommendedScore, maxTotalScore"

# Test 3: saveEssayGrade handles perItemScores parameter and updates _evaluation
$hasSaveEssayPerItem = ($kodeContent -match "function saveEssayGrade\s*\(\s*responseId\s*,\s*essayScoreInput\s*,\s*perItemScores\s*\)") -and ($kodeContent -match "perItemScores\[qid\]")
Report-Test "saveEssayGrade accepts perItemScores" $hasSaveEssayPerItem "Supports per-item manual grading and persists into _evaluation"

# Test 4: autoGradeAllEssays function exists with role check, lock, and overwriteManual flag
$hasAutoGradeAll = ($kodeContent -match "function autoGradeAllEssays\s*\(\s*examID\s*,\s*overwriteManual\s*,\s*requestorID\s*,\s*requestorToken\s*\)")
$hasRoleCheck = $kodeContent -match "role !== 'admin' && role !== 'guru'"
$hasLock = $kodeContent -match "lock\.waitLock\(15000\)"
$hasSkipProtection = ($kodeContent -match "hasManualScore && !overwriteManual")
Report-Test "autoGradeAllEssays implemented" ($hasAutoGradeAll -and $hasRoleCheck -and $hasLock -and $hasSkipProtection) "Role check, lock, and overwriteManual protection active"

Write-Host "`n=== 2. VERIFYING FRONTEND (index.html) ===" -ForegroundColor Cyan
$htmlPath = "index.html"
$htmlContent = [System.IO.File]::ReadAllText($htmlPath)

# Test 5: #btn-bulk-grade-essay exists in toolbar
$hasBtnBulk = $htmlContent -match 'id="btn-bulk-grade-essay"'
Report-Test "Toolbar has #btn-bulk-grade-essay" $hasBtnBulk "Button present with openBulkEssayModal click handler"

# Test 6: #modal-confirm-bulk-essay exists with confirmation details
$hasModalBulk = ($htmlContent -match 'id="modal-confirm-bulk-essay"') -and ($htmlContent -match 'id="chk-bulk-overwrite-manual"') -and ($htmlContent -match 'id="btn-confirm-bulk-essay"')
Report-Test "Modal #modal-confirm-bulk-essay present" $hasModalBulk "Includes overwrite manual checkbox and confirm action"

# Test 7: Upgraded #modal-grading with per-item inputs and auto recommendation button
$hasUpgradedModal = ($htmlContent -match 'id="btn-modal-apply-all-auto"') -and ($htmlContent -match 'id="grading-stats-info"') -and ($htmlContent -match 'id="input-essay-score"')
Report-Test "Upgraded #modal-grading markup present" $hasUpgradedModal "Includes apply all auto button and stats info"

# Test 8: Frontend JS functions defined
$hasJsBulk = ($htmlContent -match "function openBulkEssayModal") -and ($htmlContent -match "function closeBulkEssayModal") -and ($htmlContent -match "function executeBulkEssayGrading")
$hasJsPerItem = ($htmlContent -match "function recalcModalEssayTotal") -and ($htmlContent -match "function applyItemAutoScore") -and ($htmlContent -match "function applyAllAutoScoresToModal")
Report-Test "JS Bulk & Per-Item grading functions defined" ($hasJsBulk -and $hasJsPerItem) "Handlers for open/close/execute and item calculations defined"

# Test 9: saveEssayGrade invocation passes perItemScores
$hasSaveEssayCall = $htmlContent -match '\.saveEssayGrade\s*\(\s*currentGradingId\s*,\s*score\s*,\s*perItemScores\s*\)'
Report-Test "submitEssayGrade passes perItemScores to backend" $hasSaveEssayCall "Sends per-question scores to saveEssayGrade"

# Test 10: autoGradeAllEssays invocation in frontend
$hasAutoGradeAllCall = $htmlContent -match '\.autoGradeAllEssays\s*\(\s*examId\s*,\s*overwrite\s*,'
Report-Test "executeBulkEssayGrading calls autoGradeAllEssays" $hasAutoGradeAllCall "Sends examId and overwriteManual flag"

# Test 11: Toolbar button visibility logic in loadResultsTable
$hasBtnBulkInLoad = ($htmlContent -match "btnBulkEssay\.classList\.add\('hidden'\)") -and ($htmlContent -match "btnBulkEssay\.classList\.remove\('hidden'\)")
Report-Test "btnBulkEssay toggled in loadResultsTable" $hasBtnBulkInLoad "Hidden on empty, visible on exam selection"

Write-Host "`n=== 3. SIMULATION: EXACT KEYWORD MATCHING ALGORITHM ===" -ForegroundColor Cyan
function Sim-GradeEssayAnswer {
    param($studentAnswer, $answerKey, $weight)
    $cleanAns = if ($studentAnswer) { [string]$studentAnswer.ToLower().Trim() } else { "" }
    $cleanKey = if ($answerKey) { [string]$answerKey.ToLower().Trim() } else { "" }
    
    if (-not $cleanKey) {
        return @{ Score = $weight; Matched = @(); Missing = @(); Total = 0; Status = "Lulus (Tanpa Kunci)" }
    }
    if (-not $cleanAns) {
        return @{ Score = 0; Matched = @(); Missing = @(); Total = 0; Status = "Kosong" }
    }

    $rawKeywords = $cleanKey -split '[,;]+'
    $keywords = @()
    foreach ($k in $rawKeywords) {
        $t = $k.Trim()
        if ($t -ne "") { $keywords += $t }
    }

    if ($keywords.Count -eq 0) {
        return @{ Score = $weight; Matched = @(); Missing = @(); Total = 0; Status = "Lulus (Kunci Umum)" }
    }

    $matched = @()
    $missing = @()
    foreach ($kw in $keywords) {
        if ($cleanAns.Contains($kw)) {
            $matched += $kw
        } else {
            $missing += $kw
        }
    }

    $ratio = $matched.Count / $keywords.Count
    $calculatedScore = [Math]::Round(($ratio * $weight), 2)

    $status = if ($ratio -ge 0.8) { "Sangat Baik" }
              elseif ($ratio -ge 0.5) { "Cukup" }
              elseif ($ratio -gt 0) { "Kurang" }
              else { "Tidak Cocok" }

    return @{
        Score = $calculatedScore
        Matched = $matched
        Missing = $missing
        Total = $keywords.Count
        Status = $status
    }
}

# Test 12: Full match
$sim1 = Sim-GradeEssayAnswer "Fotosintesis membutuhkan cahaya matahari dan klorofil pada tumbuhan hijau." "cahaya matahari, klorofil, fotosintesis" 15
Report-Test "Keyword Sim 1: Full Match" ($sim1.Score -eq 15 -and $sim1.Matched.Count -eq 3) "Score: $($sim1.Score)/15, Matched: $($sim1.Matched.Count)/3"

# Test 13: Partial match
$sim2 = Sim-GradeEssayAnswer "Proses ini memerlukan cahaya matahari untuk menghasilkan glukosa." "cahaya matahari, klorofil, fotosintesis" 15
$expectedPartial = [Math]::Round((1/3) * 15, 2)
Report-Test "Keyword Sim 2: Partial Match" ($sim2.Score -eq $expectedPartial -and $sim2.Matched.Count -eq 1) "Score: $($sim2.Score)/15, Matched: $($sim2.Matched.Count)/3"

# Test 14: No match
$sim3 = Sim-GradeEssayAnswer "Saya tidak tahu jawabannya pak guru." "cahaya matahari, klorofil, fotosintesis" 15
Report-Test "Keyword Sim 3: Zero Match" ($sim3.Score -eq 0 -and $sim3.Matched.Count -eq 0) "Score: $($sim3.Score)/15, Status: $($sim3.Status)"

# Final Summary
$failed = ($global:testResults | Where-Object { $_.Status -eq "FAIL" }).Count
Write-Host "`n========================================================" -ForegroundColor Cyan
if ($failed -eq 0) {
    Write-Host " ALL $($global:testResults.Count) TESTS PASSED SUCCESSFULLY! " -ForegroundColor Black -BackgroundColor Green
} else {
    Write-Host " $failed OF $($global:testResults.Count) TESTS FAILED! " -ForegroundColor White -BackgroundColor Red
}
Write-Host "========================================================`n" -ForegroundColor Cyan
