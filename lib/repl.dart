import 'dart:io';
import 'package:repl/parser.dart';
import 'package:vm_service/vm_service.dart' show ErrorRef, InstanceRef, VmService;

late final VmService vms;
late final String isolateId;

Future repl(VmService vmService) async {
  // Get currently running VM
  vms = vmService;
  final vm = await vmService.getVM();
  final isolateRef = vm.isolates?.first;
  if (isolateRef == null) {
    throw Exception("unable to get reference to current Isolate");
  }
  if (isolateRef.id == null) {
    throw Exception("unable to get ID for current Isolate");
  }
  isolateId = isolateRef.id!;

  final isolate = await vmService.getIsolate(isolateId);

  while (true) {
    stdout.write('> ');

    final input = stdin.readLineSync();
    if (input == null || input == 'exit()') {
      if (input == null) {
        stdout.write('\n');
      }
      break;
    }
    try {
      if (input.startsWith('print(')) {
        await vmService.evaluate(isolateId, isolate.rootLib?.id ?? '', input);
      } else if (input.startsWith('reload()')) {
        reload();
      } else {
        if (isStatement(input)) {
          print('Statements are not yet supported');
        } else if (isExpression(input)) {
          final result = await vmService.evaluate(isolateId, isolate.rootLib?.id ?? '', input);
          if (result is InstanceRef) {
            final value = result.valueAsString;
            if (value != null) {
              print(value);
            }
          } else if (result is ErrorRef) {
            print('error: $result');
          } else {
            print('unknown error');
          }
        } else {
          print('not recognised: $input');
        }
      }
    } on Exception catch (errorRef) {
      print(errorRef);
    }
  }
  exit(0);
}

void reload() {
  vms.reloadSources(isolateId);
  print('reloaded');
}
