#! /bin/bash

workdir=/local/Restic
logdir=${workdir}/log
rexcfile=${workdir}/config/excludes.local

export RESTIC_REPOSITORY=$(cat ${workdir}/config/Repo.local)
export RESTIC_PASSWORD=$(  cat ${workdir}/config/Restic-Password.local)

export GOMAXPROCS=2
export RESTIC_READ_CONCURRENCY=2

today=$(date "+%F")

logfile=$logdir/$today.backup.local.log

# check for locks
if [ $(restic list locks) ]
then 
    echo "($(date "+%a %F %R %Z")) :: Need to unlock repo!" >> ${workdir}/log/unlock.log
    restic unlock 
fi

# do backup
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
