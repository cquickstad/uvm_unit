`include "uvm_unit.svh"

`RUN_PHASE_TEST(this_passing_test_is_in_another_file)
    `ASSERT_TRUE(1)
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST(this_failing_test_is_in_another_file)
    `ASSERT_FALSE(1)
`END_RUN_PHASE_TEST
