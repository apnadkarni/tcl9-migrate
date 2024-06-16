# Utility for Tcl 8 to Tcl 9 migration.
# See README.md for usage.
#
# (c) 2024 Ashok P. Nadkarni.
# See LICENSE for license terms.

namespace eval tcl9migrate {
    variable packageName tcl9migrate
    variable scriptDirectory [file dirname [info script]]
    variable packageVersion 0.1
    variable outChannel stdout

    proc warn {message {prefix {Migration}}} {
        variable outChannel
        puts $outChannel "$prefix Line ?: W $message"
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
        set fd [_tcl9orig_open $path rb]
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
}

namespace eval tcl9migrate::runtime {
    namespace path [list [namespace parent] ::tcl::unsupported]

    variable commandWrappers [list file open source]
    variable haveIcu 0
    variable enabled 0

    proc CommandExists {cmd} {
        if {[info commands $cmd] eq ""} {
            return 0
        } else {
            return 1
        }
    }
    proc WrapTclCommand {cmd} {
        set orig ::_tcl9orig_$cmd
        if {![CommandExists $orig]} {
            rename ::$cmd $orig
            interp alias {} ::$cmd {} [namespace current]::[string totitle $cmd]
        }
    }
    proc UnwrapTclCommand {cmd} {
        set orig ::_tcl9orig_$cmd
        if {[CommandExists $orig]} {
            rename ::$cmd ""
            rename $orig ::$cmd
        }
    }
    proc enable {} {
        uplevel #0 package require Tcl 9-

        set [namespace parent]::outChannel stderr

        variable haveIcu
        if {!$haveIcu} {
            if {[catch {::source [::file join [info library] icu.tcl]} message]} {
                warn "ICU libraries not available ($message). Encoding detection disabled."
                set haveIcu 0
            } else {
                set haveIcu 1
            }
        }
        variable commandWrappers
        foreach cmd $commandWrappers {
            WrapTclCommand $cmd
        }
        variable enabled
        set enabled 1
    }
    proc disable {} {
        variable commandWrappers
        foreach cmd $commandWrappers {
            UnwrapTclCommand $cmd
        }
        variable enabled
        set enabled 0
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

    # Checks if path begins with a tilde and expands it after logging a warning
    proc tildeexpand {path {cmd {}}} {
        if {[string index $path 0] eq "~" && ![::_tcl9orig_file exists $path]} {
            if {$cmd ne ""} {
                append cmd " command "
            }
            warn [string cat "Tcl 9 ${cmd}does not do tilde expansion on paths." \
                      " Change code to explicitly call \"file tildeexpand\"." \
                      " Expanding \"$path\". \[TILDE\]" \
                      [formatFrameInfo [info frame -2]]]
            set path [::_tcl9orig_file tildeexpand $path]
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
        tailcall ::_tcl9orig_file $cmd {*}$args
    }

    # Opens a channel with an appropriate encoding if it cannot be read with
    # configured encoding. Also prints warning if path begins with a ~ and
    # tilde expands it on caller's behalf, again emitting a warning.
    proc Open {path args} {
        if {[catch {
            set path [tildeexpand $path]

            # Avoid /dev/random etc.
            if {[::_tcl9orig_file isfile $path] && [::_tcl9orig_file size $path] > 0} {
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
        set fd [::_tcl9orig_open $path {*}$args]

        catch {
            if {[info exists encoding]} {
                if {[fconfigure $fd -encoding] ne "binary"} {
                    if {$encoding ne [encoding system]} {
                        warn [string cat "File \"$path\" is not in the system encoding." \
                                  " Configuring channel for encoding $encoding." \
                                  " This warning may be ignored if the code subsequently sets the encoding. \[ENCODING\]"]
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
                    warn "Encoding is not UTF-8. Sourcing with encoding $tclName. \[ENCODING\]" $path
                    set args [linsert $args 0 -encoding $tclName]
                }
            } message]} {
                warn "Error detecting encoding for $path: $message"
            }
        }
        tailcall ::_tcl9orig_source {*}$args
    }

}

proc ::tcl9migrate::help {} {
    puts [string cat \
              "Usage:\n" \
              "    [info nameofexecutable] migrate.tcl help\n" \
              "    [info nameofexecutable] migrate.tcl install ?dir?\n" \
              "    [info nameofexecutable] migrate.tcl check ?options? ?--? ?globpath ...?\n" \
              "Options:\n" \
              "    --encodingsonly, -e - Only check file encodings\n" \
              "    --migrationonly, -m - Only log messages related to migration\n" \
              "See README.md for details."
             ]
}

proc ::tcl9migrate::install {args} {
    variable packageName
    variable scriptDirectory

    if {[llength $args] == 0} {
        set args $::auto_path
    }
    # Reverse order because Tcl puts version-specific before
    # version independent
    foreach path [lreverse $args] {
        set path [file normalize $path]
        if {[lindex [file system $path] 0] eq "native"} {
            puts stdout "Installing in $path"
            set target [file join $path $packageName]
            file mkdir [file join $target nagelfar]
            file copy -force -- [info script] $target
            file copy -force -- [file join $scriptDirectory pkgIndex.tcl] $target
            file copy -force -- README.md $target
            file copy -force -- LICENSE $target
            foreach f {nagelfar.tcl syntaxdb90.tcl tcl9.tcl COPYING} {
                file copy -force -- [file join $scriptDirectory nagelfar $f] [file join $target nagelfar $f]
            }
            return
        }
    }
    puts stderr "Install failure: Could not find a native directory amongst [join $paths {, }]"
    exit 1
}

# Filter and print messages
proc ::tcl9migrate::printMessages {messages migrationOnly} {
    array set namespaces {}
    # Filter and collect meta information
    set messages [lmap message $messages {
        if {[regexp {N\s+MIGRATE:\s*AddNamespace\s+(.*)$} $message -> newNamespaces]} {
            foreach ns $newNamespaces {
                set namespaces($ns) $ns
            }
            continue
        }
        # Ignore messages other than migration-related. AFTER above check!
        if {$migrationOnly && ![regexp {\[[A-Z]+\]} $message]} {
            continue
        }
        # Ignore Nagelfar general message
        if {[string match "Checking file*" $message]} {
            continue
        }
        set message
    }]

    foreach message $messages {
        # Depending on order of file arguments, false positives are generated
        # if namespace is defined in a later file than the reference. Do not
        # print these (needs namespaces thus cannot be in filter loop above)
        if {[regexp {\s+(\S+).\s+\[RELATIVENSVAR\]} $message -> ns] &&
            [info exists namespaces($ns)]
        } {
            # False positive. In fact a valid namespace
            continue
        }

        puts $message
    }

    puts [array names namespaces]
}

# Checks a single file given by path
proc ::tcl9migrate::check1 {path migrationOnly args} {
    variable scriptDirectory
    set nagelfarDir [file join $scriptDirectory nagelfar]
    set nagelfarMessages [split \
                              [exec [info nameofexecutable] \
                                   [file join $nagelfarDir nagelfar.tcl] \
                                   -s syntaxdb90.tcl \
                                   -pluginpath $nagelfarDir -plugin tcl9.tcl \
                                   -H \
                                   {*}$args $path] \
                              \n]
    printMessages $nagelfarMessages $migrationOnly
}

# Checks multiple glob patterns. These should be supplied as part of
# args along with other options
proc ::tcl9migrate::checkGlobs {migrationOnly args} {
    variable scriptDirectory
    set nagelfarDir [file join $scriptDirectory nagelfar]
    set nagelfarMessages [split \
                              [exec [info nameofexecutable] \
                                   [file join $nagelfarDir nagelfar.tcl] \
                                   -s syntaxdb90.tcl \
                                   -pluginpath $nagelfarDir -plugin tcl9.tcl \
                                   {*}$args] \
                              \n]
    printMessages $nagelfarMessages $migrationOnly
}


proc ::tcl9migrate::check {args} {
    variable scriptDirectory
    set encodingsOnly 0
    set migrationOnly 0

    set nargs [llength $args]
    for {set i 0} {$i < $nargs} {incr i} {
        set arg [lindex $args $i]
        switch -glob $arg {
            --              { incr i; break }
            -migrationonly  -
            --migrationonly { set migrationOnly 1 }
            -encodingsonly  -
            --encodingsonly { set encodingsOnly 1 }
            -*              { help; exit 1 }
            default         { break }
        }
    }
    if {$migrationOnly && $encodingsOnly} {
        puts stderr "At most one of --encodingsonly and --migrationonly may be specified."
    }

    set globopts {}
    set paths {}
    foreach pat [lrange $args $i end] {
        lappend globopts -glob $pat
        lappend paths {*}[glob -nocomplain -- $pat]
    }

    # Encoding checks are only available on Tcl 9.
    if {[catch {
        ::tcl9migrate::runtime::enable
        set checkEncoding 1
    } message]} {
        warn "Skipping file encoding checks: $message"
        set checkEncoding 0
    }

    array set fileEncodings {}
    array set foundEncodings {}

    if {$checkEncoding} {
        set encodingErrors 0
        foreach path $paths {
            set encoding [detectFileEncoding $path]
            if {$encoding ne "" && $encoding ne "utf-8"} {
                set fileEncodings($path) $encoding
                lappend foundEncodings($encoding) $path
                warn "Encoding is $encoding, not UTF8. \[ENCODING\]" $path
                incr encodingErrors
            }
        }
        if {$encodingErrors} {
            warn "$encodingErrors non-UTF8 encoded files found. Please fix and retest. \[ENCODING\]"
        }
    }

    set checkOpts {}

    # Generate header to collect proc definitions from all files
    # Skip if doing migration only since other errors will be skipped anyway.
    if {!$migrationOnly && [catch {
        close [file tempfile headerFile]
        exec -ignorestderr -- [info nameofexecutable] \
            [file join $scriptDirectory nagelfar nagelfar.tcl] \
            -s syntaxdb90.tcl \
            -header $headerFile \
            {*}$globopts \
            2>@1
        lappend checkOpts -s $headerFile
    } message]} {
        warn "Could not generate proc syntax header: [join [lrange [split $::errorInfo \n] 0 1] { }]"
        warn "Ignore undefined proc warnings."
        catch {file delete $headerFile}
        unset -nocomplain headerFile
    }

    # Ideally we want to check all files in one shot. However, this does
    # not work if multiple encodings in use. In that case we need to
    # check file by file though that generates more false positives.
    if {[array size foundEncodings] < 2} {
        set opts $checkOpts
        if {[array size foundEncodings] == 1} {
            lappend opts -encoding [lindex [array names foundEncodings] 0]
        }
        if {[catch {
            checkGlobs $migrationOnly {*}$globopts {*}$opts
        } message]} {
            warn "Error: $message"
        }
    } else {
        warn "Multiple encodings present. Checking single file at a time; may generate more Nagelfar false positives."
        foreach path $paths {
            if {[catch {
                set opts $checkOpts
                if {[info exists fileEncodings($path)]} {
                    lappend opts -encoding $fileEncodings($path)
                }
                if {!$encodingsOnly} {
                    check1 $path $migrationOnly {*}$opts
                }
            } message]} {
                warn "Could not check $path: $message"
            }
        }
    }

    if {[info exists headerFile]} {
        #puts [readFile $headerFile]
        catch {file delete $headerFile}
    }
    puts "\nSee README.md for \[ENCODING\], \[NSVAR\], \[OCTAL\] etc. references."
}

proc ::tcl9migrate::main {args} {
    set args [lassign $args cmd]
    switch $cmd {
        install -
        check {
            $cmd {*}$args
        }
        help -
        default {
            help
            exit 1
        }
    }
}

if {[info exists ::argv0] &&
    [file dirname [file normalize [file join [info script] ...]]] eq [file dirname [file normalize [file join $::argv0 ...]]]
} {
    ::tcl9migrate::main {*}$argv
} else {
    package provide $::tcl9migrate::packageName $::tcl9migrate::packageVersion
}
