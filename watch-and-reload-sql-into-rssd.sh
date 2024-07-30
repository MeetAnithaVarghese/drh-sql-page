#!/bin/bash

# strict bash
set -euo pipefail

# Color definitions using tput
BRIGHT_YELLOW=$(tput setaf 3; tput bold)
BRIGHT_WHITE=$(tput setaf 7; tput bold)
CYAN=$(tput setaf 6)
DIM=$(tput dim)
RESET=$(tput sgr0)

# Set default database path if not provided
DB_PATH=${SURVEILR_STATEDB_FS_PATH:-resource-surveillance.sqlite.db}

# List all files being watched
echo -e "${DIM}Watching the following files:${RESET}"
ls *.sql.ts *.sql

# Exclude files
EXCLUDE_FILES=("drh-deidentification.sql" "orchestrate-drh-vv.sql")

last_command=""
last_file=""
count=0

# Watch for changes in *.sql.ts and *.sql files
inotifywait -m -e close_write --format '%w%f' *.sql.ts *.sql | while read -r file; do
    # Skip excluded files
    for exclude_file in "${EXCLUDE_FILES[@]}"; do
        if [[ "$file" == *"$exclude_file" ]]; then
            echo -e "${DIM}${file}${RESET} ${BRIGHT_WHITE}excluded${RESET}"
            continue 2
        fi
    done

    if [[ "$file" == *.sql.ts ]]; then
        command="deno run \"$file\" | sqlite3 \"$DB_PATH\""
    elif [[ "$file" == *.sql ]]; then
        command="cat \"$file\" | sqlite3 \"$DB_PATH\""
    else
        continue
    fi

    # Avoid running the same command for the same file multiple times
    if [[ "$file" == "$last_file" ]]; then
        count=$((count + 1))
        echo -e "  ${DIM}$command${RESET} (iteration ${BRIGHT_YELLOW}$count${RESET})"
    else
        if [[ $count -gt 0 ]]; then
            echo ""  # Finish the line for the previous command count
        fi
        count=1
        last_file="$file"
        last_command="$command"
        echo -e "${BRIGHT_WHITE}${file}${RESET} ${DIM}modified, running${RESET} ${BRIGHT_YELLOW}$command${RESET}"
    fi

    eval "$command"
done
