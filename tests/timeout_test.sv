// This test shows that uvm_unit can use the standard UVM phase timeout

`include "uvm_unit.svh"

`RUN_PHASE_TEST(this_test_will_timout_and_cause_an_unexpected_uvm_error_and_fail)
    uvm_top.set_timeout(.timeout(100), .overridable(0)); // set_global_timeout() is deprecated.
    #100;
    `uvm_info(get_name(), "Almost there!", UVM_NONE)
    #1;
    `uvm_info(get_name(), "You should not be seeing this!!!", UVM_NONE)
`END_RUN_PHASE_TEST
