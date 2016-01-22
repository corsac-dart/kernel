library corsac_kernel.tests.test_utilities;

import 'package:test/test.dart';
import 'package:corsac_kernel/corsac_kernel.dart';
import 'package:corsac_kernel/test.dart';

import 'src/kernel_module_a.dart';
import 'src/kernel_module_b.dart';
import 'dart:async';

void main() {
  group('TestUtilities:', () {
    setUpKernel(() {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      return Kernel.build('test', {}, modules);
    });

    test('it executes a task', () {
      kernelExecute((Kernel kernel) {
        expect(kernel, new isInstanceOf<Kernel>());
      });
    });

    test('it executes a task with an error', () {
      kernelExecute((Kernel kernel) {
        var fu = () {
          throw 'Task error';
        };
        expect(fu, throwsA('Task error'));
      });
    });

    test('it executes a task with an async error', () {
      kernelExecute((Kernel kernel) {
        var fu = () async {
          return new Future.delayed(new Duration(milliseconds: 200), () {
            throw 'Task error';
          });
        };

        expect(fu(), throwsA('Task error'));
      });
    });
  });
}
