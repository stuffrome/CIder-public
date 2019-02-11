#!/bin/sh

#  cleandisk.sh
#  Cider
#
#  Created by Gabriel Perez on 6/24/18.
#  Copyright © 2018 Gabriel Perez. All rights reserved.

search='find /private/var/folders/*/*/T/com.apple.configurator.xpc.DeviceService -name TemporaryItems'
numResults=$($search | wc -l)

if [ $numResults -eq 1 ]
then
    # Directory found is unique
    dir=$($search)

    if [ -z "$(ls $dir)" ]
    then
        echo "Disk is already clean."
        exit 0
    else
        find $dir/* -maxdepth 0 -mmin +60 -print0 | xargs -0 rm -r
    fi

    echo "Files removed. Disk is clean."

elif [ $numResults -gt 1 ]
then
    echo "Error: Multiple directories found. Cannot clean disk."
else
    echo "Error: No directories found."
fi
