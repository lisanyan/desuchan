use strict;

BEGIN {
	use constant S_NOADMIN => 'No ADMIN_PASS defined in the configuration';	# Returns error when the config is incomplete
	use constant S_NOSECRET => 'No SECRET defined in the configuration';		# Returns error when the config is incomplete
	use constant S_NOSQL => 'No SQL settings defined in the configuration';		# Returns error when the config is incomplete

	die S_NOADMIN unless(defined &ADMIN_PASS);
	die S_NOSECRET unless(defined &SECRET);
	die S_NOSQL unless(defined &SQL_DBI_SOURCE);
	die S_NOSQL unless(defined &SQL_USERNAME);
	die S_NOSQL unless(defined &SQL_PASSWORD);

	eval "use constant SQL_ADMIN_TABLE => 'admin'" unless(defined &SQL_ADMIN_TABLE);
	eval "use constant SQL_PROXY_TABLE => 'proxy'" unless(defined &SQL_PROXY_TABLE);
	eval "use constant SQL_REPORT_TABLE => 'reports'" unless(defined &SQL_REPORT_TABLE);
	eval "use constant USE_TEMPFILES => 1" unless (defined &USE_TEMPFILES);
	eval "use constant DATE_STYLE => 'futaba'" unless (defined &DATE_STYLE);
	eval "use constant ERRORLOG => ''" unless (defined &ERRORLOG);
	eval "use constant HOME => '/'" unless (defined &HOME);
	eval "use constant TIME_OFFSET => 0" unless(defined(&TIME_OFFSET));
	eval "use constant JS_FILE => 'wakaba3.js'" unless(defined(&JS_FILE));
	
	eval "use constant CONVERT_COMMAND => ''" unless (defined &CONVERT_COMMAND);

	eval "use constant USE_TEMPFILES => 1" unless(defined &USE_TEMPFILES);
	
	eval "use constant USE_SECURE_ADMIN => 0" unless (defined &USE_SECURE_ADMIN);
	eval "use constant USE_XHTML => 1" unless (defined &USE_XHTML);
	eval "use constant CHARSET => 'utf-8'" unless (defined &CHARSET);
	eval "use constant CONVERT_CHARSETS => 1" unless (defined &CONVERT_CHARSETS);

	eval "use constant PAGE_EXT => '.xhtml'" unless(defined &PAGE_EXT);

	eval "use constant HTACCESS_PATH => './'" unless (defined &HTACCESS_PATH);
	eval "use constant WAKABA_VERSION => '3.0.7 + desuchan'" unless(defined &WAKABA_VERSION);
	eval "use constant ALTERNATE_REDIRECT => 0" unless (defined &ALTERNATE_REDIRECT);
	eval "use constant SQL_ACCOUNT_TABLE => 'staff_accounts'" unless(defined &SQL_ACCOUNT_TABLE);
	eval "use constant SQL_STAFFLOG_TABLE => 'staff_activity'" unless(defined &SQL_STAFFLOG_TABLE);
	eval "use constant SQL_COMMON_SITE_TABLE => 'board_index'" unless(defined &SQL_COMMON_SITE_TABLE);
	
	eval "use constant SPAM_FILES => ('spam.txt')" unless(defined &SPAM_FILES); 
	
	eval "use constant MAX_FCGI_LOOPS => 250" unless (defined &MAX_FCGI_LOOPS);
	
	eval "use constant REPORT_COMMENT_MAX_LENGTH => 250" unless (defined &REPORT_COMMENT_MAX_LENGTH);
	eval "use constant REPORT_RENZOKU => 60" unless(defined &REPORT_RENZOKU);
	
	eval "use constant REPORT_RETENTION => 60*24*3600" unless (defined &REPORT_RETENTION);
	eval "use constant STAFF_LOG_RETENTION => 60*24*3600" unless (defined &STAFF_LOG_RETENTION);
}

1;
