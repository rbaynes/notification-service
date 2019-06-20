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

# Test the nduler class
python3.6 -c "from cloud_common.cc.notifications.notification_data import NotificationData
import logging
import datetime as dt
logging.basicConfig(level=logging.DEBUG)

nd = NotificationData()

devID='test_device_ID'
ret=nd.to_str(devID)
print(f'to_str={ret}')

print(f'\nadd notif:')
ID=nd.add(devID, 'your attitued has been noticed')
print(f'add returned ID={ID}')
ret=nd.to_str(devID)
print(f'to_str={ret}')

print(f'\nack notif ID={ID}:')
nd.ack(devID, ID)
ret=nd.to_str(devID)
print(f'to_str={ret}')

print(f'\nget UN-ack notif:')
ret=nd.get_unacknowledged(devID)
print(f'returned={ret}')

print(f'\nadd second notif:')
ID=nd.add(devID, 'yada yada')
print(f'add returned ID={ID}')
ret=nd.to_str(devID)
print(f'to_str={ret}')

print(f'\nget UN-ack notif:')
ret=nd.get_unacknowledged(devID)
print(f'returned={ret}')

"

