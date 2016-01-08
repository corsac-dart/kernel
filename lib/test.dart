/// Testing utilities for Kernel.
library corsac_kernel.test;

import 'package:test/test.dart';
import 'package:corsac_kernel/corsac_kernel.dart';
import 'dart:async';

Kernel _kernel;

void setUpKernel(Future<Kernel> createKernel()) {
  setUp(() async {
    _kernel = await createKernel();
  });

  tearDown(() {
    _kernel = null;
  });
}

Future transaction(body(Kernel kernel)) {
  return _kernel.execute(() {
    return body(_kernel);
  });
}
