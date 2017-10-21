#!/usr/bin/env bash
#############################################################################
# DESCRIPTION
# This script opens a C source file for edition; it compiles the source; and
# finally run the newly compiled program for testing.
# 
# USAGE
# ./run-c-source.sh -h
#############################################################################
# REQUIREMENTS
# This script expects gcc to be installed on the running system.  If it can't
# be find, it will return an error.
# The default editor is vim; this can be changed under the comment "Settings"
# Another editor can be passed in argument.
#############################################################################
# ERRORS
# 	1	Editor not found
#	2	Compiler (gcc) not found
#	3	Template file not found
#	4	Source file is not a C file (extension is not .c / .h)
#	5	Unknown argument
#############################################################################
# AUTHOR
# Sebastien Masson <sebastien.masson@student.unamur.be>
#
# LICENCE
# I don't give a shit
#
# A word about the "I don't give a shit" licence ...
# - Do whatever you want;
# - Really ... I just don't care, this piece of shit won't make you win a
#   bunch of money;
# - Be kind with your neighbors; and
# - Save the planet;
# - Don't piss me off with stupid questions (I'd love to read smart questions
#   anyhow);
# - People I know IRL are welcome with smart and silly questions;
# - People I don't know IRL should change this prior to formulate stupid
#   requests.
#############################################################################

# Settings
editor_name="vim"		# Default (command for) editor
source_filename="new.c"		# Default filename for C source files

#############################################################################
# DO NOT CHANGE LINES BEYOND THIS POINT UNLESS YOU KNOW WHAT YOU ARE DOING  #
#############################################################################

#############################################################################
# FUNCTIONS #################################################################
#############################################################################
usage()
{
	echo

	echo "NAME"
	echo "   run-c-source - A command line C source edition and compilation script"
	echo

	echo "SYNOPSIS"
	echo "   ./run-c-source.sh [-e <command>] [-t <template.c>] [-b] [-r] <file.x>"
	echo

	echo "DESCRIPTION"
	echo "   Open, compile and run <file.x>"
	echo "   <file.x> can have one of the following extensions: .c or .h (case sensitive)"
	echo "   If <file.x> is not supplied \"$source_filename\" will be used instead"
	echo "   Compilation is performed with \"gcc -Wall -Wextra -O2 -g -o <file> <file.c>\""
	echo

	echo "OPTIONS"
	echo "   -e : Editor"
	echo "      Edit <file.c> with editor given in <command>"
	echo "      <command> is expected to be in \$PATH"
	echo "   -t : Template"
	echo "      Create a new <file.c> based on <template.c>"
	echo "   -b : Build"
	echo "      Compile source file with gcc"
	echo "   -r : Run"
	echo "      Run binary after compilation"
	echo "      Argument \"-r\" will automatically set \"-b\""
	echo "   -c : Clean"
	echo "      Clean screen prior to run script"
	echo "      No effect without argument \"-r\""
	echo "   -h, -? : Help"
	echo "      Display this help page"
	echo

	echo "EXIT STATUS"
	echo "   0   If OK;"
	echo "   1   Editor not found;"
	echo "   2   Compiler (gcc) not found;"
	echo "   3   Template file not found;"
	echo "   4   Source file is not a C file (extension is not .c / .h)."
	echo "   5   Unknown argument"
	echo

	echo "AUTHOR"
	echo "   Initial version written by Sebastien MASSON"
	echo

	echo "REPORTING BUGS"
	echo "   Please don't"
	echo

	echo "SEE ALSO"
	echo "   RTFM"
}

#############################################################################
# PROGRAM ENTRY POINT #######################################################
#############################################################################

# Variables initialisation (Set via command line)
use_template=0		# When set: Use a template file
build_source=0		# When set: C source file is compiled/built
run_binary=0		# When set: Run binary after compilation
clear_screen=0		# When set: Clean display when executing program

