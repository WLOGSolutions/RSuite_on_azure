Write-Host 'Downloading install files.'
$base_url = "https://wlog-rsuite.s3.amazonaws.com/cli/"
$download_catalog = $env:TEMP + "\"

$client = new-object System.Net.WebClient

$pkg_index_path = $download_catalog + "PKG_INDEX" 
$client.DownloadFile($base_url + "PKG_INDEX", $pkg_index_path)
$rsuite_file_name = Select-String $pkg_index_path -pattern "win-x64: " | Select -ExpandProperty line | ForEach-Object {$_.Split("/")[1]}

$rsuite_install_file_path = $download_catalog + $rsuite_file_name
$client.DownloadFile($base_url + "windows/" + $rsuite_file_name, $rsuite_install_file_path)

Write-Host "Download complete... Preceding to installation."
$proc = Start-Process $rsuite_install_file_path -Wait -PassThru -ArgumentList '/quiet'
if ($proc.ExitCode -ne 0) {
	Write-Host "Could not install RSuite. Process exited with status code $($proc.ExitCode)"
} else{
	Write-Host "RSuite installed successfully."
	$env:Path = $env:Path + ";C:\Program Files\R\RSuiteCLI\"
	$previous_env = $env:Path
	$r_home =  $env:R_HOME -replace '/', '\' 
	$env:Path = $env:Path + ";" + $r_home + "\bin\"

	Write-Host "Installing R package for RSuite."
	cmd.exe /c "rsuite install -v"

	Write-Host "Check if everything is installed properly. Version: "
	cmd.exe /c "rsuite version"
	
	Write-Host "Install finished."
	$env:Path = $previous_env
}

Write-Host "Cleaning up..."
rm (Get-Item -LiteralPath $rsuite_install_file_path).FullName
rm $pkg_index_path
Write-Host "Script execution complete."
