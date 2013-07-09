
import module namespace sxx="http://www.SoundExchange/ns/xquery/release-id-api/util" at "../xquery/emulate-release-identification-api.xqm";
  

declare variable $containerSetStart external := 1;
declare variable $containerSetCount external := 100;
(: declare variable $containerSetStart external := -1;
   declare variable $containerSetCount external := -2; :)
declare variable $containerSetEnd   := number($containerSetStart) + number($containerSetCount) - 1;

declare variable $containerDB external := 'Release-Canonicals-Intrinsic';
declare variable $comparedDB  external := 'Release-Canonicals-Comparative';
(: declare variable $comparedDB  external := 'MISSING-PARAMETER-CONTAINER-DB'; :)
declare variable $debug       external := "false";

declare variable $xsltPath                                        := "../webapp/release-identification/xslt/";
declare variable $makeObservationsComparativeSequenceXSLT         := $xsltPath || "basex-emulation/make-observations-comparison-sequencing.xsl";
declare variable $makeObservationsComparativeDifferentiationXSLT  := $xsltPath || "make-observations-comparative.xsl";
declare variable $makeObservationsReflectiveRefinementXSLT        := $xsltPath || "make-observations-reflective-refinement.xsl";
declare variable $makeObservationsReflectiveCombinatoryXSLT       := $xsltPath || "make-observations-reflective-combinatory.xsl";
declare variable $makeObservationsReflectiveUnrefinedXSLT         := $xsltPath || "make-observations-reflective-observe-unrefined.xsl";
declare variable $segregateObservationsXSLT                       := $xsltPath || "segregate-observations.xsl";

declare variable $xsltParams := map { 'debug' := $debug };

declare variable $containerIndex :=
   <container-index> {
      let $containers := db:open(string($containerDB))
      for $provider-set in $containers[exists(sx-container/sx-manifest/provider)]
      let $provider := $provider-set/sx-container/sx-manifest/provider
      group by $provider
      return
         for $upc-set in $provider-set[exists(sx-container/canonical/release/upc)]
         let $upc := $upc-set/sx-container/canonical/release/upc
         group by $upc
         return <container-set> {
            for $container in $upc-set
            let $location := $container//sx-container/sx-manifest/location-received
            (: proxy for temporal ordering :)
            order by $location
            return <container node-id="{ db:node-pre($container) }"/> } </container-set> }
   </container-index> ;


declare function sxx:generate-compared-container($attested as element(sx-container),
                                                 $provided as element(sx-container))
                 as document-node() {
  let $comparisonPair := document {
     <container-comparison-pair>
        { sxx:mark-container($attested, 'attested') }
        { sxx:mark-container($provided, 'provided') }
     </container-comparison-pair> }
  return sxx:run-xslt($comparisonPair, $makeObservationsComparativeDifferentiationXSLT, $xsltParams)
};

(: sxx:run-xslt-pipeline accepts a document, a sequence of references to stylesheets, and a ).
 :)


(: sxx:mark-container rewrites an sx-container using the $status designated as an argument
   (so containers may be flagged for comparison on the fly).
 :)

declare function sxx:mark-container ($container as element(sx-container), $status as xs:string) as element(sx-container) {
   <sx-container purpose="repertoire-{$status}">{ $container/* }</sx-container>
};

(: The variable $comparedContainers produces a set of all containers annotated to reflect their
   relative placement within $sortedContainers, and compared with any attested containers
   in the same group.
   This is accomplished by passing the entire group through a transformation to insert
   observations into its containers, then performing pairwise comparisons
   on any containers after the first in the group, with its immediately preceding sibling. :)

declare variable $comparedContainers :=
   for $indexSequence at $p in $containerIndex/container-set
   where ($p ge number($containerSetStart) and $p le number($containerSetEnd))
   return
      let $containerSequence := document {
         <container-sequence>{
            for $c in $indexSequence/container return db:open-pre(string($containerDB),$c/@node-id)
         }</container-sequence> }
      let $annotatedSequence := sxx:run-xslt($containerSequence, $makeObservationsComparativeSequenceXSLT, $xsltParams)
      return (: debug with $annotatedSequence/*/sx-container/document { . }; :)
         ( document { $annotatedSequence/*/sx-container[1] },
           for $providedContainer in $annotatedSequence/*/sx-container[position() gt 1]
           let $attestedContainer := $providedContainer/preceding-sibling::sx-container[1]
           return sxx:generate-compared-container($attestedContainer,
                                                  $providedContainer) );


declare variable $refinedContainers :=
   let $pipeline := ($makeObservationsReflectiveRefinementXSLT  [true()], (: Switch off any transformation with false() :)
                     $makeObservationsReflectiveCombinatoryXSLT [true()],
                     $makeObservationsReflectiveUnrefinedXSLT   [$debug = 'true'],
                     $segregateObservationsXSLT                 [true()])
   return $comparedContainers/sxx:run-xslt-pipeline(., $pipeline, $xsltParams);
   
(: MAIN CALL STARTS HERE :)   

db:output('&#xA;Processed ' || count($comparedContainers) || ' containers in comparison sets ' ||
           $containerSetStart || ' to ' ||
           (if ($containerSetEnd gt count($containerIndex/container-set)) 
              then count($containerIndex/container-set) else $containerSetEnd ) ||
          '&#xA;(out of ' ||
          count($containerIndex/container-set) || ' comparison sets with ' ||
          count($containerIndex/container-set/container) || ' containers total)&#xA;' ),

for $qc in $refinedContainers
let $location := $qc/sx-container/sx-manifest/location-received
where exists($location)
return
   if (db:exists($comparedDB, $location))
   then db:replace($comparedDB, $location, $qc)
   else db:add($comparedDB, $qc, $location)

(: $comparedContainers[empty(sx-container/sx-manifest/location-received)] :)

(: count($containerIndex/container-set[position() lt 2000][count(container) gt 1]):)

(: $comparedContainers/count(/*/sx-container) :)
