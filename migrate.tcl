# Utility for Tcl 8 to Tcl 9 migration.
# See README.md for usage.
#
# (c) 2024 Ashok P. Nadkarni.
# See LICENSE for license terms.

namespace eval tcl9migrate {
    variable packageName tcl9migrate
    variable scriptDirectory [file dirname [info script]]
    variable packageVersion 1.0
    variable outChannel stdout

    proc printMessage {severity message {frame {}}} {
        set prefix Migration
        set line ?
        if {[dict exists $frame file]} {
            set prefix [dict get $frame file]
            if {[dict exists $frame line]} {
                set line [dict get $frame line]
            }
        }
        variable outChannel
        puts $outChannel "$prefix Line $line: $severity $message"
    }
    proc printWarning {message {frame {}}} {
        printMessage W $message $frame
    }
    proc warn args {
        tailcall printWarning {*}$args
    }
    proc printError  {message {frame {}}} {
        printMessage E $message $frame
    }

    # Return 1 / 0 depending on whether the data can
    # be decoded with a given encoding
    proc checkEncoding {data enc} {
        encoding convertfrom -profile strict -failindex x $enc $data
        if {$x < 0} {
            return 1
        }
        # In case of failures ignore errors near the end as it might
        # just be truncated data and not invalid encodings. However,
        # Make sure at least some minimum data has been checked.
        # Unfortunately cause of error is not available at the script
        # level.
        set len [string length $data]
        if {$len > 500 && ($x >= ($len-4))} {
            return 1
        }
        return 0
    }

    # Detect encoding for given data. Failures at the *end* of
    # data are ignored on the presumption the data sample is incomplete.
    # Returns empty string if detection fails.
    proc detectEncoding {data {expectedEncoding utf-8}} {
        if {[checkEncoding $data $expectedEncoding]} {
            return $expectedEncoding
        }

        # ICU sometimes returns ISO8859-1 for UTF-8 since all bytes are always
        # valid in 8859-1. So always check UTF-8 first. It is very unlikely
        # that non-UTF8 will match UTF-8
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
        set encodingCandidates [::tcl::unsupported::icu detect $data -all]
        # Pick the first that has a Tcl equivalent skipping utf-8
        # as already checked above.
        foreach icuName $encodingCandidates {
            set tclName [::tcl::unsupported::icu icuToTcl $icuName]
            if {$tclName ne "" &&
                $tclName ne $expectedEncoding &&
                $tclName ne "utf-8" &&
                [checkEncoding $data $tclName]} {
                return $tclName
            }
        }

        return ""

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
        return [detectEncoding $data $expectedEncoding]
    }
}

namespace eval tcl9migrate::runtime {
    namespace path [list [namespace parent] ::tcl::unsupported]

    variable commandWrappers {
        cd chan close exec file gets load open package puts read source
        tcl::tm::path tcl::tm::roots unload
    }
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
        # Force loading of tcl::tm
        catch {tcl::tm::path}
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
        if {![dict exists $frame type]} {
            return ""
        }
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
    proc tildeexpand {path cmd {frame {}}} {
        if {[string index $path 0] eq "~" && ![::_tcl9orig_file exists $path]} {
            if {$cmd ne ""} {
                set cmdText "Command \"$cmd\" in "
            }
            append cmdText "Tcl 9"
            set newPath [::_tcl9orig_file tildeexpand $path]
            warn [string cat "$cmdText does not do tilde expansion on paths." \
                      " Change code to explicitly call \"file tildeexpand\"." \
                      " Replacing \"$path\" at runtime with \"$newPath\". \[TILDEPATH\]" \
                      ] \
                $frame
            set path $newPath
        }
        return $path
    }

    proc checkChannelConfiguration {chan} {
        variable openChannels

        if {[info exists openChannels($chan)]} {
            set fileEncoding [fconfigure $chan -encoding]
            set guessedEncoding [detectEncoding [dict get $openChannels($chan) Data] $fileEncoding]
            if {$guessedEncoding ne "" && $guessedEncoding ne $fileEncoding} {
                set path [dict get $openChannels($chan) Path]
                warn [string cat "File \"$path\" is not in the configured encoding $fileEncoding." \
                          " Configuring channel for guessed encoding $guessedEncoding." \
                          " \[DATAENCODING\]"]
                fconfigure $chan -encoding $guessedEncoding
            }
            unset openChannels($chan); # No more checks. Only do on first read
        }
    }

    proc Cd {args} {
        if {[llength $args] == 1} {
            lset args end [tildeexpand [lindex $args 0] cd [info frame -1]]
        }
        tailcall ::_tcl9orig_cd {*}$args
    }

    proc Exec {args} {
        if {[llength $args] > 0} {
            lset args 0 [tildeexpand [lindex $args 0] exec [info frame -1]]
        }
        tailcall ::_tcl9orig_exec {*}$args
    }

