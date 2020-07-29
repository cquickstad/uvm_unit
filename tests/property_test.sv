`timescale 1ps/1ps
`include "sv_test.svh"

module prop_test;
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
    repeat (2) @(posedge clock);
    reset = 0;
    @(posedge clock);
    valid = 1;
    a = 1;
    b = 0;
    @(posedge clock);
    valid = 0;
    @(posedge clock);
    `ASSERT_PROPERTY_PASS_COUNT(a_and_b_together, 0)
    `ASSERT_PROPERTY_FAIL_COUNT(a_and_b_together, 1)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, 0, 1)
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
    @(posedge clock);
    valid = 1;
    a = 1;
    b = 1;
    @(posedge clock);
    valid = 0;
    @(posedge clock);
    `ASSERT_PROPERTY_PASS_COUNT(a_and_b_together, 1)
    `ASSERT_PROPERTY_FAIL_COUNT(a_and_b_together, 0)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, 1, 0)
  `END_SV_TEST

  `SV_TEST_F(a_fixture, failing_property_test_1)
    @(posedge clock);
    valid = 1;
    a = 1;
    b = 1;
    @(posedge clock);
    valid = 0;
    @(posedge clock);
    `ASSERT_PROPERTY_PASS_COUNT(a_and_b_together, 0)
    `ASSERT_PROPERTY_FAIL_COUNT(a_and_b_together, 1)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, 0, 1)
  `END_SV_TEST

  `SV_TEST_F(a_fixture, failing_property_test_2)
    @(posedge clock);
    valid = 1;
    a = 1;
    b = 0;
    @(posedge clock);
    valid = 0;
    @(posedge clock);
    `ASSERT_PROPERTY_PASS_COUNT(a_and_b_together, 1)
    `ASSERT_PROPERTY_FAIL_COUNT(a_and_b_together, 0)
    `ASSERT_PROPERTY_PASS_FAIL_COUNT(a_and_b_together, 1, 0)
  `END_SV_TEST

endmodule

