#!/bin/bash

grep "wacom_config" ~/.xbindkeysrc 2>/dev/null
bindings_ok=$?

if [ $bindings_ok -eq 0 ]; then
    echo "Bindings already setup up in ~/.xbindkeysrc"
    echo "Nothing todo..."
else
    echo "Bindings not found in in ~/.xbindkeysrc"
    echo "Setup bindings..."

#add key bindings to .xbindkeysrc
echo "

# touch ring button (number 13) pressed
\"~/.wacom/wacom_config.sh -t\" 
  b:13

# touch ring button (number 13) pressed
\"~/.wacom/wacom_config.sh -m -v -i\" 
  b:12
" >> ~/.xbindkeysrc

xbindkeys -f ~/.xbindkeysrc -p

echo "If the key binding don't work, just login/logout from your X session."

fi

echo "Ready."
echo ""