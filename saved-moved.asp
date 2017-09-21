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
<title>[<% ident(); %>] 正在重新启动...</title>
<script language='javascript'>
var n = 20;
function tick()
{
	var e = document.getElementById('continue');
	e.value = n;
	if (n == 10) {
		e.disabled = false;
	}
	if (n == 0) {
		e.value = '继续';
	}
	else {
		--n;
		setTimeout(tick, 1000);
	}
}
function go()
{
	window.location = window.location.protocol + '//<% nv("lan_ipaddr"); %>/';
}
</script></head>
<body style='background:#fff' onload='tick()'>
<table style='width:100%;height:100%'>
<tr><td style='text-align:center;vertical-align:middle;font:12px sans-serif'>
<form>
<div style='width:600px;border-bottom:1px solid #aaa;margin:5px auto;padding:5px 0;font-size:14px'>
路由器地址已变更至 <% nv("lan_ipaddr"); %>. 你可能需要刷新计算机的 DHCP 后才能继续操作.
</div>
请稍候！正在重新启动路由器... &nbsp;
<input type='button' value='' style='font:12px sans-serif;width:80px;height:24px' id='continue' onclick='go()' disabled>
</form>
</td></tr></table></body></html>
