#! /usr/bin/env tclsh8.5

package require teaspoon

namespace eval ::foo {
    variable message "Hello, world!"

    set processor [::teaspoon::processor new]

    coroutine resume $processor process "test.tsp" ::foo

    set i 0

    while {[info commands resume] ne {}} {
        resume [incr i]
    }

    $processor destroy
}
