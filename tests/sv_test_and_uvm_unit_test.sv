`include "uvm_unit.svh"

module A;
    `SV_TEST(passing_sv_test_in_module)
        `ASSERT_TRUE(1)
    `END_SV_TEST

    `SV_TEST(failing_sv_test_in_module)
        `ASSERT_TRUE(0)
    `END_SV_TEST
endmodule

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
