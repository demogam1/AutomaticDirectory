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
    
    # Check if the user exists in Active Directory
    $user = Get-ADUser -Identity $UserName -ErrorAction SilentlyContinue
    if (-not $user) {
        Write-Error "User '$UserName' not found. Operation blocked."
        exit 1
    }
    
    # Check if the group exists in Active Directory
    $group = Get-ADGroup -Identity $GroupName -ErrorAction SilentlyContinue
    if (-not $group) {
        Write-Error "Group '$GroupName' not found. Operation blocked."
        exit 1
    }
    
    # Retrieve the group's members
    $groupMembers = Get-ADGroupMember -Identity $GroupName -ErrorAction Stop
    
    # Check if the user is a member of the group
    $isMember = $groupMembers | Where-Object { $_.DistinguishedName -eq $user.DistinguishedName }
    if (-not $isMember) {
        Write-Error "User '$UserName' is not a member of group '$GroupName'. Operation blocked."
        exit 1
    }
    
    # Remove the user from the group
    Remove-ADGroupMember -Identity $GroupName -Members $user -Confirm:$false -ErrorAction Stop
    Write-Output "User '$UserName' has been successfully removed from group '$GroupName'."
}
catch {
    Write-Error "An error occurred while removing the user from the group: $_"
}
