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
<title>[<% ident(); %>] 系统管理: IP 流量监控</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<% css(); %>
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

//	<% nvram("cstats_enable,cstats_path,cstats_stime,cstats_offset,cstats_exclude,cstats_include,cstats_sshut,et0macaddr,cifs1,cifs2,jffs2_on,cstats_bak,cstats_all,cstats_labels"); %>

function fix(name)
{
	var i;
	if (((i = name.lastIndexOf('/')) > 0) || ((i = name.lastIndexOf('\\')) > 0))
		name = name.substring(i + 1, name.length);
	return name;
}

function backupNameChanged()
{
	if (location.href.match(/^(http.+?\/.+\/)/)) {
		E('backup-link').href = RegExp.$1 + 'ipt/' + fix(E('backup-name').value) + '.gz?_http_id=' + nvram.http_id;
	}
}

function backupButton()
{
	var name;

	name = fix(E('backup-name').value);
	if (name.length <= 1) {
		alert('不正确的文件名');
		return;
	}
	location.href = 'ipt/' + name + '.gz?_http_id=' + nvram.http_id;
}

function restoreButton()
{
	var fom;
	var name;
	var i;

	name = fix(E('restore-name').value);
	name = name.toLowerCase();
	if ((name.length <= 3) || (name.substring(name.length - 3, name.length).toLowerCase() != '.gz')) {
		alert('不正确的文件名. 正确的扩展名为 ".gz".');
		return;
	}
	if (!confirm('是否从 ' + name + '恢复?')) return;

	E('restore-button').disabled = 1;
	fields.disableAll(E('config-section'), 1);
	fields.disableAll(E('backup-section'), 1);
	fields.disableAll(E('footer'), 1);

	E('restore-form').submit();
}

function getPath()
{
	var s = E('_f_loc').value;
	return (s == '*user') ? E('_f_user').value : s;
}

function verifyFields(focused, quiet)
{
	var b, v;
	var path;
	var eLoc, eUser, eTime, eOfs;
	var bak;
	var eInc, eExc, eAll, eBak, eLab;

	eLoc = E('_f_loc');
	eUser = E('_f_user');
	eTime = E('_cstats_stime');
	eOfs = E('_cstats_offset');

	eInc = E('_cstats_include');
	eExc = E('_cstats_exclude');
	eAll = E('_f_all');
	eBak = E('_f_bak');

	eLab = E('_cstats_labels');

	b = !E('_f_cstats_enable').checked;
	eLoc.disabled = b;
	eUser.disabled = b;
	eTime.disabled = b;
	eOfs.disabled = b;
	eInc.disabled = b;
	eExc.disabled = b;
	eAll.disabled = b;
	eBak.disabled = b;
	eLab.disabled = b;
	E('_f_new').disabled = b;
	E('_f_sshut').disabled = b;
	E('backup-button').disabled = b;
	E('backup-name').disabled = b;
	E('restore-button').disabled = b;
	E('restore-name').disabled = b;
	ferror.clear(eLoc);
	ferror.clear(eUser);
	ferror.clear(eOfs);
	if (b) return 1;

	eInc.disabled = eAll.checked;

	path = getPath();
	E('newmsg').style.visibility = ((nvram.cstats_path != path) && (path != '*nvram') && (path != '')) ? 'visible' : 'hidden';

	bak = 0;
	v = eLoc.value;
	b = (v == '*user');
	elem.display(eUser, b);
	if (b) {
		if (!v_length(eUser, quiet, 2)) return 0;
		if (path.substr(0, 1) != '/') {
			ferror.set(eUser, '请从 / 根目录开始.', quiet);
			return 0;
		}
	}
	else if (v == '/jffs/') {
		if (nvram.jffs2_on != '1') {
			ferror.set(eLoc, 'JFFS2 未启用.', quiet);
			return 0;
		}
	}
	else if (v.match(/^\/cifs(1|2)\/$/)) {
		if (nvram['cifs' + RegExp.$1].substr(0, 1) != '1') {
			ferror.set(eLoc, 'CIFS #' + RegExp.$1 + ' 未启用.', quiet);
			return 0;
		}
	}
	else {
		bak = 1;
	}

	E('_f_bak').disabled = bak;

	return v_range(eOfs, quiet, 1, 31);
}

function save()
{
	var fom, path, en, e, aj;

	if (!verifyFields(null, false)) return;

	aj = 1;
	en = E('_f_cstats_enable').checked;
	fom = E('_fom');
	fom._service.value = 'cstats-restart';
	if (en) {
		path = getPath();
		if (((E('_cstats_stime').value * 1) <= 48) &&
			((path == '*nvram') || (path == '/jffs/'))) {
			if (!confirm('不建议对 NVRAM 或 JFFS2 进行频繁的存取，是否继续?')) return;
		}
		if ((nvram.cstats_path != path) && (fom.cstats_path.value != path) && (path != '') && (path != '*nvram') &&
			(path.substr(path.length - 1, 1) != '/')) {
			if (!confirm('注意: ' + path + ' 将会被视为一个文件. 如果这是一个目录，请使用 / 作为目录结尾. 是否继续?')) return;
		}
		fom.cstats_path.value = path;

		if (E('_f_new').checked) {
			fom._service.value = 'cstatsnew-restart';
			aj = 0;
		}
	}

	fom.cstats_path.disabled = !en;
	fom.cstats_enable.value = en ? 1 : 0;
	fom.cstats_sshut.value = E('_f_sshut').checked ? 1 : 0;
	fom.cstats_bak.value = E('_f_bak').checked ? 1 : 0;
	fom.cstats_all.value = E('_f_all').checked ? 1 : 0;

	e = E('_cstats_exclude');
	e.value = e.value.replace(/\s+/g, ',').replace(/,+/g, ',');

	e = E('_cstats_include');
	e.value = e.value.replace(/\s+/g, ',').replace(/,+/g, ',');

	fields.disableAll(E('backup-section'), 1);
	fields.disableAll(E('restore-section'), 1);
	form.submit(fom, aj);
	if (en) {
		fields.disableAll(E('backup-section'), 0);
		fields.disableAll(E('restore-section'), 0);
	}
}

