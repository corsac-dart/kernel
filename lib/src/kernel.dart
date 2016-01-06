part of corsac_kernel;

/// Generic Kernel implementation with following features:
///
/// * Enables dependency inversion via built-in DI container
///   (see [Corsac DI](https://github.com/corsac-dart/di)).
/// * Provides simple module-based system.
class Kernel {
  /// Environment for this kernel.
  final String environment;

  /// Kernel configuration parameters.
  final Map<String, dynamic> parameters;

  /// Dependency injection container used by this kernel.
  final Container container;

  final List<KernelModule> modules;

  /// Internal constructor.
  Kernel._(this.environment, this.parameters, this.container, this.modules);

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
  /// them in your module's configuration using `DI.get()`.
  ///
  /// [modules] is a list of kernel modules you wish to register with
  /// this kernel. __Please note that order of modules in this list is
  /// important__. If modules define their own service configurations then
  /// later configuration will overwrite earlier ones if keys are the same.
  static Future<Kernel> build(
      String environment, Map parameters, List<KernelModule> modules) async {
    var configs = new List<Map>();
    configs.add(new Map.from(parameters));

    for (var m in modules) {
      configs.add(m.getServiceConfiguration(environment));
    }

    var kernel = new Kernel._(environment, parameters,
        new Container.build(configs), new List.unmodifiable(modules));

    for (var module in modules) {
      await module.initialize(kernel);
    }

    return kernel;
  }

  /// Returns Kernel's container entry.
  ///
  /// This is just a shortcut for `container.get()`.
  dynamic get(dynamic id) => container.get(id);
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
///     import 'package:corsac_di/corsac_di.dart';
///
///     class UserManagementModule extends KernelModule {
///       Map<dynamic, dynamic> getServiceConfiguration(String environment) {
///         return {
///           SomeService: DI.object()
///             ..bindParameter('host', DI.env('SOME_SERVICE_HOST')),
///         };
///       }
///     }
///
abstract class KernelModule {
  /// Returns service configuration for this module.
  ///
  /// Returned map is a configuration as expected by `corsac_di` container.
  ///
  /// Override this method to customize services provided by this module.
  Map<dynamic, dynamic> getServiceConfiguration(String environment) {
    return {};
  }

  /// Runs initialization tasks for this module.
  ///
  /// This hook is called after [Kernel] has been fully loaded.
  Future initialize(Kernel kernel) => new Future.value();
}
