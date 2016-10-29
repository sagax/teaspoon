package provide teaspoon::handler      0.1
package require teaspoon::processor    0.1
package require tanzer::file::handler  0.1
package require tanzer::uri            0.1
package require TclOO

::oo::class create ::teaspoon::handler {
    superclass ::tanzer::file::handler
}

::oo::define ::teaspoon::handler constructor {opts} {
    my variable processor

    set processor [::teaspoon::processor new]

    next $opts
}

::oo::define ::teaspoon::handler destructor {
    my variable processor

    $processor destroy
}

::oo::define ::teaspoon::handler method read {session data} {
    my variable bodies

    append bodies($session) $data
}

::oo::define ::teaspoon::handler method serve {session localPath st} {
    my variable processor bodies

    set request [$session request]
    set name    [file tail $localPath]
    set type    [if {[$request headerExists "Content-Type"]} {
        $request header "Content-Type"
    } else {
        list
    }]

    switch -glob -nocase -- $name {*.tsp} {#} default {
        return [next $session $localPath $st]
    }

    if {$type eq "application/x-www-form-urlencoded"} {
        $request params [::tanzer::uri::params $bodies($session)]
    }

    $session response -new [::tanzer::response new 200 {
        Content-Type "text/html"
    }]

    $session respond

    $processor process $localPath $session [list $session write]

    $session nextRequest
}
