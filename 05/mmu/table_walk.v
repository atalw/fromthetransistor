module table_walk();

    always @(posedge in_clk) begin
        if (in_en) begin
            // Enable ram read for the TTB
            r_out_ram_ren <= 1
            // if we've got the TTB, do the first level descriptor fetch
            if (in_ram_data && ~r_l1d) begin
                // r_l1d = {in_ram_data[31:14], in_mva[31:20], 2'b00};
                r_l1d = {in_ram_data[13:6], in_mva[13:9], 2'b01};
                r_out_ram_addr = r_l1d;
            end 
            // after first level fetch, do second level fetch
            else if (in_ram_data && r_l1d && ~rl2d) begin
                r_page_table_desc = in_ram_data;
                r_l2d = {r_page_table_desc[13:5],in_mva[5:3], 2'b01};
            end
        end else begin
            r_out_ram_ren <= 0
        end
    end

endmodule
