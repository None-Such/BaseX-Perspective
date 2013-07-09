
declare namespace sxx = "http://www.SoundExchange/ns/xquery/util";

declare variable $containerDB := 'Release-Canonicals-Intrinsic';

declare variable $delim := '&#9680;'; (: ¶ paragraph symbol OR ◐ %E2%97%90 U+25D0   Circle with left half black :)
declare variable $encap := '&#9664;'; (: « Left double angle quotes ◀ %E2%97%80 U+25C0   Black left-pointing triangle :)

declare variable $match-regex := '[' || $delim || $encap || ']';

db:open($containerDB)[exists(//text()[matches(.,$match-regex)])]