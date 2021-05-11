import os
import sys
import random
import subprocess
import time
import turicreate as tc

#### Evaluate the model 
# First create test and train data: app_image_classif_create.py
# And train the model: app_image_classif_model.py

######################
tracker='sudo /home/icalciu/ccfpga/peaberry/src/pbsim-ptrace/tracker'

######################

tc.config.set_runtime_config('TURI_DEFAULT_NUM_PYLAMBDA_WORKERS', 56)

pid=os.getpid()
print "[PB]: My pid is " + str(pid)

# Load the data
#data =  tc.SFrame('cats-dogs.sframe')
test_data = tc.SFrame('cats-dogs-test.sframe')

model = tc.load_model('mymodel.model')

# Evaluate the model and print the results
print "Evaluate model"
start=time.time()
metrics = model.evaluate(test_data)
end=time.time()
print end - start
print(metrics['accuracy'])
sys.stdout.flush()

