use strict;

BEGIN { require "wakautils.pl" }

use constant NORMAL_HEAD_INCLUDE => q{

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<meta http-equiv="expires" content="Wed, 03 Nov 1999 12:21:14 GMT" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Cache-Control" content="no-cache" />
<title><if $title><var $title> - </if><const TITLE></title>
<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>" />
<link rel="shortcut icon" href="<var expand_filename(FAVICON)>" />

<style type="text/css">
body { margin: 0; padding: 8px; margin-bottom: auto; }
blockquote blockquote { margin-left: 0em }             
form { margin-bottom: 0px }
form .trap { display:none }
.postarea { text-align: center }
.postarea table { margin: 0px auto; text-align: left }
.thumb { border: none; float: left; margin: 2px 20px }
.nothumb { float: left; background: #eee; border: 2px dashed #aaa; text-align: center; margin: 2px 20px; padding: 1em 0.5em 1em 0.5em; }
.reply blockquote, blockquote :last-child { margin-bottom: 0em }
.reflink a { color: inherit; text-decoration: none }
.reply .filesize { margin-left: 20px }
.userdelete { float: right; text-align: center; white-space: nowrap }
.replypage .replylink { display: none }
.hidden { display: none }
.inline { display: inline }
</style>

<loop $stylesheets>
<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="<var $path><var $filename>" title="<var $title>" />
</loop>

<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>"; var thread_cookie = "<const SQL_TABLE>_hidden_threads"; var lastopenfield = 0;</script>
<script type="text/javascript" src="<var expand_filename(JS_FILE)>"></script>
</head>
<if $thread><body class="replypage"></if>
<if !$thread><body></if>

}.include("include/header.html").q{

<div class="adminbar">
<loop $stylesheets>
	[<a href="javascript:set_stylesheet('<var $title>')"><var $title></a>]
</loop>
-
[<a href="<var expand_filename(HOME)>" target="_top"><const S_HOME></a>]
[<a href="<var get_secure_script_name()>?task=admin"><const S_ADMIN></a>]
</div>

<div class="logo">
<if SHOWTITLEIMG==1><img src="<var expand_filename(TITLEIMG)>" alt="<const TITLE>" /></if>
<if SHOWTITLEIMG==2><img src="<var expand_filename(TITLEIMG)>" onclick="this.src=this.src;" alt="<const TITLE>" /></if>
<if SHOWTITLEIMG and SHOWTITLETXT><br /></if>
<if SHOWTITLETXT><const TITLE></if>
</div><hr />
};

use constant MINI_HEAD_INCLUDE => q{
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">}."\n\n".q{
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><if $title><var $title> - </if><const TITLE></title>
<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>" />
<link rel="shortcut icon" href="<var expand_filename(FAVICON)>" />

<style type="text/css">
body { margin: 0; padding: 8px; margin-bottom: auto; }
blockquote blockquote { margin-left: 0em }
form { margin-bottom: 0px }
form .trap { display:none }
.postarea { text-align: center }
.postarea table { margin: 0px auto; text-align: left }
.thumb { border: none; float: left; margin: 2px 20px }
.nothumb { float: left; background: #eee; border: 2px dashed #aaa; text-align: center; margin: 2px 20px; padding: 1em 0.5em 1em 0.5em; }
.reply blockquote, blockquote :last-child { margin-bottom: 0em }
.reflink a { color: inherit; text-decoration: none }
.reply .filesize { margin-left: 20px }
.userdelete { float: right; text-align: center; white-space: nowrap }
.replypage .replylink { display: none }
</style>

<loop $stylesheets>
<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="<var $path><var $filename>" title="<var $title>" />
</loop>

<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
<script type="text/javascript" src="<var expand_filename(JS_FILE)>"></script>
</head>
<body>
};

use constant MINI_HEAD_REFRESH_INCLUDE => q{
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">}."\n\n".q{
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><if $title><var $title> - </if><const TITLE></title>
<meta http-equiv="Content-Type" content="text/html;charset=<const CHARSET>" />
<link rel="shortcut icon" href="<var expand_filename(FAVICON)>" />

<style type="text/css">
body { margin: 0; padding: 8px; margin-bottom: auto; }
blockquote blockquote { margin-left: 0em }
form { margin-bottom: 0px }
form .trap { display:none }
.postarea { text-align: center }
.postarea table { margin: 0px auto; text-align: left }
.thumb { border: none; float: left; margin: 2px 20px }
.nothumb { float: left; background: #eee; border: 2px dashed #aaa; text-align: center; margin: 2px 20px; padding: 1em 0.5em 1em 0.5em; }
.reply blockquote, blockquote :last-child { margin-bottom: 0em }
.reflink a { color: inherit; text-decoration: none }
.reply .filesize { margin-left: 20px }
.userdelete { float: right; text-align: center; white-space: nowrap }
.replypage .replylink { display: none }
</style>

<loop $stylesheets>
<link rel="<if !$default>alternate </if>stylesheet" type="text/css" href="<var $path><var $filename>" title="<var $title>" />
</loop>

<script type="text/javascript">var style_cookie="<const STYLE_COOKIE>";</script>
<script type="text/javascript" src="<var expand_filename(JS_FILE)>"></script>
</head>
<body onload="window.opener.location.reload()">
};

use constant NORMAL_FOOT_INCLUDE => include("include/footer.html").q{
</body></html>
};

use constant MINI_FOOT_INCLUDE => q{
</body></html>
};

use constant PAGE_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{

<if $lockedthread ne 'yes'>
<if $thread>
	[<a href="<var expand_filename(HTML_SELF)>"><const S_RETURN></a>]
	<div class="theader"><const S_POSTING></div>
</if>

<if $postform>
	<div class="postarea">
	<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
	<input type="hidden" name="task" value="post" />
	<if $thread><input type="hidden" name="parent" value="<var $thread>" /></if>
	<if !$image_inp and !$thread and ALLOW_TEXTONLY>
		<input type="hidden" name="nofile" value="1" />
	</if>
	<if FORCED_ANON><input type="hidden" name="name" /></if>
	<if SPAM_TRAP><div class="trap"><const S_SPAMTRAP><input type="text" name="name" size="28" /><input type="text" name="link" size="28" /></div></if>

	<table><tbody>
	<if !FORCED_ANON><tr><td class="postblock"><const S_NAME></td><td><input type="text" name="field1" size="28" /></td></tr></if>
	<tr><td class="postblock"><const S_EMAIL></td><td><input type="text" name="email" size="28" /></td></tr>
	<tr><td class="postblock"><const S_SUBJECT></td><td><input type="text" name="subject" size="35" />
	<input type="submit" value="<const S_SUBMIT>" /></td></tr>
	<tr><td class="postblock"><const S_COMMENT></td><td><textarea name="comment" cols="48" rows="4"></textarea></td></tr>

	<if $image_inp>
		<tr><td class="postblock"><const S_UPLOADFILE></td><td><input type="file" name="file" size="35" />
		<if $textonly_inp>[<label><input type="checkbox" name="nofile" value="on" /><const S_NOFILE> ]</label></if>
		</td></tr>
	</if>

	<if ENABLE_CAPTCHA>
		<tr><td class="postblock"><const S_CAPTCHA></td><td><input type="text" name="captcha" size="10" />
		<img alt="" src="<var expand_filename(CAPTCHA_SCRIPT)>?key=<var get_captcha_key($thread)>&amp;dummy=<var $dummy>" />
		</td></tr>
	</if>

	<tr><td class="postblock"><const S_DELPASS></td><td><input type="password" name="password" size="8" autocomplete="off"/> <const S_DELEXPL></td></tr>
	<tr><td colspan="2">
	<div class="rules">}.include("include/rules.html").q{</div></td></tr>
	</tbody></table></form></div>
	<script type="text/javascript">set_inputs("postform")</script>

</if>
</if>

<if $lockedthread eq 'yes'>
	[<a href="<var expand_filename(HTML_SELF)>"><const S_RETURN></a>]
	<p style="font-weight:bold;font-size:1.2em"><const S_LOCKEDANNOUNCE></p>
</if>

<hr />

<if !$thread>
	<script type="text/javascript">
		var hiddenThreads=get_cookie(thread_cookie);
	</script>
</if>

<form id="delform" action="<var $self>" method="post">

<loop $threads>
	<loop $posts>
		<if !$parent>
			<div id="t<var $num>_info" style="float:left"></div>
			<if !$thread><span id="t<var $num>_display" style="float:right"><a href="javascript:threadHide('t<var $num>')" id="togglet<var $num>">Hide Thread (&minus;)</a><ins><noscript><br/>(Javascript Required.)</noscript></ins></span></if>
			<div id="t<var $num>">
			<if $image>
				<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><var get_filename($image)></a>
				-(<em><var $size> B, <var $width>x<var $height></em>)</span>
				<span class="thumbnailmsg"><const S_THUMB></span><br />

				<if $thumbnail>
					<a target="_blank" href="<var expand_image_filename($image)>" >
					<img src="<var expand_filename($thumbnail)>" width="<var $tn_width>" height="<var $tn_height>" alt="<var $size>" class="thumb" id="img<var get_filename($image)>" /></a>
				</if>
				<if !$thumbnail>
					<if DELETED_THUMBNAIL>
						<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
						<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width>" height="<var $tn_height>" alt="" class="thumb" /></a>
					</if>
					<if !DELETED_THUMBNAIL>
						<div class="nothumb"><a target="_blank" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div>
					</if>
				</if>
			</if>

			<a name="<var $num>"></a>
			<label><input type="checkbox" name="delete" value="<var $num>" />
			<span class="filetitle"><var $subject></span>
			<if $email><span class="postername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
			<if !$email><span class="postername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
			<if $stickied> <img src="<var expand_filename('include/sticky.gif')>" alt="<const S_STICKIEDALT>" title="<const S_STICKIED>" /> </if>
			<if $locked eq 'yes'> <img src="<var expand_filename('include/locked.gif')>" alt="<const S_LOCKEDALT>" title="<const S_LOCKED>" /> </if>
			<var $date></label>
			<span class="reflink">
			<if !$thread><a href="<var get_reply_link($num,0)>#i<var $num>">No.<var $num></a></if>
			<if $thread><a href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
			</span>&nbsp;
			<span class="deletelink" id="deletelink<var $num>">
				[<a href="<var $self>?task=delpostwindow&amp;num=<var $num>" target="_blank" onclick="passfield('<var $num>'); return false">Delete</a>]
				<span id="delpostcontent<var $num>" style="display:inline"></span>
			</span>&nbsp;
			[<a href="<var $self>?task=edit&amp;num=<var $num><if $admin_post eq 'yes'>&amp;admin_post=1</if>" target="_blank" onclick="popUpPost('<var $self>?task=edit&amp;num=<var $num><if $admin_post eq 'yes'>&amp;admin_post=1</if>'); return false">Edit</a>]&nbsp;
			<if !$thread>
			<if $locked ne 'yes'>[<a href="<var get_reply_link($num,0)>"><const S_REPLY></a>]</if>
			<if $locked eq 'yes'>[<a href="<var get_reply_link($num,0)>"><const S_VIEW></a>]</if>
			</if>

			<blockquote>
			<var $comment>
			<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))></div></if>
			<if $lastedit><p style="font-size: small; font-style: italic"><const S_LASTEDITED><if $admin_post eq 'yes'> <const S_BYMOD></if> <var $lastedit>.</p></if>
			</blockquote>

			<if $omit>
				<span class="omittedposts">
				<if $omitimages && !$locked><var sprintf S_ABBRIMG,$omit,$omitimages></if>
				<if $omitimages && $locked><var sprintf S_ABBRIMG_LOCK, $omit, $omitimages></if>
				<if !$omitimages && !$locked><var sprintf S_ABBR,$omit></if>
				<if !$omitimages && $locked><var sprintf S_ABBR_LOCK,$omit></if>
				</span>
			</if>
			<if !$thread>
				<script type="text/javascript">
					if (hiddenThreads.indexOf('t<var $num>,') != -1)
					{
						toggleHidden('t<var $num>');	
					}
				</script>
			</if>
		</if>
		<if $parent>
			<table><tbody><tr><td class="doubledash">&gt;&gt;</td>
			<td class="reply" id="reply<var $num>">

			<a name="<var $num>"></a>
			<label><input type="checkbox" name="delete" value="<var $num>" />
			<span class="replytitle"><var $subject></span>
			<if $email><span class="commentpostername"><a href="<var $email>"><var $name></a></span><if $trip><span class="postertrip"><a href="<var $email>"><var $trip></a></span></if></if>
			<if !$email><span class="commentpostername"><var $name></span><if $trip><span class="postertrip"><var $trip></span></if></if>
			<var $date></label>
			<span class="reflink">
			<if !$thread><a href="<var get_reply_link($parent,0)>#i<var $num>">No.<var $num></a></if>
			<if $thread><a href="javascript:insert('&gt;&gt;<var $num>')">No.<var $num></a></if>
			</span>&nbsp;
			<span class="deletelink" id="deletelink<var $num>">
				[<a href="<var $self>?task=delpostwindow&amp;num=<var $num>" target="_blank" onclick="passfield('<var $num>'); return false">Delete</a>]
				<span id="delpostcontent<var $num>" style="display:inline"></span>
			</span>&nbsp;
			[<a href="<var $self>?task=edit&amp;num=<var $num><if $admin_post eq 'yes'>&amp;admin_post=1</if>" target="_blank" onclick="popUpPost('<var $self>?task=edit&amp;num=<var $num><if $admin_post eq 'yes'>&amp;admin_post=1</if>'); return false">Edit</a>]

			<if $image>
				<br />
				<span class="filesize"><const S_PICNAME><a target="_blank" href="<var expand_image_filename($image)>"><var get_filename($image)></a>
				-(<em><var $size> B, <var $width>x<var $height></em>)</span>
				<span class="thumbnailmsg"><const S_THUMB></span><br />

				<if $thumbnail>
					<a target="_blank" href="<var expand_image_filename($image)>">
					<img src="<var expand_filename($thumbnail)>" width="<var $tn_width>" height="<var $tn_height>" alt="<var $size>" class="thumb" id="img<var get_filename($image)>" /></a>
				</if>
				<if !$thumbnail>
					<if DELETED_THUMBNAIL>
						<a target="_blank" href="<var expand_image_filename(DELETED_IMAGE)>">
						<img src="<var expand_filename(DELETED_THUMBNAIL)>" width="<var $tn_width>" height="<var $tn_height>" alt="" class="thumb" /></a>
					</if>
					<if !DELETED_THUMBNAIL>
						<div class="nothumb"><a target="_blank" href="<var expand_image_filename($image)>"><const S_NOTHUMB></a></div>
					</if>
				</if>
			</if>

			<blockquote>
			<var $comment>
			<if $abbrev><div class="abbrev"><var sprintf(S_ABBRTEXT,get_reply_link($num,$parent))></div></if>
			<if $lastedit><p style="font-size: small; font-style: italic">Last edited<if $admin_post eq 'yes'> by moderator</if> <var $lastedit>.</p></if>
			</blockquote>

			</td></tr></tbody></table>
		</if>
	</loop>
	</div>
	<br clear="left" /><hr />
</loop>

<table class="userdelete"><tbody><tr><td>
<input type="hidden" name="task" value="delete" />
<const S_REPDEL>[<label><input type="checkbox" name="fileonly" value="on" /><const S_DELPICONLY></label>]<br />
<const S_DELKEY><input type="password" name="password" size="8" autocomplete="off" />
<input value="<const S_DELETE>" type="submit" /></td></tr></tbody></table>
</form>
<script type="text/javascript">set_delpass("delform")</script>

<if !$thread>
	<table border="1"><tbody><tr><td>

	<if $prevpage><form method="get" action="<var $prevpage>"><input value="<const S_PREV>" type="submit" /></form></if>
	<if !$prevpage><const S_FIRSTPG></if>

	</td><td>

	<loop $pages>
		<if !$current>[<a href="<var $filename>"><var $page></a>]</if>
		<if $current>[<var $page>]</if>
	</loop>

	</td><td>

	<if $nextpage><form method="get" action="<var $nextpage>"><input value="<const S_NEXT>" type="submit" /></form></if>
	<if !$nextpage><const S_LASTPG></if>

	</td></tr></tbody></table>
</if>

<br clear="all" />

}.NORMAL_FOOT_INCLUDE);

