# Asegúrate de que el módulo ActiveDirectory esté instalado y disponible
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "El módulo ActiveDirectory no está instalado o no está disponible en esta sesión de PowerShell."
    return
}

# Obtiene todos los controladores de dominio en el dominio actual
$DomainControllers = Get-ADDomainController -Filter *

# Verifica si hay problemas de replicación en cada controlador de dominio
foreach ($DC in $DomainControllers) {
    Write-Host "Verificando la replicación en el controlador de dominio $($DC.HostName)..."

    # Comprueba los problemas de replicación utilizando Get-ADReplicationFailure
    $ReplicationFailures = Get-ADReplicationFailure -Target $DC.HostName -ErrorAction SilentlyContinue

    if ($ReplicationFailures) {
        Write-Host "Se encontraron problemas de replicación en $($DC.HostName) con Get-ADReplicationFailure:" -ForegroundColor Red

        foreach ($Failure in $ReplicationFailures) {
            Write-Host "`tPartner: $($Failure.Partner)"
            Write-Host "`tConsecutive Failures: $($Failure.ConsecutiveFailureCount)"
            Write-Host "`tLast Failure Time: $($Failure.LastFailureTime)"
            Write-Host "`tLast Error: $($Failure.LastErrorStatus)"
            Write-Host "`tFailure Type: $($Failure.FailureType)"
            Write-Host "`tFailure Message: $($Failure.FailureMessage)"
            Write-Host ""
        }
    } else {
        Write-Host "No se encontraron problemas de replicación en $($DC.HostName) con Get-ADReplicationFailure." -ForegroundColor Green
    }

    # Comprueba los problemas de replicación utilizando repadmin
    Write-Host "Comprobando problemas de replicación en $($DC.HostName) con repadmin..."
    $RepadminResult = repadmin /showrepl $DC.HostName

    if ($RepadminResult -match "ERROR") {
        Write-Host "Se encontraron problemas de replicación en $($DC.HostName) con repadmin:" -ForegroundColor Red
        Write-Host $RepadminResult
    } else {
        Write-Host "No se encontraron problemas de replicación en $($DC.HostName) con repadmin." -ForegroundColor Green
    }

    # Comprueba la salud de los controladores de dominio utilizando dcdiag
    Write-Host "Comprobando la salud del controlador de dominio $($DC.HostName) con dcdiag..."
    $DcdiagResult = dcdiag /s:$($DC.HostName) /q

    if ($DcdiagResult -match "FAILED") {
        Write-Host "Se encontraron problemas de salud en $($DC.HostName) con dcdiag:" -ForegroundColor Red
        Write-Host $DcdiagResult
    } else {
        Write-Host "No se encontraron problemas de salud en $($DC.HostName) con dcdiag." -ForegroundColor Green
    }
}
