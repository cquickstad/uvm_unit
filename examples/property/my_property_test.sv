// An example showing how a property can be unit tested.

`timescale 1ps/1ps

`include "sv_test.svh"

// Create a module in which to put our Property Under Test
module property_test_module;

  reg reset, clock, valid, a, b;

  initial begin : clock_drive_thread
    clock = 0;
    forever #10 clock = ~clock;
  end

  // Properties must be in some container, such as our unit-test module.
  // reset and clock are not passed through the parameter list.
  // ready, valid, a, and b are passed through the parameter list.
  `include "my_property.sv"

  // In order to test a property, it must be instantiated into an assertion.
  // This macro, provided by the unit-test framework, instantiates the property
  // in an assertion, with the pass/fail conditions connected to the unit-test
  // framework infrastructure to allow macros such as
  // `ASSERT_PROPERTY_PASS_FAIL_COUNT() to work.
  `SV_TEST_ASSERT_PROPERTY(a_and_b_together, (valid, a, b))

  `SV_TEST_ASSERT_PROPERTY(a_and_b_no_args, )


  // Using a fixture is optional, but can allow for setup() activities to run in
  // every test that uses the fixture, such as reset.
  // Defining the fixture in the module allows direct access to the signals without
  // referencing the module path (i.e 'valid' instead of 'property_test_module.valid')
  class my_fixture extends sv_test_pkg::sv_test_fixture;

    function new(unit_test_pkg::unit_test_runner tr);
      super.new(tr);
    endfunction

    virtual task setup();
      super.setup();
      do_reset();
    endtask

    virtual task do_reset();
      reset = 1;
      valid = 0;
      repeat (5) @(posedge clock);
      reset = 0;
    endtask

  endclass


  // Placing tests in the module allows direct access to the signals without
  // referencing the module path (i.e 'valid' instead of 'property_test_module.valid')
  `SV_TEST_F(my_fixture, property_fails_test)
    @(posedge clock);
    valid = 1;
    a = 1;
    b = 0;
    @(posedge clock);
    valid = 0;
    @(posedge clock);
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, 0, 1)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_no_args, 0, 1)
  `END_SV_TEST

  `SV_TEST_F(my_fixture, property_passes_test)
    @(posedge clock);
    valid = 1;
    a = 1;
    b = 1;
    @(posedge clock);
    valid = 0;
    @(posedge clock);
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, 1, 0)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_no_args, 1, 0)
  `END_SV_TEST

endmodule

