package provide teaspoon::template 0.1
package require teaspoon::output
package require TclOO

namespace eval ::teaspoon::template {}

proc ::teaspoon::template::transformTag {tag} {
    switch -regexp -matchvar script -- $tag {^<%\[(.*)\]%>$} {
        return [format {
            puts -nonewline [%s]
        } [lindex $script 1]]
    } {^<%=(.*)%>$} {
        return [format {
            puts -nonewline [expr {%s}]
        } [lindex $script 1]]
    } {^<%(.*)%>$} {
        return [lindex $script 1]
    }

    error "Invalid tag $tag"
}

::oo::class create ::teaspoon::template

::oo::define ::teaspoon::template constructor {templateFile} {
    my variable raw script

    set fh     [open $templateFile]
    set raw    [read -nonewline $fh]
    set script {}

    close $fh
}

::oo::define ::teaspoon::template method transform {} {
    my variable raw script

    if {$script ne {}} {
        return $script
    }

    set parts [list]

    set opener "<%"
    set closer "%>"

    set length [string length $raw]
    set start   0
    set end    -2

    while {1} {
        #
        # Determine the first instance of the start of the next tag opening
        # from our current position.
        #
        set start [string first $opener $raw $end]

        #
        # If we were not able to find any more tag openings, then output the
        # remaining buffer to the list and bail.
        #
        if {$start < 0} {
            lappend parts [list puts -nonewline [string range $raw \
                [expr {$end + 2}] $length]]

            break
        }

        #
        # Output everything between the current offset and the current tag
        # opening.
        #
        lappend parts [list puts -nonewline [string trimleft \
            [string range $raw [expr {$end + 2}] [expr {$start - 1}]]]]

        #
        # Determine where the tag closing is.
        #
        set end [string first $closer $raw [expr {$start + 2}]]

        #
        # Capture the entire tag.
        #
        set tag [string range $raw $start [expr {$end + 1}]]

        #
        # Transform the tag into the most appropriate script.
        #
        lappend parts [::teaspoon::template::transformTag $tag]

        #
        # If we were not able to find a tag closing at this point, then throw
        # an error.
        #
        if {$end < 0} {
            error "Syntax error: Missing template tag closing"
        }
    }

    return [set script [join $parts "\n"]]
}

::oo::define ::teaspoon::template method process {{ns ::} {outputCommand {}}} {
    if {$outputCommand ne {}} {
        set output [::teaspoon::output new $outputCommand]

        chan push stdout $output
    }

    set failed [catch {
        set result [namespace eval $ns [my transform]]
    } err]

    if {$outputCommand ne {}} {
        chan pop stdout
        $output destroy
    }

    if {$failed} {
        error $err
    }

    return $result
}
