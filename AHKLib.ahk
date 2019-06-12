;author:Howoo
;update:190120
;

#NoEnv
SetTitleMatchMode 2
DetectHiddenText, Off


;¼�ƽű�
;***********************************************************************
^k::
	;����CTRL+K
	;��¼������������꣬��������ֹͣ��¼
	;��CTRL+Gճ��

	Mousepath:={}

	loop{
		KeyWait, LButton, D
		if (A_PriorKey != "k")
			flag=1
		if (A_PriorKey != "LButton" && flag)
			break
		MouseGetPos, x, y
		tooltip(A_index "�� " x " " y " " A_Priorkey)
		Mousepath.push(x1,x2)
		Sleep, 300
	}
	flag=0
return

^g::
	;����CTRL+G
	;��CTRL+K��¼���������������ճ��

	clipboard =
	loop % Mousepath.MaxIndex()/2 {
		clipboard .= Mousepath[2*A_index-1] ", " Mousepath[2*A_index] ", "
	}
	Send, ^v
return


;����ת��
;***********************************************************************
;�����갴644*392ת��
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
	;ʶ��һЩ�����Ľ��棬����һЩ2*3����Ϸ��Ʒ������row=2��col=3
	;���ݱ��Ĵ�С�Զ������������λ�ã�����posΪ��Ʒ����ĵ�һ��������λ��
	;��¼�¸�λ�ã�������ڶ��񡢵�����...������λ��
	;��counts=5ʱ����������ң����ϵ��µ�5������
	;posΪ��Ԫ��Ҫ��������꣬luposΪ�б����Ͻ����꣬rdposΪ���½�����

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

;ͼ����
;***********************************************************************
#x::
	;��ȡ�������͸��������ɫ
	;����ճ�����༭��

	MouseGetPos, x1, x2
	tooltip(clipboard := "(" color(x1, x2) ", " x1 ", " x2 ")")
return

#c::
	;�������˱༭�����������ʱ�����������ɫ��Ϣ����ȥ����ɫ��Ϣ���ƶ���������
	;����ȷ�������Ƿ���Լ������һ��

	if InStr(clipboard, "0x")
		StringTrimLeft, clipboard, clipboard, 7	;ɾȥ��ɫ����
	StringSplit, x, % MultiStrDel(" ",")"), `,
	if x2
		Click %x1%, %x2%, 0
	tooltip(color(x1, x2) ", " x1 ", " x2)
return

color(x, y:=0) {
	;��ɫֻȡһ�����ܸ��õ����䲻ͬ�ĵ��ԣ�����˵��ɫ��RGB��F3B233�����ȡΪ��RGB��FB3
	;ע�⣬������õ���Ĭ����ɫ����һ��ΪRGB������ֻ��Ϊ�˷���

	if (y=0)
		possplit(x,y)
	PixelGetColor,c,%x%,%y%
	return MultiDelAt(c,4,6,8)
}

Colorwait(c,x,y:=0,c2:=0,counts:=5000,time:=600) {	;Ĭ�����޵ȴ�
	;����λ����ɫֱ����������λ��

	if (y=0)
		possplit(x,y)
	WinGetActiveTitle,currt
	loop {
		Sleep,%time%
		tooltip("��" A_index "�μ����")
		WinGetActiveTitle,t
		if (t <> currt) {
			tooltip("�뿪�˴���")
			Sleep, 3000
		}
		else if (A_index>counts && counts){	;��ʱ
			;timeout()
			tooltip("��ʱ")
			return false
		}
		else if (judgec(c2, x, y) && c2)	;��⵽��һ����ɫ
			return false
	} until bitdiff(color(x, y),c) && t = currt
	tooltip("���ɹ�")
	return true
}



detect_c_click(c, x, y:=0, c2:=0, counts:=0, x1:=0, y1:=0){
	if (y=0)
		possplit(x,y)

	if (Colorwait(c, x, y, c2)) {
		if (x1=0){	;Ĭ��̽����ɫ�����
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
	;һֱ��������ֱ��������λ�õ���ɫ�ı�
	;ͨ�����ڿ��ٵ������ȷ�������Ч���

	Sleep, %time%
	if (y=0)
		possplit(x,y)
	c:=color(x, y)
	loop ,15 {
		Click, %x%, %y%
		Sleep, %time%
	} until (!bitdiff(color(x,y),c))
}


;�ı������ݴ���
;***********************************************************************
;��16�������ֵ�Ŀ���ԭ����Ӧÿλ��������ƫ�����Ƚ�
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

;����num���ı��滻
ReplaceAt(searchtext, num:=1, Replacetext:=""){	;Ĭ���滻�յ�
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

;�ű���Ӧ
;***********************************************************************
beep(Frequency:= 750, Duration:= 1500){
	SoundBeep,%Frequency%, %Duration%
}

exit(){
	;beep()
	Exit
}

tooltip(text, x:=12, y:=380, t:=5000 ){
	;Ĭ�������½�λ����ʾtooltip

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