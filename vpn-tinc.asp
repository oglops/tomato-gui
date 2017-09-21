<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	Tinc Web GUI
	Copyright (C) 2014 Lance Fredrickson
	lancethepants@gmail.com

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] VPN 设置: Tinc Mesh VPN</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>

#th-grid .co1 {
	width: 10%;
	text-align: center;
}
#th-grid .co2 {
	width: 17%;
}
#th-grid .co3 {
	width: 29%;
}
#th-grid .co4 {
	width: 10%;
}
#th-grid .co5 {
	width: 14%;
}
#th-grid .co6 {
	width: 20%;
}

textarea
{
	width: 98%;
	height: 10em;
}
</style>


<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("tinc_wanup,tinc_name,tinc_devicetype,tinc_mode,tinc_vpn_netmask,tinc_private_rsa,tinc_private_ed25519,tinc_custom,tinc_hosts,tinc_firewall,tinc_manual_firewall,tinc_manual_tinc_up,tinc_tinc_up,tinc_tinc_down,tinc_host_up,tinc_host_down,tinc_subnet_up,tinc_subnet_down"); %>

var tinc_compression = [['0','0 - 无'],['1','1 - 快速 zlib'],['2','2'],['3','3'],['4','4'],['5','5'],['6','6'],['7','7'],['8','8'],['9','9 - 最好 zlib'],['10','10 - 快速 lzo'],['11','11 - 最好 lzo']];
var th = new TomatoGrid();
var cmd = null;
var cmdresult = '';

tabs = [['config', '配置'],['hosts', '主机'],['scripts', '脚本'],['keys', '生成密钥'],['status', '状态']];
changed = 0;
tincup = parseInt ('<% psup("tincd"); %>');

th.setup = function() {
	this.init('th-grid', '', 50, [
		{ type: 'checkbox' },
		{ type: 'text', maxlen: 30 },
		{ type: 'text', maxlen: 100 },
		{ type: 'text', maxlen: 5 },
		{ type: 'select', options: tinc_compression },
		{ type: 'text', maxlen: 20 },
		{ type: 'textarea', proxy: "_host_rsa_key" },
		{ type: 'textarea', proxy: "_host_ed25519_key" },
		{ type: 'textarea', proxy: "_host_custom" }
		]);
	this.headerSet(['连接至', '名称', '地址', '端口', '压缩', '子网']);
	var nv = nvram.tinc_hosts.split('>');
	for (var i = 0; i < nv.length; ++i) {
		var t = nv[i].split('<');
		if (t.length == 9){
			t[0] *= 1;
			this.insertData(-1, t);
		}
	}
	th.showNewEditor();
}

th.dataToView = function(data) {
	return [(data[0] != '0') ? 'On' : '', data[1], data[2], data[3], data[4] ,data[5] ];
}

th.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	return [f[0].checked ? 1 : 0, f[1].value, f[2].value, f[3].value, f[4].value, f[5].value, E('_host_rsa_key').value, E('_host_ed25519_key').value, E('_host_custom').value ];
}


th.resetNewEditor = function() {
	var f = fields.getAll(this.newEditor);
	f[0].checked = 0;
	f[1].value = '';
	f[2].value = '';
	f[3].value = '';
	f[4].selectedIndex = 0;
	f[5].value = '';
	E('_host_rsa_key').value = '';
	E('_host_ed25519_key').value = '';
	E('_host_custom').value = '';
	ferror.clearAll(fields.getAll(this.newEditor));
	ferror.clear(E('_host_ed25519_key'));
}

th.verifyFields = function(row, quiet) {

	var f = fields.getAll(row);

	if (f[1].value == "") {
		ferror.set(f[1], "必须有主机名称.", quiet); return 0 ; }
	else {  ferror.clear(f[1]) }

	if (f[0].checked && f[2].value == "") {
		ferror.set(f[2], "'连接至'启用时必须提供地址.", quiet); return 0 ; }
	else {  ferror.clear(f[2]) }

	if (!f[3].value == "" ) {
		if (!v_port(f[3], quiet)) return 0 ;
	}

	if(E('_tinc_devicetype').value == 'tun'){
		if ((!v_subnet(f[5], 1)) && (!v_ip(f[5], 1))) {
			ferror.set(f[5], "无效的子网或IP地址.", quiet); return 0 ; }
		else {  ferror.clear(f[5]) }
	}
	else if (E('_tinc_devicetype').value == 'tap'){
		if (f[5].value != '') {
			ferror.set(f[5], "使用TAP接口类型时子网将被留空.", quiet); return 0 ; }
		else {  ferror.clear(f[5]) }
	}

	if (E('_host_ed25519_key').value == "") {
		ferror.set(E('_host_ed25519_key'), "Ed25519 公钥必须填写.", quiet); return 0 ; }
	else {  ferror.clear(E('_host_ed25519_key')) }

	return 1;
}

