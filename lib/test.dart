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

Future kernelExecute(body(Kernel kernel)) {
  return _kernel.execute(() {
    return body(_kernel);
  });
}
