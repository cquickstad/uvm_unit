`timescale 1ps/1ps

`include "sv_test.svh"
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


// The fixture can be used by each unit test to perform common setup/tear-down
// routines as well as provide test-helper functions/methods.
class my_fixture extends sv_test_pkg::sv_test_fixture;
    function new(unit_test_pkg::unit_test_runner tr);
      super.new(tr);
    endfunction

    virtual task setup();
        cov_test_module.reset = 0;
        cov_test_module.ev = 0;
        @(posedge cov_test_module.clk);
        #0;
        cov_test_module.mut.cg_inst = new(); // Reset coverage data for each unit test
    endtask

    virtual function int get_cov_numerator();
        int denom;
        void'(cov_test_module.mut.cg_inst.get_inst_coverage(get_cov_numerator, denom));
    endfunction

    virtual function int get_cov_denominator();
        int numer;
        void'(cov_test_module.mut.cg_inst.get_inst_coverage(numer, get_cov_denominator));
    endfunction

    virtual task drive_event_pulse();
        cov_test_module.ev = 1;
        #1;
        cov_test_module.ev = 0;
        #1;
    endtask
endclass


// Custom assertion can make tests simpler and easier to read
`define ASSERT_EV_COUNT(EXPECTED_COUNT) \
    `ASSERT_EQ(cov_test_module.ev_count, EXPECTED_COUNT)

`define ASSERT_COV(EXPECTED_COV) \
    `ASSERT_EQ(get_cov_numerator(), EXPECTED_COV)


`SV_TEST_F(my_fixture, no_activity_in_reset)
    // When inside the `SV_TEST_F/`END_SV_TEST macros we are in the test_body()
    // method of a class that inherits from my_fixture.

    #1;
    `ASSERT_EV_COUNT(0)
    cov_test_module.reset = 1;
    #1;
    `ASSERT_EV_COUNT(0)
    repeat (3) drive_event_pulse();
    `ASSERT_EV_COUNT(0)

    `ASSERT_COV(0) // Coverage should not happen while in reset
`END_SV_TEST


`SV_TEST_F(my_fixture, events_counted)
    @(posedge cov_test_module.clk);
    #1;
    repeat (7) drive_event_pulse();
    `ASSERT_EV_COUNT(7)
`END_SV_TEST


`SV_TEST_F(my_fixture, event_count_is_reset_by_clock)
    @(posedge cov_test_module.clk); #1;
    `ASSERT_EV_COUNT(0)

    repeat (3) drive_event_pulse();
    `ASSERT_EV_COUNT(3)

    @(posedge cov_test_module.clk); #1;
    `ASSERT_EV_COUNT(0)
`END_SV_TEST


`SV_TEST_F(my_fixture, events_counted_when_on_same_edge_as_clk)
    @(posedge cov_test_module.clk);
    #2;
    cov_test_module.clk = 0;
    #2;
    cov_test_module.ev = 1;
    cov_test_module.clk = 1;
    #1;
    `ASSERT_EV_COUNT(1)
`END_SV_TEST


`SV_TEST_F(my_fixture, expected_number_of_bins)
    `ASSERT_EQ(get_cov_denominator(), 4)
`END_SV_TEST


`SV_TEST_F(my_fixture, each_event_cov_bin)
  // Zero bin
  @(posedge cov_test_module.clk); #1;
  `ASSERT_COV(1)

  // Zero bin + One bin
  drive_event_pulse();
  @(posedge cov_test_module.clk); #1;
  `ASSERT_COV(2)

  // Zero bin + One bin + Two bin
  repeat (2) drive_event_pulse();
  @(posedge cov_test_module.clk); #1;
  `ASSERT_COV(3)

  // Zero bin + One bin + Two bin + or_more bin
  repeat (3) drive_event_pulse();
  @(posedge cov_test_module.clk); #1;
  `ASSERT_COV(4)

  // No change for more bins
  repeat (7) drive_event_pulse();
  @(posedge cov_test_module.clk); #1;
  `ASSERT_COV(4)
`END_SV_TEST

