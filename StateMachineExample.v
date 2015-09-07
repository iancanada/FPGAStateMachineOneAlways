/**
  ******************************************************************************
  * File Name          : StateMachineExample.v
  * Date of create     : 2015-04-11
  * Author             : Ian Jin  
  *                    : iancanada.mail@gmail.com
  *                    : Twitter: @iancanadaTT
  * Description        : good example of one segment state macchine (FSM)
  *                      with intexed coding
  ******************************************************************************
  *
  * COPYRIGHT(c) Ian Jin
  */

module SourceSelectionControl(input reset,                //system reset
		              input clk,                  //system clock
			      input select,               //selection jumper, high as default duo to internal weak pull-up
			      output reg selectionresult, //slection result after removing vibration
                              output reg selectionchanged //changed flag, 65536 clock signal width to indicate selection has just been changed
			      );
reg[15:0] counter;           //count the mclk to run state machin at very low speed

//run 16bit counter,the max time for for 49.1520 clk is 65535/49.1520M=1.33ms
always@(posedge clk or negedge reset)
begin
  if(!reset)
    counter<=16'd0;
  else
    counter<=counter+16'd1;
end

//FSM in one always style with indexed coding
reg[4:0] state;
parameter[4:0] BEGIN   =0,
               SELECT1 =1,
	       CHANGE1 =2,
	       SELECT0 =3,
	       CHANGE0 =4;

//FSM in one always style with indexed code
always@(posedge clk or negedge reset)
begin
  if(!reset) begin
    selectionresult<=0;                      //power up default is 0
    selectionchanged<=0;                     //power up default is 0
    state<=BEGIN;
  end
  else begin
    if(counter==0) begin                     //run state machine at moment of each time counter==0
	   case(state)
		  BEGIN: begin
		    selectionresult<=selectionresult;  //keep selection result no change 
		    selectionchanged<=1;               //indicate slection changed to perform frontend reset, 1 only in here, in all other states is 0
		    state<=select? SELECT1:SELECT0;    //next state decided by select input
		    end
                  SELECT1: begin
		    selectionresult<=1;
	            selectionchanged<=0;
		    state<=select? SELECT1:CHANGE1;
		    end
                  CHANGE1: begin
		    selectionresult<=1;
	            selectionchanged<=0;
		    state<=select? SELECT1:BEGIN;		  
		    end
                  SELECT0: begin
		    selectionresult<=0;
		    selectionchanged<=0;
		    state<=select? CHANGE0:SELECT0;		  
		    end
                  CHANGE0: begin
		    selectionresult<=0;
		    selectionchanged<=0;
		    state<=select? BEGIN:SELECT0;		  		  
		    end   		
	   endcase
     end
     else begin                               //keep everything no change for all other moment counter!=0
	   state<=state;
	   selectionresult<=selectionresult;
	   selectionchanged<=selectionchanged;
     end
  end
end	
								  
endmodule

