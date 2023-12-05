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

<#
    Main menu loads user options for mounting disk
    image, clearing temp, or exiting program.
#>
function Main
{
    $Key = 0
    $MountType = $null
	$ClonezillaUtilExe = "$PSScriptRoot\clonezilla-util.exe"
    $Version = "0.1.1"

    Clear-Host
    Write-Host "Clonezilla Util Mount by DeAndre Queary - v$Version" -ForegroundColor Yellow

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
    Write-Host "4 - Clear cache folder."

    $Keys = @(49, 50, 51, 52, 27, 97, 98, 99, 100)

    # Listen 
    while (-not ($Key -in $Keys)) {
        $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        # When 1 on number row or numpad is pressed, set mount type to folder.
        if ($Key -eq 49 -or $Key -eq 97) 
        {
            Write-Host "`nMount Type: As Folder." -ForegroundColor Green
            $MountType = 1
        }

        # When 2 on number row or numpad is pressed, set mount type to ISO.
        if ($Key -eq 50 -or $Key -eq 98) 
        {
            Write-Host "`nMount Type: As ISO files." -ForegroundColor Green
            $MountType = 2
        }

        # When 3 on number row or numpad is pressed, set mount type export ISO.
        if ($Key -eq 51 -or $Key -eq 99) 
        {
            Write-Host "`nMount Type: N/A (Export partitions to ISO files)" -ForegroundColor Green
            $MountType = 3
        }
        
        # When 2 on number row or numpad is pressed, init clearing cache folder.
        if ($Key -eq 52 -or $Key -eq 100) 
        {
            Start-ClearCache            
        }

        # If any mount type option is set, init mounting disk image.
        if ($MountType -ge 1 -and $MountType -le 3)
        {
            Start-ImgMount
        }

        # When ESC key is pressed, nicely exit program.
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

<#
    Asks the user how they want to mount disk image
    then starts the mount process using Clonezilla Util.
#>
function Start-ImgMount
{
    # Ask user where disk image is located.
    Write-Host "Where is the disk image?" -ForegroundColor Cyan
    do {
        $Image = Read-Host "[Enter location (without quotes)]"
        Test-Reset -ReadInput $Image
    } while ($Image -eq "")

    # If disk image location does not exist, tell the user
    # and ask again.
    if (-not (Test-Path $Image)) {
        Write-Host "No disk image found at location `"$Image`"" -ForegroundColor DarkRed
        Pause
        Start-ImgMount
    }

    # If mount option is set to export/save partitions,
    # ask for the save location. Else ask user which
    # letter drive to mount disk image to.
    if ($MountType -eq 3) {
        Write-Host "Where to store extracted partitions?" -ForegroundColor Cyan
        do {
            $MountPath = Read-Host "[Enter save location (without quotes)]"
            Test-Reset -ReadInput $MountPath
        } while ($MountPath -eq "")
    } else {
        Write-Host "What letter do you want to mount to?" -ForegroundColor Cyan
        do {
            $Drive = Read-Host "[Enter letter drive]"
            Test-Reset -ReadInput $Drive
        } while ($Drive -eq "")
    }

    $Image = $Image.Trim()

    # Run clonezilla util based on the mount type.
    if ($MountType -eq 1) {
        Write-Host "`nMounting disk image to letter drive"$Drive -ForegroundColor Cyan
        Start-Sleep 2

        & "$ClonezillaUtilExe" mount --input "$Image" --mount $Drive":\"
    } elseif ($MountType -eq 2) {
        Write-Host "`nMounting disk image as ISO files to letter drive"$Drive -ForegroundColor Cyan
        Start-Sleep 2

        & "$ClonezillaUtilExe" mount-as-image-files --input "$Image" --mount $Drive":\"
    } elseif ($MountType -eq 3) {
        Write-Host "`nExporting disk image partitions as ISO files."$MountPath -ForegroundColor Cyan
        Start-Sleep 2

        & "$ClonezillaUtilExe" extract-partition-image --input "$Image" --output "$MountPath"
    }

    Pause
}

<#
    Asks the user if they'd like to clear temp
    folder located at the root location of this script.
#>
function Start-ClearCache
{
    # If cache folder is not located at the root of script,
    # tell the user and reload main menu. Otherwise ask the user
    # to confirm clearing temp, and clear temp.
    if (-not (Test-Path "$PSScriptRoot\cache")) {
        Write-Host "`nNo cache folder found at `"$PSScriptRoot`""
        Pause
        Main
    } else {
        Write-Host "`nWould you like to clear cache folder?" -ForegroundColor Green
        Write-Host "This will remove everything inside of" -ForegroundColor DarkRed
		Write-Host "`"$PSScriptRoot\cache`"" -ForegroundColor Yellow
        do {
            $Confirm = Read-Host "[no (n) / yes (yes)]"
            Test-Reset -ReadInput $Confirm
        } while (-not ($Confirm -in @("", "yes", "n", "no")))

        if ($Confirm -eq "yes") {
            $Cleared = Clear-Cache
			
			if ($Cleared) {
				Write-Host "Cache cleared." -ForegroundColor Green
			} else {
				Write-Host "Could not clear cache folder." -ForegroundColor DarkRed
			}
			
            Pause
            Main
        }
    }
}

<#
    Clears cache folder at the root of wherever this script
    is located.
#>
function Clear-Cache
{
    # Try clearing everything inside of temp, but do not
    #remove temp folder itself.
    try {
        Remove-Item "$PSScriptRoot\cache\*" -Recurse -Force -ErrorAction Stop
		Return $True
    } catch {
        Return $False
    }
}

<#
    Reloads main menu if user cancels out of
    read prompts.
#>
function Test-Reset
{
    param (
        $ReadInput
    )

    # Reloads main menu if ReadInput is set to
    #backslash [\].
    if ($ReadInput -eq "\") {
        Main
        Return
    }
}

Main