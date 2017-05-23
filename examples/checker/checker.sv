class chkr extends uvm_subscriber #(pkt);
    `uvm_component_utils(chkr)

    bit     seven_seen;
    pkt     last_pkt;

    function new(string name="chkr", uvm_component parent=null);
        super.new(name, parent);
        seven_seen = 0;
    endfunction

    virtual function void write(pkt t);
        if (t == null) begin
            `uvm_warning("NULL_PKT", "Got a null pkt in through the analysis port!")
            return;
        end
        seven_seen = (t.x == 7);
        odd_even_check(t);
    endfunction

    virtual function void odd_even_check(pkt t);
        if (last_pkt == null) begin
            void'($cast(last_pkt, t.clone()));
        end else begin
            if (t.x != last_pkt.x) `uvm_error("NO_EVEN_ODD_MATCH", "")
            last_pkt = null;
        end
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (seven_seen) `uvm_error("SEVEN_SEEN", "A 7 was seen during run_phase.")
    endfunction
endclass
