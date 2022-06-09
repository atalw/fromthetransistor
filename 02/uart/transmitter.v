module transmitter
    #(parameter CLOCKS_PER_BIT = 0)
    (
        input wire clock,
        input wire tx_bit,
        input [7:0] tx_data_byte,
        output reg serial,
        output wire tx_done
    );

    parameter IDLE_STATE = 3'b000;
    parameter START_STATE = 3'b001;
    parameter DATA_STATE = 3'b010;
    parameter STOP_STATE = 3'b100;
    parameter CLEANUP_STATE = 3'b101;

    reg [8:0] r_clock_count;
    reg [2:0] r_tx_state;
    reg [2:0] r_bit_index;
    reg [7:0] r_tx_byte;
    reg r_tx_done;

    initial
    begin
        r_clock_count = 0;
        r_tx_state = 3'b0;
        r_bit_index = 0;
        r_tx_done = 0;
    end

    always @(posedge clock)
    begin
        case (r_tx_state)
            IDLE_STATE:
            begin
                serial = 1'b1; // Drive line HIGH
                r_tx_done = 1'b0;
                r_bit_index = 0;

                if (tx_bit == 1'b1) // idle active bit
                begin
                    r_tx_byte <= tx_data_byte;
                    r_tx_state <= START_STATE;
                end
                else
                    r_tx_state <= IDLE_STATE;
            end // IDLE_STATE

            START_STATE:
            begin
                serial = 1'b0; // start bit = 0

                if (r_clock_count < CLOCKS_PER_BIT)
                    r_clock_count <= r_clock_count + 1;
                else
                begin
                    r_clock_count <= 0;
                    r_tx_state <= DATA_STATE;
                end
            end // START_STATE

            DATA_STATE:
            begin
                serial <= r_tx_byte[r_bit_index];

                if (r_clock_count < CLOCKS_PER_BIT)
                    r_clock_count <= r_clock_count + 1;
                else
                begin
                    r_clock_count <= 0;
                    if (r_bit_index == 7)
                    begin
                        r_bit_index <= 0;
                        r_tx_state <= STOP_STATE;
                    end
                    else
                        r_bit_index <= r_bit_index + 1;
                end
            end // DATA_STATE

            STOP_STATE:
            begin
                serial <= 1'b1;

                if (r_clock_count < CLOCKS_PER_BIT)
                    r_clock_count <= r_clock_count + 1;
                else
                begin
                    r_clock_count <= 0;
                    r_tx_state <= CLEANUP_STATE;
                end
            end // STOP_STATE

            CLEANUP_STATE:
            begin
                r_tx_done <= 1'b1;
                r_tx_state <= IDLE_STATE;
            end // CLEANUP_STATE

            default:
                r_tx_state <= IDLE_STATE;
        endcase
    end

    assign tx_done = r_tx_done;
endmodule
