<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2008 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	NGINX Web Server Management Control
	Ofer Chen (roadkill AT tomatoraf dot com)
	Vicente Soriano (victek AT tomatoraf dot com)
	Copyright (C) 2013 http://www.tomatoraf.com
	
	For use with Tomato Firmware only.
	No part of this file can be used or modified without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Web 服务器</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>
.controls {
 	width: 90px;
	margin-top: 5px;
	margin-bottom: 10px;
}
</style>
<script type='text/javascript'>

//	<% nvram("nginx_enable,nginx_php,nginx_keepconf,nginx_port,nginx_upload,nginx_remote,nginx_fqdn,nginx_docroot,nginx_priority,nginx_custom,nginx_httpcustom,nginx_servercustom,nginx_user,nginx_phpconf,nginx_override,nginx_overridefile"); %>

changed = 0;
nginxup = parseInt ('<% psup("nginx"); %>');

function toggle(service, isup)
{
	if (changed) {
		if (!confirm("未保存的更改将丢失. 确定要继续吗?")) return;
	}
	E('_' + service + '_button').disabled = true;
	form.submitHidden('/service.cgi', {
		_redirect: 'web-nginx.asp',
		_sleep: ((service == 'nginxfp') && (!isup)) ? '10' : '5',
		_service: service + (isup ? '-stop' : '-start')
	});
}

function verifyFields(focused, quiet)
{
	var ok = 1;

	var a = E('_f_nginx_enable').checked;
	var b = E('_f_nginx_override').checked;

	E('_f_nginx_php').disabled = !a ;
	E('_f_nginx_keepconf').disabled = !a || b;
	E('_nginx_port').disabled = !a || b;
	E('_nginx_upload').disabled = !a || b;
	E('_f_nginx_remote').disabled = !a;
	E('_nginx_fqdn').disabled = !a || b;
	E('_nginx_docroot').disabled = !a || b;
	E('_nginx_priority').disabled = !a || b;
	E('_nginx_custom').disabled = !a || b;
	E('_nginx_httpcustom').disabled = !a || b;
	E('_nginx_servercustom').disabled = !a || b;
	E('_nginx_user').disabled = !a;
	E('_nginx_phpconf').disabled = !a || b;
	E('_f_nginx_override').disabled = !a;
	E('_nginx_overridefile').disabled = !a || !b;

	return ok;
}

function save()
{
	if (verifyFields(null, 0)==0) return;
	var fom = E('_fom');

	fom.nginx_enable.value = E('_f_nginx_enable').checked ? 1 : 0;
	if (fom.nginx_enable.value) {
		fom.nginx_php.value = fom.f_nginx_php.checked ? 1 : 0;
		fom.nginx_keepconf.value = fom.f_nginx_keepconf.checked ? 1 : 0;
		fom.nginx_remote.value = fom.f_nginx_remote.checked ? 1 : 0;
		fom.nginx_override.value = fom.f_nginx_override.checked ? 1 : 0;
		fom._service.value = 'nginx-restart';
	} else {
		fom._service.value = 'nginx-stop';
	}
	form.submit(fom, 1);
}

