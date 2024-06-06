# Daemon manager with UI

## What it does?

This script allows user to launch, close and monitor deamon processes with zenity-based UI.

## Functions

- Launch and close deamons from dialogue
- List deamons avaliable
- Get status of running deamons
- Scheduled launching and closing of deamons

## CLI params
- `--help` how to use the script
- `-v` versions of the script

## Usage

### Closing Deamons
To close deamons you should go to the tab named "Close deamons" where you can select deamons to be closed.

### Scheduling launching
To schedule launchung you should go to tab named "List avaliable" to see deamons listed int the /etc/init.d/ directory.
There you select deamon and enter time in which deamon should launch in minutes.

### Listing deamons
To list deamons you should go to the "Display" tab where you will see list of all currently running deamons.
To get more information about specific deamon you can select it and it will open new window with it's details.