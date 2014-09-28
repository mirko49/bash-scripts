#!/bin/bash

IFS='
'
# Declare an array with the tags we need    
declare -A id3tags
id3tags[TITLE]="TIT2|TT2"
id3tags[ALBUM]="TALB|TAL"
#id3tags[YEAR]="TYER" 
id3tags[LEAD]="TPE1|TPE2"

# Find our mp3 files, you can send an argument the path to search it    
find $1 -name \*.mp3 | (
  while read SONG; do
  
    rm -f /tmp/song_tags /tmp/song_info
    
    # Load our tags into a tmp file
    id3v2 -l "$SONG" > /tmp/song_info
    VALUE=''
    COMPLETE="Y"

    # Using our array to set the tags attributes
    for TAG in "${!id3tags[@]}"
      do
        
        # Here we take just our tag
        COMMAND="VALUE=\$(egrep '${id3tags[$TAG]}' /tmp/song_info | head -1 | cut -d: -f2- )"

        eval $COMMAND
        
        # Our file has not all the tag we required
        if [ -z "$VALUE" ]
          then COMPLETE="N"
        
        # Got it, save our tag , this replace nonalphanumerics characters
        else
          echo -n "$TAG=" >> /tmp/song_tags
          echo $VALUE | perl -n -e 's/\W/_/g; s/^_+//; s/_+$//; s/_+/_/g; print "$_\n"' >> /tmp/song_tags
        fi
    done

    # Succesfull Move our file
    if [ "$COMPLETE" == "Y" ]
      then
        echo "##################################################################################"
        echo "# Moving or renaming FILE: $SONG"
        source /tmp/song_tags
        mkdir -p ~/music/$LEAD/$ALBUM
        mv $SONG ~/music/$LEAD/$ALBUM/$TITLE.mp3
    fi
  done)
exit
