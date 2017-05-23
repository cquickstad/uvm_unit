class mon extends uvm_component;
    `uvm_component_utils(mon)

    uvm_analysis_port #(pkt)    ap;
    virtual ifc                 mon_ifc;

    function new(string name="mon", uvm_component parent=null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        get_ifc_or_die();
    endfunction

    virtual function void get_ifc_or_die();
        if (uvm_config_db#(virtual ifc)::get(null, "", "mon_ifc", mon_ifc)) begin
            if (mon_ifc == null) begin
                `uvm_fatal("IFC_NULL", "mon_ifc was in the uvm_config_db, but was null.")
            end
        end else begin
            `uvm_fatal("IFC_NOT_IN_DB", "mon_ifc was not in the uvm_config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        fork monitor_thread(); join_none
    endtask

    virtual task monitor_thread();
        if (mon_ifc == null) return;
        forever begin
            pkt     p;
            @(posedge mon_ifc.val);
            p = new();
            p.x = mon_ifc.x;
            ap.write(p);
        end
    endtask
endclass
