# A REPL for Dart.

## Prior art

Based on early version of [a proof of concept REPL environment for Dart](https://github.com/BlackHC/dart_repl/) from [a pair of articles by Andreas Kirsch](https://medium.com/dartlang/evolving-dart-repl-poc-233440a35e1f) and an example in the [Dart SDK tests](
https://github.com/dart-lang/sdk/blob/master/pkg/vm_service/example/vm_service_tester.dart) 
and the [recharge package](https://github.com/ajinasokan/recharge)

## Features

* [X] MVP with expression evaluation
* [ ] Use code from BlackHC's work to parse input for statements vs expressions
* [ ] Support built in package imports
* [ ] Support arbitrary package imports
* [ ] Use hotreload with a scratchpad file
* [ ] Use scratchpad with dedicated Isolate
* [ ] Use `cli_repl` for better repl ergonomics
* [ ] Use standard `pub activate` for package to run its binary instead of shell script
* [ ] Improve usage documentation

## Usage

Clone this repo, then from the top level of this repo, run the bash shell script: `bin\dartr`


## Future plans

A more powerful though much more involved implmentation route would be to use the [Dart embedding API](https://github.com/dart-lang/sdk/blob/main/runtime/include/dart_api.h), perhaps via FFI to avoid needing to deal with too much c/c++ dev, assuming its possible for DartVM to call into itself via FFI using the embedding api?

## Contributing

All contributions: PRs, bug reports, feature requests, documentation are most welcome.

Contribution guidelines: TODO.