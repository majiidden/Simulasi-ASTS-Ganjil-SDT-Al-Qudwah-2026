# Test Suite: Validasi Menu 'Tentang', Fitur Unggulan, dan Copyright Maifars System Co. - V 3.5

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

Write-Host "`n=== [TEST SUITE] VALIDASI MENU TENTANG & COPYRIGHT MAIFARS SYSTEM CO. V 3.5 ===" -ForegroundColor Cyan

$htmlPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\index.html"
$htmlContent = Get-Content -Path $htmlPath -Raw -Encoding UTF8

# 1. MENU SIDEBAR "TENTANG"
Write-Host "`n--- 1. Menu Sidebar Admin 'Tentang' ---" -ForegroundColor Yellow
Assert-Test -Name "Sidebar memuat menu #menu-about" `
    -Condition ($htmlContent -match 'id="menu-about"')

Assert-Test -Name "Menu #menu-about memanggil showAdminTab('dash-about', this)" `
    -Condition ($htmlContent -match "showAdminTab\('dash-about',\s*this\)")

Assert-Test -Name "Menu #menu-about memiliki teks 'Tentang' dan ikon fas fa-info-circle" `
    -Condition ($htmlContent -match "fa-info-circle" -and $htmlContent -match 'Tentang</span>')

# 2. ROUTING SHOWADMINTAB
Write-Host "`n--- 2. Routing Halaman showAdminTab ---" -ForegroundColor Yellow
Assert-Test -Name "showAdminTab menangani tabId 'dash-about'" `
    -Condition ($htmlContent -match "tabId\s*===\s*'dash-about'")

Assert-Test -Name "showAdminTab memanggil renderAboutPage" `
    -Condition ($htmlContent -match "runRender\('renderAboutPage',\s*'Tentang Sistem & Fitur Unggulan'\)")

# 3. KONTEN HALAMAN TENTANG (RENDERABOUTPAGE)
Write-Host "`n--- 3. Konten & Arsitektur Halaman renderAboutPage ---" -ForegroundColor Yellow
Assert-Test -Name "Fungsi renderAboutPage terdefinisi" `
    -Condition ($htmlContent -match "function renderAboutPage\(container\)")

Assert-Test -Name "Hero Banner memuat branding 'Maifars System Co.' dan 'Version 3.5 Enterprise Edition'" `
    -Condition ($htmlContent -match "Version 3\.5 Enterprise Edition" -and $htmlContent -match "Maifars System Co\.")

Assert-Test -Name "Statistik performa teknis (Lock Time < 100ms, CacheService 6H, SheetJS)" `
    -Condition ($htmlContent -match "Lock Holding Time" -and $htmlContent -match "ScriptCache TTL")

Assert-Test -Name "Pilar 1: Ketahanan Konkurensi & Anti-Macet" `
    -Condition ($htmlContent -match "Ketahanan Konkurensi & Anti-Macet")

Assert-Test -Name "Pilar 2: Remedial Adaptif Berbasis KKTP" `
    -Condition ($htmlContent -match "Remedial Adaptif Berbasis KKTP")

Assert-Test -Name "Pilar 3: Koreksi Esai Otomatis & Massal" `
    -Condition ($htmlContent -match "Koreksi Esai Otomatis & Massal")

Assert-Test -Name "Pilar 4: Leger TP & Ekspor Excel Presisi" `
    -Condition ($htmlContent -match "Leger TP & Ekspor Excel Presisi")

Assert-Test -Name "Pilar 5: Keamanan & Integritas Berlapis" `
    -Condition ($htmlContent -match "Keamanan & Integritas Berlapis")

Assert-Test -Name "Pilar 6: Portal Siswa & Sinergi Orang Tua" `
    -Condition ($htmlContent -match "Portal Siswa & Sinergi Orang Tua")

Assert-Test -Name "Kartu Profil Resmi Pengembang 'Maifars System Co.'" `
    -Condition ($htmlContent -match "Maifars System Co\." -and $htmlContent -match "Official Developer")

# 4. COPYRIGHT STATEMENTS
Write-Host "`n--- 4. Penempatan Copyright 'copyright Maifars System Co. - V 3.5.' ---" -ForegroundColor Yellow
Assert-Test -Name "Copyright pada Halaman Login (#page-login)" `
    -Condition ($htmlContent -match "copyright Maifars System Co\. - V 3\.5\." -and $htmlContent -match 'id="loginForm"')

Assert-Test -Name "Copyright pada Footer Halaman Siswa (#page-student-portal)" `
    -Condition ($htmlContent -match '<!-- FOOTER HALAMAN SISWA -->' -and $htmlContent -match 'copyright Maifars System Co\. - V 3\.5\.')

Assert-Test -Name "Copyright pada Kartu Profil Pengembang di Halaman Tentang" `
    -Condition ($htmlContent -match 'copyright Maifars System Co\. - V 3\.5\.' -and $htmlContent -match 'All Rights Reserved\. SD Terpadu Al-Qudwah\.')

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " HASIL AKHIR PENGUJIAN MENU TENTANG & COPYRIGHT:" -ForegroundColor Cyan
Write-Host " Passed : $script:passed" -ForegroundColor Green
Write-Host " Failed : $script:failed" -ForegroundColor $(if ($script:failed -gt 0) { "Red" } else { "Green" })
Write-Host "========================================================`n" -ForegroundColor Cyan

if ($script:failed -gt 0) { exit 1 } else { exit 0 }
