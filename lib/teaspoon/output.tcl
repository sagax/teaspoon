package provide teaspoon::output 0.1
package require TclOO

::oo::class create ::teaspoon::output

::oo::define ::teaspoon::output constructor {newOutputCommand} {
    my variable outputCommand

    set outputCommand $newOutputCommand
}

::oo::define ::teaspoon::output method initialize {args} {
    return [list initialize finalize clear flush write]
}

::oo::define ::teaspoon::output method finalize {args} {
    return
}

::oo::define ::teaspoon::output method clear {args} {
    return
}

::oo::define ::teaspoon::output method flush {handle} {
    flush $handle
}

::oo::define ::teaspoon::output method write {handle data} {
    my variable outputCommand

    {*}$outputCommand $data

    return
}
