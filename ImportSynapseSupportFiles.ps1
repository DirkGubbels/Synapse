

# Import necessary modules
Import-Module Az.Synapse

$tenantId = "<Enter Guid of TenantID here>"
$subscriptionId = "<Enter Guid of subscriptionId here>"

$resourceGroupName = "<Enter name of resource group containing Synapse here>"
$synapseWorkspaceName = "<Name of synapse workspace>"
$rootFolder = "<Full root folder name where the support files are stored" #This is typically the folder resulting from unzipping the support files zip file


Connect-AzAccount -TenantId $tenantId
Get-AzSubscription

Select-AzSubscription -SubscriptionId $subscriptionId

# import integration runtimes

foreach ($file in Get-ChildItem "$($rootFolder)\integrationRuntime") {

    if (($file.Extension.ToLower() -eq ".json") -and ($file.Name -ne "AutoResolveIntegrationRuntime.json")) {
        try{
            $fileContent = Get-Content -Raw $file.FullName
            $jsonObject = ConvertFrom-Json $fileContent 

            Set-AzSynapseIntegrationRuntime `
                -ResourceGroupName $resourceGroupName `
                -WorkspaceName $synapseWorkspaceName `
                -Name $jsonObject.name `
                -Type $jsonObject.properties.type `
                -Location $jsonObject.properties.typeProperties.computeProperties.location `
                -DataFlowComputeType $jsonObject.properties.typeProperties.computeProperties.dataFlowProperties.computeType `
                -DataFlowTimeToLive $jsonObject.properties.typeProperties.computeProperties.dataFlowProperties.timeToLive `
                -DataFlowCoreCount $jsonObject.properties.typeProperties.computeProperties.dataFlowProperties.coreCount 
                
                


        }
        catch {
            Write-Error "Error deploying $($file.Name)"
        }
    }
}


# import linked services
foreach ($file in Get-ChildItem "$($rootFolder)\\linkedService") {

    if ($file.Extension.ToLower() -eq ".json") {
        try{
            $fileContent = Get-Content -Raw $file.FullName
            $adfObject = ConvertFrom-Json $fileContent 

            Set-AzSynapseLinkedService `
                -WorkspaceName $synapseWorkspaceName `
                -Name $adfObject.name `
                -DefinitionFile $file.FullName

        }
        catch {
            Write-Error "Error deploying $($file.Name)"
        }
    }
}

# import datasets

foreach ($file in Get-ChildItem "$($rootFolder)\dataset") {

    if ($file.Extension.ToLower() -eq ".json") {
        try{
            $fileContent = Get-Content -Raw $file.FullName
            $adfObject = ConvertFrom-Json $fileContent 

            Set-AzSynapseDataset `
                -WorkspaceName $synapseWorkspaceName `
                -Name $adfObject.name `
                -DefinitionFile $file.FullName

        }
        catch {
            Write-Error "Error deploying $($file.Name)"
        }
    }
}


# import dataflows

foreach ($file in Get-ChildItem "$($rootFolder)\dataflow") {

    if ($file.Extension.ToLower() -eq ".json") {
        try{
            $fileContent = Get-Content -Raw $file.FullName
            $adfObject = ConvertFrom-Json $fileContent 

            Set-AzSynapseDataFlow `
                -WorkspaceName $synapseWorkspaceName `
                -Name $adfObject.name `
                -DefinitionFile $file.FullName

        }
        catch {
            Write-Error "Error deploying $($file.Name)"
        }
    }
}

# import pipelines
foreach ($file in Get-ChildItem "$($rootFolder)\pipeline") {

    if ($file.Extension.ToLower() -eq ".json") {
        try{
            $fileContent = Get-Content -Raw $file.FullName
            $adfObject = ConvertFrom-Json $fileContent 

            Set-AzSynapsePipeline `
                -WorkspaceName $synapseWorkspaceName `
                -Name $adfObject.name `
                -DefinitionFile $file.FullName

        }
        catch {
            Write-Error "Error deploying $($file.Name)"
        }
    }
}


