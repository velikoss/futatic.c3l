<*
  @require macros::is_future(FutureInner, ReturnTypeValue, Ctx)
*>
module futatic::future { FutureInner };
import futatic;
 
FutureInner inner_dummy;

alias Fn @private = $typeof((FutureInner).poll); 
alias Ctx @if($defined(Fn.paramsof)) @private = $typefrom(Fn.paramsof[1].type);
alias Ctx @if(!$defined(Fn.paramsof)) @private = NoOpCtx;
alias ReturnType @if($defined(Fn.paramsof)) @private = $typefrom(Fn.returns); 
alias ReturnType @if(!$defined(Fn.paramsof)) @private = $typeof(inner_dummy.poll((Ctx) {})); 
alias ReturnTypeValue @private = $typeof(((ReturnType) {}).value); 

struct Future
{
    inline FutureInner inner;
}

macro Future.poll(&self, Ctx ctx = (Ctx) {}) 
{
    ReturnType result = self.inner.poll(ctx);
    return result;
}

<*
  @require $defined($typefrom($typeof(x).returns).poll)
*>
macro Future.then(&self, x)
{
    var $SecondFuture = $typefrom($typeof(x).returns);
    var $Then = Then {FutureInner, $SecondFuture, Ctx};
    Future {$Then} ret;
    ret.first_pending.first = self.inner;
    ret.first_pending.then  = ($typeof(ret.first_pending.then)) x;
    return ret;
}

// <*
// @require macros::is_future(FirstFuture, FirstResult, FirstPoll.paramsof[1].type)
// @require macros::is_future(SecondFuture, SecondResult, SecondPoll.paramsof[1].type)
// *>
module futatic::future::then {FirstFuture, SecondFuture, Ctx};
import futatic::macros;

alias FirstPoll = $typeof((FirstFuture).poll);
alias FirstResult = $typefrom(FirstPoll.returns); 
alias FirstResultValue = $typeof((FirstResult){}.value); 
alias SecondPoll = $typeof((SecondFuture).poll); 
alias SecondResult = $typefrom(SecondPoll.returns); 
alias ThenFn = fn SecondFuture (FirstResultValue);

enum ThenState 
{
    FIRST_PENDING,
    SECOND_PENDING
}

union ThenInner
{
    struct first_pending 
    {
        FirstFuture first;
        ThenFn then;
    }
    SecondFuture second_pending;
}

struct Then
{
    inline ThenInner inner;
    ThenState state;
}

macro Then.poll(&self, Ctx ctx)
{
    switch (self.state) {
    case FIRST_PENDING:
        FirstResult res = self.first_pending.first.poll(ctx);
        if (res.state == FINISHED) {
            self.second_pending = self.first_pending.then(res.value);
            self.state = SECOND_PENDING;
        }
        return (SecondResult) {.state = PENDING};
    case SECOND_PENDING:
        return self.second_pending.poll(ctx);
    }
}