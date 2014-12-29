

# By default, the software will look for the configuration file in the
# directory from which it was launched.  If the configuration file is
# not found, one will be created.
set configfile "bitdecode.cfg"

set logfile "bitdecode.log"

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

proc modinfo {modname} {
    set modver [package require $modname]
    set modlist [package ifneeded $modname $modver]
    set modpath [lindex $modlist end]
    return "Loaded $modname module version $modver from ${modpath}."
}


#----------------------------- Set up logger --------------------------

# The logging system will use the console text widget for visual
# logging.

package require logger
source loggerconf.tcl

${log}::info [modinfo logger]

# Testing the logger

.console_text insert end "Current loglevel is: [${log}::currentloglevel] \n"
${log}::info "Trying to log to [file normalize $logfile]"
${log}::info "Known log levels: [logger::levels]"
${log}::info "Known services: [logger::services]"
${log}::debug "Debug message"
${log}::info "Info message"
${log}::warn "Warn message"
${log}::error "Error message"

# ------------------- Set up configuration file -----------------------

package require inifile
${log}::info [modinfo inifile]


proc config_write {configfile} {
    # Write a configuration file
    #
    # Arguments:
    #   configfile -- Configuration file name (with path)
    global log
    global revcode
    set fcon [ini::open $configfile w]
    ini::set $fcon private version $revcode
    ini::comment $fcon private "" "Internal use -- do not edit."
    ini::set $fcon junk key "Some junk"
    ini::comment $fcon junk "" "Some comment about junk section."
    ini::set $fcon crap newkey "Some crap"
    ini::comment $fcon crap "" "Some comment about crap section."
    ini::comment $fcon crap newkey "Some comment about newkey."
    ini::commit $fcon
    ini::close $fcon
    
}

if {[file exists $configfile] == 0} {
    # The config file does not exist
    ${log}::info "Creating new configuration file [file normalize $configfile]"
    set fcon [ini::open $configfile w]
    ini::close $fcon
    config_write $configfile
}



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




#  Define a procedure - an action for Help-About
proc showAbout {} {
    tk_messageBox -message "Tcl/Tk\nHello Windows\nVersion 1.0" \
	-title {About bitdecode}
}

# Initialize all bits to zero
foreach cbval $butvallist {
    set $cbval 0
}

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


