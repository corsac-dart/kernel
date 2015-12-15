library corsac_kernel.test.module_b;

import 'package:corsac_kernel/corsac_kernel.dart';
import 'package:corsac_di/di.dart' as di;

class ModuleB extends KernelModule {
  @override
  Map getServiceConfiguration(String environment) {
    return {ModuleBInterface: di.get(ModuleBService),};
  }
}

abstract class ModuleBInterface {}

class ModuleBService implements ModuleBInterface {}
