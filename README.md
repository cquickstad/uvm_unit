# uvm_unit
A Unit-Testing Framework for SystemVerilog and UVM.

[SVUnit](https://github.com/svunit/svunit) is no longer the "only SystemVerilog test framework in existence."

## What's wrong with SVUnit?
I wrote uvm_unit to address the following shortcomings of SVUnit.

uvm_unit...
- reruns all UVM Phases for each unit test. **You can access and test any phase from any test.** This, for example, allows you to develop a check in the `check_phase` using TDD.
- fails the test if any `uvm_fatal`, `uvm_error`, or `uvm_warning` happens that was not explicitly expected.
- has no script dependencies. Just compile and run.
- has minimal boilerplate code. No need to generate or use templates.
- has assertion macros that show the values that caused the failure in the error messages.
- has assertion macros with `ASSERT_*()` names that are more familiar to users of other unit test frameworks.
- has UVM class-based test fixtures. Not only can one fixture inherit from another, but the fixture behaves a lot like a parent component, similar to your production environment.

## What's wrong with uvm_unit?
A critical feature of a unit testing framework is that the tests can run in any order without time/order dependencies between them. To do this, the critical UVM infrastructure needs to be destroyed and rebuilt for each unit test. The UVM codebase was not written in a way to allow for this, even by extending its base classes.

Likewise, UVM was written in a way that makes it impossible to rerun any of the UVM Phases, even by extending its base classes. This blocked the most critical feature uvm_unit tried to achieve.

The UVM Codebase makes widespread use of the evil Singleton Class anti-pattern.
- Singletons are really just fancy global state. (That's a code smell.)
- Singletons violate the Single Responsibility Principle because they control their own creation and life cycle.
- Singletons lead to tight coupling.

For these reasons, uvm_unit requires a modified UVM codebase. This means you cannot use the UVM library that shipped with your simulator or that is already installed in your environment.  Instead, you must redirect your simulator to load uvm_unit's modified version of UVM.

uvm_unit ships with the modified UVM codebase and therefore supports only these UVM versions at this time:
- UVM 1.2
- UVM-1800.2-2020-2.0

## How do I install and use uvm_unit?
- Clone or copy this repository into your work environment. To just try it out, this can be a path in your local account. Eventially, this can be located in a path common to all users where tools are installed.
- Provide the root of this resository as an include directory to your simulator (e.g. `-incdir /tool/path/uvm_unit`).
- Provide the `src` directory of the modified-UVM version as an include directory to your simulator (e.g. `-incdir /tool/path/uvm_unit/uvm-1.2/src`).
- For exact details, check out the run scripts for Xcelium, Questa, and VCS in the examples directory.

A unit test only needs to have `` `include "uvm_unit.svh"``, have additional `` `include`` statements to bring in the code you're wanting to test, then define one or more tests using one of the test definition macros such as `` `RUN_PHASE_TEST()/`END_RUN_PHASE_TEST`` or `` `UVM_TEST()/`END_UVM_TEST``.  Any tests that are defined in the global scope are automatically run by the unit test framework.

The examples in the examples directory show several use cases and provide the simple compile and run commands for each example for the major industry simulators (Xcelium, Questa, and VCS).

## Is it only for UVM test-benches?
No. uvm_unit also ships with a stripped down framework called 'sv_test' that leaves out all of the UVM stuff. See how it's used in the [coverage example](https://github.com/cquickstad/uvm_unit/tree/master/examples/coverage).

## Does this thing actually work?
Yes. uvm_unit is well tested. (See [the tests](https://github.com/cquickstad/uvm_unit/tree/master/tests).)

My coworkers and I have been using uvm_unit successfully on lots of complex projects for many years.  I'd love to hear feedback if you're enjoying it also.
