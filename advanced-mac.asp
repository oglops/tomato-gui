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
<title>[<% ident(); %>] 高级设置:  MAC地址设置</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<% css(); %>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript'>

//	<% nvram("et0macaddr,wan_mac,wan2_mac,wan3_mac,wan4_mac,mwan_num,wl_macaddr,wl_hwaddr"); %>

function et0plus(plus)
{
	var mac = nvram.et0macaddr.split(':');
	if (mac.length != 6) return '';
	while (plus-- > 0) {
		for (var i = 5; i >= 3; --i) {
			var n = (parseInt(mac[i], 16) + 1) & 0xFF;
			mac[i] = n.hex(2);
			if (n != 0) break;
		}
	}
	return mac.join(':');
}

function defmac(which)
{
	if (which == 'wan')  return et0plus(1);
	if (which == 'wan2') return et0plus(17);
/* MULTIWAN-BEGIN */
	if (which == 'wan3') return et0plus(18);
	if (which == 'wan4') return et0plus(19);
/* MULTIWAN-END */
	else {	// wlX
/* REMOVE-BEGIN */
// trying to mimic the behaviour of static int set_wlmac(int idx, int unit, int subunit, void *param) in router/rc/network.c when we have wlX or wlX.X
/* REMOVE-END */
		var u, s, t, v;
		u = which.substr(2, which.length) * 1;
		s = parseInt(u.toString().substr(u.toString().indexOf(".") + 1, u.toString().length) * 1);
		u = parseInt(u.toString().substr(0, u.toString().indexOf(".") - 1) * 1);
		t = et0plus(2 + u + ((s > 0) ? (u * 0x10 + s) : 0)).split(':');
		v = (parseInt(t[0], 16) + ((s > 0) ? (u * 0x10 + 2) : 0) ) & 0xFF;
		t[0] = v.hex(2);
		return t.join(':');
	}
}

function bdefault(which)
{
	E('_f_' + which + '_hwaddr').value = defmac(which);
	verifyFields(null, true);
}

function brand(which)
{
	var mac;
	var i;

	mac = ['00'];
	for (i = 5; i > 0; --i)
		mac.push(Math.floor(Math.random() * 255).hex(2));
	E('_f_' + which + '_hwaddr').value = mac.join(':');
	verifyFields(null, true);
}

function bclone(which)
{
	E('_f_' + which + '_hwaddr').value = '<% compmac(); %>';
	verifyFields(null, true);
}

function findPrevMAC(mac, maxidx)
{
	for (var uidx = 1; uidx <= nvram.mwan_num; ++uidx){
		var u = (uidx>1) ? uidx : '';
		if (E('_f_wan'+u+'_hwaddr').value == mac) return 1;
	}

	for (var uidx = 0; uidx < maxidx; ++uidx) {
		if (E('_f_wl'+wl_fface(uidx)+'_hwaddr').value == mac) return 1;
	}

	return 0;
}

function verifyFields(focused, quiet)
{
	var uidx, u, a;

	for (uidx = 1; uidx <= nvram.mwan_num; ++uidx){
		u = (uidx>1) ? uidx : '';
		a = E('_f_wan'+u+'_hwaddr');
		if (!v_mac(a, quiet)) return 0;
	}

	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		u = wl_fface(uidx);
		a = E('_f_wl'+u+'_hwaddr');
		if (!v_mac(a, quiet)) return 0;

		if (findPrevMAC(a.value, uidx)) {
			ferror.set(a, '地址必须是唯一的', quiet);
			return 0;
		}
	}
	return 1;
}

function save()
{
	var u, uidx, v;

	if (!verifyFields(null, false)) return;
	if (!confirm("警告: 改变 MAC 地址有可能需要把联机到这台路由器的设备、计算机或调制解调器重新开机. 是否继续执行?")) return;

	var fom = E('_fom');
	for (uidx = 1; uidx <= nvram.mwan_num; ++uidx){
		u = (uidx>1) ? uidx : '';
		v = E('_f_wan'+u+'_hwaddr').value;
		fom['wan'+u+'_mac'].value= (v == defmac('wan'+u)) ? '' : v;
	}

	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		u = wl_fface(uidx);
		v = E('_f_wl'+u+'_hwaddr').value;
		E('_wl'+u+'_hwaddr').value = (v == defmac('wl' + u)) ? '' : v;
	}

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

<input type='hidden' name='_nextpage' value='advanced-mac.asp'>
<input type='hidden' name='_nextwait' value='10'>
<input type='hidden' name='_service' value='*'>

<input type='hidden' name='wan_mac'>
<input type='hidden' name='wan2_mac'>
/* MULTIWAN-BEGIN */
<input type='hidden' name='wan3_mac'>
<input type='hidden' name='wan4_mac'>
/*MULTIWAN-END */

<script type='text/javascript'>
for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
	var u = wl_fface(uidx);
	W('<input type=\'hidden\' id=\'_wl'+u+'_hwaddr\' name=\'wl'+u+'_hwaddr\'>');
}
</script>

<div class='section-title'>MAC 地址</div>
<div class='section'>
<script type='text/javascript'>

var f = [];
for (var uidx = 1; uidx <= nvram.mwan_num; ++uidx){
	var u = (uidx>1) ? uidx : '';
	f.push(
		{ title: 'WAN'+u+' 端口', indent: 1, name: 'f_wan'+u+'_hwaddr', type: 'text', maxlen: 17, size: 20,
			suffix: ' <input type="button" value="Default" onclick="bdefault(\'wan'+u+'\')"> <input type="button" value="Random" onclick="brand(\'wan'+u+'\')"> <input type="button" value="Clone PC" onclick="bclone(\'wan'+u+'\')">',
			value: nvram['wan'+u+'_mac'] || defmac('wan'+u) }
	);
}

for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
	var u = wl_fface(uidx);
	f.push(
		{ title: '无线端口 ' + ((wl_ifaces.length > 1) ? wl_ifaces[uidx][0] : ''), indent: 1, name: 'f_wl'+u+'_hwaddr', type: 'text', maxlen: 17, size: 20,
			suffix:' <input type="button" value="默认" onclick="bdefault(\'wl'+u+'\')"> <input type="button" value="随机" onclick="brand(\'wl'+u+'\')"> <input type="button" value="克隆 PC" onclick="bclone(\'wl'+u+'\')">',
			value: nvram['wl'+u+'_hwaddr'] || defmac('wl' + u) }
		);
}

createFieldTable('', f);

</script>
<br>
<table border=0 cellpadding=1>
	<tr><td>路由器 LAN 的 MAC 地址:</td><td><b><script type='text/javascript'>W(('<% nv('et0macaddr'); %>').toUpperCase());</script></b></td></tr>
	<tr><td>电脑的 MAC 地址:</td><td><b><script type='text/javascript'>W(('<% compmac(); %>').toUpperCase());</script></b></td></tr>
</table>
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
<script type='text/javascript'>verifyFields(null, 1);</script>
</body>
</html>
