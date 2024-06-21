#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

#----------------------------------------------------------------------
#  Nagelfar, a syntax checker for Tcl.
#  Copyright (c) 1999-2022, Peter Spjuth
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING.  If not, write to
#  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#  Boston, MA 02110-1301, USA.
#
#----------------------------------------------------------------------
# prologue.tcl
#----------------------------------------------------------------------
# 845924ff336db468b8c8182c5a307ca0cc8277b0
#----------------------------------------------------------------------

set debug 0
package require Tcl 8.6-

package provide app-nagelfar 1.0
# This variable should be overwritten by the build process
set version "Version ??? ???"

# Allow thisScript to be predefined (used for test)
if {![info exists thisScript]} {
    set thisScript [file normalize [file join [pwd] [info script]]]
}
set thisDir    [file dirname $thisScript]

# Follow any link
set tmplink $thisScript
while {[file type $tmplink] == "link"} {
    set tmplink [file readlink $tmplink]
    set tmplink [file normalize [file join $thisDir $tmplink]]
    set thisDir [file dirname $tmplink]
}
unset tmplink

# This makes it possible to customize where files are installed
set dbDir      $thisDir
set docDir     $thisDir/doc
set libDir     $thisDir/lib
 
# Search where the script is, to be able to place e.g. ctext there.
if {[info exists ::starkit::topdir]} {
    lappend auto_path [file dirname [file normalize $::starkit::topdir]]
} else {
    lappend auto_path $libDir
}
set version "Version 1.3.3 2024-06-11"
#----------------------------------------------------------------------
#  Nagelfar, a syntax checker for Tcl.
#  Copyright (c) 1999-2022, Peter Spjuth
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING.  If not, write to
#  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#  Boston, MA 02110-1301, USA.
#
#----------------------------------------------------------------------
# nagelfar.tcl
#----------------------------------------------------------------------

# TODO: Make it possible to put a global var type in syntax file.
##nagelfar variable ::Nagelfar(resultWin) _obj,text

#####################
# Syntax check engine
#####################

# Arguments to many procedures:
# index     : Index of the start of a string or command.
# cmd       : Command
# argv      : List of arguments
# wordstatus: List of status for the words in argv
# indices   : List of indices where every word in argv starts
# knownVars : A dict that keeps track of variables known in this scope

# Interpretation of wordstatus:
# 1 constant
# 2 braced
# 4 quoted
# 8 {*}-expanded

# Interpretation of knownVars:
# Each key is a variable name, with a dict with the following possible fields:
# knownVars $var           : Existence means variable is known to exist.
# knownVars $var local     : Variable is local in a procedure.
# knownVars $var set       : A set of this variable has been seen.
# knownVars $var read      : A read of this variable seen before any set.
# knownVars $var used      : A read of this variable seen.
# knownVars $var type      : The variable's type if known.
# knownVars $var array     : The variable is an array
# knownVars $var namespace : Variable belongs to this namespace. (unless local)
# knownVars $var upvar     : Variable is upvared from this variable.

# Helper to initialise a knownVars element to defaults.
# This helps make sure all fields that must exist do
proc knownVar {knownVarsName var} {
    upvar $knownVarsName knownVars
    dict set knownVars $var local 0
    dict set knownVars $var set   0
    dict set knownVars $var read  0
    dict set knownVars $var used  0
    dict set knownVars $var type  ""
    # The array field can be unknown or boolean
    dict set knownVars $var array ""
    dict set knownVars $var namespace ""
    dict set knownVars $var upvar     ""
}

# Moved out message handling to make it more flexible
proc echo {str {tag {}}} {
    if {[info exists ::Nagelfar(resultWin)]} {
        if {$tag == 1} {
            set tag info
        }
        $::Nagelfar(resultWin) configure -state normal
        $::Nagelfar(resultWin) insert end $str\n $tag
        $::Nagelfar(resultWin) configure -state disabled
    } elseif {$::Nagelfar(embedded)} {
        lappend ::Nagelfar(chkResult) $str
    } else {
        puts stdout $str
    }
    update
}

# Debug output
proc decho {str} {
    if {[info exists ::Nagelfar(resultWin)]} {
        $::Nagelfar(resultWin) configure -state normal
        $::Nagelfar(resultWin) insert end $str\n error
        $::Nagelfar(resultWin) configure -state disabled
    } else {
        puts stderr $str
    }
    update
}

# Error message from program, not from syntax check
proc errEcho {msg} {
    if {$::Nagelfar(gui)} {
        tk_messageBox -title "Nagelfar Error" -type ok -icon error \
                -message $msg
    } else {
        puts stderr $msg
    }
}

