#Script for testing PowerShell execution from the Internet
#Made by Nicholas Penning
#Last Updated: 9/28/2017

Function Show-MessageBox{

	Param(
	[Parameter(Mandatory=$True)][Alias('M')][String]$Msg,
	[Parameter(Mandatory=$False)][Alias('T')][String]$Title = "",
	[Parameter(Mandatory=$False)][Alias('OC')][Switch]$OkCancel,
	[Parameter(Mandatory=$False)][Alias('OCI')][Switch]$AbortRetryIgnore,
	[Parameter(Mandatory=$False)][Alias('YNC')][Switch]$YesNoCancel,
	[Parameter(Mandatory=$False)][Alias('YN')][Switch]$YesNo,
	[Parameter(Mandatory=$False)][Alias('RC')][Switch]$RetryCancel,
	[Parameter(Mandatory=$False)][Alias('C')][Switch]$Critical,
	[Parameter(Mandatory=$False)][Alias('Q')][Switch]$Question,
	[Parameter(Mandatory=$False)][Alias('W')][Switch]$Warning,
	[Parameter(Mandatory=$False)][Alias('I')][Switch]$Informational,
    [Parameter(Mandatory=$False)][Alias('TM')][Switch]$TopMost)

	#Set Message Box Style
	IF($OkCancel){$Type = 1}
	Elseif($AbortRetryIgnore){$Type = 2}
	Elseif($YesNoCancel){$Type = 3}
	Elseif($YesNo){$Type = 4}
	Elseif($RetryCancel){$Type = 5}
	Else{$Type = 0}
	
	#Set Message box Icon
	If($Critical){$Icon = 16}
	ElseIf($Question){$Icon = 32}
	Elseif($Warning){$Icon = 48}
	Elseif($Informational){$Icon = 64}
	Else { $Icon = 0 }
	
	#Loads the WinForm Assembly, Out-Null hides the message while loading.
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	
	If ($TopMost)
	{
		#Creates a Form to use as a parent
		$FrmMain = New-Object 'System.Windows.Forms.Form'
		$FrmMain.TopMost = $true
		
		#Display the message with input
		$Answer = [System.Windows.Forms.MessageBox]::Show($FrmMain, $MSG, $TITLE, $Type, $Icon)
		
		#Dispose of parent form
		$FrmMain.Close()
		$FrmMain.Dispose()
	}
	Else
	{
		#Display the message with input
		$Answer = [System.Windows.Forms.MessageBox]::Show($MSG , $TITLE, $Type, $Icon)			
	}
	
	#Return Answer
	Return $Answer
}

$message = "Woo! Yous Infected! Bad SEP!"
Show-MessageBox -Msg $message -C
