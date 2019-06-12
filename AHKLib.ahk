;author:Howoo
;update:181208
;log:颜色模糊匹配
;

#NoEnv
SetTitleMatchMode 2
DetectHiddenText, Off


beep(Frequency:= 750, Duration:= 1500){
	soundbeep,%Frequency%, %Duration%
}

;录制脚本
;***********************************************************************
^k::
;按下CTRL+K
;记录鼠标左键点击坐标，按其他键停止记录

mousepath:={}

loop{	
	Keywait, LButton, D
	if (A_PriorKey != "k")
		flag=1
	if (A_PriorKey != "Lbutton" && flag)
		break
	MouseGetPos, x1, x2
	tooltip(A_index "次 " x1 " " x2 " " A_Priorkey)
	mousepath.push(x1,x2)
	sleep, 300	
}
flag=0
return

^g::
;按下CTRL+G
;把CTRL+K记录的鼠标左键点击坐标输出到编辑器

clipboard =
loop % mousepath.MaxIndex()/2 {	
	clipboard .= mousepath[2*A_index-1] ", " mousepath[2*A_index] ", "
}
send, ^v
return

loopclick(x, y, n1:=15, n2:=5, time:=900){
;一直左键点击，直到左键点击位置的颜色改变
;通常用于卡顿的情况，确保鼠标有效点击
;n1，n2为偏移量

	c:=color(x-n1, y-n2)
	loop{
		click, %x%, %y%
		sleep, %time%
	} until (c !=color(x-n1, y-n2))
}

untilclick(x, y, c, t:=40, x1:=0, y1:=0){
;直到坐标颜色变为指定的颜色时左键点击该位置（默认）
;c为颜色，x1，x2如果指定了，就点击该位置

	untilc(x, y, c, t)
	if !x1		;默认原处点击
		x1:=x, y1:=y
	loopclick(x1, y1)
}




dpitransform(ByRef x, ByRef y) {
	WinGetPos, , , Width, Height, A
	x := round(x * Width / 644)
	y := round(y * Height / 392)
}

relativeclick(x, y){
	dpitransform(x, y)
	click, % x "," y
}


tooltip(text, x:=12, y:=380, t:=3000 ){
	dpitransform(x, y)
	tooltip, %text%,%x%, %y%
	settimer,removetool, %t%
	return
removetool:
	settimer,removetool,off
	tooltip
	return
}

sheetclick(x, y, row, col, lux, luy, rdx, rdy, counts) {
	;鼠标坐标，左上角坐标，右下角坐标
	rpitch:= floor(abs(rdx-lux)/col)
	cpitch:= floor(abs(rdy-luy)/row)
	r:= mod(counts-1,col)
	c:= floor((counts-1)/col)
	loopclick(x + r*rpitch , y + c*cpitch)
}
return

;图像处理
;***********************************************************************
#x::
MouseGetPos, x1, x2
tooltip(clipboard := "(" x1 ", " x2 ", " color(x1, x2) ")")
return

#c::
if InStr(clipboard, "0x")
    StringTrimRight, clipboard, clipboard, 10	;删去颜色部分
StringSplit, x, % MultiStrDel(" ","("), `,
if x2
    click %x1%, %x2%, 0
tooltip(x1 ", " x2 ", " color(x1, x2))
return

color(x, y) {
	Pixelgetcolor,c,%x%,%y%	
	return MultiDelAt(c,4,6,8)
}

judgec(x,y,c){
	return (color(x,y)=c)
}

untilc(x,y,c,counts:=0) {	;默认无限等待
	WinGetActiveTitle,currt
	loop {      
		sleep,500
		tooltip("第" A_index "次检测")
		WinGetActiveTitle,t
		if (t <> currt) {
			tooltip("离开了窗口")
			sleep, 3000			
		}
		else if (A_index>counts && counts!=0){			
			timeout()
			break
		}
	} until color(x, y) = c && t = currt
	tooltip("结束")
}

;文本处理
;***********************************************************************
ReplaceAt(searchtext, num, Replacetext:=""){	;默认替换空的
	clipboard :=clipboard
	pos:=InStr(clipboard, searchtext, , , num)
	StringLeft, left, clipboard, pos-1
	StringRight, right, clipboard, StrLen(clipboard)-pos
	clipboard:=left Replacetext right
	return clipboard
}

MultiDelAt(text, p*) {
	StartPos=1
	loop, % p.maxindex(){
		str .= SubStr(text, StartPos, p[A_index]-StartPos)
		StartPos:= p[A_index]+1
	}
	str .= SubStr(text, StartPos)
	return str
}

MultiStrDel(t*) {
	clipboard := clipboard
	loop, % t.maxindex()
		StringReplace,clipboard,clipboard, % t[A_index] ,,a
	return clipboard
}

;异常处理
;***********************************************************************
timeout(){
	throw "timeout"
}