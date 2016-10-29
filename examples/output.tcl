#! /usr/bin/env tclsh8.6

package require teaspoon::output

proc myputs {data} {
    puts -nonewline stderr "Hello cats: $data"
}

set layer  [::teaspoon::output new myputs]
set handle [chan push stdout $layer]

puts "Hello, world!"
