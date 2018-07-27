// query
for $eachChunk in xdmp:filesystem-directory('D:\Trinity\PhD\Experiments\Experiment3\Datasets\Chunked\category_3.2')//*:pathname/data()
let $_ := xdmp:log($eachChunk)
let $query := "
				import module namespace sem = 'http://marklogic.com/semantics' at '/MarkLogic/semantics.xqy';
				declare variable $eachChunk external;  
				let $_ := sem:rdf-load($eachChunk
									   ,
									  ('turtle', 'graph=http://marklogic.com/semantics/DBpedia/3.2-category')
									  ,
									  ()
									  ,
									  ()
									  ,
									  '3.2-category'
									  )
				return ()
		      "
  return    
    xdmp:eval($query, (xs:QName("eachChunk"), $eachChunk)
                                           ,
                                           <options xmlns="xdmp:eval">
                                             <isolation>different-transaction</isolation>
                                             <prevent-deadlocks>false</prevent-deadlocks>
                                           </options>
                                           )