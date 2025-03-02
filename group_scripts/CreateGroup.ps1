param (
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

    # Create the new AD group
    New-ADGroup -Name $GroupName -Path $OU -GroupScope $GroupScope -Description $Description -GroupCategory Security -ErrorAction Stop

    Write-Output "Group '$GroupName' has been successfully created in OU '$OU' with scope '$GroupScope'."
}
catch {
    Write-Error "An error occurred while creating the group: $_"
}