library corsac_kernel.test.kernel;

import 'package:test/test.dart';
import 'package:corsac_kernel/corsac_kernel.dart';

import 'src/kernel_module_a.dart';
import 'src/kernel_module_b.dart';

void main() {
  group('Kernel:', () {
    test('it registers service configuration for modules', () async {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      var kernel = await Kernel.build('test', {}, modules);

      expect(kernel.container.get(ModuleAService),
          new isInstanceOf<ModuleAService>());
      var service = kernel.container.get(ModuleBInterface);
      expect(service, new isInstanceOf<ModuleBService>());
    });

    test('it calls module initialization hooks', () async {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      await Kernel.build('test', {}, modules);
      expect((modules.first as ModuleA).initialized, isTrue);
      expect((modules.last as ModuleB).initialized, isTrue);
    });
  });
}
