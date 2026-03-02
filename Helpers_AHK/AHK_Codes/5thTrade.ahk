; Custom Colored Message Box in AHK v2
MyMsgBox("5th Trade: Risk is stacking `nSLOW DOWN", "5th Trade", "OK", "0xFF8C00", "Blue")

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
