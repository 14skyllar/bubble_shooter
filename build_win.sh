#!/bin/bash

love_title=BubbleShooter.love
cmd="/mnt/c/Windows/System32/cmd.exe"
path_love="C:\Program Files\LOVE"
path_game='Z:\home\flamendless\clients\bubble_shooter\release\love\'${love_title}

function love_only()
{
	if [ ! -d release ]; then
		mkdir -p ./release/love
	fi
	zip -9r "./release/love/${love_title}" . -x \*.git\* -x \*release\* -x \*.sh\*
}

function run()
{
	echo "Running build_win.sh"
	love_only
	$cmd /c start cmd.exe /c "cd $path_love && lovec.exe $path_game & pause"
	echo "Completed build_win.sh"
}

if [ $# -eq 0 ]; then
	echo "Must pass command: run"
else
	"$@"
fi
