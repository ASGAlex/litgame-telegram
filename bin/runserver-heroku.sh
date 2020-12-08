#!/bin/sh

echo "command: dart --no-sound-null-safety run bin/server.dart --botKey $botKey -u $u -a $a -m $m -r $r -i $i"

dart --no-sound-null-safety run bin/server.dart --botKey "$botKey" -u "$u" -a "$a" -m "$m" -r "$r" -i "$i"