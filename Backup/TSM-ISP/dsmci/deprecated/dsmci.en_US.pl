##############################################################################
#
#	dsmci.pl
#	
#	script for multi stream backup of a given path
#	-- limited depth approach
#
#	(C) 2014 -- 2019 GWDG Göttingen, Bjørn Nachtwey
#	    mailto:bjoern.nachtwey@gwdg.de
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
##############################################################################
#
# changelog
# date     	version	remark
# 2014-12-19	0.1    	initial coding using bash
# 2018-02-05	0.6.0.0 fork from dsmcis.pl
# 2018-02-13	0.6.1.0	first version working, but profiling skipped out
# 2018-02-16	0.6.1.1 added global logfile, copying logs from each thread, avoiding lots of childlog files
# 2018-02-19	0.6.1.3 removed further unused lines and settings for testing
# 2018-02-20	0.6.1.4 wrong variable for depth: fixed
# 2018-02-20	0.6.1.5 eliminate grouping delimiter for bytes transferred
# 2019-03-18	0.6.1.6 several fixes suggested by Salvatore Bonaccorso <bonaccos@ee.ethz.ch> -- Thanks, Salvatore!
#			- removed "*" from dsmc i command line
#			- fixed comparison operator from "lt" to "<="
#			- added "dsmc i -subdir --dirsonly" for each starting folder to remove all deleted folder from server_name
# 2019-03-25	0.6.1.7	some more fixes
#			- put lockfile in first startpath
#			- moved progress reporting to start of a thread instead of waiting
# 2019-03-27	0.6.2	some major changes
#			- use File::Find::Rule instead of system based approaches for finding folders
#			- switched from "\" to "/" in path names to skip masking it
# 2019-03-27	0.6.2.1	fixed wrong variable for path in last loop
# 2019-06-25	0.6.2.2 fixed wrong mindepth for folders processed with "-su=n"
# 2019-06-27	0.6.3	collocate both loops in one subroutine
# 2019-07-05	0.6.3.1	added escape sequence to handle with "$" in file / folder names	
#			Thanks to Salvatore again for this fix
# 2019-07-17	0.6.3.2 fixed issue on trailing "*" on dsmc command line: last character is needed to keep trailing "/"
#			renamed last relics of name "dsmcis" to "dsmci"
# 2019-08-19	0.6.4	added file:find:rule expression to omit symlinks
# 2019-11-20    0.6.5   added a patch collecting all error and warning lines and write to an errorlog file
#			Thanks to Salvatore again for this fix
# 2019-11-26	0.6.5.1	added some return codes
# 2019-11-29	0.6.5.2	added a new sequence for escaping "[" and "]" -- patch distributed by Salvatore again
# 2019-12-06	0.6.5.3	removed used sub "array_minus"
# 2019-12-06	0.6.6	changed form of path arrays to "path;SU-switch":
#			removing @sund, @suyd, replaced by @allpaths
# 2019-12-10	0.6.6.1	add the number of threads to top of ".all.log" file
# 2019-12-10	0.6.6.2	add missing recording of severe errors to logfile -- patch by Salvatore
# 2020-02-04	0.6.7	switch path of pid-file from frist startpath to path of dsmci run
# 2020-02-04	0.6.7.1 add switch / option to disable check for pid file (so called sched mode, where the scheduler itself prevents multiple runs)
# 2020-02-04	0.6.7.2 typos removed
# 2020-02-05	0.6.7.3	starting to implement debug mode switch, giving some extra output on run
# 2020-02-06	0.6.8	encapsulate escaping of special characters for non-windows systems 
# 2020-02-12	0.6.8.1 add trailing "*" to backup path for windows again
# 2021-07-14    0.6.8.2 changed names of log files, adding "dsmci"
# 2021-07-15	0.6.9	identify and remove duplicate entries with "SUN" and "SUY" keeping "SUN" if both are given
# 2021-11-29	0.6.10	move evaluation for profiling to child tread, collect more detailed data
# 2021-11-29	0.6.10.1 changed "Bytes inspected" and "Bytes transferred" in prof file to "GBytes"
# 2022-01-24	0.6.10.2 create copy of profile file with Date for timeline anaylsis
# 2022-03-14	0.6.10.3 fixed output of profiling file
# 2022-03-14	0.6.11	add "datatransfertime" to stats file
# 2022-04-13	0.6.12 fixed multiplier as it was 2 times "MB" but no "KB"
#
# important notes
#
# => if not installed, install the module "File::Find::Rule" isussing: cpan -i File::Find::Rule
#
##############################################################################

