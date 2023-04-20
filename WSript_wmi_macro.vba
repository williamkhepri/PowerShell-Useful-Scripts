Option Explicit

Sub RunPowerShellWmiQuery()
    Dim objShell As Object
    Dim objExec As Object
    Dim strPSCode As String
    Dim strOutput As String
    Dim WmiClass As String
    Dim Results() As String
    Dim Result As Variant
    Dim i As Long
    Dim ws As Worksheet

    ' Solicitar al usuario la clase WMI que desea consultar
    WmiClass = InputBox("Ingrese la clase WMI que desea consultar (ejemplo: Win32_OperatingSystem)", "Clase WMI")

    ' Si el usuario no proporcionó una clase WMI, salga de la macro
    If WmiClass = "" Then Exit Sub

    ' Definir el código PowerShell que se ejecutará
    strPSCode = "Get-WmiObject -Class " & WmiClass & " | ConvertTo-Csv -NoTypeInformation"

    ' Crear una instancia de WScript.Shell para ejecutar el código de PowerShell
    Set objShell = CreateObject("WScript.Shell")
    Set objExec = objShell.Exec("powershell.exe -Command " & strPSCode)

    ' Leer la salida del comando PowerShell
    strOutput = objExec.StdOut.ReadAll

    ' Separar la salida en un array
    Results = Split(strOutput, vbCrLf)

    ' Crear una nueva hoja de cálculo para mostrar los resultados
    Set ws = ThisWorkbook.Worksheets.Add
    ws.Name = "WMI Results"

    ' Escribir los resultados en la hoja de cálculo
    i = 1
    For Each Result In Results
        If Result <> "" Then
            ws.Cells(i, 1).Value = Result
            i = i + 1
        End If
    Next

    ' Cambiar el ancho de las columnas para que se ajusten automáticamente
    ws.Columns("A:Z").AutoFit

    ' Limpiar objetos
    Set objExec = Nothing
    Set objShell = Nothing
End Sub
