library corsac_kernel.tests.kernel;

import 'package:test/test.dart';
import 'package:corsac_kernel/corsac_kernel.dart';

import 'src/kernel_module_a.dart';
import 'src/kernel_module_b.dart';
import 'dart:async';

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

    test('it executes a transaction', () async {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      var kernel = await Kernel.build('test', {}, modules);
      var isExecuted = false;
      kernel.execute(() {
        isExecuted = true;
      });
      expect(isExecuted, isTrue);
    });

    test('it does not share state between transaction', () async {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      var kernel = await Kernel.build('test', {}, modules);
      kernel.execute(() async {
        Map state = Zone.current[#identityMap];
        state['test1'] = 'unique-value';
        expect(state, isNot(containsPair('test2', 'unique-value2')));
      });

      kernel.execute(() async {
        Map state = Zone.current[#identityMap];
        state['test2'] = 'unique-value';
        expect(state, isNot(containsPair('test1', 'unique-value')));
      });
    });
  });
}
