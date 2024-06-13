# Script to help migration from Tcl 8 to Tcl 9.
#
# The package has two modes of operation -
#  - a runtime analyzer. This only runs under Tcl 9 and logs
#    warnings to stderr for code that is invalid under Tcl 9.
#  - a static analyzer based on Nagelfar that runs under both
#    Tcl 8.6 and 9 logging warnings for potential incompatibilities.
#
# To use the runtime analyzer, include the following lines at the top
# of your application assuming the package is installed.
#    package require tcl9migrate
#    tcl8migrate::installRuntime
#
# To use the static analyser, from the shell command line run
#    tclsh migrate.tcl PATH PATH...
# where PATH is a glob pattern matching files to be analysed.

namespace eval tcl9migrate {

    # Prints a warning
    proc warn {message} {
        puts stderr "Tcl9 Migration Warning: $message"
    }

}

namespace eval tcl9migrate::static {

}

namespace eval tcl9migrate::runtime {
    namespace path [list [namespace parent] ::tcl::unsupported]

    variable commandWrappers [list file open source]
    variable haveIcu 0

    proc CommandExists {cmd} {
        if {[info commands $cmd] eq ""} {
            return 0
        } else {
            return 1
        }
    }
    proc WrapTclCommand {cmd} {
        set orig ::_tcl9migrate_$cmd
        if {![CommandExists $orig]} {
            rename ::$cmd $orig
            interp alias {} ::$cmd {} [namespace current]::[string totitle $cmd]
        }
    }
    proc UnwrapTclCommand {cmd} {
        set orig ::_tcl9migrate_$cmd
        if {[CommandExists $orig]} {
            rename ::$cmd ""
            rename $orig ::$cmd
        }
    }
    proc enable {} {
        uplevel #0 package require Tcl 9-

        variable haveIcu
        if {!$haveIcu} {
            if {[catch {::source [::file join [info library] icu.tcl]} message]} {
                warn "ICU not available ($message). Encoding detection disabled."
                set haveIcu 0
            } else {
                set haveIcu 1
            }
        }
        variable commandWrappers
        foreach cmd $commandWrappers {
            WrapTclCommand $cmd
        }
    }
    proc disable {} {
        variable commandWrappers
        foreach cmd $commandWrappers {
            UnwrapTclCommand $cmd
        }
    }

    # Return 1 / 0 depending on whether the data can
    # be decoded with a given encoding
    proc checkEncoding {data enc} {
        encoding convertfrom -profile strict -failindex x $enc $data
        return [expr {$x < 0}]
    }

    # Detect the encoding for a file. If sampleLength is the
    # empty string, entire file is read.
    # NOTE: sampleLength other than "" has the problem that
    # the encoding may be perfectly valid but the data at
    # end is a truncated encoding sequence.
    # TODO - may be do line at a time to get around this problem
    proc detectFileEncoding {path {expectedEncoding utf-8} {sampleLength {}}} {
        set fd [_tcl9migrate_open $path rb]
        try {
            set data [read $fd {*}$sampleLength]
        } finally {
            close $fd
        }
        if {[checkEncoding $data $expectedEncoding]} {
            return $expectedEncoding
        }

        # ICU sometimes returns ISO8859-1 for UTF-8 since all bytes are always
        # valid in 8859-1. So always check UTF-8 first
        if {$expectedEncoding ne "utf-8"} {
            if {[checkEncoding $data "utf-8"]} {
                return utf-8
            }
        }

        # On Windows, try the ANSI code page
        if {$::tcl_platform(platform) eq "windows"} {
            if {![catch {
                package require registry
                set winCodePage [registry get {HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage} ACP]
            }]} {
                set tclName cp[format %u $winCodePage]
                if {$tclName in [encoding names]} {
                    if {[checkEncoding $data $tclName]} {
                        return $tclName
                    }
                }
            }
        }

        # Get possible encodings in order of confidence
        set encodingCandidates [icu detect $data -all]
        # Pick the first that has a Tcl equivalent skipping utf-8
        # as already checked above.
        foreach icuName $encodingCandidates {
            set tclName [icu icuToTcl $icuName]
            if {$tclName ne "" &&
                $tclName ne $expectedEncoding &&
                $tclName ne "utf-8" &&
                [checkEncoding $data $tclName]} {
                return $tclName
            }
        }

        return ""
    }

