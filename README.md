# futatic.c3l

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

FUTATIC — is a C3 library with FUTures, that are stATICally typed!

*Heavily WIP, currently not intended for production use*

## About

futatic.c3l provides a compile-time futures abstraction for C3, enabling asynchronous programming patterns while maintaining static type safety and minimizing runtime overhead.

## Features

- Type-safe future/promise implementation
- Compile-time error checking
- Lightweight abstraction with minimal overhead

## Installation

1. Clone this repository inside your `lib` folder:
   ```4d
   git clone https://github.com/velikoss/futatic.c3l.git
   ```

2. Include the library in your C3 project by adding the project to your `manifest.json`:
   ```json
   "dependencies": [ "futatic" ]
   ```

## Creating Future

WIP, but there are some ways now:

- Using FutureDyn (Dynamic Future)
  
  ```r
  fn Result {Type} some_polling_fn (void* arg) {
    ...
  }
  
  FutureDyn {Type} future = {
    .poll_fn = &some_polling_fn;
    .inner = arg; // Pointer to arguments passed into poll function
  }

  future.poll();
  ```
  Also there is
  ```r
  FutureDyn {Type} future = future::wrap_dyn {Type} (&some_struct_var);
  ```
  Its used for structures with .poll(&self) method. Then when polling, the argument in function would be **self**

- Using structs
  
  Example structure for then passing into polling system (always returns FINISHED with value)
  ```r
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
  ```
## API
- Result { Return }
  
  This structure must be used for all futures poll returns. 
  ```c
  struct Result 
  {
      State  state;
      Return value;
  }
  ```
- macro select(...) *(from futatic::select)*
  
  This macro returns PairSelect {...} future.
  Because returning type is complex generic one, the only ways to store right now (as of 0.7.4 C3 version) is to:
  - Wrap function call into `wrap_dyn`
  - `$typeof(select::select {bool} (f1, f2, f3)) foo = select::select {bool} (f1, f2, f3);`<br>
    Which puts returning type as type on compile-time

  These ways are temporary and could be managed better with https://github.com/c3lang/c3c/issues/2336 (proposition in [c3's discord](https://discord.com/channels/650345951868747808/1398709064585842709))

## Automatic polling

WIP

## Example Usage

```r
import futatic;

fn int main()
{    
    Ready {bool} f1 = {.value = true};
    Ready {bool} f2 = {.value = true};
    Ready {bool} f3 = {.value = true};

    $typeof(select::select {bool} (f1, f2, f3)) boo = select::select {bool} (f1, f2, f3); // WIP

    Result {bool} result = boo.poll();
  
    return 0;
}
```

## Contributing

Contributions are welcome! Please open an issue or pull request for any bugs or feature requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
