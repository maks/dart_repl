import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:cli_repl/cli_repl.dart';
import 'package:repl/parser.dart';
import 'package:vm_service/vm_service.dart' show ErrorRef, InstanceRef, Isolate, VmService;

late final VmService vms;
late final String isolateId;
late final File scratch;
late final File nextScratch;

const scratchPath = "bin/scratchpad.dart";
const nextPath = "bin/next.dart";

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

  scratch = File(scratchPath);
  if (!scratch.existsSync()) {
    throw InvalidPathResult();
  }
  nextScratch = File(nextPath);

  // clear out any previous code from previous sessions
  scratch.writeAsStringSync('');
  nextScratch.writeAsStringSync('');

  // unfortuntely Repl validator func can't be async so we need to handle validation ourselves when
  // we process possible statement inputs
  final repl = Repl(prompt: '> ', continuation: '... ', validator: null);

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
        // check for possible errors in newly added input
        final possibleError = await validator(input);
        if (possibleError != null) {
          print(possibleError);
        } else {
          vmService.reloadSources(isolateId);
          print('reloaded');
        }
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

Future<String?> validator(String input) async {
  await scratch.copy(nextPath);
  nextScratch.writeAsStringSync(input + '\n', mode: FileMode.append, flush: true);

  final collection = AnalysisContextCollection(
      includedPaths: [nextScratch.absolute.path], resourceProvider: PhysicalResourceProvider.INSTANCE);

  for (final context in collection.contexts) {
    for (final filePath in context.contextRoot.analyzedFiles()) {
      final errorsResult = await context.currentSession.getErrors(filePath);
      if (errorsResult is ErrorsResult) {
        for (final error in errorsResult.errors) {
          if (error.errorCode.type != ErrorType.TODO) {
            return error.message;
          }
        }
      }
    }
  }
  await nextScratch.copy(scratchPath);
  return null;
}
