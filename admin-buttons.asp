<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
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
<title>[<% ident(); %>] 系统管理: 按键/指示灯</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>
textarea {
	width: 98%;
	height: 15em;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>
//	<% nvram("sesx_led,sesx_b0,sesx_b1,sesx_b2,sesx_b3,sesx_script,script_brau,t_model,t_features"); %>

var ses = features('ses');
var brau = features('brau');
var aoss = features('aoss');
var wham = features('wham');

function verifyFields(focused, quiet)
{
	return 1;
}

function save()
{
	var n;
	var fom;
	
	fom = E('_fom');
	n = 0;
	if (fom._led0.checked) n |= 1;
	if (fom._led1.checked) n |= 2;
	if (fom._led2.checked) n |= 4;
	if (fom._led3.checked) n |= 8;
	fom.sesx_led.value = n;
	form.submit(fom, 1);
}

function earlyInit()
{
	if ((!brau) && (!ses)) {
		E('save-button').disabled = 1;
		return;
	}

	if (brau) E('braudiv').style.display = '';
	E('sesdiv').style.display = '';
	if ((wham) || (aoss) || (brau)) E('leddiv').style.display = '';
}
</script>
</head>
<body>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<input type='hidden' name='_nextpage' value='admin-buttons.asp'>
<input type='hidden' name='sesx_led' value='0'>

<div id='sesdiv' style='display:none'>
<div class='section-title'>SES/WPS/AOSS 按键</div>
<div class='section'>
<script type='text/javascript'>
a = [[0,'不做任何事'],[1,'开/关无线网络'],[2,'重启系统'],[3,'关闭系统'],
/* USB-BEGIN */
[5,'卸载所有 USB 设备'],
/* USB-END */
[4,'运行自定义脚本']];
createFieldTable('', [
	{ title: "当按下时..." },
	{ title: '0-2 秒', indent: 2, name: 'sesx_b0', type: 'select', options: a, value: nvram.sesx_b0 || 0 },
	{ title: '4-6 秒', indent: 2, name: 'sesx_b1', type: 'select', options: a, value: nvram.sesx_b1 || 0 },
	{ title: '8-10 秒', indent: 2, name: 'sesx_b2', type: 'select', options: a, value: nvram.sesx_b2 || 0 },
	{ title: '12+ 秒', indent: 2, name: 'sesx_b3', type: 'select', options: a, value: nvram.sesx_b3 || 0 },
	{ title: '自定义脚本', indent: 2, name: 'sesx_script', type: 'textarea', value: nvram.sesx_script }
]);
</script>
</div>
</div>

<div id='braudiv' style='display:none'>
<div class='section-title'>Bridge/Auto Switch</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '自定义脚本', indent: 2, name: 'script_brau', type: 'textarea', value: nvram.script_brau }
]);
</script>
</div>
</div>

<div id='leddiv' style='display:none'>
<div class='section-title'>启动指示灯</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '琥珀色 SES', name: '_led0', type: 'checkbox', value: nvram.sesx_led & 1, hidden: !wham },
	{ title: '白色 SES', name: '_led1', type: 'checkbox', value: nvram.sesx_led & 2, hidden: !wham },
	{ title: 'AOSS', name: '_led2', type: 'checkbox', value: nvram.sesx_led & 4, hidden: !aoss },
	{ title: '桥接', name: '_led3', type: 'checkbox', value: nvram.sesx_led & 8, hidden: !brau }
]);
</script>
</div>
</div>

<script type='text/javascript'>
if ((!ses) && (!brau)) W('<i>此路由器不支持此功能.</i>');
</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>earlyInit()</script>
</body>
</html>

