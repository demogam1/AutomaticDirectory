param (
    [Parameter(Mandatory = $true)]
    [string]$UserName,

    [Parameter(Mandatory = $true)]
    [string]$GroupName
)

try {
    # Ensure the ActiveDirectory module is loaded
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }
    
    # Check if the user exists
    $user = Get-ADUser -Identity $UserName -ErrorAction SilentlyContinue
    if (-not $user) {
        Write-Error "User '$UserName' not found. Operation blocked."
        exit 1
    }
    
    # Check if the group exists
    $group = Get-ADGroup -Identity $GroupName -ErrorAction SilentlyContinue
    if (-not $group) {
        Write-Error "Group '$GroupName' not found. Operation blocked."
        exit 1
    }
    
    # Add the user to the group
    Add-ADGroupMember -Identity $GroupName -Members $user -ErrorAction Stop
    Write-Output "User '$UserName' has been successfully added to group '$GroupName'."
}
catch {
    Write-Error "An error occurred while adding the user to the group: $_"
}