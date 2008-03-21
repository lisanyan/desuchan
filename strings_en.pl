use constant S_HOME => 'Home';										# Forwards to home page
use constant S_ADMIN => 'Manage';									# Forwards to Management Panel
use constant S_RETURN => 'Return';									# Returns to image board
use constant S_POSTING => 'Posting mode: Reply';					# Prints message in red bar atop the reply screen

use constant S_NAME => 'Name';										# Describes name field
use constant S_EMAIL => 'Link';									# Describes e-mail field
use constant S_SUBJECT => 'Subject';								# Describes subject field
use constant S_SUBMIT => 'Submit';									# Describes submit button
use constant S_COMMENT => 'Comment';								# Describes comment field
use constant S_UPLOADFILE => 'File';								# Describes file field
use constant S_NOFILE => 'No File';									# Describes file/no file checkbox
use constant S_CAPTCHA => 'Verification';							# Describes captcha field
use constant S_PARENT => 'Parent';									# Describes parent field on admin post page
use constant S_DELPASS => 'Password';								# Describes password field
use constant S_DELEXPL => '(for post and file deletion and editing)';			# Prints explanation for password box (to the right)
use constant S_SPAMTRAP => 'Leave these fields empty (spam trap): ';

use constant S_THUMB => 'Thumbnail displayed, click image for full size.';	# Prints instructions for viewing real source
use constant S_HIDDEN => 'Thumbnail hidden, click filename for the full image.';	# Prints instructions for viewing hidden image reply
use constant S_NOTHUMB => 'No<br />thumbnail';								# Printed when there's no thumbnail
use constant S_PICNAME => 'File: ';											# Prints text before upload name/link
use constant S_REPLY => 'Reply';											# Prints text for reply link
use constant S_OLD => 'Marked for deletion (old).';							# Prints text to be displayed before post is marked for deletion, see: retention
use constant S_ABBR => '%d posts omitted. Click Reply to view.';			# Prints text to be shown when replies are hidden
use constant S_ABBR_LOCK => '%d posts omitted. Click View to see them.';
use constant S_ABBRIMG => '%d posts and %d images omitted. Click Reply to view.';						# Prints text to be shown when replies and images are hidden
use constant S_ABBRTEXT => 'Comment too long. Click <a href="%s">here</a> to view the full text.';
use constant S_ABBRIMG_LOCK => '%d posts and %d images omitted. Click View to see them.';						# Prints text to be shown when replies and images are hidden

use constant S_REPDEL => 'Delete Post ';							# Prints text next to S_DELPICONLY (left)
use constant S_DELPICONLY => 'File Only';							# Prints text next to checkbox for file deletion (right)
use constant S_DELKEY => 'Password ';								# Prints text next to password field for deletion (left)
use constant S_DELETE => 'Delete';									# Defines deletion button's name

use constant S_PREV => 'Previous';									# Defines previous button
use constant S_FIRSTPG => 'Previous';								# Defines previous button
use constant S_NEXT => 'Next';										# Defines next button
use constant S_LASTPG => 'Next';									# Defines next button

use constant S_WEEKDAYS => ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');	# Defines abbreviated weekday names.

use constant S_MANARET => 'Return';										# Returns to HTML file instead of PHP--thus no log/SQLDB update occurs
use constant S_MANAMODE => 'Manager Mode';								# Prints heading on top of Manager page

use constant S_MANALOGIN => 'Manager Login';							# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_ADMINPASS => 'Admin password:';							# Prints login prompt

use constant S_MANAPANEL => 'Management Panel';							# Defines Management Panel radio button--allows the user to view the management panel (overview of all posts)
use constant S_MANABANS => 'Bans/Whitelist';							# Defines Bans Panel button
use constant S_MANAPROXY => 'Proxy Panel';
use constant S_MANASPAM => 'Spam';										# Defines Spam Panel button
use constant S_MANASQLDUMP => 'SQL Dump';								# Defines SQL dump button
use constant S_MANASQLINT => 'SQL Interface';							# Defines SQL interface button
use constant S_MANAPOST => 'Manager Post';								# Defines Manager Post radio button--allows the user to post using HTML code in the comment box
use constant S_MANAREBUILD => 'Rebuild caches';							# 
use constant S_MANANUKE => 'Nuke board';								# 
use constant S_MANALOGOUT => 'Log out';									# 
use constant S_MANASAVE => 'Remember me on this computer';				# Defines Label for the login cookie checbox
use constant S_MANASUB => 'Go';											# Defines name for submit button in Manager Mode

use constant S_NOTAGS => 'HTML tags allowed. No formatting will be done, you must use HTML for line breaks and paragraphs.'; # Prints message on Management Board

