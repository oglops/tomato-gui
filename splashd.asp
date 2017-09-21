<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2008 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	Copyright (C) 2011 Ofer Chen (Roadkill), Vicente Soriano (Victek)
	Adapted & Modified from Dual WAN Tomato Firmware.

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] 网页认证</title>
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
//	<% nvram("NC_enable,NC_Verbosity,NC_GatewayName,NC_GatewayPort,NC_ForcedRedirect,NC_HomePage,NC_DocumentRoot,NC_LoginTimeout,NC_IdleTimeout,NC_MaxMissedARP,NC_ExcludePorts,NC_IncludePorts,NC_AllowedWebHosts,NC_MACWhiteList,NC_BridgeLAN,lan_ifname,lan1_ifname,lan2_ifname,lan3_ifname"); %>
function fix(name)
{
 var i;
 if (((i = name.lastIndexOf('/')) > 0) || ((i = name.lastIndexOf('\\')) > 0))
 name = name.substring(i + 1, name.length);
 return name;
}

function uploadButton()
{
 var fom;
 var name;
 var i;
 name = fix(E('upload-name').value);
 name = name.toLowerCase();
 if ((name.length <= 5) || (name.substring(name.length - 5, name.length).toLowerCase() != '.html')) {
 alert('文件名错误, 正确的扩展名是 ".html".');
 return;
 }
 if (!confirm('你确定要上传文件' + name + '到路由器吗?')) return;
 E('upload-button').disabled = 1;
 fields.disableAll(E('config-section'), 1);
 fields.disableAll(E('footer'), 1);
 E('upload-form').submit();
}

function verifyFields(focused, quiet)
{
	var a = E('_f_NC_enable').checked;

	E('_NC_Verbosity').disabled = !a;
	E('_NC_GatewayName').disabled = !a;
	E('_NC_GatewayPort').disabled = !a;
	E('_f_NC_ForcedRedirect').disabled = !a;
	E('_NC_HomePage').disabled = !a;
	E('_NC_DocumentRoot').disabled = !a;
	E('_NC_LoginTimeout').disabled = !a;
	E('_NC_IdleTimeout').disabled = !a;
	E('_NC_MaxMissedARP').disabled = !a;
	E('_NC_ExcludePorts').disabled = !a;
	E('_NC_IncludePorts').disabled = !a;
	E('_NC_AllowedWebHosts').disabled = !a;
	E('_NC_MACWhiteList').disabled = !a;
	E('_NC_BridgeLAN').disabled = !a;

	var bridge = E('_NC_BridgeLAN');
	if(nvram.lan_ifname.length < 1)
		bridge.options[0].disabled=true;
	if(nvram.lan1_ifname.length < 1)
		bridge.options[1].disabled=true;
	if(nvram.lan2_ifname.length < 1)
		bridge.options[2].disabled=true;
	if(nvram.lan3_ifname.length < 1)
		bridge.options[3].disabled=true;

	if ( (E('_f_NC_ForcedRedirect').checked) && (!v_length('_NC_HomePage', quiet, 1, 255))) return 0;
	if (!v_length('_NC_GatewayName', quiet, 1, 255)) return 0;	
	if ( (E('_NC_IdleTimeout').value != '0') && (!v_range('_NC_IdleTimeout', quiet, 300))) return 0;
	return 1;
}

