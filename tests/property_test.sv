`timescale 1ps/1ps

`ifdef VERILATOR
  `include "unit_test_macros.sv"
`else
  `include "sv_test.svh"
`endif

module prop_test;
  // As of  5.052, verilator counts vacuous passes
  const static bit vacuous_passes_counted = `ifdef VERILATOR 1 `else 0 `endif ;

  reg reset, clock, valid, a, b;
  initial begin : clock_drive_thread
    clock = 0;
    forever #10 clock = ~clock;
  end

  property a_and_b_together(reg valid, reg a, reg b);
    @(posedge clock)
      disable iff (reset === 1)
      valid && a |-> b;
  endproperty

  `SV_TEST(property_fails_test)
    reset = 1;
    valid = 0;
    a = 0;
    b = 0;
    repeat (2) @(posedge clock); #1;
    reset = 0;
    @(posedge clock); #1;
    valid = 1;
    a = 1;
    b = 0;
    @(posedge clock); #1;
    valid = 0;
    @(posedge clock); #1;
    `ASSERT_PROPERTY_PASS_COUNT(a_and_b_together, (vacuous_passes_counted ? 2 : 0))
    `ASSERT_PROPERTY_FAIL_COUNT(a_and_b_together, 1)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, (vacuous_passes_counted ? 2 : 0), 1)
  `END_SV_TEST

  `SV_TEST_ASSERT_PROPERTY(a_and_b_together, (valid, a, b))

  class a_fixture extends sv_test_pkg::sv_test_fixture;
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
      a = 0;
      b = 0;
      repeat (5) @(posedge clock);
      reset = 0;
    endtask
  endclass

  `SV_TEST_F(a_fixture, property_passes_test)
    @(posedge clock); #1;
    valid = 1;
    a = 1;
    b = 1;
    @(posedge clock); #1;
    valid = 0;
    @(posedge clock); #1;
    `ASSERT_PROPERTY_PASS_COUNT(a_and_b_together, (vacuous_passes_counted ? 4 : 1))
    `ASSERT_PROPERTY_FAIL_COUNT(a_and_b_together, 0)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, (vacuous_passes_counted ? 4 : 1), 0)
  `END_SV_TEST

  `SV_TEST_F(a_fixture, failing_property_test_1)
    @(posedge clock); #1;
    valid = 1;
    a = 1;
    b = 1;
    @(posedge clock); #1;
    valid = 0;
    @(posedge clock); #1;
    `ASSERT_PROPERTY_PASS_COUNT(a_and_b_together, 0)
    `ASSERT_PROPERTY_FAIL_COUNT(a_and_b_together, 1)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, 0, 1)
  `END_SV_TEST

  `SV_TEST_F(a_fixture, failing_property_test_2)
    @(posedge clock); #1;
    valid = 1;
    a = 1;
    b = 0;
    @(posedge clock); #1;
    valid = 0;
    @(posedge clock); #1;
    `ASSERT_PROPERTY_PASS_COUNT(a_and_b_together, 1)
    `ASSERT_PROPERTY_FAIL_COUNT(a_and_b_together, 0)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, 1, 0)
  `END_SV_TEST

endmodule


`ifdef VERILATOR
  // As of version 5.052 2026-09-05, Verilator only supports a single top module.
  // Therefore, any module-under-test will need to be instantiated under that
  // module.  uvm_unit/sv_test need unit_test_run_module as the top module, so
  // the module-under-test will be instantiated under it.
  `define UNIT_TEST_RUN_MODULE_BODY \
      prop_test test_module();

  `include "sv_test.svh"
`endif
