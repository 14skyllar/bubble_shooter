#!/bin/bash

function run()
{
	echo "Running build.sh"
	if [ $(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip') ]; then
		echo "This is Windows WSL!"
		./build_win.sh run
	else
		echo "This is Linux"
		love "$dir_output"
	fi
	echo "Completed build.sh"
}

if [ $# -eq 0 ]; then
	echo "Must pass command: run"
else
	"$@"
fi
