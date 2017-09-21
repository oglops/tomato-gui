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
<title>[<% ident(); %>] 系统管理: 脚本管理</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->
<style type='text/css'>
.as-script {
	font: 12px monospace;
	width: 99%;
	height: 400px;
	overflow: scroll;
	border: 1px solid #eee;
	border-top: none;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("script_init,script_shut,script_fire,script_wanup"); %>

tabs = [['as-init', '初始化'],['as-shut', '关机时'],['as-fire','防火墙'],['as-wanup', '当 WAN 联机']];

function tabSelect(name)
{
	tabHigh(name);
	for (var i = 0; i < tabs.length; ++i) {
		var on = (name == tabs[i][0]);
		elem.display(tabs[i][0] + '-text', on);
	}
	if (i >= tabs.length) return;
	E(name + '-text').focus();
	cookie.set('scripts_tab', name)
}

function wordWrap()
{
	for (var i = 0; i < tabs.length; ++i) {
		var e = E(tabs[i][0] + '-text');
		var s = e.value;
		var c = e.cloneNode(false);
		wrap = E('as-wordwrap').checked;
		c.setAttribute('wrap', wrap ? 'virtual' : 'off');
		e.parentNode.replaceChild(c, e);
		c.value = s;
	}
}

function save()
{
	var i, t, n, x;

	for (i = 0; i < tabs.length; ++i) {
		t = tabs[i];
		n = E(t[0] + '-text').value.length;
		x = (t[0] == 'as-fire') ? 8192 : 4096;
		if (n > x) {
			tabSelect(t[0]);
			alert(t[1] + ' 脚本太长，最大允许 ' + x + ' bytes.');
			return;
		}
	}
	form.submit('_fom', 1);
}

function earlyInit()
{
	for (var i = 0; i < tabs.length; ++i) {
		var t = tabs[i][0];
		E(t + '-text').value = nvram['script_' + t.replace('as-', '')];
	}
	tabSelect(cookie.get('scripts_tab') || 'as-init');
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

<input type='hidden' name='_nextpage' value='admin-scripts.asp'>

<script type='text/javascript'>
tabCreate.apply(this, tabs);

wrap = cookie.get('scripts_wrap') || 0;
y = Math.floor(docu.getViewSize().height * 0.65);
s = 'height:' + ((y > 300) ? y : 300) + 'px;display:none';
for (i = 0; i < tabs.length; ++i) {
	t = tabs[i][0];
	W('<textarea class="as-script" name="script_' + t.replace('as-', '') + '" id="' + t + '-text" wrap=' + (wrap ? 'virtual' : 'off') + ' style="' + s + '"></textarea>');
}
W('<br><input type="checkbox" id="as-wordwrap" onclick="wordWrap()" onchange="wordWrap()" ' +
  (wrap ? 'checked' : '') + '> 自动换行');
</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>earlyInit();</script>
</body>
</html>
