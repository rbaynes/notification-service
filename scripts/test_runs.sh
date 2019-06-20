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

# Test the runs class
python3.6 -c "import cloud_common.cc.notifications.runs as r
import logging
logging.basicConfig(level=logging.DEBUG)
runs = r.Runs()
ret=runs.to_str('test_device_ID')
print(f'to_str={ret}')
ret=runs.get_all('test_device_ID')
print(f'get_all={ret}')
ret=runs.get_latest('test_device_ID')
print(f'get_latest={ret}')

runs.start('test_device_ID', 'test recipe name')
ret=runs.to_str('test_device_ID')
print(f'to_str={ret}')
ret=runs.get_all('test_device_ID')
print(f'get_all={ret}')
ret=runs.get_latest('test_device_ID')
print(f'get_latest={ret}')

runs.stop('test_device_ID')
ret=runs.to_str('test_device_ID')
print(f'to_str={ret}')
ret=runs.get_all('test_device_ID')
print(f'get_all={ret}')
ret=runs.get_latest('test_device_ID')
print(f'get_latest={ret}')
"

