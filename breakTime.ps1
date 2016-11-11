#Script to prompt for a break
#Made by Nicholas Penning
#Last Updated: 10/24/2016

$breakDuration = 15 #Minutes
$productivtyDuration = 600 #Seconds

#MessageBox Function
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

$beginningOfDay = Get-Date -Hour 8 -Minute 0 -Second 0
$now = Get-Date -DisplayHint Time
$endOfDay = Get-Date -Hour 17 -Minute 0 -Second 0

function breakTimePopUp{
    do {
        #Popup Function to produce Message Box with Text and Status
        function breakTime{
        #Start Timer
        $elapsed = [System.Diagnostics.Stopwatch]::StartNew()
            DO{ 
                $timeLeft = (15 - $elapsed.Elapsed.Minutes)
                $message = "Time for a quick break! Only $timeLeft minutes remain!"
                Show-MessageBox -Msg $message -C
                #Continue to do this while time elapsed is less than or equal to 15 minutes
              } While ($elapsed.Elapsed.Minutes -le $breakDuration)
        }

    #Stop Timer
    $elapsed.Stop

    #Wait for break time (Seconds)
    Start-Sleep -s $productivtyDuration

    #Call for Breaktime!
    breakTime

    $now = Get-Date -DisplayHint Time
    #Go be productive until next break!
    
    } While ($now -le $endOfDay)

    Show-MessageBox -Msg "Time to go Home!" -I
    
    #Set Current Time to Now
    $now = Get-Date -DisplayHint Time
    }

if ($now -ge $beginningOfDay -and $now -le $endOfDay){
do {breakTimePopUp} While ($now -ge $beginningOfDay -and $now -le $endOfDay)
}

Show-MessageBox -Msg "Wooo! I broke!" -I