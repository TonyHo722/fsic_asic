// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

/*
`define UNIT_DELAY         #1
`define USE_POWER_PINS
`define SIM_TIME           100_000

`include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
`include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"

`include "libs.ref/sky130_fd_sc_hvl/verilog/primitives.v"
`include "libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v"

`include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
`include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"

`include "libs.ref/sky130_fd_sc_hvl/verilog/primitives.v"
`include "libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v"

`include "libs.ref/sky130_fd_io/verilog/sky130_fd_io.v"
`include "libs.ref/sky130_fd_io/verilog/sky130_ef_io.v"
`include "libs.ref/sky130_fd_io/verilog/sky130_ef_io__gpiov2_pad_wrapped.v"

*/

// `include "defines.v
// `include "__uprj_netlists.v"
// `include "caravel_netlists.v"
// `include "spiflash.v"

// ------------------------------------------------------------------------------

`include "project_define.svh"

module top_bench #( parameter BITS=32,
		parameter pSERIALIO_WIDTH   = 12,
		parameter pADDR_WIDTH   = 15,
		parameter pDATA_WIDTH   = 32,
		parameter IOCLK_Period	= 10,
		// parameter DLYCLK_Period	= 1,
		parameter SHIFT_DEPTH = 5,
		parameter pRxFIFO_DEPTH = 5,
		parameter pCLK_RATIO = 4
	)
(
);
  `include "bench_ini.svh"
		localparam CoreClkPhaseLoop	= 1;
		localparam UP_BASE=32'h3000_0000;
		localparam AA_BASE=32'h3000_2000;
		localparam IS_BASE=32'h3000_3000;

		localparam SOC_to_FPGA_MailBox_Base=28'h000_2000;
		localparam FPGA_to_SOC_AA_BASE=28'h000_2000;
		localparam FPGA_to_SOC_IS_BASE=28'h000_3000;
		
		localparam AA_MailBox_Reg_Offset=12'h000;
		localparam AA_Internal_Reg_Offset=12'h100;
		
		localparam TUSER_AXIS = 2'b00;
		localparam TUSER_AXILITE_WRITE = 2'b01;
		localparam TUSER_AXILITE_READ_REQ = 2'b10;
		localparam TUSER_AXILITE_READ_CPL = 2'b11;

		localparam TID_DN_UP = 2'b00;
		localparam TID_DN_AA = 2'b01;
		localparam TID_UP_UP = 2'b00;
		localparam TID_UP_AA = 2'b01;
		localparam TID_UP_LA = 2'b10;

  wire        gpio;
  wire [37:0] mprj_io;
  wire        flash_csb;
  wire        flash_clk;
  wire        flash_io0;
  wire        flash_io1;
  wire        SDO;

	reg fpga_rst;
	//reg soc_resetb;		//POR reset
	reg fpga_resetb;	//POR reset	
	wire fpga_coreclk;

	//write addr channel
	reg fpga_axi_awvalid;
	reg [pADDR_WIDTH-1:0] fpga_axi_awaddr;
	wire fpga_axi_awready;
	
	//write data channel
	reg 	fpga_axi_wvalid;
	reg 	[pDATA_WIDTH-1:0] fpga_axi_wdata;
	reg 	[3:0] fpga_axi_wstrb;
	wire	fpga_axi_wready;
	
	//read addr channel
	reg 	fpga_axi_arvalid;
	reg 	[pADDR_WIDTH-1:0] fpga_axi_araddr;
	wire 	fpga_axi_arready;
	
	//read data channel
	wire 	fpga_axi_rvalid;
	wire 	[pDATA_WIDTH-1:0] fpga_axi_rdata;
	reg 	fpga_axi_rready;
	
	reg 	fpga_cc_is_enable;		//axi_lite enable

	wire [pSERIALIO_WIDTH-1:0] soc_serial_txd;
	wire soc_txclk;
	wire fpga_txclk;
	
	reg [pDATA_WIDTH-1:0] fpga_as_is_tdata;
	reg [3:0] fpga_as_is_tstrb;
	reg [3:0] fpga_as_is_tkeep;
	reg fpga_as_is_tlast;
	reg [1:0] fpga_as_is_tid;
	reg fpga_as_is_tvalid;
	reg [1:0] fpga_as_is_tuser;
	reg fpga_as_is_tready;		//when local side axis switch Rxfifo size <= threshold then as_is_tready=0; this flow control mechanism is for notify remote side do not provide data with is_as_tvalid=1

	wire [pSERIALIO_WIDTH-1:0] fpga_serial_txd;
