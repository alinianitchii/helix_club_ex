#!/bin/sh

echo "Running migrations..."
bin/helix_club eval "Memberships.ReleaseTasks.migrate()"
bin/helix_club eval "Payments.ReleaseTasks.migrate()"
bin/helix_club eval "People.ReleaseTasks.migrate()"

echo "Starting the app..."
exec bin/helix_club start
