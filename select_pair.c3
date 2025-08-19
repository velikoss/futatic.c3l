<*
@require macros::is_future(Left, Return, LeftFn.paramsof[1].type)
@require macros::is_future(Right, Return, RightFn.paramsof[1].type)
*>
module futatic::select::pair {Left, Right, Return};
import futatic::macros;
import futatic::result;

alias LeftFn = $typeof((Left).poll);
alias LeftCtx = $typefrom(LeftFn.paramsof[1].type);
alias RightFn = $typeof((Right).poll);
alias RightCtx = $typefrom(RightFn.paramsof[1].type);

struct PairSelect
{
    Left  left;
    Right right;
}

fn Result {Return} PairSelect.poll(&self, any ctx = null)
{
    Result {Return} res = self.left.poll((LeftCtx) ctx);
    if (res.state == FINISHED) return res;
    return self.right.poll((RightCtx) ctx);
}