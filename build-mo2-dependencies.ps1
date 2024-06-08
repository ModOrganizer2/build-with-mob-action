param(
    [Parameter(Mandatory=$true)][String]$Owner,
    [Parameter(Mandatory=$true)][String]$Branch,
    [Parameter(Mandatory=$true)][String]$DependenciesS
)

$Dependencies = $DependenciesS.Split()

Write-Host "Initializing repositories with mob... "
mob -l 4 -d . build `
    --ignore-uncommitted-changes `
    --redownload --reextract --no-build-task `
    @Dependencies

Push-Location build/modorganizer_super
Get-ChildItem -Directory -Exclude ".git" | ForEach-Object {
    Push-Location $_

    $name = $_.Name

    $LocalOwner = $Owner

    if ($LocalOwner -ne "ModOrganizer2") {
        $url = (git remote -v | Select-String -Raw "ModOrganizer2")[1].Split()[1].Replace("ModOrganizer2", $LocalOwner)

        if (git remote -v | Select-String "$LocalOwner") {
            git remote set-url $LocalOwner $url
        }
        else {
            git remote add $LocalOwner $url
        }

        # try to fetch
        git fetch --depth 1 $Owner 2>&1 | Out-Null
        if ($LASTEXITCODE) {
            Write-Output ("No remote $LocalOwner for $name found, falling back to ModOrganizer2.")
            $LocalOwner = "ModOrganizer2"
        }
    }

    git checkout "$LocalOwner/$Branch" 2>&1 | Out-Null
    if ($LASTEXITCODE) {
        Write-Output "No branch $LocalOwner/$Branch found for $name, staying on current branch."
    }
    else {
        Write-Output "Switch to branch $LocalOwner/$Branch for $name."
    }

    Pop-Location
}
Pop-Location

Write-Output "Building dependencies with mob... "
mob -l 4 -d . build `
    --ignore-uncommitted-changes `
    --no-pull --reconfigure --rebuild `
    @Dependencies
