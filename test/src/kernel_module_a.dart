library corsac_kernel.test.module_a;

import 'package:corsac_kernel/corsac_kernel.dart';

class ModuleAService {}

class ModuleA extends KernelModule {
  bool initialized = false;
  @override
  void initialize(Kernel kernel) {
    initialized = true;
  }
}
