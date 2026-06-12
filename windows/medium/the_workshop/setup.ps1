# ============================================================
# CTF Setup: DLL Hijacking
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 1: DLL Hijacking" -ForegroundColor Cyan

# --- Create the "vulnerable" application directory ---
$appDir = "C:\Apps\MonitoringTool"
New-Item -ItemType Directory -Path $appDir -Force | Out-Null

# Simulate a service binary (batch stub for CTF purposes)
$stub = @'
@echo off
:loop
timeout /t 30 >nul
goto loop
'@
Set-Content -Path "$appDir\MonitoringTool.exe" -Value $stub

# --- Register as a service ---
sc.exe create "MonitoringService" binPath= "`"$appDir\MonitoringTool.exe`"" start= auto DisplayName= "System Monitoring Service" | Out-Null
sc.exe description "MonitoringService" "Performs real-time system health monitoring." | Out-Null

# --- Create a helper DLL log to simulate DLL search order ---
# The "documentation" the player finds will reference that the app loads helper.dll
# We create a manifest/readme as the clue
$readme = @"
MonitoringTool v2.3.1
---------------------
This tool loads the following DLLs at startup:
  - C:\Windows\System32\kernel32.dll  (system)
  - C:\Windows\System32\user32.dll    (system)
  - helper.dll                        (local  must be in application directory)

If helper.dll is not found in the application directory, the tool will search
standard system paths. Place the DLL in $appDir to override.
"@
Set-Content -Path "$appDir\README.txt" -Value $readme

# --- Create the flag (Admin only) ---
$flagDir = "C:\CTF\challenge_dll"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\flag.txt" -Value "CTF{dll_h1j4ck_s3rv1c3_pwn3d}"

$acl = Get-Acl "$flagDir\flag.txt"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($rule)
Set-Acl "$flagDir\flag.txt" $acl

# --- Give ctfplayer write access to the application directory (the vulnerability) ---
$password = ConvertTo-SecureString "Player123!" -AsPlainText -Force
New-LocalUser -Name "ctfplayer" -Password $password -FullName "CTF Player" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Users" -Member "ctfplayer" -ErrorAction SilentlyContinue

$acl2 = Get-Acl $appDir
$rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "ctfplayer","Write,ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow")
$acl2.AddAccessRule($rule2)
Set-Acl $appDir $acl2

Write-Host "[+] Done. Service: MonitoringService | App dir: $appDir" -ForegroundColor Green
Write-Host "[+] Log in as ctfplayer / Player123! to start." -ForegroundColor Green
