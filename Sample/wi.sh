#!/bin/sh

#rm -f *.mm
#rm -f *.h

me="WInterface/Sample"
arg=$1
if [ "$arg" = "no" ]; then
    exit 0
fi

cd "/Users/Will/Documents/$me/"

ok=1
sound="Glass"

if [ "$arg" = "loop" ]; then
    while [ 1 = 1 ]
    do
        /Users/Will/Library/Developer/Xcode/DerivedData/WInterface-dinhpkjalqnjmyfrcessbfkhkssu/Build/Products/Debug/WInterface sample.wi
        if [ "$?" = "1" ]; then
            sound="Basso"
            ok=0
        fi
        read -p "Press any key"
    done
    exit 0
fi

/Users/Will/Library/Developer/Xcode/DerivedData/WInterface-dinhpkjalqnjmyfrcessbfkhkssu/Build/Products/Debug/WInterface sample.wi
if [ "$?" = "1" ]; then
    sound="Basso"
    ok=0
fi

msg=""

dobuild=0

if [ "$ok" = "1" ]; then

if [ "$dobuild" = "1" ]; then

/usr/bin/osascript <<-EOF

tell application "Notifications Scripting"
	set event handlers script path to "Macintosh HD:Users:Will:Documents:Notifications:Example.scpt"
	set dict to {theName:"Notifications Scripting", theVersion:"1.0", theScript:event handlers script path}
	display notification "$me" subtitle "" message "Building..." sound name "Pop" user info dict
end tell

EOF
    xcodebuild
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