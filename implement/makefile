# makefile for bitdecode

# The name of the program or executable -- no extensions
MAINFILE = bitdecode

# Other supporting files (with extensions)
SRC = loggerconf.tcl

ICONSDIR = icons

# Files to be copied into the icons directory (from the icons directory)
ICONS = calc_16x16.png



# The runtime engine to package in the starpack.  This, of course, has
# to run on the machine you're targeting.
TCLKIT = "/cygdrive/c/Tcl/bin/base-tk8.6-thread-win32-ix86.exe"

# The tcl shell needed to execute the Starkit Developer tools.  I
# install the Tcl tools directly from ActiveState
TCLKITSH = "/cygdrive/c/Tcl/bin/tclsh.exe"

# Download Starkit Developer Extension from whereever
SDX = "/cygdrive/c/tclkit/sdx.kit"

# List of modules to copy over into the starkit.  Download tcllib from
# core.tcl.tk.
MODULES = "/cygdrive/c/Tcl/tcllib-trunk/tcllib-trunk/modules/log" \
          "/cygdrive/c/Tcl/tcllib-trunk/tcllib-trunk/modules/inifile" \
          "/cygdrive/c/Tcl/tcllib-trunk/tcllib-trunk/modules/calendar"

#------------------------- Done with configuration ---------------------

# Make a non-posix version of the sdx path for windows.  If you're
# using windows executables, you can't use POSIX paths for arguments.
SDXNP = "$(shell cygpath -aw $(SDX))"
TCLKITNP = "$(shell cygpath -aw $(TCLKIT))"

help:
	@echo 'Makefile for $(MAINFILE)                              '
	@echo '                                                      '
	@echo 'Usage:                                                '
	@echo '   make starkit                                       '
	@echo '       Make starkit                                   '
	@echo '   make starpack                                      '
	@echo '       Make starpack                                  '

# Make the starkit.  Do not use qwrap here, since it only permits one
# tcl file.
.PHONY: starkit
starkit: $(MAINFILE).kit
$(MAINFILE).kit: $(MAINFILE).tcl \
                 $(SRC) \
                 $(MAINFILE).vfs \
                 $(MAINFILE).vfs/main.tcl \
                 $(MAINFILE).vfs/lib \
                 $(MAINFILE).vfs/lib/app-$(MAINFILE) \
                 $(MAINFILE).vfs/lib/app-$(MAINFILE)/icons \
                 $(MAINFILE).vfs/lib/app-$(MAINFILE)/$(MAINFILE).tcl
	@echo 'Making starkit'
	$(TCLKITSH) $(SDXNP) wrap $(MAINFILE)
	mv $(MAINFILE) $@

$(MAINFILE).vfs:
	mkdir $@

# Now source all the tcl code into the top of the vfs tree.  Note that
# you also have to replace each 'source' line from your tcl files with
# a command to source a file relative to the top of the vfs.
# Otherwise, tcl has no idea where these files are.
$(MAINFILE).vfs/main.tcl: $(MAINFILE).vfs
	echo 'package require starkit' > $@
	echo 'if {[starkit::startup] ne "sourced"} {' >> $@
	echo '    source [file join $$starkit::topdir'\
             'lib/app-$(MAINFILE)/$(MAINFILE).tcl]' >> $@
	echo '}' >> $@

# Creating the lib directory also copies all the needed modules.
$(MAINFILE).vfs/lib: $(MAINFILE).vfs
	mkdir $@
	cp -R $(MODULES) $@
	chmod -R a+rx *


# Copy supporting files (like sourced tcl files) into the
# /lib/app-$(MAINFILE) directory along with $(MAINFILE).tcl
$(MAINFILE).vfs/lib/app-$(MAINFILE): $(MAINFILE).vfs \
                                     $(MAINFILE).vfs/lib
	mkdir $@
	cp $(SRC) $@

# Create the icons directory to mirror that used in development.
$(MAINFILE).vfs/lib/app-$(MAINFILE)/icons:
	mkdir $@
	cp $(ICONSDIR)/$(ICONS) $@



# Fix file path strings for starkits:
# Was:
#   source something.tcl
# Becomes:
#   source [file join $starkit::topdir lib/app-bitdecode/something.tcl]
#
# Was:
#   set wmiconfile ./icons/calc_16x16.png
# Becomes:
#   set wmiconfile [file join $starkit::topdir lib/app-bitdecode/icons/calc_16x16.png]
SOURCESTR := [file join $$starkit::topdir lib/app-$(MAINFILE)/&]
ICONSTR := [file join $$starkit::topdir lib/app-$(MAINFILE)/icons/&]
$(MAINFILE).vfs/lib/app-$(MAINFILE)/$(MAINFILE).tcl: $(MAINFILE).vfs \
                                                     $(MAINFILE).vfs/lib
	sed 's,[[:graph:]]*tcl,$(SOURCESTR),g' < $(MAINFILE).tcl |\
	  sed 's,[^/]*\.png,$(ICONSTR),g' |\
          sed 's,\./icons/,,g' > $@


# The starpack is the same as a starkit with a built-in tclkit.  The
# wrap command is the only difference.
.PHONY: starpack
starpack: $(MAINFILE).exe
$(MAINFILE).exe: starkit
	$(TCLKITSH) $(SDXNP) wrap $(MAINFILE) -runtime $(TCLKITNP)
	mv $(MAINFILE) $@


.PHONY: clean
clean:
	rm -rf $(MAINFILE).vfs
	rm -f $(MAINFILE).bat

