# ============================================================
# CTF Setup: SAM Dump via Shadow Copy
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 2: SAM Database Dump" -ForegroundColor Cyan

# --- Create target account whose hash we want ---
# Calvin Candie  local admin, his hash is the prize
$candiePass = ConvertTo-SecureString "Candie$Plantation1858" -AsPlainText -Force
New-LocalUser -Name "candie" -Password $candiePass `
    -FullName "Calvin J. Candie" `
    -Description "Owner of Candyland" `
    -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Administrators" -Member "candie" -ErrorAction SilentlyContinue

# --- The flag is only accessible to candie / SYSTEM ---
$flagDir = "C:\CTF\candie_office"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\broomhilda.txt" -Value "CTF{s4m_dumped_h4sh_cr4ck3d_dj4ng0}"

$acl = Get-Acl "$flagDir\broomhilda.txt"
$acl.SetAccessRuleProtection($true, $false)
$r1 = New-Object System.Security.AccessControl.FileSystemAccessRule("candie","FullControl","Allow")
$r2 = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($r1)
$acl.AddAccessRule($r2)
Set-Acl "$flagDir\broomhilda.txt" $acl

# --- Create the low-privileged attacker account ---
$djangoPass = ConvertTo-SecureString "freedom" -AsPlainText -Force
New-LocalUser -Name "django" -Password $djangoPass `
    -FullName "Django Freeman" `
    -Description "Bounty hunter" `
    -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Users" -Member "django" -ErrorAction SilentlyContinue

# --- Create a shadow copy so the SAM is accessible (simulates backup operator scenario) ---
# Give django Backup Operator rights  the realistic escalation path
Add-LocalGroupMember -Group "Backup Operators" -Member "django" -ErrorAction SilentlyContinue

# --- Drop mission briefing ---
$briefing = @"
Candyland Intelligence Report
==============================
Target: Calvin Candie (local Administrator)
Your account: django (Backup Operator)

Candie keeps the door to Broomhilda locked at C:\CTF\candie_office\broomhilda.txt
Only Candie or SYSTEM can read it.

Your lead: Backup Operators can read any file  including the SAM and SYSTEM hives.
Extract Candie's NTLM hash. Crack it or use it directly.

Tools you will need:
  secretsdump.py  (impacket)   dump hashes from SAM/SYSTEM hives offline
  hashcat / john               crack the NTLM hash
  evil-winrm / psexec          authenticate with the cracked password
"@
New-Item -ItemType Directory -Path "C:\Users\django\Desktop" -Force | Out-Null
Set-Content -Path "C:\Users\django\Desktop\MISSION.txt" -Value $briefing
icacls "C:\Users\django\Desktop\MISSION.txt" /grant "django:F" | Out-Null

Write-Host "[+] Done." -ForegroundColor Green
Write-Host "[+] Attacker account: django / freedom (Backup Operator)" -ForegroundColor Green
Write-Host "[+] Target account:   candie / Candie`$Plantation1858 (Administrator)" -ForegroundColor Green
Write-Host "[+] Flag: C:\CTF\candie_office\broomhilda.txt" -ForegroundColor Green
