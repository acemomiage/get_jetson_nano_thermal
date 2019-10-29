#!/bin/bash

SYS_PATH='/sys/devices/virtual/thermal/thermal_zone'
VAL_TYPES=('A0' 'CPU' 'GPU' 'PLL' 'PMIC-Die')

function usage() {
    echo "${1} type"
    echo "Type is .."
    for i in {0..4}; do
        echo "${i} : ${VAL_TYPES[$i]}"
    done
    exit
}

[ ${#} -eq 1 ] || usage $0

echo "$(cat ${SYS_PATH}${1}/temp) / 1000" | bc
