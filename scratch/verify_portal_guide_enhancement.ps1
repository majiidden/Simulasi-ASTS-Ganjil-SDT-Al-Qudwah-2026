# Test Suite: Validasi Pembaruan Tab 3 Portal Siswa (Tata Tertib & Panduan Orang Tua)

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

Write-Host "`n=== [TEST SUITE] VALIDASI PEMBARUAN TATA TERTIB & PANDUAN ORANG TUA ===" -ForegroundColor Cyan

$htmlPath = "c:\Users\ACER\.gemini\antigravity\scratch\ujian online\index.html"
$htmlContent = Get-Content -Path $htmlPath -Raw -Encoding UTF8

# 1. STRUKTUR KONTAINER UTAMA
Write-Host "`n--- 1. Struktur Kontainer Utama Tab 3 ---" -ForegroundColor Yellow
Assert-Test -Name "DOM memiliki tab kontainer #tab-portal-guide" `
    -Condition ($htmlContent -match 'id="tab-portal-guide"')

Assert-Test -Name "Tata letak grid responsif 12-kolom (lg:col-span-5 dan lg:col-span-7)" `
    -Condition ($htmlContent -match 'lg:grid-cols-12' -and $htmlContent -match 'lg:col-span-5' -and $htmlContent -match 'lg:col-span-7')

# 2. TATA TERTIB SISWA LENGKAP & PEMBARUAN TEKNIS
Write-Host "`n--- 2. Tata Tertib Siswa & Aturan Teknis Terkini ---" -ForegroundColor Yellow
Assert-Test -Name "Tata Tertib: Aturan Fullscreen (Layar Penuh) dipertahankan" `
    -Condition ($htmlContent -match "Wajib Layar Penuh \(Fullscreen\)")

Assert-Test -Name "Tata Tertib: Larangan Pindah Tab dipertahankan" `
    -Condition ($htmlContent -match "Dilarang Pindah Tab \/ Aplikasi")

Assert-Test -Name "Tata Tertib: Waktu Minimal dipertahankan" `
    -Condition ($htmlContent -match "Syarat Waktu Minimal")

Assert-Test -Name "Tata Tertib: Fitur Zoom Gambar dipertahankan" `
    -Condition ($htmlContent -match "Fitur Zoom Gambar")

Assert-Test -Name "Tata Tertib [BARU]: Ketahanan Jaringan & Cadangan (.cbt) offline" `
    -Condition ($htmlContent -match "Ketahanan Jaringan & Cadangan \(\.cbt\)")

Assert-Test -Name "Tata Tertib [BARU]: Ketentuan Sesi Remedial KKTP & PIN Resmi" `
    -Condition ($htmlContent -match "Ketentuan Sesi Remedial KKTP")

# 3. PANDUAN ORANG TUA: TRANSFORMASI DIGITAL & 4 PILAR KEUNGGULAN
Write-Host "`n--- 3. Panduan Orang Tua & 4 Pilar Keunggulan Sistem ---" -ForegroundColor Yellow
Assert-Test -Name "Header: Judul 'Transformasi Digital & Kemitraan Orang Tua'" `
    -Condition ($htmlContent -match "Transformasi Digital & Kemitraan Orang Tua")

Assert-Test -Name "Narasi: Pengantar literasi digital dan karakter islami SD Terpadu Al-Qudwah" `
    -Condition ($htmlContent -match "Ayah dan Bunda yang dirahmati Allah" -and $htmlContent -match "positif, berakhlak, mandiri, dan berkarakter islami")

Assert-Test -Name "Pilar 1: Literasi Digital Sejak Dini" `
    -Condition ($htmlContent -match "Literasi Digital Sejak Dini")

Assert-Test -Name "Pilar 2: Asesmen Ramah Anak & KKTP (No Child Left Behind)" `
    -Condition ($htmlContent -match "Asesmen Ramah Anak & KKTP" -and $htmlContent -match "No Child Left Behind")

Assert-Test -Name "Pilar 3: Transparansi Capaian TP (Kurikulum Merdeka)" `
    -Condition ($htmlContent -match "Transparansi Capaian TP")

Assert-Test -Name "Pilar 4: Proteksi & Kejujuran Moral" `
    -Condition ($htmlContent -match "Proteksi & Kejujuran Moral")

Assert-Test -Name "Kutipan Refleksi: Sinergi sekolah dan keluarga" `
    -Condition ($htmlContent -match "Sinergi sekolah dan keluarga adalah kunci keberkahan belajar ananda")

Assert-Test -Name "Helpdesk: Layanan Pendampingan & Helpdesk Ujian resmi" `
    -Condition ($htmlContent -match "Layanan Pendampingan & Helpdesk Ujian")

Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " HASIL AKHIR PENGUJIAN TAB TATA TERTIB & PANDUAN ORANG TUA:" -ForegroundColor Cyan
Write-Host " Passed : $script:passed" -ForegroundColor Green
Write-Host " Failed : $script:failed" -ForegroundColor $(if ($script:failed -gt 0) { "Red" } else { "Green" })
Write-Host "========================================================`n" -ForegroundColor Cyan

if ($script:failed -gt 0) { exit 1 } else { exit 0 }
