declare namespace sxx = "http://www.SoundExchange/ns/xquery/util";

(: declare default element namespace "http://www.SoundExchange/ns"; :)

declare option output:item-separator '\n';
declare option output:method "text"; (: xml = escaped AND text= un-escaped :)

declare variable $serialization-format :=
  <output:serialization-parameters>
    <output:indent value="no"/>
  </output:serialization-parameters>;

declare variable $db := "Archive-Release-Canonicals-2013-04-05";

declare function sxx:message-items($canonical as element(canonical)) as element(item)*
(: returns a sequence of line items for releases in a given Release Canonical. :)
{ 
    let $recordings := $canonical/recording
    
    for $recording at $rc in $recordings
    let $release := $recording/../release
    return
    <item messageID="{$canonical/Provider_Manifest/ID}" rc="{$rc}">
        <canonical_uri>{            base-uri($canonical)                                     }</canonical_uri>
        <message_update_indicator>{ sxx:value($canonical/provider-manifest/message-language) }</message_update_indicator>
        <release_UPC>{              sxx:value($release/upc)                                  }</release_UPC>
        <release_title>{            sxx:value($release/title)                                }</release_title>
        <release_artists>{          sxx:value($release/artists)                              }</release_artists>
        <release_genre>{            sxx:value($release/genre)                                }</release_genre>
        <release_original_date>{    sxx:value($release/date-originated)                      }</release_original_date>
        <recording_ISRC>{           sxx:value($recording/isrc)                               }</recording_ISRC>
        <recording_title>{          sxx:value($recording/title)                              }</recording_title>
        <recording_duration>{       sxx:value($recording/duration)                           }</recording_duration>
        <recording_component>{      sxx:value($recording/component)                          }</recording_component>
        <recording_position>{       sxx:value($recording/position)                           }</recording_position>
        <recording_label>{          sxx:value($recording/label)                              }</recording_label>
        <recording_genre>{          sxx:value($recording/genre)                              }</recording_genre>
        <raw_XML>{                  serialize($canonical, $serialization-format)             }</raw_XML>
    </item>
};

declare function sxx:value($node as node()?) as xs:string
(: if given a single item or none, returns a string; if given
   more than one, returns a sequence of 'v' elements :)
{
    if (exists($node)) then 
        if (normalize-space($node)) then normalize-space($node)
        else '[NODE-WITH-NO-VALUE-loadToSolr-Recording-canonicals.xq]'
    else
        '[NODE-MISSING-loadToSolr-Recording-canonicals.xq]'
};

declare variable $delim := '&#x25D0;'; (: ◐ %E2%97%90 U+25D0   Circle with left half black :)
declare variable $encap := '&#x25C0;'; (: ◀ %E2%97%80 U+25C0   Black left-pointing triangle :)

(: Escapes any delimiter characters :)
declare function sxx:escape($str as xs:string) as xs:string {
   let $encap-escaped := replace($str,          $encap,'[ERROR: FIELD ENCAPSULATOR U+25C0 FOUND]')
   let $delim-escaped := replace($encap-escaped,$delim,'[ERROR: FIELD DELIMITER U+25D0 FOUND]')
   return $delim-escaped
};


(: Writes a sequence of elements in an item as a line :)
declare function sxx:line-item($item as element(item)) as xs:string {
  string-join($item/*/sxx:escape(string(.)),$delim)
};

let $canonicals := db:open($db)/sx-container/canonical[@content-type='repertoire-release']

for $c at $p in $canonicals
where $p le 500

(: to see intermediate results
   return $m/sxx:message-items(.)  :)

return $c/sxx:message-items(.)/sxx:line-item(.)
