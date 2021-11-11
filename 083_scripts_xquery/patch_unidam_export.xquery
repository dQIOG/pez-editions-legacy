xquery version "3.0";

import module namespace xlsx2t = "http://acdh.oeaw.ac.at/xls2t" at "xlsxquery.xqm";
declare namespace ss="urn:schemas-microsoft-com:office:spreadsheet";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
(:~
 : UNIDAM export patch script
 : Author: Daniel Schopper
 : Expected Input: ueberschuessige_tifs-Zuordnung.xml
 : Expected Output: unidam-export-patches.xml
 : 
 : 
 : Background: See README_UNIDAM_patch.md
 : 
 :  
~:)

let $table := //ss:Table[1]
let $vze := 
    for tumbling window $rows in subsequence($table/ss:Row, 2)[exists(xlsx2t:data-by-index(., 5))]
    start $first when exists(xlsx2t:data-by-index($first, 1))
    let $nr as xs:integer := xs:integer(xlsx2t:data-by-index($first, 1))
    let $filename := doc("files.xml")//file[xs:integer(.) = $nr]/@path 
    return <verz_einh nr="{$nr}" filename="{$filename}">{
        for $r in $rows
        let $id := xlsx2t:data-by-index($r, 6)
        let $n := xlsx2t:data-by-index($r, 7)
        return <img n="{$n}">{$id}</img>
    }</verz_einh>
return <_>{$vze}</_>
