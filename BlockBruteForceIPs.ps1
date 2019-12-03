. ("$PSScriptRoot\Functions.ps1")

# 
Begin_App -procName "Brute-Force IP Block"

#
Open_DBConn 

# Realiza a Consulta
Write-Host "Executando a Consulta..."

$cmd = New-Object System.Data.SqlClient.SqlCommand("EXEC master.dbo.bruteforce_IPLoginFailed 1;", $APP_ENV.DB_CONN) 
$cmd.CommandTimeout = 600
$result = $cmd.ExecuteReader()

$ENTRIES = New-Object System.Collections.ArrayList

if($result.HasRows) {
    while($result.Read()) {
        $ENTRIES.Add(@{
            IP = $result.GetString(0)
            Qtd = $result.GetInt32(1)
        }) | Out-Null;
    }
}

# Filtra as Entradas 
$FAILED_ENTRIES = $ENTRIES | Where-Object -Property Qtd -GE $APP_ENV.CONFIGS.MaxFailedLogins

# Cria as Regras no Firewall
$BlockedIPS = 0;

foreach($entry in $FAILED_ENTRIES) {    
    $IP = $entry.IP;    
    Write-Host "Encontrado: $IP"

    if($IP -ne "<local machine>" -and (-not $APP_ENV.CONFIGS.Whitelist.Contais($IP))) {
        $rule = Get-NetFirewallRule -DisplayName "SQL_BLOCK $IP" -ErrorAction SilentlyContinue
        if($rule -eq $null) {
                New-NetFirewallRule -DisplayName "SQL_BLOCK $IP" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Block -RemoteAddress $IP 
                $BlockedIPS++;
        }
    }
}

Write-Host "IPs Bloqueados: $BlockedIPS"

#
End_App
