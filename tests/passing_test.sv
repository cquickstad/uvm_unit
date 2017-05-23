`include "uvm_unit.svh"
import uvm_unit_pkg::*;

`RUN_PHASE_TEST(a_passing_unit_test)
    `ASSERT_TRUE(1)
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST(another_passing_unit_test)
    `ASSERT_FALSE(0)
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST(yet_another_passing_unit_test)
    `ASSERT_EQ(7, 7)
`END_RUN_PHASE_TEST
