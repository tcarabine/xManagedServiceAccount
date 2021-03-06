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


    if($Ensure -eq 'Present')
    {
        Write-Debug "We are setting up the AD Service account"

        Write-Verbose "Adding computer to service account"

        Add-ADComputerServiceAccount -ComputerName $ComputerName -ServiceAccount $ServiceAccountName

        if($ComputerName -eq $env:ComputerName)
        {
            Write-Debug "We are on the machine in question, lets install"

            Write-Verbose "Installing managed service account $ServiceAccountName onto computer $ComputerName"
            Install-ADServiceAccount -Identity $ServiceAccountName
        }
        else
        {
            # No idea if this will work, needs some rigourous testing

            Write-Debug "Need to connect to the remote machine"

            Write-Verbose "Installing managed service account $ServiceAccountName onto computer $ComputerName"
            Invoke-Command -ScriptBlock {Install-ADServiceAccount -Identity $ServiceAccountName} -ComputerName $ComputerName
        }
    }
    else if ($Ensure -eq 'Absent')
    {
        Write-Debug "We are removing the AD Service account"

        Write-Verbose "Removing computer from service account"
        Remove-ADComputerServiceAccount -Computer $ComputerName -ServiceAccount $ServiceAccountName
        
        if($ComputerName -eq $env:ComputerName)
        {
            Write-Debug "We are on the machine in question, lets uninstall"

            Write-Verbose "Uninstalling managed service account $ServiceAccountName from computer $ComputerName"
            Uninstall-ADServiceAccount -Identity $ServiceAccountName
        }
        else
        {
            # No idea if this will work, needs some rigourous testing

            Write-Debug "Need to connect to the remote machine"

            Write-Verbose "Uninstalling managed service account $ServiceAccountName from computer $ComputerName"
            Invoke-Command -ScriptBlock {Uninstall-ADServiceAccount -Identity $ServiceAccountName} -ComputerName $ComputerName
        }

    }

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

