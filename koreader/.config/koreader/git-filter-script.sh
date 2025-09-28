#!/bin/bash
sed -E "
# Resetting password in sync_server block
/\[\"sync_server\"\]/,/^[[:space:]]*},$/ s/\[\"password\"\] = \"[^\"]*\"/\[\"password\"\] = \"\"/

# Resetting userkey in kosync block
/\[\"kosync\"\]/,/^[[:space:]]*},$/ s/\[\"userkey\"\] = \"[^\"]*\"/\[\"userkey\"\] = \"\"/

s/\[\"lastdir\"\] = \"[^\"]*\"/\[\"lastdir\"\] = \"\"/

s/\[\"lastfile\"\] = \"[^\"]*\"/\[\"lastfile\"\] = \"\"/

s/\[\"device_id\"\] = \"[^\"]*\"/\[\"device_id\"\] = \"\"/
"
