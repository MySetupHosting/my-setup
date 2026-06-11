# Ruta donde se instalará MySetup
$installPath = "C:\Program Files\MySetup"
$exePath = "$installPath\my-setup.ps1"

# Crear carpeta si no existe
if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
}

# Copiar el script principal
Copy-Item ".\my-setup.ps1" $exePath -Force

# Añadir MySetup al PATH del sistema
$oldPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($oldPath -notlike "*C:\Program Files\MySetup*") {
    $newPath = $oldPath + ";C:\Program Files\MySetup"
    setx Path $newPath /M
}

Write-Host "MySetup instalado correctamente."
Write-Host "Cierra y vuelve a abrir PowerShell para usar el comando 'my-setup'."
