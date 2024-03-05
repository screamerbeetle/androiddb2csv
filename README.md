# androiddb2csv
awk scripts to take an android call log, contacts list, and SMS/MMS export and turn it into something I can read.

The goal of this is configurability and simplicity. Change your output by modifying the printf string at the end.

The SMS/MMS script uses gawk for the strftime, converting contacts to an org mode entry works great with nawk!