    proc Load {args} {
        set nargs [llength $args]
        for {set i 0} {$i < $nargs} {incr i} {
            switch [lindex $args $i] {
                -global -
                -lazy {
                    continue
                }
                -- {
                    incr i
                    break
                }
                default {
                    break
                }
            }
        }
        if {$i < $nargs} {
            # $i is first argument after options which would be path of
            # the shared library.
            lset args $i [tildeexpand [lindex $args $i] load [info frame -1]]
            incr i
            if {$i < $nargs} {
                # The name of the Init function must be title case
                if {[string is lower [string index [lindex $args $i] 0]]} {
                    set newName [string totitle [lindex $args $i]]
                    warn "Load command initialization function name \"[lindex $args $i]\" must start with upper case letter in Tcl 9. Replacing at runtime with \"$newName\". \[LOADCASE\]" [info frame -1]
                    lset args $i $newName
                }
            }
        }
        tailcall ::_tcl9orig_load {*}$args
    }

    proc Unload {args} {
        set nargs [llength $args]
        for {set i 0} {$i < $nargs} {incr i} {
            switch [lindex $args $i] {
                -nocomplain -
                -keeplibrary {
                    continue
                }
                -- {
                    incr i
                    break
                }
                default {
                    break
                }
            }
        }
        if {$i < $nargs} {
            # $i is first argument after options which would be path of
            # the shared library.
            lset args $i [tildeexpand [lindex $args $i] unload [info frame -1]]
        }
        tailcall ::_tcl9orig_unload {*}$args
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
                    lset args  0 [tildeexpand [lindex $args 0] "file $cmd" [info frame -1]]
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
                    tildeexpand $arg "file $cmd" [info frame -1]
                }]
            }
            join {
                # Cannot tilde expand as semantics will not be same.
                # Just warn, throw away result
                foreach arg $args {
                    tildeexpand $arg "file $cmd" [info frame -1]
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

    proc Package {cmd args} {
        set vers [lassign $args pkg]
        switch $cmd {
            present -
            require {
                if {$pkg eq "-exact"} {
                    set vers [lassign $vers pkg]
                }
                if {$pkg in {Tcl Tk} && [llength $vers]} {
                    if {![package vsatisfies 9 {*}$vers]} {
                        warn "The command \"package $cmd $args\" will fail in Tcl 9. Replacing version requirement to be 9. \[TCLPKGVER\]" [info frame -1]
                        lset args end 9
                    }
                }
            }
            vsatisfies {
                # TODO - should this check and generate warning? Not clear
                # as it could be simply doing a polyfill or similar based
                # on versions.
            }
        }
        tailcall ::_tcl9orig_package $cmd {*}$args
    }

    proc Open {path args} {
        variable openChannels

        if {[catch {
            set path [tildeexpand $path open [info frame -1]]

            # Avoid /dev/random etc.
            if {[::_tcl9orig_file isfile $path] && [::_tcl9orig_file size $path] > 0} {
                # Save up to 100000 bytes to check encoding on first read.
                set fd [::_tcl9orig_open $path rb]
                try {
                    set fileSample [::_tcl9orig_read $fd 100000]
                } finally {
                    close $fd
                }
            }
        } message]} {
            warn $message
        }

        # Actual open should not be in a catch!
        set fd [::_tcl9orig_open $path {*}$args]
        if {[info exists fileSample]} {
            dict set openChannels($fd) Data $fileSample
            dict set openChannels($fd) Path $path
        }
        return $fd
    }

    proc Close {chan args} {
        variable openChannels
        unset -nocomplain openChannels($chan)
        tailcall ::_tcl9orig_close $chan {*}$args
    }

    proc Puts {args} {
        variable openChannels
        set nargs [llength $args]
        if {$args == 3} {
            set chan [lindex $args 1]
        } elseif {$args == 2} {
            if {[lindex $args 0] ne "-nonewline"} {
                set chan [lindex $args 0]
            }
        }
        if {[info exists chan]} {
            unset -nocomplain openChannels($chan)
        }
        tailcall ::_tcl9orig_puts {*}$args
    }

    proc Read {args} {
        variable openChannels
        if {[catch {
            set nargs [llength $args]
            if {$nargs == 1} {
                set chan [lindex $args 0]
            } elseif {$nargs == 2} {
                if {[lindex $args 0] == "-nonewline"} {
                    set chan [lindex $args 1]
                } else {
                    set chan [lindex $args 0]
                }
            }
            if {[info exists chan]} {
                checkChannelConfiguration $chan
            }
        } message]} {
            warn "Error: $message"
        }

        tailcall ::_tcl9orig_read {*}$args
    }

    proc Gets {args} {
        if {[catch {
            set nargs [llength $args]
            if {$nargs > 0} {
                checkChannelConfiguration [lindex $args 0]
            }
        } message]} {
            warn "Error: $message"
        }

        tailcall ::_tcl9orig_gets {*}$args
    }

    proc Chan {cmd args} {
        switch -exact -- $cmd {
            read {
                tailcall Read {*}$args
            }
            gets {
                tailcall Gets {*}$args
            }
            puts {
                tailcall Puts {*}$args
            }
            close {
                tailcall Close {*}$args
            }
            default {
                tailcall ::_tcl9orig_chan $cmd {*}$args
            }
        }
    }

    # Sources a file, attempting to guess an encoding if one is not
    # specified. Logs a message if encoding was not the default UTF-8
    proc Source {args} {
        if {[llength $args] > 0} {
            catch {
                set args [lreplace $args end end [tildeexpand [lindex $args end] source [info frame -1]]]
            }
        }
        if {[llength $args] == 1} {
            # No options specified. Try to determine encoding.
            # In case of errors, just invoke as is
            if {[catch {
                set path [lindex $args end]
                set tclName [detectFileEncoding $path]
                if {$tclName ne "" && $tclName ne "utf-8"} {
                    warn "Encoding of sourced file \"$path\" is not UTF-8. Sourcing with encoding $tclName. \[SOURCEENCODING\]" [info frame -1]
                    set args [linsert $args 0 -encoding $tclName]
                }
            } message]} {
                warn "Error detecting encoding for $path: $message" [info frame -1]
            }
        }
        tailcall ::_tcl9orig_source {*}$args
    }

    namespace eval Tcl::tm {
        namespace path ::tcl9migrate::runtime
        proc path {cmd args} {
            switch $cmd {
                add -
                remove {
                    set args [lmap arg $args {
                        tildeexpand $arg "tcl::tm::path $cmd" [info frame -1]
                    }]
                }
            }
            tailcall ::_tcl9orig_tcl::tm::path $cmd {*}$args
        }
        proc roots {paths} {
            set paths [lmap arg $paths {
                tildeexpand $arg "tcl::tm::roots" [info frame -1]
            }]
            tailcall ::_tcl9orig_tcl::tm::roots $paths
        }
    }
}

proc ::tcl9migrate::help {args} {
    puts [string cat \
              "Usage:\n" \
              "    [info nameofexecutable] migrate.tcl help ?-detail?\n" \
              "    [info nameofexecutable] migrate.tcl install ?dir?\n" \
              "    [info nameofexecutable] migrate.tcl check ?options? ?--? ?globpath ...?\n" \
              "Options:\n" \
              "    --all, -a - Log all messages from Nagelfar, not just related to migration\n" \
              "    --encodingsonly, -e - Only check file encodings\n" \
              "    --severity LEVEL, -s LEVEL - Skip message below severity level LEVEL (note, warning, error)\n" \
              "    --sizelimit N, -l N - Skip files bigger than N bytes. If N is 0, no limit. Default 100000\n" \
             ]
    if {[llength $args] == 1 && [lindex $args 0] eq "-detail"} {
        variable scriptDirectory
        puts ""
        if {[file exists [file join $scriptDirectory README.md]]} {
            set fd [open [file join $scriptDirectory README.md]]
            puts [read $fd]
            close $fd
        } else {
            puts "See https://github.com/apnadkarni/tcl9-migrate/blob/main/README.md."
        }
    }
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
            file mkdir [file join $target nagelfar packagedb]
            file copy -force -- [info script] $target
            file copy -force -- [file join $scriptDirectory pkgIndex.tcl] $target
            file copy -force -- README.md $target
            file copy -force -- LICENSE $target
            foreach f {nagelfar.tcl syntaxdb90.tcl migratehelper.tcl packagedb/snitdb.tcl COPYING} {
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
        if {[regexp {\s+(\S+).\s+\[RELATIVENS\]} $message -> ns] &&
            [info exists namespaces($ns)]
        } {
            # False positive. In fact a valid namespace
            continue
        }

        puts $message
    }
}

# Checks a single file given by path
proc ::tcl9migrate::check1 {path migrationOnly args} {
    variable scriptDirectory
    variable fileSizeLimit
    variable severityLevel

    set nagelfarDir [file join $scriptDirectory nagelfar]
    set nagelfarMessages [split \
                              [exec [info nameofexecutable] \
                                   [file join $nagelfarDir nagelfar.tcl] \
                                   -s syntaxdb90.tcl \
                                   -pluginpath $nagelfarDir \
                                   -plugin migratehelper.tcl \
                                   -sizelimit $fileSizeLimit \
                                   -severity $severityLevel \
                                   -H \
                                   {*}$args $path] \
                              \n]
    printMessages $nagelfarMessages $migrationOnly
}

# Checks multiple glob patterns. These should be supplied as part of
# args along with other options
proc ::tcl9migrate::checkGlobs {migrationOnly args} {
    variable scriptDirectory
    variable fileSizeLimit
    variable severityLevel

    set nagelfarDir [file join $scriptDirectory nagelfar]
    set nagelfarMessages [split \
                              [exec [info nameofexecutable] \
                                   [file join $nagelfarDir nagelfar.tcl] \
                                   -s syntaxdb90.tcl \
                                   -pluginpath $nagelfarDir \
                                   -plugin migratehelper.tcl \
                                   -sizelimit $fileSizeLimit \
                                   -severity $severityLevel \
                                   {*}$args] \
                              \n]

    printMessages $nagelfarMessages $migrationOnly
}


proc ::tcl9migrate::check {args} {
    variable scriptDirectory
    variable fileSizeLimit
    variable severityLevel
    set encodingsOnly 0
    set allMessages 0
    set fileSizeLimit 100000
    set severityLevel N

    set nargs [llength $args]
    for {set i 0} {$i < $nargs} {incr i} {
        set arg [lindex $args $i]
        switch -glob $arg {
            --              { incr i; break }
            -a    -
            -all  -
            --all { set allMessages 1 }

            -e              -
            -encodingsonly  -
            --encodingsonly { set encodingsOnly 1 }

            -l         -
            -sizelimit -
            --sizelimit     {
                if {[incr i] >= $nargs} {
                    puts stderr "No value supplied for option $arg."
                    exit 1
                }
                set fileSizeLimit [lindex $args $i]
                if {[incr fileSizeLimit 0] < 0} {
                    puts stderr "Size option value for option $arg must be positive."
                }
            }

            -s        -
            -severity -
            --severity {
                if {[incr i] >= $nargs} {
                    puts stderr "No value supplied for option $arg."
                    exit 1
                }
                set severityLevel [lindex $args $i]
                switch [string tolower $severityLevel] {
                    w -
                    warn -
                    warning { set severityLevel W}
                    n -
                    note { set severityLevel N}
                    e -
                    error { set severityLevel E}
                    default {
                        puts stderr "Invalid value $severityLevel for option $arg. Must be one of note, warning or error."
                        exit 1
                    }
                }
            }
            -*              { help; exit 1 }
            default         { break }
        }
    }

    if {$allMessages && $encodingsOnly} {
        puts stderr "At most one of --encodingsonly and --all may be specified."
        exit 1
    }

    set globopts {}
    set paths {}
    foreach pat [lrange $args $i end] {
        set pat [file join $pat]; # \ -> / as nagelfar insists
        lappend globopts -glob $pat
        lappend paths {*}[glob -types f -nocomplain -- $pat]
    }

    # Encoding checks are only available on Tcl 9.
    if {[catch {
        ::tcl9migrate::runtime::enable
        variable outChannel
        set outChannel stdout
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
                warn "Encoding of file is $encoding, not UTF-8. \[ENCODING\]" [list file $path]
                incr encodingErrors
            }
        }
        if {$encodingErrors} {
            warn "$encodingErrors non-UTF8 encoded files found. Please fix and retest. \[ENCODING\]"
            if {[array size foundEncodings] > 1} {
                # If there is more than one encodings, then each file has to
                # be tested separately resulting in too many false positives.
                #exit 1
            }
        }
    }

    if {$encodingsOnly} {
        return
    }

    set checkOpts {}

    # Generate header to collect proc definitions from all files
    # Skip if doing migration only since other errors will be skipped anyway.
    if {$allMessages && [catch {
        close [file tempfile headerFile]
        exec -ignorestderr -- [info nameofexecutable] \
            [file join $scriptDirectory nagelfar nagelfar.tcl] \
            -s syntaxdb90.tcl \
            -header $headerFile \
            -sizelimit $fileSizeLimit \
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
    set migrationOnly [expr {!$allMessages}]
    if {1 || [array size foundEncodings] < 2} {
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
                check1 $path $migrationOnly {*}$opts
            } message]} {
                warn "Could not check $path: $message"
            }
        }
    }

    if {[info exists headerFile]} {
        #puts [readFile $headerFile]
        catch {file delete $headerFile}
    }
    puts "\nSee README.md or run \"tclsh migrate.tcl help -detail\" for guidance on error messages."
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
            help {*}$args
            exit 1
        }
    }
}

if {[info exists ::argv0] &&
    [file dirname [file normalize [file join [info script] ...]]] eq [file dirname [file normalize [file join $::argv0 ...]]]
} {
    if {[catch {
        ::tcl9migrate::main {*}$argv
    } emsg]} {
        puts $::errorInfo
    }
} else {
    package provide $::tcl9migrate::packageName $::tcl9migrate::packageVersion
}
