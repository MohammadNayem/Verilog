`timescale 1ns / 1ps


module digital_clock(
    input clock,
    input reset,
    output a,
    output b,
    output c,
    output d,
    output e,
    output f,
    output g,
    output DP,
    output [7:0]AN
    );
  
reg [3:0]secs_L; //register for the first digit
reg [3:0]secs_M; 
reg [3:0]mins_L;
reg [3:0]mins_M;
reg [3:0]hours_L;
reg [3:0]hours_M;

reg [22:0] delay; //register to produce the 0.1 second delay
wire test;

//always @ (posedge clock or posedge reset)
// begin
//  if (reset)
//   delay <= 0;
//  else
//   delay <= delay + 1;
// end
 
//assign test = &delay; //AND each bit of delay with itself; test will be high only when all bits of delay are high
wire clk_1hz;
Clock_divider box1(.clock_in(clock), .clock_out(clk_1hz));

always @ (posedge clk_1hz or posedge reset)
 begin
    if(reset == 1'b1)begin          // incase of reset hours:mins:secs => 00: 00: 00
         hours_M <= 0;
         hours_L <= 0;
         mins_M <= 0;
         mins_L <= 0;
         secs_M <= 0; 
         secs_L <= 0; end
     else  if(secs_L==4'd9)begin
             secs_L <= 0; 
             
             
             if(secs_M == 4'd5)begin
                secs_M <= 0;
                
                
                if(mins_L == 4'd9)begin
                    mins_L <= 0;
                    
                    
                    if(mins_M == 4'd5) begin
                        mins_M <= 0;
                        
                        
                        if(hours_L == 4'd9) begin
                            hours_L <= 0;
                            
                            
                            if(hours_M == 2) begin
                                hours_M <= 0;
                                
                            end
                            else
                                hours_M <= hours_M + 1;
                        end
                        else
                            hours_L <= hours_L + 1;
                    end
                    else
                        mins_M <= mins_M + 1;
                end
                else
                    mins_L <= mins_L +1;
             end
             else
                secs_M <= secs_M + 1;   
     end
     else
        secs_L <= secs_L + 1; 
 end
  
//Multiplexing circuit below

localparam N = 18; 

reg [N-1:0]count;

always @ (posedge clock or posedge reset)
 begin
  if (reset)
   count <= 0;
  else
   count <= count + 1;
 end

reg [6:0]sseg;
reg [7:0]an_temp;
always @ (*)
 begin
  case(count[N-1:N-3])
   
   3'b000 : 
    begin
     sseg = secs_L;
     an_temp = 8'b11111110;
    end
   
   3'b001:
    begin
     sseg = secs_M;
     an_temp = 8'b11111101;
    end
   
   3'b010:
    begin
     sseg = mins_L; //unknown sent to produce '-'
     an_temp = 8'b11111011;
    end
    
   3'b011:
    begin
     sseg = mins_M; //unknown sent to produce '-'
     an_temp = 8'b11110111;
    end
    
    3'b100:
     begin
      sseg = hours_L; //unknown sent to produce '-'
      an_temp = 8'b11101111;
     end
     
     3'b101:
      begin
       sseg = hours_M; //unknown sent to produce '-'
       an_temp = 8'b11011111;
      end
      
     3'b110:
      begin
       sseg = mins_M; //unknown sent to produce '-'
       an_temp = 8'b11110111;
      end 
  endcase
 end
assign AN = an_temp;

reg [6:0] sseg_temp; 
always @ (*)
 begin
  case(sseg)
   4'd0 : sseg_temp = 7'b1000000; //0
   4'd1 : sseg_temp = 7'b1111001; //1
   4'd2 : sseg_temp = 7'b0100100; //2
   4'd3 : sseg_temp = 7'b0110000; //3
   4'd4 : sseg_temp = 7'b0011001; //4
   4'd5 : sseg_temp = 7'b0010010; //5
   4'd6 : sseg_temp = 7'b0000010; //6
   4'd7 : sseg_temp = 7'b1111000; //7
   4'd8 : sseg_temp = 7'b0000000; //8
   4'd9 : sseg_temp = 7'b0010000; //9
   default : sseg_temp = 7'b0111111; //dash
  endcase
 end
assign {g, f, e, d, c, b, a} = sseg_temp; 
assign DP = 1'b1; //we dont need the decimal here so turn all of them off



endmodule



// Clock divider module
module Clock_divider(clock_in,clock_out);
input clock_in; 
output reg clock_out; 
reg[27:0] counter=28'd0;
parameter DIVISOR = 28'd100000000;   //To got the 1Hz clk pulse. FPGA clk pulse => 100MHz . so divisor should be 100,000000

always @(posedge clock_in)
begin
 counter <= counter + 28'd1;
 if(counter>=(DIVISOR-1))
  counter <= 28'd0;
  clock_out <= (counter<DIVISOR/2)?1'b1:1'b0;
end
endmodule


