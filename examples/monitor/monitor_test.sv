// A monitor needs access to a virtual interface. A virtual interface
// needs an actual interface instance.  An instance of an interface
// must reside in a module. The UNIT_TEST_RUN_MODULE_BODY define allows
// some code to be quickly and easily dropped inside of uvm_unit's
// unit_test_run module and avoids creating multiple top-level modules,
// if you wish to avoid that.
`define UNIT_TEST_RUN_MODULE_BODY \
    ifc     mon_ifc();

`include "uvm_unit.svh"

`include "ifc.sv"
`include "pkt.sv"
`include "monitor.sv"


// The fixture acts as a UVM environment container for our class under
// test.  Just like an env class in a test-bench, the fixture uses
// the UVM phases to build and connect the class under test.  This
// can also allows the unit-test to document the setup and config
// requirements of the class under test.
class fxtr extends uvm_unit_pkg::uvm_unit_fixture;
    `uvm_component_utils(fxtr)

    // Class Under Test -- this is the thing we're trying to test
    mon                             cut;

    // Mock an analysis port connection to the monitor
    uvm_tlm_analysis_fifo #(pkt)    af;

    // A packet handle to make unit tests easier/shorter
    pkt                             p;

    // A virtual interface handle to make unit tests easier/shorter
    virtual ifc                     vi;

    function new(string name="fxtr", uvm_component parent=null);
        super.new(name, parent);
        af = new("ap", this);
        vi = unit_test_run_module.mon_ifc;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual ifc)::set(null, "", "mon_ifc", unit_test_run_module.mon_ifc);
        cut = mon::type_id::create("cut", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cut.ap.connect(af.analysis_export);
    endfunction

    // The fixture is a great place to put test helpers.
    // Such test helpers are a great way to keep tests as simple as
    // possible so they clearly express their intent.
    virtual task drive_x_signal(byte x);
    vi.val = 0;
    vi.x = x;
    #1;
    `ASSERT_TRUE(af.is_empty())
    vi.val = 1;
    endtask
endclass


`RUN_PHASE_TEST_F(fxtr, cut_created)
    `ASSERT_NOT_NULL(cut)
    `ASSERT_STR_EQ(cut.get_name(), "cut")
    `ASSERT_STR_EQ(cut.get_type_name(), "mon")
    `ASSERT_NOT_NULL(cut.ap)
    `ASSERT_NOT_NULL(cut.mon_ifc)
    `ASSERT_NOT_NULL(af)
`END_RUN_PHASE_TEST


// This test does not use the fixture so we can setup a situation
// where the uvm_config_db is not configured correctly
`UVM_TEST(fatal_happens_when_virtual_interface_is_not_in_uvm_config_db)
    mon     cut;
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cut = mon::type_id::create("cut", this);
        `EXPECT_FATAL_ID("IFC_NOT_IN_DB")
    endfunction
`END_UVM_TEST


// Override the parent fixture to set the virtual interface
// in the config database to null.
`UVM_TEST_F(fxtr, fatal_happens_when_virtual_interface_is_null)
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual ifc)::set(null, "", "mon_ifc", null);
        `EXPECT_FATAL_ID("IFC_NULL")
    endfunction
`END_UVM_TEST


// Creating a custom check is a great way to keep a clean test and express
// its intent.  Using a macro for the check, rather than a method in the
// fixture, allows any error messages to maintain the correct file and
// line-number in the error message output.
`define ASSERT_PKT_EQ(VALUE)                \
    `ASSERT_FALSE(af.is_empty())            \
    `ASSERT_TRUE(af.try_get(p))             \
    `ASSERT_NOT_NULL(p)                     \
    if (p != null) `ASSERT_EQ(p.x, VALUE)

`RUN_PHASE_TEST_F(fxtr, values_reported_on_rising_edge_of_valid)
    drive_x_signal(123);
    #1;
    `ASSERT_PKT_EQ(123)
    drive_x_signal(2);
    #1;
    `ASSERT_PKT_EQ(2)
`END_RUN_PHASE_TEST
