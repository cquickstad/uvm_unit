class pkt extends uvm_object;
    byte x;
    `uvm_object_utils_begin(pkt)
        `uvm_field_int(x, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name="pkt");
        super.new(name);
    endfunction
endclass
