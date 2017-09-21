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
<title>[<% ident(); %>] 恢复初始设置...</title>
<script type='text/javascript'>
var n = 90;
function tick()
{
	var e = document.getElementById('continue');
	e.value = n--;
	if (n < 0) {
		e.value = 'Continue';
		return;
	}
	if (n == 19) e.disabled = false;
	setTimeout(tick, 1000);
}
function go()
{
	window.location = 'http://192.168.1.1/';
}
function init()
{
	tick()
}
</script></head>
<body style='background:#fff' onload='init()'><table style='width:100%;height:100%'>
<tr><td style='text-align:center;vertical-align:middle;font:12px sans-serif'><form>
请稍等设置恢复中... &nbsp;
<input type='button' value='' style='font:12px sans-serif;width:80px;height:24px' id='continue' onclick='go()' disabled>
<div style='width:600px;border-top:1px dashed #888;margin:5px auto;padding:5px 0;font-size:14px;' id='msg'>路由器的 IP 将重置为 192.168.1.1. 你可能需要刷新计算机的 DHCP 或重启计算机后才能继续操作.</div>
</form></td></tr>
</table></body></html>
