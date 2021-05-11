import os
import sys
import random
import subprocess
import time
import turicreate as tc

####### Training 
# Run app_image_classif_create.py first


######################
tracker='sudo /home/icalciu/ccfpga/peaberry/src/pbsim-ptrace/tracker'

######################

tc.config.set_runtime_config('TURI_DEFAULT_NUM_PYLAMBDA_WORKERS', 56)

pid=os.getpid()
print "[PB]: My pid is " + str(pid)

# Load the data
train_data = tc.SFrame('cats-dogs-train.sframe')
test_data = tc.SFrame('cats-dogs-test.sframe')

# Create the model
model = tc.image_classifier.create(train_data, target='label')

# Save the model for later use in Turi Create
model.save('mymodel.model')

sys.stdout.flush()
