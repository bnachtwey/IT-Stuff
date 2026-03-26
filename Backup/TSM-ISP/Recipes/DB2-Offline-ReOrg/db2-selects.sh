#! /bin/bash

##############################################################################
# changelog
# date        version remark
# 2023-04-05  0.1.3   added some more tables to analyse
# 2023-11-23  0.1.2c  moved to new repo
# 2023-11-10  0.1.2b  replaces tabs with 2 spaces  	
# 2023-11-10  0.1.2   moved table names to array for easy adapt
# 2023-02-20  0.1.1   added some tables + info on list 
# 2020-08-12  0.1.0   first version put to gitlab
# 2020-08-XX  0.0.1   initial coding using bash
#
##############################################################################
#
# db-selects.sh
# 
#   a script collecting some information from DB2 for offline reorg
#
#   The Author:
#   (C) 2020 -- 2023 Bjørn Nachtwey, tsm@bjoernsoe.net
#
#   Grateful Thanks to the Companies, who allowed to do the development
#   (C) 2023, 2024   Cristie Data Gmbh, www.cristie.de
#   (C) 2020 -- 2023 GWDG, www.gwdg.de
#
##############################################################################
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License
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

# check if user isn't root (so maybe the instance user)
if [ $USER == "root" ]
then
  echo "script must run as instance user, not ROOT!"
  exit;
fi

# define tables to analyse
tables=(                      \
    "ACTIVITY_LOG"            \
    "AF_SEGMENTS"             \
    "AF_BITFILES"             \
    "ARCHIVE_OBJECTS"         \
    "AS_SEGMENTS"             \
    "BACKUP_OBJECTS"          \
    "BF_AGGREGATE_ATTRIBUTES" \
    "BF_AGGREGATED_BITFILES"  \
    "BF_BITFILE_EXTENTS"      \
    "BF_DEREFERENCED_CHUNKS"  \
    "GROUP_LEADERS"           \
    "EXPORT_OBJECTS"          \
    "REPLICATED_OBJECTS"      \
    "REPLICATING_OBJECTS"     \
    "SC_OBJECT_TRACKER"       \
    "SD_CHUNK_LOCATIONS"      \
    "SD_CHUNK_COPIES"         \
    "SD_RECON_ORDER"          \
    "SD_REFCOUNT_UPDATES"     \
    "SD_REPLICATING_CHUNKS"   \
    "SD_NON_DEDUP_LOCATIONS"  \
    "SD_REPLICATED_CHUNKS"    \
    "
    "TSMMON_STATUS"           )

# possible further tables
#    added above, just delete lines of "non-interest" :-)

# print headline
printf "%25s ; %15s ; %15s ; %15s ; %25s ; %10s \n" "Tabname" "object-Count" "est. time (sec)" "object-space" "space occupied by table" "Pagesize"

# for loop on *all* tables
for tab in ${tables[@]}
do
  count=$(db2 connect to tsmdb1 2>&1>/dev/null && db2 "select count_big(*) from tsmdb1.$tab" | tail -n 4 | head -n 1 | sed -e 's/ //g' -e 's/\.$//');
  estim=$(awk "BEGIN {print ($count / 140000)}");
  tabsize=$(db2 connect to tsmdb1 2>&1>/dev/null && db2 "call sysproc.reorgchk_tb_stats('T','tsmdb1.$tab')" > /dev/null && db2 "select tsize from session.tb_stats" | tail -n 4 | head -n 1 | sed -e 's/ //g' -e 's/\.$//') ;
  tabspace=$(awk "BEGIN {print ($tabsize / 1024 / 1024 / 1024)}")
  pages=$(db2 connect to tsmdb1 2>&1>/dev/null && db2 "select t1.PAGESIZE from syscat.tablespaces t1 left join syscat.tables t2 on (t1.TBSPACEID=t2.TBSPACEID) where t2.tabname='$tab'" | tail -n 4 | head -n 1 | sed -e 's/ //g' -e 's/\.$//');
  pagesize=$(awk "BEGIN {print ($pages / 1024)}")
  
  printf "%25s ; %15d ; %15.3f ; %15d ; %22.3f GB ; %9sK \n" $tab $count $estim $tabsize $tabspace $pagesize
done

printf "\n Info:\n";
printf "you can list all possible tables by issueing \n";
printf "\tdb2 \"select TABNAME from syscat.tables where TABSCHEMA='TSMDB1' and TYPE='T' order by TABNAME\" | grep -v \"^ \"\n";
printf "as instance after 'db2 connect to tsmdb1'\n";
