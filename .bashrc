#!/usr/bin/env bash
for file in ~/.bash_profile.d/*.sh ; do
	source "${file}"
done