use constant PASSWORD => compile_template (MINI_HEAD_INCLUDE. q{
	<h1 style="text-align:center;font-size:1em">Now Editing Post No.<var $num></h1>
	<form action="<var $self>" method="post" id="delform">	
	<input type="hidden" name="task" value="editpostwindow" />
	<input type="hidden" name="num" value="<var $num>" />
	<if !$admin_post><p style="text-align:center"><const S_PROMPTPASSWORD><input type="password" name="password" size="8" autocomplete="off" /></if>
	<if $admin_post><p style="text-align:center"><const S_PROMPTPASSWORDADMIN><input type="password" name="admin" size="8" autocomplete="off" /></if>
	<input value="Edit" type="submit" /></p>
	<if !$admin_post><script type="text/javascript">set_delpass("delform")</script></if>
	</form>
}.MINI_FOOT_INCLUDE);

use constant DELPASSWORD => compile_template (MINI_HEAD_INCLUDE. q{
	<h1 style="text-align:center;font-size:1em">Deleting Post No.<var $num></h1>
	<form action="<var $self>" method="post" id="delform">	
	<input type="hidden" name="task" value="delete" />
	<input type="hidden" name="delete" value="<var $num>" />
	<input type="hidden" name="fromwindow" value="1" />
	<p style="text-align:center">
		<const S_PROMPTPASSWORD><input type="password" name="password" size="8"/>
		<br />
		[<label><input type="checkbox" name="fileonly" value="on" /><const S_DELPICONLY></label>]
		<input value="Delete" type="submit" />
	</p>
	<script type="text/javascript">set_delpass("delform")</script>
	</form>
}.MINI_FOOT_INCLUDE);

use constant POST_EDIT_TEMPLATE => compile_template (MINI_HEAD_INCLUDE.q{ 
<loop $loop>
	<h1 style="text-align:center;font-size:1em">Now Editing Post No.<var $num></h1>
	
	<if $admin><div align="center"><em><const S_NOTAGS></em></div></if>
	
	<div class="postarea">
	<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
	
	<input type="hidden" name="num" value="<var $num>" />
	<input type="hidden" name="password" value="<var $password>" />
	<input type="hidden" name="task" value="editpost" />
	<if $admin><input type="hidden" name="admin" value="<var $admin>" />
	<input type="hidden" name="no_captcha" value="1" />
	<input type="hidden" name="no_format" value="1" /></if>
	<if $parent><input type="hidden" name="parent" value="<var $parent>" /></if>
	<if FORCED_ANON><input type="hidden" name="name" /></if>
	<if SPAM_TRAP><div class="trap"><const S_SPAMTRAP><input type="text" name="name" size="28" /><input type="text" name="link" size="28" /></div></if>
	
	<table><tbody>
	<if !FORCED_ANON><tr><td class="postblock"><const S_NAME></td><td><input type="text" name="field1" value="<var $name>" size="28" /><if $trip> # <var $trip><br />(Enter new tripcode above to change.)<br />[<label><input type="checkbox" value="1" name="killtrip" /> Remove Tripcode?</label>]</if></td></tr></if>
	<tr><td class="postblock"><const S_EMAIL></td><td><input type="text" name="email" size="28" value="<var $email>" /></td></tr>
	<tr><td class="postblock"><const S_SUBJECT></td><td><input type="text" name="subject" size="35" value="<var $subject>" />
	<input type="submit" value="<const S_SUBMIT>" /></td></tr>
	<tr><td class="postblock"><const S_COMMENT></td><td>
	<textarea name="comment" cols="48" rows="4"><if $admin><var clean_string($comment)></if><if !$admin><var tag_killa($comment)></if></textarea></td></tr>
	
	<if ALLOW_IMAGE_REPLIES || !$parent>
		<tr><td class="postblock"><const S_NEWFILE></td><td><input type="file" name="file" size="35" />
		<br />(Keep this field blank to leave the file unchanged.)
		</td></tr>
	</if>
	
	<if ENABLE_CAPTCHA>
		<tr><td class="postblock"><const S_CAPTCHA></td><td><input type="text" name="captcha" size="10" />
		<img alt="" src="<var expand_filename(CAPTCHA_SCRIPT)>?key=<var get_captcha_key($parent)>&amp;dummy=<var $num>" />
		</td></tr>
	</if>
	</tbody></table></form></div>
	<script type="text/javascript">set_inputs("postform")</script>
</loop>
}.MINI_FOOT_INCLUDE);

