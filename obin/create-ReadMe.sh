#! /bin/bash

echo "Creating a 'ReadMe.md' in every subfolder -- if not already existing :-)"

find ./ \
  -type d \
  -name '.git*' \
  -prune \
  -o \
  -type d \
  -exec \
    sh -c 'for dir; do [ ! -f "$dir/ReadMe.md" ] && touch "$dir/ReadMe.md"; done' sh {} +

# Explanation of the Command
#
#    find ./: Starts searching from the current directory.
#    -type d: Specifies that you are looking for directories.
#    -name '.git*' -prune: This part tells find to ignore any directories that match the name pattern .git* and not descend into them.
#    -o: This is a logical OR operator, allowing the command to continue searching for other directories.
#    -exec sh -c '...' sh {} +: Executes a shell command for each directory found. The {} is replaced by the found directories.
#    for dir; do ... done: Loops through each directory found.
#    [ ! -f "$dir/ReadMe.md" ]: Checks if the ReadMe.md file does not exist in the directory.
#    && touch "$dir/ReadMe.md": If the file does not exist, it creates a new ReadMe.md file in that directory.

