# Generic Kernel for server-side applications

[![Build Status](https://img.shields.io/travis-ci/corsac-dart/kernel.svg?branch=master&style=flat-square)](https://travis-ci.org/corsac-dart/kernel)
[![Coverage Status](https://img.shields.io/coveralls/corsac-dart/kernel.svg?branch=master&style=flat-square)](https://coveralls.io/github/corsac-dart/kernel?branch=master)
[![License](https://img.shields.io/badge/license-BSD--2-blue.svg?style=flat-square)](https://raw.githubusercontent.com/corsac-dart/kernel/master/LICENSE)

Corsac Kernel has 3 major goals:

1. Provide module-based system to structure and organize applications.
2. Provide a way to execute application tasks in an isolated scope.
3. Provide foundation for writing applications with Dependency Inversion in
  mind.

This library is also designed to be fairly lightweight so that it's' easy to
get started and scale when needed.

## 1. Introduction / Why

All applications of somewhat significant complexity tend to have a central
component which is responsible for assembling the app.

Such a component is usually responsible for things like project configuration,
folder structure, splitting the app into a set of logical modules, extensibility
(via plugins, extensions or hooks), etc.

Pretty much common and pragmatic way of achieving this is to rely on a
general-purpose framework which usually has all the required functions in place.
There are benefits to this approach:

* No need to invent your own conventions for many common tasks like
  configuration and modularization of the app. Frameworks usually provide
  their own way of doing that.
* Applications usually have a "frontend" (Web Client or HTTP API) which
  means a specific framework will be used anyway. Decision on
  using such a framework, transitively means using this framework's way to structure your project.
* You can get many things for free just by using a very popular framework.

There are also downsides to this approach.

Frameworks are usually made to solve a particular problem, like, build a web
application, or a REST API application. As a result such frameworks are
usually structured in a way specific to that problem. For instance, web
frameworks tend to have __Model-View-Controller__-oriented structure. This
 enforces some limitations on how one would structure the project and
also makes it tightly coupled to the framework's architecture.

Each framework also defines it's own "unit-of-work" (or "task", or
"application transaction"). For web frameworks it's obviously
handling of an HTTP request, for a CLI framework this can be a particular
user input structured as a set of command-line arguments (but not
necessarily). As a result there are multiple definitions of what is
considered a single transaction and makes application's life cycle dependent
on that of the framework.

Corsac Kernel tries to reverse the situation and provide a way to structure
applications in a generic fashion without overhead of a framework oriented to
solve particular (narrow) set of problems (be it HTTP, CLI or anything else).

## 2. How

Simplest way to create a kernel:

```dart
var environment = 'prod';
var parameters = {};
var modules = [];
var kernel = await Kernel.build(environment, parameters, modules);
```

We didn't do much here but there are a couple things to note.

The `environment` parameter defines where 'physically' the application is
executing. This value is not restricted in any way, but common examples usually
include `dev`, `local`, `test`, `qa`, `ci`, `prod` and so forth.

Based on the environment setting applications can alter their behavior.

For instance, if application depends on some external service which makes
it hard to run the test suite, one can configure the app to use "stub"
implementation for this external service in the `test` environment.

The `parameters` map is specific to the project and usually contains project's
configuration loaded from a file like `parameters.yaml` or `config.json`.

The `modules` list should contain objects implementing `KernelModule`
interface. Since we didn't define any modules this list is empty.

## 3. Modules

Main purpose of modules is to make it possible to split big application into
a set of small logical pieces which makes it easier to maintain and extend.

As added benefit modules can also hook in to certain kernel's lifecycle
events.

Here is interface provided by `KernelModule`:

```dart
abstract class KernelModule {
  Map getServiceConfiguration(String environment);
  Future initialize(Kernel kernel);
  Map initializeTask(Kernel kernel);
  Future finalizeTask(Kernel);
}
```

### 3.1 Module service configuration

The `Kernel` itself is built on top of a DI container. Specifically container provided by `corsac-dart/di`. This means that one can use Kernel to access
all the application services. For instance:

```dart
class FooService {
  final BarService bar;
  FooService(this.bar);
}

class BarService {
  void baz() {
    print('foo bar baz');
  }
}

var kernel = await Kernel.build('prod', {}, []);
FooService foo = kernel.get(FooService);
foo.bar.baz(); // prints 'foo bar baz';
```

The `Kernel.get()` method is just a shortcut for `Kernel.container.get()`.

> Read more about how `DIContainer` works in the documentation for
> `corsac-dart/di` package.

The `KernelModule.getServiceConfiguration()` hook is called by `Kernel` during
initialization phase (inside `Kernel.build()`). Returned configuration map
is registered with the Kernel's DI container.

> It is important to note that if two modules provide configuration for the
> same container entry, value provided by the later module will be used.

```dart
// Example service interface and implementations
abstract class LogHandler {}
class EmailLogHandler implements LogHandler {}
class NullLogHandler implements LogHandler {}

// NullLogHandler should be used in `test` environment to avoid
// sending unnecessary emails.

class MyProjectMainModule extends KernelModule {
  Map getServiceConfiguration(String environment) {
    // Main module registers "real" implementation to use in
    // production mode.
    return {
      LogHandler: DI.get(EmailLogHandler),
    };
  }
}

class MyProjectTestModule extends KernelModule {
  Map getServiceConfiguration(String environment) {
    // Test module must override implementation when application
    // is running in `test` environment.
    var config = {};
    if (environment = 'test') {
      config[LogHandler] = DI.get(NullLogHandler);
    }
    return config;
  }
}

var kernel = await Kernel.build('prod', {}, [
  new MyProjectMainModule(),
  new MyProjectTestModule() // should go after 'main' module in order to
                            // override service configuration
]);

print(kernel.get(LogHandler)); // prints 'Instance of <EmailLogHandler>'

kernel = await Kernel.build('test', {}, [
  new MyProjectMainModule(),
  new MyProjectTestModule()
]);

print(kernel.get(LogHandler)); // prints 'Instance of <NullLogHandler>'
```

## 4. `Kernel.execute` and application tasks


## License

BSD-2
