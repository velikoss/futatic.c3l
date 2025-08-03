module futatic::select {Return};
import futatic::future;
import std::io;

<*
  @require $vacount >= 1 : "Should provide at least two futures in select"
*>
macro bool @check_futures(...)
{
    $for var $i = 0; $i < $vacount; $i++:
        $if (!$defined($vaarg[$i].poll()) ||| $typeof($vaarg[$i].poll().value).typeid != Return.typeid):
            return false;
        $endif
    $endfor
    return true;
}

<*
  @require $vacount >= 1 : "Should provide at least two futures in select"
  @require @check_futures($vasplat)
*>
macro select(...)
{   
    $if $vacount == 1: 
        return $vaarg[0];
    $else

    usz $mid = ($vacount - 1) >> 1;
    var left = select($vasplat[..$mid]);
    var right = select($vasplat[$mid+1..]);

    var res = (PairSelect {$typeof(left), $typeof(right), Return}){
        .left = left,
        .right = right,
    };

    return res;

    $endif
}

