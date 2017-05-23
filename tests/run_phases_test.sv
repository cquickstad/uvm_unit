`include "uvm_unit.svh"

class component_with_all_phases extends uvm_component;
    `uvm_component_utils(component_with_all_phases)
    function new(string name="component_with_all_phases", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    `define FUNC_PHASE_HELPER(PHNAME)                                           \
    virtual function void ``PHNAME``_phase(uvm_phase phase);                    \
        super.``PHNAME``_phase(phase);                                          \
        `uvm_info(get_name(), {"message from ", phase.get_name()}, UVM_NONE)    \
    endfunction

    `FUNC_PHASE_HELPER(build)
    `FUNC_PHASE_HELPER(connect)
    `FUNC_PHASE_HELPER(end_of_elaboration)
    `FUNC_PHASE_HELPER(extract)
    `FUNC_PHASE_HELPER(check)
    `FUNC_PHASE_HELPER(report)
    `FUNC_PHASE_HELPER(final)

    `define TASK_PHASE_HELPER(PHNAME)                                           \
    virtual task ``PHNAME``_phase(uvm_phase phase);                             \
        super.``PHNAME``_phase(phase);                                          \
        phase.raise_objection(this);                                            \
        #1;                                                                     \
        `uvm_info(get_name(), {"message from ", phase.get_name()}, UVM_NONE)    \
        phase.drop_objection(this);                                             \
    endtask

    `TASK_PHASE_HELPER(run)

    `TASK_PHASE_HELPER( pre_reset)
    `TASK_PHASE_HELPER(     reset)
    `TASK_PHASE_HELPER(post_reset)

    `TASK_PHASE_HELPER( pre_configure)
    `TASK_PHASE_HELPER(     configure)
    `TASK_PHASE_HELPER(post_configure)

    `TASK_PHASE_HELPER( pre_main)
    `TASK_PHASE_HELPER(     main)
    `TASK_PHASE_HELPER(post_main)

    `TASK_PHASE_HELPER( pre_shutdown)
    `TASK_PHASE_HELPER(     shutdown)
    `TASK_PHASE_HELPER(post_shutdown)
endclass

class fixture extends uvm_unit_pkg::uvm_unit_fixture;
    component_with_all_phases cut;
    `uvm_component_utils(fixture)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cut = component_with_all_phases::type_id::create("cut", this);
    endfunction
endclass

`RUN_PHASE_TEST_F(fixture, phase_test_1)
    #20;
    `uvm_info(get_name(), "message from run phase test 1", UVM_NONE)
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fixture, phase_test_2)
    #20;
    `uvm_info(get_name(), "message from run phase of test 2", UVM_NONE)
`END_RUN_PHASE_TEST

