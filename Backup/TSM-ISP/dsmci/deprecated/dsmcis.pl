##############################################################################
#
#	dsmciS.pl
#	
#	script for multi stream backup of a given path
#	-- Simple approach
#
#	(C) 2014 -- 2018 GWDG Göttingen, Bjørn Nachtwey
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
# 2014-12-19	0.1    	initial coding
# 2015-01-05	0.1.1	some fixes
# 2015-01-07	0.1.2	lookup all folders 
# 2015-01-09	0.2	some fixes, early \alpha
# 2015-01-15    0.2.1	remove stuff for timestamp checking	
# 2015-08-04	0.3.0	fork off from dsmci for simple approach without depth
# 2015-08-04	0.3.1	added "-mindepth 1" to find to remove root folder
#			added explicit "dsmc i" call for root folder
# 2016-XX-XX	0.3.2	adding some statistics ... 
# 2016-XX-XX	0.3.3	... and try to write timestamps back 
# 2017-05-26	0.4.0	recoded to perl
# 2017-06-14	0.4.1	forking threads
# 2017-06-20	0.4.2	basic statistics
# 2017-06-27	0.4.2.1	enhanced statistics & new version numbering
# 2017-06-27	0.4.3	switch to cfgfile instead of cmdline arguments
# 2017-06-27	0.4.4	creation of profiling file added
# 2017-06-28	0.4.5	profiling added
# 2017-06-29	0.4.5.1	some beautifications
# 2017-06-30	0.4.6	fixed windows time & date
# 2017-08-03	0.4.6.1 some beautifications: dir of #dirs
# 2017-10-23	0.4.7	added ratio of data transfer time
# 2017-10-26	0.4.7.1	some beautifications
# 2017-10-27	0.4.8	replaced "grep on array" with dedicated function "in_array"
# 2017-11-23	0.4.9	added explicit output of "ANS1329S - Server out of space"
# 2018-02-05	0.5.0	changed versioning -- too many new function to call it 1.0 :-)
# 2018-02-05	0.5.0.1	remove uncessary quotation marks from startpath, extend OS check to "msys"
# 2018-02-05	0.5.1.0	added multiple startpaths -- intial approach backing up *all* starting paths at the end
# 2018-02-05	0.5.1.1	backing up starting paths in parallel threads also
# 2018-02-05	0.5.1.5 switch to Apache License, Version 2.0
# 2018-02-14	0.5.1.6	put *all* filehandles in a variable (so some beautifications)
# 2018-02-19	0.5.1.7	added "remove group delimiter" to "bytes transferred"
#
##############################################################################

##############################################################################
##############################################################################
# global settings / global variables
##############################################################################
##############################################################################

use	strict;
use	warnings;
use	File::Spec::Functions;
use 	Time::Piece;
use	Cwd;

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
{	die " Operation System \"$osname\" is not supportet :-("	}

use constant 	FALSE 		=> 	0;
use constant 	TRUE  		=> 	1;
use constant	THREADFAILMAX 	=> 	10; 	# max number of attemps to start a new thread

use constant	RETURNALLOKAY	=>	0;	# 
use constant	RETURNWARNING	=>	4;	#
use constant	RETURNERROR	=>	12;	# backup failed due to errors
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
my	$proctime		= 0.0;		# total processing time in seconds
my	$pproctime		= 0.0;		# partial processing time in seconds per subdir		"Elapsed processing time:               00:00:01"
my	$datatransfertime	= 0.0;		# total data transfer time in seconds			"Data transfer time:                        0.00 sec"
#my	$pdatatranstime		= 0.0;		# partial data transfer time in seconds per subdir
my	$wallclocktime;				# total wallclock time in seconds
my	$speedup;				# ratio of processing time and wallclock time
my	$dttratio 		= 0.0;		# ration between datatransfer time and total time

my	$pidfile;				# name of the pid file
my	$ppid;					# parent process id (this script originally)
my	$cpid;					# child process id (copy of this script)
my	$startpath;				# pathroot where the backup should start from
my	@startpaths		= undef;	# array for multiple startpaths
my	$actpath;				# starting path actually processed
my	$actpathdir;				# name of the actually procces path for logging

