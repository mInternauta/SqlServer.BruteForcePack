function Begin_App([String] $procName)
{
    $global:APP_ENV = @{
        CONFIGS = Import-LocalizedData -FileName "Configs.psd1" -BaseDirectory "$PSScriptRoot"    
        DB_CONN = $null
    };

    if(-not [IO.Directory]::Exists("$PSScriptRoot\Logs\")) {
        [IO.Directory]::CreateDirectory("$PSScriptRoot\Logs\");
    }

    if(-not [IO.Directory]::Exists("$PSScriptRoot\Data\")) {
        [IO.Directory]::CreateDirectory("$PSScriptRoot\Data\");
    }

    Start-Transcript -Path "$PSScriptRoot\Logs\$procName.log"  
    Write-Host "Inicio do Procedimento"
    Write-Host "Procedimento: $procName" 
}

function Open_DBConn() {
    Write-Host "Iniciando Conexão com o BD..."

    $conn = New-Object System.Data.SqlClient.SqlConnection($APP_ENV.CONFIGS.ConnString);
    $conn.Open();

    $APP_ENV.DB_CONN = $conn;    
}

function Close_DBConn() {
    if($APP_ENV.DB_CONN -ne $null) {
        $APP_ENV.DB_CONN.Close();
    }
}

function End_App() {        Write-Host "Fim do Procedimento"
    Close_DBConn 
    Stop-Transcript
}