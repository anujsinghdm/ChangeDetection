
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
              for $eachNew in collection('http://marklogic.com/semantics/features/new/3.3-person.nt')
              let $_ := xdmp:document-insert($eachNew/allFeatures/@res, 

                 <change>
                  <ChangeReason rdf:resource="{$eachNew/allFeatures/@res}">addition</ChangeReason>                  
                  <subjectOfChange rdf:resource="{$eachNew/allFeatures/@res}"/>
                  <addedTriples>
                  {
                  for $feature in $eachNew/allFeatures/feature
                  return
                    <rdf:Statement>
                      <rdf:subject rdf:resource="{$eachNew/allFeatures/@res}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{$feature/@value}</rdf:object>
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
             for $eachNew in collection('http://marklogic.com/semantics/features/delete/3.2-person.nt')
              let $_ := xdmp:log($eachNew/allFeatures/@res)
              let $_ := xdmp:document-insert($eachNew/allFeatures/@res, 

                 <change>
                  <ChangeReason rdf:resource="{$eachNew/allFeatures/@res}">removal</ChangeReason>                  
                  <subjectOfChange rdf:resource="{$eachNew/allFeatures/@res}"/>                  
                  <removedTriples>
                  {
                  for $feature in $eachNew/allFeatures/feature
                  return
                    <rdf:Statement>
                      <rdf:subject rdf:resource="{$eachNew/allFeatures/@res}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{$feature/@value}</rdf:object>
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
              for $eachNew in collection('http://marklogic.com/semantics/features/update/3.2-person.nt-3.3-person.nt')
              let $_ := xdmp:document-insert($eachNew/update/@res, 

                  <change>
                    <ChangeReason rdf:resource="{$eachNew/update/@res}">update</ChangeReason>                    
                    <subjectOfChange rdf:resource="{$eachNew/update/@res}"/>                    
                    <removedTriples>
                    {
                    for $feature in $eachNew/update/deleted/feature
                    return
                      <rdf:Statement>
                        <rdf:subject rdf:resource="{$eachNew/update/@res}"/>
                        <rdf:predicate rdf:resource="{$feature/@name}"/>
                        <rdf:object>{$feature/@value}</rdf:object>
                      </rdf:Statement>
                   }
                   </removedTriples>                   
                   <addedTriples>
                    {
                    for $feature in $eachNew/update/new/feature
                    return
                      <rdf:Statement>
                        <rdf:subject rdf:resource="{$eachNew/update/@res}"/>
                        <rdf:predicate rdf:resource="{$feature/@name}"/>
                        <rdf:object>{$feature/@value}</rdf:object>
                      </rdf:Statement>
                   }
                   </addedTriples>
                   </change>, (), 'update' ) return ()

              )}</td>
        <td>{
            (
              count(collection('http://marklogic.com/semantics/features/move/3.2-person.nt-3.3-person.nt'))
              ,
              if(collection('move')) then () else
              for $eachNew in collection('http://marklogic.com/semantics/features/move/3.2-person.nt-3.3-person.nt')
              let $_ := xdmp:document-insert($eachNew/move/new/data(),
                 <change>
                  <ChangeReason rdf:resource="{$eachNew/move/old/data()}">Move:previous</ChangeReason>
                  <ChangeReason rdf:resource="{$eachNew/move/new/data()}">Move:current</ChangeReason>
                  <subjectOfChange rdf:resource="{$eachNew/move/old/data()}"/>
                  <subjectOfChange rdf:resource="{$eachNew/move/new/data()}"/>
                  <removedTriples>
                  {
                  for $feature in $eachNew/move/update/deleted/feature
                  return
                    <rdf:Statement>
                      <rdf:subject rdf:resource="{$eachNew/move/old/data()}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{$feature/@value}</rdf:object>
                    </rdf:Statement>
                 }
                 </removedTriples>
                 ,
                 <addedTriples>
                  {
                  for $feature in $eachNew/move/update/new/feature
                  return
                    <rdf:Statement>
                      <rdf:subject rdf:resource="{$eachNew/move/new/data()}"/>
                      <rdf:predicate rdf:resource="{$feature/@name}"/>
                      <rdf:object>{$feature/@value}</rdf:object>
                    </rdf:Statement>
                 }
                 </addedTriples>
                 </change>, (), 'move') return ()
            )
            }</td>
        <td>{
            (
             count(collection('http://marklogic.com/semantics/features/moveAndUpdated/3.2-person.nt-3.3-person.nt'))
             ,           
            if(collection('renew')) then () else
            for $eachNew in collection('http://marklogic.com/semantics/features/moveAndUpdated/3.2-person.nt-3.3-person.nt')
            let $_ :=  xdmp:document-insert($eachNew/moveAndUpdate/new/data(),
              <change>
                <ChangeReason rdf:resource="{$eachNew/moveAndUpdate/old/data()}">Renew:previous</ChangeReason>
                <ChangeReason rdf:resource="{$eachNew/moveAndUpdate/new/data()}">Renew:current</ChangeReason>
                <subjectOfChange rdf:resource="{$eachNew/moveAndUpdate/old/data()}"/>
                <subjectOfChange rdf:resource="{$eachNew/moveAndUpdate/new/data()}"/>
                <removedTriples>
                {
                for $feature in $eachNew/moveAndUpdate/update/deleted/feature
                return
                  <rdf:Statement>
                    <rdf:subject rdf:resource="{$eachNew/moveAndUpdate/old/data()}"/>
                    <rdf:predicate rdf:resource="{$feature/@name}"/>
                    <rdf:object>{$feature/@value}</rdf:object>
                  </rdf:Statement>
               }
               </removedTriples>
               <addedTriples>
                {
                for $feature in $eachNew/moveAndUpdate/update/new/feature
                return
                  <rdf:Statement>
                    <rdf:subject rdf:resource="{$eachNew/moveAndUpdate/new/data()}"/>
                    <rdf:predicate rdf:resource="{$feature/@name}"/>
                    <rdf:object>{$feature/@value}</rdf:object>
                  </rdf:Statement>
               }
               </addedTriples>
               </change>, (), 'renew') return ()
            )}</td>
      </tr>      
    </table>
  </body>
</html>
