#!/bin/sh

#rm -f *.mm
#rm -f *.h

scheme="WI Ruler"


me="$1"
wifile="wi/$1.wi"

arg=$2

if [ "$arg" = "no" ]; then
    exit 0
fi

ok=1

/usr/bin/osascript <<-EOF
tell application "Xcode6.1"
    activate
    tell application "System Events" to keystroke "s" using {command down, option down}
end tell

EOF


export WIBASE=$HOME/Documents
export APPNAME=$me
export MYIP="`ipconfig getifaddr en0`"
if [ "$MYIP" = "" ]; then
    export MYIP="`ipconfig getifaddr en1`"
    if [ "$MYIP" = "" ]; then
        export MYIP="`ipconfig getifaddr en2`"
        if [ "$MYIP" = "" ]; then
            sound="Basso"
            #ok=0
            export MYIP='localhost'
        fi
    fi
fi
echo "WIBASE : $WIBASE" >> /Users/Will/Documents/wi.out.txt
echo "APPNAME : $APPNAME" >> /Users/Will/Documents/wi.out.txt
echo "MYIP : $MYIP" >> /Users/Will/Documents/wi.out.txt

sound="Glass"

if [ "$ok" = "1" ]; then
    pwd
    echo "$wifile" >> /Users/Will/Documents/wi.out.txt

    /Users/Will/WInterface "$wifile" >> /Users/Will/Documents/wi.out.txt 2>&1
    if [ "$?" = "1" ]; then
        sound="Basso"
        ok=0
    fi
fi
echo a

msg=""

dobuild=1

if [ "$ok" = "1" ]; then

if [ "$dobuild" = "1" ]; then

/usr/bin/osascript <<-EOF

tell application "Notifications Scripting"
	set event handlers script path to "Macintosh HD:Users:Will:Documents:Notifications:Example.scpt"
	set dict to {theName:"Notifications Scripting", theVersion:"1.0", theScript:event handlers script path}
	display notification "$me" subtitle "" message "Building..." sound name "Pop" user info dict
end tell

EOF


/usr/bin/osascript <<-EOF
tell application "Xcode6.1"
    activate
    delay 1
    tell application "System Events" to keystroke "r" using command down
end tell

EOF
    #echo -e "\n\nxcodebuild -scheme \"scheme\" build >> /Users/Will/Documents/wi.out.txt 2>&1\n" >> /Users/Will/Documents/wi.out.txt
    #xcodebuild -scheme "$scheme" build >> /Users/Will/Documents/wi.out.txt 2>&1
    if [ "$?" = "0" ]; then
        msg="Success!"
    else
        msg="Build failed"
    fi

else
    msg="WInterface succeeded"
fi

else
    msg="WInterface reported errors"
fi

/usr/bin/osascript <<-EOF

tell application "Notifications Scripting"
	set event handlers script path to "Macintosh HD:Users:Will:Documents:Notifications:Example.scpt"
	set dict to {theName:"Notifications Scripting", theVersion:"1.0", theScript:event handlers script path}
	display notification "$me" subtitle "" message "$msg" sound name "$sound" user info dict
end tell

EOF


echo "done." >> /Users/Will/Documents/wi.out.txt
