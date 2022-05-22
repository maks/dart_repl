import 'dart:io';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:cli_repl/cli_repl.dart';
import 'package:repl/parser.dart';
import 'package:vm_service/vm_service.dart' show ErrorRef, InstanceRef, Isolate, VmService;

late final VmService vms;
late final String isolateId;
late final File scratch;

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

  scratch = File("bin/scratchpad.dart");
  if (!scratch.existsSync()) {
    throw InvalidPathResult();
  }
  scratch.writeAsStringSync('');

  final repl = Repl(prompt: '> ', continuation: '... ', validator: validator);

  for (final replInput in repl.run()) {
    if (replInput.trim().isNotEmpty) {
      await process(vmService, isolate, replInput);
    }
  }

  exit(0);
}

void reload() {
  vms.reloadSources(isolateId);
  print('reloaded');
}

Future<void> process(VmService vmService, Isolate isolate, String input) async {
  try {
    if (input.startsWith('print(')) {
      await vmService.evaluate(isolateId, isolate.rootLib?.id ?? '', input);
    } else if (input.startsWith('reload()')) {
      reload();
    } else {
      if (isStatement(input)) {
        scratch.writeAsStringSync(input + '\n', mode: FileMode.append, flush: true);
        vmService.reloadSources(isolateId);
        print('reloaded');
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

bool validator(String? input) {
  return true; //TODO actually validate the input
}
