# Corsac Dart generic Kernel library

[![Build Status](https://img.shields.io/travis-ci/corsac-dart/kernel.svg?branch=master&style=flat-square)](https://travis-ci.org/corsac-dart/kernel)
[![Coverage Status](https://img.shields.io/coveralls/corsac-dart/kernel.svg?branch=master&style=flat-square)](https://coveralls.io/github/corsac-dart/kernel?branch=master)
[![License](https://img.shields.io/badge/license-BSD--2-blue.svg?style=flat-square)](https://raw.githubusercontent.com/corsac-dart/kernel/master/LICENSE)

Kernel library built on top of Dart's library system.

* Enables dependency inversion via built-in DI container
 (see [Corsac DI](https://github.com/corsac-dart/di) for details).
* Provides simple module system based on Dart's built-in libraries.

Despite of how it sounds this is actually a very tiny library (current
  implementation is way less than 100 lines of code).

## 1. Reasoning

Regardless of the size of the project you are working on it is always
nice when it has some sort of structure.

Dart already makes it very clean by providing flexible system of composing
our code into set of libraries. And thanks to Pub we also have well-defined
folder structure.

Yet when projects grow it may become hard to manage structural complexity,
especially given there are a few pretty essential things that are not
covered by Dart's built-in features, like:

1. Project configuration, should it be a yaml file or environment variables
  or both? where should those live?
2. Large projects usually take advantage of dependency inversion via some kind
  of DI container framework. Containers usually require some configuration
  as well. Where should this go and what should the structure be?
3. Large project also tend to be split into smaller modules for cleaner
  structure and design.

This library tries to provide solution for (2) and (3) from the list above.

## 2. Features

### 2.1 Dependency inversion

Corsac Kernel is built on top of [DI container](https://github.com/corsac-dart/di).
Yet this library __does NOT__ provide dependency inversion by itself.
Instead it provides a foundation for implementing dependency inversion in
your own framework or project. Plus the Kernel's module system makes usage
of the DI container and it's configuration extensible.

For details on the DI container please visit official
[repository](https://github.com/corsac-dart/di).

### 2.2 Kernel module system

Module system of this library is actually very simple.

Basically any Dart `library` (defined with `library my_project;`) can be
registered as a module. Kernel itself is trying to make zero assumptions on
the contents of such library.

> Even though 1-to-1 relationship between modules and libraries is expected
> there is no technical restriction to this rule. Your library can register
> two or more modules if it wants.

The benefit of registering a library with the Kernel is that once it's
registered it can hook-in to Kernel via special interface and extend it.

There are only two extension points available at this point.

The first one enables modules to register their own service configurations with
the Kernel's DI container. See `KernelModule.getServiceConfiguration()`.

The other extension point enables module-specific initialization code to
be executed after Kernel is fully loaded and ready.
See `KernelModule.initialize()` for more details.

> Future versions may include more extension points..


Simple example of registering a module with it's own service configuration:

```dart
// file:lib/user_management.dart
library my_project.user_management;

import 'package:corsac_kernel/corsac_kernel.dart';
import 'package:corsac_di/corsac_di.dart';

// Kernel extension point. This class will be automatically discovered
// by the Kernel during initialization.
class UserManagementModule extends KernelModule {
  // Following configuration will be registered with the Kernel's
  // DI container.
  @override
  Map<dynamic, dynamic> getServiceConfiguration(String environment) {
    return {
      UserManager: DI.object()
        ..bindParameter('accessToken', DI.env('UM_ACCESS_TOKEN')),
    }
  }
}

// This is completely abstract class just to illustrate usage of module
// system and container configurations.
class UserManager {
  final String accessToken;
  UserManager(this.accessToken);

  User getUser(int id) {
    // implementation...
  }
}
```

And actual registration and usage:

```dart
// file:lib/my_project.dart
library my_project;

import 'package:corsac_kernel/corsac_kernel.dart';
import 'user_management.dart';

void main() async {
  var kernel = await Kernel.build('prod', {}, [
    new UserManagementModule(),
  ]);
  // accessToken will be injected into the UserManager instance from
  // the environment variable as defined in our configuration above.
  var manager = kernel.container.get(UserManager);
  manager.getUser(5); // do things...
}
```

Basically, Kernel becomes central point in your framework or project
responsible for assembling the whole project into one complete working
mechanism.

> The idea of using "modules" as a unit in Corsac Kernel is loosely based on
> concept of a "Module" in Domain driven design (Eric Evans). Therefore
> when designing your modules it's useful to keep in mind following guidelines:
>
> * Modules should tend to be fairly independent of each other. In real life
>   this can be very hard to achieve, but as a general rule - the less
>   dependencies you have between modules the better.
> * Modules must encapsulate particular part of the project's domain. Good
>   examples of module names include:
>   user management, security (authorization, authentication),
>   catalog, et cetera.

## License

BSD-2
