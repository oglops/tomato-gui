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
<title>[<% ident(); %>] 带宽监控：每月流量</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<% css(); %>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript' src='bwm-hist.js'></script>

<script type='text/javascript'>

//	<% nvram("wan_ifname,wan2_ifname,wan3_ifname,wan4_ifname,lan_ifname,rstats_enable"); %>
try {
//	<% bandwidth("monthly"); %>
}
catch (ex) {
	monthly_history = [];
}
rstats_busy = 0;
if (typeof(monthly_history) == 'undefined') {
	monthly_history = [];
	rstats_busy = 1;
}

function genData()
{
	var w, i, h;

	w = window.open('', 'tomato_data_m');
	w.document.writeln('<pre>');
	for (i = 0; i < monthly_history.length; ++i) {
		h = monthly_history[i];
		w.document.writeln([(((h[0] >> 16) & 0xFF) + 1900), (((h[0] >>> 8) & 0xFF) + 1), h[1], h[2]].join(','));
	}
	w.document.writeln('</pre>');
	w.document.close();
}

function save()
{
	cookie.set('monthly', scale, 31);
}

function redraw()
{
	var h;
	var grid;
	var rows;
	var yr, mo, da;

	rows = 0;
	block = '';
	gn = 0;

	grid = '<table class="bwmg" cellspacing="1">';
	grid += makeRow('header', '日期', '下载', '上传', '合计');

	for (i = 0; i < monthly_history.length; ++i) {
		h = monthly_history[i];
		yr = (((h[0] >> 16) & 0xFF) + 1900);
		mo = ((h[0] >>> 8) & 0xFF);

		grid += makeRow(((rows & 1) ? 'odd' : 'even'), ymText(yr, mo), rescale(h[1]), rescale(h[2]), rescale(h[1] + h[2]));
		++rows;
	}

	E('bwm-monthly-grid').innerHTML = grid + '</table>';
}

function init()
{
	var s;

	if (nvram.rstats_enable != '1') {
		E('refresh-button').disabled = 1;
		return;
	}

	if ((s = cookie.get('monthly')) != null) {
		if (s.match(/^([0-2])$/)) {
			E('scale').value = scale = RegExp.$1 * 1;
		}
	}

	initDate('ym');
	monthly_history.sort(cmpHist);
	redraw();
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

<div class='section-title'>WAN 每月流量</div>
<div id='bwm-monthly-grid' style='float:left'></div>
<div style="float:right;text-align:right">
<b>日期格式</b> <select onchange='changeDate(this, "ym")' id='dafm'><option value=0>年-月</option><option value=1>月-年</option><option value=2>月 年</option><option value=3>月.年</option></select><br>
<b>单位切换</b> <select onchange='changeScale(this)' id='scale'><option value=0>KB</option><option value=1>MB</option><option value=2 selected>GB</option></select><br>
<br>
&raquo; <a href="javascript:genData()">数据</a>
<br>
&raquo; <a href="admin-bwm.asp">设置</a>
<br><br><br>
</div>
<br>

<script type='text/javascript'>checkRstats();</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
<input type='button' value='刷新' onclick='reloadPage()'>
</td></tr>
</table>
</form>
</body>
</html>
