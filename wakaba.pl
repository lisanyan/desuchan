#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);

use strict;

use CGI;
use DBI;

# ADDED for Time Conversion Functions

use Time::Local;


#
# Import settings
#

use lib '.';
BEGIN { require "config.pl"; }
BEGIN { require "config_defaults.pl"; }
BEGIN { require "strings_en.pl"; }		# edit this line to change the language
BEGIN { require "futaba_style.pl"; }	# edit this line to change the board style
BEGIN { require "captcha.pl"; }
BEGIN { require "wakautils.pl"; }



#
# Optional modules
#

my ($has_encode);

if(CONVERT_CHARSETS)
{
	eval 'use Encode qw(decode encode)';
	$has_encode=1 unless($@);
}


#
# Global init
#

my $protocol_re=qr/(?:http|https|ftp|mailto|nntp|aim)/;

my $dbh=DBI->connect(SQL_DBI_SOURCE,SQL_USERNAME,SQL_PASSWORD,{AutoCommit=>1}) or make_error(S_SQLCONF);

return 1 if(caller); # stop here if we're being called externally

my $query=new CGI;
my $task=($query->param("task") or $query->param("action"));


# check for admin table
init_admin_database() if(!table_exists(SQL_ADMIN_TABLE));

# check for proxy table
init_proxy_database() if(!table_exists(SQL_PROXY_TABLE));

# ADDED - check for .htaccess

if (! -e "../.htaccess")
{
	open (HTACCESSMAKE, ">../.htaccess");
	print HTACCESSMAKE "RewriteEngine On\r\nOptions +FollowSymLinks +ExecCGI\r\n";
	close HTACCESSMAKE;
}

# END ADDED

if(!table_exists(SQL_TABLE)) # check for comments table
{
	init_database();
	build_cache();
	make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
	exit;
}

# ADDED - check for and remove old bans

