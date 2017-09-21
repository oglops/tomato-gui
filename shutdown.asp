<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] 关机...</title>
<script type='text/javascript'>
var n = 16;
function tick()
{
	if (--n > 0) {
		document.getElementById('sptime').innerHTML = n;
		setTimeout(tick, 1000);
	}
	else {
		document.getElementById('msg').innerHTML = '现在可以关闭路由器电源.';
	}
}
</script></head>
<body style='background:#fff' onload='tick()'><table style='width:100%;height:100%'>
<tr><td style='text-align:center;vertical-align:middle;font:12px sans-serif'>
<span id='msg'>请稍等路由器关闭中... <span id='sptime' style='font-size:80%;background:#eee'></span></span>
</td></tr>
</table></body></html>