    proc formatFrameInfo {frame} {
        set message ""
        switch -exact -- [dict get $frame type] {
            source {
                if {[dict exists $frame file]} {
                    lappend message "Source file [dict get $frame file]"
                }
                if {[dict exists $frame line]} {
                    lappend message "Line [dict get $frame line]"
                }
                if {[dict exists $frame proc]} {
                    lappend message "Proc [dict get $frame proc]"
                }
            }
            proc {
                if {[dict exists $frame proc]} {
                    lappend message "Proc [dict get $frame proc]"
                }
                if {[dict exists $frame line]} {
                    lappend message "Line [dict get $frame line]"
                }
            }
        }
        if {[dict exists $frame cmd]} {
            lappend message "Cmd [dict get $frame cmd]"
        }
        if {[llength $message]} {
            return " ([join $message {, }])"
        }
        return ""
    }

    # Checks if path begins with a tilde and expands it after
    # logging a warning
    proc tildeexpand {path {cmd {}}} {
        if {[string index $path 0] eq "~" && ![::_tcl9migrate_file exists $path]} {
            if {$cmd ne ""} {
                append cmd " command "
            }
            warn [string cat "Tcl 9 ${cmd}does not do tilde expansion on paths." \
                             " Change code to explicitly call \"file tildeexpand\"." \
                             " Expanding \"$path\"." \
                             [formatFrameInfo [info frame -2]]]
            set path [::_tcl9migrate_file tildeexpand $path]
        }
        return $path
    }

    # Checks if file command argument needs tilde expansion,
    # expanding it if so after a warning.
    proc File {cmd args} {
        switch $cmd {
            atime - attributes - dirname - executable - exists - extension -
            isdirectory - isfile - lstat - mtime - nativename - normalize -
            owned - pathtype - readable - readlink - rootname - size - split -
            separator - stat - system - tail - type - writable {
                # First argument if present is the name
                if {[llength $args]} {
                    # Replace first arg with expanded form
                    ledit args 0 0 [tildeexpand [lindex $args 0] "file $cmd"]
                }
            }
            copy -
            delete -
            link -
            mkdir -
            rename {
                # Some arguments may be options, all others paths. Only check
                # if beginning with tilde. Option will not begin with tilde
                set args [lmap arg $args {
                    tildeexpand $arg "file $cmd"
                }]
            }
            join {
                # Cannot tilde expand as semantics will not be same.
                # Just warn, throw away result
                foreach arg $args {
                    tildeexpand $arg "file $cmd"
                }
            }
            home -
            tempdir -
            tempfile -
            tildeexpand {
                # Naught to do
            }
        }
        tailcall ::_tcl9migrate_file $cmd {*}$args
    }

    # Opens a channel with an appropriate encoding if it cannot be read with
    # configured encoding. Also prints warning if path begins with a ~ and
    # tilde expands it on caller's behalf, again emitting a warning.
    proc Open {path args} {
        if {[catch {
            set path [tildeexpand $path]

            # Avoid /dev/random etc.
            if {[::_tcl9migrate_file isfile $path] && [::_tcl9migrate_file size $path] > 0} {
                # Files are opened in system encoding by default. Ensure file
                # readable with that encoding.
                set encoding [detectFileEncoding $path [encoding system]]
                if {$encoding eq ""} {
                    unset encoding
                }
            }
        } message]} {
           warn $message
        }

        # Actual open should not be in a catch!
        set fd [::_tcl9migrate_open $path {*}$args]

        catch {
            if {[info exists encoding]} {
                if {[fconfigure $fd -encoding] ne "binary"} {
                    if {$encoding ne [encoding system]} {
                        warn [string cat "File \"$path\" is not in the system encoding." \
                                  " Configuring channel for encoding $encoding." \
                                  " This warning may be ignored if the code subsequently sets the encoding."]
                    fconfigure $fd -encoding $encoding
                    }
                }
            }
        }
        return $fd
    }

    # Sources a file, attempting to guess an encoding if one is not
    # specified. Logs a message if encoding was not the default UTF-8
    proc Source {args} {
        if {[llength $args] == 1} {
            # No options specified. Try to determine encoding.
            # In case of errors, just invoke as is
            if {[catch {
                set path [lindex $args end]
                set tclName [detectFileEncoding $path]
                if {$tclName ne "" && $tclName ne "utf-8"} {
                    warn "Encoding of $path is not UTF-8. Sourcing with encoding $tclName."
                    set args [linsert $args 0 -encoding $tclName]
                }
            } message]} {
                warn "Error detecting encoding for $path: $message"
            }
        }
        tailcall ::_tcl9migrate_source {*}$args
    }

}

package provide tcl9migrate 0.1