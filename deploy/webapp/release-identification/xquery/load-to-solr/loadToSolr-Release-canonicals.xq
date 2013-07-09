declare namespace sxx = "http://www.SoundExchange/ns/xquery/util";

(: declare default element namespace "http://www.SoundExchange/ns"; :)

declare option output:item-separator '\n';
declare option output:method "text"; (: xml = escaped AND text= un-escaped :)

declare variable $serialization-format :=
  <output:serialization-parameters>
    <output:indent value="no"/>
  </output:serialization-parameters>;


declare variable $db := "Release-Canonicals-Comparative";
(: declare variable $db := "Release-Canonicals-testing"; :)


declare variable $sxx:xslt-debug                 := "false";
declare variable $sxx:xslt-path                  := "../webapp/release-identification/xslt/";
declare variable $sxx:generate-SolrLoad-xml-xslt := $sxx:xslt-path || "generate-SolrLoad-xml.xsl";
declare variable $sxx:scrub-xslt                 := $sxx:xslt-path || "utility/filter-out-linefeeds-and-normalize-whitespace.xsl";


declare function sxx:generate-SolrLoad-xml($container as document-node()) as document-node()*
{ let $xsltParams := map { 'debug' := ($sxx:xslt-debug,'false')[1] }
  let $load-xml := sxx:run-xslt($container, $sxx:generate-SolrLoad-xml-xslt, $xsltParams)
  return sxx:run-xslt($load-xml, $sxx:scrub-xslt, $xsltParams) };


declare function sxx:run-xslt($source as document-node(), $stylesheet as xs:string, $params as map(*)?)
                 as document-node()* {
   try { xslt:transform($source, $stylesheet, $params ) }
   catch * { document {
      <EXCEPTION>
        { 'EXCEPTION [' ||  $err:code || '] XSLT failed: ' || $stylesheet || ': ' || normalize-space($err:description) }
      </EXCEPTION>  } }
};

declare variable $delim := '&#9664;'; (: ◀ %E2%97%80 U+25C0   Black left-pointing triangle PREVIOUSLY tried ¶ paragraph symbol but it collided with diacritics in the data:)
declare variable $encap := '&#9680;'; (: ◐ %E2%97%90 U+25D0   Circle with left half black « Left double angle quotes but it collided with diacritics in the data:)

(: Escapes any delimiter characters :)
declare function sxx:escape($str as xs:string) as xs:string {
   let $encap-escaped := replace($str,          $encap,'[EXCEPTION: FIELD ENCAPSULATOR FOUND]')
   let $delim-escaped := replace($encap-escaped,$delim,'[EXCEPTION: FIELD DELIMITER FOUND]')
   return $delim-escaped
};

(: Writes an XML Solr-Load document as a line :)
declare function sxx:line-item($load-xml as document-node()) as xs:string
(: writes a line item as a line, with 'v' elements provided with encapsulators :)
{
   if (empty($load-xml/Solr-Load)) then 'EXCEPTION: Solr-Load XML document not given'
   else string-join(
      for $field in $load-xml/*/* return
         if ($field/@type='xml') then
            serialize($field/*, $serialization-format)
         else if ($field/@type='multi-value' and exists($field/*)) then
            string-join( for $v in $field/* return ($encap || string($v) || $encap),'' )
         else $field/string(.), $delim)
};


let $containers := 
  for $container at $position in db:open($db)
  where ($position ge 220001 and $position le 260000) 
  (: 50k as batch size for loading :)
  return $container
  

(: to see intermediate results
   return $containers/sxx:generate-SolrLoad-xml(.) and change the output method for the query (above) to XML ...  :)

return $containers/sxx:generate-SolrLoad-xml(.)/sxx:line-item(.)
(: [position() gt 2790 and position() lt 2792] :)
(: 40,000 documents in 285,348 ms :)