# ============================================================
# CTF Setup: AlwaysInstallElevated
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 2: AlwaysInstallElevated" -ForegroundColor Cyan

# --- Enable the AlwaysInstallElevated policy in both hives ---
# This is the actual vulnerability: MSI files install with SYSTEM privileges
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer" /v AlwaysInstallElevated /t REG_DWORD /d 1 /f | Out-Null
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer" /v AlwaysInstallElevated /t REG_DWORD /d 1 /f | Out-Null

# --- Create the flag (readable only by Admins) ---
$flagDir = "C:\CTF\challenge2"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\flag.txt" -Value "CTF{msi_4lw4ys_3l3v4t3d_pwn}"

$acl = Get-Acl "$flagDir\flag.txt"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($rule)
Set-Acl "$flagDir\flag.txt" $acl

# --- Create low-privileged CTF user ---
$password = ConvertTo-SecureString "Player123!" -AsPlainText -Force
New-LocalUser -Name "ctfplayer" -Password $password -FullName "CTF Player" -Description "Challenge user" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Users" -Member "ctfplayer" -ErrorAction SilentlyContinue

Write-Host "[+] Done. AlwaysInstallElevated is now enabled." -ForegroundColor Green
Write-Host "[+] Log in as ctfplayer / Player123! to start the challenge." -ForegroundColor Green
Write-Host "[!] Remember to revert this VM snapshot after the challenge  this setting is dangerous!" -ForegroundColor Yellow
