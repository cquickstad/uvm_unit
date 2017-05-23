`include "uvm_unit.svh"
import uvm_unit_pkg::*;

// CUT = Class Under Test
class my_cut extends uvm_scoreboard;
    `uvm_component_utils(my_cut)
    function new(string name="my_cut", uvm_component parent=null);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_name(), "Hello from build_phase!", UVM_NONE)
    endfunction
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        `uvm_info(get_name(), "Hello from run_phase!", UVM_NONE)
        phase.drop_objection(this);
    endtask
    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        `uvm_info(get_name(), "Hello from check_phase!", UVM_NONE)
    endfunction
endclass

class cut_fixture extends uvm_unit_fixture;
    `uvm_component_utils(cut_fixture)
    my_cut      cut;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cut = my_cut::type_id::create("cut", this);
    endfunction
endclass



`UVM_TEST_F(cut_fixture, foo)
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        #5;
        `uvm_info(get_type_name(), "This is a message from unit test foo", UVM_NONE)
        `ASSERT_TRUE_LOG(this.has_child("cut"), "cut not in child")
        phase.drop_objection(this);
    endtask
`END_UVM_TEST

`UVM_TEST_F(cut_fixture, bar)
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        #5;
        `uvm_info(get_type_name(), "This is a message from unit test bar", UVM_NONE)
        phase.drop_objection(this);
    endtask
`END_UVM_TEST

`UVM_TEST(a_test_without_a_fixture)
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        #5;
        `uvm_info(get_type_name(), "This is a message from unit test baz", UVM_NONE)
        phase.drop_objection(this);
    endtask
`END_UVM_TEST

`RUN_PHASE_TEST_F(cut_fixture, a_run_phase_test_with_a_fixture)
    #3;
    `uvm_info(get_type_name(), "This is a message from a_run_phase_test_with_a_fixture", UVM_NONE)
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST(assertions)
    uvm_component       null_handle = null;
    uvm_component       non_null_handle = this;
    int                 i_arr[] = {2, 3, 7, 9};
    string              str, s_q[$] = '{"one", "five", "ten"};

    #1;
    `ASSERT_TRUE(!(1'b1))               // Expect fail
    #1;
    `ASSERT_TRUE(1)                     // Expect pass
    #1;
    `ASSERT_TRUE_LOG(0, "a message")    // Expect fail
    #1;
    `ASSERT_FALSE(!(1'b0))              // Expect fail
    #1;
    `ASSERT_FALSE(0)                    // Expect pass
    #1;
    `ASSERT_FALSE_LOG(1, "another msg") // Expect pass
    #1;
    `ASSERT_EQ(3 + 2, 1+6)              // Expect fail
    #1;
    `ASSERT_EQ(3'b110, 3'b1x0)          // Expect fail
    #1;
    `ASSERT_EQ(4'b1100, 4'bxxxx)        // Expect fail
    #1;
    `ASSERT_EQ(3'b1x0, 3'b1x0)          // Expect pass
    #1;
    `ASSERT_NE(3 + 3, 1+2)              // Expect pass
    #1;
    `ASSERT_NE(3'b1x0, 3'b1x0)          // Expect fail
    #1;
    `ASSERT_NE(3'b110, 3'b1x0)          // Expect pass
    #1;
    `ASSERT_STR_EQ("foo", "bar")        // Expect fail
    #1;
    `ASSERT_STR_EQ("foo", "foo")        // Expect pass
    #1;
    `ASSERT_STR_NE("foo", "bar")        // Expect pass
    #1;
    `ASSERT_STR_NE("foo", "foo")        // Expect fail
    #1;
    `ASSERT_NULL(non_null_handle)       // Expect fail
    #1;
    `ASSERT_NULL(null_handle)           // Expect pass
    #1;
    `ASSERT_NOT_NULL(non_null_handle)   // Expect pass
    #1;
    `ASSERT_NOT_NULL(null_handle)       // Expect fail
    #1;
    `ASSERT_GT(3+2, 4+2)                // Expect fail
    #1;
    `ASSERT_GT(3 + 2, 4 + 1)            // Expect fail
    #1;
    `ASSERT_GT(7, 6)                    // Expect pass
    #1;
    `ASSERT_GE(3+2, 4+2)                // Expect fail
    #1;
    `ASSERT_GE(3 + 2, 4 + 1)            // Expect pass
    #1;
    `ASSERT_GE(7, 6)                    // Expect pass
    #1;
    `ASSERT_LT(4+2, 3+2)                // Expect fail
    #1;
    `ASSERT_LT(3 + 2, 4 + 1)            // Expect fail
    #1;
    `ASSERT_LT(6, 7)                    // Expect pass
    #1;
    `ASSERT_LE(4+2, 3+2)                // Expect fail
    #1;
    `ASSERT_LE(3 + 2, 4 + 1)            // Expect pass
    #1;
    `ASSERT_LE(6, 7)                    // Expect pass
    #1;
    `ASSERT_HAS(int, i_arr, item == 1)  // Expect fail
    #1;
    `ASSERT_HAS(int, {2, 3}, item == 1) // Expect fail
    #1;
    `ASSERT_HAS(int, i_arr, item == 2)  // Expect pass
    #1;
    `ASSERT_HAS(int, {1, 3}, item == 3) // Expect pass
    #1;
    str = "four";
    `ASSERT_HAS(string, s_q, item == str) // Expect fail
    #1;
    str = "ten";
    `ASSERT_HAS(string, s_q, item == str) // Expect pass
    #1;
    `ASSERT_DOES_NOT_HAVE(int, i_arr, item == 1)  // Expect pass
    #1;
    `ASSERT_DOES_NOT_HAVE(int, {2, 3}, item == 1) // Expect pass
    #1;
    `ASSERT_DOES_NOT_HAVE(int, i_arr, item == 2)  // Expect fail
    #1;
    `ASSERT_DOES_NOT_HAVE(int, {1, 3}, item == 3) // Expect fail
`END_RUN_PHASE_TEST

