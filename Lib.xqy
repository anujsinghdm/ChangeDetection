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
            let $name := $eachFeature/@name
            let $value := $eachFeature/@value  
            let $search := collection('http://marklogic.com/semantics/features/new/3.3-person.nt')//feature[@name = $name and @value = $value]
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
  let $totalFeatureFound := count($allFeatures[base-uri])
  let $percetageFeaturesFoound := ($totalFeatureFound div  $totalFeature ) * 100
  
  return
   
    if($percetageFeaturesFoound >= 50)
        then   
          for $eachDistinctURI in distinct-values($allFeatures)
          let $searchThisURIInAllFeatureResult := $allFeatures/base-uri[. = $eachDistinctURI]
            let $countSearchResult := count($searchThisURIInAllFeatureResult) 
            return
              if($totalFeatureFound = $countSearchResult)
              then
                let $oldtype :=   $deletedRes/../feature[@name = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']/@value
                let $newType := doc($eachDistinctURI)/allFeatures/feature[@name = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type']/@value
                let $newPercentage := if($oldtype = $newType) then let $percetageFeaturesFoound := (($totalFeatureFound + 1) div  $totalFeature ) * 100 return $percetageFeaturesFoound else $percetageFeaturesFoound
                return
                <move similarFeaturesPercentage="{$newPercentage}">
                      <old featureURI="{$deletedRes/base-uri()}">{data($deletedRes)}</old>
                      <new featureURI="{$eachDistinctURI}">{data(doc($eachDistinctURI)/allFeatures/@res)}</new>
                  </move>
                  
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
    
    let $doc := <moveAndUpdate similarFeaturesPercentage="{$eachMoveAndUpdate/@similarFeaturesPercentage}">
                  <old featureURI="{$oldURI}">{data($oldDoc/allFeatures/@res)}</old>
                  <new featureURI="{$newURI}">{data($newDoc/allFeatures/@res)}</new>
                </moveAndUpdate>
    return
      if($similarFeaturePercentage = 100)
      then
        (
          xdmp:document-delete($oldURI)
          ,
          xdmp:document-delete($newURI)
        )
      else
        (  
        xdmp:document-delete($oldURI)
        ,
        xdmp:document-delete($newURI)
        ,
        xdmp:document-delete($eachMoveAndUpdate/base-uri())
        ,
        xdmp:document-insert($moveAndUpdatedURI, $doc, (), $moveAndUpdatedCollectionURI)  
        )
};
