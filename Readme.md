Redis + Memtier
-------------------

Redis:
- clone https://github.com/antirez/redis
- cd redis 
- make distclean # important! 
- make 
- make test 

Configure redis:
- Edit /etc/sysctl.conf and add vm.overcommit_memory=1
- Then reboot or run the command sysctl vm.overcommit_memory=1 for this to take effect
- Disable THP: echo never > /sys/kernel/mm/transparent_hugepage/enabled (as root)
- You can add this to /etc/rc.local to retain the setting after a reboot

Memtier:
- clone https://github.com/RedisLabs/memtier_benchmark
- autoreconf -ivf
- ./configure
- make 
- make install 

Run redis:
- Cd to redis/src
- Run ./redis-server 
- edit config file to not save *.rdb or *.aof file:
   - in main redis folder, edit redis.conf
   - make sure appendonly is no 
   - remove or comment:
	" save 900 1
	  save 300 10
	  save 60 10000
	"
    - add save ""

Run memtier:
./memtier_benchmark -t 10 -n 400000 --ratio 1:1 -c 20 -x 1 --key-pattern R:R --hide-histogram --distinct-client-seed -d 300 --pipeline=1000
./memtier_benchmark -t 10 -n 400000 --ratio 1:1 -c 20 -x 1 --key-pattern S:S --hide-histogram --distinct-client-seed -d 300 --pipeline=1000

-x changes run count 
--out-file=FILE to specify output file 



Metis 
------------------
- https://github.com/ydmao/Metis
- Run linear regression and histogram 
- TODO(irina): add instructions for generating large data files 

Graph analytics
-------------------
- Download wiki dataset from: https://static.turi.com/datasets/US_business_links 
- Download twitter dataset from: http://socialcomputing.asu.edu/datasets/Twitter
- Install TuriCreate: https://github.com/apple/turicreate.git
- go to graph_analytics
- Run app_graph_analytics.py -g [wiki/twitter] -a [pagerank/connectedcomp/labelprop/graphcol]


Image classification 
-----------------------
- Install TuriCreate: https://github.com/apple/turicreate.git
- Download dataset from: https://www.microsoft.com/en-us/download/details.aspx?id=54765 (large dataset)
- go to image_classif
- Open app_image_classif_create.py and change home to your dataset 
- Run app_image_classif_create.py one time only to create the train and test data
- Run app_image_classif_model.py (Takes a few hours)
- Run app_image_classif_predict.py (Takes ~15 mins)
- Run app_image_classif_evaluate.py (Takes ~15 mins)



VoltDB + TPC-C
----------------------
(instructions from Aasheesh):

- To build VoltDB, we need OpenJDK, so install it if you don’t have it: https://stackoverflow.com/questions/14788345/how-to-install-the-jdk-on-ubuntu-linux

- Clone the VoltDB repo: https://github.com/VoltDB/voltdb
- Build VoltDB: https://github.com/VoltDB/voltdb/wiki/Building-VoltDB
- To disable THP 
    ```
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo never > /sys/kernel/mm/transparent_hugepage/defrag
    ```
- Init the VoltDB server (assuming you are in the main voltdb folder, --force is important, especially if you are running the experiment multiple times, use –force everytime): 
bin/voltdb init --force
- Start the VoltDB server: bin/voltdb start

- Now, we have the server running, lets get the client going
- In a separate terminal, cd in to the tpcc directory: cd tests/test_apps/tpcc
- The default benchmark runs for a specific duration. If you want to run for a specific number of transaction, you need to modify the `client/com/MyTPCC.java` and `client/com/MyLoader.java`. Update them with voltdb/MyTPCC.java and voltdb/MyLoader.java respectively. 
- Modify the client() function at run.sh : replace  `--duration=180 \` with `--transactions=5800000 \`. The default rate limit is 200000 TPS. To set the rate limit to a higher value, add the following line `--ratelimit=200000000 \`.  
- `./run.sh clean && ./run.sh jars`
- Load the database tables: ../../../bin/sqlcmd < ddl.sql
- TPC-C: Run the client: ./run.sh client


MNE
--------------------
- code and instructions available at: https://github.com/mne-tools/mne-python

- Install MNE: pip3 install mne (use conda?)
- conda env update --file apps/py/environment.yml
- conda activate mne



Setup for userfaultfd wp support
----------------------------------
ofed_uninstall
apt-get install -y git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache  libelf-dev libqt4-dev pkg-config ncurses-dev flex bison

git clone https://github.com/xzpeter/linux.git 
cd linux  
git checkout uffd-wp-merged
cp /boot/config-`uname -r` .config
yes '' | make oldconfig
make -j55 && make headers_install && make modules_install && make install && reboot

#after reboot
apt-get -y install libibverbs1 ibverbs-utils librdmacm1 rdmacm-utils ibsim-utils ibutils libcxgb3-1 libibmad5 libibumad3 libmlx4-1 libmthca1 libnes1 infiniband-diags mstflint opensm perftest srptools libibverbs-dev librdmacm-dev libnuma-dev
