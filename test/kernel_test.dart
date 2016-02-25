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

    test('it executes a task', () async {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      var kernel = await Kernel.build('test', {}, modules);
      var isExecuted = false;
      kernel.execute(() {
        isExecuted = true;
      });
      expect(isExecuted, isTrue);
    });

    test('it does not share state between tasks', () async {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      var kernel = await Kernel.build('test', {}, modules);
      kernel.execute(() {
        Map state = Zone.current[#identityMap];
        state['test1'] = 'unique-value';
        expect(state, isNot(containsPair('test2', 'unique-value2')));
      });

      kernel.execute(() {
        Map state = Zone.current[#identityMap];
        state['test2'] = 'unique-value';
        expect(state, isNot(containsPair('test1', 'unique-value')));
      });
    });

    test('it registers itself with the DI container', () async {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      var kernel = await Kernel.build('test', {}, modules);
      expect(kernel.get(Kernel), same(kernel));
    });

    test('it forwards finalizeTask errors to returned future', () async {
      List<KernelModule> modules = [new ModuleC()];
      var kernel = await Kernel.build('test', {}, modules);
      expect(kernel.execute(() {}), throwsA('Finalize error'));
    });

    test('it forwards initializeTask errors to returned future', () async {
      List<KernelModule> modules = [new ModuleD()];
      var kernel = await Kernel.build('test', {}, modules);
      expect(kernel.execute(() {}), throwsA('Initialize task error'));
    });

    test('it forwards sync task errors to returned future', () async {
      List<KernelModule> modules = [new ModuleA()];
      var kernel = await Kernel.build('test', {}, modules);
      expect(kernel.execute(() {
        throw 'Task error';
      }), throwsA('Task error'));
    });

    test('it forwards async task errors to returned future', () async {
      List<KernelModule> modules = [new ModuleA()];
      var kernel = await Kernel.build('test', {}, modules);
      expect(kernel.execute(() {
        return new Future.error('Async task error');
      }), throwsA('Async task error'));
    });

    test('it resolves task parameters', () async {
      List<KernelModule> modules = [new ModuleA()];
      var kernel = await Kernel.build('test', {}, modules);
      kernel.execute((Kernel actual, ExampleService service) {
        expect(actual, same(kernel));
        expect(service, new isInstanceOf<ExampleService>());
      });
    });
  });
}

class ExampleService {}

class ModuleC extends KernelModule {
  @override
  Future finalizeTask(Kernel kernel) {
    throw 'Finalize error';
  }
}

class ModuleD extends KernelModule {
  @override
  Map initializeTask(Kernel kernel) {
    throw 'Initialize task error';
  }
}
