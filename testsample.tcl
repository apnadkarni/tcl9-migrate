# tclsh c:\src\nagelfar\nagelfar.tcl -pluginpath c:/src/nagelfar/plugins -s syntaxdb90.tcl -plugin tcl9.tcl z.tcl

encoding convertfrom identity abc
string bytelength do
foobar xx

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

# Should not generate warning
if {![catch {
    set fd [open bar/~/foo]
}]} {
    close $fd
}

proc foo {} {open ~/xxx}
catch {foo}

tcl::mathop::+ 0123
expr 0123
if {0123 & 1} {}


namespace eval ::ns2 {variable var}
namespace eval ::ns {
    namespace eval childns {variable var}

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
