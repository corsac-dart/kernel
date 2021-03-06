/// Testing utilities for Kernel.
library corsac_kernel.test;

import 'dart:async';

import 'package:corsac_kernel/corsac_kernel.dart';
import 'package:test/test.dart';

export 'package:corsac_kernel/corsac_kernel.dart';

Kernel _kernel;

void setUpKernel(Future<Kernel> buildKernel()) {
  setUp(() async {
    _kernel = await buildKernel();
  });

  tearDown(() {
    _kernel = null;
  });
}

kernelExecute(Function body) {
  var f = _kernel.execute(body);
  expect(f, completes);
}
