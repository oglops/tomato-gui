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
<title>[<% ident(); %>] 端口转发: DMZ设置</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript' src='interfaces.js'></script>

<script type='text/javascript'>

//	<% nvram("dmz_enable,dmz_ipaddr,dmz_sip,dmz_ifname,dmz_ra,lan_ifname,lan1_ifname,lan2_ifname,lan3_ifname"); %>

var lipp = '<% lipp(); %>.';

function verifyFields(focused, quiet)
{
	var sip, dip, off;

	off = !E('_f_dmz_enable').checked;

	dip = E('_f_dmz_ipaddr')
	dip.disabled = off;

	sip = E('_f_dmz_sip');
	sip.disabled = off;

	sip = E('_f_dmz_ra');
	sip.disabled = off;

	var dif = E('_dmz_ifname');
	dif.disabled = off;
	if (dif.options[(dif.selectedIndex)].disabled) dif.selectedIndex = 0;

	if (off) {
		ferror.clearAll(dip, sip);
		return 1;
	}

	if (dip.value.indexOf('.') == -1) dip.value = lipp + dip.value;
	if (!v_ip(dip)) return 0;

	if ((sip.value.length) && (!v_iptaddr(sip, quiet, 15))) return 0;
	ferror.clear(sip);

	return 1;
}

function save()
{
	var fom;
	var en;
	var s;

	if (!verifyFields(null, false)) return;

	fom = E('_fom');
	en = fom.f_dmz_enable.checked;
	fom.dmz_enable.value = en ? 1 : 0;
	if (en) {
		// shorten it if possible to be more compatible with original
		s = fom.f_dmz_ipaddr.value;
		fom.dmz_ipaddr.value = (s.indexOf(lipp) == 0) ? s.replace(lipp, '') : s;
	}
	fom.dmz_sip.value = fom.f_dmz_sip.value.split(/\s*,\s*/).join(',');
	fom.dmz_ra.value = E('_f_dmz_ra').checked ? 1 : 0;
	form.submit(fom, 0);
}

function init() {
	var dif = E('_dmz_ifname');
	if(nvram.lan_ifname.length < 1)
		dif.options[0].disabled=true;
	if(nvram.lan1_ifname.length < 1)
		dif.options[1].disabled=true;
	if(nvram.lan2_ifname.length < 1)
		dif.options[2].disabled=true;
	if(nvram.lan3_ifname.length < 1)
		dif.options[3].disabled=true;
	if(nvram.dmz_enable == '1')
		verifyFields(null,true);
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

<input type='hidden' name='_nextpage' value='forward-dmz.asp'>
<input type='hidden' name='_service' value='firewall-restart'>

<input type='hidden' name='dmz_enable'>
<input type='hidden' name='dmz_ipaddr'>
<input type='hidden' name='dmz_sip'>
<input type='hidden' name='dmz_ra'>

<div class='section-title'>DMZ 设置</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用 DMZ', name: 'f_dmz_enable', type: 'checkbox', value: (nvram.dmz_enable == '1') },
	{ title: '目的地址', indent: 2, name: 'f_dmz_ipaddr', type: 'text', maxlen: 15, size: 17,
		value: (nvram.dmz_ipaddr.indexOf('.') != -1) ? nvram.dmz_ipaddr : (lipp + nvram.dmz_ipaddr) },
	{ title: '目标接口', indent: 2, name: 'dmz_ifname', type: 'select',
		options: [['br0','LAN (br0)'],['br1','LAN1  (br1)'],['br2','LAN2 (br2)'],['br3','LAN3 (br3)']], value: nvram.dmz_ifname },
	{ title: '外部IP限制', indent: 2, name: 'f_dmz_sip', type: 'text', maxlen: 512, size: 64,
		value: nvram.dmz_sip, suffix: '<br><small>("空白" 表示不限制,可单一IP或范围;例: "1.1.1.1", "1.1.1.0/24", "1.1.1.1 - 2.2.2.2" or "me.example.com")</small>' },
	null,
	{ title: '远程访问例外', indent: 2, name: 'f_dmz_ra', type: 'checkbox', value: (nvram.dmz_ra == '1'), suffix: ' &nbsp;<small>(重新定向到路由器的 SSH 和 HTTP(S) 远程访问端口)</small>' }
]);
</script>
</div>

<br>
<script type='text/javascript'>if (nvram.dmz_enable == '1') show_notice1('<% notice("iptables"); %>');</script>

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

