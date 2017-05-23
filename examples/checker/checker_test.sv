`include "uvm_unit.svh"

`include "pkt.sv"
`include "checker.sv"


// The fixture acts as a UVM environment container for our class under
// test.  Just like an env class in a test-bench, the fixture uses
// the UVM phases to build and connect the class under test.  This
// can also allows the unit-test to document the setup and config
// requirements of the class under test.
class fxtr extends uvm_unit_pkg::uvm_unit_fixture;
    `uvm_component_utils(fxtr)

    // Class Under Test -- this is the thing we're trying to test
    chkr                            cut;

    // Mock an analysis port connection to the monitor
    uvm_analysis_port #(pkt)        ap;

    // A packet handle to make unit tests easier/shorter
    pkt                             p;

    function new(string name="fxtr", uvm_component parent=null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        p = pkt::type_id::create("p");
        cut = chkr::type_id::create("cut", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ap.connect(cut.analysis_export);
    endfunction
endclass


`RUN_PHASE_TEST_F(fxtr, cut_created)
    `ASSERT_NOT_NULL(cut)
    `ASSERT_STR_EQ(cut.get_name(), "cut")
    `ASSERT_STR_EQ(cut.get_type_name(), "chkr")
    `ASSERT_NOT_NULL(ap)
`END_RUN_PHASE_TEST


`RUN_PHASE_TEST_F(fxtr, test_that_ap_is_connected)
    `EXPECT_WARNING_ID("NULL_PKT")
    ap.write(null);
`END_RUN_PHASE_TEST


// Using TEST_F gives access to all phases and uvm_component methods.
// We can use phase_started to show that the expected error isn't
// happening before the check phase.  The error expectation can be
// placed at the end of the run phase for simpler code at the expense
// of certainty of when the error is happening.
`UVM_TEST_F(fxtr, test_that_7_should_never_be_seen)
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this); // Remember the phase objection, or test may not run!
        p.x = 7;
        ap.write(p);
        phase.drop_objection(this);
    endtask
    virtual function void phase_started(uvm_phase phase);
        super.phase_started(phase);
        if (phase.get_name() == "check") begin
            `EXPECT_ERROR_ID_MSG("SEVEN_SEEN", "A 7 was seen during run_phase.")
        end
    endfunction
`END_UVM_TEST


`RUN_PHASE_TEST_F(fxtr, test_that_odd_packets_should_match_even)
    p.x = 1;
    ap.write(p);
    p.x = 1;
    ap.write(p);

    p.x = 3;
    ap.write(p);
    p.x = 4;
    `EXPECT_ERROR_ID("NO_EVEN_ODD_MATCH")
    ap.write(p);

    p.x = 2;
    ap.write(p);
    p.x = 2;
    ap.write(p);
`END_RUN_PHASE_TEST
