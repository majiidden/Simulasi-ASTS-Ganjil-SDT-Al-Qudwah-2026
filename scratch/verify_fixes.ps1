$html = Get-Content '.\index.html' -Raw -Encoding UTF8
$gs = Get-Content '.\Kode.gs.txt' -Raw -Encoding UTF8

$errors = @()

if ($html -notmatch 'openStudentPortal\(res\)') {
    $errors += 'FAIL: openStudentPortal(res) not found in index.html'
} else {
    Write-Host 'OK: openStudentPortal(res) called on login success' -ForegroundColor Green
}

if ($html -notmatch 'function initStudentPortal\(portalInitData\)') {
    $errors += 'FAIL: initStudentPortal alias function not found in index.html'
} else {
    Write-Host 'OK: initStudentPortal alias function found' -ForegroundColor Green
}

if ($html -notmatch 'ex\.isExpired') {
    $errors += 'FAIL: ex.isExpired handling not found in index.html'
} else {
    Write-Host 'OK: ex.isExpired UI handling found in index.html' -ForegroundColor Green
}

if ($gs -notmatch 'KONDISI 1: JIKA SISWA MASIH DALAM STATUS TERBLOKIR') {
    $errors += 'FAIL: Kondisi 1 (Blocked rejection) not found in Kode.gs.txt'
} else {
    Write-Host 'OK: Kondisi 1 (Blocked rejection) found in Kode.gs.txt' -ForegroundColor Green
}

if ($gs -notmatch 'KONDISI 2: JIKA SISWA MEMILIKI UJIAN AKTIF') {
    $errors += 'FAIL: Kondisi 2 (In Progress auto-resume) not found in Kode.gs.txt'
} else {
    Write-Host 'OK: Kondisi 2 (In Progress auto-resume) found in Kode.gs.txt' -ForegroundColor Green
}

if ($gs -notmatch 'KONDISI 3: SISWA LOGIN TANPA PIN') {
    $errors += 'FAIL: Kondisi 3 (No PIN -> Portal) not found in Kode.gs.txt'
} else {
    Write-Host 'OK: Kondisi 3 (No PIN -> Portal) found in Kode.gs.txt' -ForegroundColor Green
}

if ($gs -notmatch 'examItem\.isExpired = isPastTime \|\| isNonAktif') {
    $errors += 'FAIL: isExpired calculation not found in Kode.gs.txt'
} else {
    Write-Host 'OK: isExpired calculation found in Kode.gs.txt' -ForegroundColor Green
}

if ($errors.Count -eq 0) {
    Write-Host 'ALL VERIFICATIONS PASSED!' -ForegroundColor Cyan
} else {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
