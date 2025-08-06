module futatic::macros;
import futatic;
import std::io;

macro ready(value) 
{
    return (Ready {$typeof(value)}) {
        .value = value
    };
}

macro never($Type = bool) 
{
    return (Never {$Type}) {};
}

<*
 @param [in] arg
 @require $defined(#x(arg))
*>
macro @future(#x, arg, $null_is_finished = false) 
{
    var $x = #x;
    var $Type = $typeof($x(arg));
    var $Arg = $typeof(arg);
    $switch $Type.kindof:
        $case POINTER:
            return (FutureDyn {$Type}) {
                .inner = arg,
                .poll_fn = fn Result {($Type)} (void* arg) {
                    $echo($x(arg));
                    $Type result = null;
$if $null_is_finished:
                    State state = result == null ? PENDING : FINISHED;
$else
                    State state = result == null ? FINISHED : PENDING;
$endif
                    return {
                        .state = state,
                        .value = result
                    };
                },
            };
        $case STRUCT:
            $if $defined($Type.state) &&& $defined($Type.value):
                return (FutureDyn {$typeof(($Type){}.value)}) {
                    .inner = (void*)arg,
                    .poll_fn = (PollFn{$typeof(($Type){}.value)}) $x,
                };
            $endif
        $default:
            io::printn($x(arg));
            return (FutureDyn {$Type}) {
                .inner = (void*) arg,
                .poll_fn = fn Result {($Type)} (void* arg) {
                    io::printn($x);
                    // $Type value = ($Type)$x(($Arg)arg);
                    return {
                        .state = FINISHED,
                        .value = ($Type){} 
                    };
                },
            };
    $endswitch
}