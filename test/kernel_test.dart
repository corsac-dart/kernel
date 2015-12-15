library corsac_kernel.test.kernel;

import 'package:test/test.dart';
import 'package:corsac_kernel/corsac_kernel.dart';

import 'src/kernel_module_a.dart';
import 'src/kernel_module_b.dart';

void main() {
  group('Kernel:', () {
    test('it registers service configuration for modules', () {
      var kernel = new Kernel('test', {}, [
        new Symbol('corsac_kernel.test.module_a'),
        new Symbol('corsac_kernel.test.module_b'),
      ]);

      expect(kernel.container.get(ModuleAService),
          new isInstanceOf<ModuleAService>());
      var service = kernel.container.get(ModuleBInterface);
      expect(service, new isInstanceOf<ModuleBService>());
    });
  });
}
