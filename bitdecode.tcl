

set configfile "[file rootname $argv0].cfg"

# This software's version
set revcode 1.0



# Set the log level.  Known values are:
# debug
# info
# notice
# warn
# error
# critical
# alert
# emergency
set loglevel debug

# -------------------------- Set up fonts -----------------------------

# This has to come before the logger setup, since the logger needs
# fonts for the console logger.
font create FixedFont -family TkFixedFont -size 12
font create LogFont -family TkFixedFont -size 8; # Font for console log







#----------------------------- Set up logger --------------------------

# The logging system will use the console text widget for visual
# logging.

package require logger

# Set up a visual console for logging
frame .console_frme -relief groove
# Set up the text widget.  Specify -width in units of characters in
# the -font option
text .console_text -yscrollcommand {.console_scrl set} \
    -width 100 \
    -height 10 \
    -font LogFont
# Use yview for a vertical scrollbar -- scrolls in the y direction
# based on input
scrollbar .console_scrl -orient vertical -command {.console_text yview}

# initialize logger subsystems
# two loggers are created
# 1. main
# 2. a separate logger for plugins
set log [logger::init main]
set log [logger::init global]
${::log}::setlevel $loglevel; # Set the log level



proc log_to_file {txt} {
    upvar #0 argv0 thisScript; # Associate thisScript with the argv0
    set logfile "[file rootname $thisScript].log"
    set f [open $logfile {WRONLY CREAT APPEND}] ;# instead of "a"
    fconfigure $f -encoding utf-8
    puts $f $txt
    close $f
}

# Send log messages to wherever they need to go
proc log_manager {lvl txt} {
    set msg "\[[clock format [clock seconds]]\] $txt \n"
    # The logfile output
    log_to_file $msg
    
    # The console logger output.  Mark the level names and color them
    # after the text has been inserted.
    if {[string compare $lvl debug] == 0} {
	# Debug level logging
    	set msg "\[ $lvl \] $txt \n"
    	.console_text insert end $msg
    	.console_text tag add debugtag \
	    {insert linestart -1 lines +2 chars} \
	    {insert linestart -1 lines +7 chars}
    	.console_text tag configure debugtag -foreground blue
    }
    if {[string compare $lvl info] == 0} {
	# Info level logging
    	set msg "\[ $lvl \] $txt \n"
    	.console_text insert end $msg
    	.console_text tag add infotag \
	    {insert linestart -1 lines +2 chars} \
	    {insert linestart -1 lines +7 chars}
    	.console_text tag configure infotag -foreground green
    }
    if {[string compare $lvl warn] == 0} {
	# Warn level logging
    	set msg "\[ $lvl \] $txt \n"
    	.console_text insert end $msg
    	.console_text tag add warntag \
	    {insert linestart -1 lines +2 chars} \
	    {insert linestart -1 lines +7 chars}
    	.console_text tag configure warntag -foreground orange
    }
    if {[string compare $lvl error] == 0} {
	# Error level logging
    	set msg "\[ $lvl \] $txt \n"
    	.console_text insert end $msg
    	.console_text tag add errortag \
	    {insert linestart -1 lines +2 chars} \
	    {insert linestart -1 lines +7 chars}
    	.console_text tag configure errortag -foreground red
    } 
}

# Define the callback function for the logger for each log level
foreach lvl [logger::levels] {
    interp alias {} log_manager_$lvl {} log_manager $lvl
    ${log}::logproc $lvl log_manager_$lvl
}


# Testing the logger
.console_text insert end "Current loglevel is: [${log}::currentloglevel] \n"
${log}::info "Known log levels: [logger::levels]"
${log}::info "Known services: [logger::services]"
${log}::debug "Debug message"
${log}::info "Info message"
${log}::warn "Warn message"
${log}::error "Error message"

# ------------------- Set up configuration file -----------------------

lappend ::auto_path ./lib/inifile
package require inifile


# ------------------------ Set up buttons -----------------------------

# Using curly braces around callback function causes late binding --
# value sent is the value when the button was pushed.
ttk::button .calc_butt -text "Calculate" -command {calculate 0x${hexnum}}

# ------------------------ Hex code entry -----------------------------
frame .entry_frme
ttk::label .entry_frme.0x_labl -text "0x" -font FixedFont
entry .entry_frme.hex_enty -relief groove \
    -textvariable hexnum \
    -width 4 \
    -font FixedFont