use constant ERROR_TEMPLATE => compile_template(NORMAL_HEAD_INCLUDE.q{

<h1 style="text-align: center"><var $error><br /><br />
<a href="<var escamp($ENV{HTTP_REFERER})>"><const S_RETURN></a><br /><br />
</h1>

}.NORMAL_FOOT_INCLUDE);

use constant ERROR_TEMPLATE_MINI => compile_template(MINI_HEAD_INCLUDE.q{

<h1 style="text-align:center"><var $error><br /><br />
<a href="<var escamp($ENV{HTTP_REFERER})>"><const S_RETURN></a><br /><br />
</h1>

}.MINI_FOOT_INCLUDE);

use constant BAN_TEMPLATE => compile_template(q{

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<link rel="stylesheet" type="text/css" href="http://www.desuchan.net/css/style.css" />
<style type="text/css">
	p {margin-left:0.5em}
</style>
<title><const S_BADHOST> - Desuchan</title>
</head>
<body>
<div style="text-align: center;">
	<h1>Desuchan</h1>
	<h3>"back to the internet"</h3><br />
</div>
<div class="content">
	<h2 style="text-align: center;"><const S_BADHOST></h2>
	<p align="center"><img src="<var expand_filename('/ban_images/randimg.cgi')>" alt="Ban Image" /></p>
	<h3><const S_BAN_WHY></h3>
	<p><const S_BAN_REASON>: <strong><var $comment></strong></p>
	<p><const S_CURRENT_IP> <strong><var $numip></strong></p><p><if $expiration><const S_BAN_WILL_EXPIRE> <strong><var $expiration></strong>.</if>
	<if !$expiration><const S_BAN_WILL_NOT_EXPIRE></if></p>
	<h3><const S_BAN_APPEAL_HEADER></h3><p><var $appeal></p>
</div>
</body>
</html>
});

#
# Admin pages
#

use constant MANAGER_HEAD_INCLUDE => NORMAL_HEAD_INCLUDE.q{

[<a href="<var expand_filename(HTML_SELF)>"><const S_MANARET></a>]
<if $admin>
	[<a href="<var $self>?task=mpanel"><const S_MANAPANEL></a>]
	[<a href="<var $self>?task=bans"><const S_MANABANS></a>]
	[<a href="<var $self>?task=proxy"><const S_MANAPROXY></a>]
	<if $type eq 'admin'>
		[<a href="<var $self>?task=spam"><const S_MANASPAM></a>]
		[<a href="<var $self>?task=sqldump"><const S_MANASQLDUMP></a>]
		[<a href="<var $self>?task=sql"><const S_MANASQLINT></a>]
	</if>
	[<a href="<var $self>?task=mpost"><const S_MANAPOST></a>]
	[<a href="<var $self>?task=rebuild"><const S_MANAREBUILD></a>]
	<if $type eq 'admin'>
		[<a href="<var $self>?task=staff">Staff Management</a>]
		[<a href="<var $self>?task=stafflog">Staff Activity</a>]
	</if>
</if>
<div class="passvalid" style="clear:both"><const S_MANAMODE></div>
<if $admin><div style="margin-top:0;float:left">&rarr; Logged in as <span class="postername"><var $username></span> (<if $type eq 'admin'>Administrator</if><if $type eq 'mod'>Moderator</if><if $type eq 'globmod'>Global Moderator</if>). [<a href="<var $self>?task=edituserwindow&amp;username=<var $username>&amp;admin=<var $admin>">Options</a>] [<a href="<var $self>?task=logout"><const S_MANALOGOUT></a>]</div></if>
<br />
};

use constant FIRST_TIME_SETUP => compile_template(NORMAL_HEAD_INCLUDE.q{
<div align="center">
<h2>First Time Setup</h2>
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="entersetup" />
<p>Staff accounts have not yet been set up.</p>
<const S_ADMINPASS> 
<input type="password" name="berra" size="8" value="" /> 
<input type="submit" value="<const S_MANASUB>" />
</form></div>
}.NORMAL_FOOT_INCLUDE);

use constant ACCOUNT_SETUP => compile_template(NORMAL_HEAD_INCLUDE.q{
<div align="center">
<h2>First Time Setup</h2>
<form action="<var $self>" method="post">
<p>Administrator, please enter your desired login username and password.</p>
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="task" value="setup" />
Username:
<input type="text" name="username" size="8" value="" />
<br />
Password:
<input type="password" name="password" size="8" value="" />
<br />
<input type="submit" value="<const S_MANASUB>" />
</form></div>
}.NORMAL_FOOT_INCLUDE);

use constant ADMIN_LOGIN_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div align="center"><form action="<var $self>" method="post">
<input type="hidden" name="task" value="admin" />
Username:
<input type="text" name="desu" size="16" value="" />
<br />
Password:
<input type="password" name="berra" size="16" value="" />
<br />
<label><input type="checkbox" name="savelogin" /> <const S_MANASAVE></label>
<br />
<select name="nexttask">
<option value="mpanel"><const S_MANAPANEL></option>
<option value="bans"><const S_MANABANS></option>
<option value="proxy"><const S_MANAPROXY></option>
<option value="spam"><const S_MANASPAM></option>
<option value="sqldump"><const S_MANASQLDUMP></option>
<option value="sql"><const S_MANASQLINT></option>
<option value="mpost"><const S_MANAPOST></option>
<option value="rebuild"><const S_MANAREBUILD></option>
<option value=""></option>
<option value="nuke"><const S_MANANUKE></option>
</select>
<input type="submit" value="<const S_MANASUB>" />
<p><em>Cookies required for login.</em></p>
</form></div>

}.NORMAL_FOOT_INCLUDE);


use constant POST_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><h2><const S_MANAPANEL></h2></div>

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="delete" />
<input type="hidden" name="admin" value="<var $admin>" /> <!-- Will be removed shortly -->

<div class="delbuttons">
<input type="submit" value="<const S_MPDELETE>" />
<input type="submit" name="archive" value="<const S_MPARCHIVE>" />
<input type="reset" value="<const S_MPRESET>" />
[<label><input type="checkbox" name="fileonly" value="on" /><const S_MPONLYPIC></label>]
</div>

<table align="center" style="white-space: nowrap"><tbody>
<tr class="managehead"><const S_MPTABLE><if $type eq 'admin'><th>Staff</th></if></tr>

<loop $posts>
	<if !$parent><tr class="managehead"><if $type ne 'admin'><th colspan="7"></if><if $type eq 'admin'><th colspan="8"></if></th></tr></if>

	<tr class="row<var $rowtype>">

	<if !$image && !$lastedit><td></if>
	<if $image && !$lastedit><td rowspan="2"></if>
	<if $lastedit && !$image><td rowspan="2"></if>
	<if $image && $lastedit><td rowspan="3"></if>
	<label><input type="checkbox" name="delete" value="<var $num>" /><big><b><var $num></b></big>&nbsp;&nbsp;</label></td>

	<td><var make_date($timestamp,"tiny")></td>
	<td><var clean_string(substr $subject,0,20)></td>
	<td><b><var clean_string(substr $name,0,30)><var $trip></b></td>
	<td><var clean_string(substr $comment,0,30)></td>
	<td>	
	<if !$parent>
	<if $stickied><img src="<var expand_filename('include/sticky.gif')>" alt="<const S_STICKIEDALT>" title="<const S_STICKIED>" /> </if>
	<if $locked eq 'yes'><img src="<var expand_filename('include/locked.gif')>" alt="<const S_LOCKEDALT>" title="<const S_LOCKED>" /> </if>
	<if $stickied || $locked eq 'yes'><br /></if>
	<if !$stickied>[<a href="<var $self>?task=sticky&amp;thread=<var $num>"><const S_STICKYOPTION></a>] </if>
	<if $stickied>[<a href="<var $self>?task=unsticky&amp;thread=<var $num>"><const S_UNSTICKYOPTION></a>] </if>
	<if $locked ne 'yes'>[<a href="<var $self>?task=lock&amp;thread=<var $num>"><const S_LOCKOPTION></a>] <br /></if>
	<if $locked eq 'yes'>[<a href="<var $self>?task=unlock&amp;thread=<var $num>"><const S_UNLOCKOPTION></a>] <br /></if>
	</if>
	[<a href="<var $self>?task=editpostwindow&amp;num=<var $num>&amp;admin=<var $admin>" target="_blank" onclick="popUpPost('<var $self>?task=editpostwindow&amp;admin=<var $admin>&amp;num=<var $num>'); return false">Edit</a>]
	</td>
	<td><var dec_to_dot($ip)>
		[<a href="<var $self>?task=deleteall&amp;ip=<var $ip>"><const S_MPDELETEALL></a>]
		[<a href="<var $self>?task=bans&amp;ip=<var $ip>"><const S_MPBAN></a>]
	</td>
	<if $type eq 'admin'><td><var $username></td></if>
	</tr>
	<if $lastedit>
		<tr class="row<var $rowtype>">
		<td colspan="5"><small>Edited: <var $lastedit></small></td>
		<td><small><var dec_to_dot($lastedit_ip)>
		[<a href="<var $self>?task=deleteall&amp;ip=<var $lastedit_ip>"><const S_MPDELETEALL></a>]
		[<a href="<var $self>?task=bans&amp;ip=<var $lastedit_ip>"><const S_MPBAN></a>]
		</small></td>
		<if $type eq "admin"><td><if $admin_post eq 'yes'>[<a href="<var $self>?task=staffedits&amp;num=<var $num>" target="_blank" onclick="popUp('<var $self>?task=staffedits&amp;num=<var $num>');return false">Staff Editing History</a>]</if></td></if>
		</tr>
	</if>
	<if $image>
		<tr class="row<var $rowtype>">
		<if $type ne "admin"><td colspan="6"></if><if $type eq "admin"><td colspan="7"></if><small>
		<const S_PICNAME><a href="<var expand_filename(clean_path($image))>"><var clean_string($image)></a>
		(<var $size> B, <var $width>x<var $height>)&nbsp; MD5: <var $md5>
		</small></td></tr>
	</if>
