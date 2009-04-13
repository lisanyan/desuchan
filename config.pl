# use encoding 'shift-jis'; # Uncomment this to use shift-jis in strings. ALSO uncomment the "no encoding" at the end of the file!

# Wakaba configuration

use constant ADMIN_PASS => 'CHANGEME';			# Admin password. For fucks's sake, change this.
use constant SECRET => 'CHANGEME';			# Cryptographic secret. CHANGE THIS to something totally random, and long.
use constant SQL_DBI_SOURCE => 'DBI:mysql:database=CHANGEME;host=localhost'; # DBI data source string (mysql version, put server and database name in here)
use constant SQL_USERNAME => 'CHANGEME';		# MySQL login name
use constant SQL_PASSWORD => 'CHANGEME';		# MySQL password
#use constant SQL_ADMIN_TABLE => 'admin';		# Table used for admin information
#use constant SQL_PROXY_TABLE => 'proxy';		# Table used for proxy information
use constant USE_TEMPFILES => 1;			# Set this to 1 under Unix and 0 under Windows! (Use tempfiles when creating pages)
#use constant DATE_STYLE => 'futaba';			# Date style ('futaba', '2ch', 'localtime', 'tiny')
use constant ERRORLOG => 'stderr';			# Writes out all errors seen by user, mainly useful for debugging
#use constant CONVERT_COMMAND => 'convert';		# location of the ImageMagick convert command (usually just 'convert', but sometime a full path is needed)
##use constant CONVERT_COMMAND = '/usr/X11R6/bin/convert';
#use constant ALTERNATE_REDIRECT => 0;			# Use alternate redirect method. (Javascript/meta-refresh instead of HTTP forwards. Needed to run on certain servers, like IIS.)
use constant USE_SECURE_ADMIN => 1;			# Use HTTPS for admin logins.
use constant PAGE_EXT => '.html';			# File extension for all board pages.
use constant CHARSET => 'utf-8';	
use constant CONVERT_CHARSETS => 1;			# Do character set conversions internally
use constant SPAM_FILES => './spam.txt';
use constant USE_XHTML => 1;
#use constant HOME => '/';
use constant HTACCESS_PATH => './';
use constant MAX_FCGI_LOOPS => 250;
use constant TIME_OFFSET => 0;				# Time offset in seconds, for display on board pages. You can use this to adjust board time to your local time!
							# Positive value adjusts forward; negative value adjusts backward.
#use constant SQL_REPORT_TABLE => 'user_report';
#use constant STAFF_LOG_RETENTION => 30*24*3600;	# How long should staff log entries be retained? (Seconds)
#use constant REPORT_RETENTION => 30*24*3600;		# How long should report entries be retained? (Seconds)

# no encoding;

# fffffffffffff don't touch
1;
