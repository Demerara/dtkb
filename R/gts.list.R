
#The query is written to list all the geological concept of "North America".

#INPUT
# 1. prefix: optional, the prefix that need to be added
# 2. graph: optional, the graph user provided

#OUTPUT
#1. List all the geological concept of North America.

library(SPARQL)
gts.list = function(){
  
  # endpoint need to update accordingly
  endpoint = "http://virtuoso.nkn.uidaho.edu:8890/sparql/"
  
  sparql_prefix = " prefix tssc: <http://deeptimekb.org/tssc#> 
                  prefix tsnc: <http://deeptimekb.org/tsnc#> 
                  prefix dc: <http://purl.org/dc/elements/1.1/> 
                  prefix dcterms: <http://purl.org/dc/terms/> 
                  prefix foaf: <http://xmlns.com/foaf/0.1/> 
                  prefix geo: <http://www.opengis.net/ont/geosparql#> 
                  prefix gts: <http://resource.geosciml.org/ontology/timescale/gts#> 
                  prefix isc: <http://resource.geosciml.org/classifier/ics/ischart/> 
                  prefix owl: <http://www.w3.org/2002/07/owl#> 
                  prefix rank: <http://resource.geosciml.org/ontology/timescale/rank/> 
                  prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
                  prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
                  prefix samfl: <http://def.seegrid.csiro.au/ontology/om/sam-lite#> 
                  prefix sf: <http://www.opengis.net/ont/sf#> 
                  prefix skos: <http://www.w3.org/2004/02/skos/core#> 
                  prefix sosa: <http://www.w3.org/ns/sosa/> 
                  prefix thors: <http://resource.geosciml.org/ontology/timescale/thors#> 
                  prefix time: <http://www.w3.org/2006/time#> 
                  prefix ts: <http://resource.geosciml.org/vocabulary/timescale/> 
                  prefix vann: <http://purl.org/vocab/vann/> 
                  prefix void: <http://rdfs.org/ns/void#> 
                  prefix xkos: <http://rdf-vocabulary.ddialliance.org/xkos#> 
                  prefix xsd: <http://www.w3.org/2001/XMLSchema#> 
                "
  
  q = paste(sparql_prefix, '
            
            SELECT DISTINCT ?concept
WHERE
{
                
   GRAPH <http://deeptimekb.org/iscallnew>
   { 
      {
        ?sch  a skos:ConceptScheme ;
              rdfs:label ?slabel . 
        FILTER(regex(STR(?slabel), "North America", "i"))
      }

    UNION 
      {
        ?sch  a skos:ConceptScheme . 
        FILTER(regex(STR(?sch),"tsna", "i"))
      }

     ?concept  a gts:GeochronologicEra ,
                 gts:Age ; 
               skos:inScheme ?sch ;
               time:hasBeginning ?basePosition .  
     ?basePosition time:inTemporalPosition ?baseTime .
     ?baseTime time:numericPosition ?baseNum .
    }
   
}
ORDER BY ?baseNum
         
            ')
  
  res1 = SPARQL(endpoint, q)$results
  return(res1)
}         
gts.list()
