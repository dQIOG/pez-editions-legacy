(: gruppiert BildPersonen.xml (Export der Bild-Personen relations-Tabelle aus UNIDAM) nach Personen :)
<PersonBilder>{
    for $pid in distinct-values(//Person/@id)
    let $p := (//Person[@id = $pid])[1]
    let $bilder := //BildPerson[Person/@id = $p/@id]
    return 
    <Person id="{$p/@id}" vorname="{$p/Vorname}" name="{$p/Name}" occurences="{count($bilder)}">{
        for $b in $bilder
        return <Bild bildid="{$b/@bildid}" relation="{$b/@relation}">{$b/BildBeschreibung}</Bild>
    }</Person>
}</PersonBilder>