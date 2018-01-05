module namespace LIB =  "http://www.adapt.ie/kul-lib";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace json="http://marklogic.com/xdmp/json"  at "/MarkLogic/json/json.xqy";

declare function get-potential-new-triples($base-graph , $updated-graph)  as item()*
{
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
};

declare function get-potential-deleted-triples($base-graph , $updated-graph)  as item()*
{
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
          

};

declare function get-resource-features($resourceURI, $state, $graphName)  as item()*
{
		let $collection := concat('http://marklogic.com/semantics/features/',$state,'/',$graphName)
		let $docURI := fn:concat('/',$state,'/features/', tokenize($resourceURI, '/')[last()])
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
        for $eachFeature in json:transform-from-json(sem:sparql($extractfeatureQuery))
        return           
        	<feature name="{$eachFeature/*:p}" value="{$eachFeature/*:o}"/>
        }
        </allFeatures>

        return
          xdmp:document-insert($docURI, $allFeatures, (), $collection)
};


declare function identify-update($deletedRes, $newRes)  as item()*
{
	let $diff := 
                (
                <deleted>
                {
                for $eachFeatureDel in $deletedRes/../feature
                let $name := $eachFeatureDel/@name
                let $value := $eachFeatureDel/@value
                return 
                  if($newRes/../feature[@name = $name and @value = $value])
                  then ()
                  else $eachFeatureDel
                }
                </deleted>
                ,
                <new>
                {
                for $eachFeatureNew in $newRes/../feature
                let $name := $eachFeatureNew/@name
                let $value := $eachFeatureNew/@value
                return 
                  if($deletedRes/../feature[@name = $name and @value = $value])
                  then ()
                  else $eachFeatureNew
                }
                </new>
                )
    let $doc := <update res="{$deletedRes}">{$diff}</update>
    return
      $doc
};


