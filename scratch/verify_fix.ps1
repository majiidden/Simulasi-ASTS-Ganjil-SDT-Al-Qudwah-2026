$htmlPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\index.html"
$gsPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\Kode.gs.txt"

$html = Get-Content -Path $htmlPath -Raw
$gs = Get-Content -Path $gsPath -Raw

Write-Host "=== VERIFYING FIX FOR PORTAL EXIT & PIN LOGIN ===" -ForegroundColor Cyan

$checks = @(
    @{ Name = "HTML: exitResultPage function exists"; Condition = $html.Contains('function exitResultPage(') },
    @{ Name = "HTML: exitToStudentPortal function exists"; Condition = $html.Contains('function exitToStudentPortal(') },
    @{ Name = "HTML: #btn-back-from-result exists in page-result"; Condition = $html.Contains('id="btn-back-from-result"') },
    @{ Name = "HTML: Bottom return button in page-result exists"; Condition = $html.Contains('Kembali ke Halaman Siswa / Portal') },
    @{ Name = "HTML: togglePinInput removes required from pinInput"; Condition = $html.Contains("pinInput.removeAttribute('required'); // PIN Sesi selalu opsional") },
    @{ Name = "HTML: logout removes required from pinInput"; Condition = $html.Contains("pinInput.removeAttribute('required');`r`n      }") -or $html.Contains("pinInput.removeAttribute('required');`n      }") },
    @{ Name = "HTML: Halaman Siswa button in exam submission exists"; Condition = $html.Contains('onclick="exitToStudentPortal()"') },
    @{ Name = "GS: cleanPin in loginUser handles whitespace"; Condition = $gs.Contains('const cleanPin = pinSesi ? String(pinSesi).trim() :') }
)

$allPassed = $true
foreach ($chk in $checks) {
    if ($chk.Condition) {
        Write-Host "[PASS] $($chk.Name)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $($chk.Name)" -ForegroundColor Red
        $allPassed = $false
    }
}

# Verify no remaining pinInput.setAttribute('required' in login/session scripts
$pinRequiredMatches = [regex]::Matches($html, "pinInput\.setAttribute\(\s*['""]required['""]")
if ($pinRequiredMatches.Count -eq 0) {
    Write-Host "[PASS] No pinInput.setAttribute('required') remaining in index.html" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Found $($pinRequiredMatches.Count) occurrences of pinInput.setAttribute('required')!" -ForegroundColor Red
    $allPassed = $false
}

if ($allPassed) {
    Write-Host "`nAll verification checks passed successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nSome checks failed!" -ForegroundColor Red
    exit 1
}
