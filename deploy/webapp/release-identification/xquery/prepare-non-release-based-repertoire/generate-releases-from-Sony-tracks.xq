
declare namespace sxx = "http://www.SoundExchange/ns/xquery/util";

declare variable $sourceDB := 'Repertoire-Sony-asOf-2013-06-11';
declare variable $resultDB := 'Repertoire-Sony-asOf-2013-06-11-virtual-releases';

declare function sxx:represent-values($nodes as node()*) as element(v)* {
  for $n in $nodes
  return
  <v trackID="{$n/ancestor-or-self::Track/TrkID}">{ string($n) }</v>
};

declare function sxx:get-document-uris($nodes as node()*) as element(v)* {
  for $n in $nodes
  return
  <v trackID="{$n/ancestor-or-self::Track/TrkID}">{ document-uri(root($n)) }</v>
};

declare variable $aggregate :=
   for $trackSet in db:open($sourceDB)//Track
   let $releaseCode := $trackSet/MetaData/PhysicalProduct/ProductCode
   group by $releaseCode
   return
   <aggregate product-code="{ $releaseCode }">
      <location-received>{ sxx:get-document-uris($trackSet) }</location-received>
      <canonical content-type="virtual-release">
         <provider-manifest provider="Sony">
            <message-id/>
            <message-language>en</message-language>
            <message-intent/>
         </provider-manifest>
         <release type="{if (count($trackSet) gt 1) then 'album' else 'single'}"
            provided-count="{ count($trackSet)}">
            <upc>{             sxx:represent-values($trackSet/MetaData/PhysicalProduct/ProductCode) }</upc>
            <title>{           sxx:represent-values($trackSet/MetaData/PhysicalProduct/Title)       }</title>
            <artists>{         sxx:represent-values($trackSet/MetaData/PhysicalProduct/ArtistText)  }</artists>
            <label>{           sxx:represent-values($trackSet/MetaData/Label)                       }</label>
            <date-originated>{ sxx:represent-values($trackSet/MetaData/PhysicalProduct/ReleaseDate) }</date-originated>
            <genre>{           sxx:represent-values($trackSet/MetaData/Genre/@name)                 }</genre>
         </release>
         { for $t in $trackSet return
         <recording trackID="{$t/TrkID}"
            expected-count="{ $t/MetaData/PhysicalProduct/TrackCount/string() }">
            <isrc>{      $t/MetaData/ISRC/string()                       }</isrc>
            <title>{     $t/MetaData/Title/string()                      }</title>
            <artists>{   $t/MetaData/Artist/string()                     }</artists>
            <label>{     $t/MetaData/Label/string()                      }</label>
            <component>{ if (exists($t/MetaData/TrackBundle))
                         then $t/MetaData/TrackBundle/SequenceNo/string()
                         else 1                                          }</component>
            <position>{  $t/MetaData/PhysicalProduct/TrackNo/string()    }</position>
            <duration>{  $t/AudioDownload/Duration/string()              }</duration>
            <genre>{     $t/MetaData/Genre/@name/string()                }</genre>
         </recording> }
      </canonical>
   </aggregate> ;

db:create($resultDB,$aggregate,$aggregate/@product-code/concat('productCode-',.,'.xml'))