use constant S_MPDELETEIP => 'Delete all';
use constant S_MPDELETE => 'Delete';									# Defines for deletion button in Management Panel
use constant S_MPARCHIVE => 'Archive';
use constant S_MPRESET => 'Reset';										# Defines name for field reset button in Management Panel
use constant S_MPONLYPIC => 'File Only';								# Sets whether or not to delete only file, or entire post/thread
use constant S_MPDELETEALL => 'Del&nbsp;all';							# 
use constant S_MPBAN => 'Ban';											# Sets whether or not to delete only file, or entire post/thread
use constant S_MPTABLE => '<th>Post No.</th><th>Time</th><th>Subject</th>'.
                          '<th>Name</th><th>Comment</th><th>Options</th><th>IP</th>';	# Explains names for Management Panel
use constant S_IMGSPACEUSAGE => '[ Space used: %d KB ]';				# Prints space used KB by the board under Management Panel

use constant S_BANTABLE => '<th>Type</th><th>Value</th><th>Comment</th><th>Expires</th><th>Can Browse</th><th>Creator</th><th>Action</th>'; # EDITED Explains names for Ban Panel
use constant S_BANIPLABEL => 'IP';
use constant S_BANMASKLABEL => 'Mask';
use constant S_BANCOMMENTLABEL => 'Comment';
use constant S_BANWORDLABEL => 'Word';
use constant S_BANIP => 'Ban IP';
use constant S_BANWORD => 'Ban word';
use constant S_BANWHITELIST => 'Whitelist';
use constant S_BANREMOVE => 'Remove';
use constant S_BANCOMMENT => 'Comment';
use constant S_BANTRUST => 'No captcha';
use constant S_BANTRUSTTRIP => 'Tripcode';

use constant S_PROXYTABLE => '<th>Type</th><th>IP</th><th>Expires</th><th>Date</th>'; # Explains names for Proxy Panel
use constant S_PROXYIPLABEL => 'IP';
use constant S_PROXYTIMELABEL => 'Seconds to live';
use constant S_PROXYREMOVEBLACK => 'Remove';
use constant S_PROXYWHITELIST => 'Whitelist';
use constant S_PROXYDISABLED => 'Proxy detection is currently disabled in configuration.';
use constant S_BADIP => 'Bad IP value';

use constant S_SPAMEXPL => 'This is the list of domain names Wakaba considers to be spam.<br />'.
                           'You can find an up-to-date version <a href="http://wakaba.c3.cx/antispam/antispam.pl?action=view&amp;format=wakaba">here</a>, '.
                           'or you can get the <code>spam.txt</code> file directly <a href="http://wakaba.c3.cx/antispam/spam.txt">here</a>.';
use constant S_SPAMSUBMIT => 'Save';
use constant S_SPAMCLEAR => 'Clear';
use constant S_SPAMRESET => 'Restore';

use constant S_SQLNUKE => 'Nuke password:';
use constant S_SQLEXECUTE => 'Execute';

use constant S_TOOBIG => 'This image is too large!  Upload something smaller!';
use constant S_TOOBIGORNONE => 'Either this image is too big or there is no image at all.  Yeah.';
use constant S_REPORTERR => 'Error: Cannot find reply.';					# Returns error when a reply (res) cannot be found
use constant S_UPFAIL => 'Error: Upload failed.';							# Returns error for failed upload (reason: unknown?)
use constant S_NOREC => 'Error: Cannot find record.';						# Returns error when record cannot be found
use constant S_NOCAPTCHA => 'Error: No verification code on record - it probably timed out.';	# Returns error when there's no captcha in the database for this IP/key
use constant S_BADCAPTCHA => 'Error: Wrong verification code entered.';		# Returns error when the captcha is wrong
use constant S_BADFORMAT => 'Error: File format not supported.';			# Returns error when the file is not in a supported format.
use constant S_STRREF => 'Error: String refused.';							# Returns error when a string is refused
use constant S_UNJUST => 'Error: Unjust POST.';								# Returns error on an unjust POST - prevents floodbots or ways not using POST method?
use constant S_NOPIC => 'Error: No file selected. Did you forget to click "Reply"?';	# Returns error for no file selected and override unchecked
use constant S_NOTEXT => 'Error: No comment entered.';						# Returns error for no text entered in to subject/comment
use constant S_TOOLONG => 'Error: Too many characters in text field.';		# Returns error for too many characters in a given field
use constant S_NOTALLOWED => 'Error: Posting not allowed.';					# Returns error for non-allowed post types
use constant S_UNUSUAL => 'Error: Abnormal reply.';							# Returns error for abnormal reply? (this is a mystery!)
use constant S_BADHOST => 'Host is banned.';							# Returns error for banned host ($badip string)
use constant S_BADHOSTPROXY => 'Error: Proxy is banned for being open.';	# Returns error for banned proxy ($badip string)
use constant S_RENZOKU => 'Error: Flood detected, post discarded.';			# Returns error for $sec/post spam filter
use constant S_RENZOKU2 => 'Error: Flood detected, file discarded.';		# Returns error for $sec/upload spam filter
use constant S_RENZOKU3 => 'Error: Flood detected.';						# Returns error for $sec/similar posts spam filter.
use constant S_PROXY => 'Error: Open proxy detected.';						# Returns error for proxy detection.
use constant S_DUPE => 'Error: This file has already been posted <a href="%s">here in this thread</a>.';	# Returns error when an md5 checksum already exists.
use constant S_DUPENAME => 'Error: A file with the same name already exists.';	# Returns error when an filename already exists.
use constant S_NOTHREADERR => 'Error: Thread does not exist.';				# Returns error when a non-existant thread is accessed
use constant S_BADDELPASS => 'Error: Incorrect password for deletion.';		# Returns error for wrong password (when user tries to delete file)
use constant S_WRONGPASS => 'Error: Management password incorrect, or login timed out.';		# Returns error for wrong password (when trying to access Manager modes)
use constant S_VIRUS => 'Error: Possible virus-infected file.';				# Returns error for malformed files suspected of being virus-infected.
use constant S_NOTWRITE => 'Error: Could not write to directory.';				# Returns error when the script cannot write to the directory, the chmod (777) is wrong
use constant S_SPAM => 'Spammers are not welcome here.';					# Returns error when detecting spam

