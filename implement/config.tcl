

proc config.getvar {section key} {
    # Return the value corresponding to the section and key arguments.
    #
    # Will return an empty string if the value doesn't exist.
    # 
    # Arguments:
    #  section -- Configuration file section
    #  key -- Configuration key in the specified section
    global log
    global configfile
    set fcon [ini::open $configfile r]
    if {[ini::exists $fcon $section $key]} {
	set retvar [ini::value $fcon $section $key]
	ini::close $fcon
	return $retvar
    } else {
	ini::close $fcon
	return ""
    }
}

proc config.setvar {section key value} {
    # Set the key value in the specified section of the config file
    #
    # Arguments:
    #  section -- Configuration file section
    #  key -- Configuration key in the specified section
    #  value -- Configuration value for the specified key
    global log
    global configfile
    set fcon [ini::open $configfile r+]
    ini::set $fcon $section $key $value
    ini::commit $fcon
    ini::close $fcon
}

proc config.seccom {section comment} {
    # Add a section comment to the configuration file.  The section
    # will be created if it doesn't yet exist.
    #
    # Arguments:
    #  section -- Configuration file section
    #  comment -- Comment string
    global log
    global configfile
    set fcon [ini::open $configfile r+]
    if {[ini::exists $fcon $section] != 1} {
	# The section does not exist, so create it
	${log}::debug "Creating dummy key in $section section"
	ini::set $fcon $section junk junky
	set mustclean 1
    } else {
	set mustclean 0
    }
    ini::comment $fcon $section "" $comment
    if {$mustclean} {
	${log}::debug "Deleting dummy key"
	ini::delete $fcon $section junk
    }
    ini::commit $fcon
    ini::close $fcon
}
