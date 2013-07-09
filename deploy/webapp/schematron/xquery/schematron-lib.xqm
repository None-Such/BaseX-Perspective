module namespace sxs = "http://www.SoundExchange/ns/xquery/schematron/util";

declare option db:chop 'false';

(: Schematron implementation for BaseX
 : Note that Schematron phases are not supported, but that embedded XSLT should work.
 :)

(: declare directory relative to application directory (probably 'bin') :)
declare variable $sxs:schematron-xslt-dir := "../webapp/schematron/xslt";

declare function sxs:make-schematron-observations($docs as document-node()*)
                 as document-node()* {
   for $doc in $docs
   return xslt:transform($doc,sxs:get-step('svrl-sx-observations.xsl'))
};

declare function sxs:run-schematron($docs as document-node()*, $schematron as document-node())
                 as document-node()* {
   for $doc in $docs
   return xslt:transform($doc,sxs:compile-schematron($schematron))
};

declare function sxs:compile-schematron($sch as document-node())
                 as document-node() {
   let $assembled := xslt:transform( $sch,       sxs:get-step('iso-schematron-lib/iso_dsdl_include.xsl') )
   let $expanded  := xslt:transform( $assembled, sxs:get-step('iso-schematron-lib/iso_abstract_expand.xsl') )
   let $compiled  := xslt:transform( $expanded,
                                     sxs:get-step('iso-schematron-lib/iso_svrl_for_xslt2.xsl'),
                                     map{ 'allow-foreign' := 'true' } )
   return $compiled
  
};

declare function sxs:get-step($step-file as xs:string)
                 as document-node() {
   doc(string-join(($sxs:schematron-xslt-dir,$step-file),'/'))
};

(: Call like this:
let $schematron := doc("../webapp/schematron/schematron/release-canonical-diagnostics.sch")

for $rc at $p in (/)
where $p le 50
return sxs:run-schematron($rc,$schematron)/sxx:format-schematron-output(.)[exists(/*/observation)] :)
