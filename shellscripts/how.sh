#!/bin/bash
# title: "how"
# author: Hsieh-Ting Lin
# date: "2025-04-09"
# version: 1.0.0
# description:
# --END-- #
set -o pipefail

# Add cleanup trap at the start
cleanup() {
  rm -f "$output_file" 2>/dev/null
}
trap cleanup EXIT

# Ensure llm CLI is installed
if ! command -v llm &>/dev/null; then
  echo "Error: 'llm' CLI is not installed. Please install it using:"
  echo "pip install llm"
  exit 1
fi

# Ensure the script is called with a question
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [-y] [-m model_name] <your question>"
  exit 1
fi

DEFAULT_MODEL="4o"

auto_execute=false
MODEL="${HOW_SH_MODEL:-$DEFAULT_MODEL}"
while [[ "$1" =~ ^- ]]; do
  case "$1" in
  -y)
    auto_execute=true
    shift
    ;;
  -m)
    shift
    MODEL="$1"
    shift
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

# Combine all arguments into a single question
QUESTION="$*"

UNAME=$(uname -a)

SHELL=$(ps -p $$ -o command= | awk '{print $1}')

spinner() {
  pid=$!
  local delay=0.05
  local spin=('▖' '▘' '▝' '▗' '▖' '▘' '▝' '▗')
  while kill -0 "$pid" 2>/dev/null; do
    for X in "${spin[@]}"; do
      echo -ne "\r$X"
      sleep $delay
    done
  done
  echo -ne "\r" # 清掉最後 spinner 字元
}

PROMPT="
You are an experienced Linux engineer with expertise in all Linux
commands and their
functionality across different Linux systems.

Given a task, generate a single command or a pipeline
of commands that accomplish the task efficiently.
This command is to be executed in the current shell, $SHELL.
For complex tasks or those requiring multiple
steps, provide a pipeline of commands.
Ensure all commands are safe, follow best practices, and are compatible with
the system. Make sure that the command flags used are supported by the binaries
usually available in the current system or shell.
If a command is not compatible with the
system or shell, provide a suitable alternative.

The system information is: $UNAME (generated using: uname -a).

Create a command to accomplish the following task: $QUESTION

Output only the command as a single line of plain text, with no
quotes, formatting, or additional commentary. Do not use markdown or any
other formatting. Do not include the command into a code block.
Don't include the shell itself (bash, zsh, etc.) in the command.
"

output_file=$(mktemp)
llm -m $MODEL "$PROMPT" >$output_file 2>&1 &
spinner
# Despite our best efforts, the output might still contain ```, so we remove it
COMMAND=$(cat $output_file | sed 's/```//g')
rm -f $output_file

# Check if a command was generated
if [ -z "$COMMAND" ]; then
  echo "Error: No command was generated."
  exit 1
fi

while true; do
  echo "Generated command: $COMMAND"

  if [ "$auto_execute" = true ]; then
    echo "Executing: $COMMAND"
    eval "$COMMAND"
    exit $?
  fi

  # Request user confirmation
  read -p "Confirm (y/n/e/?) >> " CONFIRMATION

  if [[ "$CONFIRMATION" =~ ^[Yy]$ ]]; then
    echo "Executing: $COMMAND"
    OUTPUT=$(eval "$COMMAND")
    exit_code=$?
    echo "$OUTPUT"
    if [ $exit_code -ne 0 -a $exit_code -ne 141 ]; then
      echo "Command failed with exit code $exit_code"
      echo "I can attempt to analyze the error and provide a fix."
      read -p "Try to fix the command (y/n) >> " ANALYZE_ERROR
      if [[ "$ANALYZE_ERROR" =~ ^[Yy]$ ]]; then
        PROMPT="The following command has failed: $COMMAND.
        The output was: $OUTPUT
        Understand why did the command fail, and modify it to make it work.
        The shell is $SHELL.
        The system is $UNAME (generated using: uname -a).
        Output only the command as a single line of plain text, with no
        quotes, formatting, or additional commentary. Do not use markdown or any
        other formatting. Do not include the command into a code block.
        Don't include the shell itself (bash, zsh, etc.) in the command.
        "
        output_file=$(mktemp)
        llm -m $MODEL "$PROMPT" >$output_file 2>&1 &
        spinner
        COMMAND=$(cat $output_file)
        rm -f $output_file
      else
        exit $exit_code
      fi
    else
      exit $exit_code
    fi
  elif [[ "$CONFIRMATION" =~ ^[Ee]$ ]]; then
    PROMPT="Please explain the functionality of the following command.
If it consists of multiple commands or a pipeline, provide a detailed explanation for each part.
Output the explanation as plain text without any formatting or additional syntax.
The command to explain is: $COMMAND"

    output_file=$(mktemp)
    llm -m $MODEL "$PROMPT" >$output_file 2>&1 &
    spinner
    EXPLANATION=$(cat $output_file)
    rm -f $output_file
    echo "$EXPLANATION"
    echo ""
  elif [[ "$CONFIRMATION" = "?" ]]; then
    echo "y - confirm and execute"
    echo "n - cancel"
    echo "e - explain the command"
    echo "? - show this help"
    echo ""
  else
    echo "Command execution canceled."
    exit 1
  fi
done
