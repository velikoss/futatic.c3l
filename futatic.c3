module futatic { Return };
struct Result 
{
    State  state;
    Return value;
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