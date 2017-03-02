#!/bin/bash

until [[ `curl -s ${CONSUL}:8500/v1/status/leader` ]]
do
    echo "waiting for consul leader..."
    sleep 5
done

