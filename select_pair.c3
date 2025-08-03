<*
@require $defined((Left){}.poll)
@require $defined((Right){}.poll)
@require $typeof((Left){}.poll().value).typeid == Return.typeid
@require $typeof((Right){}.poll().value).typeid == Return.typeid
*>
module futatic::select::pair {Left, Right, Return};

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

