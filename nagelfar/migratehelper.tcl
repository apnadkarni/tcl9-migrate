##Nagelfar Plugin : routines for Tcl 9 migrations

# (c) Ashok P. Nadkarni
# Unlike other nagelfar files, this file covered by a BSD license.
# See LICENSE in top-level directory.

proc statementWords {words info} {

    # Checks common to multiple commands
    lappend res {*}[tildeChecks $words $info]
    lappend res {*}[octalChecks $words $info]
    lappend res {*}[globalChecks $words $info]

    # Checks for specific commands
    switch [lindex $words 0] {
        case {
            lappend res error "Command \"case\" is not available in Tcl 9. Use \"switch\" instead. \[UNKNOWNCOMMAND\]"
        }
        chan {
            lappend res {*}[chanChecks $words $info]
        }
        encoding {
            lappend res {*}[encodingChecks $words $info]
        }
        fconfigure {
            lappend res {*}[fconfigureChecks $words $info]
        }
        load {
            lappend res {*}[loadChecks $words $info]
        }
        namespace {
            lappend res {*}[namespaceChecks $words $info]
        }
        package {
            lappend res {*}[packageChecks $words $info]
        }
        string {
            lappend res {*}[stringChecks $words $info]
        }
        trace {
            lappend res {*}[traceChecks $words $info]
        }
        global -
        variable {
            lappend res {*}[collectVariableDeclarations $words $info]
        }
    }

    return $res
}

proc addToKnownNamespaces {ns info} {
    variable namespaceReported

    set parent [dict get $info namespace]
    if {$ns eq ""} {
        set ns $parent
    } else {
        if {![string match ::* $ns]} {
            set ns ${parent}::$ns
        }
    }
    # The "if" is just for being able to track when a ns is added
    # for debugging purposes
    if {![info exists ::knownNamespaces($ns)]} {
        # puts "Adding namespace $ns"
        set ::knownNamespaces($ns) 1
    }
    if {[dict get $info firstpass] == 0 && ![info exists namespaceReported($ns)]} {
        set namespaceReported($ns) 1
        # Migrate tool needs to track namespaces to mitigate false positives.
        return [list note "MIGRATE: AddNamespace $ns"]
    }
    return
}

# Checks related to globals
proc globalChecks {words info} {
    set res {}
    # Check for tcl_platform(threaded) but be careful to not have it
    # matched multiple times in nested blocks.
    foreach word $words {
        if {[regexp {^\S*tcl_platform\(threaded\)} $word]} {
           lappend res warning "The tcl_platform global does not have a `threaded` element in Tcl 9. \[UNKNOWNVAR\]"
        }
    }
    return $res
}

# Check commands for tilde usage
proc tildeChecks {words info} {
    set words [lassign $words cmd]
    set paths {}
    switch -exact -- $cmd {
        file {
            switch -exact -- [lindex $words 0] {
                atime - attributes - dirname - executable - exists - extension -
                isdirectory - isfile - lstat - mtime - nativename - normalize -
                owned - pathtype - readable - readlink - rootname - size - split -
                separator - stat - system - tail - type - writable {
                    # First argument if present is the name
                    lappend paths [lindex $words 1]
                }
                copy -
                delete -
                join -
                link -
                mkdir -
                rename {
                    set paths [lrange $words 1 end]
                }
            }
            set cmd "$cmd [lindex $words 0]"
        }
        unload -
        load   { set paths $words }
        source { lappend paths [lindex $words end] }
        msgcat::mcload -
        cd -
        readFile -
        writeFile -
        open -
        exec { lappend paths [lindex $words 0] }
        tcl::tm::path {
            switch -exact -- [lindex $words 0] {
                add -
                remove { set paths [lrange $words 1 end]}
                roots { set paths $words }
            }
        }
        zipfs {
            switch -exact -- [lindex $words 0] {
                canonical -
                exists -
                find -
                mount -
                mkzip -
                mkimg -
                lmkimg -
                lmkzip {
                    set paths [lrange $words 1 end]
                }
            }
        }
    }
    set res {}
    set tildeRE {^(2>|>)?\s*~}
    foreach path $paths {
        if {[regexp $tildeRE $path]} {
            lappend res warning "Path \"$path\" begins with a tilde. Tcl 9 \"$cmd\" does not do tilde expansion. \[TILDEPATH\]"
        }
    }
    return $res
}

# Checks for the namespace command, NOT content of a namespace block
proc namespaceChecks {words info} {
    if {[lindex $words 1] eq "eval"} {
        lappend res {*}[addToKnownNamespaces [lindex $words 2] $info]
    }
}

# variable command
proc collectVariableDeclarations {words info} {
    set ns [dict get $info namespace]
    if {$ns eq "" || $ns eq "::"} {
        return; # Not within a namespace
    }

    # Keep track of declared variables for this namespace
    switch [lindex $words 0] {
        variable {
            foreach {var val} [lindex $words 1 end] {
                dict set ::knownNamespaceVars(${ns}) $var 1
            }
        }
        global {
            foreach var [lindex $words 1 end] {
                dict set ::knownNamespaceVars(${ns}) $var 1
            }
        }
    }

    return
}

# load command
proc loadChecks {words info} {
    if {[llength $words] > 2 && [string is lower [string index [lindex $words 2] 0]]} {
        return [list warning "Load command initialization function name must start with upper case letter in Tcl 9. \[LOADCASE\]"]
    }
    return
}

# package command
proc packageChecks {words info} {
    set vers [lassign $words cmd sub pkg]
    switch $sub {
        present -
        require {
            if {$pkg eq "-exact"} {
                set vers [lassign $vers pkg]
            }
            if {$pkg eq "Tcl" && [llength $vers]} {
                if {![package vsatisfies 9 {*}$vers]} {
                    return [list warning "The command \"$words\" will fail in Tcl 9. \[TCLPKGVER\]"]
                }
            }
        }
        vsatisfies {
            # TODO - should this check and generate warning? Not clear
            # as it could be simply doing a polyfill or similar based
            # on versions.
        }
    }
    return
}

