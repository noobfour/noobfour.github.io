@echo off
chcp 65001 >nul
title NOOBFour - ROBLOX AI WORKSPACE SETUP
set "NF_SELF=%~f0"
rem ตัวติดตั้งไฟล์เดียว (โหลดจากเว็บ) — ส่วนล่างของไฟล์เป็น PowerShell ที่ไฟล์นี้อ่านตัวเองแล้วรัน
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f = $env:NF_SELF; $m = '#PS' + '-START#'; $t = Get-Content -LiteralPath $f -Raw -Encoding UTF8; Invoke-Expression ($t.Substring($t.IndexOf($m) + $m.Length))"
echo.
pause
exit /b
#PS-START#
# ---------- PowerShell ----------
# ทำซ้ำได้ไม่มีผลเสีย: มีของแล้วจะข้าม · มีโปรแกรมแล้วจะดึงตัวล่าสุด
[Console]::OutputEncoding = [Text.Encoding]::UTF8
function Step($t) { Write-Host "`n>> $t" -ForegroundColor Cyan }
function Ok($t) { Write-Host "   [OK] $t" -ForegroundColor Green }
function Warn($t) { Write-Host "   [!] $t" -ForegroundColor Yellow }
function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

$appRepo = 'https://noobfour@github.com/noobfour/roblox-workspace-app.git' # ใส่ชื่อบัญชีไว้ = GitHub เลือกบัญชี noobfour ให้เอง
# NF_TEST = ทดสอบตัวติดตั้ง: ไม่ถาม Enter · โหลดไปโฟลเดอร์ NF_APP_DIR · หยุดก่อนทำไอคอน (ไม่ทับไอคอนจริง)
$app = if ($env:NF_APP_DIR) { $env:NF_APP_DIR } else { Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'roblox-workspace-app' }

Write-Host ''
Write-Host '  NOOBFour · ROBLOX AI WORKSPACE' -ForegroundColor Red
Write-Host '  ตัวติดตั้งโปรแกรมของทีม (ใช้เวลาประมาณ 5-10 นาที)'
Write-Host ''
Write-Host '  จะทำ 3 อย่าง:'
Write-Host '   1) ลง Git และ Node.js ถ้ายังไม่มี (จาก winget ของ Microsoft)'
Write-Host '   2) โหลดโปรแกรมของทีมไว้ที่ Documents\roblox-workspace-app'
Write-Host '   3) ทำไอคอน ROBLOX AI WORKSPACE บนเดสก์ท็อป แล้วเปิดโปรแกรม'
Write-Host ''
Write-Host '  ต้องมีรหัสผ่านบัญชี GitHub "noobfour" (ขอจากดิว)' -ForegroundColor Yellow
Write-Host ''
if (-not $env:NF_TEST) { Read-Host '  กด Enter เพื่อเริ่ม (กด = ยอมรับเงื่อนไขการใช้งานของ Git และ Node.js) หรือปิดหน้าต่างเพื่อยกเลิก' }

function Need($cmd, $id, $name, $url) {
  if (Get-Command $cmd -ErrorAction SilentlyContinue) {
    Ok "$name มีแล้ว"
    return $true
  }
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Warn "เครื่องนี้ไม่มี winget — เปิดหน้าโหลด $name ให้ ติดตั้งแล้วดับเบิลคลิกไฟล์นี้อีกครั้ง"
    Start-Process $url
    return $false
  }
  Step "กำลังลง $name (1-3 นาที · ถ้ามีหน้าต่างถามสิทธิ์ ให้กด Yes)"
  winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements --silent
  Refresh-Path
  if (Get-Command $cmd -ErrorAction SilentlyContinue) {
    Ok "ลง $name แล้ว"
    return $true
  }
  Warn "ลง $name ไม่สำเร็จ — เปิดหน้าโหลดให้ ติดตั้งเองแล้วดับเบิลคลิกไฟล์นี้อีกครั้ง"
  Start-Process $url
  return $false
}

Step 'เช็กของที่ต้องมีในเครื่อง'
$okGit = Need 'git' 'Git.Git' 'Git' 'https://git-scm.com/download/win'
$okNode = Need 'npm' 'OpenJS.NodeJS.LTS' 'Node.js' 'https://nodejs.org/'
if (-not ($okGit -and $okNode)) { return }

if (Test-Path (Join-Path $app '.git')) {
  Step 'มีโปรแกรมอยู่แล้ว — ดึงตัวล่าสุด'
  git -C $app pull --ff-only
} else {
  Step 'โหลดโปรแกรมของทีม — ถ้ามีหน้าต่าง GitHub เด้งขึ้นมา ให้ล็อกอินบัญชี noobfour'
  git clone $appRepo $app
}
if (-not (Test-Path (Join-Path $app 'setup.ps1'))) {
  Warn 'โหลดโปรแกรมไม่สำเร็จ — ส่วนใหญ่เพราะยังไม่ได้ล็อกอิน noobfour · ดับเบิลคลิกไฟล์นี้อีกครั้ง แล้วล็อกอินตอนหน้าต่าง GitHub เด้ง'
  return
}

if ($env:NF_TEST) {
  Ok "[ทดสอบ] โหลดโปรแกรมไว้ที่ $app แล้ว · หยุดก่อนทำไอคอน"
  return
}
# ที่เหลือ (ดึงข้อมูลเกม · ลงส่วนประกอบ · ทำไอคอน · เปิดโปรแกรม) ใช้ตัวติดตั้งเดิมในโฟลเดอร์โปรแกรม
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $app 'setup.ps1')
