library corsac_kernel.test.module_b;

import 'package:corsac_kernel/corsac_kernel.dart';
import 'package:corsac_di/corsac_di.dart';

class ModuleB extends KernelModule {
  bool initialized = false;

  @override
  Map getServiceConfiguration(String environment) {
    return {ModuleBInterface: DI.get(ModuleBService),};
  }

  @override
  void initialize(Kernel kernel) {
    initialized = true;
  }
}

abstract class ModuleBInterface {}

class ModuleBService implements ModuleBInterface {}
