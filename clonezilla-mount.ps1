<#PSScriptInfo

.SYNOPSIS
    Interactive script for Clonezilla Util.

.DESCRIPTION
    This script makes it easier to mount Clonezilla images with
    Clonezilla Util.

.CREDITS
    Developer - DeAndre Wilson @DreQueary.
    GitHub - https://github.com/drequeary
    Repository - https://github.com/drequeary/clonezilla-util-mount
    
    Links:    
        Clonezilla-Util - https://github.com/fiddyschmitt/clonezilla-util
        Dokany Driver - https://github.com/dokan-dev/dokany

    Special Thanks To:
        fiddyschmitt - https://github.com/fiddyschmitt
        Donkay Team - https://github.com/dokan-dev
#>

# Note: Set exe to path of clonezilla-util.exe if it's folder
# isn't added to system PATH.
$ClonezillaUtilExe = "clonezilla-util.exe"

function Main
{
    $Key = 0
	
    Clear-Host
    Write-Host "Clonezilla Util Mount - v0.1.0 (2023)" -ForegroundColor Yellow

    Write-Host "How do you want to mount Clonezilla image?" -ForegroundColor Cyan
    Write-Host "1 - As Folder (Requires Dokan Driver)"
    Write-Host "2 - Mount As Img Files (Requires Dokan Driver)"
    Write-Host "3 - Extract Paritions To Img File"

    while ($Key -ne 49 -and $Key -ne 50 -and $Key -ne 51 -and $Key -ne 27 -and $Key -ne 97 -and $Key -ne 98 -and $Key -ne 99) {
        $Key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        # 1 KEY
        if ($Key -eq 49 -or $Key -eq 97) 
        {
            Write-Host "Mount Type: As Folder" -ForegroundColor Green
            $MountType = 1
        }

        # 2 KEY
        if ($Key -eq 50 -or $Key -eq 98) 
        {
            Write-Host "Mount Type: As Img Files" -ForegroundColor Green
            $MountType = 2
        }

        # 3 KEY
        if ($Key -eq 51 -or $Key -eq 99) 
        {
            Write-Host "Mount Type: N/A (Extracting To Img File)" -ForegroundColor Green
            $MountType = 3
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

        do {
            $Image = Read-Host "[Enter Clonezilla Img]"
        } while ($Image -eq "")
    
        if ($MountType -eq 3) {
    
            do {
                $MountPath = Read-Host "[Enter Folder To Mount To]"
            } while ($MountPath -eq "")
    
        } else {
    
            do {
                $Drive = Read-Host "[Enter Letter Drive To Mount To]"
            } while ($Drive -eq "")
    
        }
    
        $Image = $Image.Trim()
        
        Write-Host
        if ($MountType -eq 1) {
            Write-Host "Mounting image files to letter drive"$Drive -ForegroundColor Cyan
            Start-Sleep 2
    
            & $ClonezillaUtilExe mount --input "$Image" --mount $Drive":\"
        } elseif ($MountType -eq 2) {
            Write-Host "Mounting disk images to letter drive"$Drive -ForegroundColor Cyan
            Start-Sleep 2
    
            & $ClonezillaUtilExe mount-as-image-files --input "$Image" --mount $Drive":\"
        } elseif ($MountType -eq 3) {
            Write-Host "Extracting partition image to folder"$MountPath -ForegroundColor Cyan
            Start-Sleep 2
    
            & $ClonezillaUtilExe extract-partition-image --input "$Image" --output "$MountPath"
        }
    
        Pause
        Main
    }
}

Main