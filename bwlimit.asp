<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2008 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	Copyright (C) 2011 Deon 'PrinceAMD' Thomas 
	rate limit & connection limit from Conanxu, 
	adapted by Victek, Shibby, PrinceAMD, Phykris

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] IP带宽限制</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->
<style type='text/css'>
#qosg-grid {
	width: 100%;
}
#qosg-grid .co1 {
	width: 30%;
}
#qosg-grid .co2,
#qosg-grid .co3,
#qosg-grid .co4,
#qosg-grid .co5,
#qosg-grid .co6,
#qosg-grid .co7,
#qosg-grid .co8 {
	width: 10%;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>
// <% nvram("new_qoslimit_enable,wan_qos_ibw,wan_qos_obw,new_qoslimit_rules,lan_ipaddr,lan_netmask,qosl_enable,qosl_dlr,qosl_dlc,qosl_ulr,qosl_ulc,qosl_udp,qosl_tcp,limit_br0_prio,limit_br1_enable,limit_br1_dlc,limit_br1_dlr,limit_br1_ulc,limit_br1_ulr,limit_br1_prio,limit_br2_enable,limit_br2_dlc,limit_br2_dlr,limit_br2_ulc,limit_br2_ulr,limit_br2_prio,limit_br3_enable,limit_br3_dlc,limit_br3_dlr,limit_br3_ulc,limit_br3_ulr,limit_br3_prio"); %>

var class_prio = [['0','最高'],['1','高'],['2','普通'],['3','低'],['4','最低']];
var class_tcp = [['0','不限制']];
var class_udp = [['0','不限制']];
for (var i = 1; i <= 100; ++i) {
	class_tcp.push([i*10, i*10+'']);
	class_udp.push([i, i + '/s']);
}
var qosg = new TomatoGrid();

qosg.setup = function() {
	this.init('qosg-grid', '', 80, [
		{ type: 'text', maxlen: 31 },
		{ type: 'text', maxlen: 6 },
		{ type: 'text', maxlen: 6 },
		{ type: 'text', maxlen: 6 },
		{ type: 'text', maxlen: 6 },
		{ type: 'select', options: class_prio },
		{ type: 'select', options: class_tcp },
		{ type: 'select', options: class_udp }]);
	this.headerSet(['IP 地址 | IP 范围 | MAC 地址', '最小下载带宽', '最大下载带宽', '最小上传带宽', '最大上传带宽', '优先级', 'TCP 限制', 'UDP 限制']);
	var qoslimitrules = nvram.new_qoslimit_rules.split('>');
	for (var i = 0; i < qoslimitrules.length; ++i) {
		var t = qoslimitrules[i].split('<');
		if (t.length == 8) this.insertData(-1, t);
	}
	this.showNewEditor();
	this.resetNewEditor();
}

qosg.dataToView = function(data) {
	return [data[0],data[1]+'kbps',data[2]+'kbps',data[3]+'kbps',data[4]+'kbps',class_prio[data[5]*1][1],class_tcp[data[6]*1/10][1],class_udp[data[7]*1][1]];
}

qosg.resetNewEditor = function() {
	var f, c, n;

	var f = fields.getAll(this.newEditor);
	ferror.clearAll(f);
	if ((c = cookie.get('addbwlimit')) != null) {
		cookie.set('addbwlimit', '', 0);
		c = c.split(',');
		if (c.length == 2) {
	f[0].value = c[0];
	f[1].value = '';
	f[2].value = '';
	f[3].value = '';
	f[4].value = '';
	f[5].selectedIndex = '2';
	f[6].selectedIndex = '0';
	f[7].selectedIndex = '0';
	return;
		}
	}

	f[0].value = '';
	f[1].value = '';
	f[2].value = '';
	f[3].value = '';
	f[4].value = '';
	f[5].selectedIndex = '2';
	f[6].selectedIndex = '0';
	f[7].selectedIndex = '0';
	
	}

qosg.exist = function(f, v)
{
	var data = this.getAllData();
	for (var i = 0; i < data.length; ++i) {
		if (data[i][f] == v) return true;
	}
	return false;
}

qosg.existID = function(id)
{
	return this.exist(0, id);
}

qosg.existIP = function(ip)
{
	if (ip == "0.0.0.0") return true;
	return this.exist(1, ip);
}

qosg.checkRate = function(rate)
{
	var s = parseInt(rate, 10);
	if( isNaN(s) || s <= 0 || a >= 100000 ) return true;
	return false;
}

