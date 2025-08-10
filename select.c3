module futatic::select {Return};
import futatic;
import std::io;

<*
  @require $vacount >= 1 : "Should provide at least one future in select"
  @require macros::@are_futures(Return, $vasplat)
*>
macro select(...)
{   
    $if $vacount == 1: 
        return $vaarg[0];
    $else

    // Make pair-tree look more like a linked list (leaning to the right) so
    // when polling (starting from the left descendant) we will do only one
    // more step for every unsuccessfully polled future
    var left = $vaarg[0];
    var right = select($vasplat[1..]);

    var res = (PairSelect {$typeof(left), $typeof(right), Return}){
        .left = left,
        .right = right,
    };

    return res;

    $endif
}

