library corsac_kernel.tests.test_utilities;

import 'package:test/test.dart';
import 'package:corsac_kernel/corsac_kernel.dart';
import 'package:corsac_kernel/test.dart';

import 'src/kernel_module_a.dart';
import 'src/kernel_module_b.dart';

void main() {
  group('TestUtilities:', () {
    setUpKernel(() {
      List<KernelModule> modules = [new ModuleA(), new ModuleB()];
      return Kernel.build('test', {}, modules);
    });

    test('it executes a transaction', () {
      transaction((Kernel kernel) {
        expect(kernel, new isInstanceOf<Kernel>());
      });
    });

    test('it executes a transaction with error', () {
      transaction((Kernel kernel) {
        var fu = () {
          throw new ArgumentError();
        };
        expect(fu, throwsArgumentError);
      });
    });
  });
}