#############################################################################
# Handling arguments
#############################################################################
while getopts ":e:t:brch" opt; do
	case $opt in
		e)	# -e <editor command> / Editor to be used
			editor_name=$OPTARG
			;;
		t)	# -n <template.c> / Create new .c file 
			template_filename=$OPTARG
			use_template=1
			;;
		b)	# Compile source file
			build_source=1
			;;
		r)	# Run binary after compilation
			build_source=1	# Compilation mandatory prior running
			run_binary=1
			;;
		c)	# Clean screen prior running program
			clear_screen=1
			;;
		h)	usage		# Display help
			exit 0
			;;
		*)	for last_arg; do true; done
			echo "\"$0 -h\" for help"
			echo "Error: Unknown argument"
			exit 5
	esac
done
shift $(($OPTIND - 1))

# Use default filename if <file.c> is not supplied
if [ -n "$1" ]; then	# Reminder: "-n" = not null
	source_filename=$1
fi

#############################################################################
# Checking requirements
#############################################################################

# Check source file extension
echo -n "Checking source file extension ... "
if ! [[ $source_filename =~ \.c$|\.h$ ]]; then	# Reminder: Extension is .c or .h 
	echo "not recognised"
	echo "Error: Source file in not a C file" 1>&2
	echo "C source files end with .c or .h" 1>&2
	exit 4
fi

# Checking editor
# Notice: Considering the symlink, verifying path makes sense
echo -n "Looking for $editor_name ... "
if ! editor_path="$(type -p "$editor_name")" || [ -z "$editor_path" ]; then
	echo "not found"
	echo "Error: Editor $editor_name not found" 1>&2
	exit 1
else
	echo "found: OK"
fi

# Checking gcc
echo -n "Looking for C compiler ... "
if ! gcc_path="$(type -p gcc)" || [ -z "$gcc_path" ]; then
	echo "not found"
	echo "Error: gcc not found" 1>&2
	exit 2
else
	echo "found: OK"
fi

# Checking template & Checking source file
if [ $use_template -eq 1 ]; then
	# Checking template
	echo -n "Looking for template file \"$template_filename\" ... "
	if ! [ -e "$template_filename" ]; then
		echo "not found"
		echo "Error: File \"$template_filename\" does not exist in $(pwd)" 1>&2
		exit 3
	else
		echo "found: OK"
	fi

	# Checking C source file
	echo -n "Looking for C source file \"$source_filename\" ... "
	if [ -e "$source_filename" ]; then
		echo "already exists: Opening source without copying template"
	else
if [ $clean_screen -eq 1 ]; then
	clear
else
	echo		# Empty lines to keep script outputs far from program ones
	echo
	echo
fi
		echo -n "does not exist: Copying template ... "
		cp $template_filename $source_filename
		echo "done"
	fi
fi

#############################################################################
# Opening source for edition
#############################################################################
echo -n "Opening \"$source_filename\" ... "
$editor_name $source_filename
echo "closed now"

#############################################################################
# Building source
#############################################################################
if [ $build_source -eq 1 ] && [ -e "$binary_filename" ]; then
	if [[ $source_filename =~ \.c$ ]]; then
		echo "Source file ends with .c: Compiling source ..."
		echo "------------------------------------------------------"
		binary_filename=$(echo $source_filename | cut -f 1 -d '.')
		gcc -Wall -Wextra -O2 -g -o $binary_filename $source_filename
		echo "------------------------------------------------------"
		echo "... done"
	else
		echo "Source file ends with .h: Do not compile"
	fi
else
	echo "File \"$source_filename\" not compiled"
fi

#############################################################################
# Runing binary
#############################################################################
if ! [[ $source_filename =~ \.c$ ]]; then
	echo "Only .c source files can be ran"
else
	if [ $run_binary -eq 1 ] && [ -e "$binary_filename" ]; then
		if [ $clear_screen -eq 1 ]; then
			clear
		else
			echo	# Empty lines to keep script outputs far from prog ones
			echo
			echo
		fi
		./$binary_filename
	else
		echo "Program not ran"
	fi
fi

#############################################################################
# End of script
#############################################################################
echo		# Empty line to keep system prompt far from program outputs
echo
echo
exit 0		# Exit status 0: "Everything is fine"
