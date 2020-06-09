#The goal is to find all the broader and broaderTransitive concepts.i.e. concepts at higher levels, such as Epoch, Period, Era, and Eon.  

# INPUT: 
# 1. Time: time in geology, e.g. 50 Ma
# 2. prefix: optional, the prefix that need to be added
# 3. graph: optional, the graph user provided

# OUTPUT:
# All the geoConcepts for the given geology time



library(SPARQL)
gts.point = function(time, prefix = NULL, graph = NULL){
  
  # endpoint need to update accordingly
  endpoint = "http://virtuoso.nkn.uidaho.edu:8890/sparql/"
  
  sparql_prefix = " 
                prefix dc: <http://purl.org/dc/elements/1.1/>
                prefix gts: <http://resource.geosciml.org/ontology/timescale/gts#>
                prefix skos: <http://www.w3.org/2004/02/skos/core#>
                prefix time: <http://www.w3.org/2006/time#>
                prefix ts: <http://resource.geosciml.org/vocabulary/timescale/> 
                prefix isc: <http://resource.geosciml.org/classifier/ics/ischart/> 
        "

  if (!is.null(prefix)){
    sparql_prefix = paste(prefix, sparql_prefix, sep = "/n")
  }
  
  # run the query
  if(!is.null(graph)){
          q = paste(sparql_prefix, "
             SELECT DISTINCT ?All
      WHERE
      {", graph, "
         {
      
      { 
      SELECT DISTINCT ?tconcept  
      WHERE
      {
              	?tconcept skos:prefLabel ?label ;
                	dc:description 
                	[  
              	        	time:hasBeginning ?baseboundary ;
              	        	skos:inScheme ts:isc2012-08
                	] ;
                	rdf:type gts:Age.
             
       
          	
                 
      	?baseboundary time:inTemporalPosition ?basetime .
                      
                       
      	?basetime dc:description
                                      	     	[
                                      	         	time:numericPosition ?baseNum;
                                      	         	skos:inScheme ts:isc2012-08
                                      	     	]  .
      
            
            FILTER (?baseNum >=", time, ") .
      
      }
      ORDER BY ?baseNum
      LIMIT 1
      }
      
      { #This block is to include the Age-level concept in the resulting list 
        ?tconcept rdfs:label ?labelAgeC . 
        ?All rdfs:label ?labelAgeC .
      }
      UNION
      { # This and the next block are to find the broader and broaderTransitive concepts
      ?tconcept
      dc:description
            [
               skos:broaderTransitive ?All ;
               skos:inScheme  ts:isc2012-08
            ]
      }
      UNION 
      {
      ?tconcept
      dc:description
            [
               skos:broader  ?All ;
               skos:inScheme  ts:isc2012-08
            ]
      
      }
        
            ?All 
            dc:description 
            [  
              time:hasBeginning ?baseboundary1 ;
              time:hasEnd ?topboundary1 ;
              skos:inScheme ts:isc2012-08
              ] .
            
            ?baseboundary1 time:inTemporalPosition ?basetime1 .
            ?topboundary1 time:inTemporalPosition ?toptime1 .
            
            ?basetime1 dc:description
            [
              time:numericPosition ?baseNum1;
              skos:inScheme ts:isc2012-08
              ]  .
            
            ?toptime1 dc:description
            [
              time:numericPosition ?topNum1;
              skos:inScheme ts:isc2012-08
              ]  .
            
            BIND (?baseNum1 - ?topNum1 AS ?numLength1)
            
          }
      }
      
      ORDER BY ?numLength1
      
      ")
          
  } else {
    q = paste(sparql_prefix, "
       SELECT DISTINCT ?All
WHERE
{
        	GRAPH <http://deeptimekb.org/iscallnew>
   {

{ 
SELECT DISTINCT str(?label) AS ?geoConcept  # why Virtuoso 42000 Error The estimated execution time 1049 (sec) exceeds the limit of 400 (sec).
WHERE
{
        	?tconcept skos:prefLabel ?label ;
          	dc:description 
          	[  
        	        	time:hasBeginning ?baseboundary ;
        	        	skos:inScheme ts:isc2012-08
          	] ;
          	rdf:type gts:Age.
       
 
    	
           
	?baseboundary time:inTemporalPosition ?basetime .
                
                 
	?basetime dc:description
                                	     	[
                                	         	time:numericPosition ?baseNum;
                                	         	skos:inScheme ts:isc2012-08
                                	     	]  .

      
      FILTER (?baseNum >=", time, ") .

}
ORDER BY ?baseNum
LIMIT 1
}

{ #This block is to include the Age-level concept in the resulting list 
  ?tconcept rdfs:label ?labelAgeC . 
  ?All rdfs:label ?labelAgeC .
}
UNION
{ # This and the next block are to find the broader and broaderTransitive concepts
?tconcept
dc:description
      [
         skos:broaderTransitive ?All ;
         skos:inScheme  ts:isc2012-08
      ]
}
UNION 
{
?tconcept
dc:description
      [
         skos:broader  ?All ;
         skos:inScheme  ts:isc2012-08
      ]

}
  
      ?All 
      dc:description 
      [  
        time:hasBeginning ?baseboundary1 ;
        time:hasEnd ?topboundary1 ;
        skos:inScheme ts:isc2012-08
        ] .
      
      ?baseboundary1 time:inTemporalPosition ?basetime1 .
      ?topboundary1 time:inTemporalPosition ?toptime1 .
      
      ?basetime1 dc:description
      [
        time:numericPosition ?baseNum1;
        skos:inScheme ts:isc2012-08
        ]  .
      
      ?toptime1 dc:description
      [
        time:numericPosition ?topNum1;
        skos:inScheme ts:isc2012-08
        ]  .
      
      BIND (?baseNum1 - ?topNum1 AS ?numLength1)
      
    }
}

ORDER BY ?numLength1

") 
  }

  
  res = SPARQL(endpoint, q)$results
  return(res)
}



