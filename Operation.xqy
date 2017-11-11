declare namespace saxon="net.sf.saxon.Query";
import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace json="http://marklogic.com/xdmp/json"  at "/MarkLogic/json/json.xqy";
import module namespace LIB = "http://www.adapt.ie/kul-lib" at "Lib.xqy";

xdmp:set-response-content-type("text/html")

,


"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>"

,



let $mode := xdmp:get-request-field('mode')
let $url := xdmp:get-request-field('url')
return
   if($mode = 'load')
   then
     let $_ := sem:rdf-load
            (
                $url
                 ,
                ('turtle', fn:concat('graph=http://marklogic.com/semantics/',tokenize($url,'\\')[last()]))
                ,
                ()
                ,
                ()
                ,
                tokenize($url,'\\')[last()]
            )     
     return 
        xdmp:redirect-response("./main.xqy")
   else
    if($mode = 'changedetection')
    then
        (:Update detection:)

        (

        let $queryUpdate := "

        import module namespace LIB = 'http://www.adapt.ie/kul-lib' at 'Lib.xqy';

        for $deletedRes in collection('http://marklogic.com/semantics/features/delete/3.2-person.nt')/allFeatures/@res
        let $newRes := collection('http://marklogic.com/semantics/features/new/3.3-person.nt')/allFeatures/@res[. = $deletedRes]
        return 
          if($newRes)
          then     
            let $delURI := $deletedRes/base-uri()
            let $deleteCollection := xdmp:document-get-collections($delURI)
            let $newURI := $newRes/base-uri()
            let $newCollection := xdmp:document-get-collections($newRes/base-uri())
            let $doc := LIB:identify-update($deletedRes, $newRes)
            let $docURI := fn:concat('/update/features/', tokenize($deletedRes, '/')[last()])
            let $collec := concat('http://marklogic.com/semantics/features/update/', tokenize($deleteCollection, '/')[last()], '-',tokenize($newCollection, '/')[last()])
            return
              (
              xdmp:document-remove-collections($delURI, $deleteCollection)
              ,
              xdmp:document-remove-collections($newURI, $newCollection)
              ,
              xdmp:document-insert($docURI, $doc, (), $collec)
              ,
              xdmp:redirect-response('./main.xqy')
              )                 
          else ()"
          return
            xdmp:eval($queryUpdate)
          ,

        (:Move detection:)
        let $queryMove := "

        import module namespace LIB = 'http://www.adapt.ie/kul-lib' at 'Lib.xqy';
        for $deletedRes in collection('http://marklogic.com/semantics/features/delete/3.2-person.nt')/allFeatures/@res
        let $totalFeature := count($deletedRes/../*)
        let $doc := LIB:identify-move($deletedRes, $totalFeature)
        let $oldResource := data($doc//old)
        let $newResource := data($doc//new)
        let $docURI := fn:concat('/move/features/', tokenize($deletedRes, '/')[last()],'--',tokenize(data($doc//new/@featureURI),'/')[last()])
        let $newURI := data($doc//new/@featureURI)
        let $newCollection := xdmp:document-get-collections($newURI)          
        let $delURI := $deletedRes/base-uri()
        let $deleteCollection := xdmp:document-get-collections($delURI)        
        let $collec := concat('http://marklogic.com/semantics/features/move/', tokenize($deleteCollection, '/')[last()], '-',tokenize($newCollection, '/')[last()])        
        return          
          if($doc and ($oldResource != $newResource))
          then
          (
            xdmp:document-remove-collections($delURI, $deleteCollection)
            ,
            xdmp:document-remove-collections($newURI, $newCollection)
            ,
            xdmp:document-insert($docURI, $doc, (), $collec)
            ,
            xdmp:redirect-response('./main.xqy')
          )
          else ()"
          return
            xdmp:eval($queryMove) 
        )

    else
      if($mode = 'extractfeatures')
      then  
        let $graph1Name := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')/*:config/*:change-detection/*:base-version
        let $base-graph := fn:concat('http://marklogic.com/semantics/', $graph1Name)
        let $graph2Name := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')/*:config/*:change-detection/*:updated-version
        let $updated-graph := fn:concat('http://marklogic.com/semantics/', $graph2Name)
        let $IdentifyPotentialNewTriples := LIB:get-potential-new-triples($base-graph, $updated-graph)
        let $IdentifyPotentialDeletedTriples := LIB:get-potential-deleted-triples($base-graph, $updated-graph) 
        let $saveFeatures := 
                            (
                            for $eachResourceNew at $pos in distinct-values(json:transform-from-json($IdentifyPotentialNewTriples)//*:S)        
                            let $_ :=  LIB:get-resource-features($eachResourceNew, 'new', $graph2Name)
                            return
                              if($pos mod 1000 = 0)
                              then   
                                xdmp:log($pos)
                              else ()  
                            ,

                            for $eachResourceDelete at $pos in distinct-values(json:transform-from-json($IdentifyPotentialDeletedTriples)//*:S)        
                            let $_ :=  LIB:get-resource-features($eachResourceDelete, 'delete', $graph1Name)
                            return
                              if($pos mod 1000 = 0)
                              then   
                                xdmp:log($pos)
                              else ()
                            )
        return
          xdmp:redirect-response("./main.xqy")

      else ()