<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato MySQL GUI
	Copyright (C) 2014 Hyzoom, bwq518@gmail.com
	http://openlinksys.info
	For use with Tomato Shibby Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] MySQL 数据库服务器</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>
<style type='text/css'>
textarea {
 width: 98%;
 height: 15em;
}
</style>
<script type='text/javascript'>
//	<% nvram("mysql_enable,mysql_sleep,mysql_check,mysql_check_time,mysql_binary,mysql_binary_custom,mysql_usb_enable,mysql_dlroot,mysql_datadir,mysql_tmpdir,mysql_server_custom,mysql_port,mysql_allow_anyhost,mysql_init_rootpass,mysql_username,mysql_passwd,mysql_key_buffer,mysql_max_allowed_packet,mysql_thread_stack,mysql_thread_cache_size,mysql_init_priv,mysql_table_open_cache,mysql_sort_buffer_size,mysql_read_buffer_size,mysql_query_cache_size,mysql_read_rnd_buffer_size,mysql_max_connections,nginx_port"); %>

var ams_link = '&nbsp;&nbsp;<a href="http://' + location.hostname + ':' + nvram.nginx_port + '/adminer.php" target="_blank"><i>[点击这里进入 MySQL 管理页面]</i></a>';
//	<% usbdevices(); %>
var usb_disk_list = new Array();
function refresh_usb_disk()
{
	var i, j, k, a, b, c, e, s, desc, d, parts, p;
	var partcount;
	list = [];
	for (i = 0; i < list.length; ++i) {
		list[i].type = '';
		list[i].host = '';
		list[i].vendor = '';
		list[i].product = '';
		list[i].serial = '';
		list[i].discs = [];
		list[i].is_mounted = 0;
	}
	for (i = usbdev.length - 1; i >= 0; --i) {
		a = usbdev[i];
		e = {
			type: a[0],
			host: a[1],
			vendor: a[2],
			product: a[3],
			serial: a[4],
			discs: a[5],
			is_mounted: a[6]
		};
		list.push(e);
	}
	partcount = 0;
	for (i = list.length - 1; i >= 0; --i) {
		e = list[i];
		if (e.discs) {
			for (j = 0; j <= e.discs.length - 1; ++j) {
				d = e.discs[j];
				parts = d[1];
				for (k = 0; k <= parts.length - 1; ++k) {
					p = parts[k];					
					if ((p) && (p[1] >= 1) && (p[3] != 'swap')) {
						usb_disk_list[partcount] = new Array();
						usb_disk_list[partcount][0] = p[2];
						usb_disk_list[partcount][1] = '分区 ' + p[0] + ' 已挂载至 '+p[2]+' (' + p[3]+ ' - ' + doScaleSize(p[6])+ ' 剩余可用空间, 全部空间 ' + doScaleSize(p[5]) + ')';
						partcount++;
					}
				}
			}
		}
	}
	list = [];
}


function verifyFields(focused, quiet)
{
	var ok = 1;

	var a = E('_f_mysql_enable').checked;
	var o = E('_f_mysql_check').checked;
	var u = E('_f_mysql_usb_enable').checked;
	var i = E('_f_mysql_init_priv').checked;
	var r = E('_f_mysql_init_rootpass').checked;
	var h = E('_f_mysql_allow_anyhost').checked;
	
	E('_f_mysql_check').disabled = !a;
	E('_mysql_check_time').disabled = !a || !o;
	E('_mysql_sleep').disabled = !a;
	E('_mysql_binary').disabled = !a;
	E('_f_mysql_init_priv').disabled = !a;
	E('_f_mysql_init_rootpass').disabled = !a;
	E('_mysql_username').disabled = true;
	E('_mysql_passwd').disabled = !a || !r;
	E('_mysql_server_custom').disabled = !a;
	E('_f_mysql_usb_enable').disabled = !a;
	E('_mysql_dlroot').disabled = !a || !u;
	E('_mysql_datadir').disabled = !a;
	E('_mysql_tmpdir').disabled = !a;
	E('_mysql_port').disabled = !a;
	E('_f_mysql_allow_anyhost').disabled = !a;
	E('_mysql_key_buffer').disabled = !a;
	E('_mysql_max_allowed_packet').disabled = !a;
	E('_mysql_thread_stack').disabled = !a;
	E('_mysql_thread_cache_size').disabled = !a;
	E('_mysql_table_open_cache').disabled = !a;
	E('_mysql_sort_buffer_size').disabled = !a;
	E('_mysql_read_buffer_size').disabled = !a;
	E('_mysql_query_cache_size').disabled = !a;
	E('_mysql_read_rnd_buffer_size').disabled = !a;
	E('_mysql_max_connections').disabled = !a;
	
	var p = (E('_mysql_binary').value == 'custom');
	elem.display('_mysql_binary_custom', p && a);

	elem.display('_mysql_dlroot', u && a);

	var x;
	if ( r && a ) x = '';
	else x = 'none';
        PR(E('_mysql_username')).style.display = x;
        PR(E('_mysql_passwd')).style.display = x;

	var e;
	e = E('_mysql_passwd');
        s = e.value.trim();
        if ( s == '' ) {
                ferror.set(e, 'Password can not be NULL value.', quiet);
		ok = 0;
        }

	return ok;
}

