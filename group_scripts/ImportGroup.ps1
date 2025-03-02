param(
    [Parameter(Mandatory = $true)]
    [string]$OriginGroupName,

    [Parameter(Mandatory = $true)]
    [string]$DestinationGroupName
)

try {
    # Ensure the ActiveDirectory module is loaded
    if (-not (Get-Module -Name ActiveDirectory)) {
        Import-Module ActiveDirectory -ErrorAction Stop
    }

    # Verify the origin group exists
    $originGroup = Get-ADGroup -Identity $OriginGroupName -ErrorAction SilentlyContinue
    if (-not $originGroup) {
        Write-Error "Origin group '$OriginGroupName' not found. Operation blocked."
        exit 1
    }

    # Verify the destination group exists
    $destGroup = Get-ADGroup -Identity $DestinationGroupName -ErrorAction SilentlyContinue
    if (-not $destGroup) {
        Write-Error "Destination group '$DestinationGroupName' not found. Operation blocked."
        exit 1
    }

    # Retrieve members of the origin group
    $originMembers = Get-ADGroupMember -Identity $OriginGroupName -ErrorAction Stop
    if (-not $originMembers) {
        Write-Output "No members found in origin group '$OriginGroupName'."
        exit 0
    }

    # Retrieve current members of the destination group for comparison
    $destMembers = Get-ADGroupMember -Identity $DestinationGroupName -ErrorAction Stop
    $destMemberDNs = $destMembers | ForEach-Object { $_.DistinguishedName }

    # Filter out members already present in the destination group
    $membersToAdd = $originMembers | Where-Object { $destMemberDNs -notcontains $_.DistinguishedName }
    
    if ($membersToAdd.Count -eq 0) {
        Write-Output "All members of group '$OriginGroupName' are already in group '$DestinationGroupName'."
        exit 0
    }

    # Add the filtered members to the destination group
    Add-ADGroupMember -Identity $DestinationGroupName -Members $membersToAdd -ErrorAction Stop

    Write-Output "Successfully imported $($membersToAdd.Count) member(s) from group '$OriginGroupName' into group '$DestinationGroupName'."
}
catch {
    Write-Error "An error occurred during the import operation: $_"
}
