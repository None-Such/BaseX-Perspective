import module namespace sxs="http://www.SoundExchange/ns/xquery/schematron/util" at "schematron-lib.xqm";

declare option db:chop 'false';

(: Schematron implementation for BaseX
 : Note that Schematron phases are not supported, but that embedded XSLT should work.
 :)

(: declare directory relative to application directory (probably 'bin') :)

let $schematron := doc("../webapp/schematron/schematron/release-canonical-diagnostics.sch")

for $rc at $p in (/)
where $p le 50
return sxs:run-schematron($rc,$schematron)/sxs:make-schematron-observations(.)[exists(/*/observation)]
