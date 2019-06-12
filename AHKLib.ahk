;author:Howoo
;update:190120
;

#NoEnv
SetTitleMatchMode 2
DetectHiddenText, Off


;录制脚本
;***********************************************************************
^k::
	;按下CTRL+K
	;记录鼠标左键点击坐标，按其他键停止记录
	;按CTRL+G粘贴

	Mousepath:={}

	loop{
		KeyWait, LButton, D
		if (A_PriorKey != "k")
			flag=1
		if (A_PriorKey != "LButton" && flag)
			break
		MouseGetPos, x, y
		tooltip(A_index "次 " x " " y " " A_Priorkey)
		Mousepath.push(x1,x2)
		Sleep, 300
	}
	flag=0
return

^g::
	;按下CTRL+G
	;把CTRL+K记录的鼠标左键点击坐标粘贴

	clipboard =
	loop % Mousepath.MaxIndex()/2 {
		clipboard .= Mousepath[2*A_index-1] ", " Mousepath[2*A_index] ", "
	}
	Send, ^v
return


;坐标转换
;***********************************************************************
;把坐标按644*392转换
dpitransform(ByRef x, ByRef y) {
	WinGetPos, , , Width, Height, A
	x := Round(x * Width / 644)
	y := Round(y * Height / 392)
}

possplit(ByRef x,ByRef y){
	StringSplit, x, x, `,
	x := x1
	y := x2
}

relativeclick(x, y:=0){
	if (y=0)
		possplit(x,y)
	dpitransform(x, y)
	Click, % x "," y
}

sheetclick(pos, row, col, lupos, rdpos, counts) {
	;识别一些表格类的界面，比如一些2*3的游戏物品栏，则row=2，col=3
	;根据表格的大小自动计算鼠标点击的位置，比如pos为物品栏里的第一格的中央的位置
	;记录下该位置，推算出第二格、第三格...的中央位置
	;当counts=5时即点击从左到右，从上到下第5个格子
	;pos为单元格要点击的坐标，lupos为列表左上角坐标，rdpos为右下角坐标

	x:= Pos
	lux:= lupos
	rdx:= rdpos
	y:= 0, luy:=0, rdy:=0
	possplit(x,y)
	possplit(lux,luy)
	possplit(rdx,rdy)
	rpitch:= Floor(Abs(rdx-lux)/col)
	cpitch:= Floor(Abs(rdy-luy)/row)
	r:= Mod(counts-1,col)
	c:= Floor((counts-1)/col)
	loopclick(x + r*rpitch , y + c*cpitch)
}
return

;图像处理
;***********************************************************************
#x::
	;获取鼠标坐标和该坐标的颜色
	;可以粘贴到编辑器

	MouseGetPos, x1, x2
	tooltip(clipboard := "(" color(x1, x2) ", " x1 ", " x2 ")")
return

#c::
	;当复制了编辑器里鼠标坐标时，如果含有颜色信息，则去除颜色信息并移动到该坐标
	;用于确认坐标是否和自己所想的一样

	if InStr(clipboard, "0x")
		StringTrimLeft, clipboard, clipboard, 7	;删去颜色部分
	StringSplit, x, % MultiStrDel(" ",")"), `,
	if x2
		Click %x1%, %x2%, 0
	tooltip(color(x1, x2) ", " x1 ", " x2)
return

color(x, y:=0) {
	;颜色只取一部分能更好地适配不同的电脑，比如说颜色（RGB）F3B233，则截取为（RGB）FB3
	;注意，这里采用的是默认颜色，不一定为RGB，这里只是为了方便

	if (y=0)
		possplit(x,y)
	PixelGetColor,c,%x%,%y%
	return MultiDelAt(c,4,6,8)
}

Colorwait(c,x,y:=0,c2:=0,counts:=5000,time:=600) {	;默认无限等待
	;检测该位置颜色直到符合条件位置

	if (y=0)
		possplit(x,y)
	WinGetActiveTitle,currt
	loop {
		Sleep,%time%
		tooltip("第" A_index "次检测中")
		WinGetActiveTitle,t
		if (t <> currt) {
			tooltip("离开了窗口")
			Sleep, 3000
		}
		else if (A_index>counts && counts){	;超时
			;timeout()
			tooltip("超时")
			return false
		}
		else if (judgec(c2, x, y) && c2)	;检测到另一种颜色
			return false
	} until bitdiff(color(x, y),c) && t = currt
	tooltip("检测成功")
	return true
}



detect_c_click(c, x, y:=0, c2:=0, counts:=0, x1:=0, y1:=0){
	if (y=0)
		possplit(x,y)

	if (Colorwait(c, x, y, c2)) {
		if (x1=0){	;默认探测颜色处点击
			x1:=x
			y1:=y
		} else if (y1=0)
			possplit(x1,y1)
		loopclick(x1, y1)
	}
}

PicSearch(x1,y1,x2,y2,file){
	ImageSearch, Foundx, Foundy, x1, y1, x2, y2, file
	loopclick(Foundx, Foundy)
}

judgec(c,x,y:=0){
	if (y=0)
		possplit(x,y)
	return (bitdiff(color(x,y),c))
}

loopclick(x, y:=0, time:=900){
	;一直左键点击，直到左键点击位置的颜色改变
	;通常用于卡顿的情况，确保鼠标有效点击

	Sleep, %time%
	if (y=0)
		possplit(x,y)
	c:=color(x, y)
	loop ,15 {
		Click, %x%, %y%
		Sleep, %time%
	} until (!bitdiff(color(x,y),c))
}


;文本及数据处理
;***********************************************************************
;将16进制数字的目标和原来对应每位数字求差并与偏移量比较
bitdiff(ori,tar,bias:=1){
	bit:= 0xf
	power:= 8
	loop , 3{
		diff := Abs((ori >> power & bit) - (tar >> power & bit))
		if (diff <= bias)
			power -= 4
		else
			return false
	}
	return true
}

;将第num个文本替换
ReplaceAt(searchtext, num:=1, Replacetext:=""){	;默认替换空的
	pos:=InStr(clipboard, searchtext, , , num)
	StringLeft, left, clipboard, pos-1
	StringRight, Right, clipboard, StrLen(clipboard)-pos-1
	clipboard:=left Replacetext Right
	return clipboard
}



MultiDelAt(text, p*) {
	StartPos=1
	loop, % p.MaxIndex(){
		str .= SubStr(text, StartPos, p[A_index]-StartPos)
		StartPos:= p[A_index]+1
	}
	str .= SubStr(text, StartPos)
	return str
}

MultiStrDel(t*) {
	loop, % t.MaxIndex()
		StringReplace,clipboard,clipboard, % t[A_index] ,,a
	return clipboard
}

;脚本响应
;***********************************************************************
beep(Frequency:= 750, Duration:= 1500){
	SoundBeep,%Frequency%, %Duration%
}

exit(){
	;beep()
	Exit
}

tooltip(text, x:=12, y:=380, t:=5000 ){
	;默认在左下角位置显示tooltip

	dpitransform(x, y)
	ToolTip, %text%,%x%, %y%
	SetTimer,removetool, %t%
	return
removetool:
	SetTimer,removetool,off
	ToolTip
return
}

timeout(){
	throw "timeout"
}