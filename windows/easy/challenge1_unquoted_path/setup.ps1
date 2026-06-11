# ============================================================
# CTF Setup: Unquoted Service Path
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 1: Unquoted Service Path" -ForegroundColor Cyan

# --- Create a fake "vulnerable" service binary ---
$servicePath = "C:\Program Files\Vulnerable App\bin\service.exe"
$dirPath     = "C:\Program Files\Vulnerable App\bin"

New-Item -ItemType Directory -Path $dirPath -Force | Out-Null

# Minimal batch-as-exe trick: we use a simple script compiled to exe via PS.
# For CTF purposes we create a dummy bat that acts as the service placeholder.
$dummyService = @'
@echo off
:loop
timeout /t 60 >nul
goto loop
'@
Set-Content -Path "$dirPath\service.exe" -Value $dummyService

# --- Create the flag (readable only by SYSTEM/Administrators) ---
$flagDir = "C:\Windows\System32\config\ctf"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\flag.txt" -Value "CTF{unqu0t3d_p4th_pr1v3sc}"

# Lock down flag to Admins only
$acl = Get-Acl "$flagDir\flag.txt"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($rule)
Set-Acl "$flagDir\flag.txt" $acl

# --- Register the service with an unquoted path (the vulnerability) ---
# The path has spaces and NO quotes around it — Windows will try:
#   C:\Program.exe
#   C:\Program Files\Vulnerable.exe   <-- player plants their binary here
#   C:\Program Files\Vulnerable App\bin\service.exe
$binPath = "C:\Program Files\Vulnerable App\bin\service.exe"  # deliberately unquoted in sc
sc.exe create "VulnerableService" binPath= $binPath start= auto DisplayName= "Vulnerable Maintenance Service" | Out-Null
sc.exe description "VulnerableService" "Performs routine system maintenance." | Out-Null

# --- Create a low-privileged CTF user ---
$password = ConvertTo-SecureString "Player123!" -AsPlainText -Force
New-LocalUser -Name "ctfplayer" -Password $password -FullName "CTF Player" -Description "Challenge user" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Users" -Member "ctfplayer" -ErrorAction SilentlyContinue

# Give ctfplayer write access to C:\Program Files\Vulnerable App\  (not the bin subfolder)
# This simulates the common misconfiguration where the parent directory is writable
$parentDir = "C:\Program Files\Vulnerable App"
$acl2 = Get-Acl $parentDir
$rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule("ctfplayer","Write,ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow")
$acl2.AddAccessRule($rule2)
Set-Acl $parentDir $acl2

Write-Host "[+] Done. Switch to user 'ctfplayer' (password: Player123!) to start the challenge." -ForegroundColor Green
Write-Host "[+] Service name: VulnerableService" -ForegroundColor Green
