# makefile for bitdecode

MAINFILE = bitdecode

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

.PHONY: starkit
starkit: $(MAINFILE).kit
$(MAINFILE).kit: $(MAINFILE).tcl
	$(TCLKITSH) $(SDXNP) qwrap $<

.PHONY: starpack
starpack: $(MAINFILE).exe
$(MAINFILE).exe: $(MAINFILE).kit
	rm -rf temp
	mkdir temp
	cp $^ temp/$(MAINFILE).kit
	(cd temp; $(TCLKITSH) $(SDXNP) unwrap $(MAINFILE).kit)
	cp -R $(MODULES) temp/$(MAINFILE).vfs/lib
	(cd temp/$(MAINFILE).vfs/lib; chmod -R a+rx *) 
	(cd temp; $(TCLKITSH) $(SDXNP) wrap $(MAINFILE).kit -runtime $(TCLKITNP))
	mv temp/$(MAINFILE).kit $@
