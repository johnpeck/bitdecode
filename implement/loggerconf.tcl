# Set up a visual console for logging
ttk::labelframe .console_frme -text "Execution log"\
    -labelanchor n\
    -borderwidth 1\
    -relief groove
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
    # upvar #0 argv0 thisScript; # Associate thisScript with the argv0
    # set logfile "[file rootname $thisScript].log"
    global logfile
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
    # Scroll to the end
    .console_text see end
}

# Define the callback function for the logger for each log level
foreach lvl [logger::levels] {
    interp alias {} log_manager_$lvl {} log_manager $lvl
    ${log}::logproc $lvl log_manager_$lvl
}
