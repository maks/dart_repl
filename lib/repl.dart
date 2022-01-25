import 'dart:io';
import 'package:repl/parser.dart';
import 'package:vm_service/vm_service.dart' show InstanceRef, VmService;

late final VmService vms;
late final String isolateId;

Future repl(VmService vmService, String scratchPath) async {
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

  final scratch = File(scratchPath);
  scratch.writeAsStringSync('');

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
      if (input.startsWith('import')) {
        final existing = scratch.readAsStringSync();
        scratch.writeAsStringSync(input + '\n' + existing,
            mode: FileMode.write, flush: true);
        reload();
      } else if (input.startsWith('print(') || input.startsWith('reload(')) {
        await vmService.evaluate(isolateId, isolate.rootLib?.id ?? '', input)
            as InstanceRef;
      } else {
        if (isStatement(input)) {
          scratch.writeAsStringSync(input + '\n',
              mode: FileMode.append, flush: true);
          vmService.reloadSources(isolateId);
          print('reloaded');
        } else if (isExpression(input)) {
          final result = await vmService.evaluate(
              isolateId, isolate.rootLib?.id ?? '', input) as InstanceRef;
          final value = result.valueAsString;
          if (value != null) {
            print(value);
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