qosg.checkRateCeil = function(rate, ceil)
{
	var r = parseInt(rate, 10);
	var c = parseInt(ceil, 10);
	if( r > c ) return true;
	return false;
}

qosg.verifyFields = function(row, quiet)
{
	var ok = 1;
	var f = fields.getAll(row);
	var s;

/*
	if (v_ip(f[0], quiet)) {
               if(this.existIP(f[0].value)) {
                       ferror.set(f[0], 'duplicate IP address', quiet);
			ok = 0;
		}
	}
*/
	if(v_macip(f[0], quiet, 0, nvram.lan_ipaddr, nvram.lan_netmask)) {
               if(this.existIP(f[0].value)) {
                    ferror.set(f[0], 'IP 或 MAC 地址重复', quiet);
			ok = 0;
		}
	}
     
	if( this.checkRate(f[1].value)) {
	        ferror.set(f[1], '最小下载带宽必须在 1 到 99999 之间', quiet);
		ok = 0;
	}

	if( this.checkRate(f[2].value)) {
		ferror.set(f[2], '最大下载带宽必须在 1 到 99999 之间', quiet);
		ok = 0;
	}

	if( this.checkRateCeil(f[1].value, f[2].value)) {
               ferror.set(f[2], '最大下载带宽必须大于最小下载带宽', quiet);
		ok = 0;
	}

	if( this.checkRate(f[3].value)) {
                ferror.set(f[3], '最小上传带宽必须在 1 到 99999 之间', quiet);
		ok = 0;
	}

	if( this.checkRate(f[4].value)) {
                ferror.set(f[4], '最大上传带宽必须在 1 到 99999 之间', quiet);
		ok = 0;
	}

	if( this.checkRateCeil(f[3].value, f[4].value)) {
                    ferror.set(f[4], '最大上传带宽必须大于最小上传带宽', quiet);
			ok = 0;
	}

	return ok;
}

function verifyFields(focused, quiet)
{
	var a = !E('_f_new_qoslimit_enable').checked;
	var b = !E('_f_qosl_enable').checked;
	var b1 = !E('_f_limit_br1_enable').checked;
	var b2 = !E('_f_limit_br2_enable').checked;
	var b3 = !E('_f_limit_br3_enable').checked;

	E('_wan_qos_ibw').disabled = a;
	E('_wan_qos_obw').disabled = a;
	E('_f_qosl_enable').disabled = a;
	E('_f_limit_br1_enable').disabled = a;
	E('_f_limit_br2_enable').disabled = a;
	E('_f_limit_br3_enable').disabled = a;

	E('_qosl_dlr').disabled = b || a;
	E('_qosl_dlc').disabled = b || a;
	E('_qosl_ulr').disabled = b || a;
	E('_qosl_ulc').disabled = b || a;
	E('_qosl_tcp').disabled = b || a;
	E('_qosl_udp').disabled = b || a;
	E('_limit_br0_prio').disabled = b || a;

	elem.display(PR('_wan_qos_ibw'), PR('_wan_qos_obw'), !a);
	elem.display(PR('_qosl_dlr'), PR('_qosl_dlc'), PR('_qosl_ulr'), PR('_qosl_ulc'), PR('_qosl_tcp'), PR('_qosl_udp'), PR('_limit_br0_prio'), !a && !b);

	E('_limit_br1_dlr').disabled = b1 || a;
	E('_limit_br1_dlc').disabled = b1 || a;
	E('_limit_br1_ulr').disabled = b1 || a;
	E('_limit_br1_ulc').disabled = b1 || a;
	E('_limit_br1_prio').disabled = b1 || a;
	elem.display(PR('_limit_br1_dlr'), PR('_limit_br1_dlc'), PR('_limit_br1_ulr'), PR('_limit_br1_ulc'), PR('_limit_br1_prio'), !a && !b1);

	E('_limit_br2_dlr').disabled = b2 || a;
	E('_limit_br2_dlc').disabled = b2 || a;
	E('_limit_br2_ulr').disabled = b2 || a;
	E('_limit_br2_ulc').disabled = b2 || a;
	E('_limit_br2_prio').disabled = b2 || a;
	elem.display(PR('_limit_br2_dlr'), PR('_limit_br2_dlc'), PR('_limit_br2_ulr'), PR('_limit_br2_ulc'), PR('_limit_br2_prio'), !a && !b2);

	E('_limit_br3_dlr').disabled = b3 || a;
	E('_limit_br3_dlc').disabled = b3 || a;
	E('_limit_br3_ulr').disabled = b3 || a;
	E('_limit_br3_ulc').disabled = b3 || a;
	E('_limit_br3_prio').disabled = b3 || a;
	elem.display(PR('_limit_br3_dlr'), PR('_limit_br3_dlc'), PR('_limit_br3_ulr'), PR('_limit_br3_ulc'), PR('_limit_br3_prio'), !a && !b3);

	return 1;
}