# Add html quoting on a string
proc Text2Html {data} {
    string map {\& \&amp; \< \&lt; \> \&gt; \" \&quot;} $data
}

# Moved out of errorMsg so message and line-filter use the same
# text
proc errorMsgLinePrefix {line appendStr} {
    set pre ""
    if {$::currentFile != ""} {
        set pre "$::currentFile: "
    }
    if {$::Prefs(prefixFile)} {
        # Use a shorter format when -H flag is used
        # This format can be parsed by e.g. emacs compile
        set pre "${pre}$line: "
    } else {
        set pre "${pre}Line [format %3d $line]: "
    }
    return $pre$appendStr
}

# Standard error message.
# severity : How severe a message is E/W/N for Error/Warning/Note
proc errorMsg {severity msg i {notAllowedinFirst 0}} {
    #echo "$msg"
    if {$::Prefs(html)} {
        set htmlMsg [Text2Html $msg]
        if {$msg == "Expr without braces"} {
            append htmlMsg " (see <a href=\"http://tclhelp.net/unb/194\" target=\"_tclforum\">http://tclhelp.net/unb/194</a>)"
        }
    }

    if {[info exists ::Nagelfar(currentMessage)] && \
            $::Nagelfar(currentMessage) != ""} {
        lappend ::Nagelfar(messages) [list $::Nagelfar(currentMessageLine) \
                $::Nagelfar(currentMessage) $::Nagelfar(currentHtmlMessage)]
    }

    set ::Nagelfar(currentMessage) ""
    set ::Nagelfar(currentHtmlMessage) ""
    # Stop some messages in first pass
    if {$::Nagelfar(firstpass) && $notAllowedinFirst} {
        return
    }
    switch $severity {
        E {}
        W { if {$::Prefs(severity) == "E"} return }
        N { if {$::Prefs(severity) != "N"} return }
        default {
            decho "Internal error: Bad severity '$severity' passed to errorMsg"
            return
        }
    }

    set line [calcLineNo $i]
    set pre [errorMsgLinePrefix $line "$severity "]
    if {$::Prefs(html)} {
	switch $severity {
	    E { set color "#DD0000"; set severityMsg "ERROR" }
	    W { set color "#FFAA00"; set severityMsg "WARNING" }
	    N { set color "#66BB00"; set severityMsg "NOTICE" }
	}
        set htmlPre "<a href=#$::Prefs(htmlprefix)$line>Line [format %3d $line]</a>: <font color=$color><strong>$severityMsg</strong></font>: "
        set ::Nagelfar(currentHtmlMessage) $htmlPre$htmlMsg
    }

    set ::Nagelfar(indent) [string repeat " " [string length $pre]]
    set ::Nagelfar(currentMessage) $pre$msg
    set ::Nagelfar(currentMessageLine) $line
}

# Continued message. Used to give extra info after an error.
proc contMsg {msg {i {}}} {
    if {$::Nagelfar(currentMessage) == ""} return
    append ::Nagelfar(currentMessage) "\n" $::Nagelfar(indent)
    if {$i != ""} {
        regsub -all {%L} $msg [calcLineNo $i] msg
    }
    append ::Nagelfar(currentMessage) $msg
    if {$::Prefs(html)} {
        append ::Nagelfar(currentHtmlMessage) [Text2Html $msg]
    }
}

# Initialize message handling.
proc initMsg {} {
    set ::Nagelfar(messages) {}
    set ::Nagelfar(currentMessage) ""
    set ::Nagelfar(currentHtmlMessage) ""
    set ::Nagelfar(commentbrace) {}
}

# Called after a file has been parsed, to flush messages
proc flushMsg {} {
    if {[info exists ::Nagelfar(currentMessage)] && \
            $::Nagelfar(currentMessage) != ""} {
        lappend ::Nagelfar(messages) [list $::Nagelfar(currentMessageLine) \
                $::Nagelfar(currentMessage) $::Nagelfar(currentHtmlMessage)]
    }

    set msgs [lsort -integer -index 0 $::Nagelfar(messages)]

    foreach msg $msgs {
	set line [lindex $msg 0]
        set text [lindex $msg 1]
        set print 1
        foreach filter $::Nagelfar(filter) {
	    lassign $filter pat start_line end_line
	    if {$start_line > 0} {
		# line specific filter
		if {$line >= $start_line && $line <= $end_line} {
		    set final_pat [errorMsgLinePrefix $line $pat]
		    if {[string match $final_pat $text]} {
			set print 0
		    }
		}
	    } else {
		# general filter
		if {[string match $pat $text]} {
		    set print 0
		    break
		}
	    }
        }
        if {$print} {
            incr ::Nagelfar(messageCnt)
            if {$::Prefs(html)} {
                echo [lindex $msg 2] message$::Nagelfar(messageCnt)
            } else {
                echo [lindex $msg 1] message$::Nagelfar(messageCnt)
            }
            if {$::Nagelfar(exitstatus) < 2 && [string match "*: E *" $msg]} {
                set ::Nagelfar(exitstatus) 2
            } elseif {$::Nagelfar(exitstatus) < 1 && [string match "*: W *" $msg]} {
                set ::Nagelfar(exitstatus) 1
            }
        }
    }
    initMsg
}

# Report any unbalanced braces in comments that have been noticed
proc reportCommentBrace {fromIx toIx} {
    set fromLn [calcLineNo $fromIx]
    set toLn   [calcLineNo $toIx]
    set new {}
    foreach {n lineNo} $::Nagelfar(commentbrace) {
        if {$fromLn <= $lineNo && $lineNo <= $toLn} {
            contMsg "Unbalanced brace in comment in line $lineNo."
        } else {
            lappend new $n $lineNo
        }
    }
    # Only report it once
    set ::Nagelfar(commentbrace) $new
}

# Trim a string to fit within a length.
proc trimStr {str {len 10}} {
    set str [string trim $str]
    if {[string length $str] > $len} {
        set str [string range $str 0 [expr {$len - 4}]]...
    }
    return $str
}

# Test for comments with unmatched braces.
proc checkPossibleComment {str lineNo} {
    # Count braces
    set n1 [llength [split $str \{]]
    set n2 [llength [split $str \}]]
    if {$n1 != $n2} {
        lappend ::Nagelfar(commentbrace) [expr {$n1 - $n2}] $lineNo
    }
}

# Copy the syntax from one command to another
proc CopyCmdInDatabase {from to {map {}}} {
    foreach arrName {::syntax ::return ::subCmd ::option} {
        upvar 0 $arrName arr
        foreach item [array names arr] {
            if {$item eq $from} {
                # Handle overwrite?
                if {[info exists arr($to)]} {
                    if {$arrName eq "::subCmd"} {
                        # Add to a subcommand list
                        set arr($to) [lsort -unique [concat $arr($to) $arr($item)]]
                    } else {
                        # FIXA?
                        #echo "$::Nagelfar(firstpass) $from $to $arrName $item"
                    }
                } else {
                    #echo "Copy $from $to $arrName $item"
                    set arr($to) [string map $map $arr($item)]
                }
            } else {
                set len [expr {[string length $from] + 1}]
                if {[string equal -length $len $item "$from "]} {
                    set to2 "$to [string range $item $len end]"
                    set arr($to2) [string map $map $arr($item)]
                }
            }
        }
    }
    lappend ::knownCommands $to
}

# This is called when a comment is encountered.
# It allows syntax information to be stored in comments
proc checkComment {str index knownVarsName} {
    upvar $knownVarsName knownVars

    # Support Frink's inline comment
    if {[regexp {\#\s*(FRINK|PRAGMA):\s*nocheck} $str -> keyword]} {
        set line [calcLineNo $index]
        incr line
        addFilter "*" $line $line
        return
    }

    # We only care about this pattern
    if {![string match "##nagelfar *" $str]} {
        return
    }

    set commentList [string range $str 11 end]
    if {[catch {llength $commentList}]} {
        errorMsg N "Bad list in ##nagelfar comment" $index 1
        return
    }
    if {[llength $commentList] == 0} return
    set cmd [lindex $commentList 0]

    # Let plugins see comments and define additional ones
    set pluginComment [pluginHandleComment $cmd [lrange $commentList 1 end]]
    if {$pluginComment} {
        # Plugin specific action
        return
    }

    set first [lindex $commentList 1]
    set rest  [lrange $commentList 2 end]

    switch -- $cmd {
        syntax {
            #                decho "Syntax for '$first' : '$rest'"
            set ::syntax($first) $rest
            lappend ::knownCommands $first
        }
        implicitvarns {
            set ::implicitVarNs($first) $rest
        }
        implicitvarns+ {
            lappend ::implicitVarNs($first) {*}$rest
        }
        implicitvarcmd {
            set ::implicitVarCmd($first) $rest
        }
        implicitvarcmd+ {
            lappend ::implicitVarCmd($first) {*}$rest
        }
        return {
            set ::return($first) $rest
        }
        subcmd {
            set ::subCmd($first) $rest
        }
        subcmd+ {
            lappend ::subCmd($first) {*}$rest
        }
        package {
            if {$first eq "known"} {
                lappend ::knownPackages {*}$rest
            } elseif {$first eq "require"} {
                lookForPackageDb $rest $index
            } else {
                errorMsg N "Bad type in ##nagelfar comment" $index 1
            }
        }
        option {
            set ::option($first) $rest
        }
        option+ {
            lappend ::option($first) {*}$rest
        }
        variable {
            set type [join $rest]
            markVariable $first 1 "" 1n $index unknown knownVars type
        }
        vartype {
            # Just mark the type on an existing variable
            # This cannot be done during the first pass when variables
            # are not fully handled
            if {!$::Nagelfar(firstpass)} {
                set type [join $rest]
                setVariableType $first $type $index knownVars
            }
        }
        alias {
            set ::knownAliases($first) $rest
        }
        nspath {
            if {$first eq "current"} {
                set first [currentNamespace]
            }
            lappend ::namespacePath($first) {*}$rest
        }
        copy {
            #echo "Copy in $::Nagelfar(firstpass) $first [lindex $rest 0]"
            CopyCmdInDatabase $first [lindex $rest 0] [lrange $rest 1 end]
        }
        nocover {
            set ::instrumenting(no,$index) 1
        }
        cover {
            if {$first ne "variable"} {

            } else {
                set varname [lindex $rest 0]
                set ::instrumenting($index) [list var $varname]
            }
        }
        ignore -
        filter {
            set line [calcLineNo $index]
            if {[regexp {^\+\d+$} $first]} {
                # Allow an offset to ignore a line further down
                incr line $first
                incr line_to $line
                set first [lindex $rest 0]
                set rest [lrange $rest 1 end]
            } elseif {[regexp {^\#(\d+)$} $first dummy range]} {
                # Allow a range of lines to ignore
                incr line
                incr line_to [expr {$line + $range - 1}]
                set first [lindex $rest 0]
                set rest [lrange $rest 1 end]
            } else {
                incr line
                incr line_to $line
            }
            switch -- $first {
                N { addFilter "N *[join $rest]*" $line $line_to }
                W { addFilter "\[NW\] *[join $rest]*" $line $line_to }
                E { addFilter "*[join $rest]*" $line $line_to }
                default { addFilter "*$first [join $rest]*" $line $line_to }
            }
        }
        varused {
            setVarUsed knownVars $first
        }
        default {
            errorMsg N "Bad type in ##nagelfar comment" $index 1
            return
        }
    }
}

# Handle a stack of current namespaces.
proc currentNamespace {} {
    lindex $::Nagelfar(namespaces) end 0
}

proc isCurrentNamespaceVirtual {} {
    return [lindex $::Nagelfar(namespaces) end 1]
}

proc getCurrentNamespaceVirtualCmd {} {
    return [lindex $::Nagelfar(namespaces) end 2]
}

proc pushNamespace {ns {is_virtual false} {virtual_cmd ""}} {
    lappend ::Nagelfar(namespaces) [list $ns $is_virtual $virtual_cmd]
}

proc popNamespace {} {
    set ::Nagelfar(namespaces) [lrange $::Nagelfar(namespaces) 0 end-1]
}

# Handle a stack of current procedures.
proc currentProc {} {
    lindex $::Nagelfar(procs) end
}

proc pushProc {p} {
    lappend ::Nagelfar(procs) $p
}

proc popProc {} {
    set ::Nagelfar(procs) [lrange $::Nagelfar(procs) 0 end-1]
}

# Handle a current object.
proc currentObject {} {
    return [lindex $::Nagelfar(object) 0]
}

proc currentObjectOrig {} {
    return [lindex $::Nagelfar(object) 1]
}

proc setCurrentObject {objname name} {
    set ::Nagelfar(object) [list $objname $name]
}

# Return the index of the first non whitespace char following index "i".
proc skipWS {str len i} {
    set j [string length [string trimleft [string range $str $i end]]]
    return [expr {$len - $j}]
}

# Scan the string until the end of one word is found.
# When entered, i points to the start of the word.
# Returns the index of the last char of the word.
proc scanWord {str len index i} {
    set si1 $i
    set si2 $i
    set c [string index $str $i]

    if {$c eq "\{"} {
        if {[string range $str $i [expr {$i + 2}]] eq "{*}"} {
            set ni [expr {$i + 3}]
            set nc [string index $str $ni]
            if {![string is space $nc]} {
                # Non-space detected, it is expansion
                set c $nc
                set i $ni
                set si2 $i
            } else {
                errorMsg N "Standalone {*} can be confused with argument expansion. I recommend \"*\"." $index
            }
        }
    }

    if {$c eq "\{"} {
        set closeChar \}
        set charType brace
    } elseif {$c eq "\""} {
        set closeChar \"
        set charType quote
    } else {
        set closeChar ""
    }

    if {$closeChar ne ""} {
        for {} {$i < $len} {incr i} {
            # Search for closeChar
            set i [string first $closeChar $str $i]
            if {$i == -1} {
                # This should never happen since no incomplete lines should
                # reach this function.
                decho "Internal error: Did not find close char in scanWord.\
                        Line [calcLineNo $index]."
                return $len
            }
            set word [string range $str $si2 $i]
            if {[info complete $word]} {
                # Check for following whitespace
                set j [expr {$i + 1}]
                set nextchar [string index $str $j]
                if {$j == $len || [string is space $nextchar]} {
                    return $i
                }
                errorMsg E "Extra chars after closing $charType." \
                        [expr {$index + $i}]
                contMsg "Opening $charType of above was on line %L." \
                        [expr {$index + $si2}]
                # Extra info for this particular case
                if {$charType eq "brace" && $nextchar eq "\{"} {
                    contMsg "It might be a missing space between \} and \{"
                }
                # Switch over to scanning for whitespace
                incr i
                break
            }
        }
    }

    for {} {$i < $len} {incr i} {
        # Search for unescaped whitespace
        if {[regexp -start $i -indices {(^|[^\\])(\\\\)*\s} $str match]} {
            set i [lindex $match 1]
        } else {
            set i $len
        }
        # any word starting with # will not work correctly in info
        # complete, but by prepending the string with "x " it works
        if {[info complete "x [string range $str $si2 $i]"]} {
            return [expr {$i - 1}]
        }
    }

    # Theoretically, no incomplete string should come to this function,
    # but some precaution is never bad.
    if {![info complete [string range $str $si2 end]]} {
        decho "Internal error in scanWord: String not complete.\
                Line [calcLineNo [expr {$index + $si1}]]."
        decho $str
        return -code break
    }
    return [expr {$i - 1}]
}

# Split a statement into words.
# Returns a list of the words, and puts a list with the indices
# for each word in indicesName.
proc splitStatement {statement index indicesName} {
    upvar $indicesName indices
    set indices {}

    set len [string length $statement]
    if {$len == 0} {
        return {}
    }
    set words {}
    set i 0
    # There should not be any leading whitespace in the string that
    # reaches this function. Check just in case.
    set i [skipWS $statement $len $i]
    if {$i != 0 && $i < $len} {
        decho "Internal error:"
        decho " Whitespace in splitStatement. [calcLineNo $index]"
    }
    # Comments should be descarded earlier
    if {[string index $statement $i] eq "#"} {
        decho "Internal error:"
        decho " A comment slipped through to splitStatement. [calcLineNo $index]"
        return {}
    }
    while {$i < $len} {
        set si $i
        lappend indices [expr {$i + $index}]
        set i [scanWord $statement $len $index $i]
        lappend words [string range $statement $si $i]
        incr i
        set i [skipWS $statement $len $i]
    }
    return $words
}

# FIXA Options may be non constant.

# Look for options in a command's arguments.
# Check them against the list in the option database, if any.
# Returns a syntax string corresponding to the number of arguments "used".
# If 'pair' is set, all options should take a value.
proc checkOptions {cmd argv wordstatus indices wordtype startI max pair} {
    global option
    ##nagelfar cover variable max

    # Special case: the first option is "--"
    if {[lindex $argv $startI] == "--"} {
        # Allowed?
        set ix [lsearch -exact $option($cmd) --]
        if {$ix >= 0} {
            return [list x]
        }
    }

    # How many is the limit imposed by the number of arguments?
    set maxArgs [expr {[llength $argv] - $startI}]

    # Pairs swallow an even number of args.
    set extraAfterPair 0
    if {$pair && ($maxArgs % 2) == 1} {
        # If the odd one is "--", it may continue
        if {[lindex $argv [expr {$startI + $maxArgs - 1}]] == "--" && \
                [lsearch -exact $option($cmd) --] >= 0} {
            # Nothing
        } else {
            set extraAfterPair 1
            incr maxArgs -1
        }
    }

    if {$max == 0 || $maxArgs < $max} {
        set max $maxArgs
    }
    if {$maxArgs == 0} {
        return {}
    }
    set check [info exists option($cmd)]
    if {!$check && $::Nagelfar(dbpicky)} {
        errorMsg N "DB: Missing options for command \"$cmd\"" 0
    }
    set i 0
    set used 0
    set skip 0
    set skipSyn x
    set replaceSyn {}
    # Since in most cases startI is 0, I believe foreach is faster.
    foreach arg $argv ws $wordstatus index $indices wType $wordtype {
        if {$i < $startI} {
            incr i
            continue
        }
        if {$skip} {
            set skip 0
            lappend replaceSyn $skipSyn
            set skipSyn x
            incr used
            continue
        }
        if {$max != 0 && $used >= $max} {
            # A special check to give a nicer message when there is
            # a missing value among pairs.
            if {$extraAfterPair} {
                if {($ws & 1) && $check} {
                    set ix [lsearch -exact $option($cmd) $arg]
                    if {$ix >= 0} {
                        set skip 1
                    }
                }
            }
            break
        }
        if {[string match "-*" $arg]} {
            incr used
            lappend replaceSyn x
            set skip $pair
            if {($ws & 1) && $check} { # Constant
                set ix [lsearch -exact $option($cmd) $arg]
                if {$ix == -1} {
                    # Check ambiguity.
                    if {![regexp {[][?*]} $arg]} {
                        # Only try globbing if $arg is free from glob chars.
                        set match [lsearch -all -inline -glob $option($cmd) $arg*]
                    } else {
                        set match {}
                    }
                    if {[llength $match] == 0} {
                        errorMsg E "Bad option $arg to \"$cmd\"" $index
                        set item ""
                    } elseif {[llength $match] > 1} {
                        errorMsg E "Ambiguous option for \"$cmd\",\
                                $arg -> [join $match /]" $index
                        set item ""
                    } else {
                        errorMsg W "Shortened option for \"$cmd\",\
                                $arg -> [lindex $match 0]" $index

                        set item "$cmd [lindex $match 0]"
                    }
                } else {
                    set item "$cmd [lindex $option($cmd) $ix]"
                }
                if {$item ne ""} {
                    if {[info exists option($item)]} {
                        set skip 1
                        if {[regexp {^[lnvc]$} $option($item)]} {
                            set skipSyn $option($item)
                        }
                    }
                }
            }
            if {$arg eq "--"} {
                set skip 0
                break
            }
        } else { # If not -*
            if {$pair && ($ws & 8)} {
                # We accept an argument expansion were a pair is expected.
                # Communicate using a special token
                lappend replaceSyn X
                # Adjust since we ate an odd argument
                if {$extraAfterPair} {
                    set extraAfterPair 0
                    incr max
                } else {
                    set extraAfterPair 1
                    incr max -1
                }
                continue
            } elseif {$max == 1 && ($ws & 8)} {
                # Special case to allow expansion with "o."
                lappend replaceSyn x
            } elseif {$wType eq "option"} {
                if {$ws & 8} {
                    # Communicate using a special token
                    lappend replaceSyn X
                } else {
                    lappend replaceSyn x
                }
                continue
            }
            break
        }
    }
    if {$skip} {
        errorMsg E "Missing value for last option." $index
    }
    #decho "options to $cmd : $replaceSyn"
    return $replaceSyn
}

# Make a list of a string. This is easy, just treat it as a list.
# But we must keep track of indices, so our own parsing is needed too.
proc splitList {str index iName wsName} {
    upvar $iName indices $wsName wordstatuses

    # Make a copy to perform list operations on
    set lstr [string range $str 0 end]

    set indices {}
    set wordstatuses {}
    if {[catch {set n [llength $lstr]}]} {
        errorMsg E "Bad list" $index
        return {}
    }
    # Parse the string to get indices for each element
    set escape 0
    set level 0
    set len [string length $str]
    set state whsp

    for {set i 0} {$i < $len} {incr i} {
        set c [string index $str $i]
        switch -- $state {
            whsp { # Whitespace
                if {[string is space $c]} continue
                # End of whitespace, i.e. a new element
                if {$c eq "\{"} {
                    set level 1
                    set state brace
                    lappend indices [expr {$index + $i + 1}]
                    lappend wordstatuses 3
                } elseif {$c eq "\""} {
                    set state quote
                    lappend indices [expr {$index + $i + 1}]
                    lappend wordstatuses 5
                } else {
                    if {$c eq "\\"} {
                        set escape 1
                    }
                    set state word
                    lappend indices [expr {$index + $i}]
                    lappend wordstatuses 1
                }
            }
            word {
                if {$c eq "\\"} {
                    set escape [expr {!$escape}]
                } else {
                    if {!$escape} {
                        if {[string is space $c]} {
                            set state whsp
                            continue
                        }
                    } else {
                        set escape 0
                    }
                }
            }
            quote {
                if {$c eq "\\"} {
                    set escape [expr {!$escape}]
                } else {
                    if {!$escape} {
                        if {$c eq "\""} {
                            set state whsp
                            continue
                        }
                    } else {
                        set escape 0
                    }
                }
            }
            brace {
                if {$c eq "\\"} {
                    set escape [expr {!$escape}]
                } else {
                    if {!$escape} {
                        if {$c eq "\{"} {
                            incr level
                        } elseif {$c eq "\}"} {
                            incr level -1
                            if {$level <= 0} {
                                set state whsp
                            }
                        }
                    } else {
                        set escape 0
                    }
                }
            }
        }
    }

    if {[llength $indices] != $n} {
        # This should never happen.
        decho "Internal error: Length mismatch in splitList.\
                Line [calcLineNo $index]."
        decho "nindices: [llength $indices]  nwords: $n"
#        decho :$str:
        foreach l $lstr ix $indices {
            decho :$ix:[string range $l 0 10]:
        }
    }
    return $lstr
}

# Parse a variable name, check for existence
# This is called when a $ is encountered
# "i" points to the first char after $
# Returns the type of the variable
proc parseVar {str len index iName knownVarsName} {
    upvar $iName i $knownVarsName knownVars
    set si $i
    set c [string index $str $si]

    if {$c eq "\{"} {
        # A variable ref starting with a brace always ends with next brace,
        # no exceptions that I know of
        incr si
        set ei [string first "\}" $str $si]
        if {$ei == -1} {
            # This should not happen.
            errorMsg E "Could not find closing brace in variable reference." \
                    $index
        }
        set i $ei
        incr ei -1
        set var [string range $str $si $ei]
        set vararr 0
        # check for an array
        if {[string index $str $ei] eq ")"} {
            set pi [string first "(" $str $si]
            if {$pi != -1 && $pi < $ei} {
                incr pi -1
                set var [string range $str $si $pi]
                incr pi 2
                incr ei -1
                set varindex [string range $str $pi $ei]
                set vararr 1
                set varindexconst 1
            }
        }
    } else {
        for {set ei $si} {$ei < $len} {incr ei} {
            set c [string index $str $ei]
            if {[string is wordchar $c]} continue
            # :: is ok.
            if {$c eq ":"} {
                set c [string index $str [expr {$ei + 1}]]
                if {$c eq ":"} {
                    incr ei
                    continue
                }
            }
            break
        }
        if {[string index $str $ei] eq "("} {
            # Locate the end of the array index
            set pi $ei
            set apa [expr {$si - 1}]
            while {[set ei [string first ")" $str $ei]] != -1} {
                if {[info complete [string range $str $apa $ei]]} {
                    break
                }
                incr ei
            }
            if {$ei == -1} {
                # This should not happen.
                errorMsg E "Could not find closing parenthesis in variable\
                        reference." $index
                return
            }
            set i $ei
            incr pi -1
            set var [string range $str $si $pi]
            incr pi 2
            incr ei -1
            set varindex [string range $str $pi $ei]
            set vararr 1
            set varindexconst [parseSubst $varindex \
                    [expr {$index + $pi}] type knownVars]
        } else {
            incr ei -1
            set i $ei
            set var [string range $str $si $ei]
            set vararr 0
        }
    }

    # By now:
    # var is the variable name
    # vararr is 1 if it is an array
    # varindex is the array index
    # varindexconst is 1 if the array index is a constant

    if {$var == ""} {
        return ""
    }

    # Allow a plugin to have a look at the variable read
    if {$::Nagelfar(pluginVarRead)} {
        pluginHandleVarRead var knownVars $index
    }
    setVarUsed knownVars $var
    if {$vararr} {
	setVarUsed knownVars $var\($varindex\)
    }

    if {[string match ::* $var]} {
        # Skip qualified names until we handle namespace better. FIXA
        # Handle types for constant names
        if {!$vararr} {
            set full $var
        } elseif {$varindexconst} {
            set full ${var}($varindex)
        } else {
            set full ""
        }
        if {$full ne "" && [dict exists $knownVars $full]} {
            return [dict get $knownVars $full "type"]
        }
        return ""
    }
    # FIXA: Use markVariable
    if {[dict exists $knownVars $var] &&
        [dict get $knownVars $var array] ne ""} {
        if {$vararr != [dict get $knownVars $var array]} {
            if {$vararr} {
                errorMsg E "Is array, was scalar" $index
            } else {
                errorMsg E "Is scalar, was array" $index
            }
        }
    }
    if {![dict exists $knownVars $var] && !$::Prefs(noVar)} {
        if {[string match "*::*" $var]} {
            set tail [namespace tail $var]
            set ns [namespace qualifiers $var]
            #decho "'$var' '$ns' '$tail'"
            if {![dict exists $knownVars $tail] || \
                    [dict get $knownVars $tail local] || \
                    ([dict get $knownVars $tail namespace] ne $ns && \
                    [dict get $knownVars $tail namespace] ne "::$ns")} {
                if {[currentProc] eq ""} {
                    # We cannot check namespace variables in a proc.
                    # TBD: Can we ever?
                    errorMsg E "Unknown variable \"$var\"" $index 1
                }
            }
        } else {
            errorMsg E "Unknown variable \"$var\"" $index 1
        }
    }
    if {[dict exists $knownVars $var] && ![dict get $knownVars $var set]} {
        # It was read before it was set (within this scope)
        dict set knownVars $var read 1
    }
    if {$vararr && [dict exists $knownVars $var\($varindex\)] &&
        [dict get $knownVars $var\($varindex\) "type"] ne ""} {
        return [dict get $knownVars $var\($varindex\) "type"]
    }
    if {[dict exists $knownVars $var] &&
        [dict get $knownVars $var "type"] ne ""} {
        return [dict get $knownVars $var "type"]
    }
    return ""
    # Make use of markVariable. FIXA
    # If it's a constant array index, maybe it should be checked? FIXA
}

# Check for substitutions in a word
# Check any variables referenced, and parse any commands within brackets.
# Returns 1 if the string is constant, i.e. no substitutions
# Returns 0 if any substitutions are present
proc parseSubst {str index typeName knownVarsName} {
    upvar $typeName type $knownVarsName knownVars

    set type ""

    # First do a quick check for $ or [
    # If the word ends in "]" and there is no "[" it is considered
    # suspicious and we continue checking.
    if {[string first \$ $str] == -1 && [string first \[ $str] == -1 && \
            [string index $str end] ne "\]" && \
            [string index $str end] ne "\""} {
        return 1
    }

    set result 1
    set len [string length $str]
    set escape 0
    set notype 0
    set types {}
    set braces 0
    for {set i 0} {$i < $len} {incr i} {
        set c [string index $str $i]
        if {$c eq "\\"} {
            set escape [expr {!$escape}]
            set notype 1
        } elseif {!$escape} {
            if {$c eq "\$"} {
                incr i
                lappend types [parseVar $str $len $index i knownVars]
                set result 0
            } elseif {$c eq "\["} {
                set si $i
                for {} {$i < $len} {incr i} {
                    # FIXA: error => complete
                    if {[info complete [string range $str $si $i]]} {
                        break
                    }
                }
                if {$i == $len} {
                    decho "Internal error: Did not find close bracket in parseSubst.\
                            Line [calcLineNo $index]"
                }
                incr si
                incr i -1
                set body [string range $str $si $i]
                lappend types [parseBody $body \
                        [expr {$index + $si}] knownVars 1]
                incr i
                set result 0
            } else {
                set notype 1
                if {$c eq "\]" && $i == ($len - 1)} {
                    # Note unescaped bracket at end of word since it's
                    # likely to mean it should not be there.
                    errorMsg N "Unescaped end bracket" [expr {$index + $i}]
                } elseif {$c eq "\"" && $i == ($len - 1)} {
                    # Note unescaped quote at end of word since it's
                    # likely to mean it should not be there.
                    errorMsg N "Unescaped quote" [expr {$index + $i}]
                } elseif {$c eq "\{"} {
                    incr braces
                    # Unescaped brace in a word is suspicious
                    #errorMsg N "Unescaped brace" [expr {$index + $i}]
                } elseif {$c eq "\}"} {
                    incr braces -1
                    # Unescaped brace in a word is suspicious
                    if {$braces < 0} {
                        errorMsg N "Unescaped close brace" [expr {$index + $i}]
                    }
                }
            }
        } else {
            set escape 0
            set notype 1
        }
    }
    if {!$notype && [llength $types] == 1} {
        set type [lindex $types 0]
    }
    return $result
}

# Parse an expression
proc parseExpr {str index knownVarsName} {
    upvar $knownVarsName knownVars

    # Allow a plugin to have a look at the expression before substitution
    if {$::Nagelfar(pluginEarlyExpr)} {
        pluginHandleEarlyExpr str knownVars $index
    }

    # First do a quick check for $ or [
    if {[string first "\$" $str] == -1 && [string first "\[" $str] == -1} {
        set exp $str
    } else {
        # This is similar to parseSubst, just that it also check for braces
        set exp ""
        set result 1
        set len [string length $str]
        set escape 0
        set brace 0
        for {set i 0} {$i < $len} {incr i} {
            set c [string index $str $i]
            if {$c eq "\\"} {
                set escape [expr {!$escape}]
            } elseif {!$escape} {
                if {$c eq "\{"} {
                    incr brace
                } elseif {$c eq "\}"} {
                    if {$brace > 0} {
                        incr brace -1
                    }
                } elseif {$brace == 0} {
                    if {$c eq "\$"} {
                        incr i
                        parseVar $str $len $index i knownVars
                        append exp {${_____}}
                        continue
                    } elseif {$c eq "\["} {
                        set si $i
                        for {} {$i < $len} {incr i} {
                            if {[info complete [string range $str $si $i]]} {
                                break
                            }
                        }
                        if {$i == $len} {
                            errorMsg E "Missing close bracket at end of expression" $index
                        }
                        incr si
                        incr i -1
                        # Warn if the called command is expr
                        set body [string range $str $si $i]
                        if {[string match "expr*" $body]} {
                            errorMsg N "Expr called in expression" \
                                    [expr {$index + $si}]
                        }
                        parseBody $body [expr {$index + $si}] knownVars 1
                        incr i
                        append exp {${_____}}
                        continue
                    }
                }
            } else {
                set escape 0
            }
            append exp $c
        }
    }

    # Allow a plugin to have a look at the expression after substitution
    if {$::Nagelfar(pluginLateExpr)} {
        pluginHandleLateExpr exp knownVars $index
    }

    # The above have replaced any variable substitution or command
    # substitution in the expression by "${_____}"
    set _____ 1

    # This uses [expr] to do the checking which means that the checking
    # can't recognise anything that differs from the Tcl version Nagelfar
    # is run with. For example, the new operators in 8.4 "eq" and "ne"
    # will be accepted even if the database was generated using an older
    # Tcl version.  A small problem and hard to fix, so I'm ignoring it.

    if {[catch [list expr $exp] msg]} {
        regsub {syntax error in expression.*:\s+} $msg {} msg
        # Divide by zero can happen due to the substitutions above
        # but should normally not be caused by a syntax error
        if {[string match "*divide by zero*" $msg]} return
        # Another messages that means similar things
        if {[string match "*square root of negative argument*" $msg]} return
        if {[string match "*domain error: argument not in valid range*" $msg]} return

        # Invalid command name, look it up...
        if {[regexp {invalid command name "(.*)"} $msg -> cmdName]} {
            # FIXA: checking number of arguments to user defined functions?
            # It would need manual parsing of some kind though
            lookForCommand $cmdName [currentNamespace] $index
            return
        }

        errorMsg E "Bad expression: $msg" $index
    }
}

# This is to detect bad comments in constant lists.
# This will cause messages if there are comments in blocks
# that are not recognised as code.
proc checkForComment {word index} {
    # Check for "#"
    set si 0
    while {[set si [string first \# $word $si]] >= 0} {
        # Is it first in a line?
        if {[string index $word [expr {$si - 1}]] eq "\n"} {
            errorMsg N "Suspicious \# char. Possibly a bad comment." \
                    [expr {$index + $si}]
            break
        }
        incr si
    }
}

# List version of checkForComment
proc checkForCommentL {words wordstatus indices} {
    foreach word $words ws $wordstatus i $indices {
        if {$ws & 2} { # Braced
            checkForComment $word $i
        }
    }
}

# A "macro" for checkCommand/parseStatement to print common error message
# It should not be called from anywhere else.
proc WA {{debug {}}} {
    upvar 1 "cmd" cmd "index" index "argc" argc "argv" argv "indices" indices
    upvar 1 "expandWords" expandWords
    # Suppress message if expansions are present. We cannot know.
    if {[llength $expandWords] > 0} {
        return
    }
    errorMsg E "Wrong number of arguments ($argc) to \"$cmd\"$debug" $index 1

    set t 1
    set line [calcLineNo $index]
    foreach ix $indices {
        set aline [calcLineNo $ix]
        if {$aline != $line} {
            contMsg "Argument $t at line $aline"
        }
        incr t
    }
}

# Take a syntax token and extract all parts
proc SplitToken {token tokName tokCountName typeName modName lenName fromName} {
    upvar 1 $tokName tok $tokCountName tokCount $typeName type $modName mod \
            $lenName len $fromName from
    set mod ""
    set tokCount ""
    set type ""
    set tok _baad_
    set len 1
    set from ""

    if {[regexp {^(\w+)\((.*)\)$} $token -> tokL type]} {
        # Type in parenthesis
    } elseif {[regexp {^(\w+)\((.*)\)(\W.*)$} $token -> tokL type mod]} {
        # Type in parenthesis, with modifier
    } elseif {[regexp {^(\w+?)(\d*)(\W.*)?$} $token -> tokL tokCount mod]} {
        # Normal format
    } else {
        #echo "Unsupported token '$token'"
        return
    }
    # Look for the "=xx" part of a modifier
    if {[regexp {^=(.+?)(\W*)$} $mod -> m1 m2]} {
        set from $m1
        set mod $m2
    }

    set tok $tokL
    # Some tokens eat multiple arguments
    switch $tokL {
        dp - dm - dmp { set len 3 }
        dk - p - cv { set len 2 }
    }
}

# Some heuristics when non-braced non constant code is found
proc checkNonConstantCode {cmd arg tok type index} {
    # Special case: [list ...]
    if {[string match {\[list*} $arg]} {
        # FIXA: Check the code
        #echo "(List code)"
        return
    }
    # Special case: single variable
    if {[regexp {^\$[\w:]+$} $arg]} {
        return
    }

    # A specific type called "script" annotates a command that is known
    # to build valid code. E.g. mymethod in Snit.
    if {$type eq "script"} {
        return
    }

    if {$tok eq "c" || $tok eq "cv"} {
        # FIXA: Handle other common methods to construct code?

        errorMsg N "No braces around code in $cmd statement." $index
    }
}

# Check a command that have a syntax defined in the database
# 'firsti' says at which index in argv et.al. the arguments begin.
# Returns the return type of the command
# This is a helper for parseStatement, it should not be called from
# anywhere but checkCommand/parseStatement
proc checkCommand {cmd index argv wordstatus wordtype indices \
                   expandWords {firsti 0}} {
    upvar 1 "constantsDontCheck" constantsDontCheck "knownVars" knownVars

    set argc [llength $argv]
    set syn $::syntax($cmd)
    set type ""
    if {[info exists ::return($cmd)]} {
        set type $::return($cmd)
        #puts T:$cmd:$type
    }
    #puts "Checking $cmd ([lindex $argv]) against syntax $syn"

    # Check if the syntax definition has multiple entries
    # Extract the valid one and continue as normal below
    if {[string index [lindex $syn 0] end] == ":"} {
        set na [expr {$argc - $firsti}]
        set newsyn {}
        set state search
        foreach tok $syn {
            if {$state == "search"} {
                if {$tok == ":" || $tok == "${na}:"} {
                    set state copy
                }
            } elseif {$state == "copy"} {
                if {[string index $tok end] == ":"} {
                    break
                }
                lappend newsyn $tok
            }
        }
        if {[llength $newsyn] == 0} {
            echo "Can't parse syntax definition for \"$cmd\": \"$syn\""
            return $type
        }
        set syn $newsyn
    }

    # An integer token directly specifies number of arguments
    if {[string is integer -strict $syn]} {
        if {($argc - $firsti) != $syn} {
            WA
        }
        checkForCommentL $argv $wordstatus $indices
        return $type
    } elseif {[lindex $syn 0] eq "r"} {
        # A range of number of arguments
        if {($argc - $firsti) < [lindex $syn 1]} {
            WA
        } elseif {[llength $syn] >= 3 && ($argc - $firsti) > [lindex $syn 2]} {
            WA
        }
        checkForCommentL $argv $wordstatus $indices
        return $type
    }

    # Calculate the minimum number of arguments needed by non-optional
    # tokens. If this is the same number as the actual arguments, we
    # know that no optional tokens may consume anything.
    # This prevents e.g. options checking on arguments that cannot be
    # options due to their placement.

    if {![info exists ::cacheMinArgs($syn)]} {
        set minargs 0
        set minargsend 0
        set optSeen 0
        set i 0
        set last [llength $syn]
        foreach token $syn {
            SplitToken $token _ _ _ mod tokLen _
            incr i

            if {$mod eq ""} {
                # Count mandatory args
                incr minargs $tokLen
                if {$optSeen} {
                    incr minargsend $tokLen
                }
            } else {
                # Note an optional, start counting end args
                set minargsend 0
                set optSeen 1
            }
        }
        # Number of mandatory args at end
        set ::cacheEndArgs($syn) $minargsend
        # Number of mandatory args
        set ::cacheMinArgs($syn) $minargs
    }
    set anyOptional  [expr {($argc - $firsti) > $::cacheMinArgs($syn)}]
    # Points at last optional + 1. I.e. an exclusive end-of-range
    # In other words it points to the first of final mandatory args.
    set lastOptional [expr {$argc - $::cacheEndArgs($syn)}]

    # Treat syn as a stack. That way a token can replace itself without
    # increasing i and thus hand over checking to another token.

    set i $firsti
    while {[llength $syn] > 0} {
        # Pop first token from stack
        set token [lindex $syn 0]
        set syn [lrange $syn 1 end]

        # Look for multi token.
        # A multi token is separated by & and always has a modifier.
        if {[string match "*&*" $token]} {
            set mod [string index $token end]
            set newToks [split [string range $token 0 end-1] "&"]
            if {$mod ni {* ?}} {
                echo "Modifier \"$mod\" is not supported for \"$syn\" in\
                            syntax for \"$cmd\"."
            }
            set room [expr {$lastOptional - $i}]
            if {!$anyOptional || $room < [llength $newToks]} continue
            # Feed back tokens to the stack
            if {$mod eq "*"} {
                # Include the multi-token if it repeats
                set syn [linsert $syn 0 {*}$newToks $token]
            } else {
                set syn [linsert $syn 0 {*}$newToks]
            }
            continue
        }

        SplitToken $token tok tokCount _ mod tokLen tokFrom
        # Is it optional and there can't be any optional?
        if {$mod ne "" && !$anyOptional} {
            continue
        }
        # Basic checks for modifiers
        switch -- $mod {
            "" { # No modifier, and out of arguments, is an error
                if {$i >= $argc} {
                    set i -1
                    break
                }
            }
            "*" { # No more arguments is ok.
                if {$i >= $argc} {
                    set i $argc
                    break
                }
                # Supported by token?
                if {$tok ni {x xComm div nl l v n o p}} {
                    echo "Modifier \"$mod\" is not supported for \"$tok\" in\
                            syntax for \"$cmd\"."
                }
            }
            "." { # No more arguments is ok.
                if {$i >= $argc} {
                    set i $argc
                    break
                }
                # Supported by all tokens since the above check is all needed
            }
            "?" { # No more optional arguments is ok.
                if {$i >= $lastOptional} {
                    continue
                }
                # Supported by all tokens since the above check is all needed
            }
            default {
                echo "Unsupported token \"$token\" in syntax for \"$cmd\""
            }
        }

        # Common init
        # ei is an exclusive end-of-range for indexes covered by this token
        set ei [expr {$i + 1}]
        if {$mod eq "*"} {
            set ei $lastOptional
        }

        # Just skip the rest if expansion is encountered
        if {[llength $expandWords] > 0 && $i >= [lindex $expandWords 0]} {
            # Special token "X" means it should eat an expanded word.
            set skip 1
            if {$i == [lindex $expandWords 0]} {
                if {$tok eq "X"} {
                    set expandWords [lrange $expandWords 1 end]
                    incr i
                    continue
                }
                if {$tok in "o p"} {
                    # Fall down to option parsing
                    set skip 0
                }
            }
            if {$skip} {
                #errorMsg N "Skipping $i due to expand" [lindex $indices $i]
                set i $argc
                break
            }
        }

        # Main token interpretation
        switch -- $tok {
            x - X - xComm {
                # X is a special token to eat an expanded word. Handled above.
                # xComm is a special token used internally to handle if 0 as
                # a comment. xComm will not be investigated for inline comments

                set li [expr {$ei - 1}]
                if {$tok != "xComm"} {
                    checkForCommentL [lrange $argv $i $li] \
                            [lrange $wordstatus $i $li] \
                            [lrange $indices $i $li]
                }
                set i $ei
            }
            div { # Define implicit variable for this namespace
                set currNs [currentNamespace]
                while {$i < $ei} {
                    set var [lindex $argv $i]
                    lappend ::implicitVarNs($currNs) $var
                    lappend constantsDontCheck $i
                    incr i
                }
            }
            di { # Define inheritance, acts as if * was there
                while {$i < $ei} {
                    # Superclass
                    set superclass [lindex $argv $i]
                    set superObjCmd _obj,[namespace tail $superclass]
                    set objcmd [currentObject]
                    set copymap [list $objcmd $superObjCmd]
                    if {[string match *::superclass $cmd]} {
                        #puts "DI: '$superObjCmd' to '$objcmd' map '$copymap'"
                        set ::superclass($objcmd) [list $superclass $superObjCmd]
                    } else {
                        #puts stderr "* $cmd *"
                    }
                    CopyCmdInDatabase $superObjCmd $objcmd $copymap
                    incr i
                }
            }
            dc - do { # Define with copy / define object
                # dc defines a command that is a copy. Typically used for an
                # instance which is a copy of the class's object command.
                # do defines both a command to instantiate objects and a
                # corresponding object command
                #decho "$tok $tokCount $mod"
                if {([lindex $wordstatus $i] & 1) == 0} { # Non constant
                    errorMsg N "Non constant definition \"[lindex $argv $i]\".\
                            Skipping." [lindex $indices $i] 1
                } else {
                    set copyFrom $tokFrom
                    set name [lindex $argv $i]
                    #decho "Defining '$name', from '$copyFrom'"
                    if {$name eq "%AUTO%"} {
                        # No definition should be made
                    } else {
                        if {[string match "::*" $name]} {
                            set name [string range $name 2 end]
                        }
                        if {$tok eq "do"} { # Define object
                            set objname _obj,[namespace tail $name]
                            #echo "Defining object $name"
                            setCurrentObject $objname $name

                            # Special case when defining an object in tcloo
                            # Add an alias to make "my" an object
                            if {[string match oo::* $cmd]} {
                                # The construct of this should match how a
                                # virtual namespace context is named.
                                set ::knownAliases(${cmd}::${name}::my) $objname
                            }

                            if {![info exists ::syntax($objname)]} {
                                set ::syntax($objname) "s x*"
                            }
                            if {$copyFrom ne ""} {
                                set copymap [list _obj,$copyFrom $objname]
                                CopyCmdInDatabase $copyFrom $name    $copymap
                                CopyCmdInDatabase $copyFrom $objname $copymap
                            } else {
                                lappend ::knownCommands $objname
                            }
                        } else {
                            if {$copyFrom ne ""} {
                                CopyCmdInDatabase $copyFrom $name
                            } else {
                                lappend ::knownCommands $name
                                if {![info exists ::syntax($name)]} {
                                    set ::syntax($name) "x*"
                                }
                            }
                        }
                        if {$tok eq "do" && ![info exists ::syntax($name)]} {
                            set ::syntax($name) "s x*"
                        }
                    }
                }
                incr i
            }
            dk -
            dd -
            dp -
            dm -
            dmp { # Define proc and/or method
                if {$tok eq "dd"} { # One arg
                    if {$i > ($argc - 1)} {
                        break
                    }
                    set iplus2 [expr {$i + 0}]
                } elseif {$tok eq "dk"} { # Two args
                    if {$i > ($argc - 2)} {
                        break
                    }
                    set iplus2 [expr {$i + 1}]
                } else {
                    if {$i > ($argc - 3)} {
                        break
                    }
                    set iplus2 [expr {$i + 2}]
                }
                # Skip the proc if any part of it is not constant
                # FIXA: Maybe accept substitutions as part of namespace?
                foreach ws [lrange $wordstatus $i $iplus2] {
                    if {($ws & 1) == 0} {
                        errorMsg N "Non constant argument to proc \"[lindex $argv $i]\".\
                                Skipping." $index
                        return
                    }
                }
                if {$::Nagelfar(gui)} {progressUpdate [calcLineNo $index]}
                # Do not check proc/method name against variables
                lappend constantsDontCheck $i
                set isProc [expr {$tok eq "dp" || $tok eq "dmp"}]
                set isMethod [expr {$tok eq "dm" || $tok eq "dmp"}]
                if {$tok eq "dd"} { # One args
                    set procArgV [lrange $argv $i $iplus2]
                    set indicesV [lrange $indices $i $iplus2]
                    set constructorCmd "[currentObjectOrig] destructor"
                    set procArgV [linsert $procArgV 0 ::$constructorCmd {}]
                    set indicesV [linsert $indicesV 0 [lindex $indices $i] [lindex $indices $i]]
                    incr i 1
                } elseif {$tok eq "dk"} { # Two args
                    set procArgV [lrange $argv $i $iplus2]
                    set indicesV [lrange $indices $i $iplus2]
                    set constructorCmd "[currentObjectOrig] new"
                    # Suppress redefinition warnings
                    unset -nocomplain ::syntax($constructorCmd)
                    set procArgV [linsert $procArgV 0 ::$constructorCmd]
                    set indicesV [linsert $indicesV 0 [lindex $indices $i]]
                    #puts "DK: $procArgV"
                    incr i 2
                    set synConstr [parseProc $procArgV $indicesV 0 0 $cmd]
                    set ::syntax($constructorCmd) $synConstr
		    # tcl::oo also knows the create constructor with a name
		    # for the new object:
                    set constructorCmd "[currentObjectOrig] create"
                    unset -nocomplain ::syntax($constructorCmd)
		    set objtype "_obj,[currentObjectOrig]"
		    if {[string is integer $synConstr]} {
			set synConstr "dc=$objtype [string repeat "x " $synConstr]"
		    } else {
			set synConstr "dc=$objtype $synConstr"
		    }
                    set ::syntax($constructorCmd) $synConstr
                } else {
                    set procArgV [lrange $argv $i $iplus2]
                    set indicesV [lrange $indices $i $iplus2]
                    incr i 3
                    parseProc $procArgV $indicesV \
                            $isProc $isMethod $cmd
                }
            }
            E -
            e { # An expression
                if {([lindex $wordstatus $i] & 1) == 0} { # Non constant
                    if {$tok == "E"} {
                        errorMsg W "No braces around expression in\
                                $cmd statement." [lindex $indices $i]
                    } elseif {$::Prefs(warnBraceExpr)} {
                        # Allow pure command substitution if warnBraceExpr == 1
                        if {$::Prefs(warnBraceExpr) == 2 || \
                                [string index [lindex $argv $i] 0] != "\[" || \
                                [string index [lindex $argv $i] end] != "\]" } {
                            errorMsg W "No braces around expression in\
                                    $cmd statement." [lindex $indices $i]
                        }
                    }
                } elseif {[lindex $wordstatus $i] & 2} { # Braced
                    # FIXA: This is not a good check in e.g. a catch.
                    #checkForComment [lindex $argv $i] [lindex $indices $i]
                }
                parseExpr [lindex $argv $i] [lindex $indices $i] knownVars
                incr i
            }
            c - cg - cl - cn { # A code block
                if {([lindex $wordstatus $i] & 1) == 0} { # Non constant
                    # No braces around non constant code.
                    checkNonConstantCode $cmd [lindex $argv $i] $tok \
                            [lindex $wordtype $i] [lindex $indices $i]
                } else {
                    set body [lindex $argv $i]
                    if {$tokCount ne ""} {
                        # The appended value couldn't be e.g. 'x' in case
                        # the surrounding code has a variable named x.
                        append body [string repeat " ___" $tokCount]
                    }
                    # Special fix to support bind's "+".
                    if {$tok eq "cg" && [string match "+*" $body] && \
                            $cmd eq "bind"} {
                        set body [string range $body 1 end]
                        set ixAfter [expr {[lindex $indices $i] + 1}]
                        # Instrument after the +
                        instrument $ixAfter 1 $body
                    } elseif {$tok ne "cn"} {
                        # A virtual namespace should not be instrumented.
                        instrumentL $indices $argv $i
                    }
                    if {$tok eq "cg"} {
                        # Check in global context
                        pushNamespace {}
                        set dummyVars {}
                        parseBody $body [lindex $indices $i] dummyVars
                        popNamespace
                    } elseif {$tok eq "cn"} {
                        # Check in virtual namespace context
                        set vNs ${cmd}::[join [lrange $argv $firsti [expr {$i-1}]] ::]
                        # Avoid :::: if a full qualified name is used
                        set vNs [string map {:::: ::} $vNs]
                        #puts "cmd '$cmd' vNs '$vNs'"
                        pushNamespace $vNs true $cmd
                        set dummyVars {}
                        parseBody $body [lindex $indices $i] dummyVars
                        popNamespace
                    } elseif {$tok eq "cl"} {
                        #puts "Checking '$body' in local context"
                        # Check in local context
                        if {![info exists locCtxVars]} {
                            set locCtxVars {}
                        }
                        addImplicitVariablesNs $cmd [lindex $indices $i] locCtxVars
                        parseBody $body [lindex $indices $i] locCtxVars
			checkForUnusedVar locCtxVars [lindex $indices $i]
                    } else {
                        parseBody $body [lindex $indices $i] knownVars
                    }
                }
                incr i
            }
            cv { # A code block with a variable definition and local context
                # Needs two args
                if {$i > ($argc - 2)} {
                    break
                }
                if {![info exists locCtxVars]} {
                    set locCtxVars {}
                }
                if {([lindex $wordstatus $i] & 1) != 0} {
                    # Constant var list, parse it to get all vars
                    parseArgs [lindex $argv $i] [lindex $indices $i] "" \
                            locCtxVars
                } else {
                    # Non constant var list, what to do? FIXA
                }
                addImplicitVariablesNs $cmd [lindex $indices $i] locCtxVars
                # Handle Code part
                incr i
                if {([lindex $wordstatus $i] & 1) == 0} { # Non constant
                    # No braces around non constant code.
                    checkNonConstantCode $cmd [lindex $argv $i] $tok \
                            [lindex $wordtype $i] [lindex $indices $i]
                } else {
                    set body [lindex $argv $i]
                    if {$tokCount ne ""} {
                        append body [string repeat " x" $tokCount]
                    }
                    instrumentL $indices $argv $i

                    # Check in local context
                    #puts "Cmd '$cmd' NS '[currentNamespace]'"
                    parseBody $body [lindex $indices $i] locCtxVars
		    checkForUnusedVar locCtxVars [lindex $indices $i]
                }
                incr i
            }
            s { # A subcommand
                lappend constantsDontCheck $i
                if {([lindex $wordstatus $i] & 1) == 0} { # Non constant
                    errorMsg N "Non static subcommand to \"$cmd\"" \
                            [lindex $indices $i]
                } else {
                    set arg [lindex $argv $i]
                    if {[info exists ::subCmd($cmd)]} {
                        if {[lsearch $::subCmd($cmd) $arg] == -1} {
                            set ix [lsearch -glob $::subCmd($cmd) $arg*]
                            if {$ix == -1} {
                                errorMsg E "Unknown subcommand \"$arg\" to \"$cmd\""\
                                        [lindex $indices $i]
                            } else {
                                # Check ambiguity.
                                set match [lsearch -all -inline -glob \
                                        $::subCmd($cmd) $arg*]
                                if {[llength $match] > 1} {
                                    errorMsg E "Ambiguous subcommand for\
                                            \"$cmd\", $arg ->\
                                            [join $match /]" \
                                            [lindex $indices $i]
                                } elseif {$::Prefs(warnShortSub)} {
                                    # Report shortened subcmd?
                                    errorMsg W "Shortened subcommand for\
                                            \"$cmd\", $arg ->\
                                            [lindex $match 0]" \
                                            [lindex $indices $i]
                                }
                                set arg [lindex $::subCmd($cmd) $ix]
                            }
                        }
                    } elseif {$::Nagelfar(dbpicky)} {
                        errorMsg N "DB: Missing subcommands for \"$cmd\"" 0
                    }
                    # Are there any syntax definition for this subcommand?
                    set sub "$cmd $arg"
                    if {[info exists ::syntax($sub)]} {
                        set stype [checkCommand $sub $index $argv $wordstatus \
                                $wordtype \
                                $indices $expandWords [expr {$i + 1}]]
                        if {$stype != ""} {
                            set type $stype
                        }
                        set i $argc
                        break
                    } elseif {$::Nagelfar(dbpicky)} {
                        errorMsg N "DB: Missing syntax for subcommand $sub" 0
                    }
                }
                incr i
            }
            nl -
            l -
            v -
            n { # A call by name
                set typeFromToken $tokFrom
                set isArray unknown
                if {$typeFromToken eq "array"} {
                    set isArray yes
                } elseif {$typeFromToken eq "scalar"} {
                    set isArray known
                }
                while {$i < $ei} {
                    if {$tok eq "v"} {
                        # Check the variable
                        set var [lindex $argv $i]
                        # Allow a plugin to have a look at the variable read
                        if {$::Nagelfar(pluginVarRead)} {
                            pluginHandleVarRead var knownVars $index
                        }
			setVarUsed knownVars $var
                        if {[string match ::* $var]} {
                            # Skip qualified names until we handle
                            # namespace better. FIXA
                        } elseif {[markVariable $var \
                                [lindex $wordstatus $i] [lindex $wordtype $i] \
                                2 [lindex $indices $i] $isArray \
                                knownVars vtype]} {
                            if {!$::Prefs(noVar)} {
                                errorMsg E "Unknown variable \"$var\""\
                                        [lindex $indices $i] 1
                            }
                        }
                    } elseif {$tok eq "n"} {
                        markVariable [lindex $argv $i] \
                                [lindex $wordstatus $i] [lindex $wordtype $i] 1 \
                                [lindex $indices $i] $isArray knownVars ""
                    } elseif {$tok eq "nl"} {
                        set ws [lindex $wordstatus $i]
                        if {($ws & 1) == 0} {
                            errorMsg N "Non constant variable list." \
                                    [lindex $indices $i]
                        } else {
                            foreach varName [lindex $argv $i] {
                                markVariable $varName \
                                        $ws [lindex $wordtype $i] 1 \
                                        [lindex $indices $i] $isArray knownVars ""
                            }
                        }
                    } else {
                        # Mark it as just known. This does not trigger plugin
                        markVariable [lindex $argv $i] \
                                [lindex $wordstatus $i] [lindex $wordtype $i] 0 \
                                [lindex $indices $i] $isArray knownVars ""

			# not strictly speaking used but info exists etc
			# may cause a lot of false-positive without this
			set var [lindex $argv $i]
			set varBase [lindex [split [lindex $argv $i] "("] 0]
			setVarUsed knownVars $varBase
			if {$var ne $varBase} {
			    setVarUsed knownVars $var
			}
		    }

                    lappend constantsDontCheck $i
                    incr i
                }
            }
            o {
                set max [expr {$ei - $i}]
                set oSyn [checkOptions $cmd $argv $wordstatus $indices $wordtype \
                                  $i $max 0]
                set used [llength $oSyn]
                if {$used == 0 && ($mod == "" || $mod == ".")} {
                    errorMsg E "Expected an option as argument $i to \"$cmd\"" \
                            [lindex $indices $i]
                    return $type
                }

                if {[lsearch -not $oSyn "x"] >= 0} {
                    # Feed the syntax back into the check loop
                    set syn [concat $oSyn $syn]
                } else {
                    incr i $used
                }
            }
            p {
                set max [expr {$ei - $i}]
                if {$max < 2} {
                    set max 2
                }
                set oSyn [checkOptions $cmd $argv $wordstatus $indices $wordtype \
                                  $i $max 1]
                set used [llength $oSyn]
                if {$used == 0 && ($mod == "" || $mod == ".")} {
                    errorMsg E "Expected an option as argument $i to \"$cmd\"" \
                            [lindex $indices $i]
                    return $type
                }
                if {[lsearch -not $oSyn "x"] >= 0} {
                    # Feed the syntax back into the check loop
                    set syn [concat $oSyn $syn]
                } else {
                    incr i $used
                }
            }
            re {
                # Check only constant
                if {([lindex $wordstatus $i] & 1) != 0} {
                    set re [lindex $argv $i]
                    if {[catch [list regexp -- $re "test"] msg]} {
                        errorMsg E "Bad regexp: $msg" $index
                    }
                }
                incr i
            }
            default {
                echo "Unsupported token \"$token\" in syntax for \"$cmd\""
            }
        } ;# End switch Main token interpretation
    } ; # End while
    # Have we used up all arguments?
    if {$i != $argc} {
        WA
    }
    return $type
}

# Central function to handle known variable names.
# If check is 2, check if it is known, return 1 if unknown
# If check is 1, mark the variable as known and set
# If check is 1n, mark the variable as known and set, but do not trigger plugin
# If check is 0, mark the variable as known
proc markVariable {var ws wordtype check index isArray knownVarsName typeName} {
    upvar $knownVarsName knownVars
    if {$typeName ne ""} {
        upvar $typeName type
    } else {
        set type ""
    }
    if {$check eq "1n"} {
        set check 1
    } elseif {$check == 1} {
        # Allow a plugin to have a look at the variable written
        if {$::Nagelfar(pluginVarWrite)} {
            pluginHandleVarWrite var knownVars $index
        }
    }

    set varBase $var
    set varArray 0
    set varIndex ""
    set varBaseWs $ws
    set varIndexWs $ws

    # is it an array?
    set i [string first "(" $var]
    if {$i != -1} {
        incr i -1
        set varBase [string range $var 0 $i]
        incr i 2
        set varIndex [string range $var $i end-1]
        # Check if the base is free from substitutions
        if {($varBaseWs & 1) == 0 && [regexp {^(::)?(\w+(::)?)+$} $varBase]} {
            set varBaseWs 1
        }
        set varArray 1
    }

    # If the base contains substitutions it can't be checked.
    if {($varBaseWs & 1) == 0} {
        # Experimental foreach check FIXA
        if {[string match {$*} $var]} {
            set name [string range $var 1 end]
            if {[info exists ::foreachVar($name)]} {
                # Mark them as known instead
                foreach name $::foreachVar($name) {
                    markVariable $name 1 "" $check $index known knownVars ""
                }
                #return 1
            }
        }
        if {$wordtype ne "varName"} {
            # A common namespace idiom is ${x}::y
            if {[regexp {^\${\w+}(::\w+)+} $var]} {
                # Do anything?
            } else {
                errorMsg N "Suspicious variable name \"$var\"" $index
            }
        }
        return 0
    }

    # Check for scalar/array mismatch
    if {$check != 2 && [dict exists $knownVars $varBase] &&
        [dict get $knownVars $varBase array] ne ""} {
        set varReallyArray [expr {$varArray || $isArray eq "yes"}]
        if {$varReallyArray != [dict get $knownVars $varBase array]} {
            if {$varReallyArray} {
                errorMsg E "Is array, was scalar" $index
            } else {
                if {$isArray ne "unknown"} {
                    errorMsg E "Is scalar, was array" $index
                }
            }
        }
    }

    if {$check == 2} {
        # This is a check, so "type" is an out, not an inout.
        # Ignore any incoming value.
        set type ""
        if {![dict exists $knownVars $varBase]} {
            return 1
        }
        if {[dict exists $knownVars $var] &&
            [dict get $knownVars $var "type"] ne ""} {
            set type [dict get $knownVars $var "type"]
        } else {
            set type [dict get $knownVars $varBase "type"]
        }
        return 0
    } else {
        if {![dict exists $knownVars $varBase]} {
            knownVar knownVars $varBase
            if {[currentProc] ne ""} {
                dict set knownVars $varBase local 1
            } else {
                dict set knownVars $varBase namespace [currentNamespace]
            }
            if {$check == 1} {
                if {$isArray eq "known"} {
                    dict set knownVars $varBase array $varArray
                } elseif {$isArray eq "yes"} {
                    dict set knownVars $varBase array 1
                }
            }
            if {$varArray || $isArray eq "yes"} {
                dict set knownVars $varBase array 1
            }
        }
        # A non-type cannot override a known type
        if {$type ne ""} {
            if {$varArray} {
                set oldType [dict get $knownVars $varBase "type"]
                if {$oldType ne "" && $type ne $oldType} {
                    # Inconsistent types. Mark base as unknown.
                    dict set knownVars $varBase "type" _unknown
                } else {
                    dict set knownVars $varBase "type" $type
                }
            } else {
                # Warn if changed in a scalar?? FIXA
                dict set knownVars $varBase "type" $type
            }
        }
        if {$check == 1} {
            dict set knownVars $varBase set 1
        }
        # If the array index is constant, mark the whole name
        if {$varArray && ($varIndexWs & 1)} {
            if {![dict exists $knownVars $var]} {
                knownVar knownVars $var
                if {[dict get $knownVars $varBase local]} {
                    dict set knownVars $var local 1
                }
                dict set knownVars $var array 0
            }
            if {$type ne ""} {
                dict set knownVars $var "type" $type
            }
            if {$check == 1} {
                dict set knownVars $var set 1
		setVarUsed knownVars $var
            }
        }
    }
}

# Just for setting a known variable's type
proc setVariableType {var type index knownVarsName} {
    upvar $knownVarsName knownVars
    # TODO parse variable for array etc?
    set varBase $var
    if {![dict exists $knownVars $varBase]} {
        errorMsg E "Unknown variable \"$varBase\"" $index 1
        return
    }
    dict set knownVars $varBase "type" $type
}

# Check if a name in knownVars has a used count of <= 1
proc checkForUnusedVar {knownVarsName {idx 0}} {
    upvar $knownVarsName knownVars

    if {$::Nagelfar(firstpass)} {
	return
    }
    if {$::Prefs(noVar) || !$::Prefs(warnUnusedVar)} {
	return
    }

    dict for {var info} $knownVars {
	# ignore qualified names and everything starting with "_"
	if {$var eq "" || [string first "::" $var] >= 0 || [string index $var 0] eq "_"} {
	    continue
	}
	if {$var in $::Prefs(warnUnusedVarFilter)} {
	    continue
	}
	if {![dict exists $info used]} {
	    continue
	}
	set val [dict get $info used]
	if {$val == 0 || ($val == -1 && ![dict get $info set])} {
            errorMsg W "Variable \"$var\" is never read" $idx
	}
    }
}

proc setVarUsed {knownVarsName var {kind 1}} {
    upvar $knownVarsName knownVars
    if {[dict exists $knownVars $var used]} {
       dict set knownVars $var used $kind
    }
}

proc lookForCommandNS {ns cmd} {
    set cmd1 "${ns}::$cmd"
    if {[string match "::*" $cmd1]} {
        set cmd1 [string range $cmd1 2 end]
    }
    return $cmd1
}

# This is called when an unknown command is encountered.
# If not found it is stored to be checked last.
# Returns a list with a partial command where the first element
# is the resolved name with qualifier.
proc lookForCommand {cmd ns index} {
    # Get both the namespace and global possibility
    set cmds {}
    if {[string match "::*" $cmd]} {
        # Fully qualified, so only one possible
        set cmds [list [string range $cmd 2 end]]
    } elseif {$ns ne "__unknown__" } {
        # Namespace Command rules (see "name resolution" in tcl namespace-doc)
        # * current namespace
        # * current namespace command path
        # * global
        set nsSearchPath $ns
        set nsPrefix $ns
        while {$nsPrefix ne ""} {
            if {[info exists ::namespacePath($nsPrefix)]} {
                lappend nsSearchPath {*}$::namespacePath($nsPrefix)
            }
            set nsPrefix [namespace qualifiers $nsPrefix]
        }
        foreach searchNs $nsSearchPath {
            lappend cmds [lookForCommandNS $searchNs $cmd]
        }

        # Special lookup for virtual namespace: look in first surrounding
        # namespace
        set curNs [currentNamespace]
        if {$curNs eq $ns} {
            if {[isCurrentNamespaceVirtual]} {
                # try full name
                lappend cmds [lookForCommandNS $ns $cmd]
                # try name without virtual part
                set nsUp [getCurrentNamespaceVirtualCmd]
                if {$nsUp ne ""} {
                    lappend cmds [lookForCommandNS $nsUp $cmd]
                }
            }
        }
        lappend cmds $cmd

        # Look in global namespace
        if {$ns ne ""} {
            lappend cmds [lookForCommandNS "" $cmd]
        }
    } else {
        set cmds [list $cmd]
    }

    #puts "MOO cmd '$cmd' ns '$ns' '$cmds'"
    foreach cmdCandidate $cmds {
        if {[info exists ::knownAliases($cmdCandidate)]} {
            return $::knownAliases($cmdCandidate)
        }
        if {[info exists ::syntax($cmdCandidate)]} {
            return [list $cmdCandidate]
        }
        if {[lsearch -exact $::knownCommands $cmdCandidate] >= 0} {
            return [list $cmdCandidate]
        }
    }
    if {[lsearch -exact $::knownCommands $cmd] >= 0} {
        return [list $cmd]
    }

    if {$index >= 0 && !$::Nagelfar(firstpass)} {
        lappend ::unknownCommands [list $cmd $cmds $index]
    }
    return ""
}

# Check for commands with special syntax that cannot be handled be checkCommand
# Returns 1 if command has been handled, 2 if fully done with command
# This is a helper for parseStatement, it should not be called from
# anywhere but parseStatement
proc checkSpecial {cmd index argv wordstatus wordtype indices expandWords} {
    upvar 1 "constantsDontCheck" constantsDontCheck "knownVars" knownVars
    upvar 1 "noConstantCheck" noConstantCheck "type" type

    set argc [llength $argv]

    if {[string match ".*" $cmd]} {
        # FIXA, check code in any -command.
        # Even widget commands should be checked.
        # Maybe in checkOptions ?
        return 2
    }
    # FIXA: handle {*} better?
    # Most of the handlers below cannot cope with expansion.
    # FIXA: Maybe e.g. "set" should complain since expansion does not make sense?
    if {[llength $expandWords] > 0} {
        if {$cmd ni {foreach}} {
            return 0
        }
    }

    switch $cmd {
        global { # Special check of "global" command
            foreach var $argv ws $wordstatus {
                if {$ws & 1} {
                    knownVar knownVars $var
		    setVarUsed knownVars $var -1
                } else {
                    errorMsg N "Non constant argument to $cmd: $var" $index
                }
            }
            set noConstantCheck 1
        }
        variable { # Special check of "variable" command
            # Look for a defined syntax in this namespace
            set currNs [currentNamespace]
            set rescmd [lookForCommand $cmd $currNs $index]
            if {[llength $rescmd] > 0 && \
                        [info exists ::syntax([lindex $rescmd 0])]} {
                # If it resides outside a procedure, it most likely
                # defines implicit variables. Fall back to syntax def.
                # This might not cover all cases, but is good enough for now.
                if {[currentProc] eq ""} {
                    return 0
                }
            }
            set i 0
            foreach {var val} $argv {ws1 ws2} $wordstatus {
                set ns [currentNamespace]
                if {[regexp {^(.*)::([^:]+)$} $var -> root var]} {
                    set ns $root
                    if {[string match "::*" $ns]} {
                        set ns [string range $ns 2 end]
                    }
                }
                if {$ns ne "__unknown__"} {
                    if {($ws1 & 1) || [string is wordchar $var]} {
                        knownVar knownVars $var
                        dict set knownVars $var namespace $ns
                        if {$i < $argc - 1} {
                            dict set knownVars $var set 1
                            dict set knownVars $var used 1
                            dict set knownVars $var array 0
                            # FIXA: What if it is an array element?
                            # Should the array be marked?
                        } else {
			    setVarUsed knownVars $var -1
			}
                        lappend constantsDontCheck $i
                    } else {
                        errorMsg N "Non constant argument to $cmd: $var" \
                                $index
                    }
                }
                incr i 2
            }
        }
        upvar { # Special check of "upvar" command
            if {$argc < 2} {
                WA
                return 2
            }
            set level [lindex $argv 0]
            set oddA [expr {$argc % 2 == 1}]
            set hasLevel 0
            if {[lindex $wordstatus 0] & 1} {
                # Is it a level ?
                if {[regexp {^[\\\#0-9]} $level]} {
                    if {!$oddA} {
                        WA
                        return 2
                    }
                    set hasLevel 1
                } else {
                    if {$oddA} {
                        WA
                        return 2
                    }
                    set level 1
                }
            } else {
                # Assume it is not a level unless odd number of args.
                if {$oddA} {
                    # Warn here? FIXA
                    errorMsg N "Non constant level to $cmd: \"$level\"" $index
                    set hasLevel 1
                    set level ""
                } else {
                    set level 1
                }
            }
            if {$hasLevel} {
                set tmp [lrange $argv 1 end]
                set tmpWS [lrange $wordstatus 1 end]
                set tmpT [lrange $wordtype 1 end]
                set i 2
            } else {
                set tmp $argv
                set tmpWS $wordstatus
                set tmpT $wordtype
                set i 1
            }

            foreach {other var} $tmp {wsO wsV} $tmpWS {tO tV} $tmpT {
                if {($wsV & 1) == 0} {
                    # The variable name contains substitutions
                    if {$tV eq "varName"} {
                        # It is OK
                    } else {
                        errorMsg N "Suspicious upvar variable \"$var\"" $index
                    }
                } else {
                    knownVar knownVars $var
                    setVarUsed knownVars $var -1
                    lappend constantsDontCheck $i
                    if {$other eq $var} { # Allow "upvar xx xx" construct
                        lappend constantsDontCheck [expr {$i - 1}]
                    }
                    if {($wsO & 1) == 0} {
                        # Is the other name a simple var subst?
                        if {[regexp {^\$([\w()]+)$}  $other -> other] || \
                            [regexp {^\${([^{}]*)}$} $other -> other]} {
                            if {[dict exists $knownVars $other]} {
                                if {$level == 1} {
                                    dict set knownVars $other upvar $var
                                } elseif {$level eq "#0"} {
                                    # FIXA: level #0 for global
                                    dict set knownVars $other upvar $var
                                    dict set knownVars $var set 1 ;# FIXA?
                                }
                            }
                        }
                    }
                }
                incr i 2
            }
        }
        set { # Special check of "set" command
            # Set gets a different syntax string depending on the
            # number of arguments.
            set wtype ""
            if {$argc == 1} {
                # Check the variable
                set var [lindex $argv 0]
                # Allow a plugin to have a look at the variable read
                if {$::Nagelfar(pluginVarRead)} {
                    pluginHandleVarRead var knownVars $index
                }
                setVarUsed knownVars $var
                if {[string match ::* $var]} {
                    # Skip qualified names until we handle
                    # namespace better. FIXA
                } elseif {[markVariable $var \
                        [lindex $wordstatus 0] [lindex $wordtype 0] \
                        2 [lindex $indices 0] known knownVars wtype]} {
                    if {!$::Prefs(noVar)} {
                        errorMsg E "Unknown variable \"$var\""\
                                [lindex $indices 0] 1
                    }
                }
            } elseif {$argc == 2} {
                set wtype [lindex $wordtype 1]
                markVariable [lindex $argv 0] \
                        [lindex $wordstatus 0] [lindex $wordtype 0] \
                        1 [lindex $indices 0] known \
                        knownVars wtype
            } else {
                WA
            }
            lappend constantsDontCheck 0

            set type $wtype
        }
        foreach - lmap { # Special check of "foreach" and "lmap" commands
            # Check that we are in at least 8.6 for lmap
            if {$cmd eq "lmap" && ![info exists ::syntax(lmap)]} {
                return 0
            }
            # Handle expansion.
            # As long as the last arg is stable the body can be checked.
            set onlybody 0
            if {[llength $expandWords] > 0} {
                if {([lindex $wordstatus end] & 8) != 0} {
                    return 0
                }
                set onlybody 1
            }
            set varsAdded {}

            if {!$onlybody} {
                if {$argc < 3 || ($argc % 2) == 0} {
                    WA
                    return 2
                }
                for {set i 0} {$i < $argc - 1} {incr i 2} {
                    if {[lindex $wordstatus $i] == 0} {
                        errorMsg W "Non constant variable list to foreach\
                                    statement." [lindex $indices $i]
                        # FIXA, maybe abort here?
                    }
                    lappend constantsDontCheck $i
                    if {![string is list [lindex $argv $i]]} {
                        errorMsg E "Invalid variable list to foreach" [lindex $indices $i]
                    } else {
                        foreach var [lindex $argv $i] {
                            markVariable $var 1 "" 1 $index known knownVars ""
                        }
                    }
                }
                # FIXA: Experimental foreach check...
                # A special case for looping over constant lists
                foreach {varList valList} [lrange $argv 0 end-1] \
                        {varWS valWS} [lrange $wordstatus 0 end-1] {
                    if {($varWS & 1) && ($valWS & 1)} {
                        if {![string is list $valList]} {
                            errorMsg E "Invalid value list to foreach" [lindex $indices 0]
                            continue
                        }
                        if {![string is list $varList]} {
                            # Error is above
                            continue
                        }
                        set fVars {}
                        foreach fVar $varList {
                            set ::foreachVar($fVar) {}
                            lappend fVars apaV($fVar)
                            lappend varsAdded $fVar
                        }
                        ##nagelfar ignore Non constant variable list to foreach
                        foreach $fVars $valList {
                            foreach fVar $varList {
                                ##nagelfar variable apaV
                                lappend ::foreachVar($fVar) $apaV($fVar)
                            }
                        }
                    }
                }
            }

            if {([lindex $wordstatus end] & 1) == 0} {
                errorMsg W "No braces around body in foreach\
                        statement." $index
            }
            instrumentL $indices $argv end
            set type [parseBody [lindex $argv end] [lindex $indices end] \
                              knownVars]
            # Clean up
            foreach fVar $varsAdded {
                catch {unset ::foreachVar($fVar)}
            }
        }
        if { # Special check of "if" command
            if {$argc < 2} {
                WA
                return 2
            }
            set old_ifsyntax $::syntax(if)
            # Build a syntax string that fits this if statement
            set state expr
            set ifsyntax {}
            foreach arg $argv ws $wordstatus index $indices {
                switch -- $state {
                    skip {
                        # This will behave bad with "if 0 then then"...
                        lappend ifsyntax xComm
                        if {$arg ne "then"} {
                            set state else
                        }
                        continue
                    }
                    then {
                        set state body
                        if {$arg eq "then"} {
                            lappend ifsyntax x
                            continue
                        }
                    }
                    else {
                        if {$arg eq "elseif"} {
                            set state expr
                            lappend ifsyntax x
                            continue
                        }
                        set state lastbody
                        if {$arg eq "else"} {
                            lappend ifsyntax x
                            continue
                        }
                        if {$::Prefs(forceElse)} {
                            errorMsg E "Badly formed if statement" $index
                            contMsg "Found argument '[trimStr $arg]' where\
                                    else/elseif was expected."
                            return 2
                        }
                    }
                }
                switch -- $state {
                    expr {
                        # Handle if 0 { ... } as a comment
                        if {[string is integer $arg] && $arg == 0} {
                            lappend ifsyntax x
                            set state skip
                        } else {
                            lappend ifsyntax e
                            set state then
                        }
                    }
                    lastbody {
                        lappend ifsyntax c
                        set state illegal
                    }
                    body {
                        lappend ifsyntax c
                        set state else
                    }
                    illegal {
                        errorMsg E "Badly formed if statement" $index
                        contMsg "Found argument '[trimStr $arg]' after\
                              supposed last body."
                        return 2
                    }
                }
            }
            # State should be "else" if there was no else clause or
            # "illegal" if there was one.
            if {$state ne "else" && $state ne "illegal"} {
                errorMsg E "Badly formed if statement" $index
                contMsg "Missing one body."
                return 2
            } elseif {$state eq "else"} {
                # Mark the missing else for instrumenting
                instrument [expr {$index + [string length $arg]}] 2 ""
            }
#            decho "if syntax \"$ifsyntax\""
            set ::syntax(if) $ifsyntax
            checkCommand $cmd $index $argv $wordstatus $wordtype $indices \
                    $expandWords
            set ::syntax(if) $old_ifsyntax
        }
        try { # Special check of "try" command
            # Check that we are in at least 8.6
            if {![info exists ::syntax(try)]} {
                return 0
            }
            if {$argc < 1} {
                WA
                return 2
            }
            set old_trysyntax $::syntax(try)
            # Build a syntax string that fits this try statement
            set state body
            set trysyntax {}
            foreach arg $argv ws $wordstatus index $indices {
                switch -- $state {
                    body {
                        if {$arg eq "-"} {
                            lappend trysyntax x
                            set state handler-required
                        } else {
                            lappend trysyntax c
                            set state handler
                        }
                        continue
                    }
                    finally {
                        lappend trysyntax c
                        set state illegal
                        continue
                    }
                    handler-required -
                    handler {
                        if {$arg eq "on" || $arg eq "trap"} {
                            set state code
                            lappend trysyntax x
                            continue
                        }
                        if {$arg eq "finally"} {
                            lappend trysyntax x
                            set state finally
                            continue
                        }
                        errorMsg E "Bad word in try statement, should be on, trap or finally." $index
                        return 2
                    }
                    code {
                        lappend trysyntax x
                        set state varlist
                        continue
                    }
                    varlist {
                        lappend trysyntax nl
                        set state body
                        continue
                    }
                    illegal {
                        errorMsg E "Badly formed try statement" $index
                        contMsg "Found argument '[trimStr $arg]' after\
                              supposed last body."
                        return 2
                    }
                }
            }
            # State should be "handler" or "illegal"
            if {$state ne "handler" && $state ne "illegal"} {
                errorMsg E "Badly formed try statement" $index
                if {$state ne "handler-required"} {
                    #contMsg "Missing one body."
		} else {
		    contMsg "Fall-through handler can't be last."
		}
                return 2
            }
            #decho "$argc try syntax \"$trysyntax\""
            set ::syntax(try) $trysyntax
            checkCommand $cmd $index $argv $wordstatus $wordtype $indices \
                    $expandWords
            set ::syntax(try) $old_trysyntax
        }
        switch { # Special check of "switch" command
            if {$argc < 2} {
                WA
                return 2
            }
            # FIXA: As of 8.5.1, two args are not checked for options,
            # does this imply anything
            set i 0
            if {$argc > 2} {
                set max [expr {$argc - 2}]
                set oSyn [checkOptions $cmd $argv $wordstatus $indices $wordtype \
                        0 $max 0]
                set i [llength $oSyn]
                if {[lsearch -not $oSyn "x"] >= 0} {
                    # There is some special flag in there, probably a var
                    set old_swsyntax $::syntax(switch)
                    lappend oSyn xComm*
                    set ::syntax(switch) $oSyn
                    checkCommand $cmd $index $argv $wordstatus $wordtype \
                            $indices $expandWords
                    set ::syntax(switch) $old_swsyntax
                }
            }
            if {[lindex $wordstatus $i] & 1 == 1} {
                # First argument to switch is constant, suspiscious
                errorMsg N "String argument to switch is constant" \
                        [lindex $indices $i]
            }
            incr i
            set left [expr {$argc - $i}]

            if {$left == 1} {
                # One block. Split it into a list.
                # FIXA. Changing argv messes up the constant check.

                set arg [lindex $argv $i]
                set ws [lindex $wordstatus $i]
                set ix [lindex $indices $i]

                if {($ws & 1) == 1} {
                    set swargv [splitList $arg $ix swindices swwordst]
                    if {[llength $swargv] % 2 == 1} {
                        errorMsg E "Odd number of elements in last argument to\
                                switch." $ix
                        return 2
                    }
                    if {[llength $swargv] == 0} {
                        errorMsg W "Empty last argument to switch." $ix
                        return 2
                    }
                } else {
                    set swwordst {}
                    set swargv {}
                    set swindices {}
                }
            } elseif {$left % 2 == 1} {
                WA
                return 2
            } else {
                set swargv [lrange $argv $i end]
                set swwordst [lrange $wordstatus $i end]
                set swindices [lrange $indices $i end]
            }
            set count [llength $swargv]
            foreach {pat body} $swargv {ws1 ws2} $swwordst {i1 i2} $swindices {
                incr count -2
                # A stand-alone hash as a pattern is suspicious
                if {[string index $pat 0] eq "#" && $ws1 == 1} {
                    # Skip warning if body is braced
                    if {$ws2 != 3} {
                        errorMsg W "Switch pattern starting with #.\
                                This could be a bad comment." $i1
                    }
                }
                if {$body eq "-"} {
                    continue
                }
                if {($ws2 & 1) == 0} {
                    errorMsg W "No braces around code in switch\
                            statement." $i2
                }
                if {$pat eq "others" && $ws1 == 1 && $count == 0} {
                    # Bareword "others" when last can be a mistake since other
                    # languages use it as the "default" keyword.
                    errorMsg N "Switch pattern \"others\" could be a mistaken\
                            \"default\"" $i1
                }
                instrument $i2 1 $body
                parseBody $body $i2 knownVars
            }
        }
        expr { # Special check of "expr" command
            # FIXA
            # Take care of the standard case of a brace enclosed expr.
            if {$argc == 1 && ([lindex $wordstatus 0] & 1)} {
                 parseExpr [lindex $argv 0] [lindex $indices 0] knownVars
            } else {
                if {$::Prefs(warnBraceExpr)} {
                    errorMsg W "Expr without braces" [lindex $indices 0]
                }
            }
        }
        eval { # Special check of "eval" command
            # FIXA
            set noConstantCheck 1
        }
        interp { # Special check of "interp" command
            if {$argc < 1} {
                WA
                return 2
            }
            # Special handling of interp alias
            if {([lindex $wordstatus 0] & 1) && "alias" eq [lindex $argv 0]} {
                if {$argc < 3} {
                    WA
                    return 2
                }
                # This should define a source in the current interpreter
                # with a known name.
                if {$argc >= 5 && \
                        ([lindex $wordstatus 1] & 1) && \
                        "" eq [lindex $argv 1] && \
                        ([lindex $wordstatus 2] & 1)} {
                    set newAlias [lindex $argv 2]
                    set aliasCmd {}
                    for {set t 4} {$t < $argc} {incr t} {
                        if {[lindex $wordstatus 1] & 1} {
                            lappend aliasCmd [lindex $argv $t]
                        } else {
                            lappend aliasCmd {}
                        }
                    }
                    set ::knownAliases($newAlias) $aliasCmd
                }
            }
            set type [checkCommand $cmd $index $argv $wordstatus \
                    $wordtype $indices $expandWords]
            set noConstantCheck 1
        }
        package { # Special check of "package" command
            # Take care of require to autoload package definition
            if {$argc >= 2 && [lindex $argv 0] eq "require"} {
                set nameI 1
                if {[string match "-*" [lindex $argv $nameI]]} {
                    incr nameI
                }
                if {$nameI < $argc} {
                    if {[lindex $wordstatus $nameI] & 1} {
                        set pName [lindex $argv $nameI]
                        lookForPackageDb $pName [lindex $indices $nameI]
                    } else {
                        errorMsg N "Non constant package require" \
                                [lindex $indices $nameI]
                    }
                }
            }
            set type [checkCommand $cmd $index $argv $wordstatus $wordtype \
                              $indices $expandWords]
        }
        namespace { # Special check of "namespace" command
            if {$argc < 1} {
                WA
                return 2
            }
            # Special handling of namespace eval
            if {([lindex $wordstatus 0] & 1) && \
                    [string match "ev*" [lindex $argv 0]]} {
                if {$argc < 3} {
                    WA
                    return 2
                }
                set arg1const [expr {[lindex $wordstatus 1] & 1}]
                set arg2const [expr {[lindex $wordstatus 2] & 1}]
                # Look for unknown parts
                if {[string is space [lindex $argv 2]]} {
                    # Empty body, do nothing
                } elseif {$arg2const && $argc == 3} {
                    if {$arg1const} {
                        set ns [lindex $argv 1]
                        if {![string match "::*" $ns]} {
                            set root [currentNamespace]
                            if {$root ne "__unknown__"} {
                                set ns ${root}::$ns
                            }
                        }
                    } else {
                        set ns __unknown__
                    }

                    pushNamespace $ns
                    parseBody [lindex $argv 2] [lindex $indices 2] knownVars
                    popNamespace
                } else {
                    errorMsg N "Only braced namespace evals are checked." \
                            [lindex $indices 0] 1
                }
            } elseif {([lindex $wordstatus 0] & 1) && \
                    [string match "im*" [lindex $argv 0]]} {
                # Handle namespace import
		# FIXA: handle namespace import foo::*
                if {$argc < 2} {
                    # Import without args is not interesting
                    return 2
                }
                set ns [currentNamespace]
                if {[lindex $argv 1] eq "-force"} {
                    set t 2
                } else {
                    set t 1
                }
                for {} {$t < [llength $argv]} {incr t} {
                    if {([lindex $wordstatus $t] & 1) == 0} {
                        # Non constant cannot be checked
                        continue
                    }
                    set candidate [lindex $argv $t]
                    set others [lookForCommand $candidate $ns -1]
                    set others [lrange $others 0 0]
                    if {[llength $others] == 0} {
                        # Fall back on trying glob matching
                        if {[string match "::*" $candidate]} {
                            set candidate [string range $candidate 2 end]
                        }
                        # If it is an import of * we make the assumption
                        # that only lower-case procs are imported, since we
                        # do not know the export list
                        if {[string match "*::\\*" $candidate]} {
                            set candidate [string range $candidate 0 end-1]
                            append candidate {[a-z]*}
                        }
                        set others [lsearch -all -inline -glob $::knownCommands $candidate]
                    }
                    foreach other $others {
                        set tail [namespace tail $other]
                        if {$ns eq ""} {
                            set me $tail
                        } else {
                            set me ${ns}::$tail
                            if {[string match "::*" $me]} {
                                set me [string range $me 2 end]
                            }
                        }
                        #puts "ME: $me : OTHER: $other"
                        # Copy the command info
                        if {[lsearch -exact $::knownCommands $me] < 0} {
                            lappend ::knownCommands $me
                        }
                        if {![info exists ::syntax($me)] && \
                                [info exists ::syntax($other)]} {
                            set ::syntax($me) $::syntax($other)
                        }
                    }
                }
                set type [checkCommand $cmd $index $argv $wordstatus \
                        $wordtype $indices $expandWords]
            } elseif {([lindex $wordstatus 0] & 1) && \
                    [string match "pa*" [lindex $argv 0]]} {
                # Handle namespace path
                if {$argc > 2} {
                    WA
                    return 2
                }
                # Stupid simple search for obvious names
                set targets [regexp -all -inline {[\w:]+} $argv]
                set ns [currentNamespace]
                foreach target $targets {
                    if {![string match "*::*" $target]} continue
                    #puts "Added '$target' to '$ns'"
                    lappend ::namespacePath($ns) $target
                }
            } else {
                set type [checkCommand $cmd $index $argv $wordstatus \
                                  $wordtype $indices $expandWords]
            }
        }
        next { # Special check of "next" command
            # Figure out the superclass of the caller to be able to check
            set currObj [currentObject]
            if {[info exists ::superclass($currObj)]} {
                foreach {superCmd superObj} $::superclass($currObj) break
                set methodName [namespace tail [currentProc]]
                #puts "next: super '$superObj' meth '$methodName'"
                if {[string match "* new" $methodName]} {
                    # This is a constructor
                    set subCmd "$superCmd new"
                } else {
                    set subCmd "$superObj $methodName"
                }
                if {[info exists ::syntax($subCmd)]} {
                    #puts "Syntax for '$subCmd' '$::syntax($subCmd)'"
                    set type [checkCommand $subCmd $index $argv $wordstatus \
                            $wordtype $indices $expandWords]
                }
            } else {
                errorMsg N "No superclass found for 'next'" $index
            }
        }
        tailcall { # Special check of "tailcall" command
            if {$argc < 1} {
                WA
                return 2
            }
            set newStatement [join $argv]
            set newIndex [lindex $indices 0]
            set type [parseStatement $newStatement $newIndex knownVars]
            set noConstantCheck 1
        }
        uplevel { # Special check of "uplevel" command
            # FIXA
            set noConstantCheck 1
        }
        default {
            return 0
        }
    }
    return 1
}

# Parse one statement and check the syntax of the command
# Returns the return type of the statement
proc parseStatement {statement index knownVarsName} {
    upvar $knownVarsName knownVars

    # Allow a plugin to have a look at the statement
    if {$::Nagelfar(pluginStatementRaw)} {
        pluginHandleStatementRaw statement knownVars $index
    }

    set words [splitStatement $statement $index indices]

    # Allow a plugin to have a look at the statement words
    if {$::Nagelfar(pluginStatementWords)} {
        pluginHandleStatementWords words knownVars $index
    }

    if {[llength $words] == 0} {return}

    addImplicitVariablesCmd [join $words] $index knownVars

    if {$::Nagelfar(firstpass)} {
        set cmd [lindex $words 0]
        if {[string match "::*" $cmd]} {
            set cmd [string range $cmd 2 end]
        }
        if {$cmd eq "proc"} {
            # OK
        } elseif {$cmd eq "namespace" && \
                [lindex $words 1] eq "eval" && \
                [llength $words] == 4 && \
                ![regexp {[][$\\]} [lindex $words 2]] && \
                ![regexp {^[{"]?\s*["}]?$} [lindex $words 3]]} {
            # OK
        } elseif {$cmd eq "oo::class"} {
            # OK
        } elseif {$cmd eq "package"} {
            # OK
        } else {
            set ns [currentNamespace]
            set syn ""
            if {$ns eq "" && [info exists ::syntax($cmd)]} {
                set syn $::syntax($cmd)
            } else {
                set rescmd [lookForCommand $cmd $ns $index]
                if {[llength $rescmd] > 0 && \
                    [info exists ::syntax([lindex $rescmd 0])]} {
                    set cmd [lindex $rescmd 0]
                    set syn $::syntax($cmd)
                }
            }
            if {[lsearch -glob $syn d*] >= 0} {
                #echo "Firstpass '[lindex $words 0]' '$syn'"
                # OK
            } else {
                #echo "Firstpass block1 '[lindex $words 0]' '$syn'"
                return ""
            }
        }
    }

    set type ""
    set words2 {}
    set wordstatus {}
    set wordtype {}
    set indices2 {}
    set wordCnt -1
    foreach word $words index $indices {
        incr wordCnt
        set ws 0
        set wtype ""
        if {[string length $word] > 3 && [string match "{\\*}*" $word]} {
            set ws 8
            set word [string range $word 3 end]
            incr index 3
        }
        set char [string index $word 0]
        if {$char eq "\{"} {
            incr ws 3 ;# Braced & constant
            set word [string range $word 1 end-1]
            incr index
        } else {
            if {$char eq "\""} {
                set word [string range $word 1 end-1]
                incr index
                incr ws 4
            }
            if {[parseSubst $word $index wtype knownVars]} {
                # A constant
                incr ws 1
            }
            if {$wordCnt > 0 && [string index $word 0] eq "\}"} {
                errorMsg N "Unescaped close brace" $index
            }
        }
        if {($ws & 9) == 9} {
            # An expanded constant, unlikely but we can just as well handle it
            if {[catch {llength $word}]} {
                errorMsg E "Expanded word is not a valid list." $index
            } else {
                foreach apa $word {
                    lappend words2 $apa
                    lappend wordstatus 1
                    lappend wordtype ""
                    # For now I don't bother to track correct indices
                    lappend indices2 $index
                }
            }
        } else {
            lappend words2 $word
            lappend wordstatus $ws
            lappend wordtype $wtype
            lappend indices2 $index
        }
    }

    set cmd [lindex $words2 0]
    set index [lindex $indices2 0]
    set cmdtype [lindex $wordtype 0]
    set cmdws [lindex $wordstatus 0]

    if {[string match "::*" $cmd]} {
        set cmd [string range $cmd 2 end]
    }

    # Expanded command, nothing to check...
    set thisCmdHasBeenHandled 0
    if {($cmdws & 8)} {
        set thisCmdHasBeenHandled 1
    }

    # If the command contains substitutions we can not determine
    # which command it is, so we skip it, unless the type is known
    # to be an object.

    if {$thisCmdHasBeenHandled == 0 && ($cmdws & 1) == 0} {
        if {[string match "_obj,*" $cmdtype]} {
            set cmd $cmdtype
        } else {
            # Detect missing space after command
            if {[regexp {^[\w:]+\{} $cmd]} {
                errorMsg W "Suspicious command \"$cmd\"" $index
            }
            # Detect bracketed command
            if {[llength $words2] == 1 && [string index $cmd 0] eq "\["} {
                errorMsg N "Suspicious brackets around command" $index
            }
            set thisCmdHasBeenHandled 1
        }
    }

    # Extract the argument parts
    set argv       [lrange $words2     1 end]
    set wordtype   [lrange $wordtype   1 end]
    set wordstatus [lrange $wordstatus 1 end]
    set indices    [lrange $indices2   1 end]
    set argc [llength $argv]

    # Find the expanded arguments
    set expandWords {}
    set i 0
    foreach ws $wordstatus {
        if {$ws & 8} {
            lappend expandWords $i
        }
        incr i
    }

    # The parsing below can pass information to the constants checker
    # This list primarily consists of args that are supposed to be variable
    # names without a $ in front.
    set noConstantCheck 0
    set constantsDontCheck {}

    # Any command that can't be described in the syntax database
    # have their own special check implemented here.
    # Any command that can be checked by checkCommand should
    # be in the syntax database.

    # checkSpecial is coded as if inline, might affect these vars:
    # noConstantCheck constantsDontCheck type
    if {$thisCmdHasBeenHandled == 0} {
        set thisCmdHasBeenHandled [checkSpecial $cmd $index $argv $wordstatus \
                                           $wordtype $indices $expandWords]
    }
    if {$thisCmdHasBeenHandled == 2} return

    # Fallthrough
    if {!$thisCmdHasBeenHandled} {
        set ns [currentNamespace]
        if {$ns eq "" && [info exists ::syntax($cmd)]} {
#                decho "Checking '$cmd' in '$ns' res"
            set type [checkCommand $cmd $index $argv $wordstatus \
                    $wordtype $indices $expandWords]
        } else {
            # Resolve commands in namespace
            set rescmd [lookForCommand $cmd $ns $index]
            if {$ns ne ""} {
                #decho "Checking '$cmd' in '$ns' resolved '$rescmd'"
            }
            if {[llength $rescmd] > 0 && \
                    [info exists ::syntax([lindex $rescmd 0])]} {
                set cmd [lindex $rescmd 0]
                # If lookForCommand returns a partial command, fill in
                # all lists accordingly.
                if {[llength $rescmd] > 1} {
                    set preargv {}
                    set prews {}
                    set prewt {}
                    set preindices {}
                    foreach arg [lrange $rescmd 1 end] {
                        lappend preargv $arg
                        lappend prews 1
                        lappend prewt ""
                        lappend preindices $index
                    }
                    set argv [concat $preargv $argv]
                    set wordstatus [concat $prews $wordstatus]
                    set wordtype [concat $prewt $wordtype]
                    set indices [concat $preindices $indices]
                }
                set type [checkCommand $cmd $index $argv $wordstatus \
                        $wordtype $indices $expandWords]
            } elseif {$::Nagelfar(dbpicky)} {
                errorMsg N "DB: Missing syntax for command \"$cmd\"" 0
            }
        }
    }

    if {$::Prefs(noVar)} {
        return $type
    }

    if {!$noConstantCheck} {
        # Check unmarked constants against known variables to detect missing $.
        # The constant is considered ok if within quotes.
        set i 0
        foreach ws $wordstatus var $argv {
            # is it an array?
            set varBase $var
            set ix [string first "(" $var]
            if {$ix != -1} {
                incr ix -1
                set varBase [string range $var 0 $ix]
                # Check if the base is free from substitutions
                if {($ws & 1) == 0 && [regexp {^(::)?(\w+(::)?)+$} $varBase]} {
                    set ws [expr {$ws | 1}]
                }
            }
            if {[dict exists $knownVars $varBase]} {
                if {($ws & 7) == 1 && [lsearch $constantsDontCheck $i] == -1} {
                    errorMsg W "Found constant \"$varBase\" which is also a\
                            variable." [lindex $indices $i]
                }
            }
            incr i
        }
    }
    return $type
}

# Split a script into individual statements
proc splitScript {script index statementsName indicesName} {
    upvar $statementsName statements $indicesName indices

    set statements {}
    set indices {}

    # tryline accumulates from the script until it becomes a complete statement
    set tryline ""
    # newstatement indicates that we are beginning a statement. It is equivalent
    # to tryline being empty
    set newstatement 1
    # firstline stores the first line of a statement
    set firstline ""
    # alignedBraceIx stores the position of any close braced encountered that
    # is indented the same as the statement being parsed
    set alignedBraceIx -1
    # openBraceIx stores the position of the last open brace at end of line
    set openBraceIx -1
    # Bracelevel is used to switch parsing style depending on where we are
    # brace-balance wise. This is to quickly parse large brace-enclosed blocks
    # like a proc body.
    set bracelevel 0

    foreach line [split $script \n] {
        # Here we must remember that "line" misses the \n that split ate.
        # When line is used below we add \n.
        # The extra \n generated on the last line does not matter.

        if {$bracelevel > 0} {
            # Manual brace parsing is entered when we know we are in
            # a braced block.  Return to ordinary parsing as soon
            # as a balanced brace is found.

            # Extract relevant characters
            foreach char [regexp -all -inline {\\.|{|}} $line] {
                if {$char eq "\{"} {
                    incr bracelevel
                } elseif {$char eq "\}"} {
                    incr bracelevel -1
                    if {$bracelevel <= 0} break
                }
            }
            # Remember a close brace that is aligned with start of line.
            if {"\}" eq [string trim $line] && $alignedBraceIx == -1} {
                set closeBraceIx [expr {[string length $tryline] + $index}]
                set closeBraceIndent [wasIndented $closeBraceIx]
                set startIndent [wasIndented $index]
                if {$startIndent == $closeBraceIndent} {
                    set alignedBraceIx $closeBraceIx
                }
            }
            if {$bracelevel > 0} {
                # We are still in a braced block so go on to the next line
                append tryline $line\n
                set newstatement 0
                set line ""
                continue
            }
        }

        # An empty line can never cause completion, since at this stage
        # any backslash-newline has been removed.
        if {[string is space $line]} {
            if {$tryline eq ""} {
                # We have not started a statement yet, move index to next line.
                incr index [string length $line]
                incr index
            } else {
                append tryline $line\n
            }
            continue
        }

        append line \n

        # This loop gradually moves parts from line to tryline until
        # tryline becomes a complete statement.
        # This could generate multiple statements until line is consumed.
        while {$line ne ""} {

            # Some extra checking on close braces to help finding
            # brace mismatches
            set closeBraceIndent -1
            if {"\}" eq [string trim $line]} {
                set closeBraceIx [expr {[string length $tryline] + $index}]
                if {$newstatement} {
                    errorMsg E "Unbalanced close brace found" $closeBraceIx
                    reportCommentBrace 0 $closeBraceIx
                }
                set closeBraceIndent [wasIndented $closeBraceIx]
                if {$alignedBraceIx == -1} {
                    set startIndent [wasIndented $index]
                    if {$startIndent == $closeBraceIndent} {
                        set alignedBraceIx $closeBraceIx
                    }
                }
            }

            # Move everything up to the next semicolon, newline or eof
            # to tryline. Since newline and eof only happens at end of line,
            # we only need to search for semicolon.

            set i [string first ";" $line]
            if {$i != -1} {
                append tryline [string range $line 0 $i]
                if {$newstatement} {
                    set newstatement 0
                    set firstline [string range $line 0 $i]
                }
                incr i
                set line [string range $line $i end]
                set splitSemi 1
            } else {
                append tryline $line
                if {$newstatement} {
                    set newstatement 0
                    set firstline $line
                }
                set line ""
                set splitSemi 0
            }
            # If we split at a ; we must check that it really may be an end
            if {$splitSemi} {
                # Comment lines don't end with ;
                #if {[regexp {^\s*#} $tryline]} {continue}
                if {[string index [string trimleft $tryline] 0] eq "#"} continue

                # Look for \'s before the ;
                # If there is an odd number of \, the ; is ignored
                if {[string index $tryline end-1] eq "\\"} {
                    set i [expr {[string length $tryline] - 2}]
                    set t $i
                    while {[string index $tryline $t] eq "\\"} {
                        incr t -1
                    }
                    if {($i - $t) % 2 == 1} {continue}
                }
            }
            # Check if it's a complete line
            if {[info complete $tryline]} {
                # Remove leading space, keep track of index.
                # Most lines will have no leading whitespace since
                # buildLineDb removes most of it. This takes care
                # of all remaining.
                if {[string is space -failindex i $tryline]} {
                    # Only space, discard the line
                    incr index [string length $tryline]
                    set tryline ""
                    set newstatement 1
                    set alignedBraceIx -1
                    continue
                } else {
                    if {$i != 0} {
                        set tryline [string range $tryline $i end]
                        incr index $i
                    }
                }
                # Take care of the statement
                # Comments are added to the statement list and checked later
                if {$splitSemi} {
                    # Remove the semicolon from the statement
                    lappend statements [string range $tryline 0 end-1]
                } else {
                    lappend statements $tryline
                }
                lappend indices $index

                # Extra checking if the last line of the statement was
                # a close brace.
                if {$closeBraceIndent != -1} {
                    # Check if the close brace is aligned with start of command
                    set tmp [wasIndented $index]
                    if {$tmp != $closeBraceIndent} {
                        set tmp2 [wasIndented $openBraceIx]
                        # Matching last open brace is ok too
                        if {$openBraceIx == -1 || $closeBraceIndent != $tmp2} {
                            # Only do this if there is a free open brace
                            if {[regexp "\{\n" $tryline]} {
                                errorMsg N "Close brace not aligned with line\
                                    [calcLineNo $index]\
                                    ($tmp $closeBraceIndent)" \
                                        $closeBraceIx
                            }
                        }
                    }
                }
                incr index [string length $tryline]
                set tryline ""
                set newstatement 1
                set alignedBraceIx -1
            } elseif {$closeBraceIndent == 0 && \
                    ![string match "namespace eval*" $tryline] && \
                    ![string match "if *" $tryline] && \
                    ![string match "*tcl_platform*" $tryline]} {
                # A close brace that is not indented is typically the end of
                # a global statement, like "proc".
                # If it does not end the statement, there is probably a
                # brace mismatch.
                # When inside a namespace eval block, this is probably ok.
                errorMsg N "Found non indented close brace that did not end\
                        statement." $closeBraceIx
                contMsg "This may indicate a brace mismatch."
            }
        } ;# End of loop means line used up

        # If the line is complete except for a trailing open brace
        # we can switch to just scanning braces.
        # This could be made more general but since this is the far most
        # common case it's probably not worth complicating it.
        if {[string range $tryline end-2 end] eq " \{\n" && \
                    [info complete [string range $tryline 0 end-2]]} {
            set openBraceIx [expr {[string length $tryline] + $index - 1}]
            set bracelevel 1
        }
    }
    # If tryline is non empty, it did not become complete
    if {[string length $tryline] != 0} {
        errorMsg E "Could not complete statement." $index

        # Experiment a little to give more info.
        # First, at first line, to give a hint of the nature of what is missing.
        if {[info complete $firstline\}]} {
            contMsg "One close brace would complete the first line"
            reportCommentBrace $index $index
        } elseif {[info complete $firstline\}\}]} {
            contMsg "Two close braces would complete the first line"
            reportCommentBrace $index $index
        }
        if {[info complete $firstline\"]} {
            contMsg "One double quote would complete the first line"
        }
        if {[info complete $firstline\]]} {
            contMsg "One close bracket would complete the first line"
        }

        # Second, at an aligned close brace, which is a likely place.
        if {$alignedBraceIx != -1} {
            set cand [string range $tryline 0 [expr {$alignedBraceIx - $index}]]
            set txt "at end of line [calcLineNo $alignedBraceIx]."
            if {[info complete $cand\}]} {
                contMsg "One close brace would complete $txt"
            } elseif {[info complete $cand\}\}]} {
                contMsg "Two close braces would complete $txt"
            }
            # TODO: Use this information to assume completeness earlier
            # This would need to recurse back to this function after cutting of the
            # remainder of tryline.
        }

        # Third, at end of script
        set endIx [expr {$index + [string length $tryline] - 1}]
        set txt "the script body at line [calcLineNo $endIx]."
        if {[info complete $tryline\}]} {
            contMsg "One close brace would complete $txt"
            contMsg "Assuming completeness for further processing."
            reportCommentBrace $index $endIx
            lappend statements $tryline\}
            lappend indices $index
        } elseif {[info complete $tryline\}\}]} {
            contMsg "Two close braces would complete $txt"
            contMsg "Assuming completeness for further processing."
            reportCommentBrace $index $endIx
            lappend statements $tryline\}\}
            lappend indices $index
        }
        if {[info complete $tryline\"]} {
            contMsg "One double quote would complete $txt"
        }
        if {[info complete $tryline\]]} {
            contMsg "One close bracket would complete $txt"
        }
    }
}

