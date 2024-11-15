#!/usr/bin/env bash

FILE_NAME="definitions.txt"

function print_menu() {
  echo """
Select an option
0. Type '0' or 'quit' to end program
1. Convert units
2. Add a definition
3. Delete a definition"""
}

function parse_definition() {
  token_count=${#command_line[@]}
  convert_command=${command_line[0]}
  convert_factor=${command_line[1]}
  regex_command='^[a-zA-Z]+_to_[a-zA-Z]+$'
  regex_number='^-?[0-9]+\.?[0-9]*$'
}

function add_to_file() {
  echo $* >> $FILE_NAME
}

function add_definition() {
  correct_definition=false
  while ! $correct_definition; do
    echo "Enter a definition:"
    read -a command_line
    parse_definition
    if [ $token_count -ne 2 ] || [[ ! $convert_command =~ $regex_command ]] || [[ ! $convert_factor =~ $regex_number ]]; then
      echo "The definition is incorrect!"
    else
      correct_definition=true
    fi
  done
  add_to_file ${command_line[@]}
}

function list_file_with_line_numbers() {
  i=1
  while [ $i -le $lines ]; do
    echo $i'. '`sed -n $i'p' $FILE_NAME`
    (( i += 1 ))
  done
}

function delete_line_from_file() {
  if [ $1 -gt 0 ]; then
    sed -i $1'd' $FILE_NAME
  fi
}

function delete_definition() {
  regex="^0 .+$"
  if [ ! -e $FILE_NAME ] || [[ $(echo `wc $FILE_NAME`) =~ $regex ]]; then
    echo "Please add a definition first!"
    return
  fi
  echo "Type the line number to delete or '0' to return"
  regex="^([0-9]+) .*$"
  [[ $(echo `wc $FILE_NAME`) =~ $regex ]] && lines=${BASH_REMATCH[1]}

  list_file_with_line_numbers
  read line
  while [[ ! $line =~ ^[0-9]+$ ]] || [ $line -gt $lines ]; do
    echo "Enter a valid line number!"
    read line
  done
  delete_line_from_file $line
}

function convert_units() {
  if [ ! -e $FILE_NAME ] || [ ! -s $FILE_NAME ]; then
    echo "Please add a definition first!"
    return
  fi

  echo "Type the line number to convert units or '0' to return"
  lines=$(wc -l < $FILE_NAME)
  list_file_with_line_numbers
  read line_number

  while [[ ! $line_number =~ ^[0-9]+$ ]] || [ $line_number -le 0 ] || [ $line_number -gt $lines ]; do
    if [ $line_number -eq 0 ]; then
      return
    fi
    echo "Enter a valid line number!"
    read line_number
  done

  line=$(sed "${line_number}!d" "$FILE_NAME")
  read -a text <<< "$line"
  convert_factor=${text[1]}

  echo "Enter a value to convert:"
  read value

  while [[ ! $value =~ ^-?[0-9]+\.?[0-9]*$ ]]; do
    echo "Enter a float or integer value!"
    read value
  done

  result=$(echo "$value * $convert_factor" | bc -l)
  echo "Result: $result"
}

echo "Welcome to the Simple converter!"
print_menu
read choice
while [[ ! $choice =~ ^0|quit$ ]]; do
  case $choice in
    "1") convert_units;;
    "2") add_definition;;
    "3") delete_definition;;
    *) echo "Invalid option!";;
  esac
  print_menu
  read choice
done
echo "Goodbye!"