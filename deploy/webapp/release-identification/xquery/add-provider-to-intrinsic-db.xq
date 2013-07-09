(: Adding all messages from a single provider to the
   unified database of containers with canonicals for a set of BaseX databases.
   Call repeatedly with (for) the different providers to get all of them.
 :)

import module namespace sxx="http://www.SoundExchange/ns/xquery/release-id-api/util" at "emulate-release-identification-api.xqm";
  
declare variable $db             external := 'Release-Canonicals-Intrinsic';
declare variable $exceptionDB    external := 'Release-Canonicals-Exceptions';
declare variable $provider       external := 'Universal';
declare variable $showProvenance external := 'false';
declare variable $debug          external := 'false';

declare variable $buildPlan :=
   <build db="{$db}" exception-db="{$exceptionDB}"
      show-provenance="{$showProvenance}" debug="{$debug}">
      
    <source db="Repertoire-FineTunes-asOf-2013-06-11"              provider="Finetunes" />
	 <source db="Repertoire-Ingrooves-asOf-2013-06-11"              provider="Ingrooves"/>
	 <source db="Repertoire-Orchard-asOf-2013-06-11"                provider="Orchard"/>
	 <source db="Repertoire-Sony-asOf-2013-06-11-virtual-releases"  provider="Sony" />
	 <source db="Repertoire-Universal-asOf-2013-06-11"              provider="Universal"/>
    <source db="Repertoire-Warner-asOf-2013-06-11" 	              provider="Warner"/>
    
    <!-- <source db="Universal-samples"              provider="Universal"/>
         <source db="Warner-samples" 	              provider="Warner"/> -->
		  
  </build>;

(: for debugging, sxx:produce-containers will generate the results but not
   write them to the $db
   
   sxx:produce-containers($build) :)

if (exists(sxx:missing-sources($buildPlan))) then sxx:report-missing-sources($buildPlan)
else sxx:build-repertoire-db-for-provider($buildPlan,$provider)
