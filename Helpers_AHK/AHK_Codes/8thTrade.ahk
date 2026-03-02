; Custom Colored Message Box in AHK v2
MyMsgBox("8 trades in 1 DAY this is Insanity, `nStop before damage grows `nDO NOT TRADE FURTHER", "8th Trade", "OK", "0x8B0000", "White")

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
