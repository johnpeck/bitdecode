proc hex.validate {hexnum numbits} {
    # Validate a string representing a hexadecimal number.
    #
    # Arguments:
    #   hexnum -- String representing the number.  Should not have a
    #             0x prefix.
    #   numbits -- Maximum number size in bits.
    global log
    ${log}::debug "Checking input 0x$hexnum"
    if {[string compare 0x$hexnum "0x"] == 0} {
	# The input string is empty -- this is ok
	${log}::debug "Entry is ok"
	bitcalc 0
	return 1
    }
    if {[string is integer 0x$hexnum] != 1} {
	# The input string is not a number -- not ok
	${log}::debug "Entry is not ok"
	return 0
    }
    if {[expr 0x$hexnum <= ((2**$numbits) -1)]} {
	${log}::debug "Entry is ok"
	bitcalc 0x$hexnum
	return 1
    } else {
	${log}::debug "Entry is not ok"
	return 0
    }	
}
