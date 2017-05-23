`define UNIT_TEST_RUN_MODULE_BODY \
    some_interface      ifc();


`include "uvm_unit.svh"
import uvm_unit_pkg::*;


interface some_interface();
    bit x;
endinterface


`RUN_PHASE_TEST(uvm_unit_top_module_body_test)
    virtual some_interface  vi = unit_test_run_module.ifc;
    `ASSERT_NULL(vi) // Expect to fail (shows up in output log)
`END_RUN_PHASE_TEST
