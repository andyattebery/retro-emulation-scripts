#!/usr/bin/env bash

rsync -avP --prune-empty-dirs --include="*/" --include="images/*" --include="gamelist.xml" --exclude="*" /Volumes/KNULLI_SD2/roms/ nas-01:/mnt/storage/Games/Art/Batocera/level-3/roms