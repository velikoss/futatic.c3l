<*
@require macros::@is_future(Return, Left)
@require macros::@is_future(Return, Right)
*>
module futatic::select::pair {Left, Right, Return};
import futatic::macros;

struct PairSelect
{
    Left  left;
    Right right;
}

fn Result {Return} PairSelect.poll(&self)
{
    Result {Return} res = self.left.poll();
    if (res.state == FINISHED) return res;
    return self.right.poll();
}