# ============================================================
# CTF Setup: Weak Service Binary Permissions
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 3: Weak Service Binary Permissions" -ForegroundColor Cyan

# --- Create the "vulnerable" service binary ---
$serviceDir = "C:\Services\BackupService"
New-Item -ItemType Directory -Path $serviceDir -Force | Out-Null

$dummyExe = @'
@echo off
:loop
timeout /t 60 >nul
goto loop
'@
Set-Content -Path "$serviceDir\BackupService.exe" -Value $dummyExe

# --- Register the service ---
sc.exe create "BackupService" binPath= "$serviceDir\BackupService.exe" start= auto DisplayName= "Backup Manager Service" | Out-Null
sc.exe description "BackupService" "Manages automated backup operations." | Out-Null

# --- Give Everyone full control over the service binary (the vulnerability) ---
icacls "$serviceDir\BackupService.exe" /grant Everyone:F | Out-Null

# --- Create the flag ---
$flagDir = "C:\CTF\challenge3"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\flag.txt" -Value "CTF{w34k_s3rv1c3_b1n_r3pl4c3d}"

$acl = Get-Acl "$flagDir\flag.txt"
$acl.SetAccessRuleProtection($true, $false)
$adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($adminRule)
Set-Acl "$flagDir\flag.txt" $acl

# --- Create low-privileged user ---
$password = ConvertTo-SecureString "Player123!" -AsPlainText -Force
New-LocalUser -Name "ctfplayer" -Password $password -FullName "CTF Player" -Description "Challenge user" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Users" -Member "ctfplayer" -ErrorAction SilentlyContinue

# Give ctfplayer permission to restart the service (simulates having SeShutdownPrivilege or sc rights)
sc.exe sdset "BackupService" "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)(A;;RPWP;;;BU)" | Out-Null

Write-Host "[+] Done. Service 'BackupService' is installed with a world-writable binary." -ForegroundColor Green
Write-Host "[+] Log in as ctfplayer / Player123! to start the challenge." -ForegroundColor Green
