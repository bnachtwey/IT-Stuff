#! /bin/bash

workdir=/local/Restic
logdir=${workdir}/log
rexcfile=${workdir}/config/excludes.remote

export RESTIC_REPOSITORY=$(cat ${workdir}/config/Repo.remote)
export RESTIC_PASSWORD=$(  cat ${workdir}/config/Restic-Password.remote)

# Performance Flags
export GOMAXPROCS=1 
export RESTIC_READ_CONCURRENCY=1

# derive logfilename from date
today=$(date "+%F")
logfile=$logdir/$today.backup.remote.log

# check for locks
if [ $(restic list locks) ]
then 
    echo "($(date "+%a %F %R %Z")) :: Need to unlock repo!" >> ${workdir}/log/unlock.log
    restic unlock 
fi

# do backup
###########
starttime=$(date "+%a %F %R %Z")
echo "##########################################################################"   >> ${logfile}
echo "### START: $starttime"                                                        >> ${logfile}
echo "##########################################################################"   >> ${logfile}
# remove old cache ??
restic cache --cleanup
echo "##########################################################################"   >> ${logfile}
echo "### home @ LifeBook"                                                          >> ${logfile}
restic backup /home/ --one-file-system --exclude-file ${rexcfile}                   >> ${logfile}
echo "--------------------------------------------------------------------------"   >> ${logfile}
echo "### etc @ LifeBook"                                                           >> ${logfile}
restic backup /etc/  --one-file-system                                              >> ${logfile}
echo "--------------------------------------------------------------------------"   >> ${logfile}
echo "##########################################################################"   >> ${logfile}
endtime=$(date "+%a %F %R %Z")
echo "### END: $endtime"                                                            >> ${logfile}
echo "##########################################################################"   >> ${logfile}
echo ""                                                                             >> ${logfile}

# do pruning
############
# check for locks again
if [ $(restic list locks) ]
then 
    echo "($(date "+%a %F %R %Z")) :: Need to unlock repo!" >> ${workdir}/log/unlock.log
    restic unlock 
fi
logfile=$logdir/$today.prune.remote.log
starttime=$(date "+%a %F %R %Z")
echo "##########################################################################"   >> ${logfile}
echo "### START: $starttime"                                                        >> ${logfile}
echo "##########################################################################"   >> ${logfile}
echo "### forget"                                                                   >> ${logfile}
restic forget --keep-within-hourly 96h --keep-within-daily 14d --keep-within-weekly 2m --keep-within-monthly 2y --keep-within-yearly 75y >> ${logfile}
echo "##########################################################################"   >> ${logfile}
echo "### prune"                                                                    >> ${logfile}
restic prune                                                                        >> ${logfile}
echo "##########################################################################"   >> ${logfile}
echo "### Snapshots"                                                                >> ${logfile}
restic snapshots                                                                    >> ${logfile}
endtime=$(date "+%a %F %R %Z")
echo "##########################################################################"   >> ${logfile}
echo "### END: $endtime"                                                            >> ${logfile}
echo "##########################################################################"   >> ${logfile}
