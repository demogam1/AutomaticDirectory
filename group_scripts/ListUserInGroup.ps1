param (
    [Parameter(Mandatory = $true)]
    [string]$GroupName
)

try {
    # Ensure the ActiveDirectory module is loaded
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }

    # Retrieve all members of the specified group
    $members = Get-ADGroupMember -Identity $GroupName -ErrorAction Stop

    if (-not $members) {
        Write-Host "No members found in group '$GroupName'."
        exit 0
    }

    # Filter for only user objects
    $userMembers = $members | Where-Object { $_.objectClass -eq "user" }

    if (-not $userMembers) {
        Write-Host "No user members found in group '$GroupName'."
        exit 0
    }

    # Output each user's Name and SamAccountName
    $userMembers | ForEach-Object {
        $user = Get-ADUser -Identity $_.SamAccountName -Properties Name, SamAccountName
        [PSCustomObject]@{
            Name           = $user.Name
            SamAccountName = $user.SamAccountName
        }
    }
}
catch {
    Write-Error "An error occurred: $_"
}