my $oldbans=$dbh->prepare("SELECT ival1, total FROM ".SQL_ADMIN_TABLE." WHERE expiration <= ".time()." AND expiration <> 0 AND expiration IS NOT NULL;");
$oldbans->execute() or make_error(S_SQLFAIL);
my @unbanned_ips;
while (my $banrow = get_decoded_hashref($oldbans))
{
	push @unbanned_ips, $$banrow{ival1};
	if ($$banrow{total} eq 'yes')
	{
		my $ip = dec_to_dot($$banrow{ival1});
		remove_htaccess_entry($ip);
	}
}
foreach (my $i = 0; $i <= $#unbanned_ips; $i++)
{	
	my $removeban = $dbh->prepare("DELETE FROM ".SQL_ADMIN_TABLE." WHERE ival1=?") or make_error(S_SQLFAIL);
	$removeban->execute($unbanned_ips[$i]) or make_error(S_SQLFAIL);
}

if(!$task)
{
	build_cache() unless -e HTML_SELF;
	make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
}
elsif($task eq "post")
{
	my $parent=$query->param("parent");
	my $name=$query->param("field1");
	my $email=$query->param("email");
	my $subject=$query->param("subject");
	my $comment=$query->param("comment");
	my $file=$query->param("file");
	my $password=$query->param("password");
	my $nofile=$query->param("nofile");
	my $captcha=$query->param("captcha");
	my $admin=$query->param("admin");
	my $no_captcha=$query->param("no_captcha");
	my $no_format=$query->param("no_format");
	my $postfix=$query->param("postfix");
	my $sticky=$query->param("sticky");
	my $lock=$query->param("lock");

	post_stuff($parent,$name,$email,$subject,$comment,$file,$file,$password,$nofile,$captcha,$admin,$no_captcha,$no_format,$postfix,$sticky,$lock);
}
elsif($task eq "delete")
{
	my $password = $query->param("password");
	my $fileonly = $query->param("fileonly");
	my $archive=$query->param("archive");
	my $fromwindow = $query->param("fromwindow"); # Is it from a window/widget? 
	my $admin=$query->param("admin");
	my @posts=$query->param("delete");

	delete_stuff($password,$fileonly,$archive,$admin,$fromwindow,@posts);
}
elsif($task eq "admin")
{
	my $password=$query->param("berra"); # lol obfuscation
	my $nexttask=$query->param("nexttask");
	my $savelogin=$query->param("savelogin");
	my $admincookie=$query->cookie("wakaadmin");

	do_login($password,$nexttask,$savelogin,$admincookie);
}
elsif($task eq "logout")
{
	do_logout();
}
elsif($task eq "mpanel")
{
	my $admin=$query->param("admin");
	make_admin_post_panel($admin);
}
elsif($task eq "deleteall")
{
	my $admin=$query->param("admin");
	my $ip=$query->param("ip");
	my $mask=$query->param("mask");
	delete_all($admin,parse_range($ip,$mask));
}
elsif($task eq "bans")
{
	my $admin=$query->param("admin");
	my $ip=$query->param("ip");
	make_admin_ban_panel($admin,$ip);
}
elsif($task eq "addip")
{
	my $admin=$query->param("admin");
	my $type=$query->param("type");
	my $comment=$query->param("comment");
	my $ip=$query->param("ip");
	my $mask=$query->param("mask");
	my $total=$query->param("total"); # ADDED
	my $expiration=$query->param("expiration"); # ADDED
	add_admin_entry($admin,$type,$comment,parse_range($ip,$mask),'',$total,$expiration); 
	# EDITED from add_admin_entry($admin,$type,$comment,parse_range($ip,$mask),'')
}
elsif($task eq "addstring")
{
	my $admin=$query->param("admin");
	my $type=$query->param("type");
	my $string=$query->param("string");
	my $comment=$query->param("comment");
	add_admin_entry($admin,$type,$comment,0,0,$string,'',''); # EDITED
}
elsif($task eq "removeban")
{
	my $admin=$query->param("admin");
	my $num=$query->param("num");
	remove_admin_entry($admin,$num,0,0); # EDITED to accomodate $override, $noredirect
}
elsif($task eq "proxy")
{
	my $admin=$query->param("admin");
	make_admin_proxy_panel($admin);
}
elsif($task eq "addproxy")
{
	my $admin=$query->param("admin");
	my $type=$query->param("type");
	my $ip=$query->param("ip");
	my $timestamp=$query->param("timestamp");
	my $date=make_date(time(),DATE_STYLE);
	add_proxy_entry($admin,$type,$ip,$timestamp,$date);
}
elsif($task eq "removeproxy")
{
	my $admin=$query->param("admin");
	my $num=$query->param("num");
	remove_proxy_entry($admin,$num);
}
elsif($task eq "spam")
{
	my ($admin);
	$admin=$query->param("admin");
	make_admin_spam_panel($admin);
}
elsif($task eq "updatespam")
{
	my $admin=$query->param("admin");
	my $spam=$query->param("spam");
	update_spam_file($admin,$spam);
}
elsif($task eq "sqldump")
{
	my $admin=$query->param("admin");
	make_sql_dump($admin);
}
elsif($task eq "sql")
{
	my $admin=$query->param("admin");
	my $nuke=$query->param("nuke");
	my $sql=$query->param("sql");
	make_sql_interface($admin,$nuke,$sql);
}
elsif($task eq "mpost")
{
	my $admin=$query->param("admin");
	make_admin_post($admin);
}
elsif($task eq "rebuild")
{
	my $admin=$query->param("admin");
	do_rebuild_cache($admin);
}
elsif($task eq "nuke")
{
	my $admin=$query->param("admin");
	do_nuke_database($admin);
}
elsif($task eq "banreport") # ADDED for server-based ban redirects
{
	host_is_banned(dot_to_dec($ENV{REMOTE_ADDR}));
}
elsif($task eq "adminedit") # ADDED for editing bans, whitelists, etc.
{
	my $admin = $query -> param("admin");
	my $num = $query->param("num");
	my $type = $query->param("type");
	my $comment = $query->param("comment");
	my $ival1 = $query->param("ival1");
	my $ival2 = $query->param("ival2");
	my $sval1 = $query->param("sval1");
	my $total = $query->param("total");
	my $sec = $query->param("sec"); # Expiration Info
	my $min = $query->param("min");
	my $hour = $query->param("hour");
	my $day = $query->param("day");
	my $month = $query->param("month");
	my $year = $query->param("year");
	my $noexpire = $query->param("noexpire");
	edit_admin_entry($admin,$num,$type,$comment,$ival1,$ival2,$sval1,$total,$sec,$min,$hour,$day,$month,$year,$noexpire);
}
elsif($task eq "baneditwindow") # ADDED for editing ban stats and settings
{
	my $admin = $query->param("admin");
	my $num = $query->param("num");
	make_admin_ban_edit($admin, $num);	
}
elsif($task eq "adminunban") # ADDED for overriding a ban affecting an admin with the nuke pass
{
	my $admin = $query->param("admin");
	my $nuke = $query->param("nuke");
	remove_ban_on_admin($admin, $nuke);
}
elsif($task eq "editpostwindow") # ADDED for the post editing interface
{
	my $num = $query->param("num");
	my $password = $query->param("password");
	my $admin = $query->param("admin");
	edit_window($num, $password, $admin);	
}
elsif($task eq "delpostwindow")
{
	my $num = $query->param("num");
	password_window($num, '', "delete");
}
elsif($task eq "editpost") # ADDED for the post updating process when editing
{
	my $num = $query->param("num");
	my $name = $query->param("field1");
	my $email = $query->param("email");
	my $subject=$query->param("subject");
	my $comment=$query->param("comment");
	my $file=$query->param("file");
	my $captcha=$query->param("captcha");
	my $admin=$query->param("admin");                
	my $no_captcha=$query->param("no_captcha");
	my $no_format=$query->param("no_format");
	my $postfix=$query->param("postfix");
	my $password = $query->param("password");
	my $killtrip = $query->param("killtrip");
	edit_shit($num,$name,$email,$subject,$comment,$file,$file,$password,$captcha,$admin,$no_captcha,$no_format,$postfix,$killtrip);
}
elsif($task eq "edit") # ADDED for displaying the password prompts when editing
{
	my $num = $query->param("num");
	my $admin_post = $query->param("admin_post");
	password_window($num, $admin_post, "edit");
}
elsif($task eq "sticky") # ADDED for stickying threads
{
	my $num = $query->param("thread");
	my $admin = $query->param("admin");
	sticky($num, $admin);
}
elsif($task eq "unsticky") # ADDED for unstickying threads
{
	my $num = $query->param("thread");
	my $admin = $query->param("admin");
	unsticky($num, $admin);
}
elsif($task eq "lock") # ADDED for locking threads
{
	my $num = $query->param("thread");
	my $admin = $query->param("admin");
	lock_thread($num, $admin);
}
elsif($task eq "unlock") # ADDED for unlocking threads
{
	my $num = $query->param("thread");
	my $admin = $query->param("admin");
	unlock_thread($num, $admin);
}

$dbh->disconnect();





#
# Cache page creation
#

sub build_cache()
{
	my ($sth,$row,@thread);
	my $page=0;
	
	# grab all posts, in thread order (ugh, ugly kludge)
	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." ORDER BY stickied DESC, lasthit DESC, CASE parent WHEN 0 THEN num ELSE parent END ASC, num ASC;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	$row=get_decoded_hashref($sth);

	if(!$row) # no posts on the board!
	{
		build_cache_page(0,1); # make an empty page 0
	}
	else
	{
		my @threads;
		my @thread=($row);

		while($row=get_decoded_hashref($sth))
		{
			if(!$$row{parent})
			{
				push @threads,{posts=>[@thread]};
				@thread=($row); # start new thread
			}
			else
			{
				push @thread,$row;
			}
		}
		push @threads,{posts=>[@thread]};

		my $total=get_page_count(scalar @threads);
		my @pagethreads;
		while(@pagethreads=splice @threads,0,IMAGES_PER_PAGE)
		{
			build_cache_page($page,$total,@pagethreads);
			$page++;
		}
	}

	# check for and remove old pages
	while(-e $page.PAGE_EXT)
	{
		unlink $page.PAGE_EXT;
		$page++;
	}
}

sub build_cache_page($$@)
{
	my ($page,$total,@threads)=@_;
	my ($filename,$tmpname);

	if($page==0) { $filename=HTML_SELF; }
	else { $filename=$page.PAGE_EXT; }

	# do abbrevations and such
	foreach my $thread (@threads)
	{
		# split off the parent post, and count the replies and images
		my ($parent,@replies)=@{$$thread{posts}};
		my $replies=@replies;
		my $images=grep { $$_{image} } @replies;
		my $curr_replies=$replies;
		my $curr_images=$images;
		my $max_replies=REPLIES_PER_THREAD;
		my $max_images=(IMAGE_REPLIES_PER_THREAD or $images);

		# drop replies until we have few enough replies and images
		while($curr_replies>$max_replies or $curr_images>$max_images)
		{
			my $post=shift @replies;
			$curr_images-- if($$post{image});
			$curr_replies--;
		}

		# write the shortened list of replies back
		$$thread{posts}=[$parent,@replies];
		$$thread{omit}=$replies-$curr_replies;
		$$thread{omitimages}=$images-$curr_images;

		# abbreviate the remaining posts
		foreach my $post (@{$$thread{posts}})
		{
			my $abbreviation=abbreviate_html($$post{comment},MAX_LINES_SHOWN,APPROX_LINE_LENGTH);
			if($abbreviation)
			{
				$$post{comment}=$abbreviation;
				$$post{abbrev}=1;
			}
		}
	}

	# make the list of pages
	my @pages=map +{ page=>$_ },(0..$total-1);
	foreach my $p (@pages)
	{
		if($$p{page}==0) { $$p{filename}=expand_filename(HTML_SELF) } # first page
		else { $$p{filename}=expand_filename($$p{page}.PAGE_EXT) }
		if($$p{page}==$page) { $$p{current}=1 } # current page, no link
	}

	my ($prevpage,$nextpage);
	$prevpage=$pages[$page-1]{filename} if($page!=0);
	$nextpage=$pages[$page+1]{filename} if($page!=$total-1);

	print_page($filename,PAGE_TEMPLATE->(
		postform=>(ALLOW_TEXTONLY or ALLOW_IMAGES),
		image_inp=>ALLOW_IMAGES,
		textonly_inp=>(ALLOW_IMAGES and ALLOW_TEXTONLY),
		prevpage=>$prevpage,
		nextpage=>$nextpage,
		pages=>\@pages,
		threads=>\@threads
	));
}

sub build_thread_cache($)
{
	my ($thread)=@_;
	my ($sth,$row,@thread);
	my ($filename,$tmpname);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=? OR parent=? ORDER BY num ASC;") or make_error(S_SQLFAIL);
	$sth->execute($thread,$thread) or make_error(S_SQLFAIL);

	while($row=get_decoded_hashref($sth)) { push(@thread,$row); }

	make_error(S_NOTHREADERR) if($thread[0]{parent});

	$filename=RES_DIR.$thread.PAGE_EXT;

	print_page($filename,PAGE_TEMPLATE->(
		thread=>$thread,
		postform=>(ALLOW_TEXT_REPLIES or ALLOW_IMAGE_REPLIES),
		image_inp=>ALLOW_IMAGE_REPLIES,
		textonly_inp=>0,
		dummy=>$thread[$#thread]{num},
		lockedthread=>$thread[0]{locked},
		threads=>[{posts=>\@thread}])
	);
}

sub print_page($$)
{
	my ($filename,$contents)=@_;

	$contents=encode_string($contents);
#		$PerlIO::encoding::fallback=0x0200 if($has_encode);
#		binmode PAGE,':encoding('.CHARSET.')' if($has_encode);

	if(USE_TEMPFILES)
	{
		my $tmpname=RES_DIR.'tmp'.int(rand(1000000000));

		open (PAGE,">$tmpname") or make_error(S_NOTWRITE);
		print PAGE $contents;
		close PAGE;

		rename $tmpname,$filename;
	}
	else
	{
		open (PAGE,">$filename") or make_error(S_NOTWRITE);
		print PAGE $contents;
		close PAGE;
	}
}

sub build_thread_cache_all()
{
	my ($sth,$row,@thread);

	$sth=$dbh->prepare("SELECT num FROM ".SQL_TABLE." WHERE parent=0;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	while($row=$sth->fetchrow_arrayref())
	{
		build_thread_cache($$row[0]);
	}
}



#
# Posting
#

sub post_stuff($$$$$$$$$$$$$$$)
{
	my ($parent,$name,$email,$subject,$comment,$file,$uploadname,$password,$nofile,$captcha,$admin,$no_captcha,$no_format,$postfix,$sticky,$lock)=@_;
	
	# get a timestamp for future use
	my $time=time();
	
	# ADDED - admin post variable
	my $admin_post = '';

	# check that the request came in as a POST, or from the command line
	make_error(S_UNJUST) if($ENV{REQUEST_METHOD} and $ENV{REQUEST_METHOD} ne "POST");
	
	# ADDED - Is the thread stickied?

	if ($parent)
	{
		my $selectsticky=$dbh->prepare("SELECT stickied, locked FROM ".SQL_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
		$selectsticky->execute($parent) or make_error(S_SQLFAIL);
		my $sticky_check = $selectsticky->fetchrow_hashref;
	
		if ($$sticky_check{locked} eq 'yes' && !$admin)
		{
			make_error(S_THREADLOCKEDERROR);
		}
		
		if ($$sticky_check{stickied})
		{
			$sticky = 1;
		} 
		else 
		{
			$sticky = 0 unless $admin;
		}
		$selectsticky->finish();
	}

	if($admin) # check admin password - allow both encrypted and non-encrypted
	{
		check_password($admin,ADMIN_PASS);
		$admin_post = 'yes' unless $postfix; # It's not an admin post if the oekaki postfix is present.
	}
	else
	{
		# forbid admin-only features
		make_error(S_WRONGPASS) if($no_captcha or $no_format or $postfix or ($sticky && !$parent) or $lock);

		# check what kind of posting is allowed
		if($parent)
		{
			make_error(S_NOTALLOWED) if($file and !ALLOW_IMAGE_REPLIES);
			make_error(S_NOTALLOWED) if(!$file and !ALLOW_TEXT_REPLIES);
		}
		else
		{
			make_error(S_NOTALLOWED) if($file and !ALLOW_IMAGES);
			make_error(S_NOTALLOWED) if(!$file and !ALLOW_TEXTONLY);
		}
	}
	
	if ($sticky && $parent)
	{
		my $stickyupdate=$dbh->prepare("UPDATE ".SQL_TABLE." SET stickied=1 WHERE num=? OR parent=?;") or make_error(S_SQLFAIL);
		$stickyupdate->execute($parent, $parent) or make_error(S_SQLFAIL);
	}
	
	if ($lock)
	{
		if ($parent)
		{
			my $lockupdate=$dbh->prepare("UPDATE ".SQL_TABLE." SET locked='yes' WHERE num=? OR parent=?;") or make_error(S_SQLFAIL);
			$lockupdate->execute($parent, $parent) or make_error(S_SQLFAIL);
		}
		$lock='yes';
	}

	# check for weird characters
	make_error(S_UNUSUAL) if($parent=~/[^0-9]/);
	make_error(S_UNUSUAL) if(length($parent)>10);
	make_error(S_UNUSUAL) if($name=~/[\n\r]/);
	make_error(S_UNUSUAL) if($email=~/[\n\r]/);
	make_error(S_UNUSUAL) if($subject=~/[\n\r]/);

	# check for excessive amounts of text
	make_error(S_TOOLONG) if(length($name)>MAX_FIELD_LENGTH);
	make_error(S_TOOLONG) if(length($email)>MAX_FIELD_LENGTH);
	make_error(S_TOOLONG) if(length($subject)>MAX_FIELD_LENGTH);
	make_error(S_TOOLONG) if(length($comment)>MAX_COMMENT_LENGTH);

	# check to make sure the user selected a file, or clicked the checkbox
	make_error(S_NOPIC) if(!$parent and !$file and !$nofile);

	# check for empty reply or empty text-only post
	make_error(S_NOTEXT) if($comment=~/^\s*$/ and !$file);

	# get file size, and check for limitations.
	my $size=get_file_size($file) if($file);

	# find IP
	my $ip=$ENV{REMOTE_ADDR};

	#$host = gethostbyaddr($ip);
	my $numip=dot_to_dec($ip);

	# set up cookies
	my $c_name=$name;
	my $c_email=$email;
	my $c_password=$password;

	# check if IP is whitelisted
	my $whitelisted=is_whitelisted($numip);

	# process the tripcode - maybe the string should be decoded later
	my $trip;
	($name,$trip)=process_tripcode($name,TRIPKEY,SECRET,CHARSET);

	# check for bans
	ban_check($numip,$c_name,$subject,$comment) unless $whitelisted;

	# spam check
	spam_engine(
		query=>$query,
		trap_fields=>SPAM_TRAP?["name","link"]:[],
		spam_files=>[SPAM_FILES],
		charset=>CHARSET,
	) unless $whitelisted;

	# check captcha
	check_captcha($dbh,$captcha,$ip,$parent) if(ENABLE_CAPTCHA and !$no_captcha and !is_trusted($trip));

	# proxy check
	proxy_check($ip) if (!$whitelisted and ENABLE_PROXY_CHECK);

	# check if thread exists, and get lasthit value
	my ($parent_res,$lasthit);
	if($parent)
	{
		$parent_res=get_parent_post($parent) or make_error(S_NOTHREADERR);
		$lasthit=$$parent_res{lasthit};
	}
	else
	{
		$lasthit=$time;
	}


	# kill the name if anonymous posting is being enforced
	if(FORCED_ANON)
	{
		$name='';
		$trip='';
		if($email=~/sage/i) { $email='sage'; }
		else { $email=''; }
	}

	# clean up the inputs
	$email=clean_string(decode_string($email,CHARSET));
	$subject=clean_string(decode_string($subject,CHARSET));

	# fix up the email/link
	$email="mailto:$email" if $email and $email!~/^$protocol_re:/;
	
	# check subject field for 'noko'
	my $noko = 0;
	if ($subject =~ m/^noko$/i)
	{
		$subject = '';
		$noko = 1;
	}

	# format comment
	$comment=format_comment(clean_string(decode_string($comment,CHARSET))) unless $no_format;
	$comment.=$postfix;

	# insert default values for empty fields
	$parent=0 unless $parent;
	$name=make_anonymous($ip,$time) unless $name or $trip;
	$subject=S_ANOTITLE unless $subject;
	$comment=S_ANOTEXT unless $comment;

	# flood protection - must happen after inputs have been cleaned up
	flood_check($numip,$time,$comment,$file,1);

	# Manager and deletion stuff - duuuuuh?

	# generate date
	my $date=make_date($time+11*3600,DATE_STYLE);

	# generate ID code if enabled
	$date.=' ID:'.make_id_code($ip,$time,$email) if(DISPLAY_ID);

	# copy file, do checksums, make thumbnail, etc
	my ($filename,$md5,$width,$height,$thumbnail,$tn_width,$tn_height)=process_file($file,$uploadname,$time,$parent) if($file);

	$sticky = 0 if (!$sticky);
	
	# finally, write to the database
	my $sth=$dbh->prepare("INSERT INTO ".SQL_TABLE." VALUES(null,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,'','',?,?,?);") or make_error(S_SQLFAIL);
	$sth->execute($parent,$time,$lasthit,$numip,
	$date,$name,$trip,$email,$subject,$password,$comment,
	$filename,$size,$md5,$width,$height,$thumbnail,$tn_width,$tn_height,$admin_post,$sticky,$lock) or make_error(S_SQLFAIL);

	if($parent) # bumping
	{
		# check for sage, or too many replies
		unless($email=~/sage/i or sage_count($parent_res)>MAX_RES)
		{
			$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET lasthit=$time WHERE num=? OR parent=?;") or make_error(S_SQLFAIL);
			$sth->execute($parent,$parent) or make_error(S_SQLFAIL);
		}
	}

	# remove old threads from the database
	trim_database();

	# update the cached HTML pages
	build_cache();

	# update the individual thread cache
	if($parent) { build_thread_cache($parent); }
	else # must find out what our new thread number is
	{
		if($filename)
		{
			$sth=$dbh->prepare("SELECT num FROM ".SQL_TABLE." WHERE image=?;") or make_error(S_SQLFAIL);
			$sth->execute($filename) or make_error(S_SQLFAIL);
		}
		else
		{
			$sth=$dbh->prepare("SELECT num FROM ".SQL_TABLE." WHERE timestamp=? AND comment=?;") or make_error(S_SQLFAIL);
			$sth->execute($time,$comment) or make_error(S_SQLFAIL);
		}
		my $num=($sth->fetchrow_array())[0];

		if($num)
		{
			build_thread_cache($num);
			$parent = $num; # ADDED
		}
	}

	# set the name, email and password cookies
	make_cookies(name=>$c_name,email=>$c_email,password=>$c_password,
	-charset=>CHARSET,-autopath=>COOKIE_PATH); # yum!

	# forward back to the main page
	make_http_forward(HTML_SELF,ALTERNATE_REDIRECT) unless $noko;
	
	# ...unless we have "noko" (a la 4chan)--then forward to thread
	# ($parent contains current post number if a new thread was posted)
	make_http_forward(RES_DIR.$parent.PAGE_EXT,ALTERNATE_REDIRECT);
}

# Post Editing

sub edit_window($$$) # ADDED subroutine for creating the post-edit window
{
	my ($num, $password, $admin)=@_;
	my @loop;
	my $sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=?;");
	$sth->execute($num);
	check_password_editing_mode($admin, ADMIN_PASS) if $admin;
	while (my $row = get_decoded_hashref($sth))
	{
		make_error_small(S_NOPASS) if ($$row{password} eq '' && !$admin);
		make_error_small(S_BADEDITPASS) if ($$row{password} ne $password && !$admin);
		make_error_small(S_THREADLOCKEDERROR) if ($$row{locked} eq 'yes' && !$admin);
		make_error_small(S_WRONGPASS) if ($$row{admin_post} eq 'yes' && !$admin);
		push @loop, $row;
	}
	make_http_header();
	print encode_string(POST_EDIT_TEMPLATE->(admin=>$admin, password=>$password, loop=>\@loop)); 
	$sth->finish();
}

sub tag_killa($) # ADDED - subroutine for stripping HTML tags and supplanting them with corresponding wakabamark
{
	my $tag_killa = $_[0];
	$tag_killa =~ s/<p><small><strong> Oekaki post<\/strong> \(Time\:.*?<\/small><\/p>//; # Strip Oekaki postfix.
	$tag_killa =~ s/<br\s?\/?>/\n/g;
	$tag_killa =~ s/<\/p>$//;
	$tag_killa =~ s/<\/p>/\n\n/g;
	$tag_killa =~ s/<code>([^\n]*?)<\/code>/\`$1\`/g;
	while($tag_killa =~ m/<\s*?code>(.*?)<\/\s*?code>/s)
	{
		my $replace = $1;
		my @strings = split (/\n/, $replace);
		for (my $i = 0; $i <= $#strings; $i++)
		{
			$strings[$i] = '    '.$strings[$i];
		}
		my $replace2 = join ("\n", @strings);
		$tag_killa =~ s/<\s*?code>$replace<\/\s*?code>/$replace2\n\n/s;
	}
	while ($tag_killa =~ m/<ul>(.*?)<\/ul>/)
	{
		my $replace = $1;
		my $replace2 = $replace;
		my @strings = split (/<\/li>/, $replace2);
		for (my $i = 0; $i <= $#strings; $i++)
		{
			$strings[$i] =~ s/<li>/\* /;
		}
		$replace2 = join ("\n", @strings);
		$tag_killa =~ s/<ul>$replace<\/ul>/$replace2\n\n/gs;
	}
	while ($tag_killa =~ m/<ol>(.*?)<\/ol>/)
	{
		my $replace = $1;
		my $replace2 = $replace;
		my @strings = split (/<\/li>/, $replace2);
		for (my $i = 0; $i <= $#strings; $i++)
		{
			my $count = $i + 1;
			$strings[$i] =~ s/<li>/$count\. /;
		}
		$replace2 = join ("\n", @strings);
		$tag_killa =~ s/<ol>$replace<\/ol>/$replace2\n\n/gs;
	}	
	$tag_killa =~ s/<\/?em>/\*/g;
	$tag_killa =~ s/<\/?strong>/\*\*/g;
	$tag_killa =~ s/<.*?>//g;
	$tag_killa;
}
	

sub password_window($$$)
{
	my ($num,$admin_post,$type) = @_;
	make_http_header();
	if ($type eq "edit")
	{
		print encode_string(PASSWORD->(num=>$num, admin_post=>$admin_post));
	} 
	else # Deleting
	{
		print encode_string(DELPASSWORD->(num=>$num));
	}
}
	

sub edit_shit($$$$$$$$$$$$$$) # ADDED subroutine for post editing
{
	my ($num,$name,$email,$subject,$comment,$file,$uploadname,$password,$captcha,$admin,$no_captcha,$no_format,$postfix,$killtrip)=@_;
	# get a timestamp for future use
	my $time=time();
	
	my $admin_post = '';
			# Variable to declare whether this is an admin-edited post.
			# (This is done to lock-out users from editing something edited by a mod.)
			# I do not recommend moderator editing under most circumstances.
	
	# Grab original information from the target post
	my $select=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num = ?;");
	$select->execute($num);
	
	my $row = get_decoded_hashref($select);
	
	# check that the thread is not locked
	make_error(S_THREADLOCKEDERROR) if ($$row{locked} eq 'yes' && !$admin);
	
	# check that the request came in as a POST, or from the command line
	make_error(S_UNJUST) if($ENV{REQUEST_METHOD} and $ENV{REQUEST_METHOD} ne "POST");

	if($admin) # check admin password - allow both encrypted and non-encrypted
	{
		check_password_editing_mode($admin,ADMIN_PASS);
		$admin_post = 'yes' unless $postfix;
	}
	else
	{
		# forbid admin-only features or editing an admin post
		make_error_small(S_WRONGPASS) if($no_captcha or $no_format or $postfix or $$row{admin_post} eq 'yes');
		
		# No password = No editing. (Otherwise, chaos could ensue....)
		make_error_small(S_NOPASS) if ($$row{password} eq '');
	
		# Check password.
		make_error_small(S_BADEDITPASS) if ($$row{password} ne $password);

		# check what kind of posting is allowed
		if($$row{parent})
		{
			make_error_small(S_NOTALLOWED) if($file and !ALLOW_IMAGE_REPLIES);
		}
		else
		{
			make_error_small(S_NOTALLOWED) if($file and !ALLOW_IMAGES);
		}
		
		# Only staff can change management posts and edits
		make_error_small("Only management can edit this.") if ($$row{admin_post} eq 'yes');
	}

	# check for weird characters
	make_error_small(S_UNUSUAL) if($name=~/[\n\r]/);
	make_error_small(S_UNUSUAL) if($email=~/[\n\r]/);
	make_error_small(S_UNUSUAL) if($subject=~/[\n\r]/);

	# check for excessive amounts of text
	make_error_small(S_TOOLONG) if(length($name)>MAX_FIELD_LENGTH);
	make_error_small(S_TOOLONG) if(length($email)>MAX_FIELD_LENGTH);
	make_error_small(S_TOOLONG) if(length($subject)>MAX_FIELD_LENGTH);
	make_error_small(S_TOOLONG) if(length($comment)>MAX_COMMENT_LENGTH);

	# check for empty reply or empty text-only post
	make_error_small(S_NOTEXT) if($comment=~/^\s*$/ and !$file and !$$row{filename});

	# get file size, and check for limitations.
	my $size=get_file_size($file) if($file);

	# find IP
	my $ip=$ENV{REMOTE_ADDR};

	#$host = gethostbyaddr($ip);
	my $numip=dot_to_dec($ip);

	# set up cookies
	my $c_name=$name;
	my $c_email=$email;
	my $c_password=$password;

	# check if IP is whitelisted
	my $whitelisted=is_whitelisted($numip);

	# process the tripcode - maybe the string should be decoded later
	my $trip;
	($name,$trip)=process_tripcode($name,TRIPKEY,SECRET,CHARSET);
	$trip = '' if $killtrip;

	# check for bans
	ban_check($numip,$c_name,$subject,$comment) unless $whitelisted;

	# spam check
	spam_engine(
		query=>$query,
		trap_fields=>SPAM_TRAP?["name","link"]:[],
		spam_files=>[SPAM_FILES],
		charset=>CHARSET,
	) unless $whitelisted;

	# check captcha
	check_captcha($dbh,$captcha,$ip,$$row{parent}) if(ENABLE_CAPTCHA and !$no_captcha and !is_trusted($trip));

	# proxy check
	proxy_check($ip) if (!$whitelisted and ENABLE_PROXY_CHECK);

	# kill the name if anonymous posting is being enforced
	if(FORCED_ANON)
	{
		$name='';
		$trip='';
		if($email=~/sage/i) { $email='sage'; }
		else { $email=''; }
	}

	# clean up the inputs
	$email=clean_string(decode_string($email,CHARSET));
	$subject=clean_string(decode_string($subject,CHARSET));

	# fix up the email/link
	$email="mailto:$email" if $email and $email!~/^$protocol_re:/;

	# format comment
	$comment=format_comment(clean_string(decode_string($comment,CHARSET))) unless $no_format;
	
	# ADDED - check for past oekaki postfix and attach it to the current comment if necessary
	if (!$postfix && !$admin && !$file)
	{
		if ($$row{comment} =~ m/(<p><small><strong> Oekaki post<\/strong> \(Time\:.*?<\/small><\/p>)/)
		{
			$comment.=$1;
		}
	}
	elsif ($file && $postfix)
	{
		if ($$row{comment} =~ m/(<p><small><strong> Oekaki post<\/strong> \(Time\:.*?<\/small><\/p>)/)
		{
			my $oekaki_original = $1;
			$oekaki_original =~ s/<\/small><\/p>//;
			$comment.=$oekaki_original;
			$postfix =~ s/<p><small><strong>/<br \/><strong>/;
		}
		$comment.=$postfix;
	}
	else
	{
		$comment.=$postfix;
	}

	# insert default values for empty fields
	$name=make_anonymous($ip,$time) unless $name or $trip;
	$subject=S_ANOTITLE unless $subject;
	$comment=S_ANOTEXT unless $comment;

	# flood protection - must happen after inputs have been cleaned up
	flood_check($numip,$time,$comment,$file,0);

	# Manager and deletion stuff - duuuuuh?

	# generate date
	my $date=make_date($time+11*3600,DATE_STYLE);

	# generate ID code if enabled
	$date.=' ID:'.make_id_code($ip,$time,$email) if(DISPLAY_ID);

	# copy file, do checksums, make thumbnail, etc
	 if($file)
	 {
		 my ($filename,$md5,$width,$height,$thumbnail,$tn_width,$tn_height)=process_file($file,$uploadname,$time,$$row{parent});
		 my $filesth=$dbh->prepare("UPDATE ".SQL_TABLE." SET image=?, md5=?, width=?, height=?, thumbnail=?,tn_width=?,tn_height=? WHERE num=?")
		 	or make_error_small(S_SQLFAIL);
		 $filesth->execute($filename,$md5,$width,$height,$thumbnail,$tn_width,$tn_height, $num) or make_error(S_SQLFAIL);
		 # now delete original files
		 if ($$row{image} ne '') { unlink $$row{image}; }
		 my $thumb=THUMB_DIR;
		 if ($$row{thumbnail} =~ /^$thumb/) { unlink $$row{thumbnail}; }
	 }
	
	# close old dbh handle
	$select->finish(); 
	
	# finally, write to the database
	my $sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET name=?,trip=?,subject=?,email=?,comment=?,lastedit=?,lastedit_ip=?,admin_post=? WHERE num=?;") or make_error_small(S_SQLFAIL);
	$sth->execute($name,($trip || $killtrip) ? $trip : $$row{trip},$subject,$email,$comment,$date,$numip,$admin_post,$num) or make_error_small(S_SQLFAIL);

	# remove old threads from the database
	trim_database();

	# update the cached HTML pages
	build_cache();

	# update the individual thread cache
	if($$row{parent}) { build_thread_cache($$row{parent}); }
	else # rebuild cache for edited OP
	{
		build_thread_cache($num);
	}

	# redirect to confirmation page
	make_http_header();
	print encode_string(EDIT_SUCCESSFUL->()); 
}

sub sticky($$)
{
	my ($num, $admin) = @_;
	check_password($admin, ADMIN_PASS);
	my $sth=$dbh->prepare("SELECT parent, stickied FROM ".SQL_TABLE." WHERE num=? LIMIT 1;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	my $row=get_decoded_hashref($sth);
	if (!$$row{parent})
	{
		make_error(S_ALREADYSTICKIED) if $$row{stickied}; 
		my $update=$dbh->prepare("UPDATE ".SQL_TABLE." SET stickied=1 WHERE num=? OR parent=?;") or make_error(S_SQLFAIL);
		$update->execute($num, $num) or make_error(S_SQLFAIL);
	}
	else
	{
		make_error(S_NOTATHREAD);
	}
	
	build_thread_cache($num);
	build_cache();
	make_http_forward(get_script_name()."?admin=$admin&task=mpanel",ALTERNATE_REDIRECT);
}

sub unsticky($$)
{
	my ($num, $admin) = @_;
	check_password($admin, ADMIN_PASS);
	my $sth=$dbh->prepare("SELECT parent, stickied FROM ".SQL_TABLE." WHERE num=? LIMIT 1;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	my $row=get_decoded_hashref($sth);
	if (!$$row{parent})
	{
		make_error(S_NOTSTICKIED) if !$$row{stickied}; 
		my $update=$dbh->prepare("UPDATE ".SQL_TABLE." SET stickied=0 WHERE num=? OR parent=?;") 
			or make_error(S_SQLFAIL);
		$update->execute($num, $num) or make_error(S_SQLFAIL);
	}
	else
	{
		make_error("A Post, Not a Thread, Was Specified");
	}
	
	build_thread_cache($num);
	build_cache();
	make_http_forward(get_script_name()."?admin=$admin&task=mpanel",ALTERNATE_REDIRECT);
}

sub lock_thread($$)
{
	my ($num, $admin) = @_;
	check_password($admin, ADMIN_PASS);
	my $sth=$dbh->prepare("SELECT parent, locked FROM ".SQL_TABLE." WHERE num=? LIMIT 1;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	my $row=get_decoded_hashref($sth);
	if (!$$row{parent})
	{
		make_error(S_ALREADYLOCKED) if ($$row{locked} eq 'yes');
		my $update=$dbh->prepare("UPDATE ".SQL_TABLE." SET locked='yes' WHERE num=? OR parent=?;") 
			or make_error(S_SQLFAIL);
		$update->execute($num, $num) or make_error(S_SQLFAIL);
	}
	else
	{
		make_error(S_NOTATHREAD);
	}
	
	build_thread_cache($num);
	build_cache();
	make_http_forward(get_script_name()."?admin=$admin&task=mpanel",ALTERNATE_REDIRECT);
}

sub unlock_thread($$)
{
	my ($num, $admin) = @_;
	check_password($admin, ADMIN_PASS);
	my $sth=$dbh->prepare("SELECT parent, locked FROM ".SQL_TABLE." WHERE num=? LIMIT 1;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	my $row=get_decoded_hashref($sth);
	if (!$$row{parent})
	{
		make_error() if ($$row{locked} ne 'yes');
		my $update=$dbh->prepare("UPDATE ".SQL_TABLE." SET locked='' WHERE num=? OR parent=?;") 
			or make_error(S_SQLFAIL);
		$update->execute($num, $num) or make_error(S_SQLFAIL);
	}
	else
	{
		make_error(S_NOTATHREAD);
	}
	
	build_thread_cache($num);
	build_cache();
	make_http_forward(get_script_name()."?admin=$admin&task=mpanel",ALTERNATE_REDIRECT);
}

sub is_whitelisted($)
{
	my ($numip)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='whitelist' AND ? & ival2 = ival1 & ival2;") or make_error(S_SQLFAIL);
	$sth->execute($numip) or make_error(S_SQLFAIL);

	return 1 if(($sth->fetchrow_array())[0]);

	return 0;
}

sub is_trusted($)
{
	my ($trip)=@_;
	my ($sth);
        $sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='trust' AND sval1 = ?;") or make_error(S_SQLFAIL);
        $sth->execute($trip) or make_error(S_SQLFAIL);

        return 1 if(($sth->fetchrow_array())[0]);

	return 0;
}

sub ban_admin_check($$)
{
	my ($ip, $admin) = @_;
	my $sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='ipban' AND ? & ival2 = ival1 & ival2;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);
	admin_is_banned($ip, $admin) if (($sth->fetchrow_array())[0]);
}

sub ban_check($$$$)
{
	my ($numip,$name,$subject,$comment)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='ipban' AND ? & ival2 = ival1 & ival2;") or make_error(S_SQLFAIL);
	$sth->execute($numip) or make_error(S_SQLFAIL);

	host_is_banned($numip) if (($sth->fetchrow_array())[0]); # EDITED FROM make_error(S_BADHOST) if(($sth->fetchrow_array())[0]);

# fucking mysql...
#	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_ADMIN_TABLE." WHERE type='wordban' AND ? LIKE '%' || sval1 || '%';") or make_error(S_SQLFAIL);
#	$sth->execute($comment) or make_error(S_SQLFAIL);
#
#	make_error(S_STRREF) if(($sth->fetchrow_array())[0]);

	$sth->finish();

	$sth=$dbh->prepare("SELECT sval1 FROM ".SQL_ADMIN_TABLE." WHERE type='wordban';") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	my $row;
	while($row=$sth->fetchrow_arrayref())
	{
		my $regexp=quotemeta $$row[0];
		make_error(S_STRREF) if($comment=~/$regexp/);
		make_error(S_STRREF) if($name=~/$regexp/);
		make_error(S_STRREF) if($subject=~/$regexp/);
	}

	# etc etc etc

	return(0);
}

sub host_is_banned($) # ADDED subroutine for handling bans
{
	my $numip = $_[0];
	
	my $sth=$dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE type='ipban' AND ? & ival2 = ival1 & ival2;") or make_error(S_SQLFAIL);
	$sth->execute($numip) or make_error(S_SQLFAIL);
	
	my ($comment, $expiration);
	
	while (my $baninfo = $sth->fetchrow_hashref())
	{
		if ($comment && $comment ne '') # In the event that there are several bans affecting one IP
		{
			$comment .= "<br /><br />+ ".$$baninfo{comment};
		}
		else
		{			
			$comment = $$baninfo{comment};
		}
		$expiration = ($$baninfo{expiration}) ? epoch_to_human($$baninfo{expiration}) : 0 
			unless ($expiration > $$baninfo{expiration} && $$baninfo{expiration} != 0);
	}
	
	$comment = S_BAN_MISSING_REASON if ($comment eq '' || !defined($comment));
	
	my $appeal = S_BAN_APPEAL;
		
	make_http_header();

	print encode_string(BAN_TEMPLATE->(numip => dec_to_dot($numip), comment => $comment, appeal => $appeal, expiration => $expiration));
	
	$sth->finish();
	$dbh->{Warn}=0;
	$dbh->disconnect();

	if(ERRORLOG)
	{
		open ERRORFILE,'>>'.ERRORLOG;
		print ERRORFILE S_BADHOST."\n";
		print ERRORFILE $ENV{HTTP_USER_AGENT}."\n";
		print ERRORFILE "**\n";
		close ERRORFILE;
	}

	# delete temp files

	exit;
}

sub admin_is_banned($)
{
	my ($numip, $admin) = @_;
	

	make_http_header();

	print encode_string(BAN_TEMPLATE_ADMIN->(admin => $admin));

	$dbh->{Warn}=0;
	$dbh->disconnect();

	if(ERRORLOG)
	{
		open ERRORFILE,'>>'.ERRORLOG;
		print ERRORFILE S_BADHOST."\n";
		print ERRORFILE $ENV{HTTP_USER_AGENT}."\n";
		print ERRORFILE "**\n";
		close ERRORFILE;
	}

	# delete temp files

	exit;
}

sub flood_check($$$$$)
{
	my ($ip,$time,$comment,$file,$repeat_ok)=@_;
	my ($sth,$maxtime);

	if($file)
	{
		# check for to quick file posts
		$maxtime=$time-(RENZOKU2);
		$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE ip=? AND timestamp>$maxtime;") or make_error(S_SQLFAIL);
		$sth->execute($ip) or make_error(S_SQLFAIL);
		make_error(S_RENZOKU2) if(($sth->fetchrow_array())[0]);
	}
	else
	{
		# check for too quick replies or text-only posts
		$maxtime=$time-(RENZOKU);
		$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE ip=? AND timestamp>$maxtime;") or make_error(S_SQLFAIL);
		$sth->execute($ip) or make_error(S_SQLFAIL);
		make_error(S_RENZOKU) if(($sth->fetchrow_array())[0]);

		# check for repeated messages
		if ($repeat_ok) # If the post is being edited, the comment field does not have to change.
		{
			$maxtime=$time-(RENZOKU3);
			$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE ip=? AND comment=? AND timestamp>$maxtime;") or make_error(S_SQLFAIL);
			$sth->execute($ip,$comment) or make_error(S_SQLFAIL);
			make_error(S_RENZOKU3) if(($sth->fetchrow_array())[0]);
		}
	}
}

sub proxy_check($)
{
	my ($ip)=@_;
	my ($sth);

	proxy_clean();

	# check if IP is from a known banned proxy
	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_PROXY_TABLE." WHERE type='black' AND ip = ?;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);

	make_error(S_BADHOSTPROXY) if(($sth->fetchrow_array())[0]);

	# check if IP is from a known non-proxy
	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_PROXY_TABLE." WHERE type='white' AND ip = ?;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);

        my $timestamp=time();
        my $date=make_date($timestamp,DATE_STYLE);

	if(($sth->fetchrow_array())[0])
	{	# known good IP, refresh entry
		$sth=$dbh->prepare("UPDATE ".SQL_PROXY_TABLE." SET timestamp=?, date=? WHERE ip=?;") or make_error(S_SQLFAIL);
		$sth->execute($timestamp,$date,$ip) or make_error(S_SQLFAIL);
	}
	else
	{	# unknown IP, check for proxy
		my $command = PROXY_COMMAND . " " . $ip;
		$sth=$dbh->prepare("INSERT INTO ".SQL_PROXY_TABLE." VALUES(null,?,?,?,?);") or make_error(S_SQLFAIL);

		if(`$command`)
		{
			$sth->execute('black',$ip,$timestamp,$date) or make_error(S_SQLFAIL);
			make_error(S_PROXY);
		} 
		else
		{
			$sth->execute('white',$ip,$timestamp,$date) or make_error(S_SQLFAIL);
		}
	}
}

sub add_proxy_entry($$$$$)
{
	my ($admin,$type,$ip,$timestamp,$date)=@_;
	my ($sth);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	# Verifies IP range is sane. The price for a human-readable db...
	unless ($ip =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ && $1 <= 255 && $2 <= 255 && $3 <= 255 && $4 <= 255) {
		make_error(S_BADIP);
	}
	if ($type = 'white') { 
		$timestamp = $timestamp - PROXY_WHITE_AGE + time(); 
	}
	else
	{
		$timestamp = $timestamp - PROXY_BLACK_AGE + time(); 
	}	

	# This is to ensure user doesn't put multiple entries for the same IP
	$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE ip=?;") or make_error(S_SQLFAIL);
	$sth->execute($ip) or make_error(S_SQLFAIL);

	# Add requested entry
	$sth=$dbh->prepare("INSERT INTO ".SQL_PROXY_TABLE." VALUES(null,?,?,?,?);") or make_error(S_SQLFAIL);
	$sth->execute($type,$ip,$timestamp,$date) or make_error(S_SQLFAIL);

        make_http_forward(get_script_name()."?admin=$admin&task=proxy",ALTERNATE_REDIRECT);
}

sub proxy_clean()
{
	my ($sth,$timestamp);

	if(PROXY_BLACK_AGE == PROXY_WHITE_AGE)
	{
		$timestamp = time() - PROXY_BLACK_AGE;
		$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE timestamp<?;") or make_error(S_SQLFAIL);
		$sth->execute($timestamp) or make_error(S_SQLFAIL);
	} 
	else
	{
		$timestamp = time() - PROXY_BLACK_AGE;
		$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE type='black' AND timestamp<?;") or make_error(S_SQLFAIL);
		$sth->execute($timestamp) or make_error(S_SQLFAIL);

		$timestamp = time() - PROXY_WHITE_AGE;
		$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE type='white' AND timestamp<?;") or make_error(S_SQLFAIL);
		$sth->execute($timestamp) or make_error(S_SQLFAIL);
	}
}

sub remove_proxy_entry($$)
{
	my ($admin,$num)=@_;
	my ($sth);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	$sth=$dbh->prepare("DELETE FROM ".SQL_PROXY_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);

	make_http_forward(get_script_name()."?admin=$admin&task=proxy",ALTERNATE_REDIRECT);
}

sub format_comment($)
{
	my ($comment)=@_;

	# hide >>1 references from the quoting code
	$comment=~s/&gt;&gt;([0-9\-]+)/&gtgt;$1/g;

	my $handler=sub # fix up >>1 references
	{
		my $line=shift;

		$line=~s!&gtgt;([0-9]+)!
			my $res=get_post($1);
			if($res) { '<a href="'.get_reply_link($$res{num},$$res{parent}).'" onclick="highlight('.$1.')">&gt;&gt;'.$1.'</a>' }
			else { "&gt;&gt;$1"; }
		!ge;			

		return $line;
	};

	if(ENABLE_WAKABAMARK) { $comment=do_wakabamark($comment,$handler) }
	else { $comment="<p>".simple_format($comment,$handler)."</p>" }

	# fix <blockquote> styles for old stylesheets
	$comment=~s/<blockquote>/<blockquote class="unkfunc">/g;

	# restore >>1 references hidden in code blocks
	$comment=~s/&gtgt;/&gt;&gt;/g;

	return $comment;
}

sub simple_format($@)
{
	my ($comment,$handler)=@_;
	return join "<br />",map
	{
		my $line=$_;

		# make URLs into links
		$line=~s{(https?://[^\s<>"]*?)((?:\s|<|>|"|\.|\)|\]|!|\?|,|&#44;|&quot;)*(?:[\s<>"]|$))}{\<a href="$1"\>$1\</a\>$2}sgi;

		# colour quoted sections if working in old-style mode.
		$line=~s!^(&gt;[^_]*)$!\<span class="unkfunc"\>$1\</span\>!g unless(ENABLE_WAKABAMARK);

		$line=$handler->($line) if($handler);

		$line;
	} split /\n/,$comment;
}

sub encode_string($)
{
	my ($str)=@_;

	return $str unless($has_encode);
	return encode(CHARSET,$str,0x0400);
}

sub make_anonymous($$)
{
	my ($ip,$time)=@_;

	return S_ANONAME unless(SILLY_ANONYMOUS);

	my $string=$ip;
	$string.=",".int($time/86400) if(SILLY_ANONYMOUS=~/day/i);
	$string.=",".$ENV{SCRIPT_NAME} if(SILLY_ANONYMOUS=~/board/i);

	srand unpack "N",hide_data($string,4,"silly",SECRET);

	return cfg_expand("%G% %W%",
		W => ["%B%%V%%M%%I%%V%%F%","%B%%V%%M%%E%","%O%%E%","%B%%V%%M%%I%%V%%F%","%B%%V%%M%%E%","%O%%E%","%B%%V%%M%%I%%V%%F%","%B%%V%%M%%E%"],
		B => ["B","B","C","D","D","F","F","G","G","H","H","M","N","P","P","S","S","W","Ch","Br","Cr","Dr","Bl","Cl","S"],
		I => ["b","d","f","h","k","l","m","n","p","s","t","w","ch","st"],
		V => ["a","e","i","o","u"],
		M => ["ving","zzle","ndle","ddle","ller","rring","tting","nning","ssle","mmer","bber","bble","nger","nner","sh","ffing","nder","pper","mmle","lly","bling","nkin","dge","ckle","ggle","mble","ckle","rry"],
		F => ["t","ck","tch","d","g","n","t","t","ck","tch","dge","re","rk","dge","re","ne","dging"],
		O => ["Small","Snod","Bard","Billing","Black","Shake","Tilling","Good","Worthing","Blythe","Green","Duck","Pitt","Grand","Brook","Blather","Bun","Buzz","Clay","Fan","Dart","Grim","Honey","Light","Murd","Nickle","Pick","Pock","Trot","Toot","Turvey"],
		E => ["shaw","man","stone","son","ham","gold","banks","foot","worth","way","hall","dock","ford","well","bury","stock","field","lock","dale","water","hood","ridge","ville","spear","forth","will"],
		G => ["Albert","Alice","Angus","Archie","Augustus","Barnaby","Basil","Beatrice","Betsy","Caroline","Cedric","Charles","Charlotte","Clara","Cornelius","Cyril","David","Doris","Ebenezer","Edward","Edwin","Eliza","Emma","Ernest","Esther","Eugene","Fanny","Frederick","George","Graham","Hamilton","Hannah","Hedda","Henry","Hugh","Ian","Isabella","Jack","James","Jarvis","Jenny","John","Lillian","Lydia","Martha","Martin","Matilda","Molly","Nathaniel","Nell","Nicholas","Nigel","Oliver","Phineas","Phoebe","Phyllis","Polly","Priscilla","Rebecca","Reuben","Samuel","Sidney","Simon","Sophie","Thomas","Walter","Wesley","William"],
	);
}

sub make_id_code($$$)
{
	my ($ip,$time,$link)=@_;

	return EMAIL_ID if($link and DISPLAY_ID=~/link/i);
	return EMAIL_ID if($link=~/sage/i and DISPLAY_ID=~/sage/i);

	return resolve_host($ENV{REMOTE_ADDR}) if(DISPLAY_ID=~/host/i);
	return $ENV{REMOTE_ADDR} if(DISPLAY_ID=~/ip/i);

	my $string="";
	$string.=",".int($time/86400) if(DISPLAY_ID=~/day/i);
	$string.=",".$ENV{SCRIPT_NAME} if(DISPLAY_ID=~/board/i);

	return mask_ip($ENV{REMOTE_ADDR},make_key("mask",SECRET,32).$string) if(DISPLAY_ID=~/mask/i);

	return hide_data($ip.$string,6,"id",SECRET,1);
}

sub get_post($)
{
	my ($thread)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($thread) or make_error(S_SQLFAIL);

	return $sth->fetchrow_hashref();
}

sub get_parent_post($)
{
	my ($thread)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=? AND parent=0;") or make_error(S_SQLFAIL);
	$sth->execute($thread) or make_error(S_SQLFAIL);

	return $sth->fetchrow_hashref();
}

sub sage_count($)
{
	my ($parent)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE parent=? AND NOT ( timestamp<? AND ip=? );") or make_error(S_SQLFAIL);
	$sth->execute($$parent{num},$$parent{timestamp}+(NOSAGE_WINDOW),$$parent{ip}) or make_error(S_SQLFAIL);

	return ($sth->fetchrow_array())[0];
}

sub get_file_size($)
{
	my ($file)=@_;
	my (@filestats,$size);

	@filestats=stat $file;
	$size=$filestats[7];

	make_error(S_TOOBIG) if($size>MAX_KB*1024);
	make_error(S_TOOBIGORNONE) if($size==0); # check for small files, too?

	return($size);
}

sub process_file($$$$)
{
	my ($file,$uploadname,$time,$parent)=@_;
	my %filetypes=FILETYPES;

	# make sure to read file in binary mode on platforms that care about such things
	binmode $file;

	# analyze file and check that it's in a supported format
	my ($ext,$width,$height)=analyze_image($file,$uploadname);

	my $known=($width or $filetypes{$ext});

	make_error(S_BADFORMAT) unless(ALLOW_UNKNOWN or $known);
	make_error(S_BADFORMAT) if(grep { $_ eq $ext } FORBIDDEN_EXTENSIONS);
	make_error(S_TOOBIG) if(MAX_IMAGE_WIDTH and $width>MAX_IMAGE_WIDTH);
	make_error(S_TOOBIG) if(MAX_IMAGE_HEIGHT and $height>MAX_IMAGE_HEIGHT);
	make_error(S_TOOBIG) if(MAX_IMAGE_PIXELS and $width*$height>MAX_IMAGE_PIXELS);

	# generate random filename - fudges the microseconds
	my $filebase=$time.sprintf("%03d",int(rand(1000)));
	my $filename=IMG_DIR.$filebase.'.'.$ext;
	my $thumbnail=THUMB_DIR.$filebase."s.jpg";
	$filename.=MUNGE_UNKNOWN unless($known);

	# do copying and MD5 checksum
	my ($md5,$md5ctx,$buffer);

	# prepare MD5 checksum if the Digest::MD5 module is available
	eval 'use Digest::MD5 qw(md5_hex)';
	$md5ctx=Digest::MD5->new unless($@);

	# copy file
	open (OUTFILE,">>$filename") or make_error(S_NOTWRITE);
	binmode OUTFILE;
	while (read($file,$buffer,1024)) # should the buffer be larger?
	{
		print OUTFILE $buffer;
		$md5ctx->add($buffer) if($md5ctx);
	}
	close $file;
	close OUTFILE;

	if($md5ctx) # if we have Digest::MD5, get the checksum
	{
		$md5=$md5ctx->hexdigest();
	}
	else # otherwise, try using the md5sum command
	{
		my $md5sum=`md5sum $filename`; # filename is always the timestamp name, and thus safe
		($md5)=$md5sum=~/^([0-9a-f]+)/ unless($?);
	}

	if($md5 && $parent) # if we managed to generate an md5 checksum, check for duplicate files in the same thread
	{
		my $sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE md5=? AND (parent=? OR num=?);") or make_error(S_SQLFAIL);
		$sth->execute($md5, $parent, $parent) or make_error(S_SQLFAIL);

		if(my $match=$sth->fetchrow_hashref())
		{
			unlink $filename; # make sure to remove the file
			make_error(sprintf(S_DUPE,get_reply_link($$match{num},$parent)));
		}
	}

	# do thumbnail
	my ($tn_width,$tn_height,$tn_ext);

	if(!$width) # unsupported file
	{
		if($filetypes{$ext}) # externally defined filetype
		{
			open THUMBNAIL,$filetypes{$ext};
			binmode THUMBNAIL;
			($tn_ext,$tn_width,$tn_height)=analyze_image(\*THUMBNAIL,$filetypes{$ext});
			close THUMBNAIL;

			# was that icon file really there?
			if(!$tn_width) { $thumbnail=undef }
			else { $thumbnail=$filetypes{$ext} }
		}
		else
		{
			$thumbnail=undef;
		}
	}
	elsif($width>MAX_W or $height>MAX_H or THUMBNAIL_SMALL)
	{
		if($width<=MAX_W and $height<=MAX_H)
		{
			$tn_width=$width;
			$tn_height=$height;
		}
		else
		{
			$tn_width=MAX_W;
			$tn_height=int(($height*(MAX_W))/$width);

			if($tn_height>MAX_H)
			{
				$tn_width=int(($width*(MAX_H))/$height);
				$tn_height=MAX_H;
			}
		}

		if(STUPID_THUMBNAILING) { $thumbnail=$filename }
		else
		{
			$thumbnail=undef unless(make_thumbnail($filename,$thumbnail,$tn_width,$tn_height,THUMBNAIL_QUALITY,CONVERT_COMMAND));
		}
	}
	else
	{
		$tn_width=$width;
		$tn_height=$height;
		$thumbnail=$filename;
	}

	if($filetypes{$ext}) # externally defined filetype - restore the name
	{
		my $newfilename=$uploadname;
		$newfilename=~s!^.*[\\/]!!; # cut off any directory in filename
		$newfilename=IMG_DIR.$newfilename;

		unless(-e $newfilename) # verify no name clash
		{
			rename $filename,$newfilename;
			$thumbnail=$newfilename if($thumbnail eq $filename);
			$filename=$newfilename;
		}
		else
		{
			unlink $filename;
			make_error(S_DUPENAME);
		}
	}

        if(ENABLE_LOAD)
        {       # only called if files to be distributed across web     
                $ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;
		my $root=$1;
                system(LOAD_SENDER_SCRIPT." $filename $root $md5 &");
        }


	return ($filename,$md5,$width,$height,$thumbnail,$tn_width,$tn_height);
}



#
# Deleting
#

sub delete_stuff($$$$$@)
{
	my ($password,$fileonly,$archive,$admin,$fromwindow,@posts)=@_;
	my ($post);

	if($admin)
	{
	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED
	}
	
	make_error(S_BADDELPASS) unless($password or $admin); # refuse empty password immediately

	# no password means delete always
	$password="" if($admin); 

	foreach $post (@posts)
	{
		delete_post($post,$password,$fileonly,$archive);
	}

	# update the cached HTML pages
	build_cache();

	if($admin)
	{ make_http_forward(get_script_name()."?admin=$admin&task=mpanel",ALTERNATE_REDIRECT); }
	elsif ($fromwindow)
	{ make_http_header(); print encode_string(EDIT_SUCCESSFUL->());  }
	else
	{ make_http_forward(HTML_SELF,ALTERNATE_REDIRECT); }
}

sub delete_post($$$$)
{
	my ($post,$password,$fileonly,$archiving)=@_;
	my ($sth,$row,$res,$reply);
	my $thumb=THUMB_DIR;
	my $archive=ARCHIVE_DIR;
	my $src=IMG_DIR;

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($post) or make_error(S_SQLFAIL);

	if($row=$sth->fetchrow_hashref())
	{
		make_error(S_BADDELPASS) if($password and $$row{password} ne $password);

		unless($fileonly)
		{
			# remove files from comment and possible replies
			$sth=$dbh->prepare("SELECT image,thumbnail FROM ".SQL_TABLE." WHERE num=? OR parent=?") or make_error(S_SQLFAIL);
			$sth->execute($post,$post) or make_error(S_SQLFAIL);

			while($res=$sth->fetchrow_hashref())
			{
				system(LOAD_SENDER_SCRIPT." $$res{image} &") if(ENABLE_LOAD);
	
				if($archiving)
				{
					# archive images
					rename $$res{image}, ARCHIVE_DIR.$$res{image};
					rename $$res{thumbnail}, ARCHIVE_DIR.$$res{thumbnail} if($$res{thumbnail}=~/^$thumb/);
				}
				else
				{
					# delete images if they exist
					unlink $$res{image};
					unlink $$res{thumbnail} if($$res{thumbnail}=~/^$thumb/);
				}
			}

			# remove post and possible replies
			$sth=$dbh->prepare("DELETE FROM ".SQL_TABLE." WHERE num=? OR parent=?;") or make_error(S_SQLFAIL);
			$sth->execute($post,$post) or make_error(S_SQLFAIL);
		}
		else # remove just the image and update the database
		{
			if($$row{image})
			{
				system(LOAD_SENDER_SCRIPT." $$row{image} &") if(ENABLE_LOAD);

				# remove images
				unlink $$row{image};
				unlink $$row{thumbnail} if($$row{thumbnail}=~/^$thumb/);

				$sth=$dbh->prepare("UPDATE ".SQL_TABLE." SET size=0,md5=null,thumbnail=null WHERE num=?;") or make_error(S_SQLFAIL);
				$sth->execute($post) or make_error(S_SQLFAIL);
			}
		}

		# fix up the thread cache
		if(!$$row{parent})
		{
			unless($fileonly) # removing an entire thread
			{
				if($archiving)
				{
					my $captcha = CAPTCHA_SCRIPT;
					my $line;

					open RESIN, '<', RES_DIR.$$row{num}.PAGE_EXT;
					open RESOUT, '>', ARCHIVE_DIR.RES_DIR.$$row{num}.PAGE_EXT;
					while($line = <RESIN>)
					{
						$line =~ s/img src="(.*?)$thumb/img src="$1$archive$thumb/g;
						if(ENABLE_LOAD)
						{
							my $redir = REDIR_DIR;
							$line =~ s/href="(.*?)$redir(.*?).html/href="$1$archive$src$2/g;
						}
						else
						{
							$line =~ s/href="(.*?)$src/href="$1$archive$src/g;
						}
						$line =~ s/src="[^"]*$captcha[^"]*"/src=""/g if(ENABLE_CAPTCHA);
						print RESOUT $line;	
					}
					close RESIN;
					close RESOUT;
				}
				unlink RES_DIR.$$row{num}.PAGE_EXT;
			}
			else # removing parent image
			{
				build_thread_cache($$row{num});
			}
		}
		else # removing a reply, or a reply's image
		{
			build_thread_cache($$row{parent});
		}
	}
}



#
# Admin interface
#

sub make_admin_login()
{
	make_http_header();
	print encode_string(ADMIN_LOGIN_TEMPLATE->());
}

sub make_admin_post_panel($)
{
	my ($admin)=@_;
	my ($sth,$row,@posts,$size,$rowtype);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." ORDER BY stickied DESC, lasthit DESC, CASE parent WHEN 0 THEN num ELSE parent END ASC, num ASC;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	$size=0;
	$rowtype=1;
	while($row=get_decoded_hashref($sth))
	{
		if(!$$row{parent}) { $rowtype=1; }
		else { $rowtype^=3; }
		$$row{rowtype}=$rowtype;

		$size+=$$row{size};

		push @posts,$row;
	}

	make_http_header();
	print encode_string(POST_PANEL_TEMPLATE->(admin=>$admin,posts=>\@posts,size=>$size));
}

sub make_admin_ban_panel($$)
{
	my ($admin, $ip)=@_;
	my ($sth,$row,@bans,$prevtype);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	$sth=$dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE type='ipban' OR type='wordban' OR type='whitelist' OR type='trust' ORDER BY type ASC,num ASC;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	while($row=get_decoded_hashref($sth))
	{
		$$row{divider}=1 if($prevtype ne $$row{type});
		$prevtype=$$row{type};
		$$row{rowtype}=@bans%2+1;
		$$row{expirehuman}=($$row{expiration}) ? epoch_to_human($$row{expiration}) : 'Never'; # ADDED
		$$row{browsingban}=($$row{total} eq 'yes') ? 'No' : 'Yes'; # ADDED
		push @bans,$row;
	}

	make_http_header();
	print encode_string(BAN_PANEL_TEMPLATE->(admin=>$admin,bans=>\@bans,ip=>$ip)); # EDITED
}

sub make_admin_ban_edit($$) # ADDED subroutine for generating ban editing window
{
	my ($admin, $num) = @_;

	check_password($admin,ADMIN_PASS);

	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED	
	
	my (@hash, $time);
	my $sth = $dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE num=?") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);
	my @utctime;
	while (my $row=get_decoded_hashref($sth))
	{
		push (@hash, $row);
		if ($$row{expiration} != 0)
		{
			@utctime = gmtime($$row{expiration}); #($sec, $min, $hour, $day,$month,$year)
		} 
		else
		{
			@utctime = gmtime(time);
		}
			
		$utctime[5] += 1900;
		$utctime[4]++;
	}
	make_http_header();
	print encode_string(EDIT_WINDOW->(admin=>$admin, hash=>\@hash, sec=>$utctime[0], min=>$utctime[1], hour=>$utctime[2], day=>$utctime[3], month=>$utctime[4], year=>$utctime[5]));
}


sub make_admin_proxy_panel($)
{
	my ($admin)=@_;
	my ($sth,$row,@scanned,$prevtype);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	proxy_clean();

	$sth=$dbh->prepare("SELECT * FROM ".SQL_PROXY_TABLE." ORDER BY timestamp ASC;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	while($row=get_decoded_hashref($sth))
	{
		$$row{divider}=1 if($prevtype ne $$row{type});
		$prevtype=$$row{type};
		$$row{rowtype}=@scanned%2+1;
		push @scanned,$row;
	}

	make_http_header();
	print encode_string(PROXY_PANEL_TEMPLATE->(admin=>$admin,scanned=>\@scanned));
}

sub make_admin_spam_panel($)
{
	my ($admin)=@_;
	my @spam_files=SPAM_FILES;
	my @spam=read_array($spam_files[0]);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	make_http_header();
	print encode_string(SPAM_PANEL_TEMPLATE->(admin=>$admin,
	spamlines=>scalar @spam,
	spam=>join "\n",map { clean_string($_,1) } @spam));
}

sub make_sql_dump($)
{
	my ($admin)=@_;
	my ($sth,$row,@database);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE.";") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
	while($row=get_decoded_arrayref($sth))
	{
		push @database,"INSERT INTO ".SQL_TABLE." VALUES('".
		(join "','",map { s/\\/&#92;/g; $_ } @{$row}). # escape ' and \, and join up all values with commas and apostrophes
		"');";
	}

	make_http_header();
	print encode_string(SQL_DUMP_TEMPLATE->(admin=>$admin,
	database=>join "<br />",map { clean_string($_,1) } @database));
}

sub make_sql_interface($$$)
{
	my ($admin,$nuke,$sql)=@_;
	my ($sth,$row,@results);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	if($sql)
	{
		make_error(S_WRONGPASS) if($nuke ne NUKE_PASS); # check nuke password

		my @statements=grep { /^\S/ } split /\r?\n/,decode_string($sql,CHARSET,1);

		foreach my $statement (@statements)
		{
			push @results,">>> $statement";
			if($sth=$dbh->prepare($statement))
			{
				if($sth->execute())
				{
					while($row=get_decoded_arrayref($sth)) { push @results,join ' | ',@{$row} }
				}
				else { push @results,"!!! ".$sth->errstr() }
			}
			else { push @results,"!!! ".$sth->errstr() }
		}
	}

	make_http_header();
	print encode_string(SQL_INTERFACE_TEMPLATE->(admin=>$admin,nuke=>$nuke,
	results=>join "<br />",map { clean_string($_,1) } @results));
}

sub make_admin_post($)
{
	my ($admin)=@_;

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	make_http_header();
	print encode_string(ADMIN_POST_TEMPLATE->(admin=>$admin));
}

sub do_login($$$$)
{
	my ($password,$nexttask,$savelogin,$admincookie)=@_;
	my $crypt;

	if($password)
	{
		$crypt=crypt_password($password);
	}
	elsif($admincookie eq crypt_password(ADMIN_PASS))
	{
		$crypt=$admincookie;
		$nexttask="mpanel";
	}

	if($crypt)
	{
		if($savelogin and $nexttask ne "nuke")
		{
			make_cookies(wakaadmin=>$crypt,
			-charset=>CHARSET,-autopath=>COOKIE_PATH,-expires=>time+365*24*3600);
		}

		make_http_forward(get_script_name()."?task=$nexttask&admin=$crypt",ALTERNATE_REDIRECT);
	}
	else { make_admin_login() }
}

sub do_logout()
{
	make_cookies(wakaadmin=>"",-expires=>1);
	make_http_forward(get_script_name()."?task=admin",ALTERNATE_REDIRECT);
}

sub do_rebuild_cache($)
{
	my ($admin)=@_;

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	unlink glob RES_DIR.'*'.PAGE_EXT;

	repair_database();
	build_thread_cache_all();
	build_cache();

	make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
}

sub add_admin_entry($$$$$$)
{
	my ($admin,$type,$comment,$ival1,$ival2,$sval1,$total,$expiration)=@_;
	my ($sth);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED
	
	make_error(S_COMMENT_A_MUST) if !$comment; # ADDED

	$comment=clean_string(decode_string($comment,CHARSET));
	
	$expiration = ($expiration eq '' || $expiration == 0) ? 0 : $expiration + time(); # ADDED
	
	make_error(S_STRINGFIELDMISSING) if ($type eq 'wordban' && $sval1 eq '');

	$sth=$dbh->prepare("INSERT INTO ".SQL_ADMIN_TABLE." VALUES(null,?,?,?,?,?,?,?);") or make_error(S_SQLFAIL); # EDITED
	$sth->execute($type,$comment,$ival1,$ival2,$sval1,$total,$expiration) or make_error(S_SQLFAIL); # EDITED
	
	if ($total eq 'yes' && $type eq 'ipban') # ADDED - Is this a complete IP ban (forbidding content browsing)?
	{
		add_htaccess_entry(dec_to_dot($ival1));
	}
	
	
		

	make_http_forward(get_script_name()."?admin=$admin&task=bans",ALTERNATE_REDIRECT);
}

sub edit_admin_entry($$$$$$$$$$$$$$) # ADDED subroutine for editing entries in the admin table
{
	my ($admin,$num,$type,$comment,$ival1,$ival2,$sval1,$total,$sec, $min, $hour, $day,$month,$year,$noexpire)=@_;
	my ($sth, $not_total_before, $past_ip, $expiration);
	
	check_password($admin,ADMIN_PASS);
	
	make_error(S_COMMENT_A_MUST) unless $comment;
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	if ($type eq 'ipban')
	{
		my $verify=$dbh->prepare("SELECT total, ival1 FROM ".SQL_ADMIN_TABLE." WHERE num=?") or make_error(S_SQLFAIL);
		$verify->execute($num) or make_error(S_SQLFAIL);
		while (my $row = get_decoded_hashref($verify))
		{
			$not_total_before = 1 if ($$row{total} ne 'yes');
			$past_ip = dec_to_dot($$row{ival1});
		}
		$expiration = (!$noexpire) ? (timegm($sec, $min, $hour, $day,$month-1,$year) || make_error(S_DATEPROBLEM)) : 0;
	}
	if ($total eq 'yes' && ($not_total_before || $past_ip ne $ival1)) # If current IP or new IP is now on a browsing ban, add it to .htaccess.
	{
		add_htaccess_entry($ival1);
	}
	if (($total ne 'yes' || $past_ip ne $ival1) && !$not_total_before && $type eq 'ipban') # If the previous, different IP was banned from
	{															 # browsing, we should remove it from .htaccess now.
		remove_htaccess_entry($past_ip);
	}
	$sth=$dbh->prepare("UPDATE ".SQL_ADMIN_TABLE." SET comment=?, ival1=?, ival2=?, sval1=?, total=?, expiration=? WHERE num=?")  
		or make_error(S_SQLFAIL);
	$sth->execute($comment, dot_to_dec($ival1), dot_to_dec($ival2), $sval1, $total, $expiration, $num) or make_error(S_SQLFAIL);
	make_http_header();
	print encode_string(EDIT_SUCCESSFUL->());
}
	

sub remove_admin_entry($$$$)
{
	my ($admin,$num,$override,$no_redirect)=@_;
	my ($sth);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR})) || $override;
	# END ADDED
	
	# ADDED - Does the ban forbid browsing?
	
	my $totalverify_admin = $dbh->prepare("SELECT * FROM ".SQL_ADMIN_TABLE." WHERE num=?") or make_error(S_SQLFAIL);
	$totalverify_admin->execute($num) or make_error(S_SQLFAIL);
	while (my $row=get_decoded_hashref($totalverify_admin))
	{
		if ($$row{total} eq 'yes')
		{
		my $ip = dec_to_dot($$row{ival1});
		remove_htaccess_entry($ip);
		}
	}
	
	# END ADDED

	$sth=$dbh->prepare("DELETE FROM ".SQL_ADMIN_TABLE." WHERE num=?;") or make_error(S_SQLFAIL);
	$sth->execute($num) or make_error(S_SQLFAIL);

	make_http_forward(get_script_name()."?admin=$admin&task=bans",ALTERNATE_REDIRECT) unless $no_redirect; # EDITED
}

sub remove_ban_on_admin($$) # ADDED subroutine for removing bans on the admin
{
	my ($admin, $nuke) = @_;
	check_password($admin, ADMIN_PASS); 
	make_error(S_WRONGPASS) if ($nuke ne NUKE_PASS); # check nuke password
	my $sth=$dbh->prepare("SELECT num FROM ".SQL_ADMIN_TABLE." WHERE ? & ival2 = ival1 & ival2") or make_error(S_SQLFAIL);
	$sth->execute(dot_to_dec($ENV{REMOTE_ADDR})) or make_error(S_SQLFAIL);
	my @rows_to_delete;
	while (my $row=get_decoded_hashref($sth))
	{
		push @rows_to_delete, $$row{num};
	}
	for (my $i = 0; $i <= $#rows_to_delete; $i++)
	{
		remove_admin_entry($admin, $rows_to_delete[$i], 1, 1);
	}
	make_http_forward(get_script_name()."?admin=$admin&task=bans",ALTERNATE_REDIRECT);
}

sub delete_all($$$)
{
	my ($admin,$ip,$mask)=@_;
	my ($sth,$row,@posts);

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	$sth=$dbh->prepare("SELECT num FROM ".SQL_TABLE." WHERE ip & ? = ? & ?;") or make_error(S_SQLFAIL);
	$sth->execute($mask,$ip,$mask) or make_error(S_SQLFAIL);
	while($row=$sth->fetchrow_hashref()) { push(@posts,$$row{num}); }

	delete_stuff('',0,0,$admin,@posts);
}

sub update_spam_file($$)
{
	my ($admin,$spam)=@_;

	check_password($admin,ADMIN_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	my @spam=split /\r?\n/,$spam;
	my @spam_files=SPAM_FILES;
	write_array($spam_files[0],@spam);

	make_http_forward(get_script_name()."?admin=$admin&task=spam",ALTERNATE_REDIRECT);
}

sub do_nuke_database($)
{
	my ($admin)=@_;

	check_password($admin,NUKE_PASS);
	
	# ADDED - Is moderator banned?
	ban_admin_check(dot_to_dec($ENV{REMOTE_ADDR}), $admin) unless is_whitelisted(dot_to_dec($ENV{REMOTE_ADDR}));
	# END ADDED

	init_database();
	#init_admin_database();
	#init_proxy_database();

	# remove images, thumbnails and threads
	unlink glob IMG_DIR.'*';
	unlink glob THUMB_DIR.'*';
	unlink glob RES_DIR.'*';

	build_cache();

	make_http_forward(HTML_SELF,ALTERNATE_REDIRECT);
}

sub check_password($$)
{
	my ($admin,$password)=@_;

	return if($admin eq ADMIN_PASS);
	return if($admin eq crypt_password($password));

	make_error(S_WRONGPASS);
}

sub check_password_editing_mode($$)
{
	my ($admin,$password)=@_;

	return if($admin eq ADMIN_PASS);
	return if($admin eq crypt_password($password));

	make_error_small(S_WRONGPASS);
}

sub crypt_password($)
{
	my $crypt=hide_data((shift).$ENV{REMOTE_ADDR},9,"admin",SECRET,1);
	$crypt=~tr/+/./; # for web shit
	return $crypt;
}

sub add_htaccess_entry($)
{
	my $ip = $_[0];
	$ip =~ s/\./\\\./g;
	my $ban_entries_found = 0;
	my $options_followsymlinks = 0;
	my $options_execcgi = 0;
	open (HTACCESSREAD, "../.htaccess") 
	  or make_error(S_HTACCESSPROBLEM);
	while (<HTACCESSREAD>)
	{
		$ban_entries_found = 1 if m/RewriteEngine\s+On/i;
		$options_followsymlinks = 1 if m/Options.*?FollowSymLinks/i;
		$options_execcgi = 1 if m/Options.*?ExecCGI/i;
	}
	close HTACCESSREAD;
	open (HTACCESS, ">>../.htaccess");
	print HTACCESS "\n".'Options +FollowSymLinks'."\n" if !$options_followsymlinks;
	print HTACCESS "\n".'Options +ExecCGI'."\n" if !$options_execcgi;
	print HTACCESS "\n".'RewriteEngine On'."\n" if !$ban_entries_found;
	print HTACCESS "\n".'# Ban added by Wakaba'."\n";
	print HTACCESS 'RewriteCond %{REMOTE_ADDR} ^'.$ip.'$'."\n";
	print HTACCESS 'RewriteRule !(\.pl|\.js$|\.css$|\.php$|sugg|ban_images) '.$ENV{SCRIPT_NAME}.'?task=banreport'."\n";
	# mod_rewrite entry. This is customized for Desuchan and would have to be a config.pl option in a public release.
	close HTACCESS;
}

sub remove_htaccess_entry($) # ADDED subroutine for removing browsing bans (enforced by .htaccess)
{
	my $ip = $_[0];
	$ip =~ s/\./\\\\\./g;
	open (HTACCESSREAD, "../.htaccess") or make_error(S_HTACCESSCANTREMOVE);
	my $file_contents;
	while (<HTACCESSREAD>)
	{	
		$file_contents .= $_;
	}
	$file_contents =~ s/(.*)\n\# Ban added by Wakaba.*?RewriteCond.*?$ip.*?RewriteRule\s+\!\(.*?\).*?\?task\=banreport\n(.*)/$1$2/s;
	close HTACCESS;
	open (HTACCESSWRITE, ">../.htaccess") or warn "Error writing to .htaccess ";
	print HTACCESSWRITE $file_contents;
	close HTACCESSWRITE;
}



#
# Page creation utils
#

sub make_http_header()
{
	print "Content-Type: ".get_xhtml_content_type(CHARSET,USE_XHTML)."\n";
	print "\n";
}

sub make_error($)
{
	my ($error)=@_;

	make_http_header();

	print encode_string(ERROR_TEMPLATE->(error=>$error));

	if($dbh)
	{
		$dbh->{Warn}=0;
		$dbh->disconnect();
	}

	if(ERRORLOG) # could print even more data, really.
	{
		open ERRORFILE,'>>'.ERRORLOG;
		print ERRORFILE $error."\n";
		print ERRORFILE $ENV{HTTP_USER_AGENT}."\n";
		print ERRORFILE "**\n";
		close ERRORFILE;
	}

	# delete temp files

	exit;
}

sub make_error_small($)
{
	my ($error)=@_;

	make_http_header();

	print encode_string(ERROR_TEMPLATE_MINI->(error=>$error));

	if($dbh)
	{
		$dbh->{Warn}=0;
		$dbh->disconnect();
	}

	if(ERRORLOG) # could print even more data, really.
	{
		open ERRORFILE,'>>'.ERRORLOG;
		print ERRORFILE $error."\n";
		print ERRORFILE $ENV{HTTP_USER_AGENT}."\n";
		print ERRORFILE "**\n";
		close ERRORFILE;
	}

	# delete temp files

	exit;
}

sub get_script_name()
{
	return $ENV{SCRIPT_NAME};
}

sub get_secure_script_name()
{
	return 'https://'.$ENV{SERVER_NAME}.$ENV{SCRIPT_NAME} if(USE_SECURE_ADMIN);
	return $ENV{SCRIPT_NAME};
}

sub expand_image_filename($)
{
	my $filename=shift;

	return expand_filename(clean_path($filename)) unless ENABLE_LOAD;

	my ($self_path)=$ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;
	my $src=IMG_DIR;
	$filename=~/$src(.*)/;
	return $self_path.REDIR_DIR.clean_path($1).'.html';
}

sub get_reply_link($$)
{
	my ($reply,$parent)=@_;

	return expand_filename(RES_DIR.$parent.PAGE_EXT).'#'.$reply if($parent);
	return expand_filename(RES_DIR.$reply.PAGE_EXT);
}

sub get_page_count(;$)
{
	my $total=(shift or count_threads());
	return int(($total+IMAGES_PER_PAGE-1)/IMAGES_PER_PAGE);
}

sub get_filetypes()
{
	my %filetypes=FILETYPES;
	$filetypes{gif}=$filetypes{jpg}=$filetypes{png}=1;
	return join ", ",map { uc } sort keys %filetypes;
}

sub dot_to_dec($)
{
	return unpack('N',pack('C4',split(/\./, $_[0]))); # wow, magic.
}

sub dec_to_dot($)
{
	return join('.',unpack('C4',pack('N',$_[0])));
}

sub parse_range($$)
{
	my ($ip,$mask)=@_;

	$ip=dot_to_dec($ip) if($ip=~/^\d+\.\d+\.\d+\.\d+$/);

	if($mask=~/^\d+\.\d+\.\d+\.\d+$/) { $mask=dot_to_dec($mask); }
	elsif($mask=~/(\d+)/) { $mask=(~((1<<$1)-1)); }
	else { $mask=0xffffffff; }

	return ($ip,$mask);
}




#
# Database utils
#

sub init_database()
{
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_TABLE.";") if(table_exists(SQL_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_TABLE." (".

	"num ".get_sql_autoincrement().",".	# Post number, auto-increments
	"parent INTEGER,".			# Parent post for replies in threads. For original posts, must be set to 0 (and not null)
	"timestamp INTEGER,".		# Timestamp in seconds for when the post was created
	"lasthit INTEGER,".			# Last activity in thread. Must be set to the same value for BOTH the original post and all replies!
	"ip TEXT,".					# IP number of poster, in integer form!

	"date TEXT,".				# The date, as a string
	"name TEXT,".				# Name of the poster
	"trip TEXT,".				# Tripcode (encoded)
	"email TEXT,".				# Email address
	"subject TEXT,".			# Subject
	"password TEXT,".			# Deletion password (in plaintext) 
	"comment TEXT,".			# Comment text, HTML encoded.

	"image TEXT,".				# Image filename with path and extension (IE, src/1081231233721.jpg)
	"size INTEGER,".			# File size in bytes
	"md5 TEXT,".				# md5 sum in hex
	"width INTEGER,".			# Width of image in pixels
	"height INTEGER,".			# Height of image in pixels
	"thumbnail TEXT,".			# Thumbnail filename with path and extension
	"tn_width TEXT,".			# Thumbnail width in pixels
	"tn_height TEXT,".			# Thumbnail height in pixels
	"lastedit TEXT,".			# ADDED - Date of previous edit, as a string 
	"lastedit_ip TEXT,".			# ADDED - Previous editor of the post, if any
	"admin_post TEXT,".			# ADDED - Admin post?
	"stickied INTEGER,".		# ADDED - Stickied?
	"locked TEXT".			# ADDED - Locked?
	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub init_admin_database()
{
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_ADMIN_TABLE.";") if(table_exists(SQL_ADMIN_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_ADMIN_TABLE." (".

	"num ".get_sql_autoincrement().",".	# Entry number, auto-increments
	"type TEXT,".				# Type of entry (ipban, wordban, etc)
	"comment TEXT,".			# Comment for the entry
	"ival1 TEXT,".			# Integer value 1 (usually IP)
	"ival2 TEXT,".			# Integer value 2 (usually netmask)
	"sval1 TEXT,".				# String value 1
	"total TEXT, ".			# ADDED - Total Ban?
	"expiration INTEGER".		# ADDED - Ban Expiration?
	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub init_proxy_database()
{
	my ($sth);

	$sth=$dbh->do("DROP TABLE ".SQL_PROXY_TABLE.";") if(table_exists(SQL_PROXY_TABLE));
	$sth=$dbh->prepare("CREATE TABLE ".SQL_PROXY_TABLE." (".

	"num ".get_sql_autoincrement().",".	# Entry number, auto-increments
	"type TEXT,".				# Type of entry (black, white, etc)
	"ip TEXT,".				# IP address
	"timestamp INTEGER,".			# Age since epoch
	"date TEXT".				# Human-readable form of date 

	");") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);
}

sub repair_database()
{
	my ($sth,$row,@threads,$thread);

	$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE parent=0;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	while($row=$sth->fetchrow_hashref()) { push(@threads,$row); }

	foreach $thread (@threads)
	{
		# fix lasthit
		my ($upd);

		$upd=$dbh->prepare("UPDATE ".SQL_TABLE." SET lasthit=? WHERE parent=?;") or make_error(S_SQLFAIL);
		$upd->execute($$row{lasthit},$$row{num}) or make_error(S_SQLFAIL." ".$dbh->errstr());
	}
}

sub get_sql_autoincrement()
{
	return 'INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT' if(SQL_DBI_SOURCE=~/^DBI:mysql:/i);
	return 'INTEGER PRIMARY KEY' if(SQL_DBI_SOURCE=~/^DBI:SQLite:/i);
	return 'INTEGER PRIMARY KEY' if(SQL_DBI_SOURCE=~/^DBI:SQLite2:/i);

	make_error(S_SQLCONF); # maybe there should be a sane default case instead?
}

sub trim_database()
{
	my ($sth,$row,$order);

	if(TRIM_METHOD==0) { $order='num ASC'; }
	else { $order='lasthit ASC'; }

	if(MAX_AGE) # needs testing
	{
		my $mintime=time()-(MAX_AGE)*3600;

		$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE parent=0 AND timestamp<=$mintime AND stickied <> 1;") or make_error(S_SQLFAIL);
		$sth->execute() or make_error(S_SQLFAIL);

		while($row=$sth->fetchrow_hashref())
		{
			delete_post($$row{num},"",0,ARCHIVE_MODE);
		}
	}

	my $threads=count_threads();
	my ($posts,$size)=count_posts();
	my $max_threads=(MAX_THREADS or $threads);
	my $max_posts=(MAX_POSTS or $posts);
	my $max_size=(MAX_MEGABYTES*1024*1024 or $size);

	while($threads>$max_threads or $posts>$max_posts or $size>$max_size)
	{
		$sth=$dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE parent=0 AND stickied <> 0 ORDER BY $order LIMIT 1;") or make_error(S_SQLFAIL);
		$sth->execute() or make_error(S_SQLFAIL);

		if($row=$sth->fetchrow_hashref())
		{
			my ($threadposts,$threadsize)=count_posts($$row{num});

			delete_post($$row{num},"",0,ARCHIVE_MODE);

			$threads--;
			$posts-=$threadposts;
			$size-=$threadsize;
		}
		else { last; } # shouldn't happen
	}
}

sub table_exists($)
{
	my ($table)=@_;
	my ($sth);

	return 0 unless($sth=$dbh->prepare("SELECT * FROM ".$table." LIMIT 1;"));
	return 0 unless($sth->execute());
	return 1;
}

sub count_threads()
{
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE parent=0;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	return ($sth->fetchrow_array())[0];
}

sub count_posts(;$)
{
	my ($parent)=@_;
	my ($sth,$where);

	$where="WHERE parent=$parent or num=$parent" if($parent);
	$sth=$dbh->prepare("SELECT count(*),sum(size) FROM ".SQL_TABLE." $where;") or make_error(S_SQLFAIL);
	$sth->execute() or make_error(S_SQLFAIL);

	return $sth->fetchrow_array();
}

sub thread_exists($)
{
	my ($thread)=@_;
	my ($sth);

	$sth=$dbh->prepare("SELECT count(*) FROM ".SQL_TABLE." WHERE num=? AND parent=0;") or make_error(S_SQLFAIL);
	$sth->execute($thread) or make_error(S_SQLFAIL);

	return ($sth->fetchrow_array())[0];
}

sub get_decoded_hashref($)
{
	my ($sth)=@_;

	my $row=$sth->fetchrow_hashref();

	if($row and $has_encode)
	{
		for my $k (keys %$row) # don't blame me for this shit, I got this from perlunicode.
		{ defined && /[^\000-\177]/ && Encode::_utf8_on($_) for $row->{$k}; }

		if(SQL_DBI_SOURCE=~/^DBI:mysql:/i) # OMGWTFBBQ
		{ for my $k (keys %$row) { $$row{$k}=~s/chr\(([0-9]+)\)/chr($1)/ge; } }
	}

	return $row;
}

sub get_decoded_arrayref($)
{
	my ($sth)=@_;

	my $row=$sth->fetchrow_arrayref();

	if($row and $has_encode)
	{
		# don't blame me for this shit, I got this from perlunicode.
		defined && /[^\000-\177]/ && Encode::_utf8_on($_) for @$row;

		if(SQL_DBI_SOURCE=~/^DBI:mysql:/i) # OMGWTFBBQ
		{ s/chr\(([0-9]+)\)/chr($1)/ge for @$row; }
	}

	return $row;
}

# ADDED here instead of wakautils for convenience

sub epoch_to_human($) {
	my @months = ("January","February","March","April","May","June","July","August","September","October","November","December");
	my ($sec, $min, $hour, $day,$month,$year) = (gmtime($_[0]))[0,1,2,3,4,5,6]; 
	$min = (length ($min) < 2) ? '0'.$min : $min;
	$sec = (length ($sec) < 2) ? '0'.$sec : $sec;
	$hour = (length ($hour) < 2) ? '0'.$hour : $hour;
	$months[$month]." ".$day.", ".($year+1900)." at ".$hour.":".$min.":".$sec." UTC";
}