declare function identify-move($deletedRes, $totalFeature)  as item()*
{
  let $allFeatures := 
            for $eachFeature in $deletedRes/../feature[@name != 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']
            let $typeVal := data($eachFeature/../feature[@name = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']/@value)
            let $name := $eachFeature/@name
            let $value := $eachFeature/@value  
            
            let $search := collection('http://marklogic.com/semantics/features/new/3.3-person.nt')//feature[@name = $name][            
              (
               cts:contains(concat('@',@value,'@'), cts:word-query(concat('@',$value,'@')))               
              )
            and 
            (data(../feature[@name = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']/@value) = $typeVal)
            ]                   
            let $base-uris := 
                              <search name="{$name}" value="{$value}">
                              {
                              for $eachSearch in $search
                              return
                                <base-uri>{$eachSearch/base-uri()}</base-uri>
                              }
                              </search>
                              
            return
              $base-uris
              
  
  let $totalFeature := count($deletedRes/../*) - 1 
  let $totalFeatureFound := count($allFeatures[base-uri])
  let $percetageFeaturesFoound := ($totalFeatureFound div  $totalFeature ) * 100
  
  
  let $allFeaturesAgain := if($percetageFeaturesFoound >= 50) then () else
                      for $eachFeature in $deletedRes/../feature[@name != 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']
                      let $typeVal := data($eachFeature/../feature[@name = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']/@value)
                      let $name := $eachFeature/@name
                      let $value := $eachFeature/@value  

                      let $search := 
                                     collection('http://marklogic.com/semantics/features/new/3.3-person.nt')//feature[@name = $name][            
                                     (                                     
                                     if(lower-case(substring(@value,1,1)) = lower-case(substring($value,1,1)))
                                     then                 
                                       if(
                                       matches($value, '[a-z]|[A-Z]')
                                       and
                                       not(matches($value, '^http://'))
                                       and
                                       (string-length($value) > 6 )
                                       and                 
                                       (string-length(@value) - string-length($value)) <= 10
                                       and
                                       string-length($value) <= 50 )
                                       then  
                                         let $initialOld := string-join((
                                                                    for $eachInitial in tokenize($value,' ') 
                                                                    return
                                                                    concat(substring($eachInitial,1,1), substring($eachInitial, string-length($eachInitial),1)) ),' ')
                                         let $initialNew := string-join((
                                                                    for $eachInitial in tokenize(@value,' ') 
                                                                    return
                                                                    concat(substring($eachInitial,1,1), substring($eachInitial, string-length($eachInitial),1)) ),' ')
                                                                    
                                         let $string-length1 := string-length(@value)
                                         let $string-length2 := string-length($value)
                                         let $distance := if($string-length1 > $string-length2) then spell:levenshtein-distance(substring(@value,1 ,$string-length2), $value )
                                                          else spell:levenshtein-distance(@value, substring($value,1 ,$string-length1))
                                         return
                                         if(count(tokenize(@value,' ')) = count(tokenize($value,' ')))
                                         then
                                           if((spell:levenshtein-distance(@value, $value ) <= 5) and ($initialOld = $initialNew)) then 1 else 0
                                         else 
                                           if( $distance <= 3 ) then 1 else 0
                                       else (@value = $value)                                         
                                     else 0                                     
                                     )
                                     and 
                                     (data(../feature[@name = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']/@value) = $typeVal)
                                     ]
                      let $base-uris := 
                                        <search name="{$name}" value="{$value}">
                                        {
                                        for $eachSearch in $search
                                        return
                                          <base-uri>{$eachSearch/base-uri()}</base-uri>
                                        }
                                        </search>

                      return
                        $base-uris
  
  let $allFeatures := if($allFeaturesAgain[base-uri]) then $allFeaturesAgain else $allFeatures
  
  let $totalFeatureFound := if($allFeaturesAgain[base-uri]) then count($allFeaturesAgain[base-uri]) * .75 else (count($allFeatures[base-uri]))
  let $percetageFeaturesFoound := ($totalFeatureFound div  $totalFeature ) * 100   
  
  
  return
   
    if($percetageFeaturesFoound >= 50)
        then   
          let $unfilteredResult :=
          for $eachDistinctURI in distinct-values($allFeatures//base-uri)
            let $searchThisURIInAllFeatureResult := $allFeatures/base-uri[. = $eachDistinctURI]
            let $countSearchResult := count($searchThisURIInAllFeatureResult)
            
            let $newPercentage := ($countSearchResult div  $totalFeature ) * 100
            
            return
              if($newPercentage >= 50 )
              then                
                <move similarFeaturesPercentage="{$newPercentage}">
                      <old featureURI="{$deletedRes/base-uri()}">{data($deletedRes)}</old>
                      <new featureURI="{$eachDistinctURI}">{data(doc($eachDistinctURI)/allFeatures/@res)}</new> 
                      <update> 
                        <deleted>
                            {
                            for $eachDelFeature in doc($deletedRes/base-uri())
                            return
                              $eachDelFeature//feature
                            }
                        </deleted>
                        <new>
                            {
                            for $eachNewFeature in doc($eachDistinctURI)
                            return
                              $eachNewFeature//feature
                            }
                        </new>
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
                  else
                    if($unfilteredResult)
                    then tie-breaker(<root>{$unfilteredResult[@similarFeaturesPercentage = $maxPercentage]}</root>)
                    else () 
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
    let $identify-update := LIB:identify-update(doc($oldURI)/allFeatures/@res, doc($newURI)/allFeatures/@res)

    let $doc := <moveAndUpdate similarFeaturesPercentage="{$eachMoveAndUpdate/@similarFeaturesPercentage}">
                  <old featureURI="{$oldURI}">{data($oldDoc/allFeatures/@res)}</old>
                  <new featureURI="{$newURI}">{data($newDoc/allFeatures/@res)}</new>
                  <update> 
                        <deleted>
                            {
                            for $eachDelFeature in doc($oldURI)
                            return
                              $eachDelFeature//feature
                            }
                        </deleted>
                        <new>
                            {
                            for $eachNewFeature in doc($newURI)
                            return
                              $eachNewFeature//feature
                            }
                        </new>
                  </update>
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
                            if($name != 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' and matches($value,'[a-zA-Z]') and string-length($value) < 50 and abs(string-length($newValue) - string-length($value)) <= 5)
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
          if((count($resulWithDistance/move[changePercentage = $minPercentage]) >  1) )
          then ()
          else $unfilteredResults/move
          [
          old/@featureURI = $resulWithDistance/move[changePercentage = $minPercentage and changePercentage < 15]/@oldFeatureURI
          and 
          new/@featureURI = $resulWithDistance/move[changePercentage = $minPercentage and changePercentage < 15]/@newFeatureURI
          ]
};


declare function smartFeatureMatch($value, $newValue, $name)
{
                          if(count(tokenize($value, ' ')) = count(tokenize($newValue, ' ')))
                          then
                            <feature name="{$name}" oldVal="{$value}" newVal="{data($newValue)}" sum="{string-length($value) + string-length($newValue)}">
                            {
                              
                              if((createStrictAbbrev($value) = createStrictAbbrev($newValue)))
                              then
                                spell:levenshtein-distance($value,   $newValue)
                              else 
                                string-length($value) + string-length($newValue)
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
                                            <match token="{$eachToken}" searchString="{$allToken}">{spell:levenshtein-distance($eachToken,   $allToken)}</match>
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

declare function createStrictAbbrev($value)
{
  let $strictAbbrev := string-join((
                                  for $eachInitial in tokenize($value,' ') 
                                  return
                                  substring($eachInitial,1,1) ),' ')
                     return
                       $strictAbbrev
   
};