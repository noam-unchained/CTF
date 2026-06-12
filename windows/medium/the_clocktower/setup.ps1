# ============================================================
# CTF Setup: Scheduled Task  Writable Binary
# Run as Administrator in a Windows VM
# ============================================================

Write-Host "[*] Setting up Challenge 2: Scheduled Task with Writable Binary" -ForegroundColor Cyan

# --- Create the task binary ---
$taskDir = "C:\Tasks\Cleanup"
New-Item -ItemType Directory -Path $taskDir -Force | Out-Null

$stub = @'
@echo off
echo Cleanup complete >> C:\Tasks\Cleanup\cleanup.log
'@
Set-Content -Path "$taskDir\cleanup.exe" -Value $stub

# --- Register a scheduled task that runs as SYSTEM every minute ---
$action  = New-ScheduledTaskAction -Execute "$taskDir\cleanup.exe"
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 1) -Once -At (Get-Date)
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 1)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "SystemCleanup" `
    -Action $action -Trigger $trigger -Settings $settings -Principal $principal `
    -Description "Performs routine system cleanup." -Force | Out-Null

# --- Create the flag ---
$flagDir = "C:\CTF\challenge_task"
New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
Set-Content -Path "$flagDir\flag.txt" -Value "CTF{t4sk_b1n_r3pl4c3d_by_pl4y3r}"

$acl = Get-Acl "$flagDir\flag.txt"
$acl.SetAccessRuleProtection($true, $false)
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$acl.AddAccessRule($rule)
Set-Acl "$flagDir\flag.txt" $acl

# --- Create ctfplayer and give write access to the task directory ---
$password = ConvertTo-SecureString "Player123!" -AsPlainText -Force
New-LocalUser -Name "ctfplayer" -Password $password -FullName "CTF Player" -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "Users" -Member "ctfplayer" -ErrorAction SilentlyContinue

$acl2 = Get-Acl $taskDir
$rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "ctfplayer","Write,ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow")
$acl2.AddAccessRule($rule2)
Set-Acl $taskDir $acl2

Write-Host "[+] Done. Scheduled task: SystemCleanup | Task dir: $taskDir" -ForegroundColor Green
Write-Host "[+] Task runs every minute as SYSTEM." -ForegroundColor Green
Write-Host "[+] Log in as ctfplayer / Player123! to start." -ForegroundColor Green
