# suponemos que se lanza el comando y la salida la deja en un fichero
#opt/omni/bin/omnistat -detail 

# leer fichero de configuracion
$file_content = Get-Content "C:\codigo\powershell\david\app.properties" -raw
$file_content = [Regex]::Escape($file_content)
$file_content = $file_content -replace "(\\r)?\\n", [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)

# Se quitan los espacios que se hayan metido erroneamente en el fichero de configuracion 
$configuration.Session_type_tofind = $configuration.Session_type_tofind.Trim()
$configuration.Session_status_tofind = $configuration.Session_status_tofind.Trim()
$configuration.Backup_Specification_tofind = $configuration.Backup_Specification_tofind.Trim()
$configuration.Session_started_tofind = $configuration.Session_started_tofind.Trim()

#Se muestra la busqueda que se quiere hacer 
Write-Host "valor de configuration.Session_type_tofind en app.properties " $configuration.Session_type_tofind
Write-Host "valor de configuration.Session_status_tofind en app.properties " $configuration.Session_status_tofind
Write-Host "valor de configuration.Backup_Specification_tofind en app.properties " $configuration.Backup_Specification_tofind
Write-Host "valor de configuration.Session_started_tofind en app.properties " $configuration.Session_started_tofind

# fin leer fichero de configuracion

$Session_type_found = $false
$Session_status_found = $false
$Backup_Specification_found = $false
$Session_started_found = $false


$NumeroElementosABuscar =0
$NumeroElementosEncontrados=0 
$numeroSesionID=0
$ID_found = ""
$matrizSesionID = @()

$Session_type_toSeek = $False
$Session_status_toSeek = $False
$Backup_Specification_toSeek = $False
$Session_started_toSeek = $False



if ("" -ne $configuration.Session_type_tofind.Trim() -and "null" -ne $configuration.Session_type_tofind.Trim()){
    $NumeroElementosABuscar += 1
    $Session_type_toSeek = $True
}
if ("" -ne $configuration.Session_status_tofind.Trim() -and "null" -ne $configuration.Session_status_tofind.Trim()){  
    $NumeroElementosABuscar += 1
    $Session_status_toSeek = $True
}


if ("" -ne $configuration.Backup_Specification_tofind.Trim() -and "null" -ne $configuration.Backup_Specification_tofind.Trim() ){  
    $NumeroElementosABuscar += 1
    $Backup_Specification_toSeek = $True

}
if ("" -ne $configuration.Session_started_tofind.Trim() -and "null" -ne $configuration.Session_started_tofind.Trim() ){
      
    $NumeroElementosABuscar += 1
    $Session_started_toSeek = $True
}




Write-Host "Valor de matrizSesionID " $matrizSesionID
Write-Host "numero de elementos a buscar: " $NumeroElementosABuscar



foreach($line in [System.IO.File]::ReadLines("C:\codigo\powershell\david\fichero_salida_omnistat_detail.txt"))
{
       Write-Host "linea: " $line      
       if ($line -match 'SessionID : (.*)' -eq $True ){  
            $numeroSesionID += 1  
            Write-Host sessionID encontradas $numeroSesionID   
            
            if ($numeroSesionID -ge 2){
                #evalua coincidencias para saber si hay que meter el SessionID en la matriz que despues ejecutara el siguiente comando
                Write-Host NumeroElementosABuscar $NumeroElementosABuscar NumeroElementosEncontrados $NumeroElementosEncontrados
                if ($NumeroElementosABuscar -eq $NumeroElementosEncontrados -and $NumeroElementosABuscar -ne 0){
                     $matrizSesionID +=$ID_found

                }               
                $NumeroElementosEncontrados = 0
            } 
            $ID_found=$Matches[1] 
       }

       if  ($Session_type_toSeek -eq $True){
           if ($line -match 'Session type.*: (.*)' -eq $True){
              if ($Matches[1] -eq $configuration.Session_type_tofind){
                Write-Host "session type found" 
                $Session_type_found = $True
                $NumeroElementosEncontrados +=1
              }
           }
        }

       if  ($Session_status_toSeek -eq $True){
           if ($line -match 'Session status.*: (.*)' -eq $True){
               if ($Matches[1] -eq $configuration.Session_status_tofind){
                Write-Host "session status found" 
                $Session_status_found = $True
                $NumeroElementosEncontrados +=1
              }
           }
       }

       if  ($Session_started_toSeek -eq $True){
           if ($line -match 'Session started.*: (.*)' -eq $True){
              if ($Matches[1] -match  $configuration.Session_started_tofind){
                Write-Host "Session started found" 
                $Session_started_found = $True
                $NumeroElementosEncontrados +=1
              }  
           }
       }    
       
       if  ($Backup_Specification_toSeek -eq $True){
           if ($line -match 'Backup Specification: (.*)' -eq $True){
              if ($Matches[1] -match $configuration.Backup_Specification_tofind ){
                Write-Host "Bakup_Specification found" 
                $Backup_Specification_found = $True
                $NumeroElementosEncontrados +=1
              }  
           }
       }
}
 #evalua coincidencias para saber si hay que meter el SessionID en la matriz que despues ejecutara el siguiente comando
if ($numeroSesionID -ge 1){
  #evalua coincidencias para saber si hay que meter el SessionID en la matriz que despues ejecutara el siguiente comando
  if ($NumeroElementosABuscar -eq $NumeroElementosEncontrados -and $NumeroElementosABuscar -ne 0){
        $matrizSesionID +=$ID_found

  }               

}      

Write-Host "Matriz" $matrizSesionID longitud $matrizSesionID.Count
foreach ( $sesionId in $matrizSesionID )
{
    "Item: [/opt/omni/bin/omniabort -session $sesionId]"
}

#/opt/omni/bin/omniabort -session SessionID