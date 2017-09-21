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
<title>[<% ident(); %>] IP 流量: 实时 IP 流量</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<% css(); %>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>
#txt {
	width: 550px;
	white-space: nowrap;
}
#bwm-controls {
	text-align: right;
	margin-right: 5px;
	margin-top: 5px;
	float: right;
	visibility: hidden;
}
ul.tabs a,
#tabs a {
	width: 140px;
	height: 12px;
	font-size: 9px;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript' src='bwm-common.js'></script>
<script type='text/javascript' src='interfaces.js'></script>

<script type='text/javascript'>
//	<% nvram("wan_ifname,wan_proto,wan_iface,wan2_ifname,wan2_proto,wan2_iface,wan3_ifname,wan3_proto,wan3_iface,wan4_ifname,wan4_proto,wan4_iface,lan_ifname,wl_ifname,web_svg,cstats_enable,cstats_colors,dhcpd_static,lan_ipaddr,lan_netmask,lan1_ipaddr,lan1_netmask,lan2_ipaddr,lan2_netmask,lan3_ipaddr,lan3_netmask,cstats_labels"); %>

//	<% devlist(); %>

var cprefix = 'ipt_';
var updateInt = 2;
var updateDiv = updateInt;
var updateMaxL = 300;
var updateReTotal = 1;
var prev = [];
var debugTime = 0;
var avgMode = 0;
var wdog = null;
var wdogWarn = null;
var cstats_busy = 0;

var ipt_addr_shown = [];
var ipt_addr_hidden = [];

hostnamecache = [];

var ref = new TomatoRefresh('update.cgi', 'exec=iptmon', updateInt);

ref.stop = function() {
	this.timer.start(1000);
}

ref.refresh = function(text) {
	var c, i, h, n, j, k, l;

	watchdogReset();

	++updating;
	try {
		iptmon = null;
		eval(text);

		n = (new Date()).getTime();
		if (this.timeExpect) {
			if (debugTime) E('dtime').innerHTML = (this.timeExpect - n) + ' ' + ((this.timeExpect + 1000*updateInt) - n);
			this.timeExpect += 1000*updateInt;
			this.refreshTime = MAX(this.timeExpect - n, 500);
		}
		else {
			this.timeExpect = n + 1000*updateInt;
		}

		for (i in iptmon) {
			c = iptmon[i];
			if ((p = prev[i]) != null) {
				h = speed_history[i];

				h.rx.splice(0, 1);
				h.rx.push((c.rx < p.rx) ? (c.rx + (0xFFFFFFFF - p.rx + 0x00000001)) : (c.rx - p.rx));

				h.tx.splice(0, 1);
				h.tx.push((c.tx < p.tx) ? (c.tx + (0xFFFFFFFF - p.tx + 0x00000001)) : (c.tx - p.tx));
			}
			else if (!speed_history[i]) {
				speed_history[i] = {};
				h = speed_history[i];
				h.rx = [];
				h.tx = [];
				for (j = 300; j > 0; --j) {
					h.rx.push(0);
					h.tx.push(0);
				}
				h.count = 0;
				h.hide = 0;
			}
			prev[i] = c;

			if ((ipt_addr_hidden.find(i) == -1) && (ipt_addr_shown.find(i) == -1) && (i.trim() != '')) {
				ipt_addr_shown.push(i);
				var option=document.createElement("option");
				option.value=i;
				if (hostnamecache[i] != null) {
					option.text = hostnamecache[i] + ' (' + i + ')';
				} else {
					option.text=i;
				}
				E('_f_ipt_addr_shown').add(option,null);
			}

			if (ipt_addr_hidden.find(i) != -1) {
				speed_history[i].hide = 1;
			} else {
				speed_history[i].hide = 0;
			}

			verifyFields(null,1);

		}
		loadData();
	}
	catch (ex) {
/* REMOVE-BEGIN
//			alert('ex=' + ex);
REMOVE-END */
	}
	--updating;
}

function watchdog() {
	watchdogReset();
	ref.stop();
	wdogWarn.style.display = '';
}

function watchdogReset() {
	if (wdog) clearTimeout(wdog)
	wdog = setTimeout(watchdog, 5000*updateInt);
	wdogWarn.style.display = 'none';
}