</loop>

</tbody></table>

<div class="delbuttons">
<input type="submit" value="<const S_MPDELETE>" />
<input type="submit" name="archive" value="<const S_MPARCHIVE>" />
<input type="reset" value="<const S_MPRESET>" />
[<label><input type="checkbox" name="fileonly" value="on" /><const S_MPONLYPIC></label>]
</div>

</form>

<br /><div class="postarea">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="deleteall" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" />
<input type="submit" value="<const S_MPDELETEIP>" /></td></tr>
</tbody></table></form>

</div><br />

<var sprintf S_IMGSPACEUSAGE,int($size/1024)>

}.NORMAL_FOOT_INCLUDE);

use constant STAFF_MANAGEMENT => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>Staff Management</h2></div>
	
	<table align="center" style="white-space: nowrap">
	<tbody>
		<tr class="managehead">
			<th>User</th>
			<th>Class</th>
			<th width="30%">Boards Moderated</th>
			<th>Latest Activity</th>
			<th>Options</th>
		</tr>
	<loop $users>
		<tr class="row<var $rowtype>">
			<td><strong><var $username></strong></td>
			<td><if $account eq 'admin'>Administrator</if>
			<if $account eq 'mod'>Moderator</if>
			<if $account eq 'globmod'>Global Moderator</if></td>
			<td><if $account ne 'mod'><em>All</em></if><if $account eq 'mod'><var $reign></if></td>
			<td><if $action><var get_action_name($action)> on <var $actiondate> [<a href="<var $self>?task=stafflog&amp;view=user&amp;usertoview=<var $username>">View All</a>]</if><if !$action><em>None</em></if></td>
			<td>[<a href="<var $self>?task=edituserwindow&amp;username=<var $username>">Edit</a>] [<if $disabled><a href="">Enable</a></if><if !$disabled><a href="<var $self>?task=disableuserwindow&amp;username=<var $username>&amp;admin=<var $admin>">Disable</a></if>] [<a href="<var $self>?task=deleteuserwindow&amp;username=<var $username>&amp;admin=<var $admin>">Remove</a>]</td>
		</tr>
	</loop>
	</tbody>
	</table>
	
	<br />
	
	<div class="dellist"><h3>Create User</h3></div>
	
	<form action="<var $self>" method="post">
	<input type="hidden" name="task" value="createuser" />
	<input type="hidden" name="admin" value="<var $admin>" />
	<p align="center"><em>The management password is necessary only for creating administrator accounts.<br />Global moderators oversee all boards.</em></p>
	<table align="center">
	<tbody>
		<tr><td class="postblock">Username</td><td><input type="text" name="usernametocreate" size="16" value="" /><br /><em>Usernames must be 4-30 characters, A-Za-z0-9^._, and spaces</em></td></tr>
		<tr><td class="postblock">Password</td><td><input type="password" name="passwordtocreate" size="16" value="" autocomplete="off" /><br /><em>Passwords must be 8-30 characters, A-Za-z0-9^._</em></td></tr>
		<tr><td class="postblock">Account Type</td><td><select name="account" onchange="if (this.form.account.value=='mod'){document.getElementById('boardselect').style.display='';} else {document.getElementById('boardselect').style.display='none';} if (this.form.account.value=='admin') {document.getElementById('managepass').style.display='';} else {document.getElementById('managepass').style.display='none';}"><option value="mod">Moderator</option><option value="globmod" selected="selected">Global Moderator</option><option value="admin">Administrator</option></select> <input type="submit" value="Create User" /></td></tr>
		<tr id="boardselect"><td class="postblock">Controlled Boards</td>
			<td><loop $boards><label><input type="checkbox" name="reign" value="<var $board>" /> <var $board></label><br /></loop></td></tr>
		<tr id="managepass"><td class="postblock">Management Password</td><td><input type="password" name="mpass" size="10" value="" autocomplete="off" /></td></tr>
	</tbody>
	</table>
	</form>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_DELETE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>User Deletion Confirmation</h2></div>
	<p align="center">Are you sure you want to delete user <strong><var $user_to_delete></strong>?</p>
	<form id="confirm" action="<var $self>" method="post">
		<input type="hidden" name="admin" value="<var $admin>" />
		<input type="hidden" name="task" value="deleteuser" />
		<input type="hidden" name="username" value="<var $user_to_delete>" />
		<if $account eq "admin"><p align="center">Manager password required. <input type="password" name="mpass" value="" /></p></if>
		<p align="center"><input type="submit" value="Yes" /></p>
	</form>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_DISABLE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>User Disable Confirmation</h2></div>
	<p align="center">Are you sure you want to disable user <strong><var $user_to_disable></strong>?</p>
	<form id="confirm" action="<var $self>" method="post">
		<input type="hidden" name="admin" value="<var $admin>" />
		<input type="hidden" name="task" value="disableuser" />
		<input type="hidden" name="username" value="<var $user_to_disable>" />
		<if $account eq "admin"><p align="center">Manager password required. <input type="password" name="mpass" value="" /></p></if>
		<p align="center"><input type="submit" value="Yes" /></p>
	</form>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_ENABLE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>User Enable Confirmation</h2></div>
	<p align="center">Are you sure you want to re-enable user <strong><var $user_to_enable></strong>?</p>
	<form id="confirm" action="<var $self>" method="post">
		<input type="hidden" name="admin" value="<var $admin>" />
		<input type="hidden" name="task" value="enableuser" />
		<input type="hidden" name="username" value="<var $user_to_enable>" />
		<if $account eq "admin"><p align="center">Manager password required. <input type="password" name="mpass" value="" /></p></if>
		<p align="center"><input type="submit" value="Yes" /></p>
	</form>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_EDIT_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2><if $user_to_edit ne $username>Editing Details for User <var $user_to_edit></if><if $user_to_edit eq $username>Editing Profile</if></h2></div>
	<form id="user_editing" action="<var $self>" method="post">
		<input type="hidden" name="task" value="edituser" />
		<input type="hidden" name="usernametoedit" value="<var $user_to_edit>" />
		<if $user_to_edit ne $username><p align="center"><em>The management password is required only for promoting staff members to the Administrator class or editing an existing Administrator account.</em></p></if>
		<table align="center">
			<tbody>
				<tr><td class="postblock">New Password</td><td><input type="password" name="newpassword" size="10" value="" autocomplete="off" /></td></tr>
				<if $user_to_edit eq $username>
					<tr><td class="postblock">Confirm Original Password</td><td><input type="password" name="originalpassword" size="10" value="" autocomplete="off" /> <input type="submit" value="Submit" /></td></tr>
				</if>
				<if $user_to_edit ne $username>
					<tr><td class="postblock">New Account Type</td><td><select name="newclass"><option value="mod" <if $account eq 'mod'>selected="selected"</if>>Moderator</option><option value="globmod" <if $account eq 'admin'>selected="selected"</if>>Global Moderator</option><option value="admin" <if $account eq 'admin'>selected="selected"</if>>Administrator</option></select></td></tr>
					<tr><td class="postblock">Jurisdiction</td><td><loop $boards><label><input name="reign" type="checkbox" value="<var $board>" <if $underpower>checked="checked"</if> /> <var $board></label><br /></loop></td></tr>
					<tr><td class="postblock">Management Password</td><td><input type="password" name="mpass" size="10" value="" autocomplete="off" /> <input type="submit" value="Submit" /></td></tr>
				</if>
			</tbody>
		</table>
	</form>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_ACTIVITY_HEAD => q{
	<table align="center">
		<tbody>
			<tr>
				<td style="padding:0.3em 1em 0.3em 0.3em">
					<form action="<var $self>" method="get">
						<input type="hidden" name="task" value="stafflog" />
						<input type="hidden" name="view" value="user" />
						<input type="hidden" name="perpage" value="<var $perpage>" />
						View Staff: 
						<select name="usertoview">
							<option value="" selected="selected">Select</option>
							<loop $staff><option value="<var $username>"><var $username></option></loop>
						</select>
						<input type="submit" value="View" />
					</form>
				</td>
				<td style="padding:0.3em">
					<form action="<var $self>" method="get">
						<input type="hidden" name="task" value="stafflog" />
						<input type="hidden" name="view" value="action" />
						<input type="hidden" name="perpage" value="<var $perpage>" />
						View Action: 
						<select name="actiontoview">
							<option value="">Select</option>
							<option value="admin_edit">Administrative Edits</option>
							<option value="admin_post">Manager Posts</option>
							<option value="admin_delete">Administrative Deletions</option>
							<option value="ipban">IP Bans</option>
							<option value="ipban_edit">IP Ban Edits</option>
							<option value="ipban_remove">IP Ban Removals</option>
							<option value="wordban">Word Bans</option>
							<option value="wordban_edit">Word Ban Edits</option>
							<option value="wordban_remove">Word Ban Removals</option>
							<option value="whitelist">IP Whitelist</option>
							<option value="whitelist_edit">IP Whitelist Edits</option>
							<option value="whitelist_remove">IP Whitelist Removals</option>
							<option value="nocaptcha">Captcha Exemptions</option>
							<option value="nocaptcha_edit">Revised Captcha Exemptions</option>
							<option value="nocaptcha_remove">Removed Captcha Exemptions</option>
							<option value="thread_sticky">Thread Stickies</option>
							<option value="thread_unsticky">Thread Unstickies</option>
							<option value="thread_lock">Thread Locks</option>
							<option value="thread_unlock">Thread Unlocks</option>
						</select>
						<input type="submit" value="View" />
					</form>
				</td>
			</tr>
			<tr>
				<td style="padding:0.3em 1em 0.3em 0.3em">
					<form action="<var $self>" method="get">
						<input type="hidden" name="task" value="stafflog" />
						<input type="hidden" name="view" value="ip" />
						<input type="hidden" name="perpage" value="<var $perpage>" />
						<input type="hidden" name="admin" value="<var $admin>" />
						View Affected IP Address: 
						<input type="text" name="iptoview" value="" size="15" />
						<input type="submit" value="View" />
					</form>
				</td>
				<td style="padding:0.3em">
					<form action="<var $self>" method="get">
						<input type="hidden" name="task" value="stafflog" />
						<input type="hidden" name="view" value="post" />
						<input type="hidden" name="perpage" value="<var $perpage>" />
						<input type="hidden" name="admin" value="<var $admin>" />
						View Affected Post: 
						<input type="text" name="posttoview" value="" size="15" />
						<input type="submit" value="View" />
					</form>
				</td>
			</tr>
		</tbody>
	</table>
};

