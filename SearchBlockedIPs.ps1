. ("$PSScriptRoot\Functions.ps1")

# 
Begin_App -procName "Brute-Force IP Search Rules"


$SearchIP = Read-Host "IP to Search"

# List
$RulesCreated = Get-NetFirewallRule -DisplayName "*$SearchIP*"

foreach($rule in $RulesCreated) {
    $ipFilter =  $rule | Get-NetFirewallAddressFilter

    if($rule.Enabled) {
        Write-Host "Blocked IP: $($ipFilter.RemoteIP)"
    }
    else {
        Write-Host "Rule disabled for IP: $($ipFilter.RemoteIP)"
    }
}

Write-Host "Count of Rules: $($RulesCreated.Count)"

#
End_App