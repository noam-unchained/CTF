# ============================================================
# CTF Setup: SeImpersonatePrivilege  PrintSpoofer / GodPotato
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 1: SeImpersonatePrivilege" -ForegroundColor Cyan

# --- Create a service account with SeImpersonatePrivilege ---
# This mimics the real-world scenario of a compromised IIS/MSSQL service account
$password = ConvertTo-SecureString "Schultz1858!" -AsPlainText -Force
New-LocalUser -Name "schultz" -Password $password `
    -FullName "Dr. King Schultz" `
    -Description "Bounty hunter service account" `
    -ErrorAction SilentlyContinue

# Add to IIS_IUSRS to simulate a web app service account context
Add-LocalGroupMember -Group "IIS_IUSRS" -Member "schultz" -ErrorAction SilentlyContinue

# Grant SeImpersonatePrivilege via a local security policy export/import
# Using ntrights or secedit approach
$seceditCfg = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeImpersonatePrivilege = *S-1-5-32-568,*S-1-5-20,*S-1-5-19,schultz
"@
$cfgPath = "$env:TEMP\seimpersonate.cfg"
Set-Content -Path $cfgPath -Value $seceditCfg -Encoding Unicode
secedit /configure /db "$env:TEMP\secedit.sdb" /cfg $cfgPath /quiet
Remove-Item $cfgPath -Force -ErrorAction SilentlyContinue

# --- Create the flag ---
$flagDir = "C:\CTF\candyland_vault"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\broomhilda.txt" -Value "CTF{p0t4t0_k1ng_dj4ng0_1mp3rs0n4t3d_SYSTEM}"

$acl = Get-Acl "$flagDir\broomhilda.txt"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($rule)
Set-Acl "$flagDir\broomhilda.txt" $acl

# --- Drop PrintSpoofer and GodPotato download instructions ---
$toolsDir = "C:\Users\schultz\Desktop\tools"
New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
$readme = @"
Candyland Security Briefing
============================
Account: schultz
Privilege: SeImpersonatePrivilege

Your mission: escalate to SYSTEM and retrieve broomhilda.txt from C:\CTF\candyland_vault\

Tools you will need (download to this machine):
  PrintSpoofer64.exe   https://github.com/itm4n/PrintSpoofer/releases
  GodPotato.exe        https://github.com/BeichenDream/GodPotato/releases

Both exploit SeImpersonatePrivilege to impersonate the SYSTEM token.
"@
Set-Content -Path "$toolsDir\MISSION.txt" -Value $readme
icacls $toolsDir /grant "schultz:F" | Out-Null

Write-Host "[+] Done." -ForegroundColor Green
Write-Host "[+] Log in as: schultz / Schultz1858!" -ForegroundColor Green
Write-Host "[+] Flag is at: C:\CTF\candyland_vault\broomhilda.txt" -ForegroundColor Green
Write-Host "[!] Reboot the VM once after setup for SeImpersonatePrivilege to fully apply." -ForegroundColor Yellow