use constant STAFF_ACTIVITY_PAGINATION => q{
	<p align="center">
		There are <strong><var $count></strong> actions recorded in the database. Showing <var $perpage> per page.
		<br />
		<if $page != 1><a href="<var $self>?task=stafflog&amp;page=1&amp;perpage=<var $perpage>&amp;view=<var $view>&amp;usertoview=<var $user_to_view>&amp;actiontoview=<var $action_to_view>"></if>
		&lt;&lt;<if $page != 1></a></if> 
		<span style="padding-left:1em">
			<if $page != 1><a href="<var $self>?task=stafflog&amp;page=<var $page-1>&amp;perpage=<var $perpage>&amp;view=<var $view>&amp;usertoview=<var $user_to_view>&amp;actiontoview=<var $action_to_view>"></if>
			&lt;<if $page != 1></a></if>
		</span>
		<span style="padding-left:2em;padding-right:2em">Page <var $page> of <var $number_of_pages></span> 
		<span style="padding-right:1em">
			<if !$lastpage><a href="<var $self>?task=stafflog&amp;page=<var $page+1>&amp;perpage=<var $perpage>&amp;view=<var $view>&amp;usertoview=<var $user_to_view>&amp;actiontoview=<var $action_to_view>"></if>
			&gt;<if !$lastpage></a></if> 
		</span>
		<if !$lastpage><a href="<var $self>?task=stafflog&amp;page=<var $number_of_pages>&amp;perpage=<var $perpage>&amp;view=<var $view>&amp;usertoview=<var $user_to_view>&amp;actiontoview=<var $action_to_view>"></if>
		&gt;&gt;<if !$lastpage></a></if> 
	</p>
	<div align="center">
		<form action="<var $self>" method="get" style="display:inline;padding-right:5em"><input type="hidden" name="task" value="stafflog" /><input type="hidden" name="view" value="<var $view>" /><if $view eq 'user'><input type="hidden" name="usertoview" value="<var $user_to_view>" /></if><if $view eq 'action'><input type="hidden" name="actiontoview" value="<var $action_to_view>" /></if><input type="hidden" name="sortby" value="<var $sortby>" /><input type="hidden" name="order" value="<var $order>" />Show <select name="perpage"><option value="25">25</option><option value="50">50</option><option value="100">100</option><option value="200">200</option></select> per page. <input type="submit" value="Change" /></form>
		<form action="<var $self>" method="get" style="display:inline"><input type="hidden" name="task" value="stafflog" /><input type="hidden" name="view" value="<var $view>" /><input type="hidden" name="perpage" value="<var $perpage>" /><if $view eq 'user'><input type="hidden" name="usertoview" value="<var $user_to_view>" /></if><if $view eq 'action'><input type="hidden" name="actiontoview" value="<var $action_to_view>" /></if><input type="hidden" name="sortby" value="<var $sortby>" /><input type="hidden" name="order" value="<var $order>" />Jump to page: <input type="text" name="page" value="" size="2" /> <input type="submit" value="Jump" /><input type="hidden" name="task" value="stafflog" /></form>
	</div>
	<br />
	

};