# Check for octals in commands
proc octalChecks {words info} {
    set words [lassign $words cmd]
    set octalRE {^0\d+}
    set res {}
    foreach word $words {
        # Octal outside of expressions generates too many false positives
        # so only check if mathop commands
        if {[namespace tail $cmd] in {+ - / * % == != < <= > >= & ~ | ^ << >>} && [regexp $octalRE $word]} {
            lappend res warning "\"$word\" is treated as an octal representation in Tcl 8 and decimal in Tcl 9. \[OCTAL\]"
        }
    }
    return $res
}

# Check fconfigure commands
proc fconfigureChecks {words info} {
    if {[llength $words] == 4 &&
        [lindex $words 2] eq "-eofchar" &&
        [string length [lindex $words 3]] > 1
    } {
        return [list warning "The value supplied to the `fconfigure -eofchar` option must be a single character. \[EOFCHAR\]"]
    }
    return
}

# Check chan commands
proc chanChecks {words info} {
    switch [lindex $words 1] {
        configure {
            if {[llength $words] == 4 &&
                [lindex $words 2] eq "-eofchar" &&
                [string length [lindex $words 3]] > 1
            } {
                return [list warning "The value supplied to the `chan -eofchar` option must be a single character. \[EOFCHAR\]"]
            }
        }
    }
    return
}

# Checks related to encoding configuration and commands
proc encodingChecks {words info} {
    set words [lassign $words cmd]
    set res {}
    switch $cmd {
        encoding {
            if {[llength $words] > 2} {
                set sub [lindex $words 0]
                set enc [lindex $words end-1]
                if {$sub in "convertto convertfrom"} {
                    if {$enc eq "identity"} {
                        lappend res error "Unknown encoding \"$enc\". \[NOSUCHENCODING\]"
                    }
                }
            }
        }
    }
    return $res
}

# Checks related to string command
proc stringChecks {words info} {
    switch [lindex $words 1] {
        "bytelength" {
            return [list error "Command \"string bytelength\" is not available in Tcl 9. \[UNKNOWNCOMMAND\]"]
        }
        "is" {
            if {[lindex $words 2] eq "integer"} {
                return [list note "Unlike Tcl 8, \"string is integer\" does not raise an error if value does not fit in 32 bits or contains underscores. \[STRINGISINT\]"]
            }
        }
    }
    return
}

# Checks related to trace command
proc traceChecks {words info} {
    switch [lindex $words 1] {
        variable {
            return [list error "Tcl 9 does not have the \"trace [lindex $words 1]\" command. Use \"trace add variable\" instead. \[UNKNOWNCOMMAND\]"]
        }
        vdelete {
            return [list error "Tcl 9 does not have the \"trace [lindex $words 1]\" command. Use \"trace remove variable\" instead. \[UNKNOWNCOMMAND\]"]
        }
        vinfo {
            return [list error "Tcl 9 does not have the \"trace [lindex $words 1]\" command. Use \"trace info variable\" instead. \[UNKNOWNCOMMAND\]"]
        }
    }
    return
}

# Detect possible change variable name resolution rules between Tcl 8 and Tcl 9.
# The former includes global namespace in search path, the latter does not. So
# flag relative namespace paths
proc checkRelativeNamespace {var info} {
    if {[dict get $info firstpass]} {
        return
    }

    set ns [dict get $info namespace]
    if {$ns eq "" || $ns eq "::"} {
        return
    }

    # Check for relative namespaces. Do not use {^[^:]+::} as regexp
    # as want to exclude ${ns}::xxx, [namespace current]::xxx etc.
    # Note final output filter will check if namespaces are valid
    # and filter out false positives.
    if {[regexp {^[a-zA-Z0-9_]+::} $var]} {
        # Check if it is a child namespace
        set varNs ${ns}::[namespace qualifiers $var]
        if {![info exists ::knownNamespaces($varNs)]} {
            # Not a child namespace so should be fully qualified.
            # IMPORTANT: the syntax of this message is depended on by the
            # output filter that checks for false positives.
            return [list warning "Variable $var maps to possibly non-existent child namespace $varNs. \[RELATIVENS\]"]
        }
    }
    return
}

proc varWrite {var info} {
    if {[dict get $info firstpass]} {
        return
    }
    set res [checkRelativeNamespace $var $info]

    set caller [dict get $info caller]
    if {$caller eq ""} {
        set ns [dict get $info namespace]
        if {$ns ne "" && $ns ne "::" && ![string match *::* $var]} {
            # Inside a namespace and unqualified name
            if {![info exists ::knownNamespaceVars($ns)] || ![dict exists $::knownNamespaceVars($ns) $var]} {
                lappend res warning "Variable $var possibly set without a variable or global declaration within namespace $ns. \[UNDECLARED\]"
            }
        }
    }
    return $res
}

proc varRead {var info} {
    # Note: would have liked to check for tcl_platform(threaded) here
    # but var only seems to contain the array name, not element
    set res [checkRelativeNamespace $var $info]
    return $res
}

proc lateExpr {exp info} {
    if {[regexp {(^|[-+&()/*\t\b])(0\d{3,})} $exp - - number]} {
        return [list warning "\"$number\" is treated as an octal representation in Tcl 8 and decimal in Tcl 9. \[OCTAL\]"]
    }
    return
}

# Plugin hook for script bodies - Collect known namespaces
proc bodyRaw {stmt info} {
    return [addToKnownNamespaces "" $info]
}

