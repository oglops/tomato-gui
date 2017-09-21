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
<title>[<% ident(); %>] 系统管理: 调试模式</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("debug_nocommit,debug_cprintf,debug_cprintf_file,console_loglevel,t_cafree,t_hidelr,debug_ddns,debug_norestart"); %>

function nvramCommit()
{
	fields.disableAll('_fom', 1);
	form.submitHidden('nvcommit.cgi', { '_nextpage': myName() });
}

function verifyFields(focused, quiet)
{
	return 1;
}

function save()
{
	var fom = E('_fom');
	fom.debug_nocommit.value = fom.f_debug_nocommit.checked ? 1 : 0;
	fom.debug_cprintf.value = fom.f_debug_cprintf.checked ? 1 : 0;
	fom.debug_cprintf_file.value = fom.f_debug_cprintf_file.checked ? 1 : 0;
	fom.t_cafree.value = fom.f_cafree.checked ? 1 : 0;
	fom.t_hidelr.value = fom.f_hidelr.checked ? 1 : 0;
	fom.debug_ddns.value = fom.f_debug_ddns.checked ? 1 : 0;

	var a = [];
	if (fom.f_nr_crond.checked) a.push('crond');
	if (fom.f_nr_dnsmasq.checked) a.push('dnsmasq');
/* LINUX26-BEGIN */
	if (fom.f_nr_hotplug2.checked) a.push('hotplug2');
/* LINUX26-END */
	if (fom.f_nr_igmprt.checked) a.push('igmprt');
	fom.debug_norestart.value = a.join(',');

	form.submit(fom, 1);
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

<input type='hidden' name='_nextpage' value='admin-misc.asp'>

<input type='hidden' name='debug_nocommit'>
<input type='hidden' name='debug_cprintf'>
<input type='hidden' name='debug_cprintf_file'>
<input type='hidden' name='debug_ddns'>
<input type='hidden' name='debug_norestart'>
<input type='hidden' name='t_cafree'>
<input type='hidden' name='t_hidelr'>

<div class='section-title'>调试模式设置</div>
<div class='section'>
<script type='text/javascript'>
a = [];
for (i = 1; i <= 8; ++i) a.push([i, i]);
createFieldTable('', [
	{ title: '避免执行 NVRAM 提交', name: 'f_debug_nocommit', type: 'checkbox', value: nvram.debug_nocommit != '0' },
	{ title: '启用 将 cprintf<br>输出至控制台', name: 'f_debug_cprintf', type: 'checkbox', value: nvram.debug_cprintf != '0' },
	{ title: '启用 cprintf<br>输出至 /tmp/cprintf', name: 'f_debug_cprintf_file', type: 'checkbox', value: nvram.debug_cprintf_file != '0' },
	{ title: '启用 DDNS<br>输出至 /tmp/mdu-*', name: 'f_debug_ddns', type: 'checkbox', value: nvram.debug_ddns != '0' },
	{ title: '将缓存内存和缓冲区<br>计算为可用内存', name: 'f_cafree', type: 'checkbox', value: nvram.t_cafree == '1' },
	{ title: '在路由器连接中<br>不显示 LAN', name: 'f_hidelr', type: 'checkbox', value: nvram.t_hidelr == '1' },
	{ title: '控制台日志级别', name: 'console_loglevel', type: 'select', options: a, value: fixInt(nvram.console_loglevel, 1, 8, 1) },
	{ title: '如果以下进程退出<br>不重新启动', multi: [
		{ name: 'f_nr_crond', type: 'checkbox', suffix: ' crond<br>', value: (nvram.debug_norestart.indexOf('crond') != -1) },
		{ name: 'f_nr_dnsmasq', type: 'checkbox', suffix: ' dnsmasq<br>', value: (nvram.debug_norestart.indexOf('dnsmasq') != -1) },
/* LINUX26-BEGIN */
		{ name: 'f_nr_hotplug2', type: 'checkbox', suffix: ' hotplug2<br>', value: (nvram.debug_norestart.indexOf('hotplug2') != -1) },
/* LINUX26-END */
		{ name: 'f_nr_igmprt', type: 'checkbox', suffix: ' igmprt<br>', value: (nvram.debug_norestart.indexOf('igmprt') != -1) }
	] }
]);
</script>
<br><br>

&raquo; <a href='clearcookies.asp?_http_id=<% nv(http_id); %>'>清除 Cookies</a><br>
&raquo; <a href='javascript:nvramCommit()'>保存更改至 NVRAM</a><br>
&raquo; <a href='javascript:reboot()'>重新启动</a><br>
&raquo; <a href='javascript:shutdown()'>关闭系统</a><br>
<br><br>

&raquo; <a href='/cfe/cfe.bin?_http_id=<% nv(http_id); %>'>下载 CFE</a><br>
&raquo; <a href='/ipt/iptables.txt?_http_id=<% nv(http_id); %>'>下载 IPv4 防火墙配置</a><br>
<!-- IPV6-BEGIN -->
&raquo; <a href='/ip6t/ip6tables.txt?_http_id=<% nv(http_id); %>'>下载 IPv6 防火墙配置</a><br>
<!-- IPV6-END -->
&raquo; <a href='/logs/syslog.txt?_http_id=<% nv(http_id); %>'>下载日志文件</a><br>
&raquo; <a href='/nvram/nvram.txt?_http_id=<% nv(http_id); %>'>下载 NVRAM 配置</a><br>
<br>

<div style='width:80%'>
<b>警告</b>: NVRAM 镜像文本文件可能包含如下信息:如 无线加密
密钥,路由器的用户名/密码, ISP 和 DDNS 信息. 请在共享给别人之前
检查并编辑这些文件.<br>
</div>
</div>

<!-- / / / -->

</td></tr>

<tr><td id='footer' colspan=2>
<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='reloadPage();'>
	</td></tr>
</table>
</form>
</body>
</html>
