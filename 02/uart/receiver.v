module receiver
    #(parameter CLOCKS_PER_BIT = 0)
    (
        input wire clock,
        input wire serial,
        output [7:0] w_rx_byte
    );

    parameter IDLE_STATE = 3'b000;
    parameter START_STATE = 3'b001;
    parameter DATA_STATE = 3'b010;
    parameter STOP_STATE = 3'b100;
    parameter CLEANUP_STATE = 3'b101;

    reg [8:0] r_clock_count;
    reg [2:0] r_rx_state;
    reg [2:0] r_bit_index;
    reg [7:0] r_rx_byte;

    initial
    begin
        r_rx_state <= IDLE_STATE;
    end

    always @(posedge clock)
    begin
        case (r_rx_state)
            IDLE_STATE:
            begin
                r_clock_count <= 0;
                r_bit_index <= 0;

                if (serial == 1'b0)
                    r_rx_state <= START_STATE;
            end // IDLE_STATE

            START_STATE:
            begin
                // If the apparent start bit lasts at least one-half of the bit time, it is valid
                // and signals the start of a new character. If not, it is considered a spurious
                // pulse and is ignored.
                if (r_clock_count == CLOCKS_PER_BIT/2)
                begin
                    if (serial == 0)
                    begin
                        r_clock_count <= 0;
                        r_rx_state = DATA_STATE;
                    end
                    else
                        r_rx_state = IDLE_STATE;
                end
                else
                    r_clock_count <= r_clock_count + 1;
            end // START_STATE

            DATA_STATE:
            begin
                if (r_clock_count < CLOCKS_PER_BIT)
                    r_clock_count <= r_clock_count + 1;
                else
                begin
                    r_rx_byte[r_bit_index] = serial;
                    r_clock_count <= 0;

                    if (r_bit_index == 7)
                    begin
                        r_rx_state <= STOP_STATE;
                        r_bit_index <= 0;
                    end
                    else
                        r_bit_index <= r_bit_index + 1;
                end
            end // DATA_STATE

            STOP_STATE:
            begin
                if (r_clock_count < CLOCKS_PER_BIT)
                    r_clock_count <= r_clock_count + 1;
                else
                begin
                    if (serial == 1'b1)
                    begin
                        r_rx_state <= CLEANUP_STATE;
                        r_clock_count <= 0;
                    end
                end
            end // STOP_STATE

            CLEANUP_STATE:
            begin
                r_rx_state <= IDLE_STATE;
            end // CLEANUP_STATE

            default:
                r_rx_state <= IDLE_STATE;
        endcase
    end

    assign w_rx_byte = r_rx_byte;
endmodule
