xquery version "3.0";
declare namespace f = "http://expath.org/ns/file";

(:
 : script for identifying TIFF files not referenced in the UNIDAM export
 : Author: Daniel Schopper
 : See README_UNIDAM_patch.md
 : 
 : Inputs: 
 :    * Primary input / Transformation source: nothing
 :    * Secondary inputs: 
 :      * tifs: a text file with tif lists produced by `find . -name *.tif > tifs` (loaded in line 19)
 :      * Bilder-1-794.xml: UNIDAM image list XML export
 :      * _verz_einh/*.xml: UNIDAM metadata
 : Output: ueberschuessige_tifs.xml
 :)

declare variable $path-to-tiff-list := "/mnt/acdh_resources/container/C_pez_19366/R_pez_unidam_export_8768/tifs";
declare variable $path-to-verz_einh_dir := "/mnt/acdh_resources/container/C_pez_19366/R_pez_unidam_export_8768/_verz_einh/";
declare variable $path-to-unidam-md-export := "/mnt/acdh_resources/container/C_pez_19366/R_pez_unidam_export_8768/Bilder-1-794.xml";

<ueberschuessige_tifs>{
for $cs in tokenize(unparsed-text("file:"||$path-to-tiff-list),'\n')[normalize-space(.)!='']
let $ct := tokenize($cs,'/')
let $vze := $ct[2]
let $img := $ct[last()]
group by $vze
order by xs:integer($vze)
return 
    let $vze-xml-path := "file:"||$path-to-verz_einh_dir||format-number(xs:integer($vze),'0')||".xml" 
    let $bild1 := doc("file:"||$path-to-unidam-md-export)//bild[verz_einh/@id = xs:integer($vze)] 
    let $vze-xml := 
        try { doc($vze-xml-path) }
        catch * {()}
    return  
        let $diffs := 
            for $c in $cs return 
            let $id := substring-before(tokenize($c,'/')[last()],'.tif')
            return 
                if (not(($bild1,$vze-xml//bild)[@id = $id]))
                then <bild id="{$id}">{$c}</bild>
                else ()
        return
        if (count($diffs) gt 0)
        then <vze n="{$vze}" first-id="{$bild1/@id}" last-id="{($bild1,$vze-xml)//bild[last()]/@id}" cnt="{count($diffs)}">{$diffs}</vze>
        else ()

}</ueberschuessige_tifs>
