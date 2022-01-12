import 'dart:developer' as dev;
import 'dart:io';
import 'package:vm_service/vm_service.dart' show InstanceRef, VmService;
import 'package:vm_service/vm_service_io.dart' as vms;
import 'package:vm_service/utils.dart' as vmutils;

Future repl(VmService vmService) async {
  // Get currently running VM
  final vm = await vmService.getVM();
  final isolateRef = vm.isolates?.first;
  if (isolateRef == null) {
    throw Exception("unable to get reference to current Isolate");
  }
  final isolateId = isolateRef.id;
  if (isolateId == null) {
    throw Exception("unable to get ID for current Isolate");
  }
  final isolate = await vmService.getIsolate(isolateId);

  while (true) {
    stdout.write('>>> ');

    final input = stdin.readLineSync();
    if (input == null || input == 'exit()') {
      if (input == null) {
        stdout.write('\n');
      }
      break;
    }
    try {
      if (input.startsWith('var') || input.startsWith('import')) {
        final scratch = File('bin/scratchpad.dart');
        scratch.writeAsStringSync(input + '\n',
            mode: FileMode.append, flush: true);
        vmService.reloadSources(isolateId);
        print('reloaded');
      } else {
        final result = await vmService.evaluate(
            isolateId, isolate.rootLib?.id ?? '', input) as InstanceRef;
        final value = result.valueAsString;
        if (value != null) {
          print(value);
        }
      }
    } on Exception catch (errorRef) {
      print(errorRef);
    }
  }
  exit(0);
}

Future<VmService> getOwnVmService() async {
  // Observatory URL is like: http://127.0.0.1:8181/u31D8b3VvmM=/
  // Websocket endpoint for that will be: ws://127.0.0.1:8181/reBbXy32L6g=/ws
  final serverUri = (await dev.Service.getInfo()).serverUri;
  if (serverUri == null) {
    throw Exception('No VM service. Run with --enable-vm-service');
  }
  final wsUri = vmutils.convertToWebSocketUrl(serviceProtocolUrl: serverUri);

  // Get VM service
  return await vms.vmServiceConnectUri(wsUri.toString());
}
