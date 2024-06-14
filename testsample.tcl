# tclsh c:\src\nagelfar\nagelfar.tcl -pluginpath c:/src/nagelfar/plugins -s syntaxdb90.tcl -plugin tcl9.tcl z.tcl

if {![catch {
        set fd [open ~/foo]
}]} {
    close $fd
}

if {![catch {
    set fd [open ~xxx/foo]
}]} {
    close $fd
}

# Should not generate warning
if {![catch {
    set fd [open bar/~/foo]
}]} {
    close $fd
}

proc foo {} {
    open ~/xxx
}

expr 0123
if {0123 & 1} {}


namespace eval ::ns2 {variable var}
namespace eval ::ns {
    namespace eval childns {variable var}

    # Should emit warnings
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
    set childns::var xx
    append ns2::var xx
    ledit ns2::var 0 1 xx
    lset ns2::var 0 xx
    incr ns2::var
    unset ns2::var
    parray ns2::var
    info exists ns2::var
    gets stdin ns2::var
    vwait ns2::var

    proc p {} {
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
set childns::var xx
append ns2::var xx
ledit ns2::var 0 1 xx
lset ns2::var 0 xx
incr ns2::var
unset ns2::var
parray ns2::var
info exists ns2::var
gets stdin ns2::var
vwait ns2::var
