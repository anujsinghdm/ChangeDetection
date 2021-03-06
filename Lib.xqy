module namespace LIB =  "http://www.adapt.ie/kul-lib";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace json="http://marklogic.com/xdmp/json"  at "/MarkLogic/json/json.xqy";

declare function get-potential-new-triples($base-graph , $updated-graph)  as item()*
{
  
  let $query :=  concat(
                 'select distinct ?p
                  where
                    { 
                      graph <', $updated-graph ,'>
                      {
                        ?s ?p ?o
                      }
                    }
                  ')

  for $eachSub at $pos in json:transform-from-json(sem:sparql($query))                
  let $_ := xdmp:log($pos)
  let $subToSearch := if(starts-with(data($eachSub),'http://')) then concat('<', data($eachSub), '>') else data($eachSub)
  let $searchQuery :=
                        concat(
                        'select *
                         where
                          { 
                            graph <', $updated-graph ,'>
                            { ?S ', $subToSearch,' ?O}
                            BIND (',$subToSearch,' as $p)
                            FILTER NOT EXISTS
                            {
                             graph <', $base-graph ,'>     
                             {?S ', $subToSearch,'  ?O}      
                            }                            
                          }')
  return
    sem:sparql($searchQuery)
              


  (:
  let $IdentifyNewQuery := fn:concat('
                                              SELECT *
                                                WHERE
                                                {    
                                                  GRAPH <',$updated-graph,'>  
                                                  {
                                                      ?S ?P ?O

                                                  }
                                                  FILTER NOT EXISTS
                                                  {
                                                    GRAPH <',$base-graph,'>  
                                                    {
                                                         ?S ?P ?O

                                                    }
                                                  }    
                                                }
                                              '
                                          )
		 return
		    sem:sparql($IdentifyNewQuery)
    :)
};

declare function get-potential-deleted-triples($base-graph , $updated-graph)  as item()*
{

  
  let $query :=  concat(
                 'select distinct ?p
                  where
                    { 
                      graph <', $base-graph ,'>
                      {
                        ?s ?p ?o
                      }
                    }
                  ')

  for $eachSub at $pos in json:transform-from-json(sem:sparql($query))  
  let $_ := xdmp:log($pos)
  let $subToSearch := if(starts-with(data($eachSub),'http://')) then concat('<', data($eachSub), '>') else data($eachSub)
  let $searchQuery :=
                        concat(
                        'select *
                         where
                          { 
                            graph <', $base-graph ,'>
                            { ?S ', $subToSearch,' ?O}
                            BIND (',$subToSearch,' as $p)
                            FILTER NOT EXISTS
                            {
                             graph <', $updated-graph ,'>     
                             {?S ', $subToSearch,'  ?O}      
                            }                            
                          }')
  return
    sem:sparql($searchQuery)
  


          (:
          let $IdentifyDeleteQuery := fn:concat('
                                              SELECT *
                                                WHERE
                                                {    
                                                  GRAPH <',$base-graph,'>  
                                                  {
                                                      ?S ?P ?O

                                                  }
                                                  FILTER NOT EXISTS
                                                  {
                                                    GRAPH <',$updated-graph,'>  
                                                    {
                                                         ?S ?P ?O

                                                    }
                                                  }    
                                                }
                                              '
                                          )
        return           
        	sem:sparql($IdentifyDeleteQuery)
        :)

};



declare function get-resource-features($resourceURI, $state, $graphName)  as item()*
{
let $collection := concat('http://marklogic.com/semantics/features/',$state,'/',$graphName)
let $docURI := fn:concat('/',$state,'/features/', tokenize($resourceURI, 'resource/')[last()])
let $infoboxName := replace($graphName,'person.nt','category')
let $config := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')
let $duplicateFeatureCheck := <root></root>
let $allFeatures :=
    <allFeatures res="{$resourceURI}" state="{$state}">
    {
        
        let $extractfeatureQuery := fn:concat('                         
                                                select *
                        where
                        {
                            GRAPH <http://marklogic.com/semantics/',$graphName,'>  
                          {<',
                              $resourceURI, '> $p $o
                          }
                        }
                                                '
                                          )
        
        let $extractCalledFrom := concat(
                                          '
                                          select *
                                          where
                                          {
                                            GRAPH <http://marklogic.com/semantics/DBpedia/',$infoboxName,'>
                                            {
                                              <',$resourceURI,'> ?P ?calledFrom
                                            }
                                          }
                                          '
                                        )
        return
        (
          let $executeQuery := sem:sparql($extractfeatureQuery)
          let $type := data(json:transform-from-json($executeQuery)/*:p[. = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']/following-sibling::*)
          for $eachType in $type
          let $checkType := json:transform-from-json(sem:sparql(concat('select ?response
                        where
                        {
                          graph <',$graphName,'/ontology>
                          {
                          <',$eachType,'> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#Class>.
                          <',$eachType,'> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2002/07/owl#Thing>      
                          }
                        }')))/*:response
                        
          let $_ := if($checkType/@type) then xdmp:set($collection, ($collection, concat($eachType, '/', $graphName))) else ()
          
          for $eachFeature in json:transform-from-json($executeQuery)[*:p != 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']
          
          let $featureName := tokenize($eachFeature/*:p,'/')[last()]
          let $exactValue := replace(lower-case(xdmp:url-decode($eachFeature/*:o/text())),'http://dbpedia.org/resource/','')
          
          let $value :=   
                          (:
                           if(not(fn:starts-with($exactValue,'http://dbpedia.org')) and matches($exactValue,'[a-zA-Z]') and string-length($exactValue) > 5)
                           then
                            string-join((for $eachToken in tokenize($exactValue, '\s|_|-')[1 to 3]
                            let $allVowels :=  string-join((for $eachVow in ('a','e','i','o','u') return if(matches($eachToken,$eachVow,'i')) then $eachVow else ()),'')
                            return
                              concat($allVowels,lower-case(substring($eachToken,1,1)),spell:double-metaphone($eachToken)[1], lower-case(substring($eachToken,string-length($eachToken),1)))),'')
                           else 
                             if(fn:starts-with($exactValue,'http://dbpedia.org')) then spell:double-metaphone(tokenize($exactValue,'/')[last()])[1]
                             else 
                              $exactValue
                          :)
                           if(not(fn:starts-with($exactValue,'http://dbpedia.org')) and matches($exactValue,'[a-zA-Z]'))
                           then
                             element {lower-case($featureName)}{attribute type {'text'}
                             ,
                             string-join((for $eachToken in tokenize($exactValue, '\s|_|-')[1 to 3]
                             let $allVowels :=  string-join((for $eachVow in ('a','e','i','o','u') return if(matches($eachToken,$eachVow,'i')) then $eachVow else ()),'')
                              return
                                concat($allVowels,lower-case(substring($eachToken,1,1)),spell:double-metaphone($eachToken)[1], lower-case(substring($eachToken,string-length($eachToken),1)))),'')
                             }
                           else 
                             if(fn:starts-with($exactValue,'http://dbpedia.org')) 
                             then
                               element {lower-case($featureName)}{attribute type {'uri'}, $exactValue}
                             else 
                               element {lower-case($featureName)}{attribute type {'numeric'}, $exactValue }


                        
          return
            let $element := $value
            return
              $element
            ,
          for $eachCalledFrom in json:transform-from-json(sem:sparql($extractCalledFrom))          
          let $calledFromName := tokenize($eachCalledFrom/*:P,'/')[last()]
          let $exactValue := replace(lower-case(xdmp:url-decode(data($eachCalledFrom/*:calledFrom))),'http://dbpedia.org/resource/category:','')
          
          return             
               if(not($exactValue = 'Living_people'))
               then                   
                 if(not(matches($exactValue,'[0-9]')))
                 then                   
                   element {lower-case(replace($calledFromName,'\C',''))}{attribute type {'uri'}, $exactValue}
                 else 
                   element {lower-case(replace($calledFromName,'\C',''))}{attribute type {'numeric'}, $exactValue}
               else () 
        )  
          
        }
        </allFeatures>



        return          
           xdmp:document-insert($docURI, $allFeatures, (), $collection)

};



declare function identify-update($deletedRes, $newRes, $graph1Name, $graph2Name)  as item()*
{
  let $subjectURI := data($deletedRes)
  let $deletedRes := get-exact-features($graph1Name, $subjectURI)
  let $newRes := get-exact-features($graph2Name, $newRes)

	let $diff := 
                (
                <deleted>
                {
                for $eachFeatureDel in $deletedRes
                let $name := $eachFeatureDel/@name
                let $value := $eachFeatureDel/@value
                return 
                  if($newRes[@name = $name and @value = $value])
                  then ()
                  else $eachFeatureDel
                }
                </deleted>
                ,
                <new>
                {
                for $eachFeatureNew in $newRes
                let $name := $eachFeatureNew/@name
                let $value := $eachFeatureNew/@value
                return 
                  if($deletedRes[@name = $name and @value = $value])
                  then ()
                  else $eachFeatureNew
                }
                </new>
                )
    let $doc := <update res="{$subjectURI}">{$diff}</update>
    return
      $doc
};

declare function get-exact-features($graphName, $resourceURI)
{
  let $extractfeatureQuery := fn:concat('                         
                                select *
                                where
                                {
                                    GRAPH <http://marklogic.com/semantics/',$graphName,'>  
                                  {<',
                                      $resourceURI, '> $p $o
                                  }
                                }
                                                        '
                                                  )
                for $eachFeature in json:transform-from-json(sem:sparql($extractfeatureQuery))
                return           
                  <feature name="{$eachFeature/*:p}" value="{$eachFeature/*:o}"/>
};

declare function identify-move($deletedRes, $totalFeature, $graph1Name , $graph2Name, $lookupCollection)  as item()*
{
  let $allFeatures := 
            for $eachFeature in $deletedRes/../*
            let $name := local-name($eachFeature)
            let $value := data($eachFeature)
            let $type := data($eachFeature/@type)
            let $search := cts:search(collection($lookupCollection)/allFeatures/*[(local-name() = $name) and (@type = $type)], $value)
                                                                              
            let $base-uris := 
                              <search name="{$name}" value="{$value}">
                              {
                              for $eachSearch in $search
                              let $base-uri := <base-uri>{$eachSearch/base-uri()}</base-uri>
                              return
                                (
                                $base-uri
                               (: ,
                                if(cts:contains($distinctUris/base-uri, cts:word-query($base-uri/text())))
                                then ()
                                else 
                                  xdmp:set($distinctUris, <root>{($distinctUris/*, $base-uri)}</root>) :)
                                )
                              }
                              </search>
                              
            return
              $base-uris
  
  let $totalFeatureFound := count($allFeatures[base-uri])
  
  let $percetageFeaturesFoound := ($totalFeatureFound div  $totalFeature ) * 100  
  
  return
   
    if($percetageFeaturesFoound >= 50)
        then   
          let $_ := xdmp:eval("xdmp:collection-delete('lookUp')", (), <options xmlns="xdmp:eval">
                                                              <isolation>different-transaction</isolation>
                                                              <prevent-deadlocks>false</prevent-deadlocks>
                                                            </options>)
                                                         
          let $queryInsert := 
                              "                               
                               declare namespace my='http://insert/';
                               declare variable $allFeatures external;  
                              
                               for $each at $pos in $allFeatures/search
                               let $uriAndCollection := data($each/@name)
                               return
                                 xdmp:document-insert(concat($uriAndCollection,$pos), $each, (), 'lookUp')"
          
          
          let $executeQuery := xdmp:eval($queryInsert, (xs:QName("allFeatures"), <root>{$allFeatures},</root>))
          let $querySearch :=
                              "   
                              import module namespace LIB = 'http://www.adapt.ie/kul-lib' at 'Lib.xqy';                           
                              declare variable $allFeatures external;
                              declare variable $totalFeature external;
                              declare variable $deletedRes external;
                              declare variable $graph1Name external;
                              declare variable $graph2Name external;
                              
                              let $unfilteredResult :=
                                for $eachDistinctURI in distinct-values($allFeatures//base-uri)
                                                                    
                                  let $searchThisURIInAllFeatureResult := xdmp:estimate(cts:search(collection('lookUp')//base-uri[. = $eachDistinctURI], $eachDistinctURI))
                                  
                                  let $countSearchResult := $searchThisURIInAllFeatureResult
                                  
                                  let $newPercentage := ($countSearchResult div  $totalFeature ) * 100

                                return                                   
                                  if($newPercentage >= 40 )
                                  then                
                                    <move similarFeaturesPercentage='{$newPercentage}'>
                                    <old featureURI='{$deletedRes/base-uri()}'>{data($deletedRes)}</old>
                                    <new featureURI='{$eachDistinctURI}'>{data(doc($eachDistinctURI)/allFeatures/@res)}</new>                      
                                    <update>
                                <deleted>{LIB:get-exact-features($graph1Name, data($deletedRes))}</deleted>                        
                                <new>{LIB:get-exact-features($graph2Name, data(doc($eachDistinctURI)/allFeatures/@res))}</new>                       
                                    </update>                      
                                   </move>                  
                                  else () 
                               return
                                  if(count($unfilteredResult) = 1)
                                  then                                   
                                   $unfilteredResult                                   
                                  else 
                                    let $maxPercentage := max($unfilteredResult/@similarFeaturesPercentage)
                                    let $countOfMaxPercentageMove := count($unfilteredResult[@similarFeaturesPercentage = $maxPercentage])
                                    return 
                                      if($countOfMaxPercentageMove = 1)
                                      then                                         
                                        $unfilteredResult[@similarFeaturesPercentage = $maxPercentage]                                        
                                      else ()
                                         (:
                                         let $tieBreaker :=
                                           for $each in $unfilteredResult[@similarFeaturesPercentage = $maxPercentage]
                                           let $newFeaturesCount := count(doc($each/new/@featureURI)/allFeatures/*)                                           
                                           return
                                             if($totalFeature = $newFeaturesCount) then $each else ()
                                         return
                                            if(count($tieBreaker) = 1) then $tieBreaker else ()
                                          :)
                              " 
                             return                             
                               xdmp:eval($querySearch,
                                         (
                                         xs:QName("allFeatures"), <root>{$allFeatures}</root>
                                         ,
                                         xs:QName("totalFeature"), $totalFeature
                                         ,
                                         xs:QName("deletedRes"), $deletedRes
                                         ,
                                         xs:QName("graph1Name"), $graph1Name
                                         ,
                                         xs:QName("graph2Name"), $graph2Name
                                         )
                                         ,
                                         <options xmlns="xdmp:eval">
                                           <isolation>different-transaction</isolation>
                                           <prevent-deadlocks>false</prevent-deadlocks>
                                         </options>
                                         )
                              
          
            
            
        else ()

};

declare function identify-move-and-update($graph1, $graph2)  as item()*
{
  let $moveCollectionURI := fn:concat('http://marklogic.com/semantics/features/move/',$graph1,'-',$graph2)
  let $moveAndUpdatedCollectionURI := fn:concat('http://marklogic.com/semantics/features/moveAndUpdated/',$graph1,'-',$graph2)

  for $eachMoveAndUpdate in collection($moveCollectionURI)/move
    let $oldURI := $eachMoveAndUpdate/old/@featureURI
    let $oldDoc := doc($oldURI)
    let $totalFeature := count($oldDoc/*/*)
    let $newURI := $eachMoveAndUpdate/new/@featureURI
    let $newDoc := doc($newURI)
    let $moveAndUpdatedURI := concat('/moveAndUpdated/features/', tokenize($newURI,'/')[last()])
    let $similarFeaturePercentage := data($eachMoveAndUpdate/@similarFeaturesPercentage)
    let $identify-update := LIB:identify-update(doc($oldURI)/allFeatures/@res, doc($newURI)/allFeatures/@res, $graph1, $graph2)

    let $doc := <moveAndUpdate similarFeaturesPercentage="{$eachMoveAndUpdate/@similarFeaturesPercentage}">
                  {$eachMoveAndUpdate/*}
                </moveAndUpdate>
    return
      if($identify-update//*:feature)
      then
      (  
        xdmp:document-delete($oldURI)
        ,
        xdmp:document-delete($newURI)
        ,
        xdmp:document-delete($eachMoveAndUpdate/base-uri())
        ,
        xdmp:document-insert($moveAndUpdatedURI, $doc, (), $moveAndUpdatedCollectionURI)  
        )
      else
      (
        xdmp:document-delete($oldURI)
        ,
        xdmp:document-delete($newURI)
      ) 
};


declare function tie-breaker($unfilteredResults)  as item()*
{
 let $resulWithDistance :=
      <result>
      {
        for $eachUnfiltered in $unfilteredResults/move
        let $result :=  <move oldFeatureURI="{$eachUnfiltered/old/@featureURI}" newFeatureURI="{$eachUnfiltered/new/@featureURI}">
                {
                  let $oldDoc := doc($eachUnfiltered/old/@featureURI)
                  let $newDoc := doc($eachUnfiltered/new/@featureURI)
                  let $allFeatures :=
                    let $equalityTest := 
                      for $eachFeature in $oldDoc/allFeatures/feature
                      let $name := data($eachFeature/@name)
                      return
                        if(count($newDoc//feature[@name = $name]) = 1)
                        then
                           <yes/>
                        else ()
                      return
                        if(count($equalityTest) = count($oldDoc/allFeatures/feature))
                        then
                          for $eachFeatureInOld in $oldDoc/allFeatures/feature
                          let $name := data($eachFeatureInOld/@name)
                          let $value := data($eachFeatureInOld/@value)                            
                          let $value := if(matches(string($value), '^http://')) then tokenize(fn:string($value),'/')[last()] else $value
                          let $newValue := $newDoc//feature[@name = $name]/@value
                          let $newValue := if(matches(string($newValue), '^http://')) then tokenize(fn:string($newValue),'/')[last()] else $newValue
                          return  
                            if(not(matches($name,'#type')) and matches($value,'[a-zA-Z]') and string-length($value) < 50 and string-length($newValue) < 50)
                            then
                                smartFeatureMatch($value, $newValue, $name)
                            else ()  
                         else ()
                      
                  let $allFeaturesWithTotalDistance := sum($allFeatures)                  
                  return
                    if($allFeatures)
                    then
                    (
                      $allFeatures
                      ,
                      <totalDistance>{$allFeaturesWithTotalDistance}</totalDistance>
                      ,
                      <changePercentage>{($allFeaturesWithTotalDistance div sum($allFeatures/@sum)) * 100}</changePercentage>
                    )
                    else ()
                }
                </move>
         return
          $result
      }
      </result>
      
      let $minPercentage := min($resulWithDistance//changePercentage)      
      return 
          if($minPercentage >  10)
          then ()
          else 
            if((count($resulWithDistance/move[changePercentage = $minPercentage]) >  1) )
            then ()
            else 
              $unfilteredResults/move
              [
              old/@featureURI = $resulWithDistance/move[changePercentage = $minPercentage]/@oldFeatureURI
              and 
              new/@featureURI = $resulWithDistance/move[changePercentage = $minPercentage]/@newFeatureURI
              ]
};


declare function smartFeatureMatch($value, $newValue, $name)
{
if(count(tokenize($value, ' ')) = count(tokenize($newValue, ' ')))
then
  <feature name="{$name}" oldVal="{$value}" newVal="{data($newValue)}" sum="{string-length($value) + string-length($newValue)}">
  { 
    if(spell:double-metaphone($value)[1] = spell:double-metaphone($newValue)[1])
    then '0'
    else spell:levenshtein-distance($value,   $newValue)
  }
  </feature>
else 
  if(count(tokenize($value, ' ')) < count(tokenize($newValue, ' ')) and abs(count(tokenize($value, ' ')) - count(tokenize($newValue, ' '))) <= 2)
  then 
  let $matching :=
    <feature val="{$value}">
    {
    for $eachToken at $pos in tokenize($value, ' ')
        let $matchInAlltoken :=
            <token>
            {
            for $allToken in tokenize($newValue, ' ')
            return
              <match token="{$eachToken}" searchString="{$allToken}">
              {
                spell:levenshtein-distance($eachToken,   $allToken)
              }
              </match>
            }
            </token>
        let $minDist := min($matchInAlltoken//match)
        return
           $matchInAlltoken//match[. = $minDist]  
     }
     </feature>
     return
       <feature name="{$name}" oldVal="{$value}" newVal="{data($newValue)}" sum="{string-length($value) + string-length($newValue)}">{sum($matching//match)}</feature>
  else 
     if(abs(count(tokenize($value, ' ')) - count(tokenize($newValue, ' '))) > 2) then ()
     else
     let $matching :=
        <feature val="{$value}">
        {
        for $eachToken at $pos in tokenize($newValue, ' ')
            let $matchInAlltoken :=
                <token>
                {
                for $allToken in tokenize($value, ' ')
                return
                  <match token="{$eachToken}" searchString="{$allToken}">
                  {
                    spell:levenshtein-distance($eachToken,   $allToken)
                  }
                  </match>
                }
                </token>
            let $minDist := min($matchInAlltoken//match)
            return
               $matchInAlltoken//match[. = $minDist]  
         }
         </feature>
         return
           <feature name="{$name}" oldVal="{$value}" newVal="{data($newValue)}" sum="{string-length($value) + string-length($newValue)}">{sum($matching//match)}</feature> 
                                    
};


declare function identifyCriticalProperties($allMatches)
{
let $highConfidenceMove := $allMatches//match[@similarityPercentage >= 80]
let $totalHighConfidenceMove := count($highConfidenceMove)
let $toCalculateCriticalFeature :=
<resource>
  {
for $eachHighConfidenceMove in $highConfidenceMove
let $oldFeatures := doc($eachHighConfidenceMove/@delURI)
let $newFeatures := doc($eachHighConfidenceMove/@newURI)

  for $eachFeatureInOldResource in $oldFeatures//*:allFeatures/*
  let $Featurename := local-name($eachFeatureInOldResource)
  let $type := data($eachFeatureInOldResource/@type)  
  let $sameFeatureFoundInNew := $newFeatures//*:allFeatures/*[local-name() = $Featurename and @type = $type]
  return
    if($sameFeatureFoundInNew)
    then 
      if((($sameFeatureFoundInNew) = ($eachFeatureInOldResource)))
      then <sameValue old="{data($eachFeatureInOldResource)}" new="{data($sameFeatureFoundInNew)}">{fn:concat($Featurename, '/type/', $type)}</sameValue>      
      else <differentValue old="{data($eachFeatureInOldResource)}" new="{data($sameFeatureFoundInNew)}">{fn:concat($Featurename, '/type/', $type)}</differentValue>        
    else ()
  }
  </resource>
return  

for $eachDistinctFeature at $pos in distinct-values($toCalculateCriticalFeature//*/text())
let $countSameFeatureValue := count($toCalculateCriticalFeature//*:sameValue[. = $eachDistinctFeature])
let $countDifferentFeatureValue := count($toCalculateCriticalFeature//*:differentValue[. = $eachDistinctFeature])
let $totalCount := $countSameFeatureValue + $countDifferentFeatureValue
let $percentage := ($countSameFeatureValue div $totalCount) * 100
let $coveragaOfFeature := ($totalCount div $totalHighConfidenceMove) * 100
return
  if($percentage >= 98)
  then
   (
  <feature coverage="{$coveragaOfFeature}" name="{tokenize($eachDistinctFeature,'/')[1]}" type="{tokenize($eachDistinctFeature,'/')[3]}" sameCount="{$countSameFeatureValue }" differentCount="{$countDifferentFeatureValue}" percenntageOfCorrectness="{$percentage}"/>  
  )
  else ()
  };


declare function reviewMatch($move, $criticalFeatures)
{
let $confidenceValue := data($move/@similarFeaturesPercentage)
let $oldDoc := doc($move/old/@featureURI)
let $newDoc := doc($move/new/@featureURI)
return 
  if($confidenceValue >= 80)
  then $move
  else
    let $checkTotalCriticalFeatures := 
      for $eachCriticalFeature in $criticalFeatures/feature
      return 
        if($oldDoc//*[(local-name() = $eachCriticalFeature/@name) and (@type = $eachCriticalFeature/@type)])
        then 'yes'
        else ()
     
    let $checkCriticalFeature :=
      for $eachCriticalFeature in $criticalFeatures/feature
      let $criticalFeatureName := $eachCriticalFeature/@name
      let $oldDocCriticalFeature := $oldDoc//*[(local-name() = $criticalFeatureName)  and (@type = $eachCriticalFeature/@type)]
      let $newDocCriticalFeature := $newDoc//*[(local-name() = $criticalFeatureName) and (@type = $eachCriticalFeature/@type)]
      
      return
        (
        if(($oldDocCriticalFeature) and ($newDocCriticalFeature))
        then
          if(($oldDocCriticalFeature) = ($newDocCriticalFeature))
          then <criticalFeature match="yes" name="{$criticalFeatureName}"/>            
          else ()
        else ()      
        )
    return    
      if((count($checkCriticalFeature) >= (count($checkTotalCriticalFeatures))) and (count($checkCriticalFeature) > 0))
      then $move
      else ()  
};