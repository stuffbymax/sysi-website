#!/bin/bash

# Color variables
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
txtrst='\e[0m'    # Text Reset

# Function to get terminal size
get_terminal_size() {
    terminal_width=$(tput cols)
    terminal_height=$(tput lines)
}

# Import the time plugin script
source ./plugins/time_plugin.sh
source ./plugins/system_info_plugin.sh


# Function to display menu
display_menu() {
    get_terminal_size
    clear
    echo -e "${txtgrn}Simple Text Editor${txtrst}"
    echo ""
    echo -e "${txtgrn}1. Create a new file${txtrst}"
    echo -e "${txtgrn}2. Open an existing file${txtrst}"
    echo -e "${txtgrn}3. Edit existing file${txtrst}"
    echo -e "${txtgrn}4. Save file${txtrst}"
    echo -e "${txtgrn}5. Save As${txtrst}"
    echo -e "${txtgrn}6. Search for a word${txtrst}"
    echo -e "${txtgrn}7. Replace a word${txtrst}"
    echo -e "${txtgrn}8. Word Count${txtrst}"
    echo -e "${txtred}9. Delete a file${txtrst}"
    echo -e "${txtcyn}10. Time${txtrst}"
	echo -e "${txtcyn}11. system info${txtrst}"
    echo -e "${txtred}12. Exit${txtrst}"
    echo "--------------------------------------------------------------------------------"
}

# Function to create a new file
create_new_file() {
    echo "Enter the filename or full path of the new file:"
    read -rsn1  # Clear input buffer
    read filenamepath
    echo "Enter text (press Ctrl+D to save and exit):"
    text=$(cat)
    echo "$text" > "$filenamepath"
}

# Function to save the current file with its original name
save_file() {
    if [ -n "$filenamepath" ]; then
        echo "Enter the new name of the file:"
        read new_filename
        if [ -e "$new_filename" ]; then
            echo "File already exists. Do you want to overwrite it? (y/n)"
            read confirm
            if [ "$confirm" != "y" ]; then
                echo "Operation canceled."
                return
            fi
        fi
        cp "$filenamepath" "$new_filename"  # Copy the content of the original file to the new file
        echo "File content copied from $filenamepath to $new_filename."
        echo "$text" > "$new_filename"  # Write the content of the current buffer to the new file
        echo "File saved as $new_filename."
    else
        echo "No file is currently open."
    fi
}

# Function to open an existing file
open_existing_file() {
    echo "Enter the filename or full path of the file to open:"
    read filenamepath
    if [ -f "$filenamepath" ]; then
        lines_count=$(wc -l < "$filenamepath")
        page_size=$(tput lines)
        current_line=1
        while true; do
            clear
            echo "File: $filenamepath (Press 'q' to quit)"
            echo "--------------------------------------------------------------------------------"
            sed -n "$current_line,$((current_line+page_size-1))p" "$filenamepath" | nl -w3 -s'|' -v $current_line  # Add line numbers
            echo "--------------------------------------------------------------------------------"
            read -n 1 -s -r key
            case "$key" in
                q)
                    break
                    ;;
                k)
                    if [ "$current_line" -gt 1 ]; then
                        current_line=$((current_line-1))
                    fi
                    ;;
                j)
                    if [ "$((current_line+page_size-1))" -lt "$lines_count" ]; then
                        current_line=$((current_line+1))
                    fi
                    ;;
                *)
                    # Ignore other keys
                    ;;
            esac
        done
    else
        echo "File not found."
    fi
}

# Function to edit an existing file
edit_existing_file() {
    echo "Enter the filename or filepath of the file to edit:"
    read -r filenamepath

    if [ -f "$filenamepath" ]; then
        lines_count=$(wc -l < "$filenamepath")
        page_size=$(tput lines)
        current_line=1
        edited_text=$(<"$filenamepath")


        while true; do
            clear
            echo "Editing File: $filenamepath (Press q to save and quit)"
            echo "--------------------------------------------------------------------------------"
			echo ""
			echo ""
			echo ""
            sed -n "$current_line,$((current_line+page_size-1))p" "$filenamepath" | nl -w3 -s'|' -v $current_line  # Add line numbers for editing
            echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
            echo "--------------------------------------------------------------------------------"
  read -n 1 -s -r key
            case "$key" in
                q)
                    echo "$edited_text" > "$filenamepath"  # Save the edited text to the file
                    echo "Changes saved. Exiting..."
                    break
                    ;;
                k)
                    if [ "$current_line" -gt 1 ]; then
                        current_line=$((current_line-1))
                    fi
                    ;;
                j)
                    if [ "$((current_line+page_size-1))" -lt "$lines_count" ]; then
                        current_line=$((current_line+1))
                    fi
                    ;;
                e)
                    echo "Enter the text to replace the current line:"
                    read new_text
                    edited_text=$(sed "${current_line}s/.*/$new_text/" <<< "$edited_text")
                    echo "$edited_text" > "$filenamepath"  # Update the edited text in the file
                    ;;
                *)
                    # Ignore other keys
                    ;;
            esac
        done
    else
        echo "File not found."
    fi
}



save_as() {
    echo "Enter the name of the file to create:"
    read new_filename
    if [ -e "$new_filename" ]; then
        echo "File already exists. Do you want to overwrite it? (y/n)"
        read confirm
        if [ "$confirm" != "y" ]; then
            echo "Operation canceled."
            return
        fi
    fi
    if [ -n "$filenamepath" ]; then
        echo "$text" > "$new_filename"  # Write the content of the current buffer to the new file
        echo "File created as $new_filename."
    else
        echo "No file is currently open."
    fi
}


# Function to delete a file
delete_file() {
    echo "Enter the name of the file to delete:"
    read filename
    if [ -f "$filename" ]; then
        rm "$filename"
        echo "File deleted."
    else
        echo "File not found."
    fi
}

# Function to search for a word
search_word() {
    echo "Enter the word to search for:"
    read word
    if [ -n "$word" ]; then
        echo "$text" | grep -n "$word"
    else
        echo "Invalid input."
    fi
}

# Function to replace a word
replace_word() {
    echo "Enter the word to replace:"
    read old_word
    echo "Enter the new word:"
    read new_word
    if [ -n "$old_word" ] && [ -n "$new_word" ]; then
        text=$(echo "$text" | sed "s/$old_word/$new_word/g")
        echo "Word replaced."
    else
        echo "Invalid input."
    fi
}

# Function to count words
word_count() {
    echo "Word count:"
    echo "$text" | wc -w
}

# Function to handle time plugin
handle_time_plugin() {
    display_current_time
}

# Function to handle system info plugin
handle_system_info_plugin() {
    display_system_info
}

# Main loop
while true; do
    display_menu

    read -p "Enter your choice: " choice
    case $choice in
        1)
            create_new_file
            ;;
        2)
            open_existing_file
            ;;
        3)
            edit_existing_file
            ;;
        4)
            save_file
            ;;
        5)
            save_as
            ;;
        6)
            search_word
            ;;
        7)
            replace_word
            ;;
        8)
            word_count
            ;;
        9)
            delete_file
            ;;
        10)
            handle_time_plugin  # Invoke the time plugin function
            ;;
        11)
            handle_system_info_plugin  # Invoke the system info plugin function
            ;;
        12)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

    read -p "Press Enter to continue..."
done
