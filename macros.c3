module futatic::macros;
import futatic;
import std::io;

macro bool is_future($FutType, $Return, $Ctx) @const
{
    $FutType $val;

    $if !$defined($val.poll):
        $echo "False";
        return false;
    $else
    

    var $ret = @assignable_to($val.poll(($Ctx){}), Result{$Return});
    $if !$ret:
        $echo $FutType.qnameof;
        $echo $typeof($val.poll(($Ctx){})).qnameof;
        $echo Result{$Return}.qnameof;
        $echo "Non assignable";
    $endif
    
    return $ret;

    $endif
}

<*
  @require $vacount >= 1 : "Should provide at least two futures in select"
*>
macro bool are_futures($Return, ...)
{
    $for var $i = 0; $i < $vacount; $i++:
        var $FutType = $typeof($vaarg[$i]);
        var $PollFn = $typeof($FutType.poll);
        $if !is_future($FutType, $Return, $PollFn.paramsof[1].type):
            return false;
        $endif
    $endfor
    return true;
}

macro wrap_future(x)
{
	return (Future {$typeof(x)}) {.inner = x};
}

macro ready($Ctx, ret) 
{
    return wrap_future((Ready {$typeof(ret)}) {
        .value = ret,
    });
}

macro never($Ctx, $Return) 
{
    return wrap_future((Never {$Type}) {});
}

macro block_on(fut) 
{
    var res = fut.poll();
    while (res.state != FINISHED) {
        res = fut.poll();
    }
    
    return res.value;
}

module futatic::macros::test;

fn void wrap_future() @test 
{
    test::eq(test_wrap_future(), true);
}

macro test_wrap_future() {
    var fut = (Ready {int}) {
        .value = 42,
    };
    return macros::is_future(int, $typeof(macros::wrap_future(fut)));
}

fn void is_future() @test 
{
    test::eq(test_is_future(), true);
}

macro bool test_is_future() 
{
    var fut = macros::ready(1);
    return macros::is_future(int, $typeof(fut));
}

fn void are_futures() @test 
{
    test::eq(test_are_futures(), true);
}

macro bool test_are_futures() 
{
    var fut1 = macros::ready(1);
    var fut2 = macros::never(int);
    var fut3 = macros::ready(1);
    
    return macros::are_futures(int, fut1, fut2, fut3);    
}
