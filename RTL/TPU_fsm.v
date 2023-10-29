module TPU_fsm
#(  parameter ADDR_BITS=16, 
	parameter DATA_BITS=32,
	parameter DATAC_BITS=128,
	parameter S0 = 3'b000,
	parameter S1 = 3'b001,
	parameter S2 = 3'b010,
	parameter S3 = 3'b011,
	parameter S4 = 3'b100,
	parameter S5 = 3'b101,
	parameter S6 = 3'b110
)
(
	// Global Signals 
	input   wire                     	clk,
	input   wire                     	rst_n,
	output  wire [2:0] 			 	    state_TPU_o,
    input            					in_valid,
	input								done,
    input [7:0]      					K,
    input [7:0]     					M,
    input [7:0]      					N,


    output     							busy,
    output      						sa_rst_n,

	output      						A_wr_en,
	output [15:0]    					A_index,
	input  [31:0]    					A_data_out,
	
	output      						B_wr_en,
	output [15:0]    					B_index,
	input  [31:0]    					B_data_out,
    
	output      						C_wr_en,
    output  [ADDR_BITS-1:0]    			C_index,
    output  [DATAC_BITS-1:0]    		C_data_in,

	output [DATA_BITS-1:0] local_buffer_A0,
	output [DATA_BITS-1:0] local_buffer_A1,
	output [DATA_BITS-1:0] local_buffer_A2,
	output [DATA_BITS-1:0] local_buffer_A3,
	output [DATA_BITS-1:0] local_buffer_B0,
	output [DATA_BITS-1:0] local_buffer_B1,
	output [DATA_BITS-1:0] local_buffer_B2,
	output [DATA_BITS-1:0] local_buffer_B3,

	input [DATAC_BITS-1:0] local_buffer_C0,
	input [DATAC_BITS-1:0] local_buffer_C1,
	input [DATAC_BITS-1:0] local_buffer_C2,
	input [DATAC_BITS-1:0] local_buffer_C3
);
begin
	reg [15:0]				 			i, j;
	reg [2:0] 							state;
	assign state_o = state;
	
	reg A_wr_en_temp;
	reg B_wr_en_temp;
	reg C_wr_en_temp;
	reg busy_temp;
	reg sa_rst_n_temp;
	
	wire [DATAC_BITS-1:0] result[3:0];
	
	assign result[0] = local_buffer_C0;
	assign result[1] = local_buffer_C1;
	assign result[2] = local_buffer_C2;
	assign result[3] = local_buffer_C3;

	reg [DATA_BITS-1:0]	local_buffer_A[3:0];
	reg [DATA_BITS-1:0]	local_buffer_B[3:0];

	assign A_wr_en = A_wr_en_temp;
	assign B_wr_en = B_wr_en_temp;
	assign C_wr_en = C_wr_en_temp;
	assign busy = busy_temp;	
	assign sa_rst_n = sa_rst_n_temp;


	reg [ADDR_BITS-1:0]    			A_index_temp;
	reg [ADDR_BITS-1:0]    			B_index_temp;
	reg [ADDR_BITS-1:0]    			C_index_temp;
	reg [DATAC_BITS-1:0]			C_data_in_temp;

	assign	A_index = A_index_temp;
	assign	B_index = B_index_temp;
	assign	C_index = C_index_temp;
	assign 	C_data_in = C_data_in_temp;


	assign local_buffer_A0 = local_buffer_A[0];
	assign local_buffer_A1 = local_buffer_A[1];
	assign local_buffer_A2 = local_buffer_A[2];
	assign local_buffer_A3 = local_buffer_A[3];

	assign local_buffer_B0 = local_buffer_B[0];
	assign local_buffer_B1 = local_buffer_B[1];
	assign local_buffer_B2 = local_buffer_B[2];
	assign local_buffer_B3 = local_buffer_B[3];


	always@(negedge clk) begin
		if (!rst_n) begin
			state <= S0;
		end else begin
			case(state)
				S0: begin
					if (in_valid) begin
						state <= S1;
					end
					else begin
						state <= S0;
					end
				end
				S1: begin
					if (i == 4) begin
						state <= S3;
					end
					else begin
						state <= S2;
					end
				end
				S2: begin
					state <= S1;
				end
				S3: begin
					if (done) begin
						state <= S4;
					end
					else begin
						state <= S3;
					end
				end
				S4: begin
					if (j == 4) begin
						state <= S0;
					end
					else begin
						state <= S5;
					end
				end
				S5: begin
					state <= S4;
				end
				default: begin 
					state <= S0;
				end
			endcase
		end
	end
	
	// Set output value
	always @(posedge clk) begin
		case(state)
			S0: begin
				A_wr_en_temp <= 1'b0;
				B_wr_en_temp <= 1'b0;
				C_wr_en_temp <= 1'b0;
				busy_temp <= 1'b0;
				sa_rst_n_temp <= 1'b0;
				i=0;
				j=0;
			end
			S1: begin
				A_wr_en_temp <= 1'b0;
				B_wr_en_temp <= 1'b0;
				C_wr_en_temp <= 1'b0;
				busy_temp <= 1'b0;
				sa_rst_n_temp <= 1'b0;

				A_index_temp <= i;
				B_index_temp <= i;
			end
			S2: begin
				A_wr_en_temp <= 1'b0;
				B_wr_en_temp <= 1'b0;
				C_wr_en_temp <= 1'b0;
				busy_temp <= 1'b0;
				sa_rst_n_temp <= 1'b0;


				local_buffer_A[i] <= A_data_out;
				local_buffer_B[i] <= B_data_out;
				i <= i + 1;
			end
			S3: begin
				A_wr_en_temp <= 1'b0;
				B_wr_en_temp <= 1'b0;
				C_wr_en_temp <= 1'b0;
				busy_temp <= 1'b1;
				sa_rst_n_temp <= 1'b1;
			end
			S4: begin
				A_wr_en_temp <= 1'b0;
				B_wr_en_temp <= 1'b0;
				C_wr_en_temp <= 1'b1;
				busy_temp <= 1'b1;
				sa_rst_n_temp <= 1'b1;

				C_index_temp = j;
			end
			S5: begin
				A_wr_en_temp <= 1'b0;
				B_wr_en_temp <= 1'b0;
				C_wr_en_temp <= 1'b1;
				busy_temp <= 1'b1;
				sa_rst_n_temp <= 1'b1;

				C_data_in_temp <= result[j];
				j <= j + 1;
			end
		endcase
	end


	
end
endmodule