my	$debugmode	= 0;	# >1 equals TRUE, enabels some printf debugging and prevents removing logfiles
##############################################################################
##############################################################################
# global settings / global variables
##############################################################################
##############################################################################

use	strict;
use	warnings;
use	File::Spec::Functions;
use	File::Find::Rule;
use 	File::Copy;
use	Time::Piece;
use	Fcntl qw(:flock);

my	$dsmcbin;				# path and binary of "dsmc"
my	$optfile;				# optfile to be used
my	$osname	= $^O;				# name of operation systems where this script is run
if ($osname =~ m/linux/)
{
	$dsmcbin	= '/usr/bin/dsmc';
	$optfile	= '/opt/tivoli/tsm/client/ba/bin/dsm.opt';	# default path to optfile
}
elsif (( $osname eq 'MSWin32' ) or ( $osname eq 'msys' ) )
{
	$dsmcbin	= 'C:\Program Files\Tivoli\TSM\baclient\dsmc.exe';
	$optfile	= 'C:\Program Files\Tivoli\TSM\baclient\dsm.opt';# default path to optfile
}
else
{	die " Operation System \"$osname\" is not supported :-("	}

use constant 	FALSE 		=> 	0;
use constant 	TRUE  		=> 	1;
use constant	THREADFAILMAX 	=> 	10; 	# max number of attemps to start a new thread

use constant	RETURNALLOKAY	=>	0;	# 
use constant	RETURNWARNING	=>	4;	#
use constant	RETURNERROR	=>	12;	# backup failed due to errors
use constant	RETURNNOARGS	=>	13;	# no arguments given with call
use constant	RETURNNOCFGFILE	=>	14;	# no cfg file found
use constant	RETURNPIDFOUND	=>	15;	# stopped due to existing pid file
use constant	RETURNNOTHREAD	=>	21;	# cannot start new threads

my	$date;					# date for statistics file | localtime->strftime ('%F') does not work on windows
my	$starttime		= time();	# time in seconds since Jan 1, 1970
my	$starttimestring;			# starting time | localtime->strftime ('%F %R') does not work on windows
my	$endtime;				# 
my	$endtimestring;				#
my	$min;					# Minute part of localtime array
my	$hour;					# hour part of localtime array
my	$mday;					# day of month part of localtime array
my	$mon;					# month part of localtime array
my	$year;					# year part of localtime array
my	$total_elaped_time	= 0.0;		# total processing time in seconds
my	$datatransfertime	= 0.0;		# total data transfer time in seconds			"Data transfer time:                        0.00 sec"
my	$wallclocktime;				# total wallclock time in seconds
my	$speedup;				# ratio of processing time and wallclock time
my	$dttratio 		= 0.0;		# ratio between datatransfer time and total time

my	$pidfile;				# name of the pid file
my	$ppid;					# parent process id (this script originally)
my	$cpid;					# child process id (copy of this script)
my	$startpath;				# pathroot where the backup should start from
my	@startpaths		= undef;	# array for multiple startpaths
my	$actpath;				# starting path actually processed
my	$actpathdir;				# name of the actually procces path for logging
my	$maxdepth		= 3;		# number of directory level to dive into, right here all folders are processed with "-su=y"
my	$depth			= ($maxdepth - 1);	# just one level above $maxdepth, down to here all folders are processed with "-su=n"

my	$cfgfilename		= "dsmci.cfg";	# name of config file, should be located in current folder
my	$log_filename;				# filename for logging
my	$err_filename;				# filename for error logging
my	@errorlines;				# An Array holding all the logged warnings, errors and severe errors
my	$errorlogfilename;                      # filename for collected error messages
my	$globallog_filename;			# filename for collected status logs
my	@logfiles;				# array for names of all logfiles
my	$logfile;				# name of single logfile
my	$childlogapx		= ".child.log"; # Appendix of child files
my	$statfilename;				# Path and Name of statistics file
my	$proffilename;				# Path and Name of profiling file
my	$todproffilename;			# Path and Name of profiling file with date 
my	$profapx		= ".prof";	# Appendix of profiling file
my	@proftimes;				# an Array holding all subfolders and processing times
my	@profdirs;				# an Array holding all subfolders with profiling times available

my	$arg;					# name part of commandline arguments
my	$val;					# value part of commandline arguments
my	$item			= undef;	# running variable
my	$line			= undef;	# another running variable
my	$tline			= undef;	# another running temporary variable
# my	@sund			= undef;	# array for all folders below $startpath to be processed with "su=n"
# my	@suyd			= undef;	# array for all folders below $startpath to be processed with "su=y"
my	@allpaths		= undef;	# array for all folders below $startpath to be processed
my	@tdirs			= undef;	# temporary array for all folders below $startpath
my	$dir			= undef;	# running variable
my	$numdir			= undef;	# number of dirs to be processed
my	$dircount		= 0;		# number of dirs already processed
my	@switcher		= undef;	# switcher for backup with and without subfolders

