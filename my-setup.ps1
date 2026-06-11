param(
    [string]$command,
    [string]$repo
)

function Get-StartMenuPath {
    return "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
}

function Show-Progress {
    param([string]$repo, [string]$path)
    Write-Host "Cloning $repo into $path..."
    git clone "https://github.com/MySetupHosting/$repo" "$path" --progress
}

function Create-Shortcut {
    param(
        [string]$repo,
        [string]$target,
        [string]$workingDir
    )

    $startMenu = Get-StartMenuPath
    $shortcutPath = Join-Path $startMenu "$repo.lnk"

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)

    $shortcut.TargetPath = $target
    $shortcut.WorkingDirectory = $workingDir
    $shortcut.IconLocation = $target
    $shortcut.Description = $repo
    $shortcut.Save()

    Write-Host "Shortcut created: $shortcutPath"
}

function Install-Repo {
    param([string]$repo)

    $startMenu = Get-StartMenuPath
    $repoPath = Join-Path $startMenu $repo

    if (!(Test-Path $repoPath)) {
        New-Item -ItemType Directory -Path $repoPath | Out-Null
    }

    Show-Progress -repo $repo -path $repoPath

    # Detect init.* file
    $initFile = Get-ChildItem -Path $repoPath -File | Where-Object {
        $_.BaseName -eq "init"
    } | Select-Object -First 1

    if (-not $initFile) {
        Write-Host "No init.* file found. Cannot create shortcut."
        return
    }

    # Create shortcut
    Create-Shortcut -repo $repo -target $initFile.FullName -workingDir $repoPath

    Write-Host "$repo installed successfully."
    Write-Host "Remember to make a shortcut to make the program avaible on the Start Menu."
}

function Uninstall-Repo {
    param([string]$repo)

    $startMenu = Get-StartMenuPath
    $repoPath = Join-Path $startMenu $repo
    $shortcutPath = Join-Path $startMenu "$repo.lnk"

    Write-Host "Uninstalling $repo..."

    # Remove shortcut
    if (Test-Path $shortcutPath) {
        Remove-Item $shortcutPath -Force
        Write-Host "✔ Shortcut removed"
    } else {
        Write-Host "ℹ No shortcut found"
    }

    # Remove repo folder
    if (Test-Path $repoPath) {
        Remove-Item $repoPath -Recurse -Force
        Write-Host "✔ Repository folder removed"
    } else {
        Write-Host "ℹ No repository folder found"
    }

    Write-Host "✔ $repo uninstalled successfully."
}

switch ($command) {
    "install" {
        if (-not $repo) {
            Write-Host "Usage: my-setup install <repository>"
            exit
        }
        Install-Repo $repo
    }

    "uninstall" {
        if (-not $repo) {
            Write-Host "Usage: my-setup uninstall <repository>"
            exit
        }
        Uninstall-Repo $repo
    }

    default {
        Write-Host "MySetup - Initial Release"
        Write-Host "Usage:"
        Write-Host "  my-setup install <repository>"
        Write-Host "  my-setup uninstall <repository>"
    }
}

