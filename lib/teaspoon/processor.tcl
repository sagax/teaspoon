package provide teaspoon::processor 0.1
package require teaspoon::template  0.1
package require teaspoon::output    0.1

::oo::class create ::teaspoon::processor

::oo::define ::teaspoon::processor constructor {} {
    my variable cache

    set cache [dict create]
}

::oo::define ::teaspoon::processor destructor {
    my variable cache

    dict for {dev data1} $cache {
        dict for {ino data} $data1 {
            [dict get $data template] destroy
        }
    }
}

::oo::define ::teaspoon::processor method process {templateFile {ns ::} {outputCommand {}}} {
    my variable cache

    set miss 1

    file stat $templateFile st

    if {[dict exists $cache $st(dev) $st(ino)]} {
        set data [dict get $cache $st(dev) $st(ino)]

        if {$st(mtime) <= [dict get $data st mtime]} {
            set miss 0
            set template [dict get $data template]
        }
    }

    if {$miss} {
        set template [::teaspoon::template new $templateFile]

        dict set cache $st(dev) $st(ino) [dict create \
            st           [array get st] \
            templateFile $templateFile  \
            template     $template]
    }

    return [$template process $ns $outputCommand]
}
