// sv_test does not need to have UVM included, which results in less
// overhead when UVM is not needed.
`include "sv_test.svh"

// The module that will be tested.
// This would ordinarily reside in another and be included here.
module D_flip_flop
(
  input  logic  clk,
  input  logic  rst_n,
  input  logic  d,
  output logic  q
);
    always_ff @(posedge clk or negedge rst_n) begin : proc_q
        if (~rst_n) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end : proc_q
endmodule


// A parent module is needed for testing.
// The parent module provides a place for the Module Under Test (MUT) to be
// instantiated. It also provides a place to connect the test harness and
// the fixture.
// This module is a top-level module
module D_flip_flop_test_module;

    // Signals in the unit-test module used to interface to the Module Under Test.
    logic   clk;
    logic   rst_n;
    logic   d;
    logic   q;

    // Module Under Test
    D_flip_flop     mut(.*); // dot-star connects to the above signals of the same name

    // These tests do not use a custom fixture (default to sv_test_fixture)
    `SV_TEST(test_that_reset_clears_output)
        rst_n = 'X;
        #1;
        `ASSERT_EQ(q, 1'bX)

        rst_n = 1;
        #1;
        `ASSERT_EQ(q, 1'bX)

        rst_n = 0;
        #1;
        `ASSERT_EQ(q, 1'b0)

        rst_n = 1;
        #1;
        `ASSERT_EQ(q, 1'b0)
    `END_SV_TEST

    // These tests do not use a custom fixture (default to sv_test_fixture)
    `SV_TEST(clk_x)
        clk = 0;
        d = 1;
        rst_n = 1;
        #1;
        rst_n = 0;
        #1;
        `ASSERT_EQ(q, 1'b0)
        #1;
        clk = 'X;
        #1;
        `ASSERT_EQ(q, 1'bX) // Expect to fail (with Xprop turned off)
    `END_SV_TEST

    // A class-based fixture for module-based non-UVM unit tests.
    // Here we can put helpers for driving the clock and pulling reset.
    // Notice that a class inside of a module can directly reference
    // the signals in the module.
    class clk_and_rst_fixture extends sv_test_pkg::sv_test_fixture;
        bit clock_enabled;

        function new(unit_test_pkg::unit_test_runner tr); super.new(tr); endfunction

        // A helper method to drive the clock. It will need to be forked.
        virtual task drive_clock();
            clk = 0;
            while (clock_enabled) begin
              #5 clk = ~clk;
            end
        endtask

        // A helper method to reset the flip flop.
        virtual task reset_mut();
            rst_n = 0;
            repeat (2) @(posedge clk);
            rst_n = 1;
        endtask

        // Before every test, setup() will run.
        // This fixture uses setup to start driving the clock
        // and reset the module under test.
        virtual task setup();
            super.setup(); // The parent's setup() is empty, so  this isn't really needed.
            clock_enabled = 1;
            fork drive_clock(); join_none
            d = 0;
            reset_mut();
        endtask

        // After every test, teardown() will run.
        // This fixture uses setup to stop the clock
        // and put an X on the inputs to the flip flop.
        virtual task teardown();
            super.teardown(); // The parent's teardown() is empty, so  this isn't really needed.
            clock_enabled = 0; // Kill the drive_clock() thread
            rst_n = 'X;
            clk = 'X;
            d = 'X;
            #100;
        endtask
    endclass

    // The following tests are fixture-based tests that inherit the
    // clock and reset goodness provided by clk_and_rst_fixture.

    `SV_TEST_F(clk_and_rst_fixture, test_that_zero_and_one_propagate)
        @(negedge clk);
        d = 1;
        @(negedge clk);
        `ASSERT_EQ(q, 1)    // Expect pass
        `ASSERT_EQ(q, 0)    // Expect fail
        d = 0;
        @(negedge clk);
        `ASSERT_EQ(q, 0)    // Expect pass
        `ASSERT_EQ(q, 1)    // Expect fail
    `END_SV_TEST

    `SV_TEST_F(clk_and_rst_fixture, test_that_X_and_Z_propagate)
        @(negedge clk);
        d = 'X;
        @(negedge clk);
        `ASSERT_EQ(q, 1'bX) // Expect pass
        `ASSERT_EQ(q, 1'bZ) // Expect fail
        d = 'Z;
        @(negedge clk);
        `ASSERT_EQ(q, 1'bZ) // Expect pass
        `ASSERT_EQ(q, 1'bX) // Expect fail
    `END_SV_TEST

endmodule