my	$maxthreads 		= 4;		# max number of threads running parallel
my	$threads;				# number of threads running
my	$threadfail		= 0;		# counter of threads unable to be started

my	$pidmode		= undef;	# reading the pid check from config file
my	$pidcheck		= TRUE;		# setting the mode for checking for a pid file, default is check;

my	$os;					# switch for "Linux" vs "MSWin"
my	$command;				# for system calls
my	$childreturnvalue;			# return value from child process

my	$errorcount		= 0;		# amount of ANS....E messages
my	$warncount		= 0;		# amount of ANS....W messages
my	$sevecount		= 0;		# amount of ANS....S messages
my	$SooScount		= 0;		# amount of ANS1329S "Server out of Space" messages
my	$returnval		= -1;
						# due to the ISP statistics
my	$total_objects_inspected	= 0;	# "Total number of objects inspected"
my	$total_objects_backed_up	= 0;	# "Total number of objects backed up"
my	$total_objects_updated		= 0;	# "Total number of objects updated"
my	$total_objects_deleted		= 0;	# "Total number of objects deleted"
my	$total_objects_expired		= 0;	# "Total number of objects expired"
my	$total_objects_failed		= 0;	# "Total number of objects failed"
my	$total_bytes_inspected		= 0;	# "Total number of bytes inspected"
my	$total_bytes_transferred	= 0;	# "Total number of bytes transferred"
my	$total_transfer_time		= 0;	# "Total transfer time"

#filehandles
my	$PPIDFILE;
my	$LOGFILE;
my	$ERRFILE;
my	$DIRHANDLE;
my	$CHILDLOGFILE;
my	$GLOBALLOGFILE;
my	$STATFILE;
my	$CFGFILE;
my	$PROFFILE;

##############################################################################
##############################################################################
# some tests for given command line arguments
##############################################################################
##############################################################################

if ( ( defined $ARGV[0]) and ( $ARGV[0] eq "--help" ) )
{
	printf "usage: perl -f dsmci.pl\n";
	printf "use file ./dsmci.cfg for further configuration!\n";
	printf "\n";
	exit RETURNNOARGS;
}

##############################################################################
##############################################################################
# read cfg file
##############################################################################
##############################################################################

