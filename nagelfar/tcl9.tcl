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
    set words [lassign $words cmd]
    foreach word $words {
        if {[regexp $RE1 $word]} {
            lappend res warning "Tilde expansion not supported anymore. \[TILDE\]"
        }
        # Octal outside of expressions generates too many false positives
        # so only check if mathop commands
        if {[namespace tail $cmd] in {+ - / * % == != < <= > >= & ~ | ^ << >>} && [regexp $RE2 $word]} {
            lappend res warning "Value $word uses obsolete octal format. \[OCTAL\]"
        }
    }
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
            return [list warning "Variable $var maps to possibly non-existent namespace $varNs. \[RELATIVENSVAR\]"]
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
        # Also let qualified names drop down to the checkRelativeNamespace
        # command below
        if {$ns ne "" && $ns ne "::" && ![string match *::* $var]} {
            # TBD is this a good way to detect creative writing?
            if {![info exists ::known(${ns}::$var)]} {
                lappend res warning "Writing $var without variable call"
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
    set RE {(^|\W)0\d+}
    set res {}
    if {[regexp $RE $exp]} {
        lappend res warning "Value $exp uses obsolete octal format. \[OCTAL\]"
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
