#!/bin/bash

#
# This script is invoked by scripts/sweep.py to run a workload on a specified
# platform.
#
# The method_* functions correspond to method names in scripts/apps.py
#

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/../../scripts/platforms.sh

PORT=$((30000 + ${UNIQUE_ID}))

PROCESS_NAME="^\/usr\/bin\/java(.*)voltdb"

# Some dirs
VOLTDB_DIR="${SCRIPT_DIR}/voltdb"
TPCC_DIR="${VOLTDB_DIR}/tests/test_apps/tpcc"
VOLTDB_BIN_DIR="${VOLTDB_DIR}/bin"

pushd ${TPCC_DIR}
    set -x
    sudo pkill -9 -f ${PROCESS_NAME}

    sudo ./run.sh clean jars

    sudo ${VOLTDB_BIN_DIR}/voltdb init --force

    set +x

    # We want to run the actual server command directly here
    ${PLATFORM} ${OUTPUT_PREFIX} "${PARAMS}" \
        "${VOLTDB_BIN_DIR}/voltdb start --client $PORT -H localhost $APP_ARGS" &

    # Extract the exact command being executed from:
    # ${VOLTDB_DIR}/lib/python/voltcli/utility.py:run_cmd()
    #
    # ${PLATFORM} ${OUTPUT_PREFIX} "${PARAMS}" \
    #     "/usr/bin/java -Xmx2048m -Xms2048m -XX:+AlwaysPreTouch -server -Djava.awt.headless=true -Djavax.security.auth.useSubjectCredsOnly=false -Dsun.net.inetaddr.ttl=300 -Dsun.net.inetaddr.negative.ttl=3600 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseTLAB -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+UseCondCardMark -Dsun.rmi.dgc.server.gcInterval=9223372036854775807 -Dsun.rmi.dgc.client.gcInterval=9223372036854775807 -XX:CMSWaitDuration=120000 -XX:CMSMaxAbortablePrecleanTime=120000 -XX:+ExplicitGCInvokesConcurrent -XX:+CMSScavengeBeforeRemark -XX:+CMSClassUnloadingEnabled -XX:+PerfDisableSharedMem -Dlog4j.configuration=file:///<kona-repo-dir>/apps/voltdb/voltdb/voltdb/log4j.xml -Djava.library.path=default -classpath /<kona-repo-dir>/apps/voltdb/voltdb/voltdb/voltdb-10.1.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jetty-continuation-9.4.15.v20190215.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/istack-commons-runtime-3.0.8.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/avro-1.9.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/cron-java8-1.5.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/slf4j-api-1.6.2.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/calcite-linq4j-1.17.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/calcite-server-1.17.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/protobuf-java-3.4.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/janino-2.7.6.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/commons-logging-1.1.3.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/kafka-avro-serializer-3.0.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/calcite-core-1.17.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jetty-servlet-9.4.15.v20190215.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/tomcat-jdbc-7.0.96.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/httpasyncclient-4.0.2.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jackson-databind-2.9.10.1.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/servlet-api-3.1.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jaxb-runtime-2.3.0.1.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/avatica-core-1.12.0-sources.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jackson-dataformat-cbor-2.9.10.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/vmetrics.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jna.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/kafka-schema-registry-client-5.3.2.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/commons-lang3-3.8.1.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/zstd-jni-1.4.4-2.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/httpclient-4.3.6.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jaxb-api-2.3.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/felix-framework-5.6.12.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/avatica-core-1.12.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jetty-io-9.4.15.v20190215.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/slf4j-log4j12-1.6.2.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/calcite-server-1.17.0-sources.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/log4j-1.2.16.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jackson-annotations-2.9.10.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/commons-compiler-2.7.6.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/javax.activation-api-1.2.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jetty-http-9.4.15.v20190215.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/owner-java8-1.0.10.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/snmp4j-2.5.2.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/lz4-java-1.6.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/commons-codec-1.6.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jetty-server-9.4.15.v20190215.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/kafka-clients-2.3.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jsch-0.1.51.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/calcite-linq4j-1.17.0-sources.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jaxb-core-2.3.0.1.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/tomcat-juli-7.0.96.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/metrics-core-2.2.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/netty-all-4.1.43.Final.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/super-csv-2.1.0.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/httpcore-4.3.3.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/owner-1.0.10.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/netty-tcnative-boringssl-static-2.0.34.Final.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/snappy-java-1.1.7.3.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/httpcore-nio-4.3.2.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jackson-core-2.9.10.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jline-2.10.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jetty-util-9.4.15.v20190215.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/calcite-core-1.17.0-sources.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/javax.annotation-api-1.3.2.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/guava-26.0-jre.jar:/<kona-repo-dir>/apps/voltdb/voltdb/lib/jetty-security-9.4.15.v20190215.jar org.voltdb.VoltDB probe placementgroup 0 \
    #         port $PORT mesh localhost" &

    set -x

    echo Waiting for VoltDB to start
    sleep 10

    sudo VOLTDB_CLIENTPORT=$PORT ./run.sh init

    # The actual benchmark command we want to measure
    start_time=$(date +%s%N) && echo "started at $start_time"
    sudo VOLTDB_CLIENTPORT=$PORT ./run.sh client
    end_time=$(date +%s%N) && echo "ended at $end_time" && echo "run time $(((end_time-start_time)/1000000)) ms"

    sudo VOLTDB_CLIENTPORT=$PORT ./run.sh servershutdown
popd

# Exit and cleanup
sudo pkill -9 -f ${PROCESS_NAME}
sudo pkill -9 rss-profiler
