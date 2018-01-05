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

        for $deletedRes at $position in (collection('http://marklogic.com/semantics/features/delete/3.2-person.nt')/allFeatures/@res, collection('http://marklogic.com/semantics/features/probableUpdateInBase/3.2-person.nt')/allFeatures/@res)

        let $newRes := (collection('http://marklogic.com/semantics/features/new/3.3-person.nt')/allFeatures/@res[. = $deletedRes], collection('http://marklogic.com/semantics/features/probableUpdateInUpdate/3.3-person.nt')/allFeatures/@res[. = $deletedRes])

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
              xdmp:document-delete($delURI)
              ,
              xdmp:document-delete($newURI)
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

        let $compiledMoved := <root></root>
        let $allMoved :=
          for $deletedRes in collection('http://marklogic.com/semantics/features/delete/3.2-person.nt')/allFeatures/@res
          let $_ := xdmp:log($deletedRes)
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
          let $prepareAddToComiledMove := <match similarityPercentage='{data($doc/@similarFeaturesPercentage)}' delURI='{$delURI}' deleteCollection='{$deleteCollection}' newURI='{$newURI}' newCollection='{$newCollection}' docURI='{$docURI}' collec='{$collec}'>
                                            {data($doc//new/@featureURI)}
                                          </match>        
          return                    
              if($doc and ($oldResource != $newResource))
              then
                (
                $doc            
                ,
                xdmp:set($compiledMoved, <root>{($compiledMoved/*, $prepareAddToComiledMove)}</root>)
                )
              else ()

        for $eachDetectedMove in distinct-values($compiledMoved//match)
          let $duplicate := $compiledMoved//match[. = $eachDetectedMove]
          
          return
            if(count($duplicate) > 1)
            then 
              let $max := max($duplicate/@similarityPercentage)
              let $duplicate := $duplicate[@similarityPercentage = $max]

              return
                if(count($duplicate) > 1)
                then ()
                else
                  (                  
                  xdmp:document-remove-collections($duplicate/@delURI, $duplicate/@deleteCollection)
                  ,
                  xdmp:document-remove-collections($duplicate/@newURI, $duplicate/@newCollection)
                  ,
                  xdmp:document-insert($duplicate/@docURI, $allMoved[new/@featureURI = $eachDetectedMove and @similarFeaturesPercentage = $max], (), $duplicate/@collec)             
                  )
            else
              (
              xdmp:document-remove-collections($duplicate/@delURI, $duplicate/@deleteCollection)
              ,
              xdmp:document-remove-collections($duplicate/@newURI, $duplicate/@newCollection)
              ,
              xdmp:document-insert($duplicate/@docURI, $allMoved[new/@featureURI = $eachDetectedMove], (), $duplicate/@collec)             
              )
          "
          return 
            (xdmp:eval($queryMove),  xdmp:redirect-response('./main.xqy'))
        ,

        (:Move and update detection:)  

        let $queyMoveAndUpdate := "

        import module namespace LIB = 'http://www.adapt.ie/kul-lib' at 'Lib.xqy';
        let $graph1Name := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')/*:config/*:change-detection/*:base-version
        let $graph2Name := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')/*:config/*:change-detection/*:updated-version
        let $moveAndUpdate := LIB:identify-move-and-update($graph1Name, $graph2Name) 
          return ()
        "
        return
          xdmp:eval($queyMoveAndUpdate)
         
        ,

        xdmp:redirect-response("./main.xqy")
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
                            let $check := 
                                            let $checkJustURIInBaseGraphQuery := fn:concat(' SELECT *
                                                                                WHERE
                                                                                {    
                                                                                  GRAPH <',$base-graph,'>  
                                                                                  {
                                                                                      <',$eachResourceNew,'> ?P ?O

                                                                                  }       
                                                                                }')

                                            let $checkJustURIInBaseGraphQueryExecution :=  json:transform-from-json(sem:sparql($checkJustURIInBaseGraphQuery)) 

                                            let $checkIfDeletedTriplesHaveQuery := 
                                                                                fn:concat(' SELECT *
                                                                                WHERE
                                                                                {    
                                                                                  GRAPH <',$base-graph,'>  
                                                                                  {
                                                                                      <',$eachResourceNew,'> ?P ?O

                                                                                  }
                                                                                  FILTER NOT EXISTS
                                                                                  {
                                                                                    GRAPH <',$updated-graph,'>  
                                                                                    {
                                                                                        <',$eachResourceNew,'> ?P ?O

                                                                                    }   
                                                                                  }
                                                                                }')

                                            let $checkIfDeletedTriplesHaveQueryExecution := 
                                                                                if($checkJustURIInBaseGraphQueryExecution)
                                                                                then 
                                                                                  if(json:transform-from-json(sem:sparql($checkIfDeletedTriplesHaveQuery)))
                                                                                  then ''
                                                                                  else 'probale update'
                                                                                else ''
                                            return
                                              if($checkIfDeletedTriplesHaveQueryExecution = 'probale update')
                                              then LIB:get-resource-features($eachResourceNew, 'probableUpdateInBase', $graph1Name)                                               
                                              else ()
                            return
                              if($pos mod 1000 = 0)
                              then   
                                xdmp:log($pos)
                              else ()  
                            ,

                            for $eachResourceDelete at $pos in distinct-values(json:transform-from-json($IdentifyPotentialDeletedTriples)//*:S)        
                            let $_ :=  LIB:get-resource-features($eachResourceDelete, 'delete', $graph1Name)
                            let $check := 
                                            let $checkJustURIInBaseGraphQuery := fn:concat(' SELECT *
                                                                                WHERE
                                                                                {    
                                                                                  GRAPH <',$updated-graph,'>  
                                                                                  {
                                                                                      <',$eachResourceDelete,'> ?P ?O

                                                                                  }       
                                                                                }')
                                            let $checkJustURIInBaseGraphQueryExecution :=  json:transform-from-json(sem:sparql($checkJustURIInBaseGraphQuery))                                           
                                            let $checkIfDeletedTriplesHaveQuery := 
                                                                                fn:concat(' SELECT *
                                                                                WHERE
                                                                                {    
                                                                                  GRAPH <',$updated-graph,'>  
                                                                                  {
                                                                                      <',$eachResourceDelete,'> ?P ?O

                                                                                  }
                                                                                  FILTER NOT EXISTS
                                                                                  {
                                                                                    GRAPH <',$base-graph,'>  
                                                                                    {
                                                                                        <',$eachResourceDelete,'> ?P ?O

                                                                                    }   
                                                                                  }
                                                                                }')

                                            let $checkIfDeletedTriplesHaveQueryExecution := 
                                                                                if($checkJustURIInBaseGraphQueryExecution)
                                                                                then 
                                                                                  if(json:transform-from-json(sem:sparql($checkIfDeletedTriplesHaveQuery)))
                                                                                  then ''
                                                                                  else 'probale update'
                                                                                else ''
                                            return
                                              if($checkIfDeletedTriplesHaveQueryExecution = 'probale update')
                                              then LIB:get-resource-features($eachResourceDelete, 'probableUpdateInUpdate', $graph2Name)                                               
                                              else ()
                            return
                              if($pos mod 1000 = 0)
                              then   
                                xdmp:log($pos)
                              else ()
                            )
        return
          xdmp:redirect-response("./main.xqy")

      else ()