use constant STAFF_ACTIVITY_UNFILTERED => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>Staff Activity</h2></div>
	}.STAFF_ACTIVITY_HEAD.q{
	<!-- Admin w/ management pass may clean up -->
	<div class="dellist"><h3>Viewing Full Log</h3></div>
	}.STAFF_ACTIVITY_PAGINATION.q{
	<table align="center" style="white-space: nowrap">
	<tbody>
		<tr class="managehead">
			<th><a href="<var $self>?task=stafflog&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=username&amp;order=<if $order =~ /^asc/ || $sortby ne 'username'>desc</if><if $order !~ /^asc/i && $sortby eq 'username'>asc</if>">User<if $sortby eq 'username'> <if $order =~ /^asc/i>&#9660;</if><if $order !~ /^asc/>&#9650;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=account&amp;order=<if $order =~ /^asc/ || $sortby ne 'account'>desc</if><if $order !~ /^asc/i && $sortby eq 'account'>asc</if>">Class<if $sortby eq 'account'> <if $order =~ /^asc/i>&#9660;</if><if $order !~ /^asc/>&#9650;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=action&amp;order=<if $order =~ /^asc/ || $sortby ne 'action'>desc</if><if $order !~ /^asc/i && $sortby eq 'action'>asc</if>">Action<if $sortby eq 'action'> <if $order =~ /^asc/i>&#9660;</if><if $order !~ /^asc/>&#9650;</if></if></a></th>
			<th>Information</th>
			<th><a href="<var $self>?task=stafflog&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=date&amp;order=<if $order =~ /^asc/ || $sortby ne 'date'>desc</if><if $order !~ /^asc/ && $sortby eq 'date'>asc</if>">Date<if $sortby eq 'date'> <if $order =~ /^asc/i>&#9660;</if><if $order !~ /^asc/>&#9650;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog">IP Address</a></th>
		</tr>
	<loop $entries>
		<tr class="row<var $rowtype>">
			<td><if $disabled><span style="color:#555555"></if><strong><var $username></strong><if $disabled></span></if></td>
			<td><if $account eq 'admin'>Administrator</if>
			<if $account eq 'mod'>Moderator</if></td>
			<td><var get_action_name($action)></td>
			<td><var $info></td>
			<td><var $date></td>
			<td><var dec_to_dot($ip)></td>
		</tr>
	</loop>
	</tbody>
	</table>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_ACTIVITY_BY_USER => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>Staff Activity</h2></div>
	}.STAFF_ACTIVITY_HEAD.q{
	<p align="center" style="margin-top:0.2em"><a href="<var $self>?task=stafflog">Show All</a></p>
	<h3 style="text-align:center">Actions by <var $user_to_view></h3>
	}.STAFF_ACTIVITY_PAGINATION.q{
	<table align="center" style="white-space: nowrap">
	<tbody>
		<tr class="managehead">
			<th><a href="<var $self>?task=stafflog&amp;view=user&amp;usertoview=<var $user_to_view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=action&amp;order=<if $order =~ /^asc/ || $sortby ne 'action'>desc</if><if $order !~ /^asc/i && $sortby eq 'action'>asc</if>">Action<if $sortby eq 'action'> <if $order =~ /^asc/i>&#9660;</if><if $order !~ /^asc/>&#9650;</if></if></a></th>
			<th>Info</th>
			<th><a href="<var $self>?task=stafflog&amp;view=user&amp;usertoview=<var $user_to_view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=date&amp;order=<if $order =~ /^asc/ || $sortby ne 'date'>desc</if><if $order !~ /^asc/ && $sortby eq 'date'>asc</if>">Date<if $sortby eq 'date'> <if $order =~ /^asc/i>&#9660;</if><if $order !~ /^asc/>&#9650;</if></if></a></th>
			<th>IP Address</th>
		</tr>
		<loop $entries>
			<tr class="row<var $rowtype>">
				<td><var get_action_name($action)></td>
				<td><var $info></td>
				<td><var $date></td>
				<td><var dec_to_dot($ip)></td>
			</tr>
		</loop>
	</tbody>
	</table>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_ACTIVITY_BY_ACTIONS => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>Staff Activity</h2></div>
	}.STAFF_ACTIVITY_HEAD.q{
	<p align="center" style="margin-top:0.2em"><a href="<var $self>?task=stafflog">Show All</a></p>
	<div class="dellist"><h3 align="center">Viewing Action: <var $action_name></h3></div>
	}.STAFF_ACTIVITY_PAGINATION.q{
	<table align="center" style="white-space: nowrap">
	<tbody>
		<tr class="managehead">
			<th><a href="<var $self>?task=stafflog&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=username&amp;order=<if $order =~ /^asc/ || $sortby ne 'username'>desc</if><if $order !~ /^asc/i && $sortby eq 'username'>asc</if>">User<if $sortby eq 'username'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=account&amp;order=<if $order =~ /^asc/ || $sortby ne 'account'>desc</if><if $order !~ /^asc/i && $sortby eq 'account'>asc</if>">Class<if $sortby eq 'account'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th><var $content_name></th>
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=date&amp;order=<if $order =~ /^asc/ || $sortby ne 'date'>desc</if><if $order !~ /^asc/ && $sortby eq 'date'>asc</if>">Date<if $sortby eq 'date'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th>IP Address</th>
		</tr>
	<loop $entries>
		<tr class="row<var $rowtype>">
			<td><if $disabled><span style="color:#555555"></if><strong><var $username></strong><if $disabled></span></if></td>
			<td><if $account eq 'admin'>Administrator</if>
			<if $account eq 'mod'>Moderator</if></td>
			<td><var $info></td>
			<td><var $date></td>
			<td><var dec_to_dot($ip)></td>
		</tr>
	</loop>
	</tbody>
	</table>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_ACTIVITY_BY_IP_ADDRESS => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>Staff Activity</h2></div>
	}.STAFF_ACTIVITY_HEAD.q{
	<p align="center" style="margin-top:0.2em"><a href="<var $self>?task=stafflog">Show All</a></p>
	<div class="dellist"><h3>Showing Activity on IP Address <var $ip_to_view></h3></div>
	}.STAFF_ACTIVITY_PAGINATION.q{
	<table align="center" style="white-space: nowrap">
	<tbody>
		<tr class="managehead">
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=username&amp;order=<if $order =~ /^asc/ || $sortby ne 'username'>desc</if><if $order !~ /^asc/i && $sortby eq 'username'>asc</if>">User<if $sortby eq 'username'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=account&amp;order=<if $order =~ /^asc/ || $sortby ne 'account'>desc</if><if $order !~ /^asc/i && $sortby eq 'account'>asc</if>">Class<if $sortby eq 'account'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=action&amp;order=<if $order =~ /^asc/ || $sortby ne 'action'>desc</if><if $order !~ /^asc/i && $sortby eq 'action'>asc</if>">Action<if $sortby eq 'action'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th>Information</th>
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=date&amp;order=<if $order =~ /^asc/ || $sortby ne 'date'>desc</if><if $order !~ /^asc/ && $sortby eq 'date'>asc</if>">Date<if $sortby eq 'date'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th>IP Address</th>
		</tr>
	<loop $entries>
		<tr class="row<var $rowtype>">
			<td><if $disabled><span style="color:#555555"></if><strong><var $username></strong><if $disabled></span></if></td>
			<td><if $account eq 'admin'>Administrator</if>
			<if $account eq 'mod'>Moderator</if></td>
			<td><var $action></td>
			<td><var $info></td>
			<td><var $date></td>
			<td><var dec_to_dot($ip)></td>
		</tr>
	</loop>
	</tbody>
	</table>
	
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_ACTIVITY_BY_POST => compile_template(MANAGER_HEAD_INCLUDE.q{
	<div class="dellist"><h2>Staff Activity</h2></div>
	}.STAFF_ACTIVITY_HEAD.q{
	<p align="center" style="margin-top:0.2em"><a href="<var $self>?task=stafflog">Show All</a></p>
	<div class="dellist"><h3>Showing Activity on Post <var $post_to_view></h3></div>
	}.STAFF_ACTIVITY_PAGINATION.q{
	<table align="center" style="white-space: nowrap">
	<tbody>
		<tr class="managehead">
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=username&amp;order=<if $order =~ /^asc/ || $sortby ne 'username'>desc</if><if $order !~ /^asc/i && $sortby eq 'username'>asc</if>">User<if $sortby eq 'username'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=account&amp;order=<if $order =~ /^asc/ || $sortby ne 'account'>desc</if><if $order !~ /^asc/i && $sortby eq 'account'>asc</if>">Class<if $sortby eq 'account'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=action&amp;order=<if $order =~ /^asc/ || $sortby ne 'action'>desc</if><if $order !~ /^asc/i && $sortby eq 'action'>asc</if>">Action<if $sortby eq 'action'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th><a href="<var $self>?task=stafflog&amp;view=<var $view>&amp;page=<var $page>&amp;perpage=<var $perpage>&amp;sortby=date&amp;order=<if $order =~ /^asc/ || $sortby ne 'date'>desc</if><if $order !~ /^asc/ && $sortby eq 'date'>asc</if>">Date<if $sortby eq 'date'> <if $order =~ /^asc/i>&dtrif;</if><if $order !~ /^asc/>&utrif;</if></if></a></th>
			<th>IP Address</th>
		</tr>
	<loop $entries>
		<tr class="row<var $rowtype>">
			<td><if $disabled><span style="color:#555555"></if><strong><var $username></strong><if $disabled></span></if></td>
			<td><if $account eq 'admin'>Administrator</if>
			<if $account eq 'mod'>Moderator</if></td>
			<td><var $action></td>
			<td><var $date></td>
			<td><var dec_to_dot($ip)></td>
		</tr>
	</loop>
	</tbody>
	</table>
}.NORMAL_FOOT_INCLUDE);

use constant STAFF_EDIT_HISTORY => compile_template(MINI_HEAD_INCLUDE.q{
	<h1 style="font-size: 1em; text-align: center; font-weight: bold">Staff Editing History for Post <var $num></h1>
	<ul>
		<loop $edits>
			<li><span class="postername"><var $username></span> on <strong><var $date></strong>.</li> 
		</loop>
	</ul>
}.MINI_FOOT_INCLUDE);

use constant EDIT_SUCCESSFUL => compile_template(MINI_HEAD_REFRESH_INCLUDE.q{
	<p style="font-size: 1em; text-align: center; font-weight: bold">Update Successful!</p>
}.MINI_FOOT_INCLUDE);


use constant BAN_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><h2><const S_MANABANS></h2></div>

<div class="postarea">
<table><tbody><tr><td valign="middle">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="ipban" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" value="<var dec_to_dot($ip)>" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANEXPIRE></td><td><input type="text" name="expiration" size="16" /><br/>
<select name="expirepresets" onchange="this.form.expiration.value = this.form.expirepresets.options[this.form.expirepresets.selectedIndex].value;">
<option value="" selected="selected">Presets</option>
<option value="300">5 minutes</option>
<option value="900">15 minutes</option>
<option value="1800">30 minutes</option>
<option value="3600">1 hour</option>
<option value="7200">2 hours</option>
<option value="43200">12 hours</option>
<option value="86400">1 day</option>
<option value="172800">2 days</option>
<option value="604800">1 week</option>
<option value="1209600">2 weeks</option>
<option value="2419200">~1 month</option>
<option value="4838400">~2 months</option>
<option value="15768000">6 months</option>
<option value="31536000">1 year</option>
<option value="0">Eternity</option>
</select> (Javascript)
</td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="24" /></td></tr>
<tr><td class="postblock"><const S_TOTALBAN></td><td><input type="checkbox" name="total" value="yes" style="float:left; clear:none" /> <input type="submit" value="<const S_BANIP>" style="float: right; clear: none"/></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="middle">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addip" />
<input type="hidden" name="type" value="whitelist" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="mask" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANWHITELIST>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td></tr><tr><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="wordban" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANWORDLABEL></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANWORD>" /></td></tr>
</tbody></table></form>

</td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="bottom">

<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addstring" />
<input type="hidden" name="type" value="trust" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_BANTRUSTTRIP></td><td><input type="text" name="string" size="24" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" />
<input type="submit" value="<const S_BANTRUST>" /></td></tr>
</tbody></table></form>

</td></tr></tbody></table>
</div><br />

<table align="center"><tbody>
<tr class="managehead"><const S_BANTABLE></tr>

<loop $bans>
	<if $divider><tr class="managehead"><th colspan="7"></th></tr></if>

	<tr class="row<var $rowtype>">

	<if $type eq 'ipban'>
		<td>IP</td>
		<td><var dec_to_dot($ival1)>/<var dec_to_dot($ival2)></td>
	</if>
	<if $type eq 'wordban'>
		<td>Word</td>
		<td><var $sval1></td>
	</if>
	<if $type eq 'trust'>
		<td>NoCap</td>
		<td><var $sval1></td>
	</if>
	<if $type eq 'whitelist'>
		<td>Whitelist</td>
		<td><var dec_to_dot($ival1)>/<var dec_to_dot($ival2)></td>
	</if>

	<td><var $comment></td>
	<td><var $expirehuman></td>
	<td style="text-align: center"><if $type eq 'ipban'><var $browsingban></if><if $type ne 'ipban'>--</if></td>
	<td><var $username></td>
	<td>[<a href="<var $self>?admin=<var $admin>&amp;task=removeban&amp;num=<var $num>"><const S_BANREMOVE></a>] 
	[<a href="<var $self>?admin=<var $admin>&amp;task=baneditwindow&amp;num=<var $num>" target="_blank" onclick="popUp('<var $self>?admin=<var $admin>&amp;task=baneditwindow&amp;num=<var $num>'); return false"><const S_BANEDIT></a>]</td>
	</tr>
</loop>

</tbody></table><br />

}.NORMAL_FOOT_INCLUDE);

