xquery version "3.0"; 

declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: This script checks whether all previously missing TIFF references are 
 : now present in the msDesc documents.
 : 
 : Author: Daniel Schopper
 : Input: uebreschuessige_tifs.xml
 : Output: in case, every image is found in the msDesc, the script 
 : returns nothing; otherwise it lists the ids of images which are not 
 : found in the msDesc.
 : oXygen transformation scenario: Nachlass – Patch msDesc 06 – Verify
 :)


(: the directory containting the bequest data :)
declare variable $base-dir external;

(: msDDesc_by_item_ID is an index file providing the path to a msDesc 
 : document by its ID
 : It's ashamingly created by 
 : [danielschopper@ACDH-NB10 102_07_bequest]$ echo "<files>$(for i in `grep -rPo "(?<=verz_einh\"\>)\d+" msDesc/*`; do echo "<file path=\"$(echo $i | sed 's/:/">/g')</file>"; done)</files>" > msDesc_by_item_ID.xml
 :  
 :)
declare variable $msDesc_by_item_ID_filename as xs:string  := "msDesc_by_item_ID.xml";

let $msDesc_by_item_ID := doc($base-dir||"/"||$msDesc_by_item_ID_filename)
return
    (: iterate over all objects and find its path in the msDesc index file :)
    for $vze in //vze
    let $file := $msDesc_by_item_ID//file[xs:integer(.) = $vze/xs:integer(@n)]
    return 
        if (not($file))
        then ("no element with @n='"||$vze/@n||"' found in the msDesc file index", $vze)
        else 
            let $msDescPath := $base-dir||"/"||$file/@path
            let $msDescAvailable := doc-available($msDescPath)
            return
                if (not ($msDescAvailable))
                then "msDesc not found at "||$msDescPath
                else 
                    let $msDesc := doc($msDescPath)
                    return 
                    (: iterate over all unreferenced images for this object and check 
                       if a surface exists in the object's msDesc file :) 
                    for $bild in $vze//bild
                    let $surface := $msDesc//tei:surface[@xml:id = "s"||$bild/@id]
                    return 
                        if (exists($surface)) then () else $bild