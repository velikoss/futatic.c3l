<*
  @require macros::is_future($typeof($typeof((FutureInner).poll).paramsof[1]))
*>
module futatic::future { FutureInner };
import futatic;

FutureInner inner_dummy;

alias ReturnType = $typeof(inner_dummy.poll()); 
alias Fn = $typeof((FutureInner).poll); 
alias Ctx = $typeof($typeof((FutureInner).poll).paramsof[1]);

struct Future
{
    inline FutureInner inner;
}

macro Future.poll(&self, Ctx ctx) 
{
    ReturnType result = self.inner.poll();
    return result;
}

<*
  @require $defined($typefrom($typeof(x).returns).poll)
*>
macro Future.then(&self, x)
{
    var $SecondFuture = $typefrom($typeof(x).returns);
    var $Then = Then {FutureInner, $SecondFuture};
    Future {$Then} ret;
    ret.first_pending.first = self.inner;
    ret.first_pending.then  = ($typeof(ret.first_pending.then)) x;
    return ret;
}

//<*
    //@require macros::is_future()
//*>
module futatic::future::then {FirstFuture, SecondFuture, Ctx};

alias FirstResult = $typefrom($typeof((FirstFuture).poll).returns); 
alias FirstResultValue = $typeof((FirstResult){}.value); 
alias SecondResult = $typefrom($typeof((SecondFuture).poll).returns); 
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