my	$cfgfilename		= "dsmcis.cfg";	# name of config file, should be located in current folder
my	$log_filename;				# filename for logging
my	$err_filename;				# filename for error logging
my	@logfiles;				# array for names of all logfiles
my	$logfile;				# name of single logfile
my	$childlogapx		= ".child.log"; # Appendix of child files
my	$statfilename;				# Path and Name of statistics file
my	$proffilename;				# Path and Name of profiling file
my	$profapx		= ".prof";	# Appendix of profiling file
my	@proftimes;				# an Array holding all subfolders and processing times
my	@profdirs;				# an Array holding all subfolders with profiling times available

my	$arg;					# name part of commandline arguments
my	$val;					# value part of commandline arguments
my	$item			= undef;	# running variable
my	$line			= undef;	# another running variable
my	$tline			= undef;	# another running temporary variable
my	@dirs			= undef;	# array for all folders below $startpath
my	@tdirs			= undef;	# temporary array for all folders below $startpath
my	$dir			= undef;	# running variable
my	$numdir			= undef;	# number of dirs to be processed
my	$dircount		= 0;		# number of dirs already processed

my	$maxthreads 		= 4;		# max number of threads running parallel
my	$threads;				# number of threads running
my	$threadfail		= 0;		# counter of threads unable to be started

my	$os;					# switch for "Linux" vs "MSWin"
my	$command;				# for system calls
my	$childreturnvalue;			# return value from child process

my	$errorcount		= 0;		# amount of ANS....E messages
my	$warncount		= 0;		# amount of ANS....W messages
my	$sevecount		= 0;		# amount of ANS....S messages
my	$SooScount		= 0;		# amount of ANS1329S "Server out of Space" messages
my	$returnval		= -1;
						# due to the ISP statistics
my	$objects_inspected	= 0;		# "Total number of objects inspected"
my	$objects_backed_up	= 0;		# "Total number of objects backed up"
my	$objects_updated	= 0;		# "Total number of objects updated"
my	$objects_deleted	= 0;		# "Total number of objects deleted"
my	$objects_expired	= 0;		# "Total number of objects expired"
my	$objects_failed		= 0;		# "Total number of objects failed"
my	$bytes_inspected	= 0;		# "Total number of bytes inspected"
my	$bytes_transferred	= 0;		# "Total number of bytes transferred"

#filehandles
my	$PPIDFILE;
my	$LOGFILE;
my	$ERRFILE;
my	$DIRHANDLE;
my	$CHILDLOGFILE;
my	$STATFILE;
my	$CFGFILE;
my	$PROFFILE;


##############################################################################
##############################################################################
# some tests for given commandline arguments
##############################################################################
##############################################################################

