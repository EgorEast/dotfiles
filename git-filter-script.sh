#!/bin/bash
sed '/\[\"sync_server\"\]/,/^[[:space:]]*},$/d'
