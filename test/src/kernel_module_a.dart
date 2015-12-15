library corsac_kernel.test.module_a;

import 'package:corsac_kernel/corsac_kernel.dart';

class ModuleAService {}

class ModuleA implements KernelModule {
  @override
  Map getServiceConfiguration(String environment) {
    return {};
  }
}
