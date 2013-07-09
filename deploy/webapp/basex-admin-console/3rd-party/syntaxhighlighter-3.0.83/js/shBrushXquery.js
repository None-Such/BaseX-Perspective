/**
 * SyntaxHighlighter
 * http://alexgorbatchev.com/SyntaxHighlighter
 *
 * This file is an extension to SyntaxHighlighter
 * by Christian Gruen
 * 
 * @copyright
 * Copyright (C) 2004-2010 Alex Gorbatchev.
 *
 * @license
 * Dual licensed under the MIT and GPL licenses.
 */
;(function()
{
  // CommonJS
  typeof(require) != 'undefined' ? SyntaxHighlighter = require('shCore').SyntaxHighlighter : null;

  function Brush()
  {
    var keywords = 'after all and any as ascending at attribute base-uri before boundary-space by case cast castable catch collation comment construction contains content context copy copy-namespaces declare default delete descending diacritics different distance div document element else empty encoding end entire every exactly except external first for from ft-option ftand ftnot ftor fulltext fuzzy function greatest idiv if import in inherit insensitive insert instance intersect into language last lax least let levels lowercase map mod modify module most namespace no-inherit no-preserve node nodes no not occurs of option or order ordered ordering paragraph paragraphs phrase preserve processing-instruction relationship rename replace return revalidation same satisfies schema score scored sensitive sentence sentences skip some stable start stemming stop strict strip switch then times text thesaurus to treat try typeswitch union unordered updating uppercase using validate value variable version weight where group wildcards window with without word words xquery';
    var functions = 'zip:zip-file zip:xml-entry zip:update-entries zip:text-entry zip:html-entry zip:entries zip:binary-entry zero-or-one years-from-duration year-from-dateTime year-from-date xslt:version xslt:transform-text xslt:transform xslt:processor xquery:type xquery:invoke xquery:eval validate:xsd-info validate:xsd validate:dtd-info validate:dtd uri-collection upper-case unparsed-text-lines unparsed-text-available unparsed-text unordered true translate trace tokenize timezone-from-time timezone-from-dateTime timezone-from-date tail sum substring-before substring-after substring subsequence string-to-codepoints string-length string-join string static-base-uri starts-with sql:rollback sql:prepare sql:init sql:execute-prepared sql:execute sql:connect sql:commit sql:close serialize seconds-from-time seconds-from-duration seconds-from-dateTime round-half-to-even round root reverse resolve-uri resolve-QName repo:list repo:install repo:delete replace remove random:uuid random:seeded-integer random:seeded-double random:integer random:gaussian random:double QName put prof:time prof:sleep prof:mem prof:human prof:dump prof:current-ns prof:current-ms proc:system proc:execute prefix-from-QName position path partial-apply parse-xml-fragment parse-xml outermost out:tab out:nl out:format one-or-more number not normalize-unicode normalize-space node-name nilled namespace-uri-from-QName namespace-uri-for-prefix namespace-uri name months-from-duration month-from-dateTime month-from-date minutes-from-time minutes-from-duration minutes-from-dateTime min max math:tanh math:tan math:sqrt math:sinh math:sin math:pow math:pi math:log10 math:log math:exp10 math:exp math:e math:crc32 math:cosh math:cos math:atan2 math:atan math:asin math:acos matches map:size map:remove map:new map:keys map:get map:entry map:contains map:collation map-pairs map lower-case local-name-from-QName local-name last lang json:serialize-ml json:serialize json:parse-ml json:parse iri-to-uri insert-before innermost index:texts index:facets index:element-names index:attributes index:attribute-names index-of in-scope-prefixes implicit-timezone idref id http:send-request html:parser html:parse hours-from-time hours-from-duration hours-from-dateTime hof:until hof:top-k-with hof:top-k-by hof:sort-with hof:id hof:fold-left1 hof:const head hash:sha256 hash:sha1 hash:md5 hash:hash has-children generate-id function-name function-lookup function-arity ft:tokens ft:tokenize ft:search ft:score ft:mark ft:extract ft:count format-time format-number format-integer format-dateTime format-date fold-right fold-left floor filter file:write-text-lines file:write-text file:write-binary file:write file:size file:resolve-path file:read-text-lines file:read-text file:read-binary file:path-to-uri file:path-to-native file:path-separator file:move file:list file:line-separator file:last-modified file:is-file file:is-dir file:exists file:dir-separator file:dir-name file:delete file:create-dir file:copy file:base-name file:append-text-lines file:append-text file:append-binary file:append fetch:text fetch:content-type fetch:binary false exists exactly-one escape-html-uri error environment-variable ends-with encode-for-uri empty element-with-id document-uri doc-available doc distinct-values default-collation deep-equal-opt deep-equal db:text-range db:text db:system db:store db:retrieve db:replace db:rename db:output db:optimize db:open-pre db:open-id db:open db:node-pre db:node-id db:list-details db:list db:is-xml db:is-raw db:info db:fulltext db:flush db:exists db:event db:drop db:delete db:create db:content-type db:backups db:attribute-range db:attribute db:add days-from-duration day-from-dateTime day-from-date dateTime data current-time current-dateTime current-date crytpo:validate-signature crytpo:hmac crytpo:generate-signature crytpo:encrypt crytpo:decrypt count convert:string-to-hex convert:string-to-base64 convert:integer-to-dayTime convert:integer-to-dateTime convert:integer-to-base convert:integer-from-base convert:dayTime-to-integer convert:dateTime-to-integer convert:bytes-to-hex convert:bytes-to-base64 convert:binary-to-string convert:binary-to-bytes contains concat compare collection codepoints-to-string codepoint-equal client:query client:info client:execute client:connect client:close ceiling boolean base-uri avg available-environment-variables archive:update archive:options archive:extract-text archive:extract-binary archive:entries archive:delete archive:create analyze-string admin:users admin:sessions admin:logs adjust-time-to-timezone adjust-dateTime-to-timezone adjust-date-to-timezone abs fn:';
    var datatypes = 'xs:anyURI xs:base64Binary xs:boolean xs:byte xs:date xs:dateTime xs:decimal xs:double xs:duration xs:ENTITIES xs:ENTITY xs:float xs:gDay xs:gMonth xs:gMonthDay xs:gYear xs:gYearMonth xs:hexBinary xs:ID xs:IDREF xs:IDREFS xs:int xs:integer xs:language xs:long xs:Name xs:NCName xs:negativeInteger xs:NMTOKEN xs:NMTOKENS xs:nonNegativeInteger xs:nonPositiveInteger xs:normalizedString xs:NOTATION xs:positiveInteger xs:QName xs:short xs:string xs:time xs:token xs:unsignedByte xs:unsignedInt xs:unsignedLong xs:unsignedShort item';

    this.regexList = [
      { regex: /\(:[\s\S]*?:\)/gm, css: 'comments' }, // comments
      { regex: SyntaxHighlighter.regexLib.doubleQuotedString, css: 'string' },
      { regex: SyntaxHighlighter.regexLib.singleQuotedString, css: 'string' },
      { regex: /[\$%][\w-:]+/gm, css: 'variable' },
      { regex: new RegExp(this.getKeywords(keywords), 'gm'), css: 'keyword' },
      { regex: new RegExp(this.getKeywords(functions), 'gm'), css: 'functions' },
      { regex: new RegExp(this.getKeywords(datatypes), 'gm'), css: 'constants' }
    ];

    this.forHtmlScript(SyntaxHighlighter.regexLib.aspScriptTags);
  };

  Brush.prototype = new SyntaxHighlighter.Highlighter();
  Brush.aliases = ['xq', 'xquery'];

  SyntaxHighlighter.brushes.XQuery = Brush;

  // CommonJS
  typeof(exports) != 'undefined' ? exports.Brush = Brush : null;
})();