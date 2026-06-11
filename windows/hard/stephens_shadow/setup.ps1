# ============================================================
# CTF Setup: Pass-the-Hash
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 3: Pass-the-Hash" -ForegroundColor Cyan

# --- Create the Administrator-level account whose hash Django will steal ---
$stephenPass = ConvertTo-SecureString "Stephen$H3adSlave99" -AsPlainText -Force
New-LocalUser -Name "stephen" -Password $stephenPass `
    -FullName "Stephen" `
    -Description "Head of Candyland operations" `
    -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Administrators" -Member "stephen" -ErrorAction SilentlyContinue

# --- Django: a low-privileged account ---
$djangoPass = ConvertTo-SecureString "freedom" -AsPlainText -Force
New-LocalUser -Name "django" -Password $djangoPass `
    -FullName "Django Freeman" `
    -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Users" -Member "django" -ErrorAction SilentlyContinue

# --- The flag — only stephen / Administrators can read ---
$flagDir = "C:\CTF\stephen_quarters"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\orders.txt" -Value "CTF{p4ss_th3_h4sh_n04m_dj4ng0_w1ns}"

$acl = Get-Acl "$flagDir\orders.txt"
$acl.SetAccessRuleProtection($true, $false)
$r1 = New-Object System.Security.AccessControl.FileSystemAccessRule("stephen","FullControl","Allow")
$r2 = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($r1)
$acl.AddAccessRule($r2)
Set-Acl "$flagDir\orders.txt" $acl

# --- Leave a "memory dump" artifact as the attack vector ---
# In a real engagement this comes from Mimikatz / procdump on lsass.
# Here we simulate by leaving a pre-captured credential file as a clue.
$artifactDir = "C:\Users\django\Desktop\artifacts"
New-Item -ItemType Directory -Path $artifactDir -Force | Out-Null

# Compute Stephen's actual NTLM hash for the briefing note
Add-Type -AssemblyName System.Security
$md4 = [System.Security.Cryptography.MD4]::Create() 2>$null

# Leave the briefing — hash will need to be obtained via secretsdump in practice
$briefing = @"
Candyland Threat Intelligence
==============================
You are django. You have found a memory artifact on this machine.
It contains credentials from a previous session.

Your target: stephen (local Administrator)
His secrets are at: C:\CTF\stephen_quarters\orders.txt

Attack path:
  1. Dump the local SAM (use reg save — you can run cmd as django)
     OR use Mimikatz if you can get SYSTEM first.
  2. Extract stephen's NTLM hash with secretsdump.py
  3. Use the hash directly — no password cracking needed.
     Pass-the-Hash with evil-winrm, psexec, or wmiexec.

Remember: NTLM authentication accepts the hash itself.
You do not need to know the plaintext password.

Tools:
  secretsdump.py  (impacket)
  evil-winrm
  psexec.py / wmiexec.py  (impacket)
  Mimikatz (optional — if you escalate first)
"@
Set-Content -Path "$artifactDir\BRIEFING.txt" -Value $briefing
icacls $artifactDir /grant "django:F" | Out-Null

# --- Enable WinRM so evil-winrm works ---
Enable-PSRemoting -Force -ErrorAction SilentlyContinue | Out-Null
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force -ErrorAction SilentlyContinue

Write-Host "[+] Done." -ForegroundColor Green
Write-Host "[+] Attacker: django / freedom" -ForegroundColor Green
Write-Host "[+] Target:   stephen (Administrator)" -ForegroundColor Green
Write-Host "[+] Flag:     C:\CTF\stephen_quarters\orders.txt" -ForegroundColor Green
Write-Host "[+] WinRM enabled for evil-winrm attacks." -ForegroundColor Green
