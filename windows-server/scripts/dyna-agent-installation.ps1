Param(
      [Parameter(Position=0,Mandatory=$True)]
      [string]
      $HOST_DYNATRACE,
      [Parameter(Position=1,Mandatory=$True)]
      [string]
      $API_TOKEN
)

function download_installation {
    write-host "DOWNLOAD DYNATRACE"
    powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '$HOST_DYNATRACE/api/v1/deployment/installer/agent/windows/default/latest?arch=x86&flavor=default' -Headers @{ 'Authorization' = 'Api-Token $API_TOKEN' } -OutFile 'Dynatrace-OneAgent-Windows-1.261.201.exe'"
}

function run_installer {
  write-host "INSTALLER"
  Invoke-Expression "& .\Dynatrace-OneAgent-Windows-1.261.201.exe --set-infra-only=false --set-app-log-content-access=true"
}

function main {
  # Step 1
  download_installation
  # Step 2
  run_installer
}
main