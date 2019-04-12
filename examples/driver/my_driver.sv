class my_driver extends uvm_driver #(my_item);
    virtual my_interface vif;

    `uvm_component_utils(my_driver)
    function new(string name="my_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        assert (uvm_config_db#(virtual my_interface)::get(this, "", "ifc", vif) && vif != null)
        else `uvm_fatal("DRIVER_VIF_NOT_FOUND", "Did not find virtual my_interface 'vif' in the uvm_config_db")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        fork drive_thread(); join_none
    endtask

    virtual task drive_thread();
        forever begin
            #1;
            seq_item_port.get(req); // seq_item_port and req are inherited from uvm_driver
            vif.foo = req.foo;
        end
    endtask
endclass