if ( ( defined $ARGV[0]) and ( $ARGV[0] eq "--help" ) )
{
	printf "usage: perl -f dsmciS.pl\n";
	printf "use ./dsmcis.cfg for further configuration!\n";
	printf "\n";
	exit;
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

# set name of PID file
$pidfile	= File::Spec->canonpath("$startpath/dsmci.pid");	# set path and name of timestampfile
$ppid		= $$;							# parents process id (this script's PID)
$log_filename	= $$ . "log";
$err_filename	= $$ . "err";

## check for running processes like this
if ( -e $pidfile )
{
	warn "Found PID file ($pidfile) ! script stopped!";
	exit 15;
}
else
{
	open $PPIDFILE , '>' , $pidfile
		or die "cannot open PIDFILE ". $pidfile;
	printf $PPIDFILE "%d", $ppid;
	close $PPIDFILE;
}

# get from localtime()
(undef, $min, $hour, $mday, $mon, $year, undef, undef, undef) = localtime();
# sec    min   hour   mday  mon   year 	 wday   yday  isdst  
$date			= sprintf "%d-%2.2d-%2.2d", $year+1900, $mon+1, $mday;
$starttimestring	= sprintf "%d-%2.2d-%2.2d %2.2d:%2.2d", $year+1900, $mon+1, $mday, $hour, $min;

###############################################################################
###############################################################################
#	read foldernames and optimize using profiling
###############################################################################
###############################################################################

#
#	find all folders one level below $startpath
#

foreach $actpath (@startpaths)
{
	opendir $DIRHANDLE, $actpath
	  or die "$0: opendir: $!";

	@tdirs 	= grep {-d "$actpath/$_" && ! /^\.{1,2}$/} readdir($DIRHANDLE);
	closedir $DIRHANDLE;

	# add startpath to every $dir @dirs
	foreach $dir (@tdirs)
	{
		$tline	= substr(File::Spec->canonpath($actpath."/".$dir."/_"), 0, -1);
		push @dirs, $tline;
	}
}
# remove empty top element
shift @dirs;

###############################################################################
#	read profiling
###############################################################################

$proffilename	= File::Spec->canonpath("dsmcis".$profapx);
open $PROFFILE , '<', $proffilename
	or warn "STDERR::Cannot open $proffilename";

if ( defined fileno($PROFFILE) )
{
	# check if profiled folders still exist
	while (my $line = <$PROFFILE>)
	{
		# separate time from path itself
		(undef, $item)	= split ';' , $line;
		$item =~ s/^\s+|\s+$//g;
		chomp($line);
		# is this folder still existing?
		if ( in_array($item, @dirs) == TRUE )
		{
			# add it to profile array
			push @proftimes, $line;
			# for inverse check add path name to @profdirs
			push @profdirs, $item;
		}
		# else skip it
	}
	close $PROFFILE;	#
	
	# inverse check: are there some new folders?
	foreach $dir (@dirs)
	{
		if ( in_array($dir, @profdirs) == TRUE )
		{;}		# allready there
		else
		{
			# set enormous time for new folder, so it will be the first one to be processed
			$line	= sprintf "1000000000 ; %s", $dir;
			# add new folder to the beginning of the profiling array
			unshift @proftimes, $line;
		}
	}
	# empty @dirs folder for new use
	while (@dirs)
	{	pop @dirs;}
	@dirs	= undef;
	
	# sort array of profiling times and path names
	my @tproftimes	= sort { $b cmp $a } @proftimes;
	
	# set up new @dirs array in the "right" order
	foreach my $line (@tproftimes)
	{
		(undef, $dir)	= split ';', $line;
		$dir	=~ s/^\s+|\s+$//g;
		push @dirs, $dir;
	}
	# remove empty top element
	shift @dirs;
	# empty @proftimes forlder for new use
	while (@proftimes)
	{	pop @proftimes;}
	@proftimes	= undef;
}
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
$numdir		= (scalar @dirs) + (scalar @startpaths);	# number of dirs to be processed
$dircount	= 0;		# counter of dirs already processed
foreach $dir (@dirs)
{

	# all threads already running ??
	if ($threads lt $maxthreads)
	{	# NO, they don't
		$cpid=fork();					# fork new thread
		if (! defined $cpid)
		{	# unable to fork
			$threadfail++;
			if ($threadfail le THREADFAILMAX)
			{	# retry until THREADFAILMAX reached
				sleep 30;
				redo;
printf "\n\t\nTHREADFAIL!!\n\n";
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
		}
		else
		{	# child process
			# create own log file
			$log_filename	= $ppid . $$. $childlogapx;

			# backup commandline
			$command = "\"$dsmcbin\" i \"$dir*\" -optfile=\"$optfile\" -su=y > $log_filename 2>&1";
#printf "\n\tCMD: %s\n\n", $command;
			
			$childreturnvalue	= system($command);
			
			# add returnvalue to logfile
			open $CHILDLOGFILE, ">>", $log_filename;
			printf $CHILDLOGFILE "\nRETURNVAL: %d\n", $childreturnvalue;
			close $CHILDLOGFILE;
#printf "\t>\tCHILDRETURNVALUE: %5d @ %5d:%s\n", $childreturnvalue, $$, $dir;
			exit $childreturnvalue;
		}
	}
	else # YES, number of max threads reached
	{
		$cpid	= wait();			# wait for any fork exiting
		$dircount++;
		printf "\t => %5d of %5d dirs processed (%5d)\n", $dircount, $numdir, $cpid;
		$threads--;				# decrease number of threads running 
		redo;					# jump back to loop head and do not step ahead
	}
}

## and now the starting paths

foreach $actpath (@startpaths)
{
	# all threads already running ??
	if ($threads lt $maxthreads)
	{	# NO, they don't
		$cpid=fork();					# fork new thread
		if (! defined $cpid)
		{	# unable to fork
			$threadfail++;
			if ($threadfail le THREADFAILMAX)
			{	# retry until THREADFAILMAX reached
				sleep 30;
				redo;
printf "\n\t\nTHREADFAIL!!\n\n";
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
		}
		else
		{	# child process
			# create own log file
			$log_filename	= $ppid . $$. $childlogapx;

			$dir = substr(File::Spec->canonpath("$actpath/"."/_"), 0, -1);
			# backup commandline
			$command = "\"$dsmcbin\" i \"$dir*\" -optfile=\"$optfile\" -su=n > $log_filename 2>&1";
#printf "\n\tCMD: %s\n\n", $command;
			
			$childreturnvalue	= system($command);
			
			# add returnvalue to logfile
			open $CHILDLOGFILE, ">>", $log_filename;
			printf $CHILDLOGFILE "\nRETURNVAL: %d\n", $childreturnvalue;
			close $CHILDLOGFILE;
#printf "\t>\tCHILDRETURNVALUE: %5d @ %5d:%s\n", $childreturnvalue, $$, $dir;
			exit $childreturnvalue;
		}
	}
	else # YES, number of max threads reached
	{
		$cpid	= wait();			# wait for any fork exiting
		$dircount++;
		printf "\t => %5d of %5d dirs processed (%5d)\n", $dircount, $numdir, $cpid;
		$threads--;				# decrease number of threads running 
		redo;					# jump back to loop head and do not step ahead
	}
}

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

# get all logfiles belonging to this script run
@logfiles = grep ( -f ,<$ppid*$childlogapx>);

#
# analyse each logfile
#
foreach $logfile (@logfiles)
{
	open $CHILDLOGFILE, '<' , $logfile;
#		or "
	while (my $line = <$CHILDLOGFILE>)
	{
		my	@temparray	= undef;
		my	$val		= 0.0;
		my	$unit		= undef;
		my	$tsec		= 0.0;
		my	$tmin		= 0.0;
		my	$thour		= 0.0;
		
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
			{ $errorcount++;	}
		}
		elsif ( $line =~ /^AN[RS][0-9]{4}W/ )	# Warnings
		{	$warncount++;	}
		elsif ( $line =~ /^AN[RS][0-9]{4}S/ )	# Severe Errors
		{	$sevecount++;	}
		if ( $line =~ /^ANS1329S/ )		# Server-out-of-Space Errors
		{	$SooScount++;}
		#
		#	collect statistics of all jobs
		#		
		if ( $line =~ /Total number of objects inspected/ )
		{
			@temparray 		= split ':', $line;
			$val			= (pop @temparray);
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$objects_inspected	+= $val;
		}
		elsif ($line =~ /Total number of objects backed up/)
		{
			@temparray 		= split ':', $line;
			$val			= (pop @temparray);
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$objects_backed_up	+= $val;
		}
		elsif ($line =~ /Total number of objects updated/)
		{
			@temparray 		= split ':', $line;
			$val			= (pop @temparray);
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$objects_updated	+= $val;
		}
		elsif ($line =~ /Total number of objects deleted/)
		{
			@temparray 		= split ':', $line;
			$val			= (pop @temparray);
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$objects_deleted	+= $val;
		}
		elsif ($line =~ /Total number of objects expired/)
		{
			@temparray 		= split ':', $line;
			$val			= (pop @temparray);
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$objects_expired	+= $val;
		}
		elsif ($line =~ /Total number of objects failed/)
		{
			@temparray 		= split ':', $line;
			$val			= (pop @temparray);
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$objects_failed		+= $val;
		}
		elsif ($line =~ /Total number of bytes inspected/)
		{
			@temparray 		= split ':', $line;
			($val, $unit) 		= split ' ', $temparray[-1];
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$val			*= get_unit_mupliplier($unit);
			$bytes_inspected	+= $val;
		}
		elsif ($line =~ /Total number of bytes transferred/)
		{
			@temparray 		= split ':', $line;
			($val, $unit) 		= split ' ', $temparray[-1];
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$val			*= get_unit_mupliplier($unit);
			$bytes_transferred	+= $val;
		}
		elsif ($line =~ /Data transfer time/)
		{
			@temparray 		= split ':', $line;
			($val, $unit) 		= split ' ', $temparray[-1];
			$val			=~ s/,//g;		# just to elimitnate grouping delimiter
			$datatransfertime	+= $val;
		}
		elsif ($line =~ /Elapsed processing time/)
		{
			(undef, $thour, $tmin, $tsec) = split ':', $line;
			$pproctime		=  $tsec + (60 * $tmin) + (3600 * $thour);
			$proctime		+= $pproctime;
			my $tline		= sprintf "%10.10d ; %s", $pproctime, $actpathdir;
			if ( $actpathdir ne $startpath ) 
			{	push @proftimes, $tline;	}
		}
	}
	close $CHILDLOGFILE;
}

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
# wirte lines
foreach $line (@sproflines)
{	printf $PROFFILE "%s\n", $line;	}
close $PROFFILE;


###############################################################################
###############################################################################
#	summarize stats
###############################################################################
###############################################################################

$speedup	= $proctime / ($endtime - $starttime);
if ( $datatransfertime < 0.1  or $proctime < 0.1 )
{	$dttratio = 0.0; }
else
{
$dttratio 	= $datatransfertime / $proctime * 100.;
}
$proctime	= convert_time($proctime);
$statfilename	= File::Spec->canonpath($date."-stats.txt");

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
printf $STATFILE "total processing time : %20s\n", $proctime;
printf $STATFILE "total wallclock time  : %20s\n", $wallclocktime;
printf $STATFILE "effective speedup     : %20.3lf using %d parallel threads\n", $speedup, $maxthreads;
printf $STATFILE "datatransfertime ratio: %20.3lf %%\n", $dttratio;
printf $STATFILE "-------------------------------------------------\n";
printf $STATFILE "Objects inspected     : %20d\n", $objects_inspected;
printf $STATFILE "Objects backed up     : %20d\n", $objects_backed_up;
printf $STATFILE "Objects updated       : %20d\n", $objects_updated;
printf $STATFILE "Objects deleted       : %20d\n", $objects_deleted;
printf $STATFILE "Objects expired       : %20d\n", $objects_expired;
printf $STATFILE "Objects failed        : %20d\n", $objects_failed;
printf $STATFILE "Bytes inspected       : %20.3lf (GB)\n", $bytes_inspected;
printf $STATFILE "Bytes transferred     : %20.3lf (GB)\n", $bytes_transferred;
printf $STATFILE "-------------------------------------------------\n";
printf $STATFILE "Number of Errors      : %20d\n", $errorcount;
printf $STATFILE "Number of Warnings    : %20d\n", $warncount;
printf $STATFILE "# of severe Errors    : %20d\n", $sevecount;
printf $STATFILE "# Out-of-Space Errors : %20d\n", $SooScount;

close  $STATFILE;

#
#	clean up and exit
#

unlink $pidfile;	# remove PID file
remove_log_files();

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
		$dircount++;
		printf "\t => %5d of %5d dirs processed (%5d)\n", $dircount, $numdir, $cpid;
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
	elsif ( $l_unit =~ /MB/ )
	{	return	1e-6;	}
	elsif ( $l_unit =~ / B/ )
	{	return	1e-9;	}
}

sub	dbg_print_array
{
	my $i 		= 0;
	my @array	= @_;
	printf "#_:%d\n\n", $#_;
	foreach my $argi (@_)
	{
		printf "_\[%d\]: >%s<\n", $i, $argi;
		$i++;
	}
}

sub convert_time 	# (c) 2008 by https://neilang.com/articles/converting-seconds-into-a-readable-format-in-perl/
{
  my $ltime = shift;
  my $days = int($ltime / 86400);
  $ltime -= ($days * 86400);
  my $hours = int($ltime / 3600);
  $ltime -= ($hours * 3600);
  my $minutes = int($ltime / 60);
  my $seconds = $ltime % 60;

  $days = $days < 1 ? '' : $days .'d ';
  $hours = $hours < 1 ? '' : $hours .'h ';
  $minutes = $minutes < 1 ? '' : $minutes . 'm ';
  $ltime = $days . $hours . $minutes . $seconds . 's';
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
