`include "uvm_unit.svh"

`include "my_interface.sv"
`include "my_item.sv"
`include "my_driver.sv"


// Create a module in which to put our interface, with a signal to drive.
module driver_test_module;
    reg [31:0] foo;
    my_interface ifc(.*); // .* is the implicit port connection
endmodule


// The default sequencer will work fine.
typedef uvm_sequencer #(my_item) my_sequencer;


// A simple sequence will provide access to the item and do the item from
// the unit tests.
class my_sequence extends uvm_sequence #(my_item);
    `uvm_object_utils(my_sequence)
    function new(string name="my_sequence");
        super.new(name);
        req = my_item::type_id::create("req"); // req is inherited from uvm_sequnce
    endfunction
    virtual task body();
        start_item(req);
        finish_item(req);
    endtask
endclass


// The fixture can be used by each unit test to automatically setup a
// mock environment that gets the driver ready to test with stimulus from
// the sequence/item.  Remember that uvm_unit_fixture inherits from
// uvm_test, which inherits from uvm_component.
class my_fixture extends uvm_unit_pkg::uvm_unit_fixture;
    my_sequence seq;
    my_sequencer seqr;
    my_driver drvr;

    `uvm_component_utils(my_fixture)
    function new(string name="my_fixture", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual my_interface)::set(this, "*", "ifc", driver_test_module.ifc);
        seqr = my_sequencer::type_id::create("seqr", this);
        drvr = my_driver::type_id::create("drvr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drvr.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass


// This test avoids using the fixture to test what happens when the virtual
// interface is not provided in the uvm_config_db.
`UVM_TEST(test_that_uvm_fatal_happens_when_virtual_interface_is_not_found)
    // When inside the `UVM_TEST/`END_UVM_TEST macros we are in the body
    // of a class that inherits from uvm_test.

    my_driver drvr;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drvr = my_driver::type_id::create("drvr", this);
    endfunction
    virtual function void phase_started(uvm_phase phase);
        if (phase.get_name() == "connect") `EXPECT_FATAL_ID("DRIVER_VIF_NOT_FOUND")
    endfunction
`END_UVM_TEST


// This test uses the fixture)
`RUN_PHASE_TEST_F(my_fixture, test_that_driver_drives_foo)
    // When inside the `RUN_PHASE_TEST_F/`END_RUN_PHASE_TEST macros we are
    // in the run_phase() method of a class that inherits from the fixture.

    seq = new("seq");
    seq.req.foo = 42;
    seq.start(seqr);
    #1;
    `ASSERT_EQ(driver_test_module.foo, 42);

    seq = new("seq");
    seq.req.foo = 'hDEAD_BEEF;
    seq.start(seqr);
    #1;
    `ASSERT_EQ(driver_test_module.foo, 'hDEAD_BEEF);

    seq = new("seq");
    seq.req.foo = 'hC0DE;
    seq.start(seqr);
    #1;
    `ASSERT_EQ(driver_test_module.foo, 'hC0DE);
`END_RUN_PHASE_TEST