function init()
{
	backupNameChanged();
}
</script>

</head>
<body onload="init()">
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<div class='section-title'>IP 流量监控设置</div>
<div class='section' id='config-section'>
<form id='_fom' method='post' action='tomato.cgi'>
<input type='hidden' name='_nextpage' value='admin-iptraffic.asp'>
<input type='hidden' name='_service' value='cstats-restart'>
<input type='hidden' name='cstats_enable'>
<input type='hidden' name='cstats_path'>
<input type='hidden' name='cstats_sshut'>
<input type='hidden' name='cstats_bak'>
<input type='hidden' name='cstats_all'>

<script type='text/javascript'>
switch (nvram.cstats_path) {
case '':
case '*nvram':
case '/jffs/':
case '/cifs1/':
case '/cifs2/':
	loc = nvram.cstats_path;
	break;
default:
	loc = '*user';
	break;
}
createFieldTable('', [
	{ title: '启用', name: 'f_cstats_enable', type: 'checkbox', value: nvram.cstats_enable == '1' },
	{ title: '历史数据保存位置', multi: [
/* REMOVE-BEGIN
//		{ name: 'f_loc', type: 'select', options: [['','RAM (临时)'],['*nvram','NVRAM'],['/jffs/','JFFS2'],['/cifs1/','CIFS 1'],['/cifs2/','CIFS 2'],['*user','自定义路径']], value: loc },
REMOVE-END */
		{ name: 'f_loc', type: 'select', options: [['','RAM (临时)'],['/jffs/','JFFS2'],['/cifs1/','CIFS 1'],['/cifs2/','CIFS 2'],['*user','自定义路径']], value: loc },
		{ name: 'f_user', type: 'text', maxlen: 48, size: 50, value: nvram.cstats_path }
	] },
	{ title: '保存频率', indent: 2, name: 'cstats_stime', type: 'select', value: nvram.cstats_stime, options: [
		[1,'每小时'],[2,'每2小时'],[3,'每3小时'],[4,'每4小时'],[5,'每5小时'],[6,'每6小时'],
		[9,'每9小时'],[12,'每12小时'],[24,'每天'],[48,'每两天'],[72,'每三天'],[96,'每四天'],
		[120,'每五天'],[144,'每六天'],[168,'每周']] },
	{ title: '关机时保存', indent: 2, name: 'f_sshut', type: 'checkbox', value: nvram.cstats_sshut == '1' },
	{ title: '创建新文件<br><small>(清除数据)</small>', indent: 2, name: 'f_new', type: 'checkbox', value: 0,
		suffix: ' &nbsp; <b id="newmsg" style="visibility:hidden"><small>(注意：如果这是一个新文件，则启用)</small></b>' },
	{ title: '创建备份', indent: 2, name: 'f_bak', type: 'checkbox', value: nvram.cstats_bak == '1' },
	{ title: '每月第一天为', name: 'cstats_offset', type: 'text', value: nvram.cstats_offset, maxlen: 2, size: 4 },
	{ title: '排除的 IP', name: 'cstats_exclude', type: 'text', value: nvram.cstats_exclude, maxlen: 512, size: 50, suffix: '&nbsp;<small>(多个用逗号分隔)</small>' },
	{ title: '包含的 IP', name: 'cstats_include', type: 'text', value: nvram.cstats_include, maxlen: 2048, size: 50, suffix: '&nbsp;<small>(多个用逗号分隔)</small>' },
	{ title: '启用自动发现', name: 'f_all', type: 'checkbox', value: nvram.cstats_all == '1', suffix: '&nbsp;<small>(自动发现新加入的 IP 如果有流量的立即开始监控)</small>' },
	{ title: '图形标签', name: 'cstats_labels', type: 'select', value: nvram.cstats_stime, options: [[0,'显示主机名和IP'],[1,'优先显示主机, 否则显示IP'],[2,'仅显示IP']], value: nvram.cstats_labels }
]);
</script>
</form>
</div>

<br>

<div class='section-title'>备份</div>
<div class='section' id='backup-section'>
	<form>
	<script type='text/javascript'>
	W("<input type='text' size='40' maxlength='64' id='backup-name' name='backup_name' onchange='backupNameChanged()' value='tomato_cstats_" + nvram.et0macaddr.replace(/:/g, '').toLowerCase() + "'>");
	</script>
	.gz &nbsp;
	<input type='button' name='f_backup_button' id='backup-button' onclick='backupButton()' value='备份'>
	</form>
	<a href='' id='backup-link'>点此下载</a>
</div>
<br>

<div class='section-title'>恢复</div>
<div class='section' id='restore-section'>
	<form id='restore-form' method='post' action='ipt/restore.cgi?_http_id=<% nv(http_id); %>' encType='multipart/form-data'>
		<input type='file' size='40' id='restore-name' name='restore_name'>
		<input type='button' name='f_restore_button' id='restore-button' value='恢复' onclick='restoreButton()'>
		<br>
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
<div></div>
</td></tr>
</table>
<script type='text/javascript'>verifyFields(null, 1);</script>
</body>
</html>
