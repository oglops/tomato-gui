<html>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
</head>
<body style='background-color:#fff;font:13px sans-serif;color:#000' onload='setTimeout("go.submit()", 1200)'>

<div style='width:300px;padding:50px;background:#eee'>
<b>注销</b><br>
<hr size=1><br>
将要清除浏览器缓存的凭证:<br>
<br>
<b>Firefox, Internet Explorer, Opera, Safari</b><br>
- 将密码输入框清空.<br>
- 点击确定/登陆<br>
<br>
<b>Chrome</b><br>
- 选择取消.<br>
</div>

<form name='go' method='post' action='logout'>
<input type='hidden' name='_http_id' value='<% nv(http_id); %>'>
</form>
</body></html>
