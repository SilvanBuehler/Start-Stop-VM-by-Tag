workflow StartStopVMbyTag
{
        Param(
        [Parameter(Mandatory=$true)]
        [String]
        $TagName,
        [Parameter(Mandatory=$true)]
        [String]
        $TagValue,
        [Parameter(Mandatory=$true)]
        [Boolean]
        $Shutdown
        )
     
    $connectionName = "AzureRunAsConnection";
 
    try
    {
        # Ensures you do not inherit an AzContext in your runbook
        Disable-AzContextAutosave -Scope Process

        # Connect to Azure with system-assigned managed identity
        $AzureContext = (Connect-AzAccount -Identity).context

        # Get available Subscriptions
        $SubscriptionList = Get-AzContext -ListAvailable

    }
    catch {
 
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

    Foreach ($Subscription in $SubscriptionList){
        #Set Subscription Context
        Select-AzContext -Name $Subscription.Name

        $vms = Get-AzResource -TagName $TagName -TagValue $TagValue | Where-Object {$_.ResourceType -like "Microsoft.Compute/virtualMachines"}
        
        Foreach -Parallel ($vm in $vms){
            
            if($Shutdown){
                Write-Output "Stopping $($vm.Name)"       
                Stop-AzVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force
            }
            else{
                Write-Output "Starting $($vm.Name)"       
                Start-AzVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
            }
        }
    }
}