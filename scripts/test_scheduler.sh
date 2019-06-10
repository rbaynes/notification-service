#!/bin/bash

# Get the path to parent directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
cd $DIR # Go to the project top level dir.

# Deactivate any current python virtual environment we may be running.
if ! [ -z "${VIRTUAL_ENV}" ] ; then
    echo "deactivate"
fi

# All DEPLOYED env vars live in app.yaml for the gcloud GAE deployed app.
# Since we are running locally, we have to set our env. vars.
if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS}" ]]; then
  # gcloud_env.bash has not been sourced, so do it now
  source $DIR/config/gcloud_env.bash
fi

# Has the user setup the local python environment we need?
if ! [ -d pyenv ]; then
  echo 'ERROR: you have not run ./scripts/local_development_one_time_setup.sh'
  exit 1
fi

# Yes, so activate it for this bash process
source pyenv/bin/activate

# Add the top leve dir to the py path so we can pick up the submodule.
export PYTHONPATH=$DIR

# Test the scheduler class
python3.6 -c "import cloud_common.cc.notifications.scheduler as scheduler
import logging
import datetime as dt
logging.basicConfig(level=logging.DEBUG)
sched = scheduler.Scheduler()

print(f'{sched.get_commands()}')
print(f'\n\nTime now UTC={dt.datetime.utcnow()}')

devID='test_device_ID'
ret=sched.to_str(devID)
print(f'to_str={ret}')

print('\nadd take measurments:')
sched.add(devID, sched.take_measurements_command)
ret=sched.to_str(devID)
print(f'to_str={ret}')

print('\nadd harvest:')
sched.add(devID, sched.harvest_plant_command, 0)
ret=sched.to_str(devID)
print(f'to_str={ret}')

print('\nget take measurement command:')
ret=sched.get_command_dict(devID, sched.take_measurements_command)
print(f'get_command_dict={ret}')

print('\nmodify and replace take measurement command:')
ret[sched.message_key]='Hi Rob, you overwrote the message'
sched.replace_command(devID, ret)
ret=sched.to_str(devID)
print(f'to_str={ret}')

print('\nremove command take measurement:')
sched.remove_command(devID, sched.take_measurements_command)
ret=sched.to_str(devID)
print(f'to_str={ret}')

print('\nremove command that doesnt exist:')
sched.remove_command(devID, 'missing_cmd')
ret=sched.to_str(devID)
print(f'to_str={ret}')

print('\nremove all commands:')
sched.remove_all_commands(devID)
ret=sched.to_str(devID)
print(f'to_str={ret}')

print('\ncheck:')
sched.check(devID)

print('\nbump hours to 1:')
sched.set_testing_hours(1)
sched.check(devID)

print('\nbump hours to 24:')
sched.set_testing_hours(24)
sched.check(devID)

print('\nbump hours to 48:')
sched.set_testing_hours(48)
sched.check(devID)



"

