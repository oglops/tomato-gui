<html><head><title>固件升级</title></head>
<body>
<h1>固件升级</h1>
<b>警告:</b>
<ul>
<li>当您按下升级按纽后，本页面并不显示更新进度，必须在更新固件完成后才会显示新的页面.
<li>固件升级完成大约需要3分钟. 在这期间请不要断开路由器或者浏览页面.
</ul>
<br>
<form name="firmware_upgrade" method="post" action="upgrade.cgi?<% nv(http_id) %>" encType="multipart/form-data">
<input type="hidden" name="submit_button" value="升级">

固件: <input type="file" name="file"> <input type="submit" value="升级">
</form>
</body></html>
