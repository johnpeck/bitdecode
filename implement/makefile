# makefile for bitdecode

# The name of the program or executable -- no extensions
MAINFILE = bitdecode

# Other supporting files (with extensions)
SRC = loggerconf.tcl

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
                 $(MAINFILE).vfs/lib/app-$(MAINFILE)/pkgIndex.tcl
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


$(MAINFILE).vfs/lib: $(MAINFILE).vfs
	mkdir $@
	cp -R $(MODULES) $@
	chmod -R a+rx *

$(MAINFILE).vfs/lib/app-$(MAINFILE): $(MAINFILE).vfs \
                                     $(MAINFILE).vfs/lib
	mkdir $@
	cp $(SRC) $@


# Now we need to replace every instance of 'source something.tcl' with
# source [file join $starkit::topdir lib/app-bitdecode/something.tcl]
# so that the starkit can find the tcl file in the vfs.  In this sed command,
# we match <anything>tcl and substitute the match (via the &) into the
# replacement string.  This just replaces all tcl filenames with their
# starkit-located replacements.
SOURCESTR := [file join $$starkit::topdir lib/app-$(MAINFILE)/&]
$(MAINFILE).vfs/lib/app-$(MAINFILE)/$(MAINFILE).tcl: $(MAINFILE).vfs \
                                                     $(MAINFILE).vfs/lib
	sed 's,[[:graph:]]*tcl,$(SOURCESTR),g' < $(MAINFILE).tcl > $@

$(MAINFILE).vfs/lib/app-$(MAINFILE)/pkgIndex.tcl: \
  $(MAINFILE).vfs/lib/app-$(MAINFILE) \
  $(MAINFILE).vfs/lib/app-$(MAINFILE)/$(MAINFILE).tcl
	echo 'pkg_mkIndex $< *.tcl' | tclsh

# To create the starpack, we have to copy the modules we need into the
# lib directory of the virtual filesystem.  This lib directory is
# added to the auto_path variable by the tclkit when the starkit is
# run.
.PHONY: starpack
starpack: $(MAINFILE).exe
$(MAINFILE).exe: $(MAINFILE).kit
	rm -rf temp
	mkdir temp
	cp $^ temp/$(MAINFILE).kit
	cd temp; $(TCLKITSH) $(SDXNP) unwrap $(MAINFILE).kit
	cp -R $(MODULES) temp/$(MAINFILE).vfs/lib
	cd temp/$(MAINFILE).vfs/lib; chmod -R a+rx *
	cd temp; $(TCLKITSH) $(SDXNP) wrap $(MAINFILE).kit -runtime $(TCLKITNP)
	mv temp/$(MAINFILE).kit $@

.PHONY: clean
clean:
	rm -rf $(MAINFILE).vfs
	rm -f $(MAINFILE).bat