function verifyFields(focused, quiet)
{
	if (focused)
	{
		changed = 1;
	}

	// Visibility Changes
	var vis = {
		_tinc_mode: 1,
		_tinc_vpn_netmask: 1,
	};

	switch (E('_tinc_devicetype').value) {
		case 'tun':
			vis._tinc_mode = 0;
			vis._tinc_vpn_netmask = 1 ;
		break;
		case 'tap':
			vis._tinc_mode = 1;
			vis._tinc_vpn_netmask = 0 ;
		break;
	}

	switch(E('_tinc_manual_tinc_up').value) {
		case '0' :
			E('_tinc_tinc_up').disabled = 1 ;
		break;
		case '1' :
			E('_tinc_tinc_up').disabled = 0 ;
		break;
	}

	switch(E('_tinc_manual_firewall').value) {
		case '0' :
			E('_tinc_firewall').disabled = 1 ;
		break;
		default :
			E('_tinc_firewall').disabled = 0 ;
		break;
        }

	for (a in vis) {
		b = E(a);
		c = vis[a];
		b.disabled = (c != 1);
		PR(b).style.display = c ? '' : 'none';
	}

	E('edges').disabled = !tincup;
	E('connections').disabled = !tincup;
	E('subnets').disabled = !tincup;
	E('nodes').disabled = !tincup;
	E('info').disabled = !tincup;
	E('hostselect').disabled = !tincup;

	// Element Verification
	if (E('_tinc_name').value == "" && E('_f_tinc_wanup').checked) {
		ferror.set(E('_tinc_name'), "'同WAN一起启动'启用时主机名称必须填写.", quiet); return 0 ; }
	else {  ferror.clear(E('_tinc_name')) }

	if (E('_tinc_private_ed25519').value == "" && E('_tinc_custom').value == "" && E('_f_tinc_wanup').checked) {
		ferror.set(E('_tinc_private_ed25519'), "'同WAN一起启动'启用时 Ed25519 私钥必须填写.", quiet); return 0 ; }
	else {  ferror.clear(E('_tinc_private_ed25519')) }

	if (!v_netmask('_tinc_vpn_netmask', quiet)) return 0;

	if (!E('_host_ed25519_key').value == "") {
		ferror.clear(E('_host_ed25519_key')) }

	var hostdefined = false;
	var hosts = th.getAllData();
	for (var i = 0; i < hosts.length; ++i) {
		if(hosts[i][1] == E('_tinc_name').value){
			hostdefined = true;
			break;
		}
	}

	if (!hostdefined && E('_f_tinc_wanup').checked) {
		ferror.set(E('_tinc_name'), "'同WAN一起启动'启用时主机名称 \"" + E('_tinc_name').value + "\" 必须被定义在主机选项中.", quiet); return 0 ; }
	else {  ferror.clear(E('_tinc_name')) };

	return 1;
}

