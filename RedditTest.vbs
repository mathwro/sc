'Dim mybox

mybox = MsgBox ("Your wish, my command" & vbCrLf & vbCrLf & "Press yes, for seeing the interwebs", vbYesNo, "continue?")
If mybox = vbYes Then
   MsgBox ("Good for you bitch")

Else MsgBox("Okay then...")
WScript.Quit (1)
End If


Set IE = WScript.CreateObject("chrome.exe", "Chrome_")
Chrome.Visible = True
Chrome.Navigate "google.dk"
WScript.Sleep 1000
Chrome.Navigate "reddit.com"
WScript.Sleep 1000


max=28
min=3
Randomize
antaltab =(Int((max-min+1)*Rnd+min))

For i = 1 To antaltab
x.SendKeys"{tab}"
Next

x.SendKeys"{enter}"
