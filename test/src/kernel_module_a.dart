library corsac_kernel.test.module_a;

import 'package:corsac_kernel/corsac_kernel.dart';
import 'dart:async';

class ModuleAService {}

class ModuleA extends KernelModule {
  bool initialized = false;
  @override
  Future initialize(Kernel kernel) {
    initialized = true;
    return super.initialize(kernel);
  }

  @override
  Map initializeTask(Kernel kernel) => {#identityMap: new Map()};
}
