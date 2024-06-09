param(
    [Parameter(Mandatory=$true)][String]$Owner,
    [Parameter(Mandatory=$true)][String]$Branch,
    [Parameter(Mandatory=$true)][String]$DependenciesS
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

$Dependencies = $DependenciesS.Split()

Write-Host "Initializing repositories with mob... "
mob -l 4 -d . build `
    --ignore-uncommitted-changes `
    --redownload --reextract --no-build-task `
    @Dependencies

# handle USVFS (not in modorganizer_super)
Switch-Branch -Folder (Get-Item "build\usvfs")

Get-ChildItem "build/modorganizer_super" -Directory -Exclude ".git" | ForEach-Object {
    Switch-Branch -Folder $_
}

Write-Output "Building dependencies with mob... "
mob -l 4 -d . build `
    --ignore-uncommitted-changes `
    --no-pull --reconfigure --rebuild `
    @Dependencies