use constant S_SQLCONF => 'SQL connection failure';							# Database connection failure
use constant S_SQLFAIL => 'Critical SQL problem!';							# SQL Failure

use constant S_REDIR => 'If the redirect didn\'t work, please choose one of the following mirrors:';    # Redir message for html in REDIR_DIR

use constant S_BADHOST_ADMIN => 'Error: Manager Functions not Available Due to Banned Host.';		# Error message that appears when a banned IP tries to access moderator features
use constant S_BAN_WHY => 'You or another user of this IP or IP range was banned.';			# Subheader for banned IP page
use constant S_BAN_MISSING_REASON => 'No reason given. You should try refreshing this page, or you may need to speak with staff as this may be in error.';	# Appears if no Reason for the Ban is on Record
use constant S_BAN_APPEAL_HEADER => 'How to Appeal';							# Header for appealing instructions
# Instructions on Appealing. Feel free to customize.
use constant S_BAN_APPEAL => 'To appeal your ban, please visit <a href="http://www.desuchan.net/sugg/">the suggestions board</a>.<br /> Abusing this may result in permanent banishment from Desuchan\'s services.'; 
use constant S_BAN_NO_APPEAL => 'You may not appeal this ban.';						# Appears on banned IP page if no appealing is allowed. (NOT USED. KEPT IN CASE OF A REQUEST.)
use constant S_BANEXPIRE => 'Length of Ban, in Seconds<br />(Use 0 if permanent.)';			# Option in Ban Panel for adjusting ban length
use constant S_TOTALBAN => 'Ban from Browsing?';							# Option in Ban Panel for setting a ban prohibiting browsing content.
use constant S_BAN_REASON => 'Reason';									# Header for ban comment on the banned IP page
use constant S_CURRENT_IP => 'Your current IP is';							# Informs the user of the affected IP on the banned IP page.
use constant S_BAN_WILL_EXPIRE => 'This ban is set to expire';						# Appears before expiration date on banned IP page
use constant S_BAN_WILL_NOT_EXPIRE => 'This ban is not set to expire.';					# Appears on banned IP page if IP is permanently banned (or ban info is missing)
use constant S_COMMENT_A_MUST => 'Error: A Reason/Comment is Required';					# Returned if no reason/comment is entered when banning an IP 
use constant S_BANEXPIRE_EDIT => 'Time Ban Ends';							# Precedes the expiration date for the ban on the banned IP page
use constant S_UPDATE => 'Update';									# Name of submit button in the editor windows
use constant S_BANEDIT => 'Edit';									# Link name for the ban editor window
use constant S_ADMINOVERRIDE => 'To override, please input nuke password.';				# Precedes the field for typing in the admin's nuke password when a moderator is banned
use constant S_DATEPROBLEM => 'There is a problem with the date entered.';				# Appears if a bad date is entered on the ban editor page
use constant S_SETNOEXPIRE => 'No expiration';								# Appears in the ban panel for all permanent bans
use constant S_HTACCESSCANTREMOVE => 'Error: Cannot Remove .htaccess Entry.';				# Returned if an error occurs accessing .htaccess to remove a ban entry.
use constant S_HTACCESSPROBLEM => "Error: Ban Processed, but Error Accessing .htaccess.";		# Returned if an error occurs when accessing .htaccess to add a ban
use constant S_THREADLOCKEDERROR => "Error: Thread Locked.";						# Returned if a user attempts to add a post or edit an existing post in a locked thread.
use constant S_ALREADYSTICKIED => "Error: Already Stickied.";						# Returned if a moderator attempts to sticky a thread that was already stickied
use constant S_NOTATHREAD => "Error: What Was Specified is Not a Thread.";				# Returned if a moderator tries to sticky or lock a single post
use constant S_NOTSTICKIED => "Error: Does not Exist or is Already Unstickied";				# Returned if a moderator tries to lock a thread that was deleted or was already stickied
use constant S_ALREADYLOCKED => "Error: Already Locked.";						# Returned if a moderator tries to lock a thread that was already locked
use constant S_NOTLOCKED => "Error: Already Unlocked or Does Not Exist.";				# Returned if a moderator tries to unlock a thread that was deleted or already locked
use constant S_BADEDITPASS => "Error: Incorrect password for editing.";					# Returned if a user inputs the wrong password for editing
use constant S_NOPASS => "Error: No password was specified for this post.<br />It cannot be edited.";	# Returned if a bad password was given by a user when attempting to edit a post
use constant S_LASTEDITED => "Last edited";								# Precedes the editing date on the thread page if a post was edited
use constant S_BYMOD => "by moderator";									# Tagged to previous if the editing was done by a moderator
use constant S_STICKIED => "Sticky";									# Title for sticky image
use constant S_LOCKED => "Locked";									# Title for lock image
use constant S_STICKIEDALT => "(sticky)";								# Alternative text for sticky image
use constant S_LOCKEDALT => "(locked)";									# Alternative text for locked image
use constant S_STICKYOPTION => "Sticky";								# Option for stickying a thread in the moderator post panel
use constant S_LOCKOPTION => "Lock";									# Option for locking a thread in the moderator post panel
use constant S_UNSTICKYOPTION => "Unsticky";								# Option for unstickying a thread in the moderator post panel
use constant S_UNLOCKOPTION => "Unlock";								# Option for unlocking a thread in the moderator post panel
use constant S_LOCKEDANNOUNCE => "This thread is locked. You may not reply to this thread.";		# An announcement that appears in place of the post form in a locked thread
use constant S_VIEW => "View";										# Link to viewing the thread page if the thread is locked (and does not allow replies).
# Prompt for management password when editing a moderator post or moderator-edited post.
use constant S_PROMPTPASSWORDADMIN => "This post was created and/or edited by a moderator.<br />Please enter the password for management. ";
# Prompt for editing/deletion password for usual circumstances.
use constant S_PROMPTPASSWORD => "Please enter the deletion/editing password. ";
use constant S_NEWFILE => "New File";									# Prompt for replacement file in post-editing window
use constant S_STRINGFIELDMISSING => "Please input string to ban.";

