xquery version "1.0-ml"; 


import module namespace sem = "http://marklogic.com/semantics" 
      at "/MarkLogic/semantics.xqy";
 
for $eachFile in xdmp:filesystem-directory('C:\Users\Anuj Singh\Downloads\testing\3.3-infoboxes\batch4')/*
let $_ := xdmp:log(concat('Start loading----', data($eachFile//*:filename)))

let $_ := sem:rdf-load(data($eachFile//*:pathname)
             ,
            ('turtle', 'graph=http://marklogic.com/semantics/DBpedia/3.3-infobox')
            ,
            ()
            ,
            ()
            ,
            '3.3-infobox'
            )
            
let $_ := xdmp:log(concat('Finished loading----', data($eachFile//*:filename)))

return ()