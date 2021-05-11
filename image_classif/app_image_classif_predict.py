import os
import sys
import random
import subprocess
import time
import turicreate as tc


################### PBSIM ###############################
def do_attach_pbsim():
  #attach PBSim
  subprocess.Popen(tracker + " -p " + str(pid), shell=True)
  time.sleep(5)

######################
tracker='sudo /home/icalciu/ccfpga/peaberry/src/pbsim-ptrace/tracker'

######################

tc.config.set_runtime_config('TURI_DEFAULT_NUM_PYLAMBDA_WORKERS', 56)

pid=os.getpid()
print "[PB]: My pid is " + str(pid)

# Load the test data
#data =  tc.SFrame('cats-dogs.sframe')
test_data = tc.SFrame('cats-dogs-test.sframe')

# Load the model
model = tc.load_model('mymodel.model')
time.sleep(5)

print "Running prediction"
sys.stdout.flush()

#do_attach_pbsim()

start=time.time()
predictions = model.predict(test_data)
end=time.time()
print "Prediction finished"
print end - start
sys.stdout.flush()
