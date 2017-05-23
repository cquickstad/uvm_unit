`include "uvm_unit.svh"


`RUN_PHASE_TEST(one_failing_test)
    `ASSERT_FALSE(1)
`END_RUN_PHASE_TEST