//	wire [7:0] fpga_Serial_Data_Out_tdata;
//	wire fpga_Serial_Data_Out_tstrb;
//	wire fpga_Serial_Data_Out_tkeep;
//	wire fpga_Serial_Data_Out_tid_tuser;	// tid and tuser	
//	wire fpga_Serial_Data_Out_tlast_tvalid_tready;		//flowcontrol

	wire [pDATA_WIDTH-1:0] fpga_is_as_tdata;
	wire [3:0] fpga_is_as_tstrb;
	wire [3:0] fpga_is_as_tkeep;
	wire fpga_is_as_tlast;
	wire [1:0] fpga_is_as_tid;
	wire fpga_is_as_tvalid;
	wire [1:0] fpga_is_as_tuser;
	wire fpga_is_as_tready;		//when remote side axis switch Rxfifo size <= threshold then is_as_tready=0, this flow control mechanism is for notify local side do not provide data with as_is_tvalid=1



  wire [11:0] checkbits;
  assign      checkbits = uut.mprj_io_out[32:21];

  //wire  [7:0] spivalue;
  //assign      spivalue  = mprj_io[15: 8];

  reg         power1;  // 3.3V
  reg         power2;  // 1.8V

  // External clock is used by default.  Make this artificially fast for the
  // simulation.  Normally this would be a slow clock and the digital PLL
  // would be the fast clock.
  //
  reg clock;
  reg io_clk;   // generated from FPGA in real system

  localparam pSOC_FREQ = 10.0;                 // 10 MHz
  localparam pIOS_FREQ = (pSOC_FREQ * 4.0);    // 40 MHz

  // Timing Order
  // POWER ==> CLOCK ==> RESET

  initial begin
    clock  = 0;
    wait(power2);
    #100;
    forever begin
      #(500.0 / pSOC_FREQ);
      clock = ~clock;
    end
  end

  initial begin
    io_clk  = 0;
    wait(power2);
    #100;
    forever begin
      #(500.0 / pIOS_FREQ);
      io_clk = ~io_clk;
    end
  end

  wire [11:0] rx_dat;
  wire        rx_clk;
  // TBD
  assign #1 rx_clk = io_clk;
  // TBD
  assign #2 rx_dat = 12'h000;


   initial begin
    force uut.mprj_io_in[   37] = io_clk;
    
    force uut.mprj_io_in[   20] = fpga_txclk;
    force uut.mprj_io_in[19: 8] = fpga_serial_txd;

    force soc_txclk = uut.mprj_io_out[   33];
    force soc_serial_txd = uut.mprj_io_out[32: 21];

    
    test002();
    end
  wire ioclk;
  assign ioclk = io_clk;

  initial begin
    $timeformat (-9, 3, " ns", 13);
  //$dumpfile("top_bench.vcd");
  //$dumpvars(0, top_bench);


    repeat (100) begin
      repeat (1000) @(posedge clock);
    //$display("+1000 cycles");
    end

    $display("%c[1;31m",27);
    $display ("Monitor: Timeout, Test Failed");
    $display("%c[0m",27);
    $finish;
  end

  reg RSTB;

  initial begin
    RSTB <= 1'b0;
    wait(power2);
    #400;
    $display("%t MSG %m, Chip Reset# is released ", $time);
    RSTB <= 1'b1;      // Release reset
    #2000;
  end

  initial begin
    power1 <= 1'b0;
    power2 <= 1'b0;
    #200;
    power1 <= 1'b1;
    #200;
    power2 <= 1'b1;
  end

