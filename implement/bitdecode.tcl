

# --------------------- Global configuration --------------------------


# By default, the software will look for the configuration file in the
# directory from which it was launched.  If the configuration file is
# not found, one will be created.
set configfile "bitdecode.cfg"

set logfile "bitdecode.log"

# This software's version.  Anything set here will be clobbered by the
# makefile when starpacks are built.
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


# -------------------------- Root window ------------------------------

menu .menubar
menu .menubar.help -tearoff 0
.menubar add cascade -label Help -menu .menubar.help -underline 0
. configure -menu .menubar -width 200 -height 150
.menubar.help add command -label {About bitdecode...} \
    -underline 0 -command help.about

# Create window icon
set wmiconfile ./icons/calc_16x16.png
set wmicon [image create photo -format png -file $wmiconfile]
wm iconphoto . $wmicon

proc help.about {} {
    # What to execute when Help-->About is selected
    #
    # Arguments:
    #   None
    global log
    global revcode
    tk_messageBox -message "bitdecode\nVersion $revcode" \
	-title {About bitdecode}
}



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
source config.tcl

proc config.init {} {
    # Write an initial configuration file.  This will be
    # project-dependent, so it can't go in the config.tcl library.
    #
    # Arguments:
    #   None
    global log
    global revcode
    global configfile
    set fcon [ini::open $configfile w]
    # ---------------------- Private section --------------------------
    ini::set $fcon private version $revcode
    ini::comment $fcon private "" "Internal use -- do not edit."
    ini::commit $fcon
    ini::close $fcon
    # -------------------- bitlabels section --------------------------
    config.seccom bitlabels "Labels for individual bits"
}


	
if {[file exists $configfile] == 0} {
    # The config file does not exist
    ${log}::info "Creating new configuration file [file normalize $configfile]"
    set fcon [ini::open $configfile w]
    ini::close $fcon
    config.init
} else {
    ${log}::info "Reading configuration file [file normalize $configfile]"
    set fcon [ini::open $configfile r]
    ${log}::info "Configuration file version is\
                  [ini::value $fcon private version]"
    ini::close $fcon
}


# ------------------------ Hex code entry -----------------------------
# Source the hex.validate function
source number.tcl

ttk::labelframe .entry_frme -text "Hex code"\
    -labelanchor n\
    -borderwidth 1\
    -relief sunken
ttk::label .entry_frme.0x_labl -text "0x"\
    -font FixedFont
# The checkbuttons will be set when the hex code entry is validated.
ttk::entry .entry_frme.hex_enty\
    -textvariable hexnum\
    -validate key\
    -validatecommand {hex.validate %P 16}\
    -width 4 \
    -font FixedFont

proc hexcalc {} {
    # Calcuate hex input based on check button states
    #
    # Arguments:
    #   None
    global log
    global butvallist
    global hexnum
    set sum 0
    set base 1
    foreach cbval $butvallist {
	global $cbval
	incr sum [expr $$cbval * $base]
	set base [expr $base << 1]
    }
    set hexnum [format %0x $sum]
}



# ----------------------- Check buttons for bits ----------------------

# Checkbutton widget names will have the form:
# bytex_bity_cbut
# ...where x is 1 or 2 and y is 0, 1, 2, ..., 7

# Checkbutton associated variables will be in a list with indexes
# 0-15.
set butvallist []; # List of checkbutton variables
frame .bitarray_frme; # The master frame for both byte frames

# The first byte bits will be in a frame
ttk::labelframe .byte1_frme -text "Byte 1"\
    -labelanchor n\
    -borderwidth 1\
    -relief sunken
for {set bitnum 0} {$bitnum<8} {incr bitnum} {
    set bitlabel [config.getvar bitlabels byte1bit$bitnum]
    if {[string length $bitlabel] == 0} {
	# The bitlabel wasn't found in the config file
	set bitlabel "Byte 1, bit $bitnum"
	config.setvar bitlabels byte1bit$bitnum $bitlabel
    }
    ttk::checkbutton .byte1_bit${bitnum}_cbut \
	-variable byte1bit${bitnum} \
	-text $bitlabel \
	-command hexcalc
    lappend butvallist byte1bit${bitnum}
}

# The second byte bits will also be in a frame
ttk::labelframe .byte2_frme -text "Byte 2"\
    -labelanchor n\
    -borderwidth 1\
    -relief sunken
for {set bitnum 0} {$bitnum<8} {incr bitnum} {
    set bitlabel [config.getvar bitlabels byte2bit$bitnum]
    if {[string length $bitlabel] == 0} {
	# The bitlabel wasn't found in the config file
	set bitlabel "Byte 2, bit $bitnum"
	config.setvar bitlabels byte2bit$bitnum $bitlabel
    }
    ttk::checkbutton .byte2_bit${bitnum}_cbut \
	-variable byte2bit${bitnum} \
	-text $bitlabel \
	-command hexcalc
    lappend butvallist byte2bit${bitnum}
}



proc bitcalc {hexnum} {
    # Set checkbuttons according to hex entry
    global log
    global butvallist
    foreach cbval $butvallist {
	# Loop through each checkbutton variable
	global $cbval; # Associate with the checkbutton variable
	set bitval [expr $hexnum % 2]
	set hexnum [expr $hexnum / 2]
	set $cbval $bitval
    }	
}

#------------------------- Pack widgets -------------------------------
# Remember that order matters when packing


# The main window log box
pack .console_frme -side bottom\
    -padx 10 \
    -pady 10
pack .console_scrl -fill y -side right -in .console_frme
pack .console_text -fill x -side bottom\
    -in .console_frme

# The bit array master frame
pack .bitarray_frme -expand 1\
    -side bottom\
    -padx 5\
    -pady 5

# The byte1 frame
pack .byte1_frme -side left\
    -padx 5\
    -pady 5\
    -in .bitarray_frme
for {set bitnum 0} {$bitnum<8} {incr bitnum} {
    pack .byte1_bit${bitnum}_cbut -in .byte1_frme \
	-anchor w \
	-padx 5 \
	-pady 5
}

# The byte2 frame
pack .byte2_frme -side right\
    -padx 5\
    -pady 5\
    -in .bitarray_frme
for {set bitnum 0} {$bitnum<8} {incr bitnum} {
    pack .byte2_bit${bitnum}_cbut -in .byte2_frme \
	-anchor w \
	-padx 5 \
	-pady 5
}

# The hex entry frame
pack .entry_frme -side top\
    -padx 5 \
    -pady 5
pack .entry_frme.hex_enty -side right \
    -padx {0 5} \
    -pady 5
pack .entry_frme.0x_labl -side left \
    -padx {5 0}








#--------------------------- Initialize -------------------------------

# Initialize all bits to zero
foreach cbval $butvallist {
    set $cbval 0
}




