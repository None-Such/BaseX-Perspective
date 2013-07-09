declare variable $containerSetStart external := -1;
declare variable $containerSetCount external := 1;
declare variable $containerSetEnd   := number($containerSetStart) + number($containerSetCount);

db:output($containerSetEnd)