function init() {
	if (nvram.cstats_enable != '1') return;

	populateCache();

	speed_history = [];

	initCommon(2, 1, 1);

	wdogWarn = E('warnwd');
	watchdogReset();

	var c;
	if ((c = cookie.get('ipt_addr_hidden')) != null) {
		c = c.split(',');
		for (var i = 0; i < c.length; ++i) {
			if (c[i].trim() != '') {
				ipt_addr_hidden.push(c[i]);
				var option=document.createElement("option");
				option.value=c[i];
				if (hostnamecache[c[i]] != null) {
					option.text = hostnamecache[c[i]] + ' (' + c[i] + ')';
				} else {
					option.text = c[i];
				}
				E('_f_ipt_addr_hidden').add(option,null);
			}
		}
	}

	verifyFields(null,1);

	var theRules = document.styleSheets[document.styleSheets.length-1].cssRules;
	switch (nvram['cstats_labels']) {
		case '1':		// show hostnames only
			theRules[theRules.length-1].style.cssText = 'width: 140px;';
/* REMOVE-BEGIN */
//			document.styleSheets[2].deleteRule(theRules.length - 1);
/* REMOVE-END */
			break;
		case '2':		// show IPs only
			theRules[theRules.length-1].style.cssText = 'width: 140px;';
			break;
		case '0':		// show hostnames + IPs
		default:
/* REMOVE-BEGIN */
//			theRules[theRules.length-1].style.cssText = 'width: 140px; height: 12px; font-size: 9px;';
/* REMOVE-END */
			break;
	}

	ref.start();
}

function verifyFields(focused, quiet) {
	var changed_addr_hidden = 0;
	if (focused != null) {
		if (focused.id == '_f_ipt_addr_shown') {
			ipt_addr_shown.remove(focused.options[focused.selectedIndex].value);
			ipt_addr_hidden.push(focused.options[focused.selectedIndex].value);
			var option=document.createElement("option");
			option.text=focused.options[focused.selectedIndex].text;
			option.value=focused.options[focused.selectedIndex].value;
			E('_f_ipt_addr_shown').remove(focused.selectedIndex);
			E('_f_ipt_addr_shown').selectedIndex=0;
			E('_f_ipt_addr_hidden').add(option,null);
			changed_addr_hidden = 1;
		}

		if (focused.id == '_f_ipt_addr_hidden') {
			ipt_addr_hidden.remove(focused.options[focused.selectedIndex].value);
			ipt_addr_shown.push(focused.options[focused.selectedIndex].value);
			var option=document.createElement("option");
			option.text=focused.options[focused.selectedIndex].text;
			option.value=focused.options[focused.selectedIndex].value;
			E('_f_ipt_addr_hidden').remove(focused.selectedIndex);
			E('_f_ipt_addr_hidden').selectedIndex=0;
			E('_f_ipt_addr_shown').add(option,null);
			changed_addr_hidden = 1;
		}
		if (changed_addr_hidden == 1) {
			cookie.set('ipt_addr_hidden', ipt_addr_hidden.join(','), 1);
		}
	}

	if (E('_f_ipt_addr_hidden').length < 2) {
		E('_f_ipt_addr_hidden').disabled = 1;
	} else {
		E('_f_ipt_addr_hidden').disabled = 0;
	}

	if (E('_f_ipt_addr_shown').length < 2) {
		E('_f_ipt_addr_shown').disabled = 1;
	} else {
		E('_f_ipt_addr_shown').disabled = 0;
	}

	return 1;
}
</script>

