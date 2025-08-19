module futatic::macros;
import futatic;
import std::io;

macro bool is_future($FutType) @const
{
    $echo $FutType.qnameof;

    $FutType $val;

    $if !$defined($val.poll):
        return false;
    $else
    
    $echo $typeof($val.poll());

    return @assignable_to($val.poll(), Result{$Return});

    $endif
}

<*
  @require $vacount >= 1 : "Should provide at least two futures in select"
*>
macro bool are_futures($Return, $Ctx, ...)
{
    $for var $i = 0; $i < $vacount; $i++:
        $if !is_future($Return, $Ctx, $typeof($vaarg[$i])):
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
    return wrap_future((Ready {$typeof(ret), $Ctx}) {
        .value = ret,
    });
}

macro never($Ctx, $Return) 
{
    return wrap_future((Never {$Type, $Ctx}) {});
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
