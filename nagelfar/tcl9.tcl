##Nagelfar Plugin : Look for tcl 9.0 possible problems

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
        set ::knownNamespaces($ns) 1
    }
    if {[dict get $info firstpass] == 0 && ![info exists namespaceReported($ns)]} {
        set namespaceReported($ns) 1
        # Migrate tool needs to track namespaces to mitigate false positives.
        return [list note "MIGRATE: AddNamespace $ns"]
    }
    return
}

# Plugin Hook for commands
proc statementWords {words info} {
    set caller [dict get $info caller]
    set res {}

    if {$caller eq ""} {
        lappend res {*}[nsStatementWords $words $info]
    }
    set cmd [lindex $words 0]

    # Look for e.g. tilde in file related
    lappend res {*}[anyStatementWords $words $info]

    switch $cmd {
        encoding { lappend res {*}[encodingStatementWords $words $info] }
        package  { lappend res {*}[packageStatementWords $words $info] }
        namespace {
            if {[lindex $words 1] eq "eval"} {
                lappend res {*}[addToKnownNamespaces [lindex $words 2] $info]
            }
        }
    }

    return $res
}

# Encoding command
proc encodingStatementWords {words info} {
    if {[llength $words] > 3} {
        set sub [lindex $words 1]
        set enc [lindex $words end-1]
        if {$sub in "convertto convertfrom"} {
            if {$enc eq "identity"} {
                return [list error "Encoding identity does not exist anymore. \[NOSUCHENCODING\]"]
            }
        }
    }
    return
}

# Package command
proc packageStatementWords {words info} {
    set vers [lassign $words cmd sub pkg]
    switch $sub {
        present -
        require {
            if {$pkg eq "-exact"} {
                set vers [lassign $vers pkg]
            }
            if {$pkg eq "Tcl" && [llength $vers]} {
                if {![package vsatisfies 9 {*}$vers]} {
                    return [list warning "The command \"$words\" will reject Tcl 9. \[TCLPKGVER\]"]
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

# Check commands for tilde usage
proc tildeChecks {cmd words info} {
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

# Check for octals in commands
proc octalChecks {cmd words info} {
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

# Any command check
proc anyStatementWords {words info} {
    set words [lassign $words cmd]
    lappend res {*}[tildeChecks $cmd $words $info]
    lappend res {*}[octalChecks $cmd $words $info]
    return $res
}

# Checks outside of proc, in namespace. NOT namespace command itself.
proc nsStatementWords {words info} {
    set res {}
    set ns [dict get $info namespace]
    # Global is not interesting
    if {$ns eq "" || $ns eq "::"} return

    set cmd [lindex $words 0]
    # Remember "declared" variables.
    if {$cmd eq "variable"} {
        foreach {var _} [lindex $words 1 end] {
            set ::known(${ns}::$var) 1
        }
    }

    return $res
}

# Detect possible change variable name resolution rules between Tcl 8 and Tcl 9.
# The former includes global namespace in search path, the latter does not. So
# flag relative namespace paths
proc checkRelativeNamespace {var info} {
    if {[dict get $info firstpass]} {
        return
    }

    set ns [dict get $info namespace]
    # Global is not interesting
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

# Plugin Hook for variable write
proc varWrite {var info} {
    if {[dict get $info firstpass]} {
        return
    }
    set res [checkRelativeNamespace $var $info]

    set caller [dict get $info caller]
    # Outside of a proc, creative writing means unqualified var name
    # without variable definition for the namespace
    if {$caller eq ""} {
        set ns [dict get $info namespace]
        # Global is not interesting so skip in that case
        if {$ns ne "" && $ns ne "::" && ![string match *::* $var]} {
            # TBD is this a good way to detect creative writing?
            if {![info exists ::known(${ns}::$var)]} {
                lappend res warning "Variable $var possible set without a variable declaration. \[UNDECLARED\]"
            }
        }
    }
    return $res
}

# Plugin Hook for variable read
proc varRead {var info} {
    return [checkRelativeNamespace $var $info]
}

# Plugin Hook for simplified expressions
proc lateExpr {exp info} {
    # Look for octal literals
    set RE {(^|\W)(0\d+)}
    set res {}
    if {[regexp $RE $exp - - number]} {
        lappend res warning "\"$number\" is treated as an octal representation in Tcl 8 and decimal in Tcl 9. \[OCTAL\]"
    }
    return $res
}

# Plugin hook for script bodies - Collect known namespaces
proc bodyRaw {stmt info} {
    return [addToKnownNamespaces "" $info]
}

proc finalizePlugin {} {
    #puts "NS - [join [array names ::knownNamespaces] ,] \[NAMESPACES\]"
    return
}
