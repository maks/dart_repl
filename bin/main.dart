import 'dart:io';
import 'package:repl/repl.dart';
import 'package:repl/vm_service.dart';
import 'package:vm_service/vm_service.dart' show VmService;

import '/tmp/scratchpad.dart';

// Globals for easy access inside REPL
late final VmService vmService;

Future wrappedMain(List<String> args) async {
  print('Called with: ${args.join(' ')}'); // Replace by your current main code

  vmService = await getOwnVmService();
  final vm = await vmService.getVM();
  print(vm.version);
  print('Type `exit()` or Ctrl-d to quit.');

  await repl(vmService, '/tmp/scratchpad.dart');
}

const vmServiceWasEnabledArg = '--vm-service-was-enabled';

// Run again using Dart with vm service arg
// My thanks to Sigurd Meldgaard for this clever bit of code
// ref: https://github.com/dart-lang/pub/issues/3291#issuecomment-1019880145
void main(List<String> args) {
  if (args.isNotEmpty && args.first == vmServiceWasEnabledArg) {
    wrappedMain(args.skip(1).toList());
  } else {
    Process.start(
        Platform.executable,
        [
          '--enable-vm-service',
          Platform.script.toString(),
          vmServiceWasEnabledArg
        ],
        mode: ProcessStartMode.inheritStdio);
  }
}
