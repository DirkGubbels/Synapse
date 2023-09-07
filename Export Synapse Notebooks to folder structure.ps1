Import-Module Az.Synapse
Import-Module Az.Accounts

# ====== variables ==============================================

$subcriptionId = "<enter subcription id GUID here>"
$synapseWorkspaceName = "<enter synapse workspace name here>" 
$outpath = "<enter output path here, no \ at the end>"


# ====== end of variables =======================================

Connect-AzAccount

Select-AzSubscription -Subscription $subcriptionId

$ws = Get-AzSynapseWorkspace -Name $synapseWorkspaceName

$dt = (Get-Date).tostring("yyyy-MM-dd")

$outpath = "$($outpath)\$($dt)"

$sqlPath = "$($outpath)\sql"
$notebookPath = "$($outpath)\Notebooks"
$configPath = "$($outpath)\config"
If(!(test-path -PathType container $outpath))
{
      New-Item -ItemType Directory -Path $outpath
      New-Item -ItemType Directory -Path $sqlPath
      New-Item -ItemType Directory -Path $notebookPath
      New-Item -ItemType Directory -Path $configPath
}

# ====== Export Notebooks ==============================================

$theNotebooks = Get-AzSynapseNotebook -WorkspaceObject $ws

foreach ($notebook in $theNotebooks) {
    $folder=$notebook.Properties.Folder.Name
    if ($folder -eq $null) {
        $fullpath = $notebookPath
    } else {
        $folder = $folder.Replace("/","\")
        $fullpath = "$($notebookPath)\$($folder)"
    }

    If(!(test-path -PathType container $fullpath ))
    {
            New-Item -ItemType Directory -Path $fullpath 

    }

    $notebook | Export-AzSynapseNotebook -OutputFolder $fullpath 

}

# ====== Export SQL Scripts ==============================================

$theSqlScripts = Get-AzSynapseSqlScript -WorkspaceObject $ws

foreach ($sqlScript in $theSqlScripts) {
    $folder=$sqlScript.Properties.Folder.Name
    if ($folder -eq $null) {
        $fullpath = $sqlPath
    } else {
        $folder = $folder.Replace("/","\")
        $fullpath = "$($sqlPath)\$($folder)"
    }
    
    If(!(test-path -PathType container $fullpath ))
    {
            New-Item -ItemType Directory -Path $fullpath 

    }

    $sqlScript | Export-AzSynapseSqlScript -OutputFolder $fullpath 

}
#Export-AzSynapseNotebook -WorkspaceObject $ws -OutputFolder $outpath 

#Export-AzSynapseSqlScript -WorkspaceObject $ws -OutputFolder $sqlPath

Export-AzSynapseSparkConfiguration -WorkspaceObject $ws -OutputFolder $configPath 

