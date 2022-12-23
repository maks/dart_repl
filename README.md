# A REPL for Dart.

# This package is no longer being maintained. Please see [https://pub.dev/packages/interactive](https://pub.dev/packages/interactive) for a more full featured and ready to use REPL for Dart.


## Prior art

Based on early version of [a proof of concept REPL environment for Dart](https://github.com/BlackHC/dart_repl/) from [a pair of articles by Andreas Kirsch](https://medium.com/dartlang/evolving-dart-repl-poc-233440a35e1f) and an example in the [Dart SDK tests](
https://github.com/dart-lang/sdk/blob/master/pkg/vm_service/example/vm_service_tester.dart) 
and the [recharge package](https://github.com/ajinasokan/recharge)

## Features

* [X] MVP with expression evaluation
* [X] Use code from BlackHC's work to parse input for statements vs expressions
* [X] Use `cli_repl` for better repl ergonomics
* [X] Use standard `pub activate` for package to run its binary instead of shell script
* [X] Improve usage documentation
* [X] Use hotreload with a scratchpad file
* [ ] ?? Support built in package imports
* [ ] ?? Support arbitrary package imports
* [ ] ?? Use scratchpad with dedicated Isolate

?? - not clear if this is a workable approach

## Usage

To install the repl use:
```
dart pub global activate repl
```

Then as long as the pub system cache is on your path you can run it using: `drepl`

### Supported features

You can currently use expressions and statements as well as a few built-in's are supported (see below), its already possible to do a few useful things with the REPL.

For instance you can do JS style IIFE's:
```dart
> (){final data = ['this', 'is', 'a', 'test']; for(int i = 0; i < data.length; i++) print(data[i]); }()
```

But of course that is a bit contrived an example as you could also do:
```dart
> ['this', 'is', 'a', 'test'].forEach((x) => print(x))
```

Some statements are also possible, eg.

```dart
> int sqr(int a) => a*a;

> sqr(5)
> 25
```


#### Built-in's

`print()` - print to output
`reload()` - trigger a hot-reload (doesn't work well at the moment)

#### Editing, History, Shortcuts

see the [cli_repl package documentation for supported short-cut keys](https://pub.dev/packages/cli_repl#navigation).


## Development

Clone this repo, then from the top level of this repo and then run using: 
```
dart bin/main.dart
```

## Future plans

A more powerful though much more involved implmentation route would be to use the [Dart embedding API](https://github.com/dart-lang/sdk/blob/main/runtime/include/dart_api.h), perhaps via FFI to avoid needing to deal with too much c/c++ dev, assuming its possible for DartVM to call into itself via FFI using the embedding api?

## Contributing

All contributions: PRs, bug reports, feature requests, documentation are most welcome.

Contribution guidelines: TODO.