# Returns the return type of the script
proc parseBody {body index knownVarsName {isCommandSubst 0}} {
    upvar $knownVarsName knownVars

    if {$::Nagelfar(pluginBodyRaw)} {
        pluginHandleBodyRaw body knownVars $index $isCommandSubst
    }

    # Cache the splitScript result to optimise 2-pass checking.
    if {[info exists ::Nagelfar(cacheBody)] && \
            [info exists ::Nagelfar(cacheBody,$body)]} {
        set statements $::Nagelfar(cacheStatements,$body)
        set indices $::Nagelfar(cacheIndices,$body)
    } else {
        splitScript $body $index statements indices
    }
    # Unescaped newline in command substitution body is probably wrong
    if {$isCommandSubst && [llength $statements] > 1} {
        foreach statement [lrange $statements 0 end-1] \
                stmtIndex [lrange $indices 0 end-1] {
            if {[string index $statement end] eq "\n"} {
                # Comment is ok
                if {[string index $statement 0] ne "\#"} {
                    errorMsg N "Newline in command substitution" $stmtIndex
                    break
                }
            }
        }
    }

    #puts "Parsing a body with [llength $statements] stmts"
    set type ""
    foreach statement $statements index $indices {
        if {[string match "#*" $statement]} {
            checkComment $statement $index knownVars
        } else {
            set type [parseStatement $statement $index knownVars]
        }
    }
    if {$::Nagelfar(firstpass)} {
        set ::Nagelfar(cacheBody) 1
        set ::Nagelfar(cacheBody,$body) 1
        set ::Nagelfar(cacheStatements,$body) $statements
        set ::Nagelfar(cacheIndices,$body) $indices
    } else {
        # FIXA: Why is this here? Tests pass without it
        unset -nocomplain ::Nagelfar(cacheBody)
    }
    return $type
}

