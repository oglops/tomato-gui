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
<title>[<% ident(); %>] 系统管理: 配置管理</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("et0macaddr,t_features,t_model_name"); %>
//	<% nvstat(); %>

function backupNameChanged()
{
	var name = fixFile(E('backup-name').value);
	if (name.length > 1) {
		E('backup-link').href = 'cfg/' + name + '.cfg?_http_id=' + nvram.http_id;
	}
	else {
		E('backup-link').href = '?';
	}
}

function backupButton()
{
	var name = fixFile(E('backup-name').value);
	if (name.length <= 1) {
		alert('不正确的文件名');
		return;
	}
	location.href = 'cfg/' + name + '.cfg?_http_id=' + nvram.http_id;
}

function restoreButton()
{
	var name, i, f;

	name = fixFile(E('restore-name').value);
	name = name.toLowerCase();
	if ((name.indexOf('.cfg') != (name.length - 4)) && (name.indexOf('.cfg.gz') != (name.length - 7))) {
		alert('不正确的文件名. 正确的扩展名为 ".cfg" .');
		return;
	}
	if (!confirm('确认吗?')) return;
	E('restore-button').disabled = 1;

	f = E('restore-form');
	form.addIdAction(f);
	f.submit();
}

function resetButton()
{
	var i;

	i = E('restore-mode').value;
	if (i == 0) return;
	if ((i == 2) && (features('!nve'))) {
		if (!confirm('警告: 在 ' + nvram.t_model_name + ' 上清除 NVRAM 可能损坏路由器. 有可能在清除完成后无法重新设置 NVRAM，无论如何都要继续吗?')) return;
	}
	if (!confirm('确认吗?')) return;
	E('reset-button').disabled = 1;
	form.submit('aco-reset-form');
}
</script>
</head>
<body onload='backupNameChanged()'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<div class='section-title'>备份配置信息</div>
<div class='section'>
	<form>
		<script type='text/javascript'>
		W("<input type='text' size='40' maxlength='64' id='backup-name' onchange='backupNameChanged()' value='tomato_v" + ('<% version(); %>'.replace(/\./g, '')) + "_m" + nvram.et0macaddr.replace(/:/g, '').substring(6, 12) + "'>");
		</script>
		.cfg &nbsp;
		<input type='button' name='f_backup_button' onclick='backupButton()' value='备份'><br>
		<a href='' id='backup-link'>下载链接</a>
	</form>
</div>

<br><br>

<div class='section-title'>恢复配置信息</div>
<div class='section'>
	<form id='restore-form' method='post' action='cfg/restore.cgi' encType='multipart/form-data'>
		选择所要恢复的配置文件:<br>
		<input type='file' size='40' id='restore-name' name='filename'> <input type='button' name='f_restore_button' id='restore-button' value='恢复' onclick='restoreButton()'>
		<br>
	</form>
</div>

<br><br>

<div class='section-title'>恢复出厂设置</div>
<div class='section'>
	<form id='aco-reset-form' method='post' action='cfg/defaults.cgi'>
	<select name='mode' id='restore-mode'>
		<option value=0>请选择...</option>
		<option value=1>恢复默认路由器设置 (正常)</option>
		<option value=2>擦除 NVRAM 内存中的所有数据 (彻底)</option>
	</select>
	<input type='button' value='确定' onclick='resetButton()' id='reset-button'>
	</form>
</div>

<br>

<div class='section-title'></div>
<div class='section'>
<script type='text/javascript'>
var a = nvstat.free / nvstat.size * 100.0;
createFieldTable('', [
	{ title: '总容量 / 剩余容量 NVRAM:', text: scaleSize(nvstat.size) + ' / ' + scaleSize(nvstat.free) + ' <small>(' + (a).toFixed(2) + '%)</small>' }
]);

if (a <= 5) {
	document.write('<br><div id="notice1">' +
		'NVRAM 可用容量非常低. 非常推荐 ' +
		'擦除 NVRAM 内存中的所有数据，并手动重新配置路由器 ' +
		'以清除所有未使用和过时的条目.' +
		'</div><br style="clear:both">');
}
</script>
</div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
<br><br>
</body>
</html>
