#Location where the final report to be stored 
$PathOutput = "C:\AD\Password_Audit\OUTPUT"
#This is the location where your password dictionary file exists. You can start by creating a simple file with one line like Password1234
$Passwords  = "C:\AD\Password_Audit\PasswordDict.txt"
#Get the current time and date 
$ExportDateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Final Reports 
$OutPutReport_ALL                   = "$($PathOutput)\AD-PasswordQualityReport_ALL_$($ExportDateTime).txt"
$OutPutReport_Enabled_Non_Admin_Only_ALL      = "$($PathOutput)\AD-PasswordQualityReport_Enabled_Non_Admin_Only_ALL_$($ExportDateTime).txt"
#$OutPutReport_Disabled_Only_ALL     = "$($PathOutput)\AD-PasswordQualityReport_Disabled_Only_ALL_$($ExportDateTime).txt"
$OutPutReport_Enabled_Admins_Only_ALL       = "$($PathOutput)\AD-PasswordQualityReport_Enabled_Admins_Only_ALL_$($ExportDateTime).txt"

# Actual Query 
$Result_ALL                         = Get-ADReplAccount -All:$true -Server (Get-ADDomainController).Hostname -NamingContext (Get-ADRootDSE | select *naming*).defaultNamingContext

$Result_Enabled_Non_Admin_Only_ALL            = $Result_ALL | Where-Object { ($_.Enabled -eq $true) -and ($_.SamAccountType -eq "User") -and ($_.AdminCount -eq $false)}
#$Result_Disabled_Only_ALL           = $Result_ALL | Where-Object { ($_.Enabled -eq $false) -and ($_.SamAccountType -eq "User")}
$Result_Enabled_Admins_Only_ALL             = $Result_ALL | Where-Object { ($_.AdminCount -eq $true)  -and ($_.SamAccountType -eq "User") -and ($_.Enabled -eq $true)}

$PasswordResult_All                 = $Result_ALL | Test-PasswordQuality -WeakPasswordsFile $Passwords
$PasswordResult_Enabled_Non_Admin_Only_ALL    = $Result_Enabled_Non_Admin_Only_ALL | Test-PasswordQuality -WeakPasswordsFile $Passwords
#$PasswordResult_Disabled_Only_ALL   = $Result_Disabled_Only_ALL | Test-PasswordQuality -WeakPasswordsFile $Passwords
$PasswordResult_Enabled_Admins_Only_ALL     = $Result_Enabled_Admins_Only_ALL | Test-PasswordQuality -WeakPasswordsFile $Passwords

Write-Output "Building reports ...."
$PasswordResult_All | Out-File -FilePath $OutPutReport_ALL -Encoding UTF8
$PasswordResult_Enabled_Non_Admin_Only_ALL | Out-File -FilePath $OutPutReport_Enabled_Non_Admin_Only_ALL -Encoding UTF8
#$PasswordResult_Disabled_Only_ALL | Out-File -FilePath $OutPutReport_Disabled_Only_ALL -Encoding UTF8
$PasswordResult_Enabled_Admins_Only_ALL | Out-File -FilePath $OutPutReport_Enabled_Admins_Only_ALL -Encoding UTF8