function save()
{
	if (qosg.isEditing()) return;

	var data = qosg.getAllData();
	var qoslimitrules = '';
	var i;

        if (data.length != 0) qoslimitrules += data[0].join('<'); 	
	for (i = 1; i < data.length; ++i) {
		qoslimitrules += '>' + data[i].join('<');
	}

	var fom = E('_fom');
	fom.new_qoslimit_enable.value = E('_f_new_qoslimit_enable').checked ? 1 : 0;
	fom.qosl_enable.value = E('_f_qosl_enable').checked ? 1 : 0;
	fom.limit_br1_enable.value = E('_f_limit_br1_enable').checked ? 1 : 0;
	fom.limit_br2_enable.value = E('_f_limit_br2_enable').checked ? 1 : 0;
	fom.limit_br3_enable.value = E('_f_limit_br3_enable').checked ? 1 : 0;
	fom.new_qoslimit_rules.value = qoslimitrules;
	form.submit(fom, 1);
}

function init()
{
	qosg.recolor();
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

<input type='hidden' name='_nextpage' value='bwlimit.asp'>
<input type='hidden' name='_nextwait' value='10'>
<input type='hidden' name='_service' value='qoslimit-restart'>

<input type='hidden' name='new_qoslimit_enable'>
<input type='hidden' name='new_qoslimit_rules'>
<input type='hidden' name='qosl_enable'>
<input type='hidden' name='limit_br1_enable'>
<input type='hidden' name='limit_br2_enable'>
<input type='hidden' name='limit_br3_enable'>


<div id='bwlimit'>

	<div class='section-title'>LAN (br0)带宽限制</div>
	<div class='section'>
		<script type='text/javascript'>
			createFieldTable('', [
			{ title: '启用限制', name: 'f_new_qoslimit_enable', type: 'checkbox', value: nvram.new_qoslimit_enable != '0' },
			{ title: '最大下载带宽 <br><small>(与QoS使用的相同)</small>', indent: 2, name: 'wan_qos_ibw', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.wan_qos_ibw },
			{ title: '最大上传带宽 <br><small>(与QoS使用的相同)</small>', indent: 2, name: 'wan_qos_obw', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.wan_qos_obw }
			]);
		</script>
		<br>
		<table class='tomato-grid' id='qosg-grid'></table>
		<div>
			<ul>
				<li><b>IP 地址 / IP 范围:</b>
				<li>例如: 192.168.1.5 指定一个 IP.
				<li>例如: 192.168.1.4-7 指定 IP 192.168.1.4 到 192.168.1.7
				<li>例如: 4-7 指定一个 IP 范围 .4 to .7
				<li><b>IP 范围内的设备共享带宽</b>
				<li><b>MAC 地址</b> 例如: 00:2E:3C:6A:22:D8
			</ul>
		</div>
	</div>
	
	<br>

	<div class='section-title'>默认类别 - LAN (br0)中未列出的 MAC / IP</div>
	<div class='section'>
		<script type='text/javascript'>
			createFieldTable('', [
				{ title: '启用', name: 'f_qosl_enable', type: 'checkbox', value: nvram.qosl_enable == '1'},
				{ title: '最小下载带宽', indent: 2, name: 'qosl_dlr', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.qosl_dlr },
				{ title: '最大下载带宽', indent: 2, name: 'qosl_dlc', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.qosl_dlc },
				{ title: '最小上传带宽', indent: 2, name: 'qosl_ulr', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.qosl_ulr },
				{ title: '最大上传带宽', indent: 2, name: 'qosl_ulc', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.qosl_ulc },
				{ title: '优先级', indent: 2, name: 'limit_br0_prio', type: 'select', options:
					[['0','最高'],['1','高'],['2','一般'],['3','低'],['4','最低']], value: nvram.limit_br0_prio },
				{ title: 'TCP 限制', indent: 2, name: 'qosl_tcp', type: 'select', options:
					[['0', '无限制'],
					['1', '1'],
					['2', '2'],
					['5', '5'],
					['10', '10'],
					['20', '20'],
					['50', '50'],
					['100', '100'],
					['200', '200'],
					['500', '500'],
					['1000', '1000']], value: nvram.qosl_tcp },
				{ title: 'UDP 限制', indent: 2, name: 'qosl_udp', type: 'select', options:
					[['0', '无限制'],
					['1', '1/s'],
					['2', '2/s'],
					['5', '5/s'],
					['10', '10/s'],
					['20', '20/s'],
					['50', '50/s'],
					['100', '100/s']], value: nvram.qosl_udp }
			]);
		</script>
		<div>
			<ul>
				<li><b>默认类别</b> - 不在列表中的 ip / MAC 将使用默认的 速度/限制 设置
				<li><b>br0中所有未列出的主机将共享带宽</b>
			</ul>
		</div>
	</div>

	<div class='section-title'>默认类别 - LAN1 (br1)</div>
	<div class='section'>
		<script type='text/javascript'>
			createFieldTable('', [
				{ title: '启用', name: 'f_limit_br1_enable', type: 'checkbox', value: nvram.limit_br1_enable == '1'},
				{ title: '最小下载带宽', indent: 2, name: 'limit_br1_dlr', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br1_dlr },
				{ title: '最大下载带宽', indent: 2, name: 'limit_br1_dlc', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br1_dlc },
				{ title: '最小上传带宽', indent: 2, name: 'limit_br1_ulr', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br1_ulr },
				{ title: '最大上传带宽', indent: 2, name: 'limit_br1_ulc', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br1_ulc },
				{ title: '优先级', indent: 2, name: 'limit_br1_prio', type: 'select', options:
					[['0','最高'],['1','高'],['2','普通'],['3','低'],['4','最低']], value: nvram.limit_br1_prio }
			]);
		</script>
		<div>
			<ul>
				<li><b>br1中的所有主机共享带宽.</b>
			</ul>
		</div>
	</div>

	<div class='section-title'>默认类别 - LAN2 (br2)</div>
	<div class='section'>
		<script type='text/javascript'>
			createFieldTable('', [
				{ title: '启用', name: 'f_limit_br2_enable', type: 'checkbox', value: nvram.limit_br2_enable == '1'},
				{ title: '最小下载带宽', indent: 2, name: 'limit_br2_dlr', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br2_dlr },
				{ title: '最大下载带宽', indent: 2, name: 'limit_br2_dlc', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br2_dlc },
				{ title: '最小上传带宽', indent: 2, name: 'limit_br2_ulr', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br2_ulr },
				{ title: '最大上传带宽', indent: 2, name: 'limit_br2_ulc', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br2_ulc },
				{ title: '优先级', indent: 2, name: 'limit_br2_prio', type: 'select', options:
					[['0','最高'],['1','高'],['2','普通'],['3','低'],['4','最低']], value: nvram.limit_br2_prio }
			]);
		</script>
		<div>
			<ul>
				<li><b>br2中的所有主机共享带宽.</b>
			</ul>
		</div>
	</div>

	<div class='section-title'>默认类别 - LAN3 (br3)</div>
	<div class='section'>
		<script type='text/javascript'>
			createFieldTable('', [
				{ title: '启用', name: 'f_limit_br3_enable', type: 'checkbox', value: nvram.limit_br3_enable == '1'},
				{ title: '最小下载带宽', indent: 2, name: 'limit_br3_dlr', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br3_dlr },
				{ title: '最大下载带宽', indent: 2, name: 'limit_br3_dlc', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br3_dlc },
				{ title: '最小上传带宽', indent: 2, name: 'limit_br3_ulr', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br3_ulr },
				{ title: '最大上传带宽', indent: 2, name: 'limit_br3_ulc', type: 'text', maxlen: 6, size: 8, suffix: ' <small>kbit/s</small>', value: nvram.limit_br3_ulc },
				{ title: '优先级', indent: 2, name: 'limit_br3_prio', type: 'select', options:
					[['0','最高'],['1','高'],['2','普通'],['3','低'],['4','最低']], value: nvram.limit_br3_prio }
			]);
		</script>
		<div>
			<ul>
				<li><b>br3中的所有主机共享带宽.</b>
			</ul>
		</div>
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
<script type='text/javascript'>qosg.setup(); verifyFields(null, 1);</script>
</body>
</html>
