`timescale 1ps/1ps

// An example showing how coverage can be unit tested.

`include "my_coverage.sv"

// Create a module in which to put our Module Under Test, with
// signals to drive/sample from the unit tests
module cov_test_module;
    reg reset, clk, ev;
    integer ev_count;
    my_cov mut(.*); // .* is the implicit port connection. MUT = Module Under Test

    initial begin
        clk = 0;
        forever #500 clk = ~clk;
    end
endmodule

`include "unit_test_macros.sv"

  // As of version 5.052 2026-09-05, Verilator only supports a single top module.
  // Therefore, any module-under-test will need to be instantiated under that
  // module.  uvm_unit/sv_test need unit_test_run_module as the top module, so
  // the module-under-test will be instantiated under it.
  `define UNIT_TEST_RUN_MODULE_BODY \
      cov_test_module test();

`include "sv_test.svh"


// The fixture can be used by each unit test to perform common setup/tear-down
// routines as well as provide test-helper functions/methods.
class my_fixture extends sv_test_pkg::sv_test_fixture;
    function new(unit_test_pkg::unit_test_runner tr);
      super.new(tr);
    endfunction

    virtual task setup();
        unit_test_run_module.test.reset = 0;
        unit_test_run_module.test.ev = 0;
        @(posedge unit_test_run_module.test.clk);
        #0;
        unit_test_run_module.test.mut.cg_inst = new(); // Reset coverage data for each unit test
    endtask

    virtual function int get_cov_numerator();
        int denom;
        void'(unit_test_run_module.test.mut.cg_inst.get_inst_coverage(get_cov_numerator, denom));
    endfunction

    virtual function int get_cov_denominator();
        int numer;
        void'(unit_test_run_module.test.mut.cg_inst.get_inst_coverage(numer, get_cov_denominator));
    endfunction

    virtual task drive_event_pulse();
        unit_test_run_module.test.ev = 1;
        #1;
        unit_test_run_module.test.ev = 0;
        #1;
    endtask
endclass


// Custom assertion can make tests simpler and easier to read
`define ASSERT_EV_COUNT(EXPECTED_COUNT) \
    `ASSERT_EQ(unit_test_run_module.test.ev_count, EXPECTED_COUNT)

`define ASSERT_COV(EXPECTED_COV) \
    `ASSERT_EQ(get_cov_numerator(), EXPECTED_COV)


`SV_TEST_F(my_fixture, no_activity_in_reset)
    // When inside the `SV_TEST_F/`END_SV_TEST macros we are in the test_body()
    // method of a class that inherits from my_fixture.
    #1;
    unit_test_run_module.test.reset = 1;
    #1;

    // Reset coverage data. We just want to count things that shouldn't be happening in reset.
    unit_test_run_module.test.mut.cg_inst = new();

    `ASSERT_EV_COUNT(0)
    repeat (3) drive_event_pulse();
    `ASSERT_EV_COUNT(0)

    `ASSERT_COV(0) // Coverage should not happen while in reset
`END_SV_TEST


`SV_TEST_F(my_fixture, events_counted)
    @(posedge unit_test_run_module.test.clk);
    #1;
    repeat (7) drive_event_pulse();
    `ASSERT_EV_COUNT(7)
`END_SV_TEST


`SV_TEST_F(my_fixture, event_count_is_reset_by_clock)
    @(posedge unit_test_run_module.test.clk); #1;
    `ASSERT_EV_COUNT(0)

    repeat (3) drive_event_pulse();
    `ASSERT_EV_COUNT(3)

    @(posedge unit_test_run_module.test.clk); #1;
    `ASSERT_EV_COUNT(0)
`END_SV_TEST


`SV_TEST_F(my_fixture, events_counted_when_on_same_edge_as_clk)
    @(posedge unit_test_run_module.test.clk);
    #2;
    unit_test_run_module.test.clk = 0;
    #2;
    unit_test_run_module.test.ev = 1;
    unit_test_run_module.test.clk = 1;
    #1;
    `ASSERT_EV_COUNT(1)
`END_SV_TEST


`SV_TEST_F(my_fixture, expected_number_of_bins)
    `ASSERT_EQ(get_cov_denominator(), 4)
`END_SV_TEST


`SV_TEST_F(my_fixture, each_event_cov_bin)
  // Zero bin
  @(posedge unit_test_run_module.test.clk); #1;
  `ASSERT_COV(1)

  // Zero bin + One bin
  drive_event_pulse();
  @(posedge unit_test_run_module.test.clk); #1;
  `ASSERT_COV(2)

  // Zero bin + One bin + Two bin
  repeat (2) drive_event_pulse();
  @(posedge unit_test_run_module.test.clk); #1;
  `ASSERT_COV(3)

  // Zero bin + One bin + Two bin + or_more bin
  repeat (3) drive_event_pulse();
  @(posedge unit_test_run_module.test.clk); #1;
  `ASSERT_COV(4)

  // No change for more bins
  repeat (7) drive_event_pulse();
  @(posedge unit_test_run_module.test.clk); #1;
  `ASSERT_COV(4)
`END_SV_TEST

