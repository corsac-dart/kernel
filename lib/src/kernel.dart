part of corsac_kernel;

/// Generic Kernel implementation with following features:
///
/// * Enables dependency inversion via built-in DI container
///   (see [Corsac DI](https://github.com/corsac-dart/di)).
/// * Provides simple module system based on Dart's built-in libraries.
class Kernel {
  /// Environment for this kernel.
  final String environment;

  /// Kernel configuration parameters.
  final Map<String, dynamic> parameters;

  /// Dependency injection container used by this kernel.
  final di.Container container;

  /// Internal constructor.
  Kernel._(this.environment, this.parameters, this.container);

  /// Builds new instance of Kernel.
  ///
  /// [environment] should be non-empty string which defines a context under
  /// which this Kernel will operate. There are no restrictions on possible
  /// values for the environment. Very common ones are: dev, qa, test, prod,
  /// local, staging.
  ///
  /// [parameters] is an arbitrary collection of key-value pairs which you can
  /// provide to this Kernel. These parameters will be accessible in this
  /// kernel's container under the same keys which means you can reference
  /// them in your module's configuration using `di.get()`.
  ///
  /// [moduleNames] is a list of Dart library names you wish to register with
  /// this kernel. __Please note that order of modules in this list is
  /// important__. If modules define their own service configurations then
  /// later configuration will overwrite earlier ones if keys are the same.
  factory Kernel(String environment, Map parameters, List<Symbol> moduleNames) {
    var config = new Map.from(parameters);
    moduleNames.forEach((m) {
      var module = _createModuleForLibrary(m);
      config.addAll(module.getServiceConfiguration(environment));
    });

    return new Kernel._(
        environment, parameters, new di.Container.build(config));
  }
}

/// Base class for Kernel modules.
///
/// This class provides interface for interacting with the Kernel in certain
/// ways. Currently this class provides a hook for module-specific service
/// configurations.
///
/// To use it in your module's library just declare a subclass and override
/// necessary method(s). For instance:
///
///     library my_project.user_management;
///
///     import 'package:corsac_kernel/corsac_kernel.dart';
///     import 'package:corsac_di/di.dart' as di;
///
///     class UserManagementModule extends KernelModule {
///       Map<dynamic, dynamic> getServiceConfiguration(String environment) {
///         return {
///           SomeService: di.object()
///             ..bindParameter('host', di.env('SOME_SERVICE_HOST')),
///         };
///       }
///     }
///
/// Usage of this API is completely optional though. If you don't declare a
/// subclass, Kernel will build default configuration for you.
abstract class KernelModule {
  Map<dynamic, dynamic> getServiceConfiguration(String environment) {
    return {};
  }
}

KernelModule _createModuleForLibrary(Symbol libraryName) {
  var baseModuleMirror = reflectType(KernelModule);
  var lib = currentMirrorSystem().findLibrary(libraryName);
  var module;
  for (var declaration in lib.declarations.values) {
    if (declaration is ClassMirror &&
        declaration.superclass == baseModuleMirror) {
      module = declaration.newInstance(new Symbol(''), []).reflectee;
    }
  }

  if (module == null) {
    module = new _GenericModule(libraryName);
  }

  return module;
}

class _GenericModule implements KernelModule {
  final Symbol library;

  _GenericModule(this.library);

  @override
  Map getServiceConfiguration(String environment) {
    return {};
  }
}
