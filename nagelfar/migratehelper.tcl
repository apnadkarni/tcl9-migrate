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
    set res {}
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
                join -
                copy -
                delete -
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
            }
        }
        tcl::tm::roots {
            set paths [lindex $words 0 0]
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
    set tildeRE {^(2>|>)?\s*~}
    foreach path $paths {
        if {[regexp $tildeRE $path]} {
            lappend res warning "Path \"$path\" begins with a tilde. \"$cmd\" does not do tilde expansion in Tcl 9. \[TILDEPATH\]"
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
    set nargs [llength $words]
    for {set i 1} {$i < $nargs} {incr i} {
        switch [lindex $words $i] {
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
    # $i is first argument after options which would be path of
    # the shared library. Next argument, if present, is init function name
    if {[incr i] < $nargs} {
        # The name of the Init function must be title case
        if {[string is lower [string index [lindex $words $i] 0]]} {
            return [list warning "Load command initialization function name \"[lindex $words $i]\" must start with upper case letter in Tcl 9. \[LOADCASE\]"]
        }
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

# Check arguments passed to fconfigure and chan configure.
proc configureChecks {cmd arguments} {
    # CHAN ...
    set res {}
    if {[llength $arguments] > 2} {
        foreach {opt optval} [lrange $arguments 1 end] {
            # Nagelfar passes the raw word. Extract the literal value.
            if {[regexp {^\[.*\]$} $optval] ||
                [string match "{\*}*" $optval] ||
                [string index $optval 0] eq "\$"
            } {
                # Argument is [command] or {*} or $var. Skip
                continue
            }
            # Remove "" and {} delmiters
            set first [string index $optval 0]
            set last [string index $optval end]
            if {($first eq "\"" && $last eq $first) ||
                ($first eq "\{" && $last eq "\}")} {
                set optval [string range $optval 1 end-1]
            }
            switch $opt {
                "-eofchar" {
                    if {[string length $optval] > 1} {
                        lappend res error "The value \"$optval\" supplied to the \"$cmd $opt\" option must be a single character. \[EOFCHAR\]"
                    }
                }
                "-encoding" {
                    if {$optval in {binary {}}} {
                        lappend res error "The value \"$optval\" is not valid for the \"$cmd $opt\" option. \[CHANENCODING\]"
                    }
                }
            }
        }
    }
    return $res
}

# Check fconfigure commands
proc fconfigureChecks {words info} {
    return [configureChecks "fconfigure" [lrange $words 1 end]]
}

# Check chan commands
proc chanChecks {words info} {
    switch [lindex $words 1] {
        configure {
            return [configureChecks "chan configure" [lrange $words 2 end]]
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
                return [list note "Semantics of \"string is integer\" are different between Tcl 8 and Tcl 9. \[STRINGISINT\]"]
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
        # Check if it is a child namespace. If so ok, otherwise log warning.
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

proc checkUnqualifiedReference {var info op} {
    set res {}
    set caller [dict get $info caller]
    if {$caller eq ""} {
        set ns [dict get $info namespace]
        if {$ns ne "" && $ns ne "::" && ![string match snit::* $ns] && ![string match *::* $var]} {
            # Inside a namespace and unqualified name
            # The variable may be an array element like A(foo) in which
            # case we need to check both A and A(foo)
            if {![regexp {^([[:alnum:]_:]*)(\(.*\))?$} $var - arrayVar]} {
                set arrayVar $var
            }
            if {![info exists ::knownNamespaceVars($ns)] ||
                (![dict exists $::knownNamespaceVars($ns) $var] &&
                 ![dict exists $::knownNamespaceVars($ns) $arrayVar])} {
                lappend res warning "Variable \"$var\" possibly referenced ($op) without a variable or global declaration within namespace $ns. \[UNDECLARED\]"
            }
        }
    }
    return $res
}

proc varWrite {var info} {
    if {[dict get $info firstpass]} {
        return
    }
    lappend res {*}[checkRelativeNamespace $var $info]
    lappend res {*}[checkUnqualifiedReference $var $info write]
    return $res
}

proc varRead {var info} {
    # Note: var only contains array name, not array element on
    # $v but full name on "set v"

    lappend res {*}[checkRelativeNamespace $var $info]
    lappend res {*}[checkUnqualifiedReference $var $info read]
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