function init()
{
	verifyFields(null, 1);
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

<!-- / / / -->
<div class='section-title'>Status</div>
<div class='section' id='status-section'>
<script type='text/javascript'>
	W('NGINX 服务器现在 '+(!nginxup ? '已停止' : '运行中')+' ');
	W('<input type="button" value="' + (nginxup ? '停止' : '现在启动') + ' " onclick="toggle(\'nginxfp\', nginxup)" id="_nginxfp_button">');
</script>
<br>
</div>

<div class='section-title'>基本设置</div>
<div class='section' id='config-section'>
<form id='_fom' method='post' action='tomato.cgi'>
<input type='hidden' name='_nextpage' value='web-nginx.asp'>
<input type='hidden' name='_service' value='enginex-restart'>
<input type='hidden' name='_nextwait' value='10'>
<input type='hidden' name='_reboot' value='0'>

<input type='hidden' name='nginx_enable'>
<input type='hidden' name='nginx_php'>
<input type='hidden' name='nginx_keepconf'>
<input type='hidden' name='nginx_remote'>
<input type='hidden' name='nginx_override'>

<script type='text/javascript'>
createFieldTable('', [
	{ title: '开机时启动服务', name: 'f_nginx_enable', type: 'checkbox', value: nvram.nginx_enable == '1'},
	{ title: '启用 PHP 支持', name: 'f_nginx_php', type: 'checkbox', value: nvram.nginx_php == '1' },
	{ title: '以用户身份运行', name: 'nginx_user', type: 'select',
		options: [['root','Root'],['nobody','Nobody']], value: nvram.nginx_user },
	{ title: '保存配置文件', name: 'f_nginx_keepconf', type: 'checkbox', value: nvram.nginx_keepconf == '1' },
	{ title: 'Web 服务器端口', name: 'nginx_port', type: 'text', maxlen: 5, size: 7, value: fixPort(nvram.nginx_port, 85), suffix: '<small> 默认: 85</small>' },
	{ title: '上传文件大小限制', name: 'nginx_upload', type: 'text', maxlen: 5, size: 7, value: nvram.nginx_upload, suffix: '<small> MB</small>'},
	{ title: '允许远程访问', name: 'f_nginx_remote', type: 'checkbox', value: nvram.nginx_remote == '1' },
	{ title: 'Web 服务器名', name: 'nginx_fqdn', type: 'text', maxlen: 255, size: 20, value: nvram.nginx_fqdn },
	{ title: '服务器根目录', name: 'nginx_docroot', type: 'text', maxlen: 255, size: 40, value: nvram.nginx_docroot, suffix: '<small>&nbsp;/index.html / index.htm / index.php</small>' },
	{ title: '服务器优先级', name: 'nginx_priority', type: 'text', maxlen: 8, size:3, value: nvram.nginx_priority, suffix:'<small> 最大优先级: -20, 最小优先级: 19, 默认: 10</small>' }
]);
</script>
</div>
<div class='section-title'>高级设置</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '<a href="http://wiki.nginx.org/Configuration" target="_new">NGINX</a><br>HTTP Section<br> 自定义配置', name: 'nginx_httpcustom', type: 'textarea', value: nvram.nginx_httpcustom },
	{ title: '<a href="http://wiki.nginx.org/Configuration" target="_new">NGINX</a><br>SERVER Section<br> 自定义配置', name: 'nginx_servercustom', type: 'textarea', value: nvram.nginx_servercustom },
	{ title: '<a href="http://wiki.nginx.org/Configuration" target="_new">NGINX</a><br> 自定义配置', name: 'nginx_custom', type: 'textarea', value: nvram.nginx_custom },
	{ title: '<a href="http://php.net/manual/en/ini.php" target="_new">PHP</a><br> 自定义配置', name: 'nginx_phpconf', type: 'textarea', value: nvram.nginx_phpconf },
	null,
	{ title: '使用用户配置文件', name: 'f_nginx_override', type: 'checkbox', value: nvram.nginx_override == '1', suffix: '<small> 如果使用户配置文件, 一些本页面上的GUI设置将被忽略</small>' },
	{ title: '用户配置文件路径', name: 'nginx_overridefile', type: 'text', maxlen: 255, size: 40, value: nvram.nginx_overridefile }
]);
</script>
</div>
<div class='section-title'>说明</div>
<div class='section'>
<ul>
<li><b> 状态按钮:</b> 快速启动/停止服务. 勾选"启用 Web 服务器"之后才能更改此设置.<br>
<li><b> 开机时启动服务:</b> 勾选后路由器启动时将自动启动 Web 服务器.<br>
<li><b> 启用 PHP 支持:</b> 勾选后启用 PHP support (php-cgi) 支持.<br>
<li><b> 以用户身份运行:</b> 选择启动 nginx 和 php-cgi 服务的用户.<br>
<li><b> 保存配置文件:</b> 如果你手动修改了配置文件? 勾选此选项可以确保配置被保存.<br> 
<li><b> Web 服务器端口:</b> 访问Web 服务器的端口. 请确保此端口没有被其他服务占用.<br>
<li><b> 允许远程访问:</b> 这个选项将允许从广域网端口访问Web服务器的GUI, 服务将可以从互联网被访问. <br>
<li><b> Web 服务器名:</b> 该名字将出现在你的浏览器上.<br>0
<li><b> 服务器根目录:</b> 在你路由器上文档的存储路径.<br>
<li><b> 例如:<br></b>
/tmp/mnt/HDD/www 你可以参考 USB 挂载路径.<br>
<li><b> NGINX 自定义配置:</b> 你可以在 nginx.conf 里添加其他的设置来满足你的需求.<br>
<li><b> NGINX HTTP Section 自定义配置:</b> 你可以在 nginx.conf 里的 http {} 部分添加其他的设置来满足你的需求.<br>
<li><b> NGINX SERVER Section 自定义配置:</b> 你可以在 nginx.conf 里的 server {} 部分添加其他的设置来满足你的需求.<br>
<li><b> PHP 自定义配置:</b> 你可以在 php.ini 里添加其他的设置来满足你的需求.<br>
<li><b> 服务器优先级:</b> 设置服务的优先级，相对于运行在路由器上的其他进程.<br><br>
操作系统内和的优先级是 -5.<br>
永远不要选择低于内核使用的值。不要使用服务测试页面来调整服务性能<br>
它的性能取决于媒体所处的位置, 如; 优盘, 硬盘 或 SSD.<br>
</ul>
</div>
</form>
</div>


<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
<form>
	<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
</form>
</td></tr>
</table>
<script type='text/javascript'>verifyFields(null, 1);</script>
</body>
</html>
