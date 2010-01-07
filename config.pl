# use encoding 'shift-jis'; # Uncomment this to use shift-jis in strings. ALSO uncomment the "no encoding" at the end of the file!

# Wakaba configuration

use constant ADMIN_PASS => 'desu';			# Admin password. For fucks's sake, change this.
use constant SECRET => 'ajkgha;weoitu3985p2398j324waptiowegspoiajspgjapdfoibjzoxnhy8zdsr0y8zw4yw4';				# Cryptographic secret. CHANGE THIS to something totally random, and long.
use constant SQL_DBI_SOURCE => 'DBI:mysql:database=wkba2;host=localhost'; # DBI data source string (mysql version, put server and database name in here)
use constant SQL_USERNAME => 'root';		# MySQL login name
use constant SQL_PASSWORD => 'helpless912';		# MySQL password
#use constant SQL_BACKUP_TABLE => '__waka_backup';			# Table backup
#use constant SQL_ADMIN_TABLE => 'admin';		# Table used for admin information
#use constant SQL_PROXY_TABLE => 'proxy';		# Table used for proxy information
#use constant USE_TEMPFILES => 1;				# Set this to 1 under Unix and 0 under Windows! (Use tempfiles when creating pages)
#use constant DATE_STYLE => 'futaba';			# Date style ('futaba', '2ch', 'localtime', 'tiny')
#use constant ERRORLOG => '';					# Writes out all errors seen by user, mainly useful for debugging
#use constant CONVERT_COMMAND => 'convert';		# location of the ImageMagick convert command (usually just 'convert', but sometime a full path is needed)
##use constant CONVERT_COMMAND = '/usr/X11R6/bin/convert';
#use constant ALTERNATE_REDIRECT => 0;			# Use alternate redirect method. (Javascript/meta-refresh instead of HTTP forwards. Needed to run on certain servers, like IIS.)
#use constant USE_SECURE_ADMIN => 1;			# Use HTTPS for admin logins.
#use constant USE_TEMPFILES => 1;			# Use temporary files.	(1: Unix; 0: Windows)
#use constant PAGE_EXT => '.html';			# File extension for all board pages.
#use constant CHARSET => 'utf-8';	
#use constant CONVERT_CHARSETS => 1;			# Do character set conversions internally
#use constant SPAM_FILES => 'spam.txt';
#use constant USE_XHTML => 1;
#use constant HOME => '/';
#use constant HTACCESS_PATH => './';
#use constant PASSFAIL_THRESHOLD => 5;			# Number of times a user may fail a password prompt prior to banning.
#use constant PASSFAIL_ROLLBACK => 1*24*3600;		# How long a failed password prompt is held against a host.
#use constant PASSPROMPT_EXPIRE_TO_FAILURE => 300;	# How long password prompts last before timing out and counting against the user.
#use constant MAX_FCGI_LOOPS => 250;
#use constant TIME_OFFSET => 0;				# Time offset in seconds, for display on board pages. You can use this to adjust board time to your local time!
							# Positive value adjusts forward; negative value adjusts backward.
#use constant SQL_REPORT_TABLE => 'user_report';
#use constant STAFF_LOG_RETENTION => 30*24*3600;	# How long should staff log entries be retained? (Seconds)
#use constant REPORT_RETENTION => 30*24*3600;		# How long should report entries be retained? (Seconds)

#use constant POST_BACKUP=>1;				# 1: Back up posts that are deleted or edited. 0: Do not back up.
#use constant POST_BACKUP_EXPIRE => 3600*24*14;		# How long should backups last prior to purging?

# use constant ENABLE_ABBREVIATED_THREAD_PAGES => 1;	# Want to enable "Last xx Posts?" Then set this to 1.
# use constant POSTS_IN_ABBREVIATED_THREAD_PAGES => 50;	# Number of posts to show in abbreviated reply views.

# use constant ENABLE_RSS => 1;				# Do RSS feeds.
# use constant RSS_LENGTH => 10;			# Number of items in each feed.
# use constant RSS_WEBMASTER => "dark.master.schmidt@gmail.com (Dark^Master^Schmidt)";
							# Webmaster email address and name. Example format should be preserved for RSS spec.

# no encoding;

1;