#
# Oekaki
#

use constant S_OEKPAINT => 'Painter: ';									# Describes the oekaki painter to use
use constant S_OEKSOURCE => 'Source: ';							# Describes the source selector
use constant S_OEKNEW => 'New image';							# Describes the new image option
use constant S_OEKMODIFY => 'Modify No.%d';						# Describes an option to modify an image
use constant S_OEKX => 'Width: ';									# Describes x dimension for oekaki
use constant S_OEKY => 'Height: ';									# Describes y dimension for oekaki
use constant S_OEKSUBMIT => 'Paint!';									# Oekaki button used for submit
use constant S_OEKIMGREPLY => 'Reply';

use constant S_OEKIMGREPLY => 'Reply';
use constant S_OEKREPEXPL => 'Picture will be posted as a reply to thread <a href="%s">%s</a>.';

use constant S_OEKTOOBIG => 'The requested dimensions are too large.';
use constant S_OEKTOOSMALL => 'The requested dimensions are too small.';
use constant S_OEKUNKNOWN => 'Unknown oekaki painter requested.';
use constant S_HAXORING => 'Stop hax0ring the Gibson!';

use constant S_OEKPAINTERS => [
	{ painter=>"shi_norm", name=>"Shi Normal" },
	{ painter=>"shi_pro", name=>"Shi Pro" },
	{ painter=>"shi_norm_selfy", name=>"Shi Normal+Selfy" },
	{ painter=>"shi_pro_selfy", name=>"Shi Pro+Selfy" },
];

1;

