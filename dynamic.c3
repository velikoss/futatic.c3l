<*
* Dynamic Future Creation
*>
module futatic::future::dyn { Return };

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
macro Future {FutureDyn} wrap_dyn(&future)
{
  return (Future {FutureDyn}) {
    .inner = (void*)future,
    .poll_fn = (PollFn)&($typeof(*future)).poll,
  };
}