# This is called when a definition command is encountered
# Add arguments to variable scope
proc parseArgs {procArgs indexArgs syn knownVarsName} {
    upvar $knownVarsName knownVars

    if {[catch {llength $procArgs}]} {
        errorMsg E "Argument list is not a valid list" $indexArgs 1
        set procArgs {}
    }
    # Do not loop $syn in the foreach command since it can be shorter
    set seenDefault 0
    set i -1
    set varNames {}
    foreach a $procArgs {
        incr i
        set var [lindex $a 0]
        lappend varNames $var
        if {[llength $a] > 1} {
            set seenDefault 1
            if {$var eq "args"} {
                errorMsg N "Default given to 'args'" $indexArgs 1
            }
        } elseif {$seenDefault && $var ne "args"} {
            errorMsg N "Non-default arg after default arg" $indexArgs 1
            # Reset to avoid further messages
            set seenDefault 0
        }
        knownVar knownVars $var
        dict set knownVars $var local 1
        dict set knownVars $var set   1
        SplitToken [lindex $syn $i] tok _ type _ _ _
        if {$type eq "" && $tok in {v n l}} {
            # The token indicates a variable name
            set type "varName"
        }
        dict set knownVars $var "type" $type
    }

    # Sanity check of argument names
    if {!$::Nagelfar(firstpass)} {
        # Check for non-last "args"
        set i [lsearch $varNames "args"]
        if {$i >= 0 && $i != [llength $procArgs] - 1} {
            errorMsg N "Argument 'args' used before last, which can be confusing" \
                    $indexArgs
        }
        # Check for duplicates
        set l1 [lsort $varNames]
        set l2 [lsort -unique $varNames]
        if {$l1 ne $l2} {
            errorMsg N "Duplicate proc arguments" $indexArgs
        }
    }
}

