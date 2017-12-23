
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
              count(collection('http://marklogic.com/semantics/features/new/3.3-person.nt'))
              , 
              if(collection('addition')) then () else             
              for $eachNew at $pos in collection('http://marklogic.com/semantics/features/new/3.3-person.nt')
              let $_ := xdmp:document-insert($eachNew/allFeatures/@res, 

                 <change rdf:about="{fn:concat('http://change/addition/',$pos)}">
                  <ChangeReason>addition</ChangeReason>                  
                  <subjectOfChange rdf:resource="{$eachNew/allFeatures/@res}"/>
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
                 </change>, (), 'addition' ) return ()
              
                   
               )}</td>
        <td>{
             (
             count(collection('http://marklogic.com/semantics/features/delete/3.2-person.nt'))
             ,
             if(collection('removal')) then () else
             for $eachNew at $pos in collection('http://marklogic.com/semantics/features/delete/3.2-person.nt')
              
              let $_ := xdmp:document-insert($eachNew/allFeatures/@res, 

                 <change rdf:about="{fn:concat('http://change/removal/',$pos)}">
                  <ChangeReason>removal</ChangeReason>                  
                  <subjectOfChange rdf:resource="{$eachNew/allFeatures/@res}"/>                  
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
                 </change>, (), 'removal' ) return ()
             )
             }</td>
        <td>{(
              count(collection('http://marklogic.com/semantics/features/update/3.2-person.nt-3.3-person.nt'))
              ,
              if(collection('update')) then () else
              for $eachNew at $pos in collection('http://marklogic.com/semantics/features/update/3.2-person.nt-3.3-person.nt')
              let $_ := xdmp:document-insert($eachNew/update/@res, 

                  <change rdf:about="{fn:concat('http://change/update/',$pos)}">
                    <ChangeReason>update</ChangeReason>                    
                    <subjectOfChange rdf:resource="{$eachNew/update/@res}"/>                    
                    <removedTriplesInUpdate>
                    {
                    for $feature at $tripleCount in $eachNew/update/deleted/feature
                    return
                      <rdf:Statement rdf:about="{fn:concat('http://change/update/',$pos,'/removedTriples/',$tripleCount)}">
                        <rdf:subject rdf:resource="{$eachNew/update/@res}"/>
                        <rdf:predicate rdf:resource="{$feature/@name}"/>
                        <rdf:object>{data($feature/@value)}</rdf:object>
                      </rdf:Statement>
                   }
                   </removedTriplesInUpdate>                   
                   <addedTriplesInUpdate>
                    {
                    for $feature at $tripleCount in $eachNew/update/new/feature
                    return
                      <rdf:Statement rdf:about="{fn:concat('http://change/update/',$pos,'/addedTriples/',$tripleCount)}">
                        <rdf:subject rdf:resource="{$eachNew/update/@res}"/>
                        <rdf:predicate rdf:resource="{$feature/@name}"/>
                        <rdf:object>{data($feature/@value)}</rdf:object>
                      </rdf:Statement>
                   }
                   </addedTriplesInUpdate>
                   </change>, (), 'update' ) return ()

              )}</td>
        <td>{
            (
              count(collection('http://marklogic.com/semantics/features/move/3.2-person.nt-3.3-person.nt'))
              ,
              if(collection('move')) then () else
              for $eachNew at $pos in collection('http://marklogic.com/semantics/features/move/3.2-person.nt-3.3-person.nt')
              let $_ := xdmp:document-insert($eachNew/move/new/data(),
                 <change rdf:about="{fn:concat('http://change/move/',$pos)}">
                  <ChangeReason>move</ChangeReason>                  
                  <subjectOfChange rdf:resource="{$eachNew/move/old/data()}"/>
                  <subjectOfChange rdf:resource="{$eachNew/move/new/data()}"/>
                  <removedTriplesInMove>
                  {
                  for $feature at $tripleCount in $eachNew/move/update/deleted/feature
                  return
                    <rdf:Statement rdf:about="{fn:concat('http://change/move/',$pos,'/removedTriples/',$tripleCount)}">
                      <rdf:subject rdf:resource="{$eachNew/move/old/data()}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{data($feature/@value)}</rdf:object>
                    </rdf:Statement>
                 }
                 </removedTriplesInMove>                 
                 <addedTriplesInMove>
                  {
                  for $feature at $tripleCount in $eachNew/move/update/new/feature
                  return
                    <rdf:Statement rdf:about="{fn:concat('http://change/move/',$pos,'/addedTriples/',$tripleCount)}">
                      <rdf:subject rdf:resource="{$eachNew/move/new/data()}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{data($feature/@value)}</rdf:object>
                    </rdf:Statement>
                 }
                 </addedTriplesInMove>
                 </change>, (), 'move') return ()
            )
            }</td>
        <td>{
            (
             count(collection('http://marklogic.com/semantics/features/moveAndUpdated/3.2-person.nt-3.3-person.nt'))
             ,           
            if(collection('renew')) then () else
            for $eachNew at $pos in collection('http://marklogic.com/semantics/features/moveAndUpdated/3.2-person.nt-3.3-person.nt')
            let $_ :=  xdmp:document-insert($eachNew/moveAndUpdate/new/data(),
              <change rdf:about="{fn:concat('http://change/renew/',$pos)}">
                <ChangeReason>Renew</ChangeReason>                
                <subjectOfChange rdf:resource="{$eachNew/moveAndUpdate/old/data()}"/>
                <subjectOfChange rdf:resource="{$eachNew/moveAndUpdate/new/data()}"/>
                <removedTriplesInRenew>
                {
                for $feature at $tripleCount in $eachNew/moveAndUpdate/update/deleted/feature
                return
                  <rdf:Statement rdf:about="{fn:concat('http://change/renew/',$pos,'/removedTriples/',$tripleCount)}">
                    <rdf:subject rdf:resource="{$eachNew/moveAndUpdate/old/data()}"/>
                    <rdf:predicate rdf:resource="{$feature/@name}"/>
                    <rdf:object>{data($feature/@value)}</rdf:object>
                  </rdf:Statement>
               }
               </removedTriplesInRenew>
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
               </change>, (), 'renew') return ()
            )}</td>
      </tr>      
    </table>
  </body>
</html>
