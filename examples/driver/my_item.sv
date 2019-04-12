class my_item extends uvm_sequence_item;
    rand int foo;

    `uvm_object_utils(my_item)

    function new(string name="my_item");
        super.new(name);
    endfunction
endclass