# Create a syntax definition from args list, and given the info
# about variables in the body.
proc parseArgsToSyn {name procArgs indexArgs syn knownVars} {

    if {[catch {llength $procArgs}]} {
        # This is reported elsewhere
        set procArgs {}
    }

    # Build a syntax description for the procedure.
    # Parse the arguments.
    set upvared 0
    set unlim 0
    set min 0
    set newsyntax {}
    foreach a $procArgs {
        set var [lindex $a 0]
        set type x

        # Check for any upvar in the proc
        if {[dict get $knownVars $var upvar] ne ""} {
            set other [dict get $knownVars $var upvar]
            if {[dict get $knownVars $other read]} {
                set type v
            } elseif {[dict get $knownVars $other set]} {
                set type n
            } else {
                set type l
            }
            set upvared 1
        }
        if {$var eq "args"} {
            set unlim 1
            set type x*
        } elseif {[llength $a] == 2} {
            append type .
        } else {
            incr min
        }
        lappend newsyntax $type
    }

    if {!$upvared} {
        if {$unlim} {
            set newsyntax [list r $min]
        } elseif {$min == [llength $procArgs]} {
            set newsyntax $min
        } else {
            set newsyntax [list r $min [llength $procArgs]]
        }
    }

    if {$syn ne ""} {
        # Check if it matches previously defined syntax
        set prevmin 0
        set prevmax 0
        set prevunlim 0
        if {[string is integer $syn]} {
            set prevmin $syn
            set prevmax $syn
        } elseif {[string match "r*" $syn]} {
            set prevmin [lindex $syn 1]
            set prevmax [lindex $syn 2]
            if {$prevmax == ""} {
                set prevmax $prevmin
                set prevunlim 1
            }
        } else {
            foreach token $syn {
                # Look for multi token
                if {[regexp {&.*(.)$} $token -> mod]} {
                    if {$mod == "?"} {
                        incr prevmax 2
                    } elseif {$mod == "*"} {
                        set prevunlim 1
                    }
                    continue
                }
                SplitToken $token tok tokCount _ mod n _
                if {$mod == ""} {
                    incr prevmin $n
                    incr prevmax $n
                } elseif {$mod == "?"} {
                        incr prevmax $n
                } elseif {$mod == "*"} {
                    set prevunlim 1
                } elseif {$mod == "."} {
                    incr prevmax $n
                }
            }
        }
        if {$prevunlim != $unlim || \
                ($prevunlim == 0 && $prevmax != [llength $procArgs]) \
                || $prevmin != $min} {
            errorMsg W "Procedure \"$name\" does not match previous definition" \
                    $indexArgs 1
            contMsg "Previous '$syn'  New '$newsyntax'"
            set newsyntax $syn
        } else {
            # It matched.  Does the new one seem better?
            if {[regexp {^(?:r )?\d+(?: \d+)?$} $syn]} {
                #if {$syntax($name) != $newsyntax} {
                #    decho "$name : Prev: '$syntax($name)'  New: '$newsyntax'"
                #}
                #                    decho "Syntax for '$name' : '$newsyntax'"
                #set syntax($name) $newsyntax
            } else {
                set newsyntax $syn
            }
        }
    } else {
        #            decho "Syntax for '$name' : '$newsyntax'"
        #set syntax($name) $newsyntax
    }
    return $newsyntax
}

# Look for implicit variables for the surrounding namespace
proc addImplicitVariablesNs {cmd index knownVarsName} {
    upvar $knownVarsName knownVars
    set cNs  [currentNamespace]
    set cNsC ${cNs}::[namespace tail $cmd]
    set impVar {}
    if {[info exists ::implicitVarNs($cNsC)]} {
        set impVar $::implicitVarNs($cNsC)
    } elseif {[info exists ::implicitVarNs($cNs)]} {
        set impVar $::implicitVarNs($cNs)
    } else {
        #decho "Looking for implicit in '$cNsC' '$cNs'"
        #parray ::implicitVarNs
    }
    #echo "addImplicitVariablesNs $cmd $impVar"
    foreach var $impVar {
        set varName [lindex $var 0]
        set type    [lindex $var 1]
        markVariable $varName 1 "" 1n \
                $index unknown knownVars type
        # not every implicit var is used inside a method
        # so always mark as used
        setVarUsed knownVars $varName
    }
}

# Look for implicit variables for this command
proc addImplicitVariablesCmd {cmd index knownVarsName} {
    if {[array size ::implicitVarCmd] == 0} return
    upvar $knownVarsName knownVars
    foreach pattern [array names ::implicitVarCmd] {
        set impVar {}
        if {[string match $pattern $cmd]} {
            eval lappend impVar $::implicitVarCmd($pattern)
        }
        foreach var $impVar {
            set varName [lindex $var 0]
            set type    [lindex $var 1]
            markVariable $varName 1 "" 1n \
                    $index unknown knownVars type
        }
    }
}

# This is called when a proc command is encountered.
# It is assumed that argv and indices has three elements.
proc parseProc {argv indices isProc isMethod definingCmd} {
    global knownGlobals syntax

    foreach {name argList body} $argv break

    set nameMethod ""
    if {$isMethod} {
        set currentObj [currentObject]
        if {$currentObj eq ""} {
            errorMsg N "Method definition without a current object" \
                    [lindex $indices 0]
            set isMethod 0
        } else {
            lappend ::subCmd($currentObj) $name
            #echo "Adding $::Nagelfar(firstpass) '$name' to '$currentObj' -> '$::subCmd($currentObj)'"
            set nameMethod "$currentObj $name"
        }
    }

    # Take care of namespace
    set cns [currentNamespace]
    set ns [namespace qualifiers $name]
    set tail [namespace tail $name]
    set storeIt $isProc
    if {![string match "::*" $ns]} {
        if {$cns eq "__unknown__"} {
            set ns $cns
            set storeIt 0
        } elseif {$ns != ""} {
            set ns ${cns}::$ns
        } else {
            set ns $cns
        }
    }
    set fullname ${ns}::$tail
    #decho "proc $name -> $fullname ($cns) ($ns) ($tail)"
    # Do not include the first :: in the name
    if {[string match ::* $fullname]} {
        set fullname [string range $fullname 2 end]
    }
    set name $fullname

    # Parse the arguments.
    # Initialise a knownVars dict with the arguments.
    set knownVars {}

    # Scan the syntax definition in parallel to look for types
    if {$isProc && [info exists syntax($name)]} {
        set syn $syntax($name)
    } elseif {$isMethod && [info exists syntax($nameMethod)]} {
        set syn $syntax($nameMethod)
    } else {
        set syn ""
    }

    parseArgs $argList [lindex $indices 1] $syn knownVars

    if {$storeIt} {
        lappend ::knownCommands $name
    }
    addImplicitVariablesNs $definingCmd [lindex $indices 0] knownVars

    # Look in the calling environment for known globals with types.
    # TODO: Better handling of known globals.
    upvar 1 "knownVars" envKnownVars
    dict for {var i} $envKnownVars {
        set type [dict get $i type]
        if {![dict get $i local] && $type ne ""} {
            dict set knownVars $var $i
        }
    }

#    decho "Note: parsing procedure $name"
    if {!$::Nagelfar(firstpass)} {
        if {$isProc} {
            pushNamespace $ns
        }
        pushProc $name
        parseBody $body [lindex $indices 2] knownVars
        if {[string trim $body] ne ""} {
            # check only if not an empty 'dummy' function
            checkForUnusedVar knownVars [lindex $indices 0]
        }
        popProc
        if {$isProc} {
            popNamespace
        }
    }
    instrumentL $indices $argv 2

    set newSyn [parseArgsToSyn $name $argList [lindex $indices 1] \
            $syn $knownVars]
    if {$storeIt} {
        set syntax($name) $newSyn
    }
    if {$isMethod} {
        if {[info exists syntax($nameMethod)]} {
            #echo "Overwriting $nameMethod from '$syn' with '$newSyn'"
        } else {
            #echo "Writing $nameMethod from '$syn' with '$newSyn'"
        }
        set syntax($nameMethod) $newSyn
    }

    # Update known globals with those that were set in the proc.
    # I.e. anyone with set == 1 and namespace == "" should be
    # added to known globals.
    foreach var [dict keys $knownVars] {
        if {[dict get $knownVars $var local]} continue
        if {![dict get $knownVars $var set]} continue
        set ns [dict get $knownVars $var namespace]
#        decho "Set global $var in ns $ns in proc $name."
        if {$ns eq "" && [lsearch $knownGlobals $var] == -1} {
            lappend knownGlobals $var
        }
    }
    return $newSyn
}

# Given an index in the original string, calculate its line number.
proc calcLineNo {ix} {
    global newlineIx

    # Shortcut for exact match, which happens when the index is first
    # in a line. This is common when called from wasIndented.
    set i [lsearch -integer -sorted $newlineIx $ix]
    if {$i >= 0} {
        return [expr {$i + 2}]
    }

    # Binary search
    if {$ix < [lindex $newlineIx 0]} {return 1}
    set first 0
    set last [expr {[llength $newlineIx] - 1}]
    if {$last < 0} {set last 0}

    while {$first < ($last - 1)} {
        set n [expr {($first + $last) / 2}]
        set ni [lindex $newlineIx $n]
        if {$ni < $ix} {
            set first $n
        } elseif {$ni > $ix} {
            set last $n
        } else {
            # Equality should have been caught in the lsearch above.
            decho "Internal error: Equal element slipped through in calcLineNo"
            return [expr {$n + 2}]
        }
    }
    return [expr {$last + 1}]
}

# Given an index in the original string, tell if that line was indented
# This should preferably be called with the index to the first char of
# the line since that case is much more efficient in calcLineNo.
proc wasIndented {i} {
    lindex $::indentInfo [calcLineNo $i]
}

# Length of initial whitespace
proc countIndent {str} {
    # Get whitespace
    set str [string range $str 0 end-[string length [string trimleft $str]]]
    # Any tabs?
    if {[string first \t $str] != -1} {
        # Only tabs in beginning?
        if {[regexp {^\t+[^\t]*$} $str]} {
            set str [string map $::Nagelfar(tabMap) $str]
        } else {
            regsub -all $::Nagelfar(tabReg) $str $::Nagelfar(tabSub) str
        }
    }
    return [string length $str]
}

# Build a database of newlines to be able to calculate line numbers.
# Also replace all escaped newlines with a space, and remove all
# whitespace from the start of lines. Later processing is greatly
# simplified if it does not need to bother with those.
# Returns the simplified script.
proc buildLineDb {str} {
    global newlineIx indentInfo

    set result ""
    set lines [split $str \n]
    if {[lindex $lines end] eq ""} {
        set lines [lrange $lines 0 end-1]
    }
    set newlineIx {}
    # Dummy element to get 1.. indexing
    set indentInfo [list {}]

    # Detect a header.  Backslash-newline is not substituted in the header,
    # and the index after the header is kept.  This is to preserve the header
    # in code coverage mode.
    # The first non-empty non-comment line ends the header.
    set ::instrumenting(header) 0
    set ::instrumenting(already) 0
    set headerLines 1
    set previousWasEscaped 0

    # This is a trick to get "sp" and "nl" to get an internal string rep.
    # This also makes sure it will not be a shared object, which can mess up
    # the internal rep.
    # Append works a lot better that way.
    set sp [string range " " 0 0]
    set nl [string range \n 0 0]
    set lineNo 0
    set lastCmdLine ""
    set knownVars {}

    foreach line $lines {
        incr lineNo

        if {$::Nagelfar(pluginLineRaw)} {
            pluginHandleLineRaw line knownVars [string length $result]
        }

        # Count indent spaces and remove them
        set indent [countIndent $line]
        set line [string trimleft $line]
        if {$::Nagelfar(lineLen) > 0} {
            if {$indent + [string length $line] > $::Nagelfar(lineLen)} {
                errorMsg W "Too long line" [string length $result]
            }
        }
        if {!$previousWasEscaped} {
            set lastCmdLine $line
        }
        # Check for comments.
        if {[string index $line 0] eq "#"} {
            # Make notes about unbalanced braces in comments
            checkPossibleComment $line $lineNo
            # A # in the middle of backslash-newline rows is suspicious.
            if {$previousWasEscaped} {
                if {[string index $lastCmdLine 0] ne "#"} {
                    errorMsg N "Suspicious \# char. Possibly a bad comment." \
                            [string length $result]
                }
            }
        }
        # Keep track of the leading comment lines (header) to preserve them
        # when instrumenting for coverage.
        if {[string index $line 0] eq "#" && \
                    ![string match "##nagelfar *" $line]} {
            # Do nothing, this can be a header line
            # Inline comment pragmas are not considered part of a header
        } elseif {$headerLines && $line ne "" && !$previousWasEscaped} {
            set headerLines 0
            set ::instrumenting(header) [string length $result]
            if {$line eq "namespace eval ::_instrument_ {}"} {
                set ::instrumenting(already) 1
            }
        }

        # Count backslashes to determine if it's escaped
        set previousWasEscaped 0
        if {[string index $line end] eq "\\"} {
            set len [string length $line]
            set si [expr {$len - 2}]
            while {[string index $line $si] eq "\\"} {incr si -1}
            if {($len - $si) % 2 == 0} {
                # An escaped newline
                set previousWasEscaped 1
                if {!$headerLines} {
                    append result [string range $line 0 end-1] $sp
                    lappend newlineIx [string length $result]
                    lappend indentInfo $indent
                    continue
                }
            }
        }
        # Unescaped newline
        # It's important for performance that all elements in append
        # has an internal string rep. String index takes care of $line
        append result $line $nl
        lappend newlineIx [string length $result]
        lappend indentInfo $indent
    }
    if {$::Nagelfar(gui)} {progressMax $lineNo}
    return $result
}

