(: XQuery module - Sound Exchange Repertoire Release Identification
   
   This XQuery module provides functions for handling Repertoire messages,
   generating API requests, canonical versions in response to requests, etc.
   
 :)

module namespace sxx = "http://www.SoundExchange/ns/xquery/release-id-api/util";

(: build-repertoire-db adds messages to a database according to a plan, either
   adding to a designated database or creating a new one when it does not
   already exist.
   
   Example input:
   <build db="Release-canonicals-20130415test"
       show-provenance="no" debug="no"
       message-start="200" message-count="300">
       <source db="Ingrooves-samples" provider="Ingrooves"/>
      <source db="Warner-samples" 	 provider="Warner"/>
      <source db="Universal-samples" provider="Universal"/>
   </build>
:)

(: ** Module Entry-point when generating incrementally (batching all providers by message counts) :)
declare %updating function sxx:build-repertoire-db-incrementally($buildPlan as element(build)) {
  
   let $db := $buildPlan/@db/string()
   let $exceptionDB := $buildPlan/@exception-db/string()
   let $containers := sxx:incrementally-construct-and-pipeline-containers($buildPlan)
   return
      for $c in $containers
      let $location := $c/sx-container/sx-manifest/location-received
         return
         if (sxx:okay-to-add($c)) then
            if (db:exists($db, $location)) then db:replace($db, $location, $c)
            else                                db:add($db, $c, $location )
         else db:add($exceptionDB, $c, ($location,'exception.xml')[1] )
 };

(: ** Module Entry-point when generating by provider :)
declare %updating function sxx:build-repertoire-db-for-provider($buildPlan as element(build), $provider as xs:string) {
  
   let $db := $buildPlan/@db/string()
   let $exceptionDB := $buildPlan/@exception-db/string()
   let $containers :=
      let $source := $buildPlan/source[@provider=$provider]
      let $pipelineParams := map {                                           (: $pipelineParams will be sent into XSLT at runtime. :)
   	    'provider'         := $provider,
   	    'showProvenance'   := ($buildPlan/@show-provenance,'false')[1],
   	    'debug'            := ($buildPlan/@debug,'false')[1] }
      return db:open(string($source/@db))/sxx:construct-container(., $pipelineParams)/sxx:pipeline-container(., $pipelineParams)
   
   return
      for $c in $containers
      let $location := $c/sx-container/sx-manifest/location-received
         return
         if (sxx:okay-to-add($c)) then
            if (db:exists($db, $location)) then db:replace($db, $location, $c)
            else                                db:add($db, $c, $location )
         else db:add($exceptionDB, $c, ($location,'exception.xml')[1] )
 };

declare function sxx:missing-sources($buildPlan as element(build)) as element(source)* {
   $buildPlan//source[not(db:exists(@db))]
};

declare %updating function sxx:report-missing-sources($buildPlan as element(build)) {
  let $missing := sxx:missing-sources($buildPlan)
  return db:output('Missing source database' || 's'[count($missing) ne 1] || ' declared in build: ' ||
                   string-join($missing/@db,', ') )
};

(: sxx:okay-to-add() returns true() only when a container is fit to be added to the Repertoire DB. :)
declare function sxx:okay-to-add($container as document-node()) as xs:boolean {
  (: provider is given :)
  exists($container/sx-container/sx-manifest/provider)  and

  (: upc is given :)
  exists($container/sx-container/canonical/release/upc) and
  
  (: location-received is given, only once, not empty or whitespace-only :)
  (let $location := $container/sx-container/sx-manifest/location-received
   return count($location) eq 1 and matches($location,'\S') )
};

