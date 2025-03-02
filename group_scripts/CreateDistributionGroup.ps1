param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string]$OU,

    [Parameter(Mandatory = $true)]
    [ValidateSet("Global", "DomainLocal", "Universal")]
    [string]$GroupScope,

    [Parameter(Mandatory = $true)]
    [string]$Description
)

try {
    # Ensure the ActiveDirectory module is loaded
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }

    # Create the new distribution group in Active Directory
    New-ADGroup -Name $GroupName -Path $OU -GroupScope $GroupScope -Description $Description -GroupCategory Distribution -ErrorAction Stop

    Write-Output "Distribution group '$GroupName' has been successfully created in OU '$OU' with scope '$GroupScope'."
}
catch {
    Write-Error "An error occurred while creating the distribution group: $_"
}
