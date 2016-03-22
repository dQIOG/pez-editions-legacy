xquery version "3.0" encoding "utf-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $letter := "letter "||//id
return
if (exists(//tei:seg[@type = 'context']))
then
    let $max := max(//tei:seg[@type = 'context']/xs:integer(@n))
    return
        for $i in 1 to $max
        let $segs := //tei:seg[@type = 'context'][@n = $i]
        return 
            if (not(exists($segs[ancestor::tei:div[@type = 'regest']]))) then <error>{$letter} seg @n {$i} missing in regest</error> else
            if (not(exists($segs[ancestor::tei:div[@type = 'edition']]))) then <error>{$letter} seg @n {$i} missing in edition text</error>
            else ()
else 
    if (//deduced = 'true')
    then ()
    else <warn>{$letter} has no contexts (not even one!)</warn>
