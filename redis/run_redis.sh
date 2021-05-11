#!/bin/bash

source ./run_make_pbsim.sh

REDIS_HOME='/home/icalciu/redis/src'
MEMTIER_HOME='/home/icalciu/memtier_benchmark'

RESDIR=$RESDIR_HOME/redis_$(date +%Y-%m-%d_%H-%M-%S)

NUMACMD_REDIS="numactl -N 0 -m 0"
NUMACMD_MEMTIER="numactl -N 0 -m 0"
NUMACMD_TRACKER="numactl -N 0 -m 0"

cleanup() {
  echo "Killing old processes..."
  sudo pkill -9 memtier
  sudo pkill -9 -f run_writeprotect.sh
  sudo pkill -2 tracker
  sleep 10 
  sudo pkill -9 redis-server
  sleep 5 
}

run_redis() {
  cleanup
  local cmd="${NUMACMD_REDIS} ${REDIS_HOME}/redis-server ${REDIS_HOME}/../redis_memory.conf"
  echo $cmd 
  eval "$cmd &"
  sleep 5
}

run_memtier_rand() {
  local cmd="${NUMACMD_MEMTIER} ${MEMTIER_HOME}/memtier_benchmark -t 10 -n 400000 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 --out-file=$RESDIR/output_memtier_rand_$1.txt"
  echo $cmd
  eval "$cmd"
  sleep 2
  cleanup
}

run_memtier_seq() {
  local cmd="${NUMACMD_MEMTIER} ${MEMTIER_HOME}/memtier_benchmark -t 10 -n 400000 --ratio 1:1 -c 20 -x 1 --key-pattern S:S --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 --out-file=$RESDIR/output_memtier_seq_$1.txt"
  echo $cmd
  eval "$cmd"
  sleep 2 
  cleanup
}


run_memtier_seq_large() {
  local cmd="${NUMACMD_MEMTIER} ${MEMTIER_HOME}/memtier_benchmark -t 10 -n 8000000 --ratio 1:1 -c 20 -x 1 --key-pattern S:S --hide-histogram --distinct-client-seed -d 300 --pipeline=1000 --out-file=$RESDIR/output_memtier_seq_large_$1.txt"
  echo $cmd
  eval "$cmd"
  sleep 2 
  cleanup
}


run_pbsim() {
  local pid=`pgrep redis-server`
  local cmd="${NUMACMD_TRACKER} sudo ${PBSIM_HOME}/tracker -p $pid"
  echo $cmd
  eval "$cmd &"  
  sleep 10
}

run_redis_rand_pbsim() {
  # redis rand + PBSim
  run_redis 
  run_pbsim
  run_memtier_rand pbsim_$1
  sudo chown icalciu: dcl_*.bin res_pbsim_*.txt
  sudo mv dcl_*.bin $RESDIR/redis_rand_dcl_$1.bin
  sudo mv res_pbsim_*.txt $RESDIR/res_pbsim_redis_rand_$1.txt
}

run_redis_seq_pbsim() {
  # redis seq + PBSim 
  run_redis
  run_pbsim 
  run_memtier_seq pbsim_$1 
  sudo chown icalciu: dcl_*.bin res_pbsim_*.txt
  sudo mv dcl_*.bin $RESDIR/redis_seq_dcl_$1.bin
  sudo mv res_pbsim_*.txt $RESDIR/res_pbsim_redis_seq_$1.txt
}

run_redis_rand_orig() {
  # redis rand original app
  run_redis 
  run_memtier_rand orig
}

run_redis_seq_orig() {
  # redis seq original app
  run_redis
  run_memtier_seq orig
}

run_redis_seq_large_orig() {
  # redis seq original app
  run_redis
  run_memtier_seq_large orig
}

run_redis_rand_orig_wp() {
  # redis rand original app with writeprotect
  run_redis 
  ./run_writeprotect.sh redis-server 1 & 
  run_memtier_rand orig_wp
}

run_redis_seq_orig_wp() {
  # redis rand original app with writeprotect
  run_redis 
  ./run_writeprotect.sh redis-server 1 & 
  run_memtier_seq orig_wp
}

########################################################

cp redis_memory.conf ${REDIS_HOME}/../
mkdir -p $RESDIR
sudo rm -f dcl_*.bin res_pbsim_*.txt
sudo ./configure_redis.sh


###### PBSIM ##################

CMD=(cl wp notracking sleep report_times)
#CMD=(report_times wp)
#CMD=(report_times)

for cmd in ${CMD[@]}; do 
  make_pbsim_$cmd
  run_redis_rand_pbsim $cmd
  #run_redis_seq_pbsim $cmd 
done


######### NO PBSIM ##########
run_redis_rand_orig
#run_redis_seq_orig
#run_redis_seq_large_orig
#run_redis_rand_orig_wp
#run_redis_seq_orig_wp
