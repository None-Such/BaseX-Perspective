
declare namespace sxx = "http://www.SoundExchange/ns/xquery/util";

declare variable $sourceDB := 'Excel-XML';
declare variable $resultDB := 'Excel-virtual-releases';

declare function sxx:rowPath($row as element(row)) as xs:string {
  'doc(''' || document-uri(root($row)) || ''')//row[@index=''' || $row/@index || ''']'
};

declare function sxx:represent-values($nodes as node()*) as element(v)* {
  for $n in $nodes
  return
  <v row-path="{sxx:rowPath($n/ancestor-or-self::row[1])}">{ string($n) }</v>
};

declare function sxx:get-document-uris($nodes as element(row)*) as element(v)* {
  for $n in $nodes
  return
  <v row-path="{sxx:rowPath($n)}">{ document-uri(root($n)) }</v>
};

declare variable $aggregate :=
   for $rowSet in db:open($sourceDB)//row
   let $releaseCode := $rowSet/album_upc
   group by $releaseCode
   return
   <aggregate product-code="{ $releaseCode }">
      <location-received>{ sxx:get-document-uris($rowSet) }</location-received>
      <canonical content-type="virtual-release">
         <provider-manifest provider="Excel">
            <message-id/>
            <message-language>en</message-language>
            <message-intent/>
         </provider-manifest>
         <release type="{if (count($rowSet) gt 1) then 'album' else 'single'}"
            provided-count="{ count($rowSet)}">
            <upc>{             sxx:represent-values($rowSet/album_upc)             }</upc>
            <title>{           sxx:represent-values($rowSet/album_title)           }</title>
            <artists>{         sxx:represent-values($rowSet/album_artists)         }</artists>
            <label>{           sxx:represent-values($rowSet/album_label)           }</label>
            <date-originated>{ sxx:represent-values($rowSet/album_date-originated) }</date-originated>
            <genre>{           sxx:represent-values($rowSet/album_genre)           }</genre>
         </release>
         { for $r at $p in $rowSet return
         <recording row-path="{sxx:rowPath($r)}">
            <isrc>{      $r/recording_isrc/string()    }</isrc>
            <title>{     $r/recording_title/string()   }</title>
            <artists>{   $r/recording_artists/string() }</artists>
            <label>{     $r/album_label/string()       }</label>
            <component>{ ()                            }</component>
            <position>{  $p                            }</position>
            <duration>{  ()                }</duration>
            <genre>{     $r/album_genre/string()       }</genre>
         </recording> }
      </canonical>
   </aggregate> ;

db:create($resultDB,$aggregate,$aggregate/@product-code/concat('productCode-',.,'.xml'))