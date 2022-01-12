import 'package:repl/dart_repl.dart';
import 'package:vm_service/vm_service.dart' show VmService;

// Globals for easy access inside REPL
late final VmService vmService;

// MUST be run with: "dart --enable-vm-service"

Future main(List<String> args) async {
  vmService = await getOwnVmService();
  final vm = await vmService.getVM();
  print(vm.version);
  print('Type `exit()` to quit.');

  await repl(vmService);
}
