#!/bin/bash

set -x #echo on
DAYS_TO_KEEP=30
BACKUP_DIR=/GDrive/p4Backup
DEPOT_DIR=/PerforceRoot

p4 verify -q //…
p4 verify -u -q //…
p4 admin checkpoint
mv $DEPOT_DIR/journal.* $BACKUP_DIR
mv $DEPOT_DIR/checkpoint.* $BACKUP_DIR

find $BACKUP_DIR/journal.* -mtime +$DAYS_TO_KEEP -exec rm -f {} \;
find $BACKUP_DIR/checkpoint.* -mtime +$DAYS_TO_KEEP -exec rm -f{} \;

rsync -avzhr $DEPOT_DIR/depot/ $BACKUP_DIR/depot/