use constant EDIT_WINDOW => compile_template(MINI_HEAD_INCLUDE.q{
<h1 style="text-align: center; font-size: 1em">Editing Admin Entry</h1>
<div class="postarea">
<loop $hash>
<if $type eq 'ipban'>
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="adminedit" />
<input type="hidden" name="type" value="ipban" />
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="num" value="<var $num>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ival1" size="24" value="<var dec_to_dot($ival1)>" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="ival2" size="24" value="<var dec_to_dot($ival2)>" /></td></tr>
<tr><td class="postblock"><const S_BANEXPIRE_EDIT></td><td>
<select name="day">
<option value="1"<if $day == 1> selected="selected"</if>>1</option>
<option value="2"<if $day == 2> selected="selected"</if>>2</option>
<option value="3"<if $day == 3> selected="selected"</if>>3</option>
<option value="4"<if $day == 4> selected="selected"</if>>4</option>
<option value="5"<if $day == 5> selected="selected"</if>>5</option>
<option value="6"<if $day == 6> selected="selected"</if>>6</option>
<option value="7"<if $day == 7> selected="selected"</if>>7</option>
<option value="8"<if $day == 8> selected="selected"</if>>8</option>
<option value="9"<if $day == 9> selected="selected"</if>>9</option>
<option value="10"<if $day == 10> selected="selected"</if>>10</option>
<option value="11"<if $day == 11> selected="selected"</if>>11</option>
<option value="12"<if $day == 12> selected="selected"</if>>12</option>
<option value="13"<if $day == 13> selected="selected"</if>>13</option>
<option value="14"<if $day == 14> selected="selected"</if>>14</option>
<option value="15"<if $day == 15> selected="selected"</if>>15</option>
<option value="16"<if $day == 16> selected="selected"</if>>16</option>
<option value="17"<if $day == 17> selected="selected"</if>>17</option>
<option value="18"<if $day == 18> selected="selected"</if>>18</option>
<option value="19"<if $day == 19> selected="selected"</if>>19</option>
<option value="20"<if $day == 20> selected="selected"</if>>20</option>
<option value="21"<if $day == 21> selected="selected"</if>>21</option>
<option value="22"<if $day == 22> selected="selected"</if>>22</option>
<option value="23"<if $day == 23> selected="selected"</if>>23</option>
<option value="24"<if $day == 24> selected="selected"</if>>24</option>
<option value="25"<if $day == 25> selected="selected"</if>>25</option>
<option value="26"<if $day == 26> selected="selected"</if>>26</option>
<option value="27"<if $day == 27> selected="selected"</if>>27</option>
<option value="28"<if $day == 28> selected="selected"</if>>28</option>
<option value="29"<if $day == 29> selected="selected"</if>>29</option>
<option value="30"<if $day == 30> selected="selected"</if>>30</option>
<option value="31"<if $day == 31> selected="selected"</if>>31</option>
</select> 
<select name="month">
<option value="1" <if $month == 1>selected="selected"</if>>January</option>
<option value="2" <if $month == 2>selected="selected"</if>>February</option>
<option value="3" <if $month == 3>selected="selected"</if>>March</option>
<option value="4" <if $month == 4>selected="selected"</if>>April</option>
<option value="5" <if $month == 5>selected="selected"</if>>May</option>
<option value="6" <if $month == 6>selected="selected"</if>>June</option>
<option value="7" <if $month == 7>selected="selected"</if>>July</option>
<option value="8" <if $month == 8>selected="selected"</if>>August</option>
<option value="9" <if $month == 9>selected="selected"</if>>September</option>
<option value="10" <if $month == 10>selected="selected"</if>>October</option>
<option value="11" <if $month == 11>selected="selected"</if>>November</option>
<option value="12" <if $month == 12>selected="selected"</if>>December</option>
</select> 
<input type="text" name="year" value="<var $year>" size="5" />
<br />
<select name="hour">
<option value="0" <if $hour == 0 >selected="selected"</if>>00</option>
<option value="1" <if $hour == 1 >selected="selected"</if>>01</option>
<option value="2" <if $hour == 2 >selected="selected"</if>>02</option>
<option value="3" <if $hour == 3 >selected="selected"</if>>03</option>
<option value="4" <if $hour == 4 >selected="selected"</if>>04</option>
<option value="5" <if $hour == 5 >selected="selected"</if>>05</option>
<option value="6" <if $hour == 6 >selected="selected"</if>>06</option>
<option value="7" <if $hour == 7 >selected="selected"</if>>07</option>
<option value="8" <if $hour == 8 >selected="selected"</if>>08</option>
<option value="9" <if $hour == 9 >selected="selected"</if>>09</option>
<option value="10" <if $hour == 10>selected="selected"</if>>10</option>
<option value="11" <if $hour == 11>selected="selected"</if>>11</option>
<option value="12" <if $hour == 12>selected="selected"</if>>12</option>
<option value="13" <if $hour == 13>selected="selected"</if>>13</option>
<option value="14" <if $hour == 14>selected="selected"</if>>14</option>
<option value="15" <if $hour == 15>selected="selected"</if>>15</option>
<option value="16" <if $hour == 16>selected="selected"</if>>16</option>
<option value="17" <if $hour == 17>selected="selected"</if>>17</option>
<option value="18" <if $hour == 18>selected="selected"</if>>18</option>
<option value="19" <if $hour == 19>selected="selected"</if>>19</option>
<option value="20" <if $hour == 20>selected="selected"</if>>20</option>
<option value="21" <if $hour == 21>selected="selected"</if>>21</option>
<option value="22" <if $hour == 22>selected="selected"</if>>22</option>
<option value="23" <if $hour == 23>selected="selected"</if>>23</option>
</select> : 
<select name="min">
<option value="0" <if $min == 0 >selected="selected"</if>>00</option>
<option value="1" <if $min == 1 >selected="selected"</if>>01</option>
<option value="2" <if $min == 2 >selected="selected"</if>>02</option>
<option value="3" <if $min == 3 >selected="selected"</if>>03</option>
<option value="4" <if $min == 4 >selected="selected"</if>>04</option>
<option value="5" <if $min == 5 >selected="selected"</if>>05</option>
<option value="6" <if $min == 6 >selected="selected"</if>>06</option>
<option value="7" <if $min == 7 >selected="selected"</if>>07</option>
<option value="8" <if $min == 8 >selected="selected"</if>>08</option>
<option value="9" <if $min == 9 >selected="selected"</if>>09</option>
<option value="10" <if $min == 10>selected="selected"</if>>10</option>
<option value="11" <if $min == 11>selected="selected"</if>>11</option>
<option value="12" <if $min == 12>selected="selected"</if>>12</option>
<option value="13" <if $min == 13>selected="selected"</if>>13</option>
<option value="14" <if $min == 14>selected="selected"</if>>14</option>
<option value="15" <if $min == 15>selected="selected"</if>>15</option>
<option value="16" <if $min == 16>selected="selected"</if>>16</option>
<option value="17" <if $min == 17>selected="selected"</if>>17</option>
<option value="18" <if $min == 18>selected="selected"</if>>18</option>
<option value="19" <if $min == 19>selected="selected"</if>>19</option>
<option value="20" <if $min == 20>selected="selected"</if>>20</option>
<option value="21" <if $min == 21>selected="selected"</if>>21</option>
<option value="22" <if $min == 22>selected="selected"</if>>22</option>
<option value="23" <if $min == 23>selected="selected"</if>>23</option>
<option value="24" <if $min == 24>selected="selected"</if>>24</option>
<option value="25" <if $min == 25>selected="selected"</if>>25</option>
<option value="26" <if $min == 26>selected="selected"</if>>26</option>
<option value="27" <if $min == 27>selected="selected"</if>>27</option>
<option value="28" <if $min == 28>selected="selected"</if>>28</option>
<option value="29" <if $min == 29>selected="selected"</if>>29</option>
<option value="30" <if $min == 30>selected="selected"</if>>30</option>
<option value="31" <if $min == 31>selected="selected"</if>>31</option>
<option value="32" <if $min == 32>selected="selected"</if>>32</option>
<option value="33" <if $min == 33>selected="selected"</if>>33</option>
<option value="34" <if $min == 34>selected="selected"</if>>34</option>
<option value="35" <if $min == 35>selected="selected"</if>>35</option>
<option value="36" <if $min == 36>selected="selected"</if>>36</option>
<option value="37" <if $min == 37>selected="selected"</if>>37</option>
<option value="38" <if $min == 38>selected="selected"</if>>38</option>
<option value="39" <if $min == 39>selected="selected"</if>>39</option>
<option value="40" <if $min == 40>selected="selected"</if>>40</option>
<option value="41" <if $min == 41>selected="selected"</if>>41</option>
<option value="42" <if $min == 42>selected="selected"</if>>42</option>
<option value="43" <if $min == 43>selected="selected"</if>>43</option>
<option value="44" <if $min == 44>selected="selected"</if>>44</option>
<option value="45" <if $min == 45>selected="selected"</if>>45</option>
<option value="46" <if $min == 46>selected="selected"</if>>46</option>
<option value="47" <if $min == 47>selected="selected"</if>>47</option>
<option value="48" <if $min == 48>selected="selected"</if>>48</option>
<option value="49" <if $min == 49>selected="selected"</if>>49</option>
<option value="50" <if $min == 50>selected="selected"</if>>50</option>
<option value="51" <if $min == 51>selected="selected"</if>>51</option>
<option value="52" <if $min == 52>selected="selected"</if>>52</option>
<option value="53" <if $min == 53>selected="selected"</if>>53</option>
<option value="54" <if $min == 54>selected="selected"</if>>54</option>
<option value="55" <if $min == 55>selected="selected"</if>>55</option>
<option value="56" <if $min == 56>selected="selected"</if>>56</option>
<option value="57" <if $min == 57>selected="selected"</if>>57</option>
<option value="58" <if $min == 58>selected="selected"</if>>58</option>
<option value="59" <if $min == 59>selected="selected"</if>>59</option>
<option value="60" <if $min == 60>selected="selected"</if>>60</option>
</select> : 
<select name="sec">
<option value="0" <if $sec == 0 >selected="selected"</if>>00</option>
<option value="1" <if $sec == 1 >selected="selected"</if>>01</option>
<option value="2" <if $sec == 2 >selected="selected"</if>>02</option>
<option value="3" <if $sec == 3 >selected="selected"</if>>03</option>
<option value="4" <if $sec == 4 >selected="selected"</if>>04</option>
<option value="5" <if $sec == 5 >selected="selected"</if>>05</option>
<option value="6" <if $sec == 6 >selected="selected"</if>>06</option>
<option value="7" <if $sec == 7 >selected="selected"</if>>07</option>
<option value="8" <if $sec == 8 >selected="selected"</if>>08</option>
<option value="9" <if $sec == 9 >selected="selected"</if>>09</option>
<option value="10" <if $sec == 10 >selected="selected"</if>>10</option>
<option value="11" <if $sec == 11>selected="selected"</if>>11</option>
<option value="12" <if $sec == 12>selected="selected"</if>>12</option>
<option value="13" <if $sec == 13>selected="selected"</if>>13</option>
<option value="14" <if $sec == 14>selected="selected"</if>>14</option>
<option value="15" <if $sec == 15>selected="selected"</if>>15</option>
<option value="16" <if $sec == 16>selected="selected"</if>>16</option>
<option value="17" <if $sec == 17>selected="selected"</if>>17</option>
<option value="18" <if $sec == 18>selected="selected"</if>>18</option>
<option value="19" <if $sec == 19>selected="selected"</if>>19</option>
<option value="20" <if $sec == 20>selected="selected"</if>>20</option>
<option value="21" <if $sec == 21>selected="selected"</if>>21</option>
<option value="22" <if $sec == 22>selected="selected"</if>>22</option>
<option value="23" <if $sec == 23>selected="selected"</if>>23</option>
<option value="24" <if $sec == 24>selected="selected"</if>>24</option>
<option value="25" <if $sec == 25>selected="selected"</if>>25</option>
<option value="26" <if $sec == 26>selected="selected"</if>>26</option>
<option value="27" <if $sec == 27>selected="selected"</if>>27</option>
<option value="28" <if $sec == 28>selected="selected"</if>>28</option>
<option value="29" <if $sec == 29>selected="selected"</if>>29</option>
<option value="30" <if $sec == 30>selected="selected"</if>>30</option>
<option value="31" <if $sec == 31>selected="selected"</if>>31</option>
<option value="32" <if $sec == 32>selected="selected"</if>>32</option>
<option value="33" <if $sec == 33>selected="selected"</if>>33</option>
<option value="34" <if $sec == 34>selected="selected"</if>>34</option>
<option value="35" <if $sec == 35>selected="selected"</if>>35</option>
<option value="36" <if $sec == 36>selected="selected"</if>>36</option>
<option value="37" <if $sec == 37>selected="selected"</if>>37</option>
<option value="38" <if $sec == 38>selected="selected"</if>>38</option>
<option value="39" <if $sec == 39>selected="selected"</if>>39</option>
<option value="40" <if $sec == 40>selected="selected"</if>>40</option>
<option value="41" <if $sec == 41>selected="selected"</if>>41</option>
<option value="42" <if $sec == 42>selected="selected"</if>>42</option>
<option value="43" <if $sec == 43>selected="selected"</if>>43</option>
<option value="44" <if $sec == 44>selected="selected"</if>>44</option>
<option value="45" <if $sec == 45>selected="selected"</if>>45</option>
<option value="46" <if $sec == 46>selected="selected"</if>>46</option>
<option value="47" <if $sec == 47>selected="selected"</if>>47</option>
<option value="48" <if $sec == 48>selected="selected"</if>>48</option>
<option value="49" <if $sec == 49>selected="selected"</if>>49</option>
<option value="50" <if $sec == 50>selected="selected"</if>>50</option>
<option value="51" <if $sec == 51>selected="selected"</if>>51</option>
<option value="52" <if $sec == 52>selected="selected"</if>>52</option>
<option value="53" <if $sec == 53>selected="selected"</if>>53</option>
<option value="54" <if $sec == 54>selected="selected"</if>>54</option>
<option value="55" <if $sec == 55>selected="selected"</if>>55</option>
<option value="56" <if $sec == 56>selected="selected"</if>>56</option>
<option value="57" <if $sec == 57>selected="selected"</if>>57</option>
<option value="58" <if $sec == 58>selected="selected"</if>>58</option>
<option value="59" <if $sec == 59>selected="selected"</if>>59</option>
<option value="60" <if $sec == 60>selected="selected"</if>>60</option>
</select> UTC<br />
<input type="checkbox" name="noexpire" value="noexpire"<if $expiration==0> checked="checked"</if> /> <const S_SETNOEXPIRE>
</td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" value="<var $comment>" /></td></tr>
<tr><td class="postblock"><const S_TOTALBAN></td><td><input type="checkbox" name="total" value="yes"<if $total eq 'yes'> checked="checked"</if> style="float:left; clear:none" />
<input type="submit" value="<const S_UPDATE>" style="float: right; clear:none"/></td></tr>
</tbody></table></form></if>
<if $type eq 'whitelist'>
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="adminedit" />
<input type="hidden" name="type" value="whitelist" />
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="num" value="<var $num>" />
<table><tbody>
<tr><td class="postblock"><const S_BANIPLABEL></td><td><input type="text" name="ival1" size="24" value="<var dec_to_dot($ival1)>" /></td></tr>
<tr><td class="postblock"><const S_BANMASKLABEL></td><td><input type="text" name="ival2" size="24" value="<var dec_to_dot($ival2)>"/></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" value="<var $comment>" />
<input type="submit" value="<const S_UPDATE>" /></td></tr>
</tbody></table></form>
</if>
<if $type eq 'trust'>
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="adminedit" />
<input type="hidden" name="type" value="trust" />
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="num" value="<var $num>" />
<table><tbody>
<tr><td class="postblock"><const S_BANTRUSTTRIP></td><td><input type="text" name="sval1" size="24" value="<var $sval1>" /></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" value="<var $comment>" />
<input type="submit" value="<const S_UPDATE>" /></td></tr>
</tbody></table></form>
</if>
<if $type eq 'wordban'>
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="adminedit" />
<input type="hidden" name="type" value="wordban" />
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="num" value="<var $num>" />
<table><tbody>
<tr><td class="postblock"><const S_BANWORDLABEL></td><td><input type="text" name="sval1" size="24" value="<var $sval1>"/></td></tr>
<tr><td class="postblock"><const S_BANCOMMENTLABEL></td><td><input type="text" name="comment" size="16" value="<var $comment>" />
<input type="submit" value="<const S_UPDATE>" /></td></tr>
</tbody></table></form>
</if>
</loop>
</div>
}.MINI_FOOT_INCLUDE);


