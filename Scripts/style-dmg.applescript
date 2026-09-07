on run arguments
    set volumeName to item 1 of arguments
    set appName to item 2 of arguments
    set mountPath to item 3 of arguments
    set backgroundFile to POSIX file (mountPath & "/.background/background.png") as alias

    tell application "Finder"
        tell disk volumeName
            open
            delay 1

            tell container window
                set current view to icon view
                set toolbar visible to false
                set statusbar visible to false
                set pathbar visible to false
                set sidebar width to 0
                set bounds to {180, 120, 900, 580}
            end tell

            tell icon view options of container window
                set arrangement to not arranged
                set icon size to 104
                set text size to 13
                set label position to bottom
                set shows item info to false
                set shows icon preview to true
                set background picture to backgroundFile
            end tell

            set position of item appName to {188, 289}
            set position of item "Applications" to {531, 289}
            update without registering applications
            delay 2
            close
        end tell
    end tell
end run
