`ifdef VERILATOR
    `include "unit_test_macros.sv"
`else
    `include "sv_test.svh"
`endif

module A;
    `SV_TEST(passing_sv_test_in_module)
        `ASSERT_TRUE(1)
    `END_SV_TEST

    `SV_TEST(failing_sv_test_in_module)
        `ASSERT_TRUE(0)
    `END_SV_TEST
endmodule

`ifdef VERILATOR

    // As of version 5.052 2026-09-05, Verilator only supports a single top module.
    // Therefore, any module-under-test will need to be instantiated under that
    // module.  uvm_unit/sv_test need unit_test_run_module as the top module, so
    // the module-under-test will be instantiated under it.
    `define UNIT_TEST_RUN_MODULE_BODY \
        A a();
`endif

`include "uvm_unit.svh"

`SV_TEST(passing_sv_test)
    `ASSERT_TRUE(1)
`END_SV_TEST

`SV_TEST(failing_sv_test)
    `ASSERT_TRUE(0)
`END_SV_TEST

`RUN_PHASE_TEST(passing_uvm_test)
    `ASSERT_TRUE(1)
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST(failing_uvm_test)
    `ASSERT_TRUE(0)
`END_RUN_PHASE_TEST