function save()
{
  if (verifyFields(null, 0)==0) return;
  var fom = E('_fom');
  fom.NC_enable.value = E('_f_NC_enable').checked ? 1 : 0;
  fom.NC_ForcedRedirect.value = E('_f_NC_ForcedRedirect').checked ? 1 : 0;

  // blank spaces with commas
  e = E('_NC_ExcludePorts');
  e.value = e.value.replace(/\,+/g, ' ');

  e = E('_NC_IncludePorts');
  e.value = e.value.replace(/\,+/g, ' ');

  e = E('_NC_AllowedWebHosts');
  e.value = e.value.replace(/\,+/g, ' ');
  
  e = E('_NC_MACWhiteList');
  e.value = e.value.replace(/\,+/g, ' ');

  fields.disableAll(E('upload-section'), 1);
  if (fom.NC_enable.value == 0) {
	fom._service.value = 'splashd-stop';
  }
	else {
	fom._service.value = 'splashd-restart';
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
<div class='section-title'>网页认证管理</div>
<div class='section' id='config-section'>
<form id='_fom' method='post' action='tomato.cgi'>
<input type='hidden' name='_nextpage' value='splashd.asp'>
<input type='hidden' name='_service' value='splashd-restart'>
<input type='hidden' name='NC_enable'>
<input type='hidden' name='NC_ForcedRedirect'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用功能', name: 'f_NC_enable', type: 'checkbox', value: nvram.NC_enable == '1' },
	{ title: '接口', multi: [
		{ name: 'NC_BridgeLAN', type: 'select', options: [
			['br0','LAN (br0)*'],
			['br1','LAN1 (br1)'],
			['br2','LAN2 (br2)'],
			['br3','LAN3 (br3)']
			], value: nvram.NC_BridgeLAN, suffix: ' <small>* 默认</small> ' } ] },
	{ title: '网关名称', name: 'NC_GatewayName', type: 'text', maxlen: 255, size: 34, value: nvram.NC_GatewayName },
	{ title: '认证网页跳转', name: 'f_NC_ForcedRedirect', type: 'checkbox', value: (nvram.NC_ForcedRedirect == '1') },
	{ title: '主页', name: 'NC_HomePage', type: 'text', maxlen: 255, size: 34, value: nvram.NC_HomePage },
	{ title: '欢迎HTML文件路径', name: 'NC_DocumentRoot', type: 'text', maxlen: 255, size: 20, value: nvram.NC_DocumentRoot, suffix: '<span>&nbsp;/splash.html</span>' },
	{ title: '登陆超时', name: 'NC_LoginTimeout', type: 'text', maxlen: 8, size: 4, value: nvram.NC_LoginTimeout, suffix: ' <small>秒</small>' },
	{ title: '空闲超时', name: 'NC_IdleTimeout', type: 'text', maxlen: 8, size: 4, value: nvram.NC_IdleTimeout, suffix: ' <small>秒 (0 - unlimited)</small>' },
	{ title: '最大丢失 ARP', name: 'NC_MaxMissedARP', type: 'text', maxlen: 10, size: 2, value: nvram.NC_MaxMissedARP },
	null,
	{ title: '日志信息级别', name: 'NC_Verbosity', type: 'text', maxlen: 10, size: 2, value: nvram.NC_Verbosity },
	{ title: '网关端口', name: 'NC_GatewayPort', type: 'text', maxlen: 10, size: 7, value: fixPort(nvram.NC_GatewayPort, 5280) },
	{ title: '无需被重定向的端口', name: 'NC_ExcludePorts', type: 'text', maxlen: 255, size: 34, value: nvram.NC_ExcludePorts },
	{ title: '需要被重定向的端口', name: 'NC_IncludePorts', type: 'text', maxlen: 255, size: 34, value: nvram.NC_IncludePorts },
	{ title: '无需认证的URL', name: 'NC_AllowedWebHosts', type: 'text', maxlen: 255, size: 34, value: nvram.NC_AllowedWebHosts },
	{ title: 'MAC 地址白名单', name: 'NC_MACWhiteList', type: 'text', maxlen: 255, size: 34, value: nvram.NC_MACWhiteList }
]);
</script>
</form>
</div>
<br>
<div class='section-title'>自定义 Splash 文件路径</div>
<div class='section' id='upload-section'>
 <form id='upload-form' method='post' action='uploadsplash.cgi?_http_id=<% nv(http_id); %>' encType='multipart/form-data'>
 <input type='file' size='40' id='upload-name' name='upload_name'>
 <input type='button' name='f_upload_button' id='upload-button' value='上传' onclick='uploadButton()'>
 <br>
 </form>
</div>
<hr>
<span style='color:blue'>
<b>网页认证. 用户指南.</b><br>
<br>
<b>*- 启用功能:</b> 勾选保存后计算机登陆Internet时路由器会显示欢迎页面.<br>
<b>*- 接口:</b> 选择上网认证监听的接口.<br>
<b>*- 网关名称:</b> 网关的名称会出现在欢迎页面.<br>
<b>*- 认证网页跳转:</b> 激活后,用户同意欢迎页面后会跳转至'主页'(详见下一条).<br>
<b>*- 主页:</b> 通过欢迎页面后出现的页面地址.<br>
<b>*- 欢迎 html 文件地址:</b> 欢迎页面文件的地址<br>
<b>*- 登陆超时:</b> 访问设备认证通过后欢迎页面重新出现(重新认证)的时间.默认为3600秒.(1小时).<br>
<b>*- 空闲超时:</b> 认证期限到期后不能再次接入认证的时间.默认值为0.<br>
<b>*- 最大丢失 ARP:</b> APR丢失达到最大允许数目后断开客户端的连接. 默认值为5<br>
<b>*- 网关端口:</b> 网页认证使用的为网页重新定向的端口.端口1到65534可用.默认5280端口.<br>
<b>*- 无需/需要被重定向的端口:</b> 设定的端口间用空格隔开,比如:25 110 4662 4672.为了避免冲突，请使用两项中最合适的那一项.<br>
<b>*- 无需认证的 URL:</b> 直接访问不需要弹出欢迎页面的URL. 多个URL之间请用空格隔开.例如:http://www.google.com http://www.google.es<br>
<b>*- MAC 地址白名单:</b> 无需认证的MAC地址.MAC地址之间请用空格隔开,例如:11:22:33:44:55:66 11:22:33:44:55:67<br>
<b>*- 自定义Splash文件路径:</b> 这里可以上传用来替换默认欢迎页面的自定义页面文件.<br><br>
</span>
<br>
<span style='color:red'>
<b> 注意: 访问时间到期后您需要重新进入欢迎页面来获得新的租期.请注意,到期后并不会有提醒, 但是您会与Internet断开连接.</b><br>
</span>
<br>
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
