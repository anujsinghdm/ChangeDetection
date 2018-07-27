import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace json="http://marklogic.com/xdmp/json"  at "/MarkLogic/json/json.xqy";
declare variable $graph1Name := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')/*:config/*:change-detection/*:base-version;        
declare variable $graph2Name := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')/*:config/*:change-detection/*:updated-version;
xdmp:set-response-content-type("text/html")

,


"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>"

,



<html>
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />    
    <link rel="stylesheet" type="text/css" href="main.css?refresh{current-dateTime()}" />
    <script type="text/javascript" src="js/Javascript.js">&#160;</script>

    
  </head>

  <body>
    <table class="gridtable">
      <tr>
        <th>Create</th><th>Remove</th><th>Update</th><th>Move</th><th>Renew <br/> (Move and update)</th>
      </tr>
      <tr>
        <td>{ (
              count(collection(concat('http://marklogic.com/semantics/features/new/', $graph2Name)))
              , 
              if(collection('addition')) then () else  
              (:
              let $xml := 
              <delta rdf:about="http://changeInformation">
                 <baseVersion>{$graph1Name}</baseVersion>
                 <updatedVersion>{$graph2Name}</updatedVersion>
                 <changes>
                 {           
                for $eachNew at $pos in collection(concat('http://marklogic.com/semantics/features/new/', $graph2Name))
                return
              
                 <change rdf:about="{fn:concat('http://change/addition/',$pos)}">
                  <Changetype>addition</Changetype>                  
                  <SOCInUpdated rdf:resource="{$eachNew/allFeatures/@res}"/>
                  { 
                  <addedTriples>
                  {
                  for $feature at $tripleCount in $eachNew/allFeatures/feature
                  return
                    <rdf:Statement rdf:about="{fn:concat('http://change/addition/',$pos,'/addedTriple/',$tripleCount)}">
                      <rdf:subject rdf:resource="{$eachNew/allFeatures/@res}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{data($feature/@value)}</rdf:object>
                    </rdf:Statement>
                 }
                 </addedTriples>
                 }
                 </change>
                 }
                 </changes>
                 </delta>
                :)
                let $xml := 
                              <delta rdf:about="http://changeInformation">
                                 <baseVersion>{data($graph1Name)}</baseVersion>
                                 <updatedVersion>{data($graph2Name)}</updatedVersion>
                                 <changes>
                                 {           
                                for $eachNew at $pos in collection(concat('http://marklogic.com/semantics/features/new/', $graph2Name))
                                return                              
                                 <change rdf:about="{fn:concat('http://change/addition/',$pos)}">
                                  <Changetype>addition</Changetype>                  
                                  <SOCInUpdated rdf:resource="{$eachNew/allFeatures/@res}"/>
                                  { 
                                  <addedTriples>
                                  {
                                  
                                  let $exactValueOfPredicateQuery := concat(
                                  "
                                  select ?p ?o
                                  where
                                  {
                                    graph <http://marklogic.com/semantics/", $graph2Name ,">
                                    {<",data($eachNew/allFeatures/@res),"> ?p ?o }
                                  }
                                  "
                                  )                  
                                  for $eachTriple at $tripleCount in json:transform-from-json(sem:sparql($exactValueOfPredicateQuery))
                                  let $predicate := data($eachTriple/*:p)
                                  let $object := data($eachTriple/*:o)
                                  return
                                    <rdf:Statement rdf:about="{fn:concat('http://change/addition/',$pos,'/addedTriple/',$tripleCount)}">
                                      <rdf:subject rdf:resource="{$eachNew/allFeatures/@res}"/>
                                      <rdf:predicate rdf:resource="{$predicate}"/>
                                      <rdf:object>{$object}</rdf:object>
                                    </rdf:Statement>
                                 }
                                 </addedTriples>
                                 }
                                 </change>
                                 }
                                 </changes>
                                 </delta>

              let $xmlToRDF := sem:rdf-parse($xml, "rdfxml")

              let $_ := sem:rdf-insert($xmlToRDF, ('override-graph=http://marklogic.com/semantics/changes/addition'), (), 'addition')  return ()
               )}</td>
        <td>{
             (
             count(collection(concat('http://marklogic.com/semantics/features/delete/', $graph1Name)))
             ,
             if(collection('removal')) then () else
             (:
             let $xml := 
             <delta rdf:about="http://changeInformation">
               <baseVersion>3.2 person snapshot</baseVersion>
               <updatedVersion>3.3 person snapshot</updatedVersion>
               <changes>
             {    
             for $eachNew at $pos in collection(concat('http://marklogic.com/semantics/features/delete/', $graph1Name))
              
              return
              
                 <change rdf:about="{fn:concat('http://change/removal/',$pos)}">
                  <Changetype>removal</Changetype>                  
                  <SOCInBase rdf:resource="{$eachNew/allFeatures/@res}"/>  
                  {(:                
                  <removedTriples>
                  {
                  for $feature at $tripleCount in $eachNew/allFeatures/feature
                  return
                    <rdf:Statement rdf:about="{fn:concat('http://change/removal/',$pos,'/removedTriple/',$tripleCount)}">
                      <rdf:subject rdf:resource="{$eachNew/allFeatures/@res}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{data($feature/@value)}</rdf:object>
                    </rdf:Statement>
                 }
                 </removedTriples>
                 :)}
                 </change>
             }
                </changes>
                </delta>
              :)
                let $xml := 
                              <delta rdf:about="http://changeInformation">
                                 <baseVersion>{data($graph1Name)}</baseVersion>
                                 <updatedVersion>{data($graph2Name)}</updatedVersion>
                                 <changes>
                                 {           
                                for $eachNew at $pos in collection(concat('http://marklogic.com/semantics/features/delete/', $graph1Name))
                                return                              
                                 <change rdf:about="{fn:concat('http://change/removal/',$pos)}">
                                  <Changetype>removal</Changetype>                  
                                  <SOCInBase rdf:resource="{$eachNew/allFeatures/@res}"/>  
                                  { 
                                  <removedTriples>
                                  {
                                  
                                  let $exactValueOfPredicateQuery := concat(
                                  "
                                  select ?p ?o
                                  where
                                  {
                                    graph <http://marklogic.com/semantics/", $graph1Name ,">
                                    {<",data($eachNew/allFeatures/@res),"> ?p ?o }
                                  }
                                  "
                                  )                  
                                  for $eachTriple at $tripleCount in json:transform-from-json(sem:sparql($exactValueOfPredicateQuery))
                                  let $predicate := data($eachTriple/*:p)
                                  let $object := data($eachTriple/*:o)
                                  return
                                    <rdf:Statement rdf:about="{fn:concat('http://change/removal/',$pos,'/removedTriple/',$tripleCount)}">
                                      <rdf:subject rdf:resource="{$eachNew/allFeatures/@res}"/>
                                      <rdf:predicate rdf:resource="{$predicate}"/>
                                      <rdf:object>{$object}</rdf:object>
                                    </rdf:Statement>
                                 }
                                 </removedTriples>
                                 }
                                 </change>
                                 }
                                 </changes>
                                 </delta>
                 let $xmlToRDF := sem:rdf-parse($xml, "rdfxml")
                 let $_ := sem:rdf-insert($xmlToRDF, ('override-graph=http://marklogic.com/semantics/changes/removal'), (), 'removal')  return () 
             )
             }</td>
        <td>{(
              count(collection(concat('http://marklogic.com/semantics/features/update/', $graph1Name, '-', $graph2Name)))
              ,
              if(collection('update')) then () else
              let $xml := 
              <delta rdf:about="http://changeInformation">
                 <baseVersion>{data($graph1Name)}</baseVersion>
                 <updatedVersion>{data($graph2Name)}</updatedVersion>
                 <changes>
                 {
              for $eachNew at $pos in collection(concat('http://marklogic.com/semantics/features/update/', $graph1Name, '-', $graph2Name))
              return
                  <change rdf:about="{fn:concat('http://change/update/',$pos)}">
                    <Changetype>update</Changetype>                    
                    <SOCInBase rdf:resource="{$eachNew/update/@res}"/>                    
                    <SOCInUpdated rdf:resource="{$eachNew/update/@res}"/>  
                                      
                    <removedTriples>
                    {
                    for $feature at $tripleCount in $eachNew/update/deleted/feature
                    return
                      <rdf:Statement rdf:about="{fn:concat('http://change/update/',$pos,'/removedTriples/',$tripleCount)}">
                        <rdf:subject rdf:resource="{$eachNew/update/@res}"/>
                        <rdf:predicate rdf:resource="{$feature/@name}"/>
                        <rdf:object>{data($feature/@value)}</rdf:object>
                      </rdf:Statement>
                   }
                   </removedTriples>                   
                   <addedTriples>
                    {
                    for $feature at $tripleCount in $eachNew/update/new/feature
                    return
                      <rdf:Statement rdf:about="{fn:concat('http://change/update/',$pos,'/addedTriples/',$tripleCount)}">
                        <rdf:subject rdf:resource="{$eachNew/update/@res}"/>
                        <rdf:predicate rdf:resource="{$feature/@name}"/>
                        <rdf:object>{data($feature/@value)}</rdf:object>
                      </rdf:Statement>
                   }
                   </addedTriples>
                   
                   </change>
                   }
                   </changes>
                   </delta>
                   let $xmlToRDF := sem:rdf-parse($xml, "rdfxml")
                   let $_ := sem:rdf-insert($xmlToRDF, ('override-graph=http://marklogic.com/semantics/changes/update'), (), 'update')  return ()

              )}</td>
        <td>{
            (
              count(collection(concat('http://marklogic.com/semantics/features/move/', $graph1Name, '-', $graph2Name)))
              ,
              if(collection('move')) then () else
              let $xml :=
              <delta rdf:about="http://changeInformation">
                 <baseVersion>{data($graph1Name)}</baseVersion>
                 <updatedVersion>{data($graph2Name)}</updatedVersion>
                 <changes>
              {
              for $eachNew at $pos in collection(concat('http://marklogic.com/semantics/features/move/', $graph1Name, '-', $graph2Name))
                return
                 <change rdf:about="{fn:concat('http://change/move/',$pos)}">
                  <Changetype>move</Changetype>    
                  <SOCInBase rdf:resource="{$eachNew/move/old/data()}"/>
                  <SOCInUpdated rdf:resource="{$eachNew/move/new/data()}"/>  
                 
                  <removedTriples>
                  {
                  for $feature at $tripleCount in $eachNew/move/update/deleted/feature
                  return
                    <rdf:Statement rdf:about="{fn:concat('http://change/move/',$pos,'/removedTriples/',$tripleCount)}">
                      <rdf:subject rdf:resource="{$eachNew/move/old/data()}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{data($feature/@value)}</rdf:object>
                    </rdf:Statement>
                 }
                 </removedTriples>                 
                 <addedTriples>
                  {
                  for $feature at $tripleCount in $eachNew/move/update/new/feature
                  return
                    <rdf:Statement rdf:about="{fn:concat('http://change/move/',$pos,'/addedTriples/',$tripleCount)}">
                      <rdf:subject rdf:resource="{$eachNew/move/new/data()}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{data($feature/@value)}</rdf:object>
                    </rdf:Statement>
                 }
                 </addedTriples>
                 
                 </change>
                 }                 
                </changes>
                </delta>

                let $xmlToRDF := sem:rdf-parse($xml, "rdfxml")
                let $_ := xdmp:log($xmlToRDF)
                let $_ := sem:rdf-insert($xmlToRDF, ('override-graph=http://marklogic.com/semantics/changes/move'), (), 'move')  return ()
            )
            }</td>
        <td>{
            (
             count(collection(concat('http://marklogic.com/semantics/features/moveAndUpdated/',$graph1Name,'-', $graph2Name)))
             ,           
            if(collection('renew')) then () else
            let $xml :=  
            <delta rdf:about="http://changeInformation">
                 <baseVersion>{data($graph1Name)}</baseVersion>
                 <updatedVersion>{data($graph2Name)}</updatedVersion>
                 <changes>
              {  
            for $eachNew at $pos in collection(concat('http://marklogic.com/semantics/features/moveAndUpdated/',$graph1Name,'-', $graph2Name))
            return
              <change rdf:about="{fn:concat('http://change/renew/',$pos)}">
                <Changetype>Renew</Changetype> 
                <SOCInBase rdf:resource="{$eachNew/moveAndUpdate/old/data()}"/>
                <SOCInUpdated rdf:resource="{$eachNew/moveAndUpdate/new/data()}"/>  
                
                <removedTriples>
                {
                for $feature at $tripleCount in $eachNew/moveAndUpdate/update/deleted/feature
                return
                  <rdf:Statement rdf:about="{fn:concat('http://change/renew/',$pos,'/removedTriples/',$tripleCount)}">
                    <rdf:subject rdf:resource="{$eachNew/moveAndUpdate/old/data()}"/>
                    <rdf:predicate rdf:resource="{$feature/@name}"/>
                    <rdf:object>{data($feature/@value)}</rdf:object>
                  </rdf:Statement>
               }
               </removedTriples>
               <addedTriplesInRenew>
                {
                for $feature at $tripleCount in $eachNew/moveAndUpdate/update/new/feature
                return
                  <rdf:Statement rdf:about="{fn:concat('http://change/renew/',$pos,'/addedTriples/',$tripleCount)}">
                    <rdf:subject rdf:resource="{$eachNew/moveAndUpdate/new/data()}"/>
                    <rdf:predicate rdf:resource="{$feature/@name}"/>
                    <rdf:object>{data($feature/@value)}</rdf:object>
                  </rdf:Statement>
               }
               </addedTriplesInRenew>
               
               </change>
               }
               </changes>
               </delta>
               let $xmlToRDF := sem:rdf-parse($xml, "rdfxml")
               let $_ := sem:rdf-insert($xmlToRDF, ('override-graph=http://marklogic.com/semantics/changes/renew'), (), 'renew')  return ()

            )}</td>
      </tr>      
    </table>
  </body>
</html>