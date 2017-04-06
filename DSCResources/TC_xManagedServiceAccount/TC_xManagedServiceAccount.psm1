Import-Module -Name ActiveDirectory

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        [parameter(Mandatory = $true)]
        [System.String]
        $ServiceAccountName
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    $returnValue = @{
        ComputerName = [System.String] $ComputerName
        Ensure = [System.String]'Absent'
        ServiceAccountName = [System.String] $ServiceAccountName
    }

    # Get DN of computer
    $computerDN = (Get-ADComputer -Identity $ComputerName).distinguishedName
    # Getting all accounts installed on machine
    $installedAccounts = (Get-ADServiceAccount -filter {HostComputers -eq "$computerDN"}).Name

    if($installedAccounts -contains $ServiceAccountName)
    {
        $returnValue.Ensure = 'Present'
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $ServiceAccountName
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $ServiceAccountName
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    $result = [System.Boolean]((Get-TargetResource -ComputerName $ComputerName -ServiceAccountName).Ensure -eq $Ensure)
    
    $result

}


Export-ModuleMember -Function *-TargetResource

