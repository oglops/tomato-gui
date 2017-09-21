<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2012 Shibby
	http://openlinksys.info
	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] 系统管理: TomatoAnon 项目</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript'>
//	<% nvram("tomatoanon_enable,tomatoanon_answer,tomatoanon_id,tomatoanon_notify"); %>

var anon_link = '&nbsp;&nbsp;<a href="http://anon.groov.pl/index.php?search=9&routerid=<% nv('tomatoanon_id'); %>" target="_blank"><i>[查看我的路由器]</i></a>';

function verifyFields(focused, quiet)
{
	var o = (E('_tomatoanon_answer').value == '1');
	var s = (E('_tomatoanon_enable').value == '1');

	E('_tomatoanon_enable').disabled = !o;
	E('_f_tomatoanon_notify').disabled = !o || !s;

	return 1;
}

function save()
{
	if (verifyFields(null, 0)==0) return;
	var fom = E('_fom');

	fom.tomatoanon_notify.value = E('_f_tomatoanon_notify').checked ? 1 : 0;

	fom._service.value = 'tomatoanon-restart';
	form.submit('_fom', 1);
}

function init()
{
}
</script>
</head>

<body onLoad="init()">
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
<div class='title'>Tomato</div>
<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>
<form id='_fom' method='post' action='tomato.cgi'>
<input type='hidden' name='_nextpage' value='admin-tomatoanon.asp'>
<input type='hidden' name='_service' value='tomatoanon-restart'>
<input type='hidden' name='tomatoanon_notify'>
<div class='section-title'>关于 TomatoAnon 项目</div>
<div class="fields"><div class="about">
<b>您好,</b><br>
<br>
我想向您介绍一个我正在开发的新项目，名为 TomatoAnon。<br>
TomatoAnon 脚本将向在线数据库发送有关您的路由器型号和已安装的 Tomato 版本的信息.<br>
提交的信息是100％匿名的，只用于统计目的.<br>
<b>此脚本不会收集或传输任何私人或个人信息（例如 MAC 地址，IP 地址等）!</b><br>
TomatoAnon 脚本是完全开放的，并且用 bash 编写。 每个人都可以自由地查看所收集并传输到数据库的信息.<br>
<br>
收集的数据可以在 <a href="http://anon.groov.pl/" target="_blank"><b>TomatoAnon 统计</b></a> 页面查看.<br>
这些信息可以帮助您选择您所在国家或地区可用的最佳和最受欢迎的路由器.<br>
您可以在此找到每个路由器最常用和最稳定的 Tomato 版本<br>
<br>
如果您不希望提供数据或对正在收集的数据不舒服的情况下，可以禁用 TomatoAnon 脚本.<br>
当然您也可以随时重新启用它.<br>
<br>
以下数据由 TomatoAnon 收集和传输:<br>
 - WAN+LAN MAC 地址的 MD5SUM - 用来区分路由器. 如: 1c1dbd4202d794251ec1acf1211bb2c8<br>
 - 路由器型号. 如: Asus RT-N66U<br>
 - 当前安装的 Tomato 版本. 如: 102 K26 USB<br>
 - 编译类型. 如: Mega-VPN-64K<br>
 - 路由器开机时间. 如: 3 天<br>
这就是全部的数据了 !!<br>
<br>
感谢您的阅读，请做出正确的选择来帮助这个项目.<br>
<br>
<b>谨此致意!</b>
</div></div>
<br>
<br>
<div class='section-title'>TomatoAnon 设置 <script>W(anon_link);</script></div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '你了解 TomatoAnon<br>功能了吗', name: 'tomatoanon_answer', type: 'select', options: [ ['0','不, 我不清楚. 我需要阅读上述信息并作出明智的决定.'], ['1','是的, 我已了解并作出决定.'] ], value: nvram.tomatoanon_answer, suffix: ' '},
	{ title: '是否要启用<br>TomatoAnon ?', name: 'tomatoanon_enable', type: 'select', options: [ ['-1','我现在不确定'], ['1','是的, 我确定启用它'], ['0','不, 我不想启用它'] ], value: nvram.tomatoanon_enable, suffix: ' '}
]);
</script>
</div>

<div class='section-title'>Tomato 更新通知系统</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
{ title: '启用', name: 'f_tomatoanon_notify', type: 'checkbox', value: nvram.tomatoanon_notify == '1' }
]);
</script>
<ul>
	<li>当有可更新的 Tomato 版本时，将在“系统状态”页面通知您.
</ul>
</div>
</form>
<div></div>
</td></tr>
<tr><td id='footer' colspan=2>
 <form>
 <span id='footer-msg'></span>
 <input type='button' value='保存设置' id='save-button' onclick='save()'>
 <input type='button' value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
 </form>
<div></div>
</td></tr>
</table>
<script type='text/javascript'>verifyFields(null, 1);</script>
</body>
</html>
