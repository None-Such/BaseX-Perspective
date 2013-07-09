(: Generating a unified database of containers with canonicals for a set of BaseX databases
   This generates the intrinsic database incrementally, running a batch of messages
   indicated by $messageStart and $messageCount, from *each* source (provider) given in the build plan.   
 :)

import module namespace sxx="http://www.SoundExchange/ns/xquery/release-id-api/util" at "emulate-release-identification-api.xqm";
  
declare variable $db             external := 'Release-Canonicals-Intrinsic';
declare variable $exceptionDB    external := 'Release-Canonicals-Exceptions';
declare variable $messageStart   external := 1;
declare variable $messageCount   external := 1000;
declare variable $showProvenance external := 'false';
declare variable $debug          external := 'false';

declare variable $buildPlan :=
   <build db="{$db}" exception-db="{$exceptionDB}"
      show-provenance="{$showProvenance}" debug="{$debug}"
      message-start="{$messageStart}" message-count="{$messageCount}">
      <!-- you can also say release-type="single" -->
      <source db="Repertoire-FineTunes-asOf-2013-06-11"              provider="Finetunes" />
			<source db="Repertoire-Ingrooves-asOf-2013-06-11"              provider="Ingrooves"/>
			<source db="Repertoire-Orchard-asOf-2013-06-11"                provider="Orchard"/>
			<source db="Repertoire-Sony-asOf-2013-06-11-virtual-releases"  provider="Sony" />
			<source db="Repertoire-Universal-asOf-2013-06-11"              provider="Universal"/>
  		<source db="Repertoire-Warner-asOf-2013-06-11" 	               provider="Warner"/>
   </build>;

(: for debugging, sxx:produce-containers will generate the results but not
   write them to the $db
   
   sxx:produce-containers($build) :)

if (exists(sxx:missing-sources($buildPlan))) then sxx:report-missing-sources($buildPlan)
else sxx:build-repertoire-db-incrementally($buildPlan)
