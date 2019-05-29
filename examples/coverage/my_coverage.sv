module my_cov (
    input reset,
    input clk,
    input ev,
    output integer ev_count
);

    covergroup cg();
        option.per_instance = 1;
        option.comment = "Coverage for events per clock cycle";
        cp_ev_count: coverpoint ev_count iff (!reset) {
            bins zero = {0};
            bins a_few[] = {[1:2]};
            bins more = {[3:$]};
        }
    endgroup

    cg cg_inst;
    initial cg_inst = new();

    task clk_thread();
        forever begin
            @(posedge clk);
            cg_inst.sample();
            ev_count = 0;
        end
    endtask

    task ev_thread();
        forever begin
            @(posedge ev);
            if (!reset) begin
                #0; // clk_thread wins race
                ev_count++;
            end
        end
    endtask

    task reset_thread();
        forever begin
            @(posedge reset);
            ev_count = 0;
        end
    endtask

    initial begin
        ev_count = 0;
        fork
            reset_thread();
            clk_thread();
            ev_thread();
        join_none
    end

endmodule
