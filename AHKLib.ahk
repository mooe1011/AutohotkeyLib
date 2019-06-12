;author:Howoo
;update:181208
;log:��ɫģ��ƥ��
;

#NoEnv
SetTitleMatchMode 2
DetectHiddenText, Off


beep(Frequency:= 750, Duration:= 1500){
	soundbeep,%Frequency%, %Duration%
}

;¼�ƽű�
;***********************************************************************
^k::
;����CTRL+K
;��¼������������꣬��������ֹͣ��¼

mousepath:={}

loop{	
	Keywait, LButton, D
	if (A_PriorKey != "k")
		flag=1
	if (A_PriorKey != "Lbutton" && flag)
		break
	MouseGetPos, x1, x2
	tooltip(A_index "�� " x1 " " x2 " " A_Priorkey)
	mousepath.push(x1,x2)
	sleep, 300	
}
flag=0
return

^g::
;����CTRL+G
;��CTRL+K��¼���������������������༭��

clipboard =
loop % mousepath.MaxIndex()/2 {	
	clipboard .= mousepath[2*A_index-1] ", " mousepath[2*A_index] ", "
}
send, ^v
return

loopclick(x, y, n1:=15, n2:=5, time:=900){
;һֱ��������ֱ��������λ�õ���ɫ�ı�
;ͨ�����ڿ��ٵ������ȷ�������Ч���
;n1��n2Ϊƫ����

	c:=color(x-n1, y-n2)
	loop{
		click, %x%, %y%
		sleep, %time%
	} until (c !=color(x-n1, y-n2))
}

untilclick(x, y, c, t:=40, x1:=0, y1:=0){
;ֱ��������ɫ��Ϊָ������ɫʱ��������λ�ã�Ĭ�ϣ�
;cΪ��ɫ��x1��x2���ָ���ˣ��͵����λ��

	untilc(x, y, c, t)
	if !x1		;Ĭ��ԭ�����
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
	;������꣬���Ͻ����꣬���½�����
	rpitch:= floor(abs(rdx-lux)/col)
	cpitch:= floor(abs(rdy-luy)/row)
	r:= mod(counts-1,col)
	c:= floor((counts-1)/col)
	loopclick(x + r*rpitch , y + c*cpitch)
}
return

;ͼ����
;***********************************************************************
#x::
MouseGetPos, x1, x2
tooltip(clipboard := "(" x1 ", " x2 ", " color(x1, x2) ")")
return

#c::
if InStr(clipboard, "0x")
    StringTrimRight, clipboard, clipboard, 10	;ɾȥ��ɫ����
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

untilc(x,y,c,counts:=0) {	;Ĭ�����޵ȴ�
	WinGetActiveTitle,currt
	loop {      
		sleep,500
		tooltip("��" A_index "�μ��")
		WinGetActiveTitle,t
		if (t <> currt) {
			tooltip("�뿪�˴���")
			sleep, 3000			
		}
		else if (A_index>counts && counts!=0){			
			timeout()
			break
		}
	} until color(x, y) = c && t = currt
	tooltip("����")
}

;�ı�����
;***********************************************************************
ReplaceAt(searchtext, num, Replacetext:=""){	;Ĭ���滻�յ�
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

;�쳣����
;***********************************************************************
timeout(){
	throw "timeout"
}