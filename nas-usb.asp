<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
Tomato GUI
USB Support - !!TB
For use with Tomato Firmware only.
No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] NAS: USB 支持</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>
textarea {
width: 98%;
height: 5em;
}
</style>
<style type='text/css'>
#dev-grid .co1 {
width: 10%;
}
#dev-grid .co2 {
width: 9%;
}
#dev-grid .co3 {
width: 65%;
}
#dev-grid .co4 {
width: 16%;
text-align: center;
}
#dev-grid .header {
text-align: left;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("usb_enable,usb_uhci,usb_ohci,usb_usb2,usb_mmc,usb_storage,usb_printer,usb_printer_bidirect,usb_automount,usb_fs_ext3,usb_fs_fat,usb_fs_ntfs,usb_fs_hfs,script_usbmount,script_usbumount,script_usbhotplug,idle_enable,usb_3g,usb_apcupsd"); %>
//	<% usbdevices(); %>
list = [];
var xob = null;
function _umountHost(host)
{
form.submitHidden('usbcmd.cgi', { remove: host });
}
function _mountHost(host)
{
form.submitHidden('usbcmd.cgi', { mount: host });
}
function _forceRefresh()
{
if (!ref.running) ref.once = 1;
ref.start();
}
function umountHost(a, host)
{
if (xob) return;
if ((xob = new XmlHttp()) == null) {
_umountHost(host);
return;
}
a = E(a);
	a.innerHTML = '请稍等...';

xob.onCompleted = function(text, xml) {
eval(text);
if (usb.length == 1) {
if (usb[0] != 0)
				ferror.set(a, 'USB 设备繁忙.请确认没有任何程序访问 USB 设备后重试.', 0);
}
xob = null;
_forceRefresh();
}
xob.onError = function() {
xob = null;
_forceRefresh();
}
xob.post('usbcmd.cgi', 'remove=' + host);
}
function mountHost(a, host)
{
if (xob) return;
if ((xob = new XmlHttp()) == null) {
_mountHost(host);
return;
}
a = E(a);
	a.innerHTML = '请稍等...';

xob.onCompleted = function(text, xml) {
eval(text);
if (usb.length == 1) {
if (usb[0] == 0)
				ferror.set(a, 'USB 设备挂载失败.请确认 USB 设备已正确插入后重试.', 0);
}
xob = null;
_forceRefresh();
}
xob.onError = function() {
xob = null;
_forceRefresh();
}
xob.post('usbcmd.cgi', 'mount=' + host);
}
var ref = new TomatoRefresh('update.cgi', 'exec=usbdevices', 0, 'nas_usb_refresh');
ref.refresh = function(text)
{
try {
eval(text);
}
catch (ex) {
return;
}
dg.removeAllData();
dg.populate();
dg.resort();
}
var dg = new TomatoGrid();
dg.sortCompare = function(a, b) {
var col = this.sortColumn;
var ra = a.getRowData();
var rb = b.getRowData();
var r;
switch (col) {
case 1:
if (ra.type == 'Storage' && ra.type == rb.type)
r = cmpInt(ra.host, rb.host);
else
r = cmpText(ra.host, rb.host);
break;
default:
r = cmpText(a.cells[col].innerHTML, b.cells[col].innerHTML);
}
return this.sortAscending ? r : -r;
}
dg.populate = function()
{
var i, j, k, a, b, c, e, s, desc, d, parts, p;
list = [];
for (i = 0; i < list.length; ++i) {
list[i].type = '';
list[i].host = '';
list[i].vendor = '';
list[i].product = '';
list[i].serial = '';
list[i].discs = [];
list[i].is_mounted = 0;
}
for (i = usbdev.length - 1; i >= 0; --i) {
a = usbdev[i];
e = {
type: a[0],
host: a[1],
vendor: a[2],
product: a[3],
serial: a[4],
discs: a[5],
is_mounted: a[6]
};
list.push(e);
}
for (i = list.length - 1; i >= 0; --i) {
e = list[i];
if (e.type != 'Storage')
s = '&nbsp<br><small>&nbsp</small>';
else {
if (xob)
				s = ((e.is_mounted == 0) ? '否' : '是') + '<br><small>请稍等...</small>';
else if (e.is_mounted == 0)
				s = 'No<br><small><a href="javascript:mountHost(\'L' + i + '\',\'' + e.host + '\')" title="挂载 USB 设备的所有分区" id="L' + i + '">[ 挂载 ]</a></small>';
else
				s = 'Yes<br><small><a href="javascript:umountHost(\'L' + i + '\',\'' + e.host + '\')" title="安全卸载 USB 设备的所有分区" id="L' + i + '">[ 卸载 ]</a></small>';
}
		desc = (e.vendor + ' ' + e.product).trim() + '<small>'; // + (e.serial == '' ? '' : '<br>序列号: ' + e.serial);
if (e.discs) {
for (j = 0; j <= e.discs.length - 1; ++j) {
d = e.discs[j];
parts = d[1];
for (k = 0; k <= parts.length - 1; ++k) {
p = parts[k];
if (p) {
						desc = desc + '<br>分区 \'' + p[0] + '\'' + (p[3] != '' ? ' ' + p[3] : '') +
((p[5] != 0) ? ' (' + doScaleSize(p[5], 0) + 
							((p[1] == 1) ? ' / ' + doScaleSize(p[6], 0) + ' 空闲' : '') +
')' : '') + ' ' +
							((p[1] != 0) ? '' : '没有被 ') + ((p[3] == 'swap') ? '激活' : '挂载') +
							((p[2] != '') ? ' 到 ' + p[2] : '');
}
}
}
}
desc = desc + '</small>';
this.insert(-1, e, [e.type, e.host, desc, s], false);
}
list = [];
}
dg.setup = function()
{
this.init('dev-grid', 'sort');
	this.headerSet(['类型', '主机', '产品名称', '已挂载?']);
this.populate();
this.sort(1);
}
function earlyInit()
{
dg.setup();
}
function init()
{
dg.recolor();
ref.initPage();
}
function verifyFields(focused, quiet)
{
var b = !E('_f_usb').checked;
var a = !E('_f_storage').checked;
E('_f_uhci').disabled = b || nvram.usb_uhci == -1;
E('_f_ohci').disabled = b || nvram.usb_ohci == -1;
E('_f_usb2').disabled = b;
E('_f_print').disabled = b;
E('_f_storage').disabled = b;

/* LINUX26-BEGIN */
/* MICROSD-BEGIN */
E('_f_mmc').disabled = a || b || nvram.usb_mmc == -1;
elem.display(PR('_f_mmc'), nvram.usb_mmc != -1);
/* MICROSD-END */
/* LINUX26-END */

E('_f_ext3').disabled = b || a;
E('_f_fat').disabled = b || a;
/* LINUX26-BEGIN */
E('_f_idle_enable').disabled = b || a;
E('_f_usb_3g').disabled = b;
/* LINUX26-END */
/* UPS-BEGIN */
	E('_f_usb_apcupsd').disabled = b;
/* UPS-END */
/* NTFS-BEGIN */
E('_f_ntfs').disabled = b || a;
/* NTFS-END */
/* HFS-BEGIN */
E('_f_hfs').disabled = b || a; //!Victek
/* HFS-END */
E('_f_automount').disabled = b || a;
E('_f_bprint').disabled = b || !E('_f_print').checked;
elem.display(PR('_f_automount'), !b && !a);
elem.display(PR('_script_usbmount'), PR('_script_usbumount'), !b && !a && E('_f_automount').checked);
elem.display(PR('_script_usbhotplug'), !b && (!a || E('_f_print').checked));
if (!v_length('_script_usbmount', quiet, 0, 2048)) return 0;
if (!v_length('_script_usbumount', quiet, 0, 2048)) return 0;
if (!v_length('_script_usbhotplug', quiet, 0, 2048)) return 0;
return 1;
}
function save()
{
var fom;
if (!verifyFields(null, 0)) return;
fom = E('_fom');
fom.usb_enable.value = E('_f_usb').checked ? 1 : 0;
fom.usb_uhci.value = nvram.usb_uhci == -1 ? -1 : (E('_f_uhci').checked ? 1 : 0);
fom.usb_ohci.value = nvram.usb_ohci == -1 ? -1 : (E('_f_ohci').checked ? 1 : 0);
fom.usb_usb2.value = E('_f_usb2').checked ? 1 : 0;
fom.usb_storage.value = E('_f_storage').checked ? 1 : 0;
fom.usb_printer.value = E('_f_print').checked ? 1 : 0;
fom.usb_printer_bidirect.value = E('_f_bprint').checked ? 1 : 0;

/* LINUX26-BEGIN */
/* MICROSD-BEGIN */
fom.usb_mmc.value = nvram.usb_mmc == -1 ? -1 : (E('_f_mmc').checked ? 1 : 0);
/* MICROSD-END */
/* LINUX26-END */

fom.usb_fs_ext3.value = E('_f_ext3').checked ? 1 : 0;
fom.usb_fs_fat.value = E('_f_fat').checked ? 1 : 0;
/* NTFS-BEGIN */
fom.usb_fs_ntfs.value = E('_f_ntfs').checked ? 1 : 0;
/* NTFS-END */
/* HFS-BEGIN */
fom.usb_fs_hfs.value = E('_f_hfs').checked ? 1 : 0; //!Victek
/* HFS-END */
fom.usb_automount.value = E('_f_automount').checked ? 1 : 0;
/* LINUX26-BEGIN */
fom.idle_enable.value = E('_f_idle_enable').checked ? 1 : 0;
fom.usb_3g.value = E('_f_usb_3g').checked ? 1 : 0;
/* LINUX26-END */
/* UPS-BEGIN */
	fom.usb_apcupsd.value = E('_f_usb_apcupsd').checked ? 1 : 0;
/* UPS-END */

form.submit(fom, 1);
}
function submit_complete()
{
reloadPage();
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

<input type='hidden' name='_nextpage' value='nas-usb.asp'>
<input type='hidden' name='_service' value='usb-restart'>
<input type='hidden' name='usb_enable'>
<input type='hidden' name='usb_uhci'>
<input type='hidden' name='usb_ohci'>
<input type='hidden' name='usb_usb2'>
<input type='hidden' name='usb_mmc'>
<input type='hidden' name='usb_storage'>
<input type='hidden' name='usb_printer'>
<input type='hidden' name='usb_printer_bidirect'>
<input type='hidden' name='usb_fs_ext3'>
<input type='hidden' name='usb_fs_fat'>
<!-- NTFS-BEGIN
<input type='hidden' name='usb_fs_ntfs'>
NTFS-END -->
<!-- HFS-BEGIN
<input type='hidden' name='usb_fs_hfs'>
HFS-END -->
<input type='hidden' name='usb_automount'>
/* LINUX26-BEGIN */
<input type='hidden' name='idle_enable'>
<input type='hidden' name='usb_3g'>
/* LINUX26-END */
/* UPS-BEGIN */
<input type='hidden' name='usb_apcupsd'>
/* UPS-END */

<div class='section-title'>USB 设置</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用 USB 功能', name: 'f_usb', type: 'checkbox', value: nvram.usb_enable == 1 },
	{ title: 'USB 2.0 支持', indent: 2, name: 'f_usb2', type: 'checkbox', value: nvram.usb_usb2 == 1 },
	{ title: 'USB 1.1 支持', indent: 2, multi: [
{ suffix: '&nbsp; OHCI &nbsp;&nbsp;&nbsp;', name: 'f_ohci', type: 'checkbox', value: nvram.usb_ohci == 1 },
{ suffix: '&nbsp; UHCI &nbsp;',	name: 'f_uhci', type: 'checkbox', value: nvram.usb_uhci == 1 }
] },
null,
	{ title: 'USB 打印机支持', name: 'f_print', type: 'checkbox', value: nvram.usb_printer == 1 },
		{ title: '双向复制', indent: 2, name: 'f_bprint', type: 'checkbox', value: nvram.usb_printer_bidirect == 1 },
null,
	{ title: 'USB 存储支持', name: 'f_storage', type: 'checkbox', value: nvram.usb_storage == 1 },
		{ title: '文件系统支持', indent: 2, multi: [
{ suffix: '&nbsp; Ext2 / Ext3 &nbsp;&nbsp;&nbsp;', name: 'f_ext3', type: 'checkbox', value: nvram.usb_fs_ext3 == 1 },
/* NTFS-BEGIN */
{ suffix: '&nbsp; NTFS &nbsp;&nbsp;&nbsp;', name: 'f_ntfs', type: 'checkbox', value: nvram.usb_fs_ntfs == 1 },
/* NTFS-END */
{ suffix: '&nbsp; FAT &nbsp;', name: 'f_fat', type: 'checkbox', value: nvram.usb_fs_fat == 1 }
/* HFS-BEGIN */
,{ suffix: '&nbsp; HFS / HFS+ &nbsp;', name: 'f_hfs', type: 'checkbox', value: nvram.usb_fs_hfs == 1 }
/* HFS-END */
] },
/* LINUX26-BEGIN */
/* MICROSD-BEGIN */
		{ title: 'SD/MMC 卡支持', indent: 2, name: 'f_mmc', type: 'checkbox', value: nvram.usb_mmc == 1 },
/* MICROSD-END */
/* LINUX26-END */
		{ title: '自动挂载', indent: 2, name: 'f_automount', type: 'checkbox',
			suffix: ' <small>自动挂载所有分区到 <i>/mnt</i>.</small>', value: nvram.usb_automount == 1 },
	{ title: '挂载后运行脚本', indent: 2, name: 'script_usbmount', type: 'textarea', value: nvram.script_usbmount },
	{ title: '卸载前运行脚本', indent: 2, name: 'script_usbumount', type: 'textarea', value: nvram.script_usbumount },
null,
/* LINUX26-BEGIN */
	{ title: '启用硬盘休眠', name: 'f_idle_enable', type: 'checkbox',
		suffix: ' <small>当硬盘空闲时进入休眠状态.对闪存设备无效.</small>', value: nvram.idle_enable == 1 },
	{ title: 'USB 3G上网卡支持', name: 'f_usb_3g', type: 'checkbox',
		suffix: ' <small>断开上网卡前请禁用该功能.如果上网卡使用串口USB模块,断开前必须重启路由器.</small>', value: nvram.usb_3g == 1 },
/* LINUX26-END */
/* UPS-BEGIN */
	{ title: '运行 APCUPSD 服务', name: 'f_usb_apcupsd', type: 'checkbox',
		suffix: ' <small>UPS 监视器需要此服务 (APC 不间断应急电源)</small>', value: nvram.usb_apcupsd == 1 },
/* UPS-END */
	{ title: 'Hotplug 脚本<br><small>(设备连接或移除时执行)</small>', name: 'script_usbhotplug', type: 'textarea', value: nvram.script_usbhotplug },
null,
	{ text: '<small>某些设置只有在重启路由器后才会生效.</small>' }
]);
</script>
</div>

<!-- / / / -->

<div class='section-title'>已连接设备</div>
<div class='section'>
<table id='dev-grid' class='tomato-grid' cellspacing=0></table>
<div id='usb-controls'>
<script type='text/javascript'>genStdRefresh(1,0,'ref.toggle()');</script>
</div>
<script type='text/javascript'></script>
</div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>earlyInit();verifyFields(null, 1);</script>
</body>
</html>
