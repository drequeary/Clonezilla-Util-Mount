<#PSScriptInfo

.SYNOPSIS
    Interactive script for Clonezilla Util.

.DESCRIPTION
    This script makes it easier to mount Clonezilla images with
    Clonezilla Util.

.CREDITS
    Developer - DeAndre Queary @drequeary.
    GitHub - https://github.com/drequeary
    Repository - https://github.com/drequeary/clonezilla-util-mount
    
    Links:
        Clonezilla-Util - https://github.com/fiddyschmitt/clonezilla-util
        Dokany Driver - https://github.com/dokan-dev/dokany

    Special Thanks To:
        fiddyschmitt - https://github.com/fiddyschmitt
        Donkay Team - https://github.com/dokan-dev
#>

function Main
{
    $Key = 0
    $MountType = $null
	$ClonezillaUtilExe = "$PSScriptRoot\clonezilla-util.exe"

    Clear-Host
    Write-Host "Clonezilla Util Mount by DeAndre Queary - v0.1.0" -ForegroundColor Yellow

    if ($null -eq (Get-Command "$ClonezillaUtilExe" -ErrorAction SilentlyContinue)) {
        Write-Host "clonezilla-util.exe wasn't found. Cannot start Clonezilla Mount." -ForegroundColor Red
        Write-Host "Please place this script in the same folder as clonezilla-util.exe" -ForegroundColor DarkRed
        Pause
        EXIT
    } else {
        Write-Host "reset - enter [\] for input / exit - press [ESC] on main menu"
    }
    Write-Host "--------------------------------------------------------------" -ForegroundColor Green
    Write-Host "How do you want to mount Clonezilla disk image?" -ForegroundColor Cyan
    Write-Host "1 - Mount disk image as a folder. (Requires Dokan Driver)"
    Write-Host "2 - Mount disk image as ISO files. (Requires Dokan Driver)"
    Write-Host "3 - Export disk image partitions as ISO files."

    while ($Key -ne 49 -and $Key -ne 50 -and $Key -ne 51 -and $Key -ne 27 -and $Key -ne 97 -and $Key -ne 98 -and $Key -ne 99) {
        $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        # 1 KEY
        if ($Key -eq 49 -or $Key -eq 97) 
        {
            Write-Host "Mount Type: As Folder." -ForegroundColor Green
            $MountType = 1
        }

        # 2 KEY
        if ($Key -eq 50 -or $Key -eq 98) 
        {
            Write-Host "Mount Type: As ISO files." -ForegroundColor Green
            $MountType = 2
        }

        # 3 KEY
        if ($Key -eq 51 -or $Key -eq 99) 
        {
            Write-Host "Mount Type: N/A (Export partitions to ISO files)" -ForegroundColor Green
            $MountType = 3
        }

        if ($MountType -ge 1 -and $MountType -le 3) {
            Start-ImgMount
        }

        # ESC KEY
        if ($Key -eq 27) 
        {
            Write-Host
            Write-Host "Goodbye.🙋🏾‍♂️" -ForegroundColor Green
            Start-Sleep 0.5
            Clear-Host
            EXIT
        }

        Main
    }
}

function Start-ImgMount
{
    Write-Host
    Write-Host "Where is the disk image?" -ForegroundColor Cyan
    do {
        $Image = Read-Host "[Enter location (without qoutes)]"
        Test-Reset -ReadInput $Image
    } while ($Image -eq "")

    if ($MountType -eq 3) {
        Write-Host
        Write-Host "Where to store extracted paritions?" -ForegroundColor Cyan
        do {
            $MountPath = Read-Host "[Enter save location (without qoutes)]"
            Test-Reset -ReadInput $MountPath
        } while ($MountPath -eq "")

    } else {
        Write-Host
        Write-Host "What letter do you want to mount to?" -ForegroundColor Cyan

        do {
            $Drive = Read-Host "[Enter letter drive]"
            Test-Reset -ReadInput $Drive
        } while ($Drive -eq "")

    }

    $Image = $Image.Trim()

    Write-Host
    if ($MountType -eq 1) {
        Write-Host "Mounting disk image to letter drive"$Drive -ForegroundColor Cyan
        Start-Sleep 2

        & "$ClonezillaUtilExe" mount --input "$Image" --mount $Drive":\"
    } elseif ($MountType -eq 2) {
        Write-Host "Mounting disk image as ISO files to letter drive"$Drive -ForegroundColor Cyan
        Start-Sleep 2

        & "$ClonezillaUtilExe" mount-as-image-files --input "$Image" --mount $Drive":\"
    } elseif ($MountType -eq 3) {
        Write-Host "Exporting disk image partitions as ISO files."$MountPath -ForegroundColor Cyan
        Start-Sleep 2

        & "$ClonezillaUtilExe" extract-partition-image --input "$Image" --output "$MountPath"
    }

    Pause
}

function Test-Reset
{
    param (
        $ReadInput
    )

    if ($ReadInput -eq "\") {
        Main
        Return
    }
}

Main