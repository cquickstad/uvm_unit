`timescale 1ps/1ps

// Include the design under test (DUT), which is a simple mux.
`include "mux.sv"

// A module is needed to give our DUT a place to be instantated.
module mux_test;
    reg [3:0] in[4];
    reg [1:0] sel;
    wire [3:0] out;

    mux#(.NUM_PORTS(4),.DATA_WIDTH(4)) my_mux(.*);
endmodule

`define UNIT_TEST_RUN_MODULE_BODY \
    mux_test test_module();

// Include the unit-testing framework, which brings in all of the collateral
// to define tests and assertion macros, find tests, run them, and collect
// and report the results.
`include "sv_test.svh"

// A fixture provides a place to define test-helping functions or tasks. It
// provides a setup() and teardown() as well.
// Every test that uses the fixture will automatically run the defined setup
// and teardown as well as have access to the helper-functions/tasks.
class mux_fxtr extends sv_test_pkg::sv_test_fixture;

    function new(unit_test_pkg::unit_test_runner tr);
        super.new(tr);
    endfunction

    virtual task setup();
        // Zero out the input for each test
        foreach (unit_test_run_module.test_module.in[i]) unit_test_run_module.test_module.in[i] = '0;
        unit_test_run_module.test_module.sel = '0;
        #10; // Time delay between tests
    endtask

    virtual task apply_stimulus(bit [1:0] sel, bit [3:0] in[]);
        #1;
        foreach (in[i]) unit_test_run_module.test_module.in[i] = in[i];
        unit_test_run_module.test_module.sel = sel;
        #1;
    endtask

endclass


// Tests defined with the unit-test-framework's test definition macros are
// are automatically found and run by the unit-test-framework.
// The test definition macros that end in '_F' are the "fixture" version
// that allow the user to specify a custom fixture. Otherwise the defualt
// fixture is used.
`SV_TEST_F(mux_fxtr, test_that_port_zero_is_routed_to_the_output)
    apply_stimulus(.sel(0),.in({'hA, 'hB, 'hC, 'hD}));
    `ASSERT_EQ(unit_test_run_module.test_module.out, 'hA);
    apply_stimulus(.sel(0),.in({'h7, 'hB, 'hC, 'hD}));
    `ASSERT_EQ(unit_test_run_module.test_module.out, 'h7);
`END_SV_TEST

`SV_TEST_F(mux_fxtr, test_that_port_two_is_routed_to_the_output)
    apply_stimulus(.sel(2),.in({'hA, 'hB, 'hC, 'hD}));
    `ASSERT_EQ(unit_test_run_module.test_module.out, 'hC)
    apply_stimulus(.sel(2),.in({'hA, 'hB, 'h6, 'hD}));
    `ASSERT_EQ(unit_test_run_module.test_module.out, 'h6)
`END_SV_TEST
