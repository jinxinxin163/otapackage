#!/bin/bash

# Uninstall steps: 
kill -9 `pidof  testhello`
rm -rf /bin/testhello

# Install steps:
cp -rfa ./testhello /bin/
chmod 755 /bin/testhello