open $CFGFILE, '<' , $cfgfilename;
if ( defined $CFGFILE )
{
	my	$line1;			# local temporary line variable
	my	$line2;			# local temporary line variable
	while ($line = <$CFGFILE>)
	{
		# skip all lines starting with comment sign
		if 	( $line =~ /^\*/ or  $line =~ /^#/)
		{	next;	}
		# remove inline comments
		if ( (index $line, "#", 1) ge 0 ) 
		{	
			$line1	= substr($line, 0, (index $line, "#", 1) - 1)
		}
		else
		{	$line1	= $line; }
		
		if ( (index $line1, "*", 1) ge 0 )
		{
			$line2	= substr($line1, 0, (index $line1, "*", 1) - 1)
		}
		else
		{	$line2	= $line1;	}

		if 	( $line2 =~ /^MAXTHREADS/ )
		{
			(undef, $maxthreads) = split '=', $line2;
			$maxthreads	 =~ s/^\s+|\s+$//g;
		}
		elsif	( $line2 =~ /^OPTFILE/ )
		{
			(undef, $optfile) = split '=', $line2;
			$optfile	=~ s/^\s+|\s+$//g;
		}
		elsif	( $line2 =~ /^DEPTH/ )
		{
			(undef, $maxdepth) = split '=', $line2;
			$maxdepth	=~ s/^\s+|\s+$//g;
			$depth		= ($maxdepth - 1);
		}
		elsif	( $line2 =~ /^MODE/ )
		{
			(undef, $pidmode) = split '=', $line2;
			$pidmode	=~ s/^\s+|\s+$//g;
			if ( $pidmode =~ /SCHED/ or $pidmode =~ /sched/)
			{	$pidcheck = FALSE; }
		}
		elsif	( $line2 =~ /^STARTPATH/ )
		{
			(undef, $startpath) = split '=', $line2;
			$startpath	=~ s/^\s+|\s+$//g;
			$startpath	=~ s/^"*//;			# remove leading quotation marks
			$startpath	=~ s/"*$//;			# remove trailing quotation marks
			if ( @startpaths )
			{
				push @startpaths, $startpath;
			}
			else
			{
				@startpaths = $startpath;
			}
		}
	}
}
else
{
	warn "cannot open cfg file";
	exit RETURNNOCFGFILE;
}
close $CFGFILE;
shift @startpaths;

foreach $actpath (@startpaths)
{
	printf "STARTPATH >>%s<<\n", $actpath;
}

###############################################################################
#
# some preparation
#
###############################################################################
# get from localtime()
(undef, $min, $hour, $mday, $mon, $year, undef, undef, undef) = localtime();
# sec    min   hour   mday  mon   year 	 wday   yday  isdst  
$date			= sprintf "%d-%2.2d-%2.2d", $year+1900, $mon+1, $mday;
$starttimestring	= sprintf "%d-%2.2d-%2.2d %2.2d:%2.2d", $year+1900, $mon+1, $mday, $hour, $min;

# set name of PID file
$pidfile		= "dsmci.pid";				# set path and name of timestampfile
$ppid			= $$;					# parents process id (this script's PID)
$log_filename		= $$ . "log";
$err_filename		= $$ . "err";
$globallog_filename	= $$ . ".all.log";

$proffilename		= File::Spec->canonpath("dsmci".$profapx);
$todproffilename	= File::Spec->canonpath($date.".dsmci".$profapx);

if ( $pidcheck == TRUE )
{
	## check for running processes like this
	if ( -e $pidfile )
	{
		warn "Found PID file ($pidfile) ! script stopped!";
		exit RETURNPIDFOUND;
	}
	else
	{
		open $PPIDFILE , '>' , $pidfile
			or die "cannot open PIDFILE ". $pidfile;
		printf $PPIDFILE "%d", $ppid;
		close $PPIDFILE;
	}
}



###############################################################################
###############################################################################
#	read foldernames and optimize using profiling
###############################################################################
###############################################################################

###############################################################################
#
#	find all folders below $startpath and seperate for processing with "su=n" or "su=y"
#
###############################################################################

foreach $actpath (@startpaths)
{
	my $rule =  File::Find::Rule->new;
	$rule->directory;
	$rule->maxdepth($maxdepth);
	$rule->mindepth($maxdepth);
	$rule->not($rule->new->symlink);
	my @tsuyd = $rule->in($actpath);
	
	# add su=y information to each path entry
	foreach $item (@tsuyd)
	{
		$line=sprintf "%s;Y", $item;
		push @allpaths, $line;
	}
	
	$rule->directory;
	$rule->maxdepth($depth);
	$rule->mindepth(0);
	$rule->not($rule->new->symlink);
	my @tsund = $rule->in($actpath);
	# add su=y information to each path entry
	foreach $item (@tsund)
	{
		$line=sprintf "%s;N", $item;
		push @allpaths, $line;
	}
}

# remove empty top element
shift @allpaths;

###############################################################################
#
#	eliminate redundant entries from folderlist, keeping SUN if also SUY given
#
###############################################################################

# sort list to put "similar" entries next together
my 	@sortlist = sort @allpaths;

# undef @allpaths, list will be recreated when after duplicates are removed
undef @allpaths;

# look for duplicate entries
# => this also reduces all entries to just one entity with SUN and SUY 
my 	%seen;
 
foreach $item (@sortlist) 
{
	# assuming SUN is sorted upwards of SUY, the SUN entry is first, therefore referencing the first entry only
	$actpath 	= substr $item, 0, -2;
	if (! $seen{$actpath} ) 
	{
		push @allpaths, $item;
		$seen{$actpath} = 1;
	}
}

###############################################################################
#
#	read last profiling
#
###############################################################################

## code snipped off to "profiling_v2.pl"
#else take the dirs as they are listed

###############################################################################
###############################################################################
#	main loop
###############################################################################
###############################################################################

#
# start loop on all folders
#
$threads 	= 0;		# reset number of child threads to zero
$numdir		= (scalar @allpaths);
$dircount	= 0;		# counter of dirs already processed

# write number of threads to global logfile
open $GLOBALLOGFILE, ">>", $globallog_filename;
printf $GLOBALLOGFILE "Number of Threads: %d\n\n", $numdir;
close  $GLOBALLOGFILE;

###############################################################################
#
# 	do the parallel backup
#
###############################################################################

fork_backup_threads(\@allpaths);

# wait for all child threads exiting
wait_for_threads();

###############################################################################
#
# get endtime and calculate wallclocktime
#
###############################################################################
$endtime	= time();
# get from localtime()
(undef, $min, $hour, $mday, $mon, $year, undef, undef, undef) = localtime();
# sec    min   hour   mday  mon   year 	 wday   yday  isdst  
$endtimestring	= sprintf "%d-%2.2d-%2.2d %2.2d:%2.2d", $year+1900, $mon+1, $mday, $hour, $min;
$wallclocktime	= convert_time($endtime - $starttime);

###############################################################################
###############################################################################
#	do some statistics for return code
###############################################################################
###############################################################################

# open global logfile for analyzation
open $GLOBALLOGFILE, '<' , $globallog_filename or warn "cannot open global log file $globallog_filename";

while (my $line = <$GLOBALLOGFILE>)
{
	#
	#	identify subdir
	#
	if ( $line =~ /Incremental backup of volume/ )
	{
		(undef, $actpathdir, undef)	= split '\'', $line;
		$actpathdir	=~ s/\*//g;
	}
	#
	#	collect Errors and Warnings
	#
	if ( $line =~ /^AN[RS][0-9]{4}E/ )	# Errors
	{
		if ( $line =~ /^ANS1228E/ or $line =~ /^ANS1802E/)
		{;}
		else
		{	$errorcount++; push @errorlines, $line;	}
	}
	elsif ( $line =~ /^AN[RS][0-9]{4}W/ )	# Warnings
	{	$warncount++; push @errorlines, $line;	}
	elsif ( $line =~ /^AN[RS][0-9]{4}S/ )	# Severe Errors
	{	$sevecount++; push @errorlines, $line;	}
	if ( $line =~ /^ANS1329S/ )		# Server-out-of-Space Errors
	{	$SooScount++; push @errorlines, $line;	}
	#
	#	collect statistics of all jobs
	#		
	if ( $line =~ /#profilinglog/ )
	{
		# reset variables for profiling
		my	$et	;	# elapsed time
		my	$oi	;	# objects inspected
		my	$ob	;	# objects backed up
		my	$ou	;	# objects updated
		my	$od	;	# objects deleted
		my	$oe	;	# objects expired
		my	$of	;	# objects failed
		my	$bi	;	# bytes inspected
		my	$bt	;	# bytes transfered
		my	$dtt	;	# transfer time
		my  	$rc	= -1;	# return code of child process

		(undef, $et, $dir, $rc, $oi, $ob, $ou, $od, $oe, $of, $bi, $bt, $dtt) = split ';', $line;

		$total_elaped_time		+= $et;		# "Summary on elapsed time"
		$total_objects_inspected	+= $oi;		# "Total number of objects inspected"
		$total_objects_backed_up	+= $ob;		# "Total number of objects backed up"
		$total_objects_updated		+= $ou;		# "Total number of objects updated"
		$total_objects_deleted		+= $od;		# "Total number of objects deleted"
		$total_objects_expired		+= $oe;		# "Total number of objects expired"
		$total_objects_failed		+= $of;		# "Total number of objects failed"
		$total_bytes_inspected		+= $bi;		# "Total number of bytes inspected"
		$total_bytes_transferred	+= $bt;		# "Total number of bytes transferred"
		$total_transfer_time		+= $dtt;	# "Total transfer time"

		my $tline		= sprintf "%10.10d ; %s ; %d ; %d ; %d ; %d ; %d ; %d ; %d ; %lf ; %lf; %lf",
					 $et, $dir, $rc, $oi, $ob, $ou, $od, $oe, $of, $bi, $bt, $dtt;

		# need to figure out why I implemented this vvv
 		if ( $actpathdir ne $startpath ) 
		{	
			push @proftimes, $tline;	
		}
	}
}
close $GLOBALLOGFILE;

###############################################################################
#	write new profiling infos
###############################################################################

# remove empty top elemet
shift @proftimes;

# reorder elements 
my	@sproflines	= sort { $b cmp $a } @proftimes;

# open profiling file
open $PROFFILE, '>', $proffilename
	or warn "Cannot open Profiling file $proffilename";
# write in index line
printf $PROFFILE "# Elapsed Time ; Directory; Return Code; Objects inspected; Objects backed up; Objects updated; Objects deleted; Objects expired; Objects failed; GBytes inspected; GBytes transferred; Data transfer time\n";
# write lines
foreach $line (@sproflines)
{	printf $PROFFILE "%s\n", $line;	}
close $PROFFILE;

# create copy of profline file with actual date in name
copy($proffilename, $todproffilename) or warn "Cannot copy profiling file";

###############################################################################
#   write error info log
###############################################################################

$errorlogfilename	= File::Spec->canonpath($date.".dsmci-error.txt");
open ERRORFILE, '>', $errorlogfilename or warn "Cannot open Error/Warning logfile: $errorlogfilename";
foreach $line (@errorlines) 
{
        print ERRORFILE $line;
}
close(ERRORFILE);

###############################################################################
###############################################################################
#	summarize stats
###############################################################################
###############################################################################

$speedup	= $total_elaped_time / ($endtime - $starttime);
if ( $datatransfertime < 0.1  or $total_elaped_time < 0.1 )
{	$dttratio = 0.0; }
else
{
	$dttratio 	= $datatransfertime / $total_elaped_time * 100.;
}
$total_elaped_time	= convert_time($total_elaped_time);
$statfilename		= File::Spec->canonpath($date.".dsmci-stats.txt");

open $STATFILE, ">", $statfilename 
	or warn "cannot open $statfilename";

printf $STATFILE "Process ID            : %20d\n", $ppid;
foreach $actpath (@startpaths)
{
	printf $STATFILE "Path processed        : %20s\n", $actpath;
}
printf $STATFILE "-------------------------------------------------\n";
printf $STATFILE "Start time            : %20s\n", $starttimestring;
printf $STATFILE "End time              : %20s\n", $endtimestring;
printf $STATFILE "total processing time : %20s\n", $total_elaped_time;
printf $STATFILE "total wallclock time  : %20s\n", $wallclocktime;
printf $STATFILE "effective speedup     : %20.3lf using %d parallel threads\n", $speedup, $maxthreads;
printf $STATFILE "datatransfertime      : %20.3lf %%\n", $datatransfertime;
printf $STATFILE "datatransfertime ratio: %20.3lf %%\n", $dttratio;
printf $STATFILE "-------------------------------------------------\n";
printf $STATFILE "Objects inspected     : %20d\n", $total_objects_inspected;
printf $STATFILE "Objects backed up     : %20d\n", $total_objects_backed_up;
printf $STATFILE "Objects updated       : %20d\n", $total_objects_updated;
printf $STATFILE "Objects deleted       : %20d\n", $total_objects_deleted;
printf $STATFILE "Objects expired       : %20d\n", $total_objects_expired;
printf $STATFILE "Objects failed        : %20d\n", $total_objects_failed;
printf $STATFILE "Bytes inspected       : %20.3lf (GB)\n", $total_bytes_inspected;
printf $STATFILE "Bytes transferred     : %20.3lf (GB)\n", $total_bytes_transferred;
printf $STATFILE "-------------------------------------------------\n";
printf $STATFILE "Number of Errors      : %20d\n", $errorcount;
printf $STATFILE "Number of Warnings    : %20d\n", $warncount;
printf $STATFILE "# of severe Errors    : %20d\n", $sevecount;
printf $STATFILE "# Out-of-Space Errors : %20d\n", $SooScount;

close  $STATFILE;

#
#	clean up and exit
#

if ( $pidcheck == TRUE )
{
	unlink $pidfile;	# remove PID file
}
if ( $debugmode != TRUE )
{
	unlink $globallog_filename;
	remove_log_files();
}

if ( $sevecount gt 1 or $errorcount gt 1 )
{	exit RETURNERROR;	}
elsif	( $warncount gt 1 )
{	exit RETURNWARNING;	}
else
{	exit RETURNALLOKAY;	}

###############################################################################
###############################################################################
#	subroutines
###############################################################################
###############################################################################

sub wait_for_threads
{
	for (1 .. $threads)
	{	
		$cpid	= wait();
	}
}

sub remove_log_files
{
	@logfiles = grep ( -f ,<$ppid*$childlogapx>);
	foreach $logfile (@logfiles)
	{	
		unlink $logfile;# remove log file
	}
}

sub get_unit_mupliplier
{
	my	$l_unit	= shift (@_);
	if ( $l_unit =~ /PB/ )
	{	return	1e6;	}
	elsif ( $l_unit =~ /TB/ )
	{	return	1e3;	}
	elsif ( $l_unit =~ /GB/ )
	{	return	1e0;	}
	elsif ( $l_unit =~ /MB/ )
	{	return	1e-3;	}
	elsif ( $l_unit =~ /KB/ )
	{	return	1e-6;	}
	elsif ( $l_unit =~ / B/ )
	{	return	1e-9;	}
}

sub	dbg_print_array
{
	my $i 		= 0;
	my @array	= @_;
	my $argi	= undef;
	
	printf "#_:%d\n\n", $#_;
	foreach $argi (@_)
	{
		printf "_DBG:_ \[%4d\]: >%s<\n", ++$i, $argi;
	}
	return $i;			# maybe the number of elements will be of interrest?
}

sub convert_time 	# (c) 2008 by https://neilang.com/articles/converting-seconds-into-a-readable-format-in-perl/
{
	my 	$ltime		=  shift;
	my 	$days		=  int($ltime / 86400);
		$ltime		-= ($days * 86400);
	my 	$hours		=  int($ltime / 3600);
		$ltime		-= ($hours * 3600);
	my 	$minutes	=  int($ltime / 60);
	my 	$seconds	=  $ltime % 60;

		$days 		=  $days < 1 ? '' : $days .'d ';
		$hours 		=  $hours < 1 ? '' : $hours .'h ';
		$minutes 	=  $minutes < 1 ? '' : $minutes . 'm ';
		$ltime 		=  $days . $hours . $minutes . $seconds . 's';
	return $ltime;
}

sub in_array
{	
	my ($sstring, @array) = @_;
	
	foreach my $argi (@array)
	{
		if ( $argi eq $sstring )
		{
			return TRUE;
		}
	}
	return	FALSE;
}

# look up if a given string is already stored in an array, where each array item consists of two parts seperated by ";"
sub in_array1
{	
	my 	($sstring, @array) = @_;	# input: string and array
	my	$argi1;				# first element of string given in array @array
	
	foreach my $argi (@array)
	{
		($argi1, undef)	= split ';', $argi;	# devide array item in both parts
		if ( $argi1 eq $sstring )		# compare first part with given string
		{
			return TRUE;
		}
	}
	return	FALSE;
}
# collocate both loops in one subroutine 
sub fork_backup_threads
{
	my	$switcher;	
	
	foreach $item (@allpaths)
	{
		# split path and SU-switcher
		($actpath, $switcher) = split ';', $item;

		# all threads already running ??
		if ($threads < $maxthreads)
		{	# NO, they don't
			$cpid=fork();					# fork new thread
			if (! defined $cpid)
			{	# unable to fork
				$threadfail++;
				if ($threadfail <= THREADFAILMAX)
				{	# retry until THREADFAILMAX reached
					sleep 30;
					redo;
				}
				else
				{	# end all thread and fail
					wait_for_threads();
					remove_pid_file();
					#				# do not remove logfiles
					exit RETURNNOTHREAD;
				}
			}
			if ($cpid)
			{	# parent process
				$threads++;				# increase number of threads running 
				$threadfail = 0;			# reset threadfail
				$dircount++;
				printf "\t => processing dir %5d of %5d (CPID:%5d)\n", $dircount, $numdir, $cpid;
			}
			else
			{	# child process

				# reset variables for profiling
				my	$et		= 0;	# elapsed time
				my	$oi		= 0;	# objects inspected
				my	$ob		= 0;	# objects backed up
				my	$ou		= 0;	# objects updated
				my	$od		= 0;	# objects deleted
				my	$oe		= 0;	# objects expired
				my	$of		= 0;	# objects failed
				my	$bi		= 0;	# bytes inspected
				my	$bt		= 0;	# bytes transfered
				my	$dtt 		= 0;	# transfer time

				# some temporary variables
				my @temparray;		# just a temporary arry for splitting values
				my $unit;			# getting the unit of the value
				my $thour;
				my $tmin;
				my $tsec;

				# create own log file
				$log_filename	= $ppid . $$. $childlogapx;

				# escape special characters if not running on windows
				if (! ( $osname eq 'MSWin32' ) or ( $osname eq 'msys' ) )
				{ 	
					$dir = File::Spec->canonpath("$actpath/#");
					# cut off trailing "#", needed to preserver trailing "/" :-|
					$dir =~ s{\#$}{};

					# escape "$" if part of the name 
					$dir =~ s{\$}{\\\$}g;	
					# escape special [ and ] in paths
					$dir =~ s{([\[\]])}{\\$1}g;
				}
				else
				{
					# add "*" at the end of path
					$dir = File::Spec->canonpath("$actpath/*");
				}

				# backup commandline
				$command = "\"$dsmcbin\" i \"$dir\" -su=$switcher -optfile=\"$optfile\"  >> $log_filename 2>&1";
				if ( $debugmode == TRUE ) { printf "%s\n", $command; } 

				# record commandline in childlogfile
				open $CHILDLOGFILE, ">", $log_filename;
				printf $CHILDLOGFILE "CMD: >>%s<<\n\n", $command;
				close $CHILDLOGFILE;
				
				# do backup and pipe output to childlogfile
				$childreturnvalue	= system($command);

				# copy logfile to global log file
				open $GLOBALLOGFILE, ">>", $globallog_filename;
				# set exclusive lock on file - or wait for the actual lock to resume
				flock ($GLOBALLOGFILE, LOCK_EX);
				open $CHILDLOGFILE, "<", $log_filename;
				while (my $line = <$CHILDLOGFILE>)
				{
					# copy each line to gobal log file
					printf $GLOBALLOGFILE "%s", $line;

					# collect data for profiling log
					if ( $line =~ /Total number of objects inspected/ )
					{
						@temparray 	= split ':', $line;
						$oi		= (pop @temparray);
						$oi		=~ s/\.//g;		# just to eliminate grouping delimiter
						$oi		=~ s/,//g;		# just to eliminate grouping delimiter
					}
					elsif ($line =~ /Total number of objects backed up/)
					{
						@temparray 	= split ':', $line;
						$ob		= (pop @temparray);
						$ob		=~ s/\.//g;		# just to eliminate grouping delimiter
						$ob		=~ s/,//g;		# just to eliminate grouping delimiter
					}
					elsif ($line =~ /Total number of objects updated/)
					{
						@temparray 	= split ':', $line;
						$ou		= (pop @temparray);
						$ou		=~ s/\.//g;		# just to eliminate grouping delimiter
						$ou		=~ s/,//g;		# just to eliminate grouping delimiter
					}
					elsif ($line =~ /Total number of objects deleted/)
					{
						@temparray 	= split ':', $line;
						$od		= (pop @temparray);
						$od		=~ s/\.//g;		# just to eliminate grouping delimiter
						$od		=~ s/,//g;		# just to eliminate grouping delimiter
					}
					elsif ($line =~ /Total number of objects expired/)
					{
						@temparray 	= split ':', $line;
						$oe		= (pop @temparray);
						$oe		=~ s/\.//g;		# just to eliminate grouping delimiter
						$oe		=~ s/,//g;		# just to eliminate grouping delimiter
					}
					elsif ($line =~ /Total number of objects failed/)
					{
						@temparray 	= split ':', $line;
						$of		= (pop @temparray);
						$of		=~ s/\.//g;		# just to eliminate grouping delimiter
						$of		=~ s/,//g;		# just to eliminate grouping delimiter
					}
					elsif ($line =~ /Total number of bytes inspected/)
					{
						@temparray 	= split ':', $line;
						($bi, $unit) 	= split ' ', $temparray[-1];
						$bi		=~ s/\.//g;		# just to eliminate grouping delimiter
						$bi		=~ s/,/\./g;		# replace decimal "," with "."
						$bi		*= get_unit_mupliplier($unit);
					}
					elsif ($line =~ /Total number of bytes transferred/)
					{
						@temparray 	= split ':', $line;
						($bt, $unit) 	= split ' ', $temparray[-1];
						$bt		=~ s/\.//g;		# just to eliminate grouping delimiter
						$bt		=~ s/,/\./g;		# replace decimal "," with "."
						$bt		*= get_unit_mupliplier($unit);
					}
					elsif ($line =~ /Data transfer time/)
					{
						@temparray 	= split ':', $line;
						($dtt, $unit) 	= split ' ', $temparray[-1];
						$dtt		=~ s/\.//g;		# just to eliminate grouping delimiter
						$dtt		=~ s/,/\./g;		# replace decimal "," with "."
					}
					elsif ($line =~ /Elapsed processing time/)
					{
						(undef, $thour, $tmin, $tsec) = split ':', $line;
						$et		=  $tsec + (60 * $tmin) + (3600 * $thour);
					}
				}

				# print line for profiling log
				printf $GLOBALLOGFILE "#profilinglog ; %d ; %s ; %d ; %d ; %d ; %d ; %d ; %d ; %d ; %.3lf ; %.3lf; %.3lf",
					 $et, $dir, $childreturnvalue, $oi, $ob, $ou, $od, $oe, $of, $bi, $bt, $dtt;
				if ( $debugmode == 2 ) 
				{	
					printf "#profilinglog ;  %d ; %s ; %d ;% 15.15d ; % 15.15d ; % 15.15d ; % 15.15d ; % 15.15d ; % 15.15d ; %15.3lf ; %15.3lf; %15.3lf",
					 $et, $dir, $childreturnvalue, $oi, $ob, $ou, $od, $oe, $of, $bi, $bt, $dtt;
				}
				close $CHILDLOGFILE;
				printf $GLOBALLOGFILE "\nRETURNVAL: %d\n", $childreturnvalue;
				# close global log file and remove lock
#				flock ($GLOBALLOGFILE, LOCK_UN);
				close $GLOBALLOGFILE; # also removes lock
				# remove original child log file
				unlink $log_filename;

                		# return rc and finish thread
				exit $childreturnvalue;
			}
		}
		else # YES, number of max threads reached
		{
			$cpid	= wait();			# wait for any fork exiting
			$threads--;				# decrease number of threads running 
			redo;					# jump back to loop head and do not step ahead
		}
	}
}
