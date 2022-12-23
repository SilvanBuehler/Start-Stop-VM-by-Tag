# Start-Stop-VM-by-Tag

Azure Automation PS workflow to automatically start and stop VMs by ressource tags.
The script utilizes system managed identities (need proper permission on target VMs) and runs trough all subscriptions the managed identity has access to.

Be sure to name the runbook the same as the workflow name (StartStopVMbyTag).
