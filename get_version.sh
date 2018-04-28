#!/bin/bash

if test 0 -eq "$(git diff | wc -l)"; then
    cat VERSION
else
    version_regex='[0-9]+\.[0-9]+\.[0-9]+'
    branch=$(git branch | cut -f 2 -d ' ')
    old_version=$(git diff origin/${branch} VERSION | grep -E "^-${version_regex}" | cut -c 2-)
    new_version=$(git diff origin/${branch} VERSION | grep -E "^\+${version_regex}" | cut -c 2-)

    if ! echo $new_version | grep -E "^${version_regex}" > /dev/null; then
        exit 1
    fi

    echo $new_version
fi
