param(
    [Parameter(Mandatory = $true)][String]$Owner,
    [Parameter(Mandatory = $true)][String]$Branch,
    [Parameter(Mandatory = $true)][String]$DependenciesS
)

function Switch-Branch {
    param (
        [System.IO.FileSystemInfo]$Folder
    )
    Push-Location $Folder

    $name = $Folder.Name

    $remote = "origin"

    if ($Owner -ne "ModOrganizer2") {

        $remote = $Owner
        $url = (git remote -v | Select-String -Raw "ModOrganizer2")[1].Split()[1].Replace("ModOrganizer2", $Owner)

        if (git remote -v | Select-String "$Owner/") {
            git remote set-url $remote $url
        }
        else {
            git remote add $remote $url
        }

        # try to fetch
        git fetch --depth 1 $Owner 2>&1 | Out-Null
        if ($LASTEXITCODE) {
            Write-Output ("No remote $remote for $name found, falling back to ModOrganizer2.")
            $Owner = "ModOrganizer2"
            $remote = "origin"
        }
    }

    git checkout "$remote/$Branch" 2>&1 | Out-Null
    if ($LASTEXITCODE) {
        Write-Output "No branch $Owner/$Branch found for $name, staying on current branch."
    }
    else {
        Write-Output "Switch to branch $Owner/$Branch for $name."
    }

    Pop-Location
}

$simpleRepositoryNames = @("usvfs", "cmake_common")

New-Item -Path "build" -ItemType Directory -Force | Out-Null
Push-Location "build"

Write-Host "Initializing repositories... "
$DependenciesS.Split() | Select-Object -Unique | ForEach-Object {
    $fullname = $_
    if (!($simpleRepositoryNames -contains $fullname)) {
        $fullname = "modorganizer-$fullname"
    }
    git clone "https://github.com/ModOrganizer2/$fullname.git" $_
}

Write-Host "Switching branches... "
Get-ChildItem -Directory -Exclude ".git" | ForEach-Object {
    Write-Host "Switching branch for $($_.Name)..."
    Switch-Branch -Folder $_
}

Pop-Location
