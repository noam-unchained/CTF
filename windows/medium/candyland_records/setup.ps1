# ============================================================
# CTF Setup: Registry Autorun Hijack
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 3: Registry Autorun Hijack" -ForegroundColor Cyan

# --- Create the "agent" binary that autoruns as SYSTEM ---
$agentDir = "C:\ProgramData\SysAgent"
New-Item -ItemType Directory -Path $agentDir -Force | Out-Null

$stub = @'
@echo off
echo Agent started >> C:\ProgramData\SysAgent\agent.log
'@
Set-Content -Path "$agentDir\agent.exe" -Value $stub

# --- Add an HKLM Run registry key pointing to the binary ---
# HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run entries run at logon for all users
# On this machine the entry has been configured to run under the SYSTEM context via a wrapper
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SysAgent" /t REG_SZ /d "`"$agentDir\agent.exe`"" /f | Out-Null

# --- Create the flag ---
$flagDir = "C:\CTF\challenge_reg"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\flag.txt" -Value "CTF{r3g1stry_4ut0run_h1j4ck3d}"

$acl = Get-Acl "$flagDir\flag.txt"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($rule)
Set-Acl "$flagDir\flag.txt" $acl

# --- Create ctfplayer ---
$password = ConvertTo-SecureString "Player123!" -AsPlainText -Force
New-LocalUser -Name "ctfplayer" -Password $password -FullName "CTF Player" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Users" -Member "ctfplayer" -ErrorAction SilentlyContinue

# --- Give ctfplayer write access to the agent directory (the vulnerability) ---
$acl2 = Get-Acl $agentDir
$rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "ctfplayer","FullControl","ContainerInherit,ObjectInherit","None","Allow")
$acl2.AddAccessRule($rule2)
Set-Acl $agentDir $acl2

# --- Also give ctfplayer write access to the Run registry key ---
# So they can also observe the key (read) and understand the attack surface
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$regAcl = Get-Acl $regPath
$regRule = New-Object System.Security.AccessControl.RegistryAccessRule(
    "ctfplayer","ReadKey","Allow")
$regAcl.AddAccessRule($regRule)
Set-Acl $regPath $regAcl

Write-Host "[+] Done. Registry key: HKLM\...\Run\SysAgent -> $agentDir\agent.exe" -ForegroundColor Green
Write-Host "[+] The agent directory is writable by ctfplayer." -ForegroundColor Green
Write-Host "[+] Log in as ctfplayer / Player123!  the autorun fires at next logon." -ForegroundColor Green
Write-Host "[!] Take a VM snapshot before setup. The autorun will fire on your own logon too." -ForegroundColor Yellow
