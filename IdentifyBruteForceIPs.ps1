. ("$PSScriptRoot\Functions.ps1")

# 
Begin_App -procName "Brute-Force IP Identify"

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

# Lista
foreach($entry in $FAILED_ENTRIES) {    
    Write-Host "IP: $($entry.IP) / Falhas: $($entry.Qtd)"
}

#
End_App
