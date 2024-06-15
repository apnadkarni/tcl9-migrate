##Nagelfar Plugin : Look for tcl 9.0 possible problems


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
    }
    
    return $res
}

# Encoding command
proc encodingStatementWords {words info} {
    set sub [lindex $words 1]
    set enc [lindex $words 2]

    if {$sub in "convertto convertfrom"} {
        if {$enc eq "identity"} {
            return [list error "Encoding identity does not exist anymore. \[NOSUCHENCODING\]"]
        }
    }
}

# Package command
proc packageStatementWords {words info} {
    set sub [lindex $words 1]
    set pkg [lindex $words 2]
    set ver [lindex $words 3]
    set vers [lrange $words 3 end]

    if {$sub eq "require" && $pkg eq "Tcl"} {
        if {![string match "*-" $ver]} {
            return [list warning "Consider ending required revision with -, e.g. \"8.5-\""]
        }
    }
    if {$sub eq "vsatisfies" && [string match "* Tcl*" $pkg]} {
        if {[llength $vers] == 1} {
            return [list warning "Consider comparing revision against a range, e.g. \"8.5 9\""]
        }
    }
}

# Any command check
proc anyStatementWords {words info} {
    set RE1 {^(2>|>)?\s*~}
    set RE2 {^0\d+}
    set res {}
    foreach word $words {
        if {[regexp $RE1 $word]} {
            lappend res warning "Tilde expansion not supported anymore. \[TILDE\]"
        }
        if {[regexp $RE2 $word]} {
            lappend res warning "Octal number \"$word\" not supported anymore. \[OCTAL\]"
        }
    }
    return $res
}

# Checks outside of proc, in namespace
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
    if {[regexp {^[^:]+::} $var]} {
        # Check if it is a child namespace
        set varNs ${ns}::[namespace qualifiers $var]
        if {![info exists ::knownNamespaces($varNs)]} {
            # Not a child namespace so should be fully qualified.
            return [list warning "Variable $var qualified with namespace $varNs. \[NSVAR\]"]
        }
    }
    return
}

# Plugin Hook for variable write
proc varWrite {var info} {
    set caller [dict get $info caller]

    # Outside of a proc, creative writing means unqualified var name
    # without variable definition for the namespace
    if {$caller eq ""} {
        set ns [dict get $info namespace]
        # Global is not interesting so skip in that case
        if {$ns ne "" && $ns ne "::"} {
            # TBD is this a good way to detect creative writing?
            if {![info exists ::known(${ns}::$var)]} {
                return [list warning "Writing $var without variable call"]
            }
        }
    }
    return [checkRelativeNamespace $var $info]
}

# Plugin Hook for variable read
proc varRead {var info} {
    return [checkRelativeNamespace $var $info]
}

# Plugin Hook for simplified expressions
proc lateExpr {exp info} {
    # Look for octal literals
    set RE {(^|\W)0\d+}
    set res {}
    if {[regexp $RE $exp]} {
        lappend res warning "Octal format not supported \[OCTAL\]"
    }
    return $res
}

# Plugin hook for script bodies - Collect known namespaces
proc bodyRaw {stmt info} {
    set ::knownNamespaces([dict get $info namespace]) 1
    return
}