# Parse a global script
proc parseScript {script} {
    global knownGlobals unknownCommands knownCommands syntax

    catch {unset unknownCommands}
    set unknownCommands {}
    set knownVars {}
    array set ::knownAliases {}
    array set ::namespacePaths {}
    foreach g $knownGlobals {
        knownVar knownVars $g
        dict set knownVars $g set 1
    }
    set ::Nagelfar(firstpass) 0
    set script [buildLineDb $script]
    set ::instrumenting(script) $script

    pushNamespace {}
    if {$::Nagelfar(2pass)} {
        # First do one round with proc checking
        set ::Nagelfar(firstpass) 1
        parseBody $script 0 knownVars
        #echo "Second pass"
        set ::Nagelfar(firstpass) 0
    }
    parseBody $script 0 knownVars
    popNamespace

    # Check commands that where unknown when encountered
    # FIXA: aliases
    foreach apa $unknownCommands {
        foreach {cmd cmds index} $apa break
        set found 0
        foreach cmdCandidate $cmds {
            if {[info exists syntax($cmdCandidate)] || \
                    [lsearch $knownCommands $cmdCandidate] >= 0} {
                set found 1
                break
            }
        }
        if {!$found} {
            # Close brace is reported elsewhere
            if {$cmd ne "\}"} {
                # Different messages depending on name
                if {[regexp {^(?:(?:[\w',:.-]+)|(?:%W))$} $cmd]} {
                    errorMsg W "Unknown command \"$cmd\"" $index
                } else {
                    errorMsg E "Strange command \"$cmd\"" $index
                }
                if {$::Nagelfar(pluginUnknownCommand)} {
                    pluginHandleUnknownCommand cmd knownVars $index
                }
            }
        }
    }
    # Update known globals.
    # FIXA: This should transfer any known types
    foreach var [dict keys $knownVars] {
        if {[dict get $knownVars $var namespace] != ""} continue
        if {[dict get $knownVars $var local]} continue
        # Check if it has been set.
        if {[dict get $knownVars $var set]} {
            if {[lsearch $knownGlobals $var] == -1} {
                lappend knownGlobals $var
            }
        }
    }
}

# Parse a file
proc parseFile {filename} {
    set ch [open $filename]
    if {[info exists ::Nagelfar(encoding)] && \
            $::Nagelfar(encoding) ne "system"} {
        fconfigure $ch -encoding $::Nagelfar(encoding)
    }
    if {[catch {
        set script [read $ch]
    }]} {
        close $ch
        set ch [open $filename]
        fconfigure $ch -profile replace
        if {[info exists ::Nagelfar(encoding)] && \
                $::Nagelfar(encoding) ne "system"} {
            fconfigure $ch -encoding $::Nagelfar(encoding)
        }
        set script [read $ch]
    }
    close $ch

    # Check for Ctrl-Z
    set i [string first \u001a $script]
    if {$i >= 0} {
        # Cut off the script as source would do
        set script [string range $script 0 [expr {$i - 1}]]
    }

    array unset ::instrumenting

    # Special case
    if {[file tail $filename] eq "pkgIndex.tcl"} {
        # Know about dir variable
        lappend ::knownGlobals dir
    }

    initMsg
    parseScript $script
    if {$i >= 0} {
        # Add a note about the Ctrl-Z
        errorMsg N "Aborted script due to end-of-file marker" \
                [expr {[string length $::instrumenting(script)] - 1}]
    }
    flushMsg

    if {$::Nagelfar(instrument) && \
            [file extension $filename] ne ".syntax"} {
        # Experimental instrumenting
        dumpInstrumenting $filename
    }
}

# Find an element that is less than or equal, in a decreasing sorted list
proc binSearch {sortedList ix} {
    # Shortcut for exact match
    set i [lsearch -decreasing -integer -sorted $sortedList $ix]
    if {$i >= 0} {
        return $i
    }

    # Binary search
    if {$ix > [lindex $sortedList 0]} {return 0}
    set first 0
    set last [expr {[llength $sortedList] - 1}]
    if {$ix < [lindex $sortedList end]} {return -1}

    while {$first < ($last - 1)} {
        set n [expr {($first + $last) / 2}]
        set ni [lindex $sortedList $n]
        if {$ni > $ix} {
            set first $n
        } elseif {$ni < $ix} {
            set last $n
        } else {
            # Equality should have been caught in the lsearch above.
            decho "Internal error: Equal element slipped through in binSearch"
            return [expr {$n + 1}]
        }
    }
    return $last
}

# Store information for instrumenting
# TODO: Maybe replace these with dummies when instrumenting is off?
proc instrument {index value body} {
    set ::instrumenting($index) $value
    # Remember the end of block
    set ::instrumenting(end,$index) [expr {$index + [string length $body] -1}]
}
# List version of instrument, since many callers need this structure.
proc instrumentL {indices argv i} {
    instrument [lindex $indices $i] 1 [lindex $argv $i]
}

# Decide for an identifying name for a file.
# TODO: Maybe use whole path? Does it matter?
proc instrumentId {filename tailName idStringName baseName} {
    upvar 1 $tailName tail $idStringName idString $baseName base
    set fullname [file normalize [file join [pwd] $filename]]
    set tail [file tail $fullname]
    set parts [file split $fullname]
    set lastParts [lrange $parts end-2 end]
    set idString [file join {*}$lastParts]
    set base $filename
    if {$::Nagelfar(idir) ne ""} {
        file mkdir $::Nagelfar(idir)
        # TODO: Should any part of file's path be included under idir?
        set base [file join $::Nagelfar(idir) $tail]
    }
}

# Write source instrumented for code coverage
proc dumpInstrumenting {filename} {
    instrumentId $filename tail idString base
    if {$::instrumenting(already)} {
        echo "Warning: Instrumenting already instrumented file $tail"
    }
    set iFile ${base}_i
    set logFile ${base}_log
    echo "Writing file $iFile" 1
    set iscript $::instrumenting(script)
    set indices {}
    foreach item [array names ::instrumenting] {
        if {[string is digit $item]} {
            lappend indices $item
        }
    }
    set indices [lsort -decreasing -integer $indices]
    # Look for lines marked with nocover
    foreach item [array names ::instrumenting no,*] {
        set index [lindex [split $item ","] end]
        set i [binSearch $indices $index]
        if {$i < 0} continue
        # Default range to delete is one item
        set iEnd $i
        # Any end to extend range to?
        set indexStart [lindex $indices $i]
        if {[info exists ::instrumenting(end,$indexStart)]} {
            set indexEnd $::instrumenting(end,$indexStart)
            set i2 [binSearch $indices $indexEnd]
            if {$i2 >= 0 && $i2 <= $i} {
                set iEnd $i2
            }
        }
        # Indices are decreasing so iEnd is first
        set indices [lreplace $indices $iEnd $i]
    }
    set init {}
    lappend init [list set current $idString]
    lappend init [list set idir $::Nagelfar(idir)]
    lappend init [list set "logFile" $logFile]
    set headerIndex $::instrumenting(header)
    foreach ix $indices {
        # Indices goes backwards here, so when reaching headerIndex we are done
        if {$ix <= $headerIndex} break
        set line [calcLineNo $ix]
        set item "$idString,$line"
        set i 2
        while {[info exists done($item)]} {
            set item "$idString,$line,$i"
            incr i
        }
        set done($item) 1
        set default 0

        if {[llength $::instrumenting($ix)] > 1} {
            foreach {type varname} $::instrumenting($ix) break
            set endix [string first \n $iscript $ix]
            set pre [string range $iscript 0 [expr {$ix - 1}]]
            set post [string range $iscript $endix end]
            append item ",var"
            set insert "[list lappend ::_instrument_::log($item)] \$[list $varname]"
            set default {}
        } elseif {$::instrumenting($ix) == 2} {
            # Missing else clause
            if {[string index $iscript $ix] eq "\}"} {
                incr ix
            }
            # To make the instrumentation side effect free the else clause
            # returns an empty string by adding the "list" command at the end.
            set insert [list incr ::_instrument_::log($item)]\;list
            set insert " [list else $insert]"
            set pre [string range $iscript 0 [expr {$ix - 1}]]
            set post [string range $iscript $ix end]
        } else {
            # Normal
            set insert [list incr ::_instrument_::log($item)]\;
            set pre [string range $iscript 0 [expr {$ix - 1}]]
            set post [string range $iscript $ix end]

            set c [string index $pre end]
            if {$c ne "\[" && $c ne "\{" && $c ne "\"" && $c ne "+"} {
                if {[regexp {^(\s*\w+)(\s.*)$} $post -> word rest]} {
                    append pre "\{"
                    set post "$word\}$rest"
                } else {
                    echo "Not instrumenting line: $line\
                            [string range $pre end-5 end]<>[string range $post 0 5]"
                    continue
                }
            }
        }
        set iscript $pre$insert$post

        lappend init [list set log($item) $default]
    }
    set ch [open $iFile w]
    if {[info exists ::Nagelfar(encoding)] && \
            $::Nagelfar(encoding) ne "system"} {
        fconfigure $ch -encoding $::Nagelfar(encoding)
    }
    # Start with a copy of the original's header
    if {$headerIndex > 0} {
        puts $ch [string range $iscript 0 [expr {$headerIndex - 1}]]
        set iscript [string range $iscript $headerIndex end]
    }
    # Create a prolog equal in all instrumented files
    # The first line is indented with one space to make it detectable when
    # looking for an instrumented file
    puts $ch { namespace eval ::_instrument_ {}}
    puts $ch [list set ::_instrument_::replaceSource \
                      [expr {!$::Nagelfar(nosource)}]]
    puts $ch [info body _instrumentProlog1]
    # Insert file specific info
    # This is only initialised first time a file is sourced
    puts $ch "if {!\[[list info exists ::_instrument_::doneFile($idString)]\]} \{"
    puts $ch [list set ::_instrument_::doneFile($idString) 1]

    puts $ch "# Initialise list of lines"
    puts $ch "namespace eval ::_instrument_ \{"
    puts $ch [join $init \n]
    puts $ch "\}"
    # More common prolog for file specific stuff
    puts $ch [info body _instrumentProlog2]

    # End of the if doneFile block
    puts $ch "\}"

    puts $ch "\#instrumented source goes here"
    puts $ch $iscript
    close $ch

    # Copy permissions to instrumented file.
    catch {file attributes $iFile -permissions \
            [file attributes $filename -permissions]}
}

# The body of this procedure is used as common code in instrumented files
# It is stored in a proc to be able to treat it as code in indentation and
# syntax checking.
proc _instrumentProlog1 {} {
    # Defining help procedures should be done once even if multiple
    # instrumented files are loaded, so check if it has been done.
    if {[info commands ::_instrument_::flock] == ""} {
        if {$::_instrument_::replaceSource} {
            rename ::source ::_instrument_::source
            ##nagelfar ignore does not match previous
            proc ::source {args} {
                set fileName [lindex $args end]
                set args [lrange $args 0 end-1]
                set newFileName $fileName
                set altFileNames [list ${fileName}_i]
                if {$::_instrument_::idir ne ""} {
                    lappend altFileNames [file join $::_instrument_::idir \
                                                  [file tail $fileName]_i]
                }
                foreach altFileName $altFileNames {
                    if {[file exists $altFileName]} {
                        set newFileName $altFileName
                    }
                }
                set args [linsert $args 0 ::_instrument_::source]
                lappend args $newFileName
                uplevel 1 $args
            }
        }
        rename ::exit ::_instrument_::exit
        ##nagelfar ignore does not match previous
        proc ::exit {args} {
            ::_instrument_::cleanup
            uplevel 1 [linsert $args 0 ::_instrument_::exit]
        }
        ##nagelfar syntax _instrument_::flock x c
        proc ::_instrument_::flock {filename cmds} {
            set lck ${filename}.lck
            set i 0
            while { [catch {open $lck {WRONLY CREAT EXCL}} lock] } {
                incr i
                after 250
                if {$i > 9} {
                    # Warn about this but continue with next file.
                    # Since we are in instrumented code we only have access
                    # to stdout for this warning.
                    puts "Warning: Could not acquire lock '$lck' in $i tries!"
                    puts "Warning: Results from '$filename' will be lost!"
                    return
                }
            }
            # Should use try in 8.6
            set errCode [catch { uplevel 1 $cmds } errMsg]
            # finally
            close $lock
            file delete $lck
            if {$errCode} {
                return -code $errCode $errMsg
            }
        }
        proc ::_instrument_::cleanup {} {
            variable log
            variable all
            variable dumpList
            foreach {src logFile} $dumpList {
                flock $logFile {
                    # The log consists of incr/lappend commands so eval:ing it
                    # merges those results with current data
                    if {[file exists $logFile]} {
                        # Avoid source command
                        set ch [open $logFile r]
                        set logdata [read $ch]
                        close $ch
                        eval $logdata
                    }
                    set ch [open $logFile w]
                    foreach item [lsort -dictionary [array names log $src,*]] {
                        if {[string match *,var $item]} {
                            # Variable coverage is a list, not a number
                            puts $ch [linsert $::_instrument_::log($item) 0 \
                                    lappend ::_instrument_::log($item)]
                        } else {
                            puts $ch [list incr ::_instrument_::log($item) \
                                              $::_instrument_::log($item)]
                        }
                        set ::_instrument_::log($item) 0
                    }
                    close $ch
                }
            }
        }
    }
}

# The body of this procedure is used as common code in instrumented files
# It is stored in a proc to be able to treat it as code in indentation and
# syntax checking.
# Variables dumpList and current are known where this code is run, this is
# emulated by making them arguments.
proc _instrumentProlog2 {dumpList current logFile} {
    # Store information about this particular file for later use in cleanup
    namespace eval ::_instrument_ {
        lappend dumpList $current $logFile
    }
}

# Add Code Coverage markup to a file according to measured coverage
proc instrumentMarkup {filename full} {
    instrumentId $filename tail idString base
    set logFile ${base}_log
    set mFile ${base}_m

    namespace eval ::_instrument_ {}
    source $logFile
    set covered 0
    set noncovered 0
    foreach item [array names ::_instrument_::log $idString,*] {
        if {[string match "*,var" $item]} {
            set values [lsort -dictionary -unique $::_instrument_::log($item)]
            # FIXA: Maybe support expected values check
            if {[regexp {,(\d+),\d+,var$} $item -> line]} {
                set lines($line) ";# $values"
            } elseif {[regexp {,(\d+),var$} $item -> line]} {
                set lines($line) ";# $values"
            }
            continue
        }
        if {$::_instrument_::log($item) != 0} {
            incr covered
            # Markup covered only if full is requested
            if {$full} {
                if {[regexp {,(\d+),\d+$} $item -> line]} {
                    set lines($line) \
                            " ;# Reached $::_instrument_::log($item) times"
                } elseif {[regexp {,(\d+)$} $item -> line]} {
                    set lines($line) \
                            " ;# Reached $::_instrument_::log($item) times"
                }
            }
            continue
        }
        incr noncovered
        if {[regexp {,(\d+),\d+$} $item -> line]} {
            set lines($line) " ;# Not covered"
        } elseif {[regexp {,(\d+)$} $item -> line]} {
            set lines($line) " ;# Not covered"
        }
    }
    set total [expr {$covered + $noncovered}]
    if {$total == 0} {
        set coverage 100.0
    } else {
        set coverage [expr {100.0 * $covered / $total}]
    }
    set stats [format "(%d/%d %4.1f%%)" \
            $covered $total $coverage]
    echo "Writing file $mFile $stats" 1
    if {[array size lines] == 0} {
        echo "All lines covered in $tail"
        file copy -force $filename $mFile
        return
    }

    set chi [open $filename r]
    set cho [open $mFile w]
    if {[info exists ::Nagelfar(encoding)] && \
            $::Nagelfar(encoding) ne "system"} {
        fconfigure $chi -encoding $::Nagelfar(encoding)
        fconfigure $cho -encoding $::Nagelfar(encoding)
    }
    set lineNo 1
    while {[gets $chi line] >= 0} {
        if {$line eq " namespace eval ::_instrument_ {}"} {
            echo "File $filename is instrumented, aborting markup"
            close $chi
            close $cho
            file delete $mFile
            return
        }
        if {[info exists lines($lineNo)]} {
            append line $lines($lineNo)
        }
        puts $cho $line
        incr lineNo
    }
    close $chi
    close $cho
}

# Add a message filter
proc addFilter {pat {start_line -1} {end_line -1} {reapply 0}} {
    set flt [list $pat $start_line $end_line]
    if {[lsearch -exact $::Nagelfar(filter) $flt] < 0} {
        lappend ::Nagelfar(filter) $flt
    }
    if {$reapply} {
        set w $::Nagelfar(resultWin)
        $w configure -state normal
        set ln 1
        while {1} {
            set tags [$w tag names $ln.0]
            set tag [lsearch -glob -inline $tags "message*"]
            if {$tag == ""} {
                set range [list $ln.0 $ln.end+1c]
                set line [$w get $ln.0 $ln.end]
            } else {
                set range [$w tag nextrange $tag $ln.0]
                if {$range == ""} {
                    incr ln
                    if {[$w index end] <= $ln} {
                        break
                    }
                    continue
                }
                set line [eval \$w get $range]
            }
            if {[string match $pat $line]} {
                eval \$w delete $range
            } else {
                incr ln
            }
            if {[$w index end] <= $ln} break
        }
        $w configure -state disabled
    }
}

# Clear out all filters
proc resetFilters {} {
    set ::Nagelfar(filter) {}
}

# FIXA: Move safe reading to package
##nagelfar syntax _ipsource x
##nagelfar syntax _ipexists l
##nagelfar syntax _ipset    1: v : n x
##nagelfar syntax _iplappend n x*
##nagelfar syntax _iparray  s v
##nagelfar subcmd _iparray  exists get

# Load syntax database using safe interpreter
proc loadDatabases {{addDb {}}} {
    if {[interp exists loadinterp]} {
        interp delete loadinterp
    }
    interp create -safe loadinterp
    interp expose loadinterp source
    interp alias {} _ipsource loadinterp source
    interp alias {} _ipexists loadinterp info exists
    interp alias {} _ipset    loadinterp set
    interp alias {} _ipeval   loadinterp eval
    interp alias {} _iplappend loadinterp lappend
    interp alias {} _iparray  loadinterp array
    if {$addDb ne ""} {
        set dbs [list $addDb]
    } else {
        set dbs $::Nagelfar(db)
    }

    set intDb [info exists ::Nagelfar(dbContents)]
    if {$intDb} {
        set dbs [list $::Nagelfar(dbContents)]
    }

    foreach f $dbs {
        # FIXA: catch?
        if {$intDb} {
            _ipeval $f
        } else {
            _ipsource $f
        }

        # Support inline comments in db file
        if {$intDb} {
            set data $f
            set f "_internal_"
        } else {
            set ch [open $f r]
            set data [read $ch]
            close $ch
        }
        if {[string first "##nagelfar" $data] < 0} continue
        set lines [split $data \n]
        set commentlines [lsearch -all $lines "*##nagelfar*"]
        foreach commentline $commentlines {
            set comment [lindex $lines $commentline]
            set str [string trim $comment]
            if {![string match "##nagelfar *" $str]} continue

            # Increase to make a line number from the index
            incr commentline
            set rest [string range $str 11 end]
            if {[catch {llength $rest}]} {
                echo "Bad list in ##nagelfar comment in db $f line $commentline"
                continue
            }
            if {[llength $rest] == 0} continue
            set cmd [lindex $rest 0]
            set first [lindex $rest 1]
            set rest [lrange $rest 2 end]
            switch -- $cmd {
                syntax {
                    _ipset ::syntax($first) $rest
                    _iplappend ::knownCommands $first
                }
                implicitvarns {
                    _ipset ::implicitVarNs($first) $rest
                }
                implicitvarcmd {
                    _ipset ::implicitVarCmd($first) $rest
                }
                return {
                    _ipset ::return($first) $rest
                }
                subcmd {
                    _ipset ::subCmd($first) $rest
                }
                subcmd+ {
                    eval [list _iplappend "::subCmd($first)"] $rest
                }
                package {
                    if {$first eq "known"} {
                        eval _iplappend ::knownPackages $rest
                    } else {
                        # Note: require not allowed here yet...
                        if {!$::Nagelfar(firstpass)} {
                            echo "Bad type in ##nagelfar comment in db $f line $commentline"
                        }
                    }
                }
                option {
                    _ipset ::option($first) $rest
                }
                option+ {
                    eval [list _iplappend "::option($first)"] $rest
                }
                alias {
                    _ipset ::knownAliases($first) $rest
                }
                nspath {
                    eval [list _iplappend "::namespacePath($first)"] $rest
                }
                default {
                    echo "Bad type in ##nagelfar comment in db $f line $commentline"
                    continue
                }
            }
        }
    }
    if {$addDb eq ""} {
        # Clean up if we are loading all databases
        set ::knownGlobals {}
        set ::knownCommands {}
        set ::knownPackages {}
    }

    if {[_ipexists ::knownGlobals]} {
        eval lappend ::knownGlobals [_ipset ::knownGlobals]
    }
    if {[_ipexists ::knownCommands]} {
        eval [linsert [_ipset ::knownCommands] 0 lappend "::knownCommands"]
    }
    if {[_ipexists ::knownPackages]} {
        eval lappend ::knownPackages [_ipset ::knownPackages]
    }
    if {[_ipexists ::dbInfo]} {
        set ::Nagelfar(dbInfo) [join [_ipset ::dbInfo] \n]
    } else {
        set ::Nagelfar(dbInfo) {}
    }
    if {[_ipexists ::dbTclVersion]} {
        set ::Nagelfar(dbTclVersion) [_ipset ::dbTclVersion]
    } else {
        set ::Nagelfar(dbTclVersion) [package present Tcl]
    }
    if {$addDb eq ""} {
        # Clean up if we are loading all databases
        catch {unset ::syntax}
        catch {unset ::implicitVarNs}
        catch {unset ::implicitVarCmd}
        catch {unset ::return}
        catch {unset ::subCmd}
        catch {unset ::option}
        catch {unset ::knownAliases}
        catch {unset ::namespacePath}
    }
    if {[_iparray exists ::syntax]} {
        array set ::syntax [_iparray get ::syntax]
    }
    if {[_iparray exists ::implicitVarNs]} {
        array set ::implicitVarNs [_iparray get ::implicitVarNs]
    }
    if {[_iparray exists ::implicitVarCmd]} {
        array set ::implicitVarCmd [_iparray get ::implicitVarCmd]
    }
    if {[_iparray exists ::return]} {
        array set ::return [_iparray get ::return]
    }
    if {[_iparray exists ::subCmd]} {
        array set ::subCmd [_iparray get ::subCmd]
    }
    if {[_iparray exists ::option]} {
        array set ::option [_iparray get ::option]
    }
    if {[_iparray exists ::knownAliases]} {
        array set ::knownAliases [_iparray get ::knownAliases]
    }
    if {[_iparray exists ::namespacePath]} {
        array set ::knownAliases [_iparray get ::namespacePath]
    }

    interp delete loadinterp

    if {$::Prefs(strictAppend)} {
        set ::syntax(lappend) [string map {n v} $::syntax(lappend)]
        set ::syntax(append) [string map {n v} $::syntax(append)]
    }
}

# Look for a database file for a package and load it if found.
# This is called when a package require is detected
proc lookForPackageDb {pName i} {
    if {[lsearch -exact $::knownPackages $pName] >= 0} {
        #errorMsg N "Seeing known package $pName" $i
        return
    }
    set fileName [string tolower [string map ":: _" $pName]]db.tcl
    set found 0
    foreach db $::Nagelfar(allDb) {
        if {$fileName eq $db || $fileName eq [file tail $db]} {
            loadDatabases $db
            #errorMsg N "Loaded db for package $pName" $i
            set found 1
            break
        }
    }
    if {$found} {
        # Double check if it is marked as known
        if {[lsearch -exact $::knownPackages $pName] < 0} {
            lappend ::knownPackages $pName
            if {$::Nagelfar(pkgpicky)} {
                errorMsg N "Package database for '$pName' not marked as known" \
                        $i
            }
        }
    } else {
        if {$::Nagelfar(pkgpicky)} {
            errorMsg N "No info on package '$pName' found" $i
        }
    }
}

# Execute the checks
proc doCheck {} {
    set intDb [info exists ::Nagelfar(dbContents)]
    if {!$intDb && [llength $::Nagelfar(db)] == 0} {
        if {$::Nagelfar(gui)} {
            tk_messageBox -title "Nagelfar Error" -type ok -icon error \
                    -message "No syntax database file selected"
            return
        } else {
            puts stderr "No syntax database file found"
            exit 3
        }
    }

    set int [info exists ::Nagelfar(scriptContents)]

    if {!$int && [llength $::Nagelfar(files)] == 0} {
        errEcho "No files to check"
        return
    }

    if {$::Nagelfar(gui)} {
        allowStop
        busyCursor
    }

    if {!$int} {
        set ::Nagelfar(editFile) ""
    }
    if {[info exists ::Nagelfar(resultWin)]} {
        $::Nagelfar(resultWin) configure -state normal
        $::Nagelfar(resultWin) delete 1.0 end
    }
    set ::Nagelfar(messageCnt) 0

    # Load syntax databases
    loadDatabases

    # In header generation, store info before reading
    if {$::Nagelfar(header) ne ""} {
        array set h_oldsyntax [array get ::syntax]
        array set h_oldsubCmd [array get ::subCmd]
        array set h_oldoption [array get ::option]
        array set h_oldreturn [array get ::return]
        array set h_oldimplicitvarns [array get ::implicitVarNs]
        array set h_oldimplicitvarcmd [array get ::implicitVarCmd]
        array set h_oldaliases [array get ::knownAliases]
        array set h_oldnspath [array get ::namespacePath]
        set h_oldknownpackages $::knownPackages
    }

    # Initialise variables
    set ::Nagelfar(namespaces) {}
    set ::Nagelfar(procs) {}
    set ::Nagelfar(object) ""

    # Do the checking

    set ::currentFile ""
    set ::Nagelfar(exitstatus) 0
    if {$int} {
        initMsg
        parseScript $::Nagelfar(scriptContents)
        flushMsg
    } else {
        foreach f $::Nagelfar(files) {
            if {$::Nagelfar(stop)} break
            if {$::Nagelfar(gui) || [llength $::Nagelfar(files)] > 1 || \
                    $::Prefs(prefixFile)} {
                set ::currentFile $f
            }
            set syntaxfile [file rootname $f].syntax
            if {[file exists $syntaxfile]} {
                if {!$::Nagelfar(quiet)} {
                    echo "Parsing file $syntaxfile" 1
                }
                parseFile $syntaxfile
            }
            if {$f == $syntaxfile} continue
            if {[file isfile $f] && [file readable $f]} {
                if {!$::Nagelfar(quiet)} {
                    echo "Checking file $f" 1
                }
                parseFile $f
            } else {
                errEcho "Could not find file '$f'"
            }
        }
    }
    # Generate header
    if {$::Nagelfar(header) ne ""} {
        # Exclude everything that was there from the syntax database
        foreach item [array names h_oldsyntax] {
            if {$h_oldsyntax($item) eq $::syntax($item)} {
                unset ::syntax($item)
            }
        }
        foreach item [array names h_oldsubCmd] {
            if {$h_oldsubCmd($item) eq $::subCmd($item)} {
                unset ::subCmd($item)
            }
        }
        foreach item [array names h_oldoption] {
            if {$h_oldoption($item) eq $::option($item)} {
                unset ::option($item)
            }
        }
        foreach item [array names h_oldreturn] {
            if {$h_oldreturn($item) eq $::return($item)} {
                unset ::return($item)
            }
        }
        foreach item [array names h_oldimplicitvarns] {
            if {$h_oldimplicitvarns($item) eq $::implicitVarNs($item)} {
                unset ::implicitVarNs($item)
            }
        }
        foreach item [array names h_oldimplicitvarcmd] {
            if {$h_oldimplicitvarcmd($item) eq $::implicitVarCmd($item)} {
                unset ::implicitVarCmd($item)
            }
        }
        foreach item [array names h_oldaliases] {
            if {$h_oldaliases($item) eq $::knownAliases($item)} {
                unset ::knownAliases($item)
            }
        }
        foreach item [array names h_oldnspath] {
            if {$h_oldnspath($item) eq $::namespacePath($item)} {
                unset ::namespacePath($item)
            }
        }

        if {[catch {set ch [open $::Nagelfar(header) w]}]} {
            puts stderr "Could not create file \"$::Nagelfar(header)\""
        } else {
            echo "Writing \"$::Nagelfar(header)\"" 1
            foreach item $::knownPackages {
                if {[lsearch -exact $h_oldknownpackages $item] < 0} {
                    # TODO: Exclude autoloaded package info from header
                    # file and emit package require instead.
                    puts $ch "\#\#nagelfar [list package known $item]"
                }
            }
            foreach item [lsort -dictionary [array names ::syntax]] {
                puts $ch "\#\#nagelfar [list syntax $item] $::syntax($item)"
            }
            foreach item [lsort -dictionary [array names ::subCmd]] {
                puts $ch "\#\#nagelfar [list subcmd $item] $::subCmd($item)"
            }
            foreach item [lsort -dictionary [array names ::option]] {
                puts $ch "\#\#nagelfar [list option $item] $::option($item)"
            }
            foreach item [lsort -dictionary [array names ::return]] {
                puts $ch "\#\#nagelfar [list return $item] $::return($item)"
            }
            foreach item [lsort -dictionary [array names ::implicitVarNs]] {
                puts $ch "\#\#nagelfar [list implicitvarns $item] $::implicitVarNs($item)"
            }
            foreach item [lsort -dictionary [array names ::implicitVarCmd]] {
                puts $ch "\#\#nagelfar [list implicitvarcmd $item] $::implicitVarCmd($item)"
            }
            foreach item [lsort -dictionary [array names ::knownAliases]] {
                puts $ch "\#\#nagelfar [list alias $item] $::knownAliases($item)"
            }
            foreach item [lsort -dictionary [array names ::namespacePath]] {
                puts $ch "\#\#nagelfar [list nspath $item] $::namespacePath($item)"
            }
            pluginHandleWriteHeader $ch
            close $ch
        }
    }
    initMsg
    finalizePlugin
    flushMsg
    if {$::Nagelfar(gui)} {
        if {[info exists ::Nagelfar(resultWin)]} {
            set result [$::Nagelfar(resultWin) get 1.0 end-1c]
            set n [regsub -all {Line\s+\d+: N } $result "" ->]
            set w [regsub -all {Line\s+\d+: W } $result "" ->]
            set e [regsub -all {Line\s+\d+: E } $result "" ->]
            # show statistics depending on severity level
            switch $::Prefs(severity) {
                N {echo "Done (E/W/N: $e/$w/$n)" 1}
                W {echo "Done (E/W: $e/$w)" 1}
                E {echo "Done (E: $e)" 1}
            }
        } else {
            echo "Done" 1
        }
        normalCursor
        progressUpdate -1
    }
}
#----------------------------------------------------------------------
#  Nagelfar, a syntax checker for Tcl.
#  Copyright (c) 1999-2022, Peter Spjuth
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING.  If not, write to
#  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#  Boston, MA 02110-1301, USA.
#
#----------------------------------------------------------------------
# gui.tcl
#----------------------------------------------------------------------

##nagelfar variable ::Nagelfar(resultWin) _obj,text

proc busyCursor {} {
    if {![info exists ::oldcursor]} {
        set ::oldcursor  [. cget -cursor]
        set ::oldcursor2 [$::Nagelfar(resultWin) cget -cursor]
    }

    . config -cursor watch
    $::Nagelfar(resultWin) configure -cursor watch
}

proc normalCursor {} {
    . config -cursor $::oldcursor
    $::Nagelfar(resultWin) configure -cursor $::oldcursor2
}

proc exitApp {} {
    exit
}

# Browse for and add a syntax database file
proc addDbFile {} {
    if {[info exists ::Nagelfar(lastdbdir)]} {
        set initdir $::Nagelfar(lastdbdir) 
    } elseif {[info exists ::Nagelfar(lastdir)]} {
        set initdir $::Nagelfar(lastdir)
    } else {
        set initdir [pwd]
    }
    set apa [tk_getOpenFile -title "Select db file" \
            -initialdir $initdir]
    if {$apa == ""} return

    lappend ::Nagelfar(db) $apa
    lappend ::Nagelfar(allDb) $apa
    lappend ::Nagelfar(allDbView) $apa
    updateDbSelection -fromvar
    set ::Nagelfar(lastdbdir) [file dirname $apa]
}

# File drop using TkDnd
proc fileDropDb {files} {
    foreach file $files {
        set file [fileRelative [pwd] $file]
        lappend ::Nagelfar(db) $file
        lappend ::Nagelfar(allDb) $file
        lappend ::Nagelfar(allDbView) $file
    }
    updateDbSelection -fromvar
}

# Remove a file from the database list
proc removeDbFile {} {
    set ixs [lsort -decreasing -integer [$::Nagelfar(dbWin) curselection]]
    foreach ix $ixs {
        set ::Nagelfar(allDb) [lreplace $::Nagelfar(allDb) $ix $ix]
        set ::Nagelfar(allDbView) [lreplace $::Nagelfar(allDbView) $ix $ix]
    }
    updateDbSelection
    updateDbSelection -fromvar
}

# Browse for and add a file to check.
proc addFile {} {
    if {[info exists ::Nagelfar(lastdir)]} {
        set initdir $::Nagelfar(lastdir)
    } elseif {[info exists ::Nagelfar(lastdbdir)]} {
        set initdir $::Nagelfar(lastdbdir) 
    } else {
        set initdir [pwd]
    }
    
    set filetypes [list {{Tcl Files} {.tcl}} \
            [list {All Tcl Files} $::Prefs(extensions)] \
            {{All Files} {*}}]
    set apa [tk_getOpenFile -title "Select file(s) to check" \
            -initialdir $initdir \
            -multiple 1 \
            -filetypes $filetypes]
    if {[llength $apa] == 0} return

    set newpwd [file dirname [lindex $apa 0]]
    if {[llength $::Nagelfar(files)] == 0 && $newpwd ne [pwd]} {
        set res [tk_messageBox -title "Nagelfar" -icon question -type yesno \
                -message \
                "Change current directory to [file nativename $newpwd] ?"]
        if {$res eq "yes"} {
            cd $newpwd
        }
    }
    set skipped {}
    foreach file $apa {
        set relfile [fileRelative [pwd] $file]
        if {[lsearch -exact $::Nagelfar(files) $relfile] >= 0} {
            lappend skipped $relfile
            continue
        }
        lappend ::Nagelfar(files) $relfile
        set ::Nagelfar(lastdir) [file dirname $file]
    }
    if {[llength $skipped] > 0} {
        tk_messageBox -title "Nagelfar" -icon info -type ok -message \
                "Skipped duplicate file"
    }
}

# Remove a file from the list to check
proc removeFile {} {
    set ixs [lsort -decreasing -integer [$::Nagelfar(fileWin) curselection]]
    foreach ix $ixs {
        set ::Nagelfar(files) [lreplace $::Nagelfar(files) $ix $ix]
    }
}

# Move a file up/down file list
proc moveFile {dir} {
    # FIXA: Allow this line on a global level or in .syntax file
    ##nagelfar variable ::Nagelfar(fileWin) _obj,listbox
    set ix [lindex [$::Nagelfar(fileWin) curselection] 0]
    if {$ix eq ""} return
    set len [llength $::Nagelfar(files)]
    set nix [expr {$ix + $dir}]
    if {$nix < 0 || $nix >= $len} return
    set item [lindex $::Nagelfar(files) $ix]
    set ::Nagelfar(files) [lreplace $::Nagelfar(files) $ix $ix]
    set ::Nagelfar(files) [linsert $::Nagelfar(files) $nix $item]
    $::Nagelfar(fileWin) see $nix 
    $::Nagelfar(fileWin) selection clear 0 end
    $::Nagelfar(fileWin) selection set $nix
    $::Nagelfar(fileWin) selection anchor $nix
    $::Nagelfar(fileWin) activate $nix
}

# File drop using TkDnd
proc fileDropFile {files} {
    foreach file $files {
        lappend ::Nagelfar(files) [fileRelative [pwd] $file]
    }
}
# This shows the file and the line from an error in the result window.
proc showError {{lineNo {}}} {
    set w $::Nagelfar(resultWin)
    if {$lineNo == ""} {
        set lineNo [lindex [split [$w index current] .] 0]
    }

    $w tag remove hl 1.0 end
    $w tag add hl $lineNo.0 $lineNo.end
    $w mark set insert $lineNo.0
    set line [$w get $lineNo.0 $lineNo.end]

    if {[regexp {^(.*): Line\s+(\d+):} $line -> fileName fileLine]} {
        editFile $fileName $fileLine
    } elseif {[regexp {^Line\s+(\d+):} $line -> fileLine]} {
        editFile "" $fileLine
    }
}

# Scroll a text window to view a certain line, and possibly some
# lines before and after.
proc seeText {w si} {
    $w see $si
    $w see $si-3lines
    $w see $si+3lines
    if {[llength [$w bbox $si]] == 0} {
        $w yview $si-3lines
    }
    if {[llength [$w bbox $si]] == 0} {
        $w yview $si
    }
}

# Make next "E" error visible
proc seeNextError {} {
    set w $::Nagelfar(resultWin)
    set lineNo [lindex [split [$w index insert] .] 0]

    set index [$w search -exact ": E " $lineNo.end]
    if {$index eq ""} {
        $w see end
        return
    }
    seeText $w $index
    set lineNo [lindex [split $index .] 0]
    $w tag remove hl 1.0 end
    $w tag add hl $lineNo.0 $lineNo.end
    $w mark set insert $lineNo.0
}

proc resultPopup {x y X Y} {
    set w $::Nagelfar(resultWin)

    set index [$w index @$x,$y]
    set tags [$w tag names $index]
    set tag [lsearch -glob -inline $tags "message*"]
    if {$tag == ""} {
        set lineNo [lindex [split $index .] 0]
        set line [$w get $lineNo.0 $lineNo.end]
    } else {
        set range [$w tag nextrange $tag 1.0]
        set line [lindex [split [eval \$w get $range] \n] 0]
    }

    destroy .popup
    menu .popup

    if {[regexp {^(.*): Line\s+(\d+):} $line -> fileName fileLine]} {
        .popup add command -label "Show File" \
                -command [list editFile $fileName $fileLine]
    }
    if {[regexp {^(.*): Line\s+\d+:\s*(.*)$} $line -> pre post]} {
        .popup add command -label "Filter this message" \
                -command [list addFilter "*$pre*$post*" -1 -1 1]
        .popup add command -label "Filter this message in all files" \
                -command [list addFilter "*$post*" -1 -1 1]
        regsub {".+?"} $post {"*"} post2
        regsub -all {\d+} $post2 "*" post2
        if {$post2 ne $post} {
            .popup add command -label "Filter this generic message" \
                    -command [list addFilter "*$post2*" -1 -1 1]
        }
    }
    # FIXA: This should be handled abit better.
    .popup add command -label "Reset all filters" -command resetFilters

    if {[$::Nagelfar(resultWin) get 1.0 1.end] ne ""} {
        .popup add command -label "Save Result" -command saveResult
    }

    tk_popup .popup $X $Y
}

# Save result as file
proc saveResult {} {
    # set initial filename to 1st file in list
    set iniFile [file rootname [lindex $::Nagelfar(files) 0]]
    if {$iniFile == ""} {
        set iniFile "noname"
    }
    append iniFile ".nfr"
    set iniDir [file dirname $iniFile]
    set types {
        {"Nagelfar Result" {.nfr}}
        {"All Files" {*}}
    }
    set file [tk_getSaveFile -initialdir $iniDir -initialfile $iniFile \
            -filetypes $types -title "Save File"]
    if {$file != ""} {
        set ret [catch {open $file w} msg]
        if {!$ret} {
            set fid $msg
            fconfigure $fid -translation {auto lf}
            set ret [catch {puts $fid [$::Nagelfar(resultWin) get 1.0 end-1c]} msg]
        }
        catch {close $fid}
        if {!$ret} {
            tk_messageBox -title "Nagelfar" -icon info -type ok \
                    -message "Result saved as [file nativename $file]"
        } else {
            tk_messageBox -title "Nagelfar Error" -type ok -icon error \
                    -message "Cannot write [file nativename $file]:\n$msg"
        }
    }
}

# Update the selection in the db listbox to or from the db list.
proc updateDbSelection {{fromVar -fromgui}} {
    if {$fromVar eq "-fromvar"} {
        $::Nagelfar(dbWin) selection clear 0 end
        # Try to keep one selected
        if {[llength $::Nagelfar(db)] == 0} {
            set ::Nagelfar(db) [lrange $::Nagelfar(allDb) 0 0]
        }
        foreach f $::Nagelfar(db) {
            set i [lsearch $::Nagelfar(allDb) $f]
            if {$i >= 0} {
                $::Nagelfar(dbWin) selection set $i
            }
        }
        return
    }

    set ::Nagelfar(db) {}
    foreach ix [$::Nagelfar(dbWin) curselection] {
        lappend ::Nagelfar(db) [lindex $::Nagelfar(allDb) $ix]
    }
}

# A little helper to make a scrolled window
# It returns the name of the scrolled window
##nagelfar syntax Scroll x x x p*
##nagelfar option Scroll -listvariable -height -width -selectmode -wrap -font -linemap
##nagelfar option Scroll\ -listvariable v
proc Scroll {dir class w args} {
    switch -- $dir {
        both {
            set scrollx 1
            set scrolly 1
        }
        x {
            set scrollx 1
            set scrolly 0
        }
        y {
            set scrollx 0
            set scrolly 1
        }
        default {
            return -code error "Bad scrolldirection \"$dir\""
        }
    }

    frame $w
    eval [list $class $w.s] $args

    # Move border properties to frame
    set bw [$w.s cget -borderwidth]
    set relief [$w.s cget -relief]
    $w configure -relief $relief -borderwidth $bw
    $w.s configure -borderwidth 0

    grid $w.s -sticky news

    if {$scrollx} {
        $w.s configure -xscrollcommand [list $w.sbx set]
        scrollbar $w.sbx -orient horizontal -command [list $w.s xview]
        grid $w.sbx -row 1 -sticky we
    }
    if {$scrolly} {
        $w.s configure -yscrollcommand [list $w.sby set]
        scrollbar $w.sby -orient vertical -command [list $w.s yview]
        grid $w.sby -row 0 -column 1 -sticky ns
    }
    grid columnconfigure $w 0 -weight 1
    grid rowconfigure    $w 0 -weight 1

    return $w.s
}

# Set the progress
proc progressUpdate {n} {
    if {$n < 0} {
        $::Nagelfar(progressWin) configure -relief flat
    } else {
        $::Nagelfar(progressWin) configure -relief solid
    }
    if {$n <= 0} {
        place $::Nagelfar(progressWin).f -x -100 -relx 0 -y 0 -rely 0 \
                -relheight 1.0 -relwidth 0.0
    } else {
        set frac [expr {double($n) / $::Nagelfar(progressMax)}]

        place $::Nagelfar(progressWin).f -x 0 -relx 0 -y 0 -rely 0 \
                -relheight 1.0 -relwidth $frac
    }
    update idletasks
}

# Set the 100 % level of the progress bar
proc progressMax {n} {
    set ::Nagelfar(progressMax) $n
    progressUpdate 0
}

# Create a simple progress bar
proc progressBar {w} {
    set ::Nagelfar(progressWin) $w

    frame $w -bd 1 -relief solid -padx 2 -pady 2 -width 100 -height 20
    frame $w.f -background blue

    progressMax 100
    progressUpdate -1
}

# A thing to easily get to debug mode
proc backDoor {a} {
    append ::Nagelfar(backdoor) $a
    set ::Nagelfar(backdoor) [string range $::Nagelfar(backdoor) end-9 end]
    if {$::Nagelfar(backdoor) eq "PeterDebug"} {
        # Second time it redraw window, thus giving debug menu
        if {$::debug == 1} {
            makeWin
        }
        set ::debug 1
        catch {console show}
        set ::Nagelfar(backdoor) ""
    }
}

# Flag that the current run should be stopped
proc stopCheck {} {
    set ::Nagelfar(stop) 1
    $::Nagelfar(stopWin) configure -state disabled
}

# Allow the stop button to be pressed
proc allowStop {} {
    set ::Nagelfar(stop) 0
    $::Nagelfar(stopWin) configure -state normal
}

# Create main window
proc makeWin {} {
    defaultGuiOptions

    catch {font create ResultFont -family courier \
            -size [lindex $::Prefs(resultFont) 1]}

    eval destroy [winfo children .]
    wm protocol . WM_DELETE_WINDOW exitApp
    wm title . "Nagelfar: Tcl Syntax Checker"
    tk appname Nagelfar
    wm withdraw .

    # Syntax database section

    frame .fs
    label .fs.l -text "Syntax database files"
    button .fs.bd -text "Del" -width 10 -command removeDbFile
    button .fs.b -text "Add" -width 10 -command addDbFile
    set lb [Scroll y listbox .fs.lb \
                    -listvariable ::Nagelfar(allDbView) \
                    -height 4 -width 40 -selectmode extended]
    set ::Nagelfar(dbWin) $lb

    bind $lb <Key-Delete> "removeDbFile"
    bind $lb <<ListboxSelect>> updateDbSelection
    bind $lb <Button-1> [list focus $lb]
    updateDbSelection -fromvar

    grid .fs.l  .fs.bd .fs.b -sticky w -padx 2 -pady 2
    grid .fs.lb -      -     -sticky news
    grid columnconfigure .fs 0 -weight 1
    grid rowconfigure .fs 1 -weight 1


    # File section

    frame .ff
    label .ff.l -text "Tcl files to check"
    button .ff.bd -text "Del" -width 10 -command removeFile
    button .ff.b -text "Add" -width 10 -command addFile
    set lb [Scroll y listbox .ff.lb \
                    -listvariable ::Nagelfar(files) \
                    -height 4 -width 40]
    set ::Nagelfar(fileWin) $lb

    bind $lb <Key-Delete> "removeFile"
    bind $lb <Button-1> [list focus $lb]
    bind $lb <Shift-Up> {moveFile -1}
    bind $lb <Shift-Down> {moveFile 1}

    grid .ff.l  .ff.bd .ff.b -sticky w -padx 2 -pady 2
    grid .ff.lb -      -     -sticky news
    grid columnconfigure .ff 0 -weight 1
    grid rowconfigure .ff 1 -weight 1

    # Set up file dropping in listboxes if TkDnd is available
    if {![catch {package require tkdnd}]} {
        dnd bindtarget . text/uri-list <Drop> {fileDropFile %D}
        #dnd bindtarget $::Nagelfar(fileWin) text/uri-list <Drop> {fileDropFile %D}
        dnd bindtarget $::Nagelfar(dbWin) text/uri-list <Drop> {fileDropDb %D}
    }

    # Result section

    frame .fr
    progressBar .fr.pr
    button .fr.b -text "Check" -underline 0 -width 10 -command "doCheck"
    bind . <Alt-Key-c> doCheck
    bind . <Alt-Key-C> doCheck
    button .fr.bb -text "Stop" -underline 0 -width 10 -command "stopCheck"
    bind . <Alt-Key-b> stopCheck
    bind . <Alt-Key-B> stopCheck
    set ::Nagelfar(stopWin) .fr.bb
    button .fr.bn -text "Next E" -underline 0 -width 10 -command "seeNextError"
    bind . <Alt-Key-n> seeNextError
    bind . <Alt-Key-N> seeNextError
    if {$::debug == 0} {
        bind . <Key> "backDoor %A"
    }

    set ::Nagelfar(resultWin) [Scroll both \
            text .fr.t -width 100 -height 25 -wrap none -font ResultFont]

    grid .fr.b .fr.bb .fr.bn .fr.pr -sticky w -padx 2 -pady {0 2}
    grid .fr.t -      -      -      -sticky news
    grid columnconfigure .fr 2 -weight 1
    grid rowconfigure    .fr 1 -weight 1

    $::Nagelfar(resultWin) tag configure info -foreground #707070
    $::Nagelfar(resultWin) tag configure error -foreground red
    $::Nagelfar(resultWin) tag configure hl -background yellow
    bind $::Nagelfar(resultWin) <Double-Button-1> "showError ; break"
    bind $::Nagelfar(resultWin) <Button-3> "resultPopup %x %y %X %Y ; break"

    # Use the panedwindow in 8.4
    panedwindow .pw -orient vertical
    lower .pw
    frame .pw.f
    grid .fs x .ff -in .pw.f -sticky news
    grid columnconfigure .pw.f {0 2} -weight 1 -uniform a
    grid columnconfigure .pw.f 1 -minsize 4
    grid rowconfigure .pw.f 0 -weight 1

    # Make sure the frames have calculated their size before
    # adding them to the pane
    # This update can be excluded in 8.4.4+
    update idletasks
    .pw add .pw.f -sticky news
    .pw add .fr   -sticky news
    pack .pw -fill both -expand 1


    # Menus

    menu .m
    . configure -menu .m

    # File menu

    .m add cascade -label "File" -underline 0 -menu .m.mf
    menu .m.mf
    .m.mf add command -label "Exit" -underline 1 -command exitApp

    # Options menu
    addOptionsMenu .m

    # Tools menu

    .m add cascade -label "Tools" -underline 0 -menu .m.mt
    menu .m.mt
    .m.mt add command -label "Edit Window" -underline 0 \
            -command {editFile "" 0}
    .m.mt add command -label "Browse Database" -underline 0 \
            -command makeDbBrowserWin
    addRegistryToMenu .m.mt

    # Debug menu

    if {$::debug == 1} {
        .m add cascade -label "Debug" -underline 0 -menu .m.md
        menu .m.md
        if {$::tcl_platform(platform) == "windows"} {
            .m.md add checkbutton -label Console -variable consolestate \
                    -onvalue show -offvalue hide \
                    -command {console $consolestate}
            .m.md add separator
        }
        .m.md add command -label "Reread Source" -command {source $thisScript}
        .m.md add separator
        .m.md add command -label "Redraw Window" -command {makeWin}
        #.m.md add separator
        #.m.md add command -label "Normal Cursor" -command {normalCursor}
    }

    # Help menu is last

    .m add cascade -label "Help" -underline 0 -menu .m.help
    menu .m.help
    foreach label {README Messages {Syntax Databases} {Inline Comments} {Call By Name} {Syntax Tokens} {Code Coverage} {Plugins} {Object Orientation}} \
            file {README.txt messages.txt syntaxdatabases.txt inlinecomments.txt call-by-name.txt syntaxtokens.txt codecoverage.txt plugins.txt oo.txt} {
        .m.help add command -label $label -command [list makeDocWin $file]
    }
    .m.help add separator
    .m.help add command -label About -command makeAboutWin

    wm deiconify .
}

#############################
# A simple file viewer/editor
#############################

# Try to locate emacs, if not done before
proc locateEmacs {} {
    if {[info exists ::Nagelfar(emacs)]} return

    # Look for standard names in the path
    set path [auto_execok emacs]
    if {$path != ""} {
        set ::Nagelfar(emacs) [list $path -f server-start]
    } else {
        set path [auto_execok runemacs.exe]
        if {$path != ""} {
            set ::Nagelfar(emacs) [list $path]
        }
    }

    if {![info exists ::Nagelfar(emacs)]} {
        # Try the places where I usually have emacs on Windows
        foreach dir [lsort -decreasing -dictionary \
                [glob -nocomplain c:/apps/emacs*]] {
            set em [file join $dir bin runemacs.exe]
            set em [file normalize $em]
            if {[file exists $em]} {
                set ::Nagelfar(emacs) [list $em]
                break
            }
        }
    }
    # Look for emacsclient
    foreach name {emacsclient} {
        set path [auto_execok $name]
        if {$path != ""} {
            set ::Nagelfar(emacsclient) $path
            break
        }
    }
}

# Try to show a file using emacs
proc tryEmacs {filename lineNo} {
    locateEmacs
    # First try with emacsclient
    if {[catch {exec $::Nagelfar(emacsclient) -n +$lineNo $filename}]} {
        # Start a new emacs
        if {[catch {eval exec $::Nagelfar(emacs) [list +$lineNo \
                $filename] &}]} {
            # Failed
            return 0
        }
    }
    return 1
}

# Try to show a file using vim
proc tryVim {filename lineNo} {
    if {[catch {exec gvim +$lineNo $filename &}]} {
        if {[catch {exec xterm -exec vi +$lineNo $filename &}]} {
            return 0
        }
    }
    return 1
}

# Try to show a file using pfe
proc tryPfe {filename lineNo} {
    if {$lineNo > 0} {
        if {[catch {exec [auto_execok pfe32] /g $lineNo $filename &}]} {
            return 0
        }
    } elseif {[catch {exec [auto_execok pfe32] &}]} {
        return 0
    }
    return 1
}

# Edit a file using internal or external editor.
proc editFile {filename lineNo} {
    if {$::Prefs(editor) eq "emacs" && [tryEmacs $filename $lineNo]} return
    if {$::Prefs(editor) eq "vim"   && [tryVim   $filename $lineNo]} return
    if {$::Prefs(editor) eq "pfe"   && [tryPfe   $filename $lineNo]} return

    if {[winfo exists .fv]} {
        wm deiconify .fv
        raise .fv
        set w $::Nagelfar(editWin)
    } else {
        toplevel .fv
        wm title .fv "Nagelfar Editor"

	if {$::Nagelfar(withCtext)} {
	    set w [Scroll both ctext .fv.t -linemap 0 \
                    -width 80 -height 25 -font $::Prefs(editFileFont)]
	    ctext::setHighlightTcl $w
	} else {
            set w [Scroll both text .fv.t \
                    -width 80 -height 25 -font $::Prefs(editFileFont)]
        }
        set ::Nagelfar(editWin) $w
        # Set up a tag for incremental search bindings
        if {[info procs textSearch::enableSearch] != ""} {
            textSearch::enableSearch $w -label ::Nagelfar(iSearch)
        }

        frame .fv.f
        grid .fv.t -sticky news
        grid .fv.f -sticky we
        grid columnconfigure .fv 0 -weight 1
        grid rowconfigure .fv 0 -weight 1

        menu .fv.m
        .fv configure -menu .fv.m
        .fv.m add cascade -label "File" -underline 0 -menu .fv.m.mf
        menu .fv.m.mf
        .fv.m.mf add command -label "Save"  -underline 0 -command "saveFile"
        .fv.m.mf add separator
        .fv.m.mf add command -label "Close"  -underline 0 -command "closeFile"

        .fv.m add cascade -label "Edit" -underline 0 -menu .fv.m.me
        menu .fv.m.me
        .fv.m.me add command -label "Clear/Paste" -underline 6 \
                -command "clearAndPaste"
        .fv.m.me add command -label "Check" -underline 0 \
                -command "checkEditWin"

        .fv.m add cascade -label "Search" -underline 0 -menu .fv.m.ms
        menu .fv.m.ms
        if {[info procs textSearch::searchMenu] != ""} {
            textSearch::searchMenu .fv.m.ms
        } else {
            .fv.m.ms add command -label "Text search not available" \
                    -state disabled
        }

        .fv.m add cascade -label "Options" -underline 0 -menu .fv.m.mo
        menu .fv.m.mo
        .fv.m.mo add checkbutton -label "Backup" -underline 0 \
                -variable ::Prefs(editFileBackup)

        .fv.m.mo add cascade -label "Font" -underline 0 -menu .fv.m.mo.mf
        menu .fv.m.mo.mf
        set cmd "[list $w] configure -font \$::Prefs(editFileFont)"
        foreach lab {Small Medium Large} size {8 10 14} {
            .fv.m.mo.mf add radiobutton -label $lab  -underline 0 \
                    -variable ::Prefs(editFileFont) \
                    -value [list Courier $size] \
                    -command $cmd
        }

        label .fv.f.ln -width 5 -anchor e -textvariable ::Nagelfar(lineNo)
        label .fv.f.li -width 1 -pady 0 -padx 0 \
                -textvariable ::Nagelfar(iSearch)
        pack .fv.f.ln .fv.f.li -side right -padx 3

        bind $w <Any-Key> {
            after idle {
                set ::Nagelfar(lineNo) \
                        [lindex [split [$::Nagelfar(editWin) index insert] .] 0]
            }
        }
        bind $w <Any-Button> [bind $w <Any-Key>]

        wm protocol .fv WM_DELETE_WINDOW closeFile
        $w tag configure hl -background yellow
        if {[info exists ::Nagelfar(editFileGeom)]} {
            wm geometry .fv $::Nagelfar(editFileGeom)
        } else {
            after idle {after 1 {
                set ::Nagelfar(editFileOrigGeom) [wm geometry .fv]
            }}
        }
    }

    if {$filename != "" && \
            (![info exists ::Nagelfar(editFile)] || \
            $filename != $::Nagelfar(editFile))} {
        $w delete 1.0 end
        set ::Nagelfar(editFile) $filename
        wm title .fv [file tail $filename]

        # Try to figure out eol style
        set ch [open $filename r]
        fconfigure $ch -translation binary
        set data [read $ch 400]
        close $ch

        set crCnt [expr {[llength [split $data \r]] - 1}]
        set lfCnt [expr {[llength [split $data \n]] - 1}]
        if {$crCnt == 0 && $lfCnt > 0} {
            set ::Nagelfar(editFileTranslation) lf
        } elseif {$crCnt > 0 && $crCnt == $lfCnt} {
            set ::Nagelfar(editFileTranslation) crlf
        } elseif {$lfCnt == 0 && $crCnt > 0} {
            set ::Nagelfar(editFileTranslation) cr
        } else {
            set ::Nagelfar(editFileTranslation) auto
        }

        #puts "EOL $::Nagelfar(editFileTranslation)"

        set ch [open $filename r]
        set data [read $ch]
        close $ch
	if {$::Nagelfar(withCtext)} {
	    $w fastinsert end $data
	} else {
            $w insert end $data
        }
    }
    # Disable Save if there is no file
    if {![info exists ::Nagelfar(editFile)] || $::Nagelfar(editFile) eq ""} {
        .fv.m.mf entryconfigure "Save" -state disabled
    } else {
        .fv.m.mf entryconfigure "Save" -state normal
    }

    $w tag remove hl 1.0 end
    $w tag add hl $lineNo.0 $lineNo.end
    $w mark set insert $lineNo.0
    focus $w
    set ::Nagelfar(lineNo) $lineNo
    update
    $w see insert
    #after 1 {after idle {$::Nagelfar(editWin) see insert}}
    if {$::Nagelfar(withCtext)} {
        after idle [list $w highlight 1.0 end]
    }
}

proc saveFile {} {
    if {![info exists ::Nagelfar(editFile)]} {
        # Gracefully handle if this happens
        return
    }
    if {[tk_messageBox -parent .fv -title "Save File" -type okcancel \
            -icon question \
            -message "Save file\n$::Nagelfar(editFile)"] != "ok"} {
        return
    }
    if {$::Prefs(editFileBackup)} {
        file copy -force -- $::Nagelfar(editFile) $::Nagelfar(editFile)~
    }
    set ch [open $::Nagelfar(editFile) w]
    fconfigure $ch -translation $::Nagelfar(editFileTranslation)
    puts -nonewline $ch [$::Nagelfar(editWin) get 1.0 end-1char]
    close $ch
}

proc closeFile {} {
    if {[info exists ::Nagelfar(editFileGeom)] || \
            ([info exists ::Nagelfar(editFileOrigGeom)] && \
             $::Nagelfar(editFileOrigGeom) != [wm geometry .fv])} {
        set ::Nagelfar(editFileGeom) [wm geometry .fv]
    }

    destroy .fv
    set ::Nagelfar(editFile) ""
}

proc clearAndPaste {} {
    set w $::Nagelfar(editWin)
    $w delete 1.0 end
    focus $w

    if {$::tcl_platform(platform) == "windows"} {
        event generate $w <<Paste>>
    } else {
        $w insert 1.0 [selection get]
    }
}

proc checkEditWin {} {
    set w $::Nagelfar(editWin)

    set script [$w get 1.0 end]
    set ::Nagelfar(scriptContents) $script
    doCheck
    unset ::Nagelfar(scriptContents)
}

######
# Help
######

proc helpWin {w title} {
    destroy $w

    toplevel $w
    wm title $w $title
    bind $w <Key-Return> "destroy $w"
    bind $w <Key-Escape> "destroy $w"
    frame $w.f
    button $w.b -text "Close" -command "destroy $w" -width 10 \
            -default active
    pack $w.b -side bottom -pady 3
    pack $w.f -side top -expand y -fill both
    focus $w
    return $w.f
}

proc makeAboutWin {} {
    global version

    set w [helpWin .ab "About Nagelfar"]


    text $w.t -width 45 -height 7 -wrap none -relief flat \
            -bg [$w cget -bg]
    pack $w.t -side top -expand y -fill both

    $w.t insert end "A syntax checker for Tcl\n\n"
    $w.t insert end "$version\n\n"
    $w.t insert end "Made by Peter Spjuth\n"
    $w.t insert end "E-Mail: peter.spjuth@gmail.com\n"
    $w.t insert end "\nURL: http://nagelfar.sourceforge.net\n"
    $w.t insert end "\nTcl version: [info patchlevel]"
    set d [package provide tkdnd]
    if {$d != ""} {
        $w.t insert end "\nTkDnd version: $d"
    }
    catch {loadDatabases}
    if {[info exists ::Nagelfar(dbInfo)] &&  $::Nagelfar(dbInfo) != ""} {
        $w.t insert end "\nSyntax database: $::Nagelfar(dbInfo)"
    }
    set last [lindex [split [$w.t index end] "."] 0]
    $w.t configure -height $last
    $w.t configure -state disabled
}

# Partial backslash-subst
proc mySubst {str} {
    subst -nocommands -novariables [string map {\\\n \\\\\n} $str]
}

# Insert a text file into a text widget.
# Any XML-style tags in the file are used as tags in the text window.
proc insertTaggedText {w file} {
    set ch [open $file r]
    set data [read $ch]
    close $ch

    # Disable tag handling since current doc files are just text
    $w insert end $data
    return

    set tags {}
    while {$data != ""} {
        if {[regexp {^([^<]*)<(/?)([^>]+)>(.*)$} $data -> pre sl tag post]} {
            $w insert end [mySubst $pre] $tags
            set i [lsearch $tags $tag]
            if {$sl != ""} {
                # Remove tag
                if {$i >= 0} {
                    set tags [lreplace $tags $i $i]
                }
            } else {
                # Add tag
                lappend tags $tag
            }
            set data $post
        } else {
            $w insert end [mySubst $data] $tags
            set data ""
        }
    }
}

proc makeDocWin {fileName} {
    set w [helpWin .doc "Nagelfar Help"]
    set t [Scroll both \
                   text $w.t -width 80 -height 25 -wrap none -font ResultFont]
    pack $w.t -side top -expand 1 -fill both

    # Set up tags
    $t tag configure ul -underline 1
    $t tag configure u -underline 1

    if {![file exists $::docDir/$fileName]} {
        $t insert end "ERROR: Could not find doc file "
        $t insert end \"$fileName\"
        return
    }
    insertTaggedText $t $::docDir/$fileName

    #focus $t
    $t configure -state disabled
}

# Generate a file path relative to a dir
proc fileRelative {dir file} {
    set dirpath [file split $dir]
    set filepath [file split $file]
    set newpath {}

    set dl [llength $dirpath]
    set fl [llength $filepath]
    for {set t 0} {$t < $dl && $t < $fl} {incr t} {
        set f [lindex $filepath $t]
        set d [lindex $dirpath $t]
        if {$f ne $d} break
    }
    # Return file if too unequal
    if {$t <= 2 || ($dl - $t) > 3} {
        return $file
    }
    for {set u $t} {$u < $dl} {incr u} {
        lappend newpath ".."
    }
    return [eval file join $newpath [lrange $filepath $t end]]
}

proc defaultGuiOptions {} {
    catch {package require griffin}

    option add *Menu.tearOff 0
    if {[tk windowingsystem]=="x11"} {
        option add *Menu.activeBorderWidth 1
        option add *Menu.borderWidth 1

        option add *Listbox.exportSelection 0
        option add *Listbox.borderWidth 1
        option add *Listbox.highlightThickness 1
        option add *Font "Helvetica -12"
    }

    if {$::tcl_platform(platform) == "windows"} {
        option add *Panedwindow.sashRelief flat
        option add *Panedwindow.sashWidth 4
        option add *Panedwindow.sashPad 0
    }
}
#----------------------------------------------------------------------
# dbbrowser.tcl, Database browser
#----------------------------------------------------------------------

proc makeDbBrowserWin {} {
    if {[winfo exists .db]} {
        wm deiconify .db
        raise .db
        set w $::Nagelfar(dbBrowserWin)
    } else {
        toplevel .db
        wm title .db "Nagelfar Database"

        set w [Scroll y text .db.t -wrap word \
                       -width 80 -height 15 -font $::Prefs(editFileFont)]
        set ::Nagelfar(dbBrowserWin) $w
        $w tag configure all -lmargin2 2c
        set f [frame .db.f -padx 3 -pady 3]
        grid .db.f -sticky we
        grid .db.t -sticky news
        grid columnconfigure .db 0 -weight 1
        grid rowconfigure .db 1 -weight 1

        label $f.l -text "Command"
        entry $f.e -textvariable ::Nagelfar(dbBrowserCommand) -width 15
        button $f.b -text "Search" -command dbBrowserSearch -default active

        grid $f.l $f.e $f.b -sticky ew -padx 3
        grid columnconfigure $f 1 -weight 1

        bind .db <Key-Return> dbBrowserSearch
    }
}

proc dbBrowserSearch {} {
    set cmd $::Nagelfar(dbBrowserCommand)
    set w $::Nagelfar(dbBrowserWin)

    loadDatabases
    $w delete 1.0 end

    # Must be at least one word char in the pattern
    set pat $cmd*
    if {![regexp {\w} $pat]} {
        set pat ""
    }

    foreach item [lsort -dictionary [array names ::syntax $pat]] {
        $w insert end "\#\#nagelfar syntax [list $item]"
        $w insert end " "
        $w insert end $::syntax($item)\n
    }
    foreach item [lsort -dictionary [array names ::subCmd $pat]] {
        $w insert end "\#\#nagelfar subcmd [list $item]"
        $w insert end " "
        $w insert end $::subCmd($item)\n
    }
    foreach item [lsort -dictionary [array names ::option $pat]] {
        $w insert end "\#\#nagelfar option [list $item]"
        $w insert end " "
        $w insert end $::option($item)\n
    }
    foreach item [lsort -dictionary [array names ::return $pat]] {
        $w insert end "\#\#nagelfar return [list $item]"
        $w insert end " "
        $w insert end $::return($item)\n
    }

    if {[$w index end] eq "2.0"} {
        $w insert end "No match!"
    }
    $w tag add all 1.0 end
}
#----------------------------------------------------------------------
# registry.tcl, Support for Windows Registry
#----------------------------------------------------------------------

# Make a labelframe for one registry item
proc makeRegistryFrame {w label key newvalue} {

    set old {}
    catch {set old [registry get $key {}]}

    set l [labelframe $w -text $label -padx 4 -pady 4]

    label $l.key1 -text "Key:"
    label $l.key2 -text $key
    label $l.old1 -text "Old value:"
    label $l.old2 -text $old
    label $l.new1 -text "New value:"
    label $l.new2 -text $newvalue

    button $l.change -text "Change" -width 10 -command \
            "[list registry set $key {} $newvalue] ; \
             [list $l.change configure -state disabled]"
    button $l.delete -text "Delete" -width 10 -command \
            "[list registry delete $key] ; \
             [list $l.delete configure -state disabled]"
    if {$newvalue eq $old} {
        $l.change configure -state disabled
    }
    if {"" eq $old} {
        $l.delete configure -state disabled
    }
    grid $l.key1 $l.key2 -     -sticky "w" -padx 4 -pady 4
    grid $l.old1 $l.old2 -     -sticky "w" -padx 4 -pady 4
    grid $l.new1 $l.new2 -     -sticky "w" -padx 4 -pady 4
    grid $l.delete - $l.change -sticky "w" -padx 4 -pady 4
    grid $l.change -sticky "e"
    grid columnconfigure $l 2 -weight 1
}

# Registry dialog
proc makeRegistryWin {} {
    global thisScript

    # Locate executable for this program
    set exe [info nameofexecutable]
    if {[regexp {^(.*wish)\d+\.exe$} $exe -> pre]} {
        set alt $pre.exe
        if {[file exists $alt]} {
            set a [tk_messageBox -title "Nagelfar" -icon question \
                    -title "Which Wish" -message \
                    "Would you prefer to use the executable\n\
                    \"$alt\"\ninstead of\n\
                    \"$exe\"\nin the registry settings?" -type yesno]
            if {$a eq "yes"} {
                set exe $alt
            }
        }
    }

    set top .reg
    destroy $top
    toplevel $top
    wm title $top "Register Nagelfar"

    # Registry keys

    set key {HKEY_CLASSES_ROOT\.tcl\shell\Check\command}
    set old {}
    catch {set old [registry get {HKEY_CLASSES_ROOT\.tcl} {}]}
    if {$old != ""} {
        set key "HKEY_CLASSES_ROOT\\$old\\shell\\Check\\command"
    }

    # Are we in a starkit?
    if {[info exists ::starkit::topdir]} {
        # In a starpack ?
        set exe [file normalize $exe]
        if {[file normalize $::starkit::topdir] eq $exe} {
            set myexe [list $exe]
        } else {
            set myexe [list $exe $::starkit::topdir]
        }
    } else {
        if {[regexp {wish\d+\.exe} $exe]} {
            set exe [file join [file dirname $exe] wish.exe]
            if {[file exists $exe]} {
                set myexe [list $exe]
            }
        }
        set myexe [list $exe $thisScript]
    }

    set valbase {}
    foreach item $myexe {
        lappend valbase \"[file nativename $item]\"
    }
    set valbase [join $valbase]

    set new "$valbase -gui \"%1\""
    makeRegistryFrame $top.d "Check" $key $new

    pack $top.d -side "top" -fill x -padx 4 -pady 4

    button $top.close -text "Close" -width 10 -command [list destroy $top] \
            -default active
    pack $top.close -side bottom -pady 4
    bind $top <Key-Return> [list destroy $top]
    bind $top <Key-Escape> [list destroy $top]
}

# Add a registry item to a menu, if supported.
proc addRegistryToMenu {m} {
    if {$::tcl_platform(platform) eq "windows"} {
        if {![catch {package require registry}]} {
            $m add separator
            $m add command -label "Setup Registry" -underline 6 \
                    -command makeRegistryWin
        }
    }
}
#----------------------------------------------------------------------
#  Nagelfar, a syntax checker for Tcl.
#  Copyright (c) 1999-2022, Peter Spjuth
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING.  If not, write to
#  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#  Boston, MA 02110-1301, USA.
#
#----------------------------------------------------------------------
# preferences.tcl
#----------------------------------------------------------------------

# Save default options
proc saveOptions {} {
    if {[catch {set ch [open "~/.nagelfarrc" w]}]} {
        errEcho "Could not create options file."
        return
    }

    foreach i [array names ::Prefs] {
        puts $ch [list set ::Prefs($i) $::Prefs($i)]
    }
    close $ch
}

# Fill in default options and load user's saved file
proc getOptions {} {
    array set ::Prefs {
        warnBraceExpr 2
        warnShortSub 1
        strictAppend 0
        prefixFile 0
        forceElse 1
        noVar 0
	warnUnusedVar 0
	warnUnusedVarFilter {args}
        severity N
        editFileBackup 1
        editFileFont {Courier 10}
        resultFont {Courier 10}
        editor internal
        extensions {.tcl .test .adp .tk}
        exitcode 0
        html 0
        htmlprefix ""
    }

    # Do not load anything during test
    if {[info exists ::_nagelfar_test]} return

    foreach candidate {.nagelfarrc ~/.nagelfarrc} {
        if {[file exists $candidate]} {
            interp create -safe loadinterp
            interp expose loadinterp source
            interp eval loadinterp source $candidate
            array set ::Prefs [interp eval loadinterp array get ::Prefs]
            interp delete loadinterp
            break
        }
    }
}

# Add an "Options" cascade to a menu
proc addOptionsMenu {m} {
    $m add cascade -label "Options" -underline 0 -menu $m.mo
    menu $m.mo

    $m.mo add cascade -label "Result Window Font" -menu $m.mo.mo
    menu $m.mo.mo
    $m.mo.mo add radiobutton -label "Small" \
	    -variable ::Prefs(resultFont) -value "Courier 8" \
	    -command {font configure ResultFont -size 8}
    $m.mo.mo add radiobutton -label "Medium" \
	    -variable ::Prefs(resultFont) -value "Courier 10" \
	    -command {font configure ResultFont -size 10}
    $m.mo.mo add radiobutton -label "Large" \
	    -variable ::Prefs(resultFont) -value "Courier 14" \
	    -command {font configure ResultFont -size 14}

    $m.mo add cascade -label "Editor" -menu $m.mo.med
    menu $m.mo.med
    $m.mo.med add radiobutton -label "Internal" \
            -variable ::Prefs(editor) -value internal
    $m.mo.med add radiobutton -label "Emacs" \
            -variable ::Prefs(editor) -value emacs
    $m.mo.med add radiobutton -label "Vim" \
            -variable ::Prefs(editor) -value vim

    if {$::tcl_platform(platform) == "windows"} {
        $m.mo.med add radiobutton -label "Pfe" \
                -variable ::Prefs(editor) -value pfe
    }

    $m.mo add separator

    $m.mo add cascade -label "Severity level" -menu $m.mo.ms
    menu $m.mo.ms
    $m.mo.ms add radiobutton -label "Show All (E/W/N)" \
            -variable ::Prefs(severity) -value N
    $m.mo.ms add radiobutton -label {Show Warnings (E/W)} \
            -variable ::Prefs(severity) -value W
    $m.mo.ms add radiobutton -label {Show Errors (E)} \
            -variable ::Prefs(severity) -value E

    $m.mo add checkbutton -label "Warn about shortened subcommands" \
            -variable ::Prefs(warnShortSub)
    $m.mo add cascade -label "Braced expressions" -menu $m.mo.mb
    menu $m.mo.mb
    $m.mo.mb add radiobutton -label "Allow unbraced" \
            -variable ::Prefs(warnBraceExpr) -value 0
    $m.mo.mb add radiobutton -label {Allow 'if [cmd] {xxx}'} \
            -variable ::Prefs(warnBraceExpr) -value 1
    $m.mo.mb add radiobutton -label "Warn on any unbraced" \
            -variable ::Prefs(warnBraceExpr) -value 2
    $m.mo add checkbutton -label "Enforce else keyword" \
            -variable ::Prefs(forceElse)
    $m.mo add checkbutton -label "Strict (l)append" \
            -variable ::Prefs(strictAppend)
    $m.mo add checkbutton -label "Disable variable checking" \
            -variable ::Prefs(noVar)

    $m.mo add cascade -label "Script encoding" -menu $m.mo.me
    menu $m.mo.me
    $m.mo.me add radiobutton -label "Ascii" \
            -variable ::Nagelfar(encoding) -value ascii
    $m.mo.me add radiobutton -label "Iso8859-1" \
            -variable ::Nagelfar(encoding) -value iso8859-1
    $m.mo.me add radiobutton -label "System ([encoding system])" \
            -variable ::Nagelfar(encoding) -value system


    $m.mo add separator
    $m.mo add command -label "Save Options" -command saveOptions

}
#----------------------------------------------------------------------
#  Nagelfar, a syntax checker for Tcl.
#  Copyright (c) 2013-2022, Peter Spjuth
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING.  If not, write to
#  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#  Boston, MA 02110-1301, USA.
#
#----------------------------------------------------------------------
# plugin.tcl
#----------------------------------------------------------------------

proc PluginSearchPath {} {
    set dirs [list . ./plugins]
    lappend dirs [file join $::thisDir .. ..]
    lappend dirs [file join $::thisDir .. .. plugins]
    lappend dirs [file join $::thisDir .. plugins]
    foreach d $::Nagelfar(pluginPath) {
        lappend dirs $d
    }
    return $dirs
}

# Locate plugin source
proc LocatePlugin {plugin} {
    set src ""
    set dirs [PluginSearchPath]

    foreach dir $dirs {
        set dir [file normalize $dir]
        set files {}
        lappend files [file join $dir $plugin]
        lappend files [file join $dir $plugin.tcl]
        foreach file $files {
            if {![file exists   $file]} continue
            if {![file isfile   $file]} continue
            if {![file readable $file]} continue
            set ch [open $file r]
            set data [read $ch 20]
            close $ch
            if {[string match "##Nagelfar Plugin*" $data]} {
                set src $file
                break
            }
        }
        if {$src ne ""} break
    }
    return $src
}

proc createPluginInterp {plugin} {
    set src [LocatePlugin $plugin]

    if {$src eq ""} {
        return ""
    }
    # Create interpreter
    set pi [interp create -safe]

    # Load source
    $pi invokehidden -global source $src
    $pi eval [list set ::WhoAmI [file rootname [file tail $src]]]
    interp share {} stdout $pi

    # Expose needed commands
    #interp expose $pi fconfigure ;# ??
    interp hide $pi close

    # Register what hooks it has in the global variables
    foreach func {
        statementRaw statementWords earlyExpr lateExpr varWrite
        varRead syntaxComment lineRaw bodyRaw unknownCommand
    } {
        if {[$pi eval info proc $func] ne ""} {
            # var names start with uppercase
            set func [string toupper $func 0 0]
            lappend ::Nagelfar(pluginHooks$func) $pi
            set ::Nagelfar(plugin$func) 1
        }
    }
    return $pi
}

proc resetPluginData {} {
    foreach func {StatementRaw StatementWords EarlyExpr LateExpr VarWrite
                  VarRead SyntaxComment LineRaw BodyRaw UnknownCommand
    } {
        set ::Nagelfar(pluginHooks$func) {}
        set ::Nagelfar(plugin$func) 0
    }
    set ::Nagelfar(pluginInterp) {}
}

proc initPlugin {} {
    resetPluginData
    foreach plugin $::Nagelfar(plugin) {
        set pinterp [createPluginInterp $plugin]
        if {$pinterp eq ""} {
            puts "Bad plugin: $plugin"
            printPlugins
            exit 1
        }
        lappend ::Nagelfar(pluginInterp) $pinterp
        set ::Nagelfar(pluginNames,$pinterp) $plugin
    }
}

proc finalizePlugin {} {
    foreach pi $::Nagelfar(pluginInterp) {
        if {[$pi eval info proc finalizePlugin] ne ""} {
            set x [$pi eval finalizePlugin]
            if {[catch {llength $x}] || ([llength $x] % 2) != 0} {
                errorMsg E "Plugin $::Nagelfar(pluginNames,$pi) returned malformed list from finalizePlugin" 0
            } else {
                foreach {cmd value} $x {
                    switch $cmd {
                        error   { errorMsg E $value 0 }
                        warning { errorMsg W $value 0 }
                        note    { errorMsg N $value 0 }
                        default {
                            errorMsg E "Plugin $::Nagelfar(pluginNames,$pi) returned bad keyword '$cmd' from finalizePlugin" 0
                        }
                    }
                }
            }
        }

        interp delete $pi
        unset ::Nagelfar(pluginNames,$pi)
    }

    resetPluginData
}

proc pluginHandleWriteHeader {ch} {
    foreach pi $::Nagelfar(pluginInterp) {
        if {[$pi eval info proc writeHeader] ne ""} {
            set x [$pi eval writeHeader]
            foreach value $x {
                if {![regexp "^\#\#nagelfar\[^\n\]" $value]} {
                    errorMsg E "Plugin $::Nagelfar(pluginNames,$pi) returned illegal comment" 0
                } else {
                    puts $ch $value
                }
            }
        }
    }
}

proc printPlugin {plugin} {
    set src [LocatePlugin $plugin]
    if {$src eq ""} {
        printPlugins
        return
    }
    set ch [open $src]
    puts -nonewline [read $ch]
    close $ch
}

proc listPlugins {} {
    set dirs [PluginSearchPath]

    foreach dir $dirs {
        set dir [file normalize $dir]
        set files [glob -nocomplain [file join $dir *.tcl]]
        foreach file $files {
            set file [file normalize $file]
            if {[info exists done($file)]} continue
            if {![file exists $file]} continue
            if {![file isfile $file]} continue
            if {![file readable $file]} continue

            set done($file) 1
            set ch [open $file r]
            set data [read $ch 200]
            close $ch
            if {[regexp {^\#\#Nagelfar Plugin :(.*?)(\n|$)} $data -> descr]} {
                set result([file rootname [file tail $file]]) $descr
            }
        }
    }
    set resultSort {}
    foreach elem [lsort -dictionary [array names result]] {
        lappend resultSort $elem $result($elem)
    }
    return $resultSort
}

proc printPlugins {} {
    set plugins [listPlugins]
    if {[llength $plugins] == 0} {
        puts "No plugins found."
        return
    }
    puts "Available plugins:"
    foreach {plugin descr} $plugins {
        puts "Plugin \"$plugin\" : $descr"
    }
}

# Generic handler to call plugin
proc PluginHandle {
                   pi what indata outdataName knownVarsName index {extraInfo {}}
               } {
    upvar 1 $outdataName outdata $knownVarsName knownVars

    set outdata $indata
    set info [list namespace [currentNamespace] \
                      caller [currentProc] \
                      file $::currentFile \
                      firstpass $::Nagelfar(firstpass) \
                      vars $knownVars \
                      cmds [array names ::syntax]]
    set info [dict merge $info $extraInfo]

    set x [$pi eval [list $what $indata $info]]

    if {[catch {llength $x}] || ([llength $x] % 2) != 0} {
        errorMsg E "Plugin $::Nagelfar(pluginNames,$pi) returned malformed list from $what" $index
        return
    }

    foreach {cmd value} $x {
        switch $cmd {
            replace {
                set outdata $value
            }
            comment {
                foreach line [split $value \n] {
                    checkComment $line $index knownVars
                }
            }
            error   {errorMsg E $value $index 1}
            warning {errorMsg W $value $index 1}
            note    {errorMsg N $value $index 1}
            default {
                errorMsg E "Plugin $::Nagelfar(pluginNames,$pi) returned bad keyword '$cmd' from $what" $index
            }
        }
    }
}

# This is called to let a plugin react to a line
proc pluginHandleLineRaw {lineName knownVarsName lineNo} {
    upvar 1 $lineName line $knownVarsName knownVars

    set outdata $line
    foreach pi $::Nagelfar(pluginHooksLineRaw) {
        PluginHandle $pi lineRaw $line outdata knownVars $lineNo
    }
    set line $outdata
}

# This is called to let a plugin react to a script body
proc pluginHandleBodyRaw {lineName knownVarsName lineNo isSubst} {
    upvar 1 $lineName line $knownVarsName knownVars

    set outdata $line
    foreach pi $::Nagelfar(pluginHooksBodyRaw) {
        PluginHandle $pi bodyRaw $line outdata knownVars $lineNo \
                [list subst $isSubst]
    }
    set line $outdata
}

# This is called to let a plugin react to a statement, pre-substitution
proc pluginHandleStatementRaw {stmtName knownVarsName index} {
    upvar 1 $stmtName stmt $knownVarsName knownVars

    set outdata $stmt
    foreach pi $::Nagelfar(pluginHooksStatementRaw) {
        PluginHandle $pi statementRaw $stmt outdata knownVars $index
    }
    set stmt $outdata
}

# This is called to let a plugin react to a statement, pre-substitution
proc pluginHandleStatementWords {wordsName knownVarsName index} {
    upvar 1 $wordsName words $knownVarsName knownVars

    foreach pi $::Nagelfar(pluginHooksStatementWords) {
        PluginHandle $pi statementWords $words outdata knownVars $index
        # A replacement must be a list
        if {[string is list $outdata]} {
            set words $outdata
        } else {
            errorMsg E "Plugin $::Nagelfar(pluginNames,$pi) returned malformed replacement from statementWords" $index
        }
    }
}

# This is called to let a plugin react to an expression, pre-substitution
proc pluginHandleEarlyExpr {expName knownVarsName index} {
    upvar 1 $expName exp $knownVarsName knownVars

    set outdata $exp
    foreach pi $::Nagelfar(pluginHooksEarlyExpr) {
        PluginHandle $pi earlyExpr $exp outdata knownVars $index
    }
    set exp $outdata
}

# This is called to let a plugin react to an expression, post-substitution
proc pluginHandleLateExpr {expName knownVarsName index} {
    upvar 1 $expName exp $knownVarsName knownVars

    foreach pi $::Nagelfar(pluginHooksLateExpr) {
        PluginHandle $pi lateExpr $exp outdata knownVars $index

        # A replacement expression must not have commands in it
        if {$exp ne $outdata} {
            # It has been replaced
            # a '[' is forbidden but an '\[' is ok
            if {![regexp {^\[|[^\\]\[} $outdata]} {
                set exp $outdata
            } else {
                errorMsg E "Plugin $::Nagelfar(pluginNames,$pi) returned malformed replacement from lateExpr" $index
            }
        }
    }
}

# This is called to let a plugin react to a variable write
proc pluginHandleVarWrite {varName knownVarsName index} {
    upvar 1 $varName var $knownVarsName knownVars

    foreach pi $::Nagelfar(pluginHooksVarWrite) {
        PluginHandle $pi varWrite $var outdata knownVars $index
        set var $outdata
    }
}

# This is called to let a plugin react to a variable read
proc pluginHandleVarRead {varName knownVarsName index} {
    upvar 1 $varName var $knownVarsName knownVars

    foreach pi $::Nagelfar(pluginHooksVarRead) {
        PluginHandle $pi varRead $var outdata knownVars $index
        set var $outdata
    }
}

# This is called to let a plugin see syntax comments
proc pluginHandleComment {type opts} {
    set res false
    foreach pi $::Nagelfar(pluginHooksSyntaxComment) {
        if {[$pi eval [list syntaxComment $type $opts]]} {
            set res true
        }
    }
    return $res
}

# This is called for all unknown commands
proc pluginHandleUnknownCommand {cmdName knownVarsName index} {
    upvar 1 $cmdName cmd $knownVarsName knownVars

    set outdata $cmd
    foreach pi $::Nagelfar(pluginHooksUnknownCommand) {
        PluginHandle $pi unknownCommand $cmd outdata knownVars $index
    }
    set cmd $outdata
}
#----------------------------------------------------------------------
#  Nagelfar, a syntax checker for Tcl.
#  Copyright (c) 1999-2022, Peter Spjuth
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING.  If not, write to
#  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#  Boston, MA 02110-1301, USA.
#
#----------------------------------------------------------------------
# startup.tcl
#----------------------------------------------------------------------

# Output usage info and exit
proc usage {} {
    puts $::version
    puts {Usage: nagelfar [options] scriptfile ...
 -help             : Show usage.
 -gui              : Start with GUI even when files are specified.
 -s <dbfile>       : Include a database file. (More than one is allowed.)
                   : If <dbfile> is "_", it adds the default database.
 -encoding <enc>   : Read script with this encoding.
 -filter <p>       : Any message that matches the glob pattern is suppressed.
 -severity <level> : Set severity level filter to N/W/E (default N).
 -html             : Generate html-output.
 -prefix <pref>    : Prefix for line anchors (html output)
 -novar            : Disable variable checking.
 -WexprN           : Sets expression warning level to N.
   2 (def)         = Warn about any unbraced expression.
   1               = Don't warn on single commands. "if [apa] {...}" is ok.
 -WsubN            : Sets subcommand warning level to N.
   1 (def)         = Warn about shortened subcommands.
 -WelseN           : Enforce else keyword. Default 1.
 -Wunusedvar	   : Check for unused variables.
 -WunusedvarFilter : List of names to ignore for unused check.
 -strictappend     : Enforce having an initialised variable in (l)append.
 -tab <size>       : Tab size, default is 8. Used for indentation checks.
 -len <len>        : Enforce max line length.
 -header <file>    : Create a "header" file with syntax info for scriptfiles.
 -instrument       : Instrument source file for code coverage.
 -markup           : Markup source file with code coverage result.
 -markupfull       : Like -markup, but includes stats for covered blocks.
 -idir <dir>       : Store code coverage files in this dir.
 -nosource         : When instrumenting, do not overload source.
 -quiet            : Suppress non-syntax output.
 -glob <pattern>   : Add matching files to scriptfiles to check.
 -plugin <plugin>  : Run with this plugin.
 -plugindump <plugin> : Print contents of plugin source
 -pluginlist       : List known plugins
 -pluginpath <dir> : Configure plugin search path.
 -H                : Prefix each error line with file name.
 -exitcode         : Return status code 2 for any error or 1 for warning.
 -dbpicky          : Enable checking of syntax DB.
 -pkgpicky         : Warn about redundant package require.
 -trace <file>     : Output debug info to file}
    exit
}

# Initialise global variables with defaults.
proc StartUp {} {
    set ::Nagelfar(db) {}
    set ::Nagelfar(files) {}
    set ::Nagelfar(gui) 0
    set ::Nagelfar(quiet) 0
    set ::Nagelfar(filter) {}
    set ::Nagelfar(2pass) 1
    set ::Nagelfar(encoding) system
    set ::Nagelfar(dbpicky) 0
    set ::Nagelfar(pkgpicky) 0
    set ::Nagelfar(withCtext) 0
    set ::Nagelfar(instrument) 0
    set ::Nagelfar(nosource) 0
    set ::Nagelfar(markup) 0
    set ::Nagelfar(idir) ""
    set ::Nagelfar(header) ""
    set ::Nagelfar(tabReg) { {0,7}\t| {8,8}}
    set ::Nagelfar(tabSub) [string repeat " " 8]
    set ::Nagelfar(tabMap) [list \t $::Nagelfar(tabSub)]
    set ::Nagelfar(lineLen) 0
    set ::Nagelfar(procs) {}
    set ::Nagelfar(stop) 0
    set ::Nagelfar(trace) ""
    set ::Nagelfar(plugin) {}

    if {![info exists ::Nagelfar(embedded)]} {
        set ::Nagelfar(embedded) 0
    }

    getOptions
}

# Procedure to perform a check when embedded.
# If iscontents is set fpath and dbPath contains the file contents, not names
proc synCheck {fpath dbPath {iscontents 0}} {
    if {$iscontents} {
        set ::Nagelfar(scriptContents) $fpath
        set ::Nagelfar(files) {}
    } else {
        set ::Nagelfar(files) [list $fpath]
    }
    set ::Nagelfar(allDb) {}
    set ::Nagelfar(allDbView) {}
    set ::Nagelfar(allDb) [list $dbPath]
    set ::Nagelfar(allDbView) [list [file tail $dbPath] "(app)"]
    if {$iscontents} {
        set ::Nagelfar(dbContents) $dbPath
        set ::Nagelfar(db) {}
    } else {
        set ::Nagelfar(db) [list $dbPath]
    }
    set ::Nagelfar(embedded) 1
    set ::Nagelfar(chkResult) ""
    # FIXA: Allow control of plugin when embedded?
    set ::Nagelfar(plugin) {}
    initPlugin
    doCheck
    if {$iscontents} {
        unset ::Nagelfar(scriptContents)
        unset ::Nagelfar(dbContents)
    }
    return $::Nagelfar(chkResult)
}

# Helper for debug tracer
# Make a compact string for a command to give a decent output in trace
proc traceCompactCmd {cmd} {
    if {[info exists ::memoize_traceCompactCmd($cmd)]} {
        return $::memoize_traceCompactCmd($cmd)
    }
    set res {}
    foreach elem $cmd {
        set cut 0
        set i [string first \n $elem]
        if {$i >= 0} {
            set elem [string range $elem 0 [expr {$i - 1}]]\\n
            set cut 1
        }
        if {[string length $elem] > 40} {
            set elem [string range $elem 0 39]
            set cut 1
        }
        if {$cut} {
            lappend res $elem...
        } else {
            lappend res $elem
        }
    }
    set ::memoize_traceCompactCmd($cmd) $res
    return $res
}

# Debug tracer
proc traceCmd {cmd args} {
    set cmd [traceCompactCmd $cmd]
    set what [lindex $args end]
    set args [lrange $args 0 end-1]
    set ch [open $::Nagelfar(trace) a]
    if {$what in {enter enterstep}} {
        puts $ch "$cmd"
    } else {
        foreach {code res} $args break
        set res [traceCompactCmd [list $res]]
        puts $ch "$cmd --> $code [lindex $res 0]"
        #if {[string match splitScript*bin/sh* $cmd]} exit
    }
    close $ch
}

proc traceVar {name1 name2 op} {
    set ch [open $::Nagelfar(trace) a]
    puts $ch "Variable $op '$name1' '$name2'"
    close $ch
}

# Global code is only run first time to allow re-sourcing
if {![info exists gurka]} {
    set gurka 1

    StartUp

    if {[info exists _nagelfar_test]} return
    # To use Nagelfar embedded, set ::Nagelfar(embedded) 1
    # before sourcing nagelfar.tcl.
    if {$::Nagelfar(embedded)} return

    # Locate default syntax database(s)
    set ::Nagelfar(allDb) {}
    set ::Nagelfar(allDbView) {}
    set apa {}
    lappend apa [file join [pwd] syntaxdb.tcl]
    eval lappend apa [glob -nocomplain [file join [pwd] syntaxdb*.tcl]]

    lappend apa [file join $::dbDir syntaxdb.tcl]
    eval lappend apa [glob -nocomplain [file join $::dbDir syntaxdb*.tcl]]
    set pdbDir [file join $::dbDir packagedb]
    eval lappend apa [glob -nocomplain [file join $pdbDir *db*.tcl]]

    set ::Nagelfar(pluginPath) {}

    foreach file $apa {
        if {[file isfile $file] && [file readable $file] && \
                [lsearch $::Nagelfar(allDb) $file] == -1} {
            lappend ::Nagelfar(allDb) $file
            if {[file dirname $file] == $::dbDir} {
                lappend ::Nagelfar(allDbView) "[file tail $file] (app)"
            } elseif {[file dirname $file] == $pdbDir} {
                lappend ::Nagelfar(allDbView) "[file tail $file] (app)"
            } else {
                lappend ::Nagelfar(allDbView) [fileRelative [pwd] $file]
            }
        }
    }

    # Parse command line options
    for {set i 0} {$i < $argc} {incr i} {
        set arg [lindex $argv $i]
        switch -glob -- $arg {
            --h* -
            -h - -hel* {
                usage
            }
            -s {
                incr i
                set arg [lindex $argv $i]
                if {$arg eq "_"} {
                    # Add the first, or none if allDb is empty
                    lappend ::Nagelfar(db) {*}[lrange $::Nagelfar(allDb) 0 0]
                } elseif {[file isfile $arg] && [file readable $arg]} {
                    lappend ::Nagelfar(db) $arg
                    lappend ::Nagelfar(allDb) $arg
                    lappend ::Nagelfar(allDbView) $arg
                } else {
                    # Look through allDb for a match
                    set found 0
                    foreach db $::Nagelfar(allDb) {
                        if {$arg eq $db || $arg eq [file tail $db]} {
                            lappend ::Nagelfar(db) $db
                            set found 1
                            break
                        }
                    }
                    if {!$found} {
                        puts stderr "Cannot read \"$arg\""
                    }
                }
            }
            -editor {
                incr i
                set arg [lindex $argv $i]
                switch -glob -- $arg {
                    ema*    {set ::Prefs(editor) emacs}
                    inte*   {set ::Prefs(editor) internal}
                    vi*     {set ::Prefs(editor) vim}
                    default {
                        puts stderr "Bad -editor option: \"$arg\""
                    }
                }
            }
            -encoding {
                incr i
                set enc [lindex $argv $i]
                if {$enc eq ""} {set enc system}
                if {[lsearch -exact [encoding names] $enc] < 0} {
                    puts stderr "Bad encoding name: \"$enc\""
                    set enc system
                }
                set ::Nagelfar(encoding) $enc
            }
            -H {
                set ::Prefs(prefixFile) 1
            }
            -exitcode {
                set ::Prefs(exitcode) 1
            }
            -2pass {
                set ::Nagelfar(2pass) 1
            }
            -gui {
                set ::Nagelfar(gui) 1
            }
            -quiet {
                set ::Nagelfar(quiet) 1
            }
            -header {
                incr i
                set arg [lindex $argv $i]
                set ::Nagelfar(header) $arg
                # Put checks down as much as possible
                array set ::Prefs {
                    warnBraceExpr 0
                    warnShortSub 0
                    strictAppend 0
                    forceElse 0
                    noVar 1
                    severity E
                }
            }
            -instrument {
                set ::Nagelfar(instrument) 1
                # Put checks down as much as possible
                array set ::Prefs {
                    warnBraceExpr 0
                    warnShortSub 0
                    strictAppend 0
                    forceElse 0
                    noVar 1
                    severity E
                }
            }
            -nosource {
                set ::Nagelfar(nosource) 1
            }
            -markup* {
                set ::Nagelfar(markup) [expr {1 + ($arg eq "-markupfull")}]
            }
            -idir {
                incr i
                set arg [lindex $argv $i]
                set ::Nagelfar(idir) $arg
            }
            -plugin {
                incr i
                set arg [lindex $argv $i]
                lappend ::Nagelfar(plugin) $arg
            }
            -plugindump {
                incr i
                set arg [lindex $argv $i]
                printPlugin $arg
                exit
            }
            -pluginlist {
                printPlugins
                exit
            }
            -pluginpath {
                incr i
                set arg [lindex $argv $i]
                lappend ::Nagelfar(pluginPath) $arg
            }
            -novar {
                set ::Prefs(noVar) 1
            }
	    -Wunusedvar {
                set ::Prefs(warnUnusedVar) 1
	    }
	    -WunusedvarFilter {
		incr i
                set arg [lindex $argv $i]
                lappend ::Prefs(warnUnusedVarFilter) $arg
	    }
            -dbpicky { # A debug thing to help make a more complete database
                set ::Nagelfar(dbpicky) 1
            }
            -pkgpicky { # A debug thing to help make a more complete database
                set ::Nagelfar(pkgpicky) 1
            }
            -Wexpr* {
                set ::Prefs(warnBraceExpr) [string range $arg 6 end]
            }
            -Wsub* {
                set ::Prefs(warnShortSub) [string range $arg 5 end]
            }
            -Welse* {
                set ::Prefs(forceElse) [string range $arg 6 end]
            }
            -strictappend {
                set ::Prefs(strictAppend) 1
            }
            -filter {
                incr i
                addFilter [lindex $argv $i]
            }
            -severity {
                incr i
                set ::Prefs(severity) [lindex $argv $i]
                if {![regexp {^[EWN]$} $::Prefs(severity)]} {
                    puts "Bad severity level '$::Prefs(severity)',\
                            should be E/W/N."
                    exit
                }
            }
            -html {
                set ::Prefs(html) 1
            }
            -prefix {
                incr i
                set ::Prefs(htmlprefix) [lindex $argv $i]
            }
            -len {
                incr i
                set arg [lindex $argv $i]
                if {![string is integer -strict $arg] || $arg < 1} {
                    puts "Bad len value '$arg'"
                    exit
                }
                set ::Nagelfar(lineLen) $arg
            }
            -tab {
                incr i
                set arg [lindex $argv $i]
                if {![string is integer -strict $arg] || \
                        $arg < 2 || $arg > 20} {
                    puts "Bad tab value '$arg'"
                    exit
                }
                set ::Nagelfar(tabReg) " {0,[expr {$arg - 1}]}\t| {$arg,$arg}"
                set ::Nagelfar(tabSub) [string repeat " " $arg]
                set ::Nagelfar(tabMap) [list \t $::Nagelfar(tabSub)]
            }
            -glob {
                incr i
                set files [glob -types f -nocomplain [lindex $argv $i]]
                set ::Nagelfar(files) [concat $::Nagelfar(files) $files]
            }
            -trace {
                # Turn on debug tracer and set its output file name
                incr i
                set ::Nagelfar(trace) [lindex $argv $i]
            }
             -* {
                puts "Unknown option $arg"
                usage
            }
            default {
                lappend ::Nagelfar(files) $arg
            }
        }
    }

    if {$::Nagelfar(markup)} {
        instrumentMarkup [lindex $::Nagelfar(files) 0] \
                [expr {$::Nagelfar(markup) == 2}]
        exit
    }
    # Sanity check
    if {$::Nagelfar(idir) ne "" && !$::Nagelfar(instrument)} {
        puts "Option -idir can only be used with -instrument or -markup*"
        exit
    }

    # Initialise plugin system
    initPlugin

    # Use default database if none were given
    if {[llength $::Nagelfar(db)] == 0} {
        if {[llength $::Nagelfar(allDb)] != 0} {
            lappend ::Nagelfar(db) [lindex $::Nagelfar(allDb) 0]
        }
    }

    # If we are on Windows and Tk is already loaded it means we run in
    # wish, and there is no stdout. Thus non-gui is pointless.
    if {!$::Nagelfar(gui) && $::tcl_platform(platform) eq "windows" &&
        [package provide Tk] ne ""} {
        set ::Nagelfar(gui) 1
    }

    if {$::Nagelfar(trace) ne ""} {
        # Turn on debug tracer and initialise its output file
        set ch [open $::Nagelfar(trace) w]
        close $ch
        foreach cmd [info procs] {
            # Trace all procedures but those involved in the trace command
            if {$cmd in {trace proc traceCmd traceCompactCmd traceVar set open puts close}} continue
            trace add execution $cmd enter traceCmd
            trace add execution $cmd leave traceCmd
            # Infastructure for more info
            if {$cmd in {lookForCommand}} {
                #trace add execution $cmd enterstep traceCmd
                #trace add execution $cmd leavestep traceCmd
            }
        }
    }

    # If there is no file specified, try invoking a GUI
    if {$::Nagelfar(gui) || [llength $::Nagelfar(files)] == 0} {
        if {[catch {package require Tk}]} {
            if {$::Nagelfar(gui)} {
                puts stderr "Failed to start GUI"
                exit 1
            } else {
                puts stderr "No files specified"
                exit 1
            }
        }
        # use ctext if available
        if {![catch {package require ctext}]} {
            if {![catch {package require ctext_tcl}]} {
                if {[info procs ctext::setHighlightTcl] ne ""} {
                    set ::Nagelfar(withCtext) 1
                    proc ctext::update {} {::update}
                }
            }
        }

        catch {package require textSearch}
        set ::Nagelfar(gui) 1
        makeWin
        vwait forever
        exit
    }

    doCheck

    #_dumplogme
    #if {[array size _stats] > 0} {
    #    array set _apa [array get _stats]
    #    parray _apa
    #    set sum 0
    #    foreach name [array names _apa] {
    #        incr sum $_apa($name)
    #    }
    #    puts "Total $sum"
    #}
    exit [expr {$::Prefs(exitcode) ? $::Nagelfar(exitstatus) : 0}]
}