function escapeText(s)
{
	function esc(c) {
		return '&#' + c.charCodeAt(0) + ';';
	}
	return s.replace(/[&"'<>]/g, esc).replace(/\n/g, ' <br>').replace(/ /g, '&nbsp;');
}

function spin(x,which)
{
	E(which).style.visibility = x ? 'visible' : 'hidden';
	if (!x) cmd = null;
}

// Borrowed from http://snipplr.com/view/14074/
String.prototype.between = function(prefix, suffix) {
	s = this;
	var i = s.indexOf(prefix);
	if (i >= 0) {
		s = s.substring(i + prefix.length);
	}
	else {
		return '';
	}
	if (suffix) {
		i = s.indexOf(suffix);
		if (i >= 0) {
			s = s.substring(0, i);
		}
		else {
			return '';
		}
	}
	return s;
}

function displayKeys()
{
	E('_rsa_private_key').value = "-----BEGIN RSA PRIVATE KEY-----\n" + cmdresult. between('-----BEGIN RSA PRIVATE KEY-----\n','\n-----END RSA PRIVATE KEY-----') + "\n-----END RSA PRIVATE KEY-----";
	E('_rsa_public_key').value = "-----BEGIN RSA PUBLIC KEY-----\n" + cmdresult. between('-----BEGIN RSA PUBLIC KEY-----\n','\n-----END RSA PUBLIC KEY-----') + "\n-----END RSA PUBLIC KEY-----";
	E('_ed25519_private_key').value = "-----BEGIN ED25519 PRIVATE KEY-----\n" + cmdresult. between('-----BEGIN ED25519 PRIVATE KEY-----\n','\n-----END ED25519 PRIVATE KEY-----') + "\n-----END ED25519 PRIVATE KEY-----";
	E('_ed25519_public_key').value = cmdresult. between('-----END ED25519 PRIVATE KEY-----\n','\n');

	cmdresult = '';
	spin(0,'generateWait');
	E('execb').disabled = 0;
}

function generateKeys()
{
	E('execb').disabled = 1;
	spin(1,'generateWait');

	E('_rsa_private_key').value = "";
	E('_rsa_public_key').value = "";
	E('_ed25519_private_key').value = "";
	E('_ed25519_public_key').value = "";

	cmd = new XmlHttp();
	cmd.onCompleted = function(text, xml) {
		eval(text);
		displayKeys();
	}
	cmd.onError = function(x) {
		cmdresult = 'ERROR: ' + x;
		displayKeys();
	}

	var commands = "/bin/rm -rf /etc/keys \n\
		/bin/mkdir /etc/keys \n\
		/bin/echo -e '\n\n\n\n' | /usr/sbin/tinc -c /etc/keys generate-keys \n\
		/bin/cat /etc/keys/rsa_key.priv \n\
		/bin/cat /etc/keys/rsa_key.pub \n\
		/bin/cat /etc/keys/ed25519_key.priv \n\
		/bin/cat /etc/keys/ed25519_key.pub";

	cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(commands.replace(/\r/g, '')));

}

function displayStatus()
{
	E('result').innerHTML = '<tt>' + escapeText(cmdresult) + '</tt>';
	cmdresult = '';
	spin(0,'statusWait');
}

function updateStatus(type)
{
	E('result').innerHTML = '';
	spin(1,'statusWait');

	cmd = new XmlHttp();
	cmd.onCompleted = function(text, xml) {
		eval(text);
		displayStatus();
	}
	cmd.onError = function(x) {
		cmdresult = 'ERROR: ' + x;
		displayStatus();
	}

	if(type != "info"){
		var commands = "/usr/sbin/tinc dump " + type + "\n";
	}
	else
	{
		var selects = document.getElementById("hostselect");
		var commands = "/usr/sbin/tinc " + type + " " + selects.options[selects.selectedIndex].text + "\n";
	}

	cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(commands.replace(/\r/g, '')));
	updateNodes();
}

function displayNodes()
{

	var hostselect=document.getElementById("hostselect")
	var selected = hostselect.value;

	while(hostselect.firstChild){
		hostselect.removeChild(hostselect.firstChild);
	}

	var hosts = cmdresult.split("\n");

	for (var i = 0; i < hosts.length; ++i)
	{
		if (hosts[i] != ''){
			hostselect.options[hostselect.options.length]=new Option(hosts[i],hosts[i]);
			if(hosts[i] == selected){
				hostselect.value = selected;
			}
		}
	}

	cmdresult = '';
}

function updateNodes()
{

	if (tincup)
	{
		cmd = new XmlHttp();
		cmd.onCompleted = function(text, xml) {
			eval(text);
			displayNodes();
		}
		cmd.onError = function(x) {
			cmdresult = 'ERROR: ' + x;
			displayNodes();
		}

		var commands = "/usr/sbin/tinc dump nodes | /bin/busybox awk '{print $1}'";
		cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(commands.replace(/\r/g, '')));
	}
}

