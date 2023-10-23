#!/bin/bash
module load rclone/1.53.2
PRJ="HCC-CBS-162-Hillman-BFerris-18139-HN-Vectra"
src=/ix/rbao/Projects/$PRJ
dst=odrive:/Internal_Project_Data_2/$PRJ
logs=$src/logs
rlogs=$src/logs/rclone

#Move scripts
echo "Begin moving scripts"
log_file=$(date "+%Y-%m-%d_%H-%M-%S_rclone_scripts_log.txt")
rclone -v copy $src/scripts $dst/scripts \
   --exclude ".git/" --exclude "**.sh~" --exclude "**.un~" \
   2>&1 | tee -a $rlogs/$log_file
echo "Finished" >> $rlogs/$log_file

#Move results
echo "Begin moving results."
log_file=$(date "+%Y-%m-%d_%H-%M-%S_rclone_results_log.txt")
rclone -v copy $src/results $dst/results \
    --exclude "cores/" \
    2>&1 | tee -a $rlogs/$log_file
echo "Finished" >> $rlogs/$log_file

#Move sampleinfo
echo "Begin moving sampleinfo."
log_file=$(date "+%Y-%m-%d_%H-%M-%S_rclone_sampleinfo_log.txt")
rclone -v copy $src/sampleinfo $dst/sampleinfo \
    2>&1 | tee -a $rlogs/$log_file
echo "Finished" >> $rlogs/$log_file

#Move log files
echo "Begin moving logs."
rclone -v copy $logs $dst/logs
echo Finished!
