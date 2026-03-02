#Requires AutoHotkey v2.0
#SingleInstance Force

MyMsgBox(Text, Title := "Message", ButtonText := "OK", BGColor := "White", FontColor := "Black") {
    GuiObj := Gui("+AlwaysOnTop -SysMenu +ToolWindow", Title)
    GuiObj.BackColor := BGColor
    GuiObj.SetFont("s12", "Segoe UI")
    
    ; Add Text
    GuiObj.Add("Text", "c" FontColor " Center w300", Text)
    
    ; Add Button
    Btn := GuiObj.Add("Button", "Center w80", ButtonText)
    Btn.OnEvent("Click", (*) => GuiObj.Destroy())
    
    ; Show the GUI in center
    GuiObj.Show("AutoSize Center")
}

if WinExist("ahk_exe mpc-hc64.exe")
{
	url1 := "http://localhost:13579/variables.html"
	url2 := "http://localhost:13579/command.html?wm_command=888"
	HttpObject := ComObject("WinHttp.WinHttpRequest.5.1")
	HttpObject.Open("GET", url1)
	HttpObject.Send()
	response := HttpObject.ResponseText
	if InStr(response, '<p id="state">2</p>')
	{
		HttpObject.Open("POST", url2)
   		HttpObject.Send()
   	}
}
SoundPlay("*-1")

; Custom Colored Message Box in AHK v2
MyMsgBox("Draw SELL Trade Alert", "SELL Alert", "OK", "Blue", "White")