function displayVersion()
{
	E('version').innerHTML = "<small>Tinc " + escapeText(cmdresult) + "</small>";
        cmdresult = '';
}

function getVersion()
{
	cmd = new XmlHttp();
	cmd.onCompleted = function(text, xml) {
		eval(text);
		displayVersion();
	}
	cmd.onError = function(x) {
		cmdresult = 'ERROR: ' + x;
		displayVersion();
	}

	var commands = "/usr/sbin/tinc --version | /bin/busybox awk 'NR==1  {print $3}'";
	cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(commands.replace(/\r/g, '')));
}

function tabSelect(name)
{
	tgHideIcons();
	cookie.set('vpn_tinc_tab', name);
	tabHigh(name);

	for (var i = 0; i < tabs.length; ++i)
	{
		var on = (name == tabs[i][0]);
		elem.display(tabs[i][0] + '-tab', on);
	}
}


function toggle(service, isup)
{

	var data = th.getAllData();
	var s = '';
	for (var i = 0; i < data.length; ++i) {
		s += data[i].join('<') + '>';
	}

	if (nvram.tinc_hosts != s)
		changed = 1;

	if (changed) {
		if (!confirm("未保存的设置将会丢失. 继续?")) return;
	}

	E('_' + service + '_button1').disabled = true;
	E('_' + service + '_button2').disabled = true;
	E('_' + service + '_button3').disabled = true;
	E('_' + service + '_button4').disabled = true;
	form.submitHidden('/service.cgi', {
		_redirect: 'vpn-tinc.asp',
		_sleep: ((service == 'tinc') && (!isup)) ? '3' : '3',
		_service: service + (isup ? '-stop' : '-start')
	});
}

function save()
{
	if (!verifyFields(null, false)) return;
	if (th.isEditing()) return;

	var data = th.getAllData();
	var s = '';
	for (var i = 0; i < data.length; ++i) {
		s += data[i].join('<') + '>';
	}
	var fom = E('_fom');
	fom.tinc_hosts.value = s;
	fom.tinc_wanup.value = fom.f_tinc_wanup.checked ? 1 : 0;

	if ( tincup )
	{
		fom._service.value = 'tinc-restart';
	}

	changed = 0;

	form.submit(fom, 1);
}

function init()
{
	verifyFields(null, true);
	th.recolor();
	th.resetNewEditor();
	var c;
	if (((c = cookie.get('vpn_tinc_hosts_vis')) != null) && (c == '1')) toggleVisibility("hosts");
	getVersion();
	updateNodes();
}

function earlyInit()
{
	tabSelect(cookie.get('vpn_tinc_tab') || 'config');
}

function toggleVisibility(whichone) {
        if (E('sesdiv_' + whichone).style.display == '') {
                E('sesdiv_' + whichone).style.display = 'none';
                E('sesdiv_' + whichone + '_showhide').innerHTML = '(点击此处显示)';
                cookie.set('vpn_tinc_' + whichone + '_vis', 0);
        } else {
                E('sesdiv_' + whichone).style.display='';
                E('sesdiv_' + whichone + '_showhide').innerHTML = '(点击此处隐藏)';
                cookie.set('vpn_tinc_' + whichone + '_vis', 1);
        }
}

</script>
</head>

<body onload='init()'>
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

<input type='hidden' name='_nextpage' value='vpn-tinc.asp'>
<input type='hidden' name='_service' value=''>

<div class='section-title' style='float:right' id='version'></div>
<div class='section-title'>Tinc 配置</div>


<script type='text/javascript'>

	// -------- BEGIN CONFIG TAB -----------
	tabCreate.apply(this, tabs);

	t = "config";
	W('<div id=\''+t+'-tab\'>');
	W('<br>');
	W('<input type=\'hidden\' name=\'tinc_wanup\'>');
	W('<div class=\'section\'>');

	createFieldTable('', [
		{ title: '同 WAN 一起启动', name: 'f_tinc_wanup', type: 'checkbox', value: (nvram.tinc_wanup == 1) },
		{ title: '接口类型', name: 'tinc_devicetype', type: 'select', options: [['tun','TUN'],['tap','TAP']], value: nvram.tinc_devicetype },
		{ title: '形式', name: 'tinc_mode', type: 'select', options: [['switch','交换机'],['hub','集线器']], value: nvram.tinc_mode },
		{ title: 'VPN 子网掩码', name: 'tinc_vpn_netmask', type: 'text', maxlen: 15, size: 25, value: nvram.tinc_vpn_netmask,  suffix: ' <small>子网掩码将用于全部VPN网络.</small>' },
		{ title: '主机名称', name: 'tinc_name', type: 'text', maxlen: 30, size: 25, value: nvram.tinc_name, suffix: ' <small>必须被定义在\'主机\'选项中.</small>' },
		{ title: 'Ed25519 私钥', name: 'tinc_private_ed25519', type: 'textarea', value: nvram.tinc_private_ed25519 },
		{ title: 'RSA 私钥 *', name: 'tinc_private_rsa', type: 'textarea', value: nvram.tinc_private_rsa },
		{ title: '自定义', name: 'tinc_custom', type: 'textarea', value: nvram.tinc_custom }
	]);

	W('<small><b style=\'font-size: 1.5em\'>*</b> tinc1.0 节点仅需要创建传统的连接.</small>');
	W('</div>');
	W('<input type="button" value="' + (tincup ? '停止' : '启动') + ' " onclick="toggle(\'tinc\', tincup)" id="_tinc_button1">');
	W('</div>');
	// -------- END CONFIG TAB -----------


	// -------- BEGIN HOSTS TAB -----------
	t = "hosts";
	W('<div id=\''+t+'-tab\'>');
	W('<br>');
	W('<div class=\'section\'>');
	W('<input type=\'hidden\' name=\'tinc_hosts\'>');
	W('<table class=\'tomato-grid\' cellspacing=1 id=\'th-grid\'></table>');

	th.setup();

	createFieldTable('', [
		{ title: 'Ed25519 公钥', name: 'host_ed25519_key', type: 'textarea' },
		{ title: 'RSA 公钥 *', name: 'host_rsa_key', type: 'textarea' },
		{ title: '自定义', name: 'host_custom', type: 'textarea' }
	]);

	W('<small><b style=\'font-size: 1.5em\'>*</b> tinc1.0节点仅需要创建传统的连接.</small>');
	W('</div>');
	W('<input type="button" value="' + (tincup ? '停止' : '启动') + ' " onclick="toggle(\'tinc\', tincup)" id="_tinc_button2">');

	W('<br>');
	W('<br>');

	W('<div class=\'section-title\'>说明 <small><i><a href=\'javascript:toggleVisibility(\"hosts\");\'><span id=\'sesdiv_hosts_showhide\'>(点击此处显示)</span></a></i></small></div>');
	W('<div class=\'section\' id=\'sesdiv_hosts\' style=\'display:none\'>');
	W('<ul>');
	W('<li><b>连接至</b> - Tinc 将尝试创建一个元连接到主机.需要地址字段');
	W('<li><b>名称</b> - 主机的名称.必须填写主机名称.');
	W('<li><b>地址</b> <i>(可选)</i> - 解析得到的外部IP地址必须在主机能达到的范围内.');
	W('<li><b>端口</b> <i>(可选)</i> - 主机的监听端口.如果未指定则使用默认值(655).');
	W('<li><b>压缩</b> - UDP 包使用的压缩等级.使用合理的值 ');
	W('0 (关闭), 1 (快速 zlib) and any integer up to 9 (最好 zlib), 10 (快速 lzo) and 11 (最好 lzo).');
	W('<li><b>Subnet</b> - 主机提供的子网.');
	W('</ul>');
	W('</div>');

	W('</div>');

	// ---------- END HOSTS TAB ------------


	// -------- BEGIN SCRIPTS TAB -----------
	t = "scripts";
	W('<div id=\''+t+'-tab\'>');
	W('<br>');
	W('<div class=\'section\'>');

	createFieldTable('', [
		{ title: '防火墙规则', name: 'tinc_manual_firewall', type: 'select', options: [['0','自动'],['1','附加的'],['2','手动']], value: nvram.tinc_manual_firewall },
		{ title: '防火墙', name: 'tinc_firewall', type: 'textarea', value: nvram.tinc_firewall },
		{ title: 'tinc 启动模式', name: 'tinc_manual_tinc_up', type: 'select', options: [['0','自动'],['1','手动']], value: nvram.tinc_manual_tinc_up },
		{ title: 'tinc 启动', name: 'tinc_tinc_up', type: 'textarea', value: nvram.tinc_tinc_up },
		{ title: 'tinc 关闭', name: 'tinc_tinc_down', type: 'textarea', value: nvram.tinc_tinc_down },
		{ title: '主机启动', name: 'tinc_host_up', type: 'textarea', value: nvram.tinc_host_up },
		{ title: '主机关闭', name: 'tinc_host_down', type: 'textarea', value: nvram.tinc_host_down },
		{ title: '子网建立', name: 'tinc_subnet_up', type: 'textarea', value: nvram.tinc_subnet_up },
		{ title: '子网取消', name: 'tinc_subnet_down', type: 'textarea', value: nvram.tinc_subnet_down }
	]);

	W('</div>');
	W('<input type="button" value="' + (tincup ? '停止' : '启动') + ' " onclick="toggle(\'tinc\', tincup)" id="_tinc_button3">');
	W('</div>');
	// -------- END SCRIPTS TAB -----------

	// -------- BEGIN KEYS TAB -----------
	t = "keys";
	W('<div id=\''+t+'-tab\'>');
	W('<br>');
	W('<div class=\'section\'>');

	createFieldTable('', [
		{ title: 'Ed25519 私钥', name: 'ed25519_private_key', type: 'textarea', value: "" },
		{ title: 'Ed25519 公钥', name: 'ed25519_public_key', type: 'textarea', value: "" },
		{ title: 'RSA 私钥', name: 'rsa_private_key', type: 'textarea', value: "" },
		{ title: 'RSA 公钥', name: 'rsa_public_key', type: 'textarea', value: "" }
        ]);

	W('</div>');
	W('<div style=\'float:left\'><input type=\'button\' value=\'生成密钥\' onclick=\'generateKeys()\' id=\'execb\'></div>');
	W('<div style=\"visibility:hidden;text-align:right\" id=\"generateWait\">请稍等... <img src=\'spin.gif\' style=\"vertical-align:top\"></div>');
	W('</div>');

	// -------- END KEY TAB -----------

	// -------- BEGIN STATUS TAB -----------
	t = "status";

	W('<div id=\''+t+'-tab\'>');
	W('<br>');

	W('<div class=\'section\'>');
	W('Tinc 目前 '+(!tincup ? '未运行.' : '正在运行.')+' ');
	W('<input type="button" value="' + (tincup ? '停止' : '启动') + ' " onclick="toggle(\'tinc\', tincup)" id="_tinc_button4">');
	W('</div>');


	W('<div class=\'section\'>');

	W('<div style=\'float:left\'><input type=\'button\' value=\'边缘服务器\' onclick=\'updateStatus(\"edges\")\' id=\'edges\' style=\"width:85px\"></div>');
	W('<div style=\'float:left\'><input type=\'button\' value=\'子网\' onclick=\'updateStatus(\"subnets\")\' id=\'subnets\' style=\"width:85px\"></div>');
	W('<div style=\'float:left\'><input type=\'button\' value=\'连接\' onclick=\'updateStatus(\"connections\")\' id=\'connections\' style=\"width:85px\"></div>');
	W('<div style=\'float:left\'><input type=\'button\' value=\'节点\' onclick=\'updateStatus(\"nodes\")\' id=\'nodes\' style=\"width:85px\"></div>');
	W('<div style=\"visibility:hidden;text-align:right\" id=\"statusWait\">请稍等... <img src=\'spin.gif\' style=\"vertical-align:top\"></div>');

	W('</div>');

	W('<div class=\'section\'>');
	W('<input type=\'button\' value=\'信息\' onclick=\'updateStatus(\"info\")\' id=\'info\' style=\"width:85px\">');
	W('<select id=\'hostselect\' style=\"width:170px\"></select>');
	W('</div>');

	W('<pre id=\'result\'></pre>');

	W('</div>');
        // -------- END KEY TAB -----------

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
<script type='text/javascript'>
	earlyInit();
	verifyFields(null,true);
</script>
</body>
</html>
