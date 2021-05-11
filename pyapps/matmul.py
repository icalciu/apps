import os

import timeit
import json
import sys

import gc
gc.disable()

if len(sys.argv) < 2 or sys.argv[1] not in ["ones", "arange"]:
    print ("usage: matmul.py <ones|arange> [num_threads]")
    quit()

method = sys.argv[1]
if len(sys.argv) > 2:
    num_threads = int(sys.argv[2])
    print("Using threads: " + str(num_threads))
    os.environ["OMP_NUM_THREADS"] = str(num_threads)
else:
    print("Not setting threads limit")

import numpy as np
print("imports complete")

profile_times = {}
start_time = timeit.default_timer()

if method == "ones":
    matrix_side = 20000
    matrix_side_common = matrix_side

    a = np.ones((matrix_side, matrix_side_common))
    b = np.ones((matrix_side_common, matrix_side))
elif method == "arange":
    matrix_side = 30000
    matrix_side_common = 64

    a = np.arange(matrix_side*matrix_side_common).reshape(matrix_side, matrix_side_common)
    b = np.arange(matrix_side*matrix_side_common).reshape(matrix_side_common, matrix_side)
else:
    quit()

end_time = timeit.default_timer()
profile_times['arange'] = end_time - start_time
start_time = end_time

c = np.matmul(a, b)

end_time = timeit.default_timer()
profile_times['matmul'] = end_time - start_time
start_time = end_time

gc.collect()

end_time = timeit.default_timer()
profile_times['gc'] = end_time - start_time

print("profile_times:::" + str(json.dumps(profile_times)))

#
# Note: uncomment this return statement if you want to verify the output
quit()

print("Verify results")
import hashlib
def print_hash(arr, name):
    hh = hashlib.sha224(arr.tostring()).hexdigest()
    print("Hash {} = {}".format(name, hh))
    return hh


if method == "arange":
    if (print_hash(a, "a") != "0a1bd04bd777eab8db24d0730586e023060e7a544bf83ed08486c219" or
        print_hash(b, "b") != "0a1bd04bd777eab8db24d0730586e023060e7a544bf83ed08486c219" or
        print_hash(c, "c") != "843a28fb477662b26939c80266c12619866a0ff4b80b517547ca98b3"):
        raise Exception("ERROR! Hashes do not match!")
elif method == "ones":
    print_hash(a, "a")
    print_hash(b, "b")
    print_hash(c, "c")
    if (print_hash(a, "a") != "7529d049109151bd56c3db264a31d8120b39afe3075fd4025e5d6c5c" or
        print_hash(b, "b") != "7529d049109151bd56c3db264a31d8120b39afe3075fd4025e5d6c5c" or
        print_hash(c, "c") != "e253c30742fde6c67a7d986352d47495dafef38cc8e6fdf1ceb13160"):
        raise Exception("ERROR! Hashes do not match!")
