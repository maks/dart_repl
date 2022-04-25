import 'dart:developer' as dev;

import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart' as vms;
import 'package:vm_service/utils.dart' as vmutils;

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
