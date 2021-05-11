The original TPC-C benchmark in voltDB repo works for a specific amount of time. To evaluate it for the same amount of memory consumption, the duration based execution needs to be replaced by a fixed amount of transaction based execution.

- MyTPCC.java: The `run()` function is triggered when `./run.sh client` is executed. Added a counter `numSPCalls` to track the total number of transactions at each epoch. Modify the break logic `while (endTime > currentTime)` with `while (numSPCalls < totalTransactions)`
- MyLoader.java: added the following line to the constructor to expose the `transactions` parameter 
    ```
    m_helpah.add("transactions", "number_of_transactions", "Number of total transactions", 2000000);
    ```
- Command to Run without any container:
    ```
    cgcreate -g memory:voltdb
    echo 8500M > /sys/fs/cgroup/memory/voltdb/memory.limit_in_bytes
   cgexec -g memory:voltdb ./run_tpcc.sh
   ```
- To use ftrace:
    - apt-get install trace-cmd
    - cd /sys/kernel/debug/tracing
    - cat /dev/null >  trace
    - echo 10 > max_graph_depth #how deep you want to trace
    - echo function_graph > current_tracer
    - echo 1 > tracing_on
    - trace-cmd record -p function_graph -g <function_name> #if you want to track a specific function, add -P <pid> 
    - trace-cmd report > <output_file_name>
    - python parse_ftrace -file <trace_output_file> -func <function_name> -count <#of_appearance_to_observe>