</head>
<body onload='init()'>
<form>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->
<div id='cstats'>
	<div id='tab-area'></div>

	<script type='text/javascript'>
	if ((nvram.web_svg != '0') && (nvram.cstats_enable == '1')) {
		// without a div, Opera 9 moves svgdoc several pixels outside of <embed> (?)
		W("<div style='border-top:1px solid #f0f0f0;border-bottom:1px solid #f0f0f0;visibility:hidden;padding:0;margin:0' id='graph'><embed src='bwm-graph.svg?<% version(); %>' style='width:760px;height:300px;margin:0;padding:0' type='image/svg+xml' pluginspage='http://www.adobe.com/svg/viewer/install/'></embed></div>");
	}
	</script>

	<div id='bwm-controls'>
		<small>(<script type='text/javascript'>W(5*updateInt);</script> 分钟绘图窗口, <script type='text/javascript'>W(updateInt);</script> 秒钟间隔)</small><br>
		<br>
		平均:&nbsp;
			<a href='javascript:switchAvg(1)' id='avg1'>关闭</a>,
			<a href='javascript:switchAvg(2)' id='avg2'>2x</a>,
			<a href='javascript:switchAvg(4)' id='avg4'>4x</a>,
			<a href='javascript:switchAvg(6)' id='avg6'>6x</a>,
			<a href='javascript:switchAvg(8)' id='avg8'>8x</a><br>
		最大:&nbsp;
			<a href='javascript:switchScale(0)' id='scale0'>一致</a>,
			<a href='javascript:switchScale(1)' id='scale1'>每个</a><br>
		显示:&nbsp;
			<a href='javascript:switchDraw(0)' id='draw0'>填充</a>,
			<a href='javascript:switchDraw(1)' id='draw1'>实线</a><br>
		颜色:&nbsp; <a href='javascript:switchColor()' id='drawcolor'>-</a><br>
		<small><a href='javascript:switchColor(1)' id='drawrev'>[颜色反转]</a></small><br>

		<br><br>
		&nbsp; &raquo; <a href="admin-iptraffic.asp">设置</a>
	</div>

	<br><br>
	<table border=0 cellspacing=2 id='txt'>
	<tr>
		<td width='8%' align='right' valign='top'><b style='border-bottom:blue 1px solid' id='rx-name'>接收</b></td>
			<td width='15%' align='right' valign='top'><span id='rx-current'></span></td>
		<td width='8%' align='right' valign='top'><b>平均</b></td>
			<td width='15%' align='right' valign='top' id='rx-avg'></td>
		<td width='8%' align='right' valign='top'><b>最大</b></td>
			<td width='15%' align='right' valign='top' id='rx-max'></td>
		<td width='8%' align='right' valign='top'><b>合计</b></td>
			<td width='14%' align='right' valign='top' id='rx-total'></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td width='8%' align='right' valign='top'><b style='border-bottom:blue 1px solid' id='tx-name'>传送</b></td>
			<td width='15%' align='right' valign='top'><span id='tx-current'></span></td>
		<td width='8%' align='right' valign='top'><b>平均</b></td>
			<td width='15%' align='right' valign='top' id='tx-avg'></td>
		<td width='8%' align='right' valign='top'><b>最大</b></td>
			<td width='15%' align='right' valign='top' id='tx-max'></td>
		<td width='8%' align='right' valign='top'><b>合计</b></td>
			<td width='14%' align='right' valign='top' id='tx-total'></td>
		<td>&nbsp;</td>
	</tr>
	</table>

<!-- / / / -->

<br>

<div>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '当前显示的 IP', name: 'f_ipt_addr_shown', type: 'select', options: [[0,'选择']], suffix: ' <small>(点击/从列表中选取一个要隐藏的 IP)</small>' },
	{ title: '当前隐藏的 IP', name: 'f_ipt_addr_hidden', type: 'select', options: [[0,'选择']], suffix: ' <small>(点击/选择要重新显示的 IP)</small>' }
	]);
</script>
</div>

</div>
<br>

<!-- / / / -->

<script type='text/javascript'>
if (nvram.cstats_enable != '1') {
	W('<div class="note-disabled">IP 流量监控已关闭.</b><br><br><a href="admin-iptraffic.asp">启用 &raquo;</a><div>');
	E('cstats').style.display = 'none';
}else {
	W('<div class="note-warning" style="display:none" id="rbusy">cstat 程序没有响应或正忙,请几秒钟后尝试重新加载.</div>');
}
</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='warnwd' style='display:none'>警告:超时10秒钟,重新绘图中...&nbsp;</span>
	<span id='dtime'></span>
	<img src='spin.gif' id='refresh-spinner' onclick='javascript:debugTime=1'>

</td></tr>
</table>
</form>
</body>
</html>
