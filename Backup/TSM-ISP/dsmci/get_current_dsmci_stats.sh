#! /bin/bash
export LANG=en_US

for i in $(ls *.all.log) 
do
	# collecting data
	tftbp=$(printf " %10d " $(grep "Number of Threads:"        $i | awk -F ':' '{print $2}'))
	total=$(printf " %10d " $(grep 'CMD: >>"/usr/bin/dsmc" i ' $i | wc -l))
	trans=$(printf " %10d " $(grep "Total number of bytes transferred" $i | grep -v "0  B" | wc -l))
	inspe=$(printf " %10d " $(grep "Total number of objects inspected" $i | sed -e 's/\.//g' |  awk -F ':' '{sum+=$2} END {print sum}'))
	backu=$(printf " %10d " $(grep "Total number of objects backed up" $i | sed -e 's/\.//g' |  awk -F ':' '{sum+=$2} END {print sum}'))
	updat=$(printf " %10d " $(grep "Total number of objects updated"   $i | sed -e 's/\.//g' |  awk -F ':' '{sum+=$2} END {print sum}'))
	expir=$(printf " %10d " $(grep "Total number of objects expired"   $i | sed -e 's/\.//g' |  awk -F ':' '{sum+=$2} END {print sum}'))
	faile=$(printf " %10d " $(grep "Total number of objects failed"    $i | sed -e 's/\.//g' |  awk -F ':' '{sum+=$2} END {print sum}'))
	e0362=$(printf " %10d " $(grep "ANS0362E"                  $i | wc -l))
	e1228=$(printf " %10d " $(grep "ANS1228E"                  $i | wc -l))
	e1329=$(printf " %10d " $(grep "ANS1329S"                  $i | wc -l))
	e1351=$(printf " %10d " $(grep "ANS1351E"                  $i | wc -l))
	e4005=$(printf " %10d " $(grep "ANS4005E"                  $i | wc -l))
	error=$(printf " %10d " $(grep "AN[E,R,S][0-9]*[E,S]"      $i | wc -l))

	# printing stats
	printf "\n"	
	printf " Total folders to be  processed    : %10d \n" $tftbp
	printf " Total folders processed           : %10d ==> %7.3f %%\n" $total $(echo "$total / $tftbp * 100" | bc -l)
	printf " Folders with Data stored          : %10d ==> %7.3f %%\n" $trans $(echo "$trans / $tftbp * 100" | bc -l)
	printf "\n"
	printf " Total number of objects inspected : %10d\n" $inspe
	printf " Total number of objects backed up : %10d ==> %7.3f %%\n" $backu $(echo "$backu / $inspe * 100" | bc -l)
	printf " Total number of objects updated   : %10d ==> %7.3f %%\n" $updat $(echo "$updat / $inspe * 100" | bc -l)
	printf " Total number of objects expired   : %10d ==> %7.3f %%\n" $expir $(echo "$expir / $inspe * 100" | bc -l)
	printf " Total number of objects failed    : %10d ==> %7.3f %%\n" $faile $(echo "$faile / $inspe * 100" | bc -l)
	printf " ANS0362E Errors (nummp exceeded)  : %10d\n" $e0362
	printf " ANS1228E Errors (sending failed)  : %10d\n" $e1228
	printf " ANS1329S Errors (Out-od-Space)    : %10d\n" $e1329
	printf " ANS1351E Errors (#sess exceeded)  : %10d\n" $e1351
	printf " ANS4005E Errors (file not found)  : %10d\n" $e4005
	printf " ANS4005E Errors (file not found)  : %10d\n" $e4005
	printf " total number of Errormessages     : %10d\n" $error
	printf "\n"
done
