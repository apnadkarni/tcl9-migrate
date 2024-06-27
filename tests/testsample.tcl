# tclsh c:\src\nagelfar\nagelfar.tcl -pluginpath c:/src/nagelfar/plugins -s syntaxdb90.tcl -plugin tcl9.tcl z.tcl

catch {
    package require Tcl 8
}

catch {set tcl_platform(threaded) $tcl_platform(threaded)}

source [file join [file dirname [info script]] iso8859-1.tcl]
foobar xx

puts $foo

if {![catch {
        set fd [open ~/foo]
}]} {
    close $fd
}

if {![catch {
    set fd [open ~$::env(USERNAME)/foo]
}]} {
    close $fd
}

if {![catch {
    exec ~/bar
}]} {
    close $fd
}

# Should not generate warning
if {![catch {
    set fd [open bar/~/foo]
}]} {
    close $fd
}

file exists ~/foo
file join ~ foo
file join foo ~
catch {
    file copy ~/nosuchfile foo
    file copy nosuchfile ~/foo
}
oo::class create C {
    method m {} {file join ~ foo}
}

proc foo {} {open ~/xxx}
catch {foo}

catch {::msgcat::mcload ~/mccatalog}

tcl::mathop::+ 0123
expr 0123
if {0123 & 1} {}
if {0123&1} {}
if {1+0123} {}
if {(0123&1)} {}
expr 1e+01 ;# Should not be caught

string is integer 10
if {![info exists ::tcl9migrate::runtime::enabled]} {
    encoding convertfrom identity abc
    string bytelength do
}

catch {load bar.dll}; # Should not generate warning
catch {load bar.dll Bar}; # Should not generate warning
catch {load foo.dll foo}
catch {load -global foo.dll foo}

catch {
    trace variable foo r {}
    trace vdelete foo
    trace vinfo foo
}

catch {
    case foo {}
}

catch {fconfigure somechan -eofchar X}; # Should not generate warning
catch {fconfigure somechan -eofchar {}}; # Should not generate warning
catch {fconfigure somechan -eofchar {a b}}
catch {chan configure somechan -eofchar {a b}}

namespace eval ::ns2 {variable var}
namespace eval ::ns {

    catch {set xx $::tcl_platform(threaded)}

    namespace eval childns {variable var}

    variable nsvar
    global globvar
    set nsvar foo; # Should not generate warning
    set globvar foo; # Should not generate warning
    set creativevar xx

    # Only during static test else raises runtime errors
    if {![info exists ::tcl9migrate::runtime::enabled]} {

        # Should emit warnings
        array exists ns2::arr
        array set ns2::arr {}
        array anymore ns2::arr xx
        array donesearch ns2::arr xx
        array for {i j} ns2::arr {}
        array get ns2::arr
        array names ns2::arr
        array nextelement ns2::arr xx
        array size ns2::arr
        array startsearch ns2::arr
        array statistics ns2::arr
        array unset ns2::arr *

        dict append ns2::dictionary xx xx
        dict incr ns2::dictionary xx
        dict lappend ns2::dictionary xx xx
        dict set ns2::dictionary xx xx
        dict with ns2::dictionary {}
        dict update ns2::dictionary k v {}
        dict unset ns2::dictionary xx

        set ns2::var xx
        append ns2::var xx
        ledit ns2::var 0 1 xx
        lset ns2::var 0 xx
        incr ns2::var
        unset ns2::var
        parray ns2::var
        info exists ns2::var
        gets stdin ns2::var
        vwait ns2::var
    }


    proc p {} {
        expr 0123
        if {0123 & 1} {}
        array anymore ns2::arr xx
        array donesearch ns2::arr xx
        array exists ns2::arr
        array for {i j} ns2::arr {}
        array get ns2::arr
        array names ns2::arr
        array nextelement ns2::arr xx
        array set ns2::arr {}
        array size ns2::arr
        array startsearch ns2::arr
        array statistics ns2::arr
        array unset ns2::arr *

        dict append ns2::dictionary xx xx
        dict incr ns2::dictionary xx
        dict lappend ns2::dictionary xx xx
        dict set ns2::dictionary xx xx
        dict with ns2::dictionary {}
        dict update ns2::dictionary k v {}
        dict unset ns2::dictionary xx

        set ns2::var xx
        append ns2::var xx
        ledit ns2::var 0 1 xx
        lset ns2::var 0 xx
        incr ns2::var
        unset ns2::var
        namespace upvar ns2 var xx
        parray ns2::var
        info exists ns2::var
        gets stdin ns2::var
        vwait ns2::var
    }
}

# Should NOT emit warnings at global level
if {![info exists ::tcl9migrate::runtime::enabled]} {
    array anymore ns2::arr xx
    array donesearch ns2::arr xx
    array exists ns2::arr
    array for {i j} ns2::arr {}
    array get ns2::arr
    array names ns2::arr
    array nextelement ns2::arr xx
    array set ns2::arr {}
    array size ns2::arr
    array startsearch ns2::arr
    array statistics ns2::arr
    array unset ns2::arr *

    dict append ns2::dictionary xx xx
    dict incr ns2::dictionary xx
    dict lappend ns2::dictionary xx xx
    dict set ns2::dictionary xx xx
    dict with ns2::dictionary {}
    dict update ns2::dictionary k v {}
    dict unset ns2::dictionary xx

    set ns2::var xx
    append ns2::var xx
    ledit ns2::var 0 1 xx
    lset ns2::var 0 xx
    incr ns2::var
    unset ns2::var
    parray ns2::var
    info exists ns2::var
    gets stdin ns2::var
    vwait ns2::var
}

# Should not emit warnings as child namespace exists
namespace eval ns {
    if {![info exists ::tcl9migrate::runtime::enabled]} {
        array exists childns::arr
        array set childns::arr {}
        array anymore childns::arr xx
        array donesearch childns::arr xx
        array for {i j} childns::arr {}
        array get childns::arr
        array names childns::arr
        array nextelement childns::arr xx
        array size childns::arr
        array startsearch childns::arr
        array statistics childns::arr
        array unset childns::arr *

        dict append childns::dictionary xx xx
        dict incr childns::dictionary xx
        dict lappend childns::dictionary xx xx
        dict set childns::dictionary xx xx
        dict with childns::dictionary {}
        dict update childns::dictionary k v {}
        dict unset childns::dictionary xx

        set childns::var xx
        append childns::var xx
        ledit childns::var 0 1 xx
        lset childns::var 0 xx
        incr childns::var
        unset childns::var
        parray childns::var
        info exists childns::var
        gets stdin childns::var
        vwait childns::var
        
    }
}