use constant PROXY_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><h2><const S_MANAPROXY></h2></div>
        
<div class="postarea">
<table><tbody><tr><td valign="bottom">

<if !ENABLE_PROXY_CHECK>
	<div class="dellist"><const S_PROXYDISABLED></div>
	<br />
</if>        </td></tr></tbody></table>
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="addproxy" />
<input type="hidden" name="type" value="white" />
<input type="hidden" name="admin" value="<var $admin>" />
<table><tbody>
<tr><td class="postblock"><const S_PROXYIPLABEL></td><td><input type="text" name="ip" size="24" /></td></tr>
<tr><td class="postblock"><const S_PROXYTIMELABEL></td><td><input type="text" name="timestamp" size="24" />
<input type="submit" value="<const S_PROXYWHITELIST>" /></td></tr>
</tbody></table></form>
</div><br />

<table align="center"><tbody>
<tr class="managehead"><const S_PROXYTABLE></tr>

<loop $scanned>
        <if $divider><tr class="managehead"><th colspan="6"></th></tr></if>

        <tr class="row<var $rowtype>">

        <if $type eq 'white'>
                <td>White</td>
	        <td><var $ip></td>
        	<td><var $timestamp+PROXY_WHITE_AGE-time()></td>
        </if>
        <if $type eq 'black'>
                <td>Black</td>
	        <td><var $ip></td>
        	<td><var $timestamp+PROXY_BLACK_AGE-time()></td>
        </if>

        <td><var $date></td>
        <td><a href="<var $self>?admin=<var $admin>&amp;task=removeproxy&amp;num=<var $num>"><const S_PROXYREMOVEBLACK></a></td>
        </tr>
</loop>
</tbody></table><br />

}.NORMAL_FOOT_INCLUDE);


use constant SPAM_PANEL_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div align="center">
<div class="dellist"><h2><const S_MANASPAM></h2></div>
<p><const S_SPAMEXPL></p>

<form action="<var $self>" method="post">

<input type="hidden" name="task" value="updatespam" />
<input type="hidden" name="admin" value="<var $admin>" />

<div class="buttons">
<input type="submit" value="<const S_SPAMSUBMIT>" />
<input type="button" value="<const S_SPAMCLEAR>" onclick="document.forms[0].spam.value=''" />
<input type="reset" value="<const S_SPAMRESET>" />
</div>

<textarea name="spam" rows="<var $spamlines>" cols="60"><var $spam></textarea>

<div class="buttons">
<input type="submit" value="<const S_SPAMSUBMIT>" />
<input type="button" value="<const S_SPAMCLEAR>" onclick="document.forms[0].spam.value=''" />
<input type="reset" value="<const S_SPAMRESET>" />
</div>

</form>

</div>

}.NORMAL_FOOT_INCLUDE);



use constant SQL_DUMP_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><h2><const S_MANASQLDUMP></h2></div>

<pre><code><var $database></code></pre>

}.NORMAL_FOOT_INCLUDE);



use constant SQL_INTERFACE_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><const S_MANASQLINT></div>

<div align="center">
<form action="<var $self>" method="post">
<input type="hidden" name="task" value="sql" />
<input type="hidden" name="admin" value="<var $admin>" />

<textarea name="sql" rows="10" cols="60"></textarea>

<div class="delbuttons"><const S_SQLNUKE>
<input type="password" name="nuke" value="<var $nuke>" />
<input type="submit" value="<const S_SQLEXECUTE>" />
</div>

</form>
</div>

<pre><code><var $results></code></pre>

}.NORMAL_FOOT_INCLUDE);




use constant ADMIN_POST_TEMPLATE => compile_template(MANAGER_HEAD_INCLUDE.q{

<div class="dellist"><h2>Manager Posting</h2></div>
	
<div align="center"><em><const S_NOTAGS></em></div>
<br />

<div class="postarea">
<form id="postform" action="<var $self>" method="post" enctype="multipart/form-data">
<input type="hidden" name="task" value="post" />
<input type="hidden" name="admin" value="<var $admin>" />
<input type="hidden" name="no_captcha" value="1" />
<input type="hidden" name="no_format" value="1" />

<table><tbody>
<tr><td class="postblock"><const S_NAME></td><td><input type="text" name="field1" size="28" /></td></tr>
<tr><td class="postblock"><const S_EMAIL></td><td><input type="text" name="email" size="28" /></td></tr>
<tr><td class="postblock"><const S_SUBJECT></td><td><input type="text" name="subject" size="35" />
<input type="submit" value="<const S_SUBMIT>" /></td></tr>
<tr><td class="postblock"><const S_COMMENT></td><td><textarea name="comment" cols="48" rows="4"></textarea></td></tr>
<tr><td class="postblock"><const S_UPLOADFILE></td><td><input type="file" name="file" size="35" />
[<label><input type="checkbox" name="nofile" value="on" /><const S_NOFILE></label>]
</td></tr>
<tr><td class="postblock"><const S_PARENT></td><td><input type="text" name="parent" size="8" /></td></tr>
<tr><td class="postblock"><const S_DELPASS></td><td><input type="password" name="password" size="8" /> (for post and file deletion)</td></tr>
<tr><td class="postblock">Options</td><td>[<label><input type="checkbox" name="sticky" value="1" /> Sticky Thread After Posting</label>]<br />[<label><input type="checkbox" name="lock" value="1" /> Lock Thread After Posting</label>]</td></tr>
</tbody></table></form></div><hr />
<script type="text/javascript">set_inputs("postform")</script>

}.NORMAL_FOOT_INCLUDE);



no strict;
$stylesheets=get_stylesheets(); # make stylesheets visible to the templates
use strict;

sub get_filename($) { my $path=shift; $path=~m!([^/]+)$!; clean_string($1) }

sub get_stylesheets()
{
	my $found=0;
	my @stylesheets=map
	{
		my %sheet;

		$sheet{filename}=$_;

		($sheet{title})=m!([^/]+)\.css$!i;
		$sheet{title}=ucfirst $sheet{title};
		$sheet{title}=~s/_/ /g;
		$sheet{title}=~s/ ([a-z])/ \u$1/g;
		$sheet{title}=~s/([a-z])([A-Z])/$1 $2/g;

		if($sheet{title} eq DEFAULT_STYLE) { $sheet{default}=1; $found=1; }
		else { $sheet{default}=0; }

		\%sheet;
	} glob(CSS_DIR."*.css");

	$stylesheets[0]{default}=1 if(@stylesheets and !$found);

	return \@stylesheets;
}

1;

