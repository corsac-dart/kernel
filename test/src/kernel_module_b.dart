library corsac_kernel.test.module_b;

import 'package:corsac_kernel/corsac_kernel.dart';
import 'package:corsac_di/corsac_di.dart';
import 'dart:async';

class ModuleB extends KernelModule {
  bool initialized = false;

  @override
  Map getServiceConfiguration(String environment) {
    return {ModuleBInterface: DI.get(ModuleBService),};
  }

  @override
  Future initialize(Kernel kernel) {
    initialized = true;
    return super.initialize(kernel);
  }
}

abstract class ModuleBInterface {}

class ModuleBService implements ModuleBInterface {}
