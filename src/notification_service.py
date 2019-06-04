#!/usr/bin/env python3

""" This service subscribes for pub-sub notifications sent by the the 
    MQTT service (on belhaf of device messages).
    - Handles recipe start/stop/end messages.
    - Maintains a schedule of events that can create notifications.
    - Maintains a list of recipe runs.
"""

import os, sys, json, argparse, logging, signal

from cloud_common import cc
from cloud_common.cc.google import pubsub # takes a few secs...
from cloud_common.cc.google import env_vars 

#debugrob: move to main and change to logging
print(f'{__file__} using cloud_common version {cc.version.__version__}')


#------------------------------------------------------------------------------
# Handle the user pressing Control-C
def signal_handler(signal, frame):
    logging.critical( 'Exiting.' )
    sys.exit(0)
signal.signal( signal.SIGINT, signal_handler )


#------------------------------------------------------------------------------
# This callback is called for each PubSub/IoT message we receive.
# We acknowledge the message, then validate and act on it if valid.
def callback(msg):
    try:
        msg.ack() # acknowledge to the server that we got the message

        display_data = msg.data
        if 250 < len(display_data):
            display_data = "..."
        logging.debug('data={}\n  deviceId={}\n  subFolder={}\n  '
            'deviceNumId={}\n'.
            format( 
                display_data, 
                msg.attributes['deviceId'],
                msg.attributes['subFolder'],
                msg.attributes['deviceNumId'] ))

        """debugrob, change this
        # try to decode the byte data as a string / JSON
        pydict = json.loads( msg.data.decode('utf-8'))
        # os.getenv('GCLOUD_PROJECT'),
        # os.getenv('BQ_DATASET'),
        # os.getenv('BQ_TABLE'),
        # os.getenv('CS_BUCKET'))
        """

    except Exception as e:
        logging.critical(f'Exception in callback(): {e}')


#------------------------------------------------------------------------------
def main():

    # Default log level.
    logging.basicConfig( level=logging.ERROR ) # can only call once

    # Parse command line args.
    parser = argparse.ArgumentParser()
    parser.add_argument( '--log', type=str, 
        help='log level: debug, info, warning, error, critical', 
        default='info' )
    args = parser.parse_args()

    # User specified log level.
    numeric_level = getattr( logging, args.log.upper(), None )
    if not isinstance( numeric_level, int ):
        logging.critical('publisher: Invalid log level: %s' % \
                args.log )
        numeric_level = getattr( logging, 'ERROR', None )
    logging.getLogger().setLevel( level=numeric_level )

    # Make sure our env. vars are set up.
    if None == env_vars.cloud_project_id or \
       None == env_vars.notifications_topic_subs:
        logging.critical('Missing required environment variables.')
        exit( 1 )

    # Infinetly re-subscribe to this topic and receive callbacks for each
    # message.
    pubsub.subscribe(env_vars.cloud_project_id, 
            env_vars.notifications_topic_subs, callback)


#------------------------------------------------------------------------------
if __name__ == "__main__":
    main()



