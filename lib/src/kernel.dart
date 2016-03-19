part of corsac_kernel;

/// Corsac Kernel.
class Kernel {
  /// Environment for this kernel.
  final String environment;

  /// Kernel configuration parameters.
  final Map<String, dynamic> parameters;

  /// Dependency injection container used by this kernel.
  final DIContainer container;

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

    var container = new DIContainer.build(configs);
    var kernel = new Kernel._(
        environment, parameters, container, new List.unmodifiable(modules));
    container.set(Kernel, kernel);

    for (var module in modules) {
      await module.initialize(kernel);
    }

    return kernel;
  }

  /// Returns Kernel's container entry.
  ///
  /// This is a shortcut for `kernel.container.get(id)`.
  dynamic get(id) => container.get(id);

  /// Executes [task] in a [Zone].
  Future execute(Function task) {
    ClosureMirror mirror = reflect(task);
    var positionalArguments = [];
    for (var param in mirror.function.parameters) {
      if (!param.isNamed) {
        positionalArguments.add(get(param.type.reflectedType));
      }
    }

    return new Future.sync(() {
      var state = new Map();
      for (var m in modules) {
        state.addAll(m.initializeTask(this));
      }

      var r = runZoned(() {
        return mirror.apply(positionalArguments).reflectee;
      }, zoneValues: state);

      Future future = (r is Future) ? r : new Future.value(r);

      return future.whenComplete(() {
        return Future.wait(modules.map((_) => _.finalizeTask(this)));
      });
    });
  }

  /// Shuts down any processes running within this kernel. This effectively
  /// indicates end of this kernel's lifecycle and it shouldn't be used after
  /// it's been shutdown.
  Future shutdown() => Future.wait(modules.map((_) => _.shutdown(this)));
}

/// Base class for Kernel modules.
///
/// This class provides interface for interacting with the Kernel.
///
/// Example of a module:
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
  Map getServiceConfiguration(String environment) {
    return {};
  }

  /// Runs initialization tasks for this module.
  ///
  /// This hook is called after [Kernel] has been fully loaded.
  Future initialize(Kernel kernel) => new Future.value();

  /// Returns a Map of task-local values that modules wish to register
  /// for a task before it's executed.
  ///
  /// This hook is called by `Kernel.execute()` to initialize shared state for
  /// the task which is about to be executed.
  ///
  /// Behind the hood the values map returned by this hook will be passed to the
  /// `runZoned()` call as zone-local values.
  ///
  /// During task execution these values can be accessed via
  /// `Zone.current[#key]`, where `#key` corresponds to a key in the returned
  /// Map.
  ///
  /// Refer to documentation on Zones and zone-local values for more details.
  Map initializeTask(Kernel kernel) => new Map();

  /// Finalizes task execution.
  ///
  /// Modules should override this hook if they wish to perform any action
  /// after [Kernel] task has been executed.
  ///
  /// A typical example could be committing a database transaction.
  Future finalizeTask(Kernel kernel) => new Future.value();

  /// Runs shutdown tasks for this module.
  ///
  /// This hook is called by [Kernel.shutdown] for all modules. Modules
  /// are responsible for cleaning up their state here and closing any open
  /// connections.
  Future shutdown(Kernel kernel) => new Future.value();
}
