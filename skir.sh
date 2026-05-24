#!/bin/bash
bunx skir@1.2 "$@"
# To be sure, we run the formatter after this
(cd server && gleam format)
