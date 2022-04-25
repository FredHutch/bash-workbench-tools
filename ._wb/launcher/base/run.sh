#!/bin/bash

set -em

echo "Running natively without any elaborations"

# Execute the tool in the local environment

# Start the tool in the background
/bin/bash ._wb/helpers/run_tool &

# Get the process ID
PID="$!"

# Make a task which can kill this process
if [ ! -d ._wb/bin ]; then mkdir ._wb/bin; fi
echo """
#!/bin/bash

echo \"\$(date) Sending a kill signal to the process\"

kill ${PID}
""" > ._wb/bin/stop
chmod +x ._wb/bin/stop

# Bring the command back to the foreground
fg %1
