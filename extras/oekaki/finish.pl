#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);

use strict;

use CGI;
use DBI;



#
# Import settings
#

use lib '.';
BEGIN { require "config.pl"; }
BEGIN { require "config_defaults.pl"; }
BEGIN { require "strings_en.pl"; }
BEGIN { require "oekaki_style.pl"; }
BEGIN { require "oekaki_config.pl"; }
BEGIN { require "oekaki_strings_en.pl"; }
BEGIN { require "wakautils.pl"; }



#
# Optional modules
#

my ($has_encode);

if(CHARSET) # don't use Unicode at all if CHARSET is not set.
{
	eval 'use Encode qw(decode)';
	$has_encode=1 unless($@);
}



#
# Global init
#

my $query=new CGI;
my $task=$query->param("task");

my $ip=$ENV{REMOTE_ADDR};
my $oek_ip=$query->param("oek_ip");
$oek_ip=$ip unless($oek_ip);

die unless($oek_ip=~/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/);

my $tmpname=TMP_DIR.$oek_ip.'.png';

my $num=$query->param("num");
my $dummy=$query->param("dummy");

if(!$task)
{
	my $oek_parent=$query->param("oek_parent");
	my $srcinfo=$query->param("srcinfo");
	my $oek_editing=$query->param("oek_editing");
	my $password=$query->param("password");

	make_http_header();

	if (!$oek_editing)
	{
		print OEKAKI_FINISH_TEMPLATE->(
			tmpname=>$tmpname,
			oek_parent=>clean_string($oek_parent),
			oek_ip=>$oek_ip,
			srcinfo=>clean_string($srcinfo),
			dummy=>$dummy,
			decodedinfo=>OEKAKI_INFO_TEMPLATE->(decode_srcinfo($srcinfo))
		);
	}
	else
	{
		
		require "wakaba.pl";
		
		my $dbh=DBI->connect(SQL_DBI_SOURCE,SQL_USERNAME,SQL_PASSWORD,{AutoCommit=>1}) or make_error(S_SQLCONF);
		my $sth = $dbh->prepare("SELECT * FROM ".SQL_TABLE." WHERE num = ?;");
		$sth->execute($num);
		my $row = get_decoded_hashref($sth);
		
		print OEKAKI_FINISH_EDIT_TEMPLATE->(
			tmpname=>$tmpname,
			oek_parent=>clean_string($oek_parent),
			oek_ip=>$oek_ip,
			srcinfo=>clean_string($srcinfo),
			decodedinfo=>OEKAKI_EDIT_INFO_TEMPLATE->(decode_srcinfo($srcinfo)),
			num=>$num,
			dummy => $dummy,
			comment=>tag_killa($$row{comment}),
			name=>$$row{name},
			email=>$$row{email},
			subject=>$$row{subject},
			password=>$password
		);
		$sth->finish();
	}
}
elsif($task eq "post")
{
	require "wakaba.pl";

	my $parent=$query->param("parent");
	my $name=$query->param("field1");
	my $email=$query->param("email");
	my $subject=$query->param("subject");
	my $comment=$query->param("comment");
	my $password=$query->param("password");
	my $captcha=$query->param("captcha");
	my $srcinfo=$query->param("srcinfo");
	
	$ENV{SCRIPT_NAME}=~s/\w+\.pl$/wakaba.pl/;

	open TMPFILE,$tmpname or die "Can't read uploaded file";

	post_stuff($parent,$name,$email,$subject,$comment,\*TMPFILE,$tmpname,$password,
	0,$captcha,'',0,0,OEKAKI_INFO_TEMPLATE->(decode_srcinfo($srcinfo)),,);

	unlink $tmpname;
}
elsif ($task eq "edit")
{
	require "wakaba.pl";
	
	my $name=$query->param("field1");
	my $email=$query->param("email");
	my $subject=$query->param("subject");
	my $comment=$query->param("comment");
	my $password=$query->param("password");
	my $captcha=$query->param("captcha");
	my $srcinfo=$query->param("srcinfo");
	my $password=$query->param("password");
	
	my $dbh=DBI->connect(SQL_DBI_SOURCE,SQL_USERNAME,SQL_PASSWORD,{AutoCommit=>1}) or make_error(S_SQLCONF);
	my $sth = $dbh->prepare("SELECT password FROM ".SQL_TABLE." WHERE num = ?;");
	$sth->execute($num);
	my $row = get_decoded_hashref($sth);
	
	make_error(S_BADEDITPASS) if ($$row{password} ne $password);
	
	$sth->finish();
	
	$ENV{SCRIPT_NAME}=~s/\w+\.pl$/wakaba.pl/;

	open TMPFILE,$tmpname or die "Can't read uploaded file";

	edit_shit($num,$name,$email,$subject,$comment,\*TMPFILE,$tmpname,$password,
	$captcha,'',0,0,OEKAKI_EDIT_INFO_TEMPLATE->(decode_srcinfo($srcinfo)));
	
	unlink $tmpname;
	
}

sub make_http_header()
{
	print "Content-Type: ".get_xhtml_content_type(CHARSET)."\n";
	print "\n";

	$PerlIO::encoding::fallback=0x0200;
	binmode STDOUT,':encoding('.CHARSET.')' if($has_encode);
}

sub expand_filename($)
{
	my ($filename)=@_;
	return $filename if($filename=~m!^/!);
	return $filename if($filename=~m!^\w+:!);

	my ($self_path)=$ENV{SCRIPT_NAME}=~m!^(.*/)[^/]+$!;
	return $self_path.$filename;
}

sub decode_srcinfo($$)
{
	my ($srcinfo)=@_;
	my @info=split /,/,$srcinfo;
	my @stat=stat $tmpname;
	my $fileage=$stat[9];
	my ($painter)=grep { $$_{painter} eq $info[1] } @{S_OEKPAINTERS()};

	return (
		time=>clean_string(pretty_age($fileage-$info[0])),
		painter=>clean_string($$painter{name}),
		source=>clean_string($info[2]),
	);
}

sub pretty_age($)
{
	my ($age)=@_;

	return "HAXORED" if($age<0);
	return $age." s" if($age<60);
	return int($age/60)." min" if($age<3600);
	return int($age/3600)." h ".int(($age%3600)/60)." min" if($age<3600*24*7);
	return "HAXORED";
}