# ---------------------- Set up pull-down menu ------------------------
menu .menubar
menu .menubar.help -tearoff 0
.menubar add cascade -label Help -menu .menubar.help -underline 0
. configure -menu .menubar -width 200 -height 150
.menubar.help add command -label {About bitdecode...} \
    -underline 0 -command showAbout


# ----------------------- Check buttons for bits ----------------------

# Checkbutton widget names will have the form:
# bytex_bity_cbut
# ...where x is 1 or 2 and y is 0, 1, 2, ..., 7

# Checkbutton associated variables will be in a list with indexes
# 0-15.
set butvallist []; # List of checkbutton variables
frame .bitarray_frme; # The master frame for both byte frames

frame .byte1_frme; # The frame for the first byte
for {set bitnum 0} {$bitnum<8} {incr bitnum} {
    ttk::checkbutton .byte1_bit${bitnum}_cbut \
	-variable byte1bit${bitnum} \
	-text "Byte 1, bit $bitnum"
    lappend butvallist byte1bit${bitnum}
}

frame .byte2_frme; # The frame for the second byte
for {set bitnum 0} {$bitnum<8} {incr bitnum} {
    ttk::checkbutton .byte2_bit${bitnum}_cbut \
	-variable byte2bit${bitnum} \
	-text "Byte 2, bit $bitnum"
    lappend butvallist byte2bit${bitnum}
}




#------------------------- Pack widgets -------------------------------
# Remember that order matters when packing

pack .console_frme -side bottom
pack .console_scrl -fill y -side right -in .console_frme
pack .console_text -fill x -side bottom -expand 1 -in .console_frme

# The bit array master frame
pack .bitarray_frme -expand 1 -side bottom

# The byte1 frame
pack .byte1_frme -side left -expand 1 -ipadx 100 -in .bitarray_frme
for {set bitnum 0} {$bitnum<8} {incr bitnum} {
    pack .byte1_bit${bitnum}_cbut -in .byte1_frme
}

# The byte2 frame
pack .byte2_frme -side right -expand 1 -ipadx 100 -in .bitarray_frme
for {set bitnum 0} {$bitnum<8} {incr bitnum} {
    pack .byte2_bit${bitnum}_cbut -in .byte2_frme
}

pack .entry_frme -padx 5 -pady 5; # Hex word entry frame
pack .entry_frme.hex_enty -side right
pack .entry_frme.0x_labl -side left

pack .calc_butt -expand 1 -pady 5; # The calculate button


proc configfile_init {filename} {
    upvar #0 argv0 thisScript; # Associate thisScript with the argv0
    upvar 1 log inlog
    upvar 1 revcode inrevcode
    set configfile $filename
    set fout [open $configfile w]
    fconfigure $fout -encoding utf-8
    set scriptname [file rootname [file tail $thisScript]]
    ${inlog}::info "Writing configuration file $configfile"
    puts $fout "\# Configuration file for $scriptname"
    puts $fout "\# This file is simply sourced by the tcl interpreter"
    puts $fout ""
    puts $fout "\# Software version that wrote this configuration file"
    puts $fout "set config.version $inrevcode"
    close $fout
}

# Write a configuration file if none exists
if {[file exists $configfile] == 0} {
    # The config file does not exist
    configfile_init $configfile
} else {
    source $configfile
    ${log}::debug "Configuration file version is ${config.version}"
}


#  Define a procedure - an action for Help-About
proc showAbout {} {
    tk_messageBox -message "Tcl/Tk\nHello Windows\nVersion 1.0" \
	-title {About bitdecode}
}

# Initialize all bits to zero
foreach cbval $butvallist {
    set $cbval 0
}


${log}::info "Trying to log to [file rootname $argv0].log"

# Calculate button callback.  I'm ok with using upvar to pull in the
# logger so it doesn't have to be passed around.
proc calculate {hexnum} {
    upvar 1 log inlog
    upvar 1 butvallist inbutvallist
    ${inlog}::info "Button was pressed with $hexnum"
    set shift 0
    foreach cbval $inbutvallist {
	# Loop through each checkbutton variable
	${inlog}::debug "Working with $cbval"
	global $cbval; # Associate with the checkbutton variable
	set bitval [expr $hexnum % 2]
	set hexnum [expr $hexnum / 2]
	${inlog}::debug "Setting $cbval to $bitval"
	set $cbval $bitval
	incr shift
    }	
}



proc getfiledata {filepath} {
    set fp [open $filepath r]
    set filedata [read $fp]
    close $fp
    return $filedata
}


