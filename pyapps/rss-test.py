import time
import os
import subprocess

pid = os.getpid()

def get_rss(msg):
    print("\nget_rss: {}".format(msg))
    ret = {}
    for k in ["VmRSS", "VmHWM", "VmPeak", "VmSize"]:
        ret[k] = subprocess.check_output(['bash', '-c', 'cat /proc/{}/status | grep {}'.format(pid, k)]).decode('utf-8')
        print ("{}".format(ret[k].strip()))
    return ret


get_rss("init")

import numpy as np
get_rss("after numpy")

small_a = np.arange(4).reshape(2, 2)
small_b = np.arange(4).reshape(2, 2)
get_rss("after small arange")

matrix_side = 32768
matrix_side_common = 64
a = np.arange(matrix_side*matrix_side_common).reshape(matrix_side, matrix_side_common)
b = np.arange(matrix_side*matrix_side_common).reshape(matrix_side_common, matrix_side)
# a = np.random.rand(matrix_side, matrix_side_common)
# b = np.random.rand(matrix_side_common, matrix_side)
get_rss("after large arange")

matrix_side = 20000
a = np.ones((matrix_side, matrix_side))
b = np.ones((matrix_side, matrix_side))
get_rss("after large ones")

small_c = np.matmul(small_a, small_b)
get_rss("after small matmul")
