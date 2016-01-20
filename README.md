# Generic Kernel for server-side applications

[![Build Status](https://img.shields.io/travis-ci/corsac-dart/kernel.svg?branch=master&style=flat-square)](https://travis-ci.org/corsac-dart/kernel)
[![Coverage Status](https://img.shields.io/coveralls/corsac-dart/kernel.svg?branch=master&style=flat-square)](https://coveralls.io/github/corsac-dart/kernel?branch=master)
[![License](https://img.shields.io/badge/license-BSD--2-blue.svg?style=flat-square)](https://raw.githubusercontent.com/corsac-dart/kernel/master/LICENSE)

Corsac Kernel has 3 major goals:

1. Provide module-based system to structure and organize applications.
2. Provide a way to execute application tasks in an isolated scope.
3. Provide foundation for writing applications with Dependency Inversion in
  mind.

Corsac Kernel also tries to be very lightweight so that it is fairly easy to
start with and scale over time.

## 1. Introduction
### 1.1 Why

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

## 2. Modules
## 3. `Kernel.execute` and application tasks
## 4. Dependency Inversion

## License

BSD-2
