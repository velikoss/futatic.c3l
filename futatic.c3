module futatic { Return };

struct Ready
{
    Return value;
}

fn Result {Return} Ready.poll(&self, NoOpCtx _ctx)
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

fn Result {Return} Never.poll(&self, NoOpCtx _ctx)
{
    return {
        .state = PENDING,
    };
}

module futatic::result { Return };
import futatic;

struct Result
{
    types::State  state;
    Return value;
}