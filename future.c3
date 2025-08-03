module futatic::future { Return };

alias PollFn = fn Result {Return} (void*);

struct FutureDyn 
{
  void* inner;
  PollFn poll_fn;
}

fn Result {Return} FutureDyn.poll(&self) 
{
  return self.poll_fn(self.inner);
}

<*
  @require $defined(($typeof(*future)){}.poll)
  @require $typeof(($typeof(*future)){}.poll().value).typeid == Return.typeid
*>
macro FutureDyn wrap_dyn(&future)
{
  return {
    .inner = (void*)future,
    .poll_fn = (PollFn)&($typeof(*future)).poll,
  };
}

struct Ready
{
    Return value;
}

fn Result {Return} Ready.poll(&self)
{
    return {
        .state = FINISHED,
        .value = self.value
    };
}

struct Never
{
    bool __ignore;
}

fn Result {Return} Never.poll(&self)
{
    return {
        .state = PENDING,
    };
}