(: sxx:incrementally-produce-containers processes a specification of a build (runtime parameters and inputs) to return a set of containers. It accepts the same input 'build' element as its calling function. :)   
declare function sxx:incrementally-construct-and-pipeline-containers($build as element(build)) as document-node()* {
   for $source in $build/source
   let $start := ($build/@message-start/number(),1)[1]
   let $end   := $start + ($build/@message-count/(number() - 1),xs:double('INF'))[1]
   let $pipelineParams := map {                                           (: $pipelineParams will be sent into XSLT at runtime. :)
      'provider'         := $source/@provider,
      'showProvenance'   := ($build/@show-provenance,'false')[1],
      'debug'            := ($build/@debug,'false')[1] }
   for $doc at $p in db:open(string($source/@db))
      (: NOTE: Following 2 lines would constrain processing to incremental batching, as opposed to processing an entire provider db's content when commented out:)
      (: [if (empty($build/@release-type)) then true() else sxx:release-type(.) = $build/@release-type] :)
      where ($p ge $start and $p le $end)

   (:  executes 2 functions in a row, passing the result of the 1st to the 2nd:)
   return sxx:construct-container($doc, $pipelineParams)/sxx:pipeline-container(., $pipelineParams)
};

(: Containers are populated with the results of transformations run on messages, as follows.

 : Paths to stylesheets will be resolved relative to the startup directory (typically 'bin') :)

declare variable $sxx:xsltPath                              := "../webapp/release-identification/xslt/";
declare variable $sxx:composeManifestXSLT                   := $sxx:xsltPath || "basex-emulation/compose-provisional-sx-manifest.xsl";
declare variable $sxx:createCanonicalAndAddToContainerXSLT  := $sxx:xsltPath || "create-canonical-and-add-to-container.xsl";
declare variable $sxx:makeObservationsIntrinsicXSLT         := $sxx:xsltPath || "make-observations-intrinsic.xsl";
declare variable $sxx:assessComparabilityXSLT               := $sxx:xsltPath || "make-observations-reflective-comparability.xsl";

(: sxx:construct-container builds an sx-container document combining
   an sx-manifest (emulating the manifest in a container submitted to the API)
   with the original provider message.
:)
declare function sxx:construct-container($message as document-node(), $pipelineParams as map(*) ) as document-node() {
   document {
      <sx-container purpose="repertoire-attested">
         { sxx:run-xslt($message, $sxx:composeManifestXSLT, $pipelineParams) }
         { element { 'provider-message' } { $message } }
      </sx-container> 
   }
};

(: processes a container through an XSLT pipeline. :)
declare function sxx:pipeline-container($container as document-node(), (: a container as made by sxx:construct-container :)
                                       $pipelineParams as map(*))     (: parameters for XSLT processes :)
                 as document-node()* {

   let $pipeline := ($sxx:createCanonicalAndAddToContainerXSLT [true()], 
                     $sxx:makeObservationsIntrinsicXSLT        [true()],
                     $sxx:assessComparabilityXSLT              [false()])
   return sxx:run-xslt-pipeline($container, $pipeline, $pipelineParams)
};

(: recursively processes the XSLT pipeline as a sequence of XSLT references (passed in as a list of strings) :)
declare function sxx:run-xslt-pipeline($source as document-node(),
                                       $stylesheets as xs:string*,
                                       $params as map(*)? )
                 as document-node() {
   if (empty($stylesheets)) then $source
   else
      let $intermediate := sxx:run-xslt($source, $stylesheets[1], $params)
      return sxx:run-xslt-pipeline($intermediate, remove($stylesheets,1),$params)
};

(: for robustness of execution, to catch Saxon errors (to safely message them) and avoid BaseX runtime errors :)
declare function sxx:run-xslt($source as document-node(), $stylesheet as xs:string, $params as map(*)?)
                 as document-node()* {
   try { xslt:transform($source, $stylesheet, $params ) }
   catch * { document {
      <EXCEPTION>
        { 'EXCEPTION [' ||  $err:code || '] XSLT failed: ' || $stylesheet || ': ' || normalize-space($err:description) }
      </EXCEPTION>  } }
};

(: Following is a utility function for determining the release type of an input message by static analysis, for use if you wish to populate a database only with a certain message type -- without generating canonicals    for those you don't want.  :)
declare function sxx:release-type($doc as document-node()) as xs:string* {
   (: DDEX: lower-case values of Release/ReleaseType
      (we have seen 'Single', 'TrackRelease', 'Album') :) 
   $doc/*:NewReleaseMessage/ReleaseList/Release/ReleaseType/lower-case(.),

   (: Universal: 'album' or 'single' depending on whether the message contains
      more than one track (album) or not (single). :)
   $doc/product[@upc]/
      (if (count(tracks/track) gt 1) then 'album' else 'single')
};
