. ("$PSScriptRoot\Functions.ps1")

# 
Begin_App -procName "Brute-Force IP Compare"

#
Open_DBConn 

# Realiza a Consulta
Write-Host "Querying..."

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

# 
$DataFile =  "$PSScriptRoot\Data\LAST_COLLECTED_IPS.json"
$Comparar = [IO.File]::Exists($DataFile);

if($Comparar) {
    $oldData = ConvertFrom-Json ([IO.File]::ReadAllText($DataFile))

    # Compara os Dados
    foreach($entry in $oldData) {
        # Procura pela Entrada na Pesquisa Atual
        $cEntry = $FAILED_ENTRIES | Where-Object -Property IP -EQ $entry.IP 
    
        # 
        if($cEntry -eq $null) {
            Write-Host "IP was no longer reported: $($entry.IP)"
        } else {
            $diffFalhas = $entry.Qtd - $cEntry.Qtd;

            if($diffFalhas -ge 1) {
                Write-Host "IP reported more failures: $($entry.IP) / $diffFalhas"
            }
            elseif($diffFalhas -le -1) {
                $diffFalhas = ($diffFalhas * (-1));
                Write-Host "IP reported less failures: $($entry.IP) / $diffFalhas"
            } 
            elseif($diffFalhas -eq 0) {
                Write-Host "IP reported the same number of failures: $($entry.IP)"
            }
        }
    }    
	
	# Mostra novos IPs
	foreach($entry in $FAILED_ENTRIES) {
		# Procura pela Entrada na Pesquisa Atual
        $cEntry = $oldData | Where-Object -Property IP -EQ $entry.IP 
    
        # 
        if($cEntry -eq $null) {
            Write-Host "New IP reported: $($entry.IP)"
        } 
	}
} 

$data = ConvertTo-Json $FAILED_ENTRIES
[IO.File]::WriteAllText($DataFile, $data)

if(-not $Comparar) {  
    Write-Host "First Data File Generated, Run Comparison Again in A HOUR!"
}

#
End_App