function save()
{
  if (verifyFields(null, 0)==0) return;
  var fom = E('_fom');
  
  fom.mysql_enable.value               = E('_f_mysql_enable').checked ? 1 : 0;
  fom.mysql_check.value                = E('_f_mysql_check').checked ? 1 : 0;
  fom.mysql_usb_enable.value           = E('_f_mysql_usb_enable').checked ? 1 : 0;
  fom.mysql_init_priv.value            = E('_f_mysql_init_priv').checked ? 1 : 0;
  fom.mysql_init_rootpass.value        = E('_f_mysql_init_rootpass').checked ? 1 : 0;
  fom.mysql_allow_anyhost.value        = E('_f_mysql_allow_anyhost').checked ? 1 : 0;
	
  if (fom.mysql_enable.value == 0) {
  	fom._service.value = 'mysql-stop';
  }
  else {
  	fom._service.value = 'mysql-restart'; 
  }
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
<input type='hidden' name='_nextpage' value='mysql.asp'>
<input type='hidden' name='_service' value='mysql-restart'>
<input type='hidden' name='mysql_enable'>
<input type='hidden' name='mysql_check'>
<input type='hidden' name='mysql_usb_enable'>
<input type='hidden' name='mysql_init_priv'>
<input type='hidden' name='mysql_init_rootpass'>
<input type='hidden' name='mysql_allow_anyhost'>

<div class='section-title'>基本设置<script>W(ams_link);</script></div>
<div class='section' id='config-section'>
<script type='text/javascript'>
	
refresh_usb_disk();

createFieldTable('', [
	{ title: '启用 MySQL 服务器', name: 'f_mysql_enable', type: 'checkbox', value: nvram.mysql_enable == 1, suffix: ' <small>*</small>' },
	{ title: 'MySQL 程序路径', multi: [
		{ name: 'mysql_binary', type: 'select', options: [
			['internal','Internal (/usr/bin)'],
			['optware','Optware (/opt/bin)'],
			['custom','自定义'] ], value: nvram.mysql_binary, suffix: ' <small>*</small> ' },
		{ name: 'mysql_binary_custom', type: 'text', maxlen: 40, size: 40, value: nvram.mysql_binary_custom , suffix: ' <small>不包括 "/mysqld"</small>' }
	] },
	{ title: '保持连接', name: 'f_mysql_check', type: 'checkbox', value: nvram.mysql_check == 1, suffix: ' <small>*</small>' },
	{ title: '检查连接间隔', indent: 2, name: 'mysql_check_time', type: 'text', maxlen: 5, size: 7, value: nvram.mysql_check_time, suffix: ' <small>分 (范围: 1 - 55; 默认: 1)</small>' },
	{ title: '启动延迟', name: 'mysql_sleep', type: 'text', maxlen: 5, size: 7, value: nvram.mysql_sleep, suffix: ' <small>秒 (范围: 1 - 60; 默认: 2)</small>' },
	{ title: 'MySQL 监听端口', name: 'mysql_port', type: 'text', maxlen: 5, size: 7, value: nvram.mysql_port, suffix: ' <small> 默认: 3306</small>' },
	{ title: '允许任何主机连接', name: 'f_mysql_allow_anyhost', type: 'checkbox', value: nvram.mysql_allow_anyhost == 1, suffix: ' <small>允许任何主机连接数据库服务器.</small>' },
	{ title: '重新初始化权限表', name: 'f_mysql_init_priv', type: 'checkbox', value: nvram.mysql_init_priv== 1, suffix: ' <small>如勾选, 权限表将被 mysql_install_db 重新初始化.</small>' },
	{ title: '重新初始化 root 密码', name: 'f_mysql_init_rootpass', type: 'checkbox', value: nvram.mysql_init_rootpass == 1, suffix: ' <small>如勾选, root 密码将被重新初始化.</small>' },
	{ title: 'root 用户名', name: 'mysql_username', type: 'text', maxlen: 32, size: 16, value: nvram.mysql_username, suffix: ' <small>服务器管理员用户名.(默认: root)</small>' },
	{ title: 'root 密码', name: 'mysql_passwd', type: 'password', maxlen: 32, size: 16, peekaboo: 1, value: nvram.mysql_passwd, suffix: ' <small>不允许留空.(默认: admin)</small>' },
	{ title: '启用 USB 分区', multi: [
		{ name: 'f_mysql_usb_enable', type: 'checkbox', value: nvram.mysql_usb_enable == 1, suffix: '  ' },
		{ name: 'mysql_dlroot', type: 'select', options: usb_disk_list, value: nvram.mysql_dlroot, suffix: ' '} ] },
	{ title: '数据目录.', indent: 2, name: 'mysql_datadir', type: 'text', maxlen: 50, size: 40, value: nvram.mysql_datadir, suffix: ' <small>已挂载分区下的目录名.</small>' },
	{ title: '临时目录.', indent: 2, name: 'mysql_tmpdir', type: 'text', maxlen: 50, size: 40, value: nvram.mysql_tmpdir, suffix: ' <small>已挂载分区下的目录名.</small>' }
]);
</script>
	<ul>
		<li><b>启用 MySQL 服务器</b> - 注意! - 如果你的路由器只有 32MB 内存, 你必须使用 swap 分区.
		<li><b>MySQL MySQL 程序路径</b> - 包含有 mysqld 等可执行文件的目录路径，请不要包括可执行文件名 "/mysqld"
		<li><b>保持连接</b> - 如果启用, mysqld 将会按照指定的频率被检查，并且崩溃后会被自动重启.
		<li><b>数据目录和临时目录.</b> - 警告! 请勿使用 NAND 闪存作为数据目录或临时目录.
	</ul>
</div>
</div>

<div class='section-title'>高级设置</div>
<div class='section' id='config-section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '索引缓冲区', name: 'mysql_key_buffer', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_key_buffer, suffix: ' <small>MB (范围: 1 - 1024; 默认: 8)</small>' },
	{ title: '最大允许插入封包大小', name: 'mysql_max_allowed_packet', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_max_allowed_packet, suffix: ' <small>MB (范围: 1 - 1024; 默认: 4)</small>' },
	{ title: '线程堆栈', name: 'mysql_thread_stack', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_thread_stack, suffix: ' <small>KB (范围: 1 - 1024000; 默认: 192)</small>' },
	{ title: '线程缓存大小', name: 'mysql_thread_cache_size', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_thread_cache_size, suffix: ' <small>(范围: 1 - 999999; 默认: 8)</small>' },
	{ title: '表打开时的缓存', name: 'mysql_table_open_cache', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_table_open_cache, suffix: ' <small>(范围: 1 - 999999; 默认: 4)</small>' },
	{ title: '查询缓存大小', name: 'mysql_query_cache_size', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_query_cache_size, suffix: ' <small>MB (范围: 0 - 1024; 默认: 16)</small>' },
	{ title: '排序缓冲区大小', name: 'mysql_sort_buffer_size', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_sort_buffer_size, suffix: ' <small>KB (范围: 0 - 1024000; 默认: 128)</small>' },
	{ title: '读取缓冲区大小', name: 'mysql_read_buffer_size', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_read_buffer_size, suffix: ' <small>KB (范围: 0 - 1024000; 默认: 128)</small>' },
	{ title: '读取边缘缓冲区大小', name: 'mysql_read_rnd_buffer_size', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_read_rnd_buffer_size, suffix: ' <small>KB (范围: 1 - 1024000; 默认: 256)</small>' },
	{ title: '最大连接数', name: 'mysql_max_connections', type: 'text', maxlen: 10, size: 10, value: nvram.mysql_max_connections, suffix: ' <small>(范围: 0 - 999999; 默认: 1000)</small>' },
	{ title: 'MySQL 服务器自定义配置.', name: 'mysql_server_custom', type: 'textarea', value: nvram.mysql_server_custom }
]);
</script>
	<ul>
		<li><b>MySQL 服务器自定义配置.</b> - 输入:  参数=值   如.  connect_timeout=10
	</ul>
</div>
</div>
</form>
</div>
</td></tr>
<tr><td id='footer' colspan=2>
 <form>
 <span id='footer-msg'></span>
 <input type='button' value='保存设置' id='save-button' onclick='save()'>
 <input type='button' value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
 </form>
</div>
</td></tr>
</table>
<script type='text/javascript'>verifyFields(null, 1);</script>
</body>
</html>