/*
  always @(checkbits) begin
    //#1 $display("GPIO state = %b ", checkbits);
    #1 $display("%t IOCLK = %b, TX_CLK=%b, TXD=%b, RX_CLK=%b, RXD=%b,  ", $time, uut.mprj_io_in[37], uut.mprj_io_out[33], uut.mprj_io_out[32:21], uut.mprj_io_in[20], uut.mprj_io_in[19:8]);
  end
*/

  wire VDD3V3;
  wire VDD1V8;
  wire VSS;
  
  assign VDD3V3 = power1;
  assign VDD1V8 = power2;
  assign VSS    = 1'b0;

  // These are the mappings of mprj_io GPIO pads that are set to
  // specific functions on startup:
  //
  // JTAG      = mgmt_gpio_io[0]              (inout)
  // SDO       = mgmt_gpio_io[1]              (output)
  // SDI       = mgmt_gpio_io[2]              (input)
  // CSB       = mgmt_gpio_io[3]              (input)
  // SCK       = mgmt_gpio_io[4]              (input)
  // ser_rx    = mgmt_gpio_io[5]              (input)
  // ser_tx    = mgmt_gpio_io[6]              (output)
  // irq       = mgmt_gpio_io[7]              (input)


  // move to bench_vec.svh
  // assign mprj_io[3] = 1'b1;  // Force CSB high.

  caravel uut (.vddio     (VDD3V3),
               .vddio_2   (VDD3V3),
               .vssio     (VSS),
               .vssio_2   (VSS),
               .vdda      (VDD3V3),
               .vssa      (VSS),
               .vccd      (VDD1V8),
               .vssd      (VSS),
               .vdda1     (VDD3V3),
               .vdda1_2   (VDD3V3),
               .vdda2     (VDD3V3),
               .vssa1     (VSS),
               .vssa1_2   (VSS),
               .vssa2     (VSS),
               .vccd1     (VDD1V8),
               .vccd2     (VDD1V8),
               .vssd1     (VSS),
               .vssd2     (VSS),
               .clock     (clock),
               .gpio      (gpio),
               .mprj_io   (mprj_io),
               .flash_csb (flash_csb),
               .flash_clk (flash_clk),
               .flash_io0 (flash_io0),
               .flash_io1 (flash_io1),
               .resetb    (RSTB) );


  spiflash #(.FILENAME("riscv.hex")) spiflash ( .csb(flash_csb),
                                              .clk(flash_clk),
                                              .io0(flash_io0),
                                              .io1(flash_io1),
                                              .io2(),          // not used
                                              .io3() );        // not used
	fsic_clock_div fpga_clock_div (
	.resetb(fpga_resetb),
	.in(ioclk),
	.out(fpga_coreclk)
	);

	fpga  #(
		.pSERIALIO_WIDTH(pSERIALIO_WIDTH),
		.pADDR_WIDTH(pADDR_WIDTH),
		.pDATA_WIDTH(pDATA_WIDTH),
		.pRxFIFO_DEPTH(pRxFIFO_DEPTH),
		.pCLK_RATIO(pCLK_RATIO)
	)
	fpga_fsic(
		.axis_rst_n(~fpga_rst),
		.axi_reset_n(~fpga_rst),
		.serial_tclk(fpga_txclk),
		.serial_rclk(soc_txclk),
		.ioclk(ioclk),
		.axis_clk(fpga_coreclk),
		.axi_clk(fpga_coreclk),
		
		//write addr channel
		.axi_awvalid_s_awvalid(fpga_axi_awvalid),
		.axi_awaddr_s_awaddr(fpga_axi_awaddr),
		.axi_awready_axi_awready3(fpga_axi_awready),

		//write data channel
		.axi_wvalid_s_wvalid(fpga_axi_wvalid),
		.axi_wdata_s_wdata(fpga_axi_wdata),
		.axi_wstrb_s_wstrb(fpga_axi_wstrb),
		.axi_wready_axi_wready3(fpga_axi_wready),

		//read addr channel
		.axi_arvalid_s_arvalid(fpga_axi_arvalid),
		.axi_araddr_s_araddr(fpga_axi_araddr),
		.axi_arready_axi_arready3(fpga_axi_arready),
		
		//read data channel
		.axi_rvalid_axi_rvalid3(fpga_axi_rvalid),
		.axi_rdata_axi_rdata3(fpga_axi_rdata),
		.axi_rready_s_rready(fpga_axi_rready),
		
		.cc_is_enable(fpga_cc_is_enable),


		.as_is_tdata(fpga_as_is_tdata),
		.as_is_tstrb(fpga_as_is_tstrb),
		.as_is_tkeep(fpga_as_is_tkeep),
		.as_is_tlast(fpga_as_is_tlast),
		.as_is_tid(fpga_as_is_tid),
		.as_is_tvalid(fpga_as_is_tvalid),
		.as_is_tuser(fpga_as_is_tuser),
		.as_is_tready(fpga_as_is_tready),
		.serial_txd(fpga_serial_txd),
		.serial_rxd(soc_serial_txd),
		.is_as_tdata(fpga_is_as_tdata),
		.is_as_tstrb(fpga_is_as_tstrb),
		.is_as_tkeep(fpga_is_as_tkeep),
		.is_as_tlast(fpga_is_as_tlast),
		.is_as_tid(fpga_is_as_tid),
		.is_as_tvalid(fpga_is_as_tvalid),
		.is_as_tuser(fpga_is_as_tuser),
		.is_as_tready(fpga_is_as_tready)
	);

  reg [31:0] i;
  
	task fpga_apply_reset;
		input real delta1;		// for POR De-Assert
		input real delta2;		// for reset De-Assert
		begin
			#(40);
			$display($time, "=> fpga POR Assert"); 
			fpga_resetb = 0;
			$display($time, "=> fpga reset Assert"); 
			fpga_rst = 1;
			#(delta1);

			$display($time, "=> fpga POR De-Assert"); 
			fpga_resetb = 1;

			#(delta2);
			$display($time, "=> fpga reset De-Assert"); 
			fpga_rst = 0;
		end
	endtask

	task test002;		//test002_fpga_axis_req
		//input [7:0] compare_data;

		begin
			for (i=0;i<CoreClkPhaseLoop;i=i+1) begin
				$display("test002: fpga_axis_req - loop %02d", i);
				fork 
					//soc_apply_reset(40+i*10, 40);			//change coreclk phase in soc
					fpga_apply_reset(40,40);		//fix coreclk phase in fpga
				join
				#40;

				fpga_as_to_is_init();
				
				//soc_cc_is_enable=1;
				fpga_cc_is_enable=1;
				fork 
					//soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
					fpga_cfg_write(0,1,1,0);
				join
				//$display($time, "=> soc rxen_ctl=1");
				$display($time, "=> fpga rxen_ctl=1");

				#400;
				$display($time, "=> wait uut.mprj.u_fsic.U_IO_SERDES0.rxen");
        wait(uut.mprj.u_fsic.U_IO_SERDES0.rxen);
				$display($time, "=> detect uut.mprj.u_fsic.U_IO_SERDES0.rxen=1");
				repeat(4) @(posedge fpga_coreclk);
				fork 
					//soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
					fpga_cfg_write(0,3,1,0);
				join
				//$display($time, "=> soc txen_ctl=1");
				$display($time, "=> fpga txen_ctl=1");

				#200;
				fpga_as_is_tdata = 32'h5a5a5a5a;
				#40;
				#200;

				//test002_fpga_axis_req();		//target to Axis Switch

				#200;
			end
		end
	endtask

	reg[31:0]idx3;

	task test002_fpga_axis_req;
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin
			//tony_Debug force uut.AXIS_SW0.up_as_tready = 1;

			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;
			
			for(idx3=0; idx3<32; idx3=idx3+1)begin		//
				fpga_axis_req(32'h11111111 * (idx3 & 32'h0000_000F), TID_DN_UP);		//target to User Project
				//if (idx3 > 12 ) 			force dut.AXIS_SW0.up_as_tready = 1;
			end
			//tony_Debug release dut.AXIS_SW0.up_as_tready;
			
			$display($time, "=> test002_fpga_axis_req done");
		end
	endtask

	task fpga_axis_req;
		input [31:0] data;
		input [1:0] tid;
		begin
			fpga_as_is_tdata <= data;	//for axis write data
			$strobe($time, "=> fpga_axis_req fpga_as_is_tdata = %x", fpga_as_is_tdata);
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  tid;		//set target
			fpga_as_is_tuser <=  TUSER_AXIS;		//for axis req
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			fpga_as_is_tvalid <= 0;
		
		end
	endtask

	task fpga_as_to_is_init;
		//input [7:0] compare_data;

		begin
			//init fpga as to is signal, set fpga_as_is_tready = 1 for receives data from soc
			@ (posedge fpga_coreclk);
			fpga_as_is_tdata <=  32'h0;
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  TID_DN_UP;
			fpga_as_is_tuser <=  TUSER_AXIS;
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 0;
			fpga_as_is_tready <= 1;
			$display($time, "=> fpga_as_to_is_init done");
		end
	endtask

	task fpga_cfg_write;		//input addr, data, strb and valid_delay 
		input [pADDR_WIDTH-1:0] axi_awaddr;
		input [pDATA_WIDTH-1:0] axi_wdata;
		input [3:0] axi_wstrb;
		input [7:0] valid_delay;
		
		begin
			fpga_axi_awaddr <= axi_awaddr;
			fpga_axi_awvalid <= 0;
			fpga_axi_wdata <= axi_wdata;
			fpga_axi_wstrb <= axi_wstrb;
			fpga_axi_wvalid <= 0;
			//$display($time, "=> fpga_delay_valid before : valid_delay=%x", valid_delay); 
			repeat (valid_delay) @ (posedge fpga_coreclk);
			//$display($time, "=> fpga_delay_valid after  : valid_delay=%x", valid_delay); 
			fpga_axi_awvalid <= 1;
			fpga_axi_wvalid <= 1;
			@ (posedge fpga_coreclk);
			while (fpga_axi_awready == 0) begin		//assume both fpga_axi_awready and fpga_axi_wready assert as the same time.
					@ (posedge fpga_coreclk);
			end
			$display($time, "=> fpga_cfg_write : fpga_axi_awaddr=%x, fpga_axi_awvalid=%b, fpga_axi_awready=%b, fpga_axi_wdata=%x, axi_wstrb=%x, fpga_axi_wvalid=%b, fpga_axi_wready=%b", fpga_axi_awaddr, fpga_axi_awvalid, fpga_axi_awready, fpga_axi_wdata, axi_wstrb, fpga_axi_wvalid, fpga_axi_wready); 
			fpga_axi_awvalid <= 0;
			fpga_axi_wvalid <= 0;
		end
		
	endtask

  wire   uart_tx;
  assign uart_tx = mprj_io[6];


  tbuart tbuart (.ser_rx(uart_tx));  // I

  // -------------------------------------------------------
  `include "bench_vec.svh"

  // -------------------------------------------------------
  `ifdef    CPU_TRACE
  `include "cpu_trace.v"
  `include "dasm.v"
  `endif // CPU_TRACE

endmodule // top_bench

`default_nettype wire
