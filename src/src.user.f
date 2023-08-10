
   ../src/project_define.svh

// files from Efabless Caravel SOC
   ../../../fork/caravel/verilog/rtl/defines.v
   ../../../fork/caravel/verilog/rtl/user_defines.v

// -------------------------------------------------
// User Project Wrapper
// ../../../fork/caravel/verilog/rtl/debug_regs.v
// ../../../fork/caravel/verilog/rtl/__user_project_wrapper.v
-f ../../fsic_fpga/rtl/user/rtl/rtl.f

// ../../../fork/caravel/verilog/rtl/housekeeping_spi.v
   ../src/housekeeping_spi.v
   ../../../fork/caravel/verilog/rtl/housekeeping.v

   ../../../fork/caravel/verilog/rtl/mgmt_protect_hv.v
   ../../../fork/caravel/verilog/rtl/mgmt_protect.v

   ../../../fork/caravel/verilog/rtl/clock_div.v
// ../../../fork/caravel/verilog/rtl/caravel_clocking.v
   ../../caravel_user_project/caravel/verilog/rtl/caravel_clocking.v

   ../../../fork/caravel/verilog/rtl/buff_flash_clkrst.v


// ../../../fork/caravel/verilog/rtl/ring_osc2x13.v
   ../src/ring_osc2x13.v

// ../../../fork/caravel/verilog/rtl/digital_pll_controller.v
   ../src/digital_pll_controller.v

   ../../../fork/caravel/verilog/rtl/digital_pll.v

   ../../../fork/caravel/verilog/rtl/gpio_logic_high.v
   ../../../fork/caravel/verilog/rtl/gpio_signal_buffering.v

// ../../../fork/caravel/verilog/rtl/ibex_all.v

// copy from caravel_mgmt_soc_litex
// ../../../fork/caravel_mgmt_soc_litex/verilog/rtl/picorv32.v
// ../src/picorv32.v

// copy from caravel_mgmt_soc_litex
// ../../../fork/caravel_mgmt_soc_litex/verilog/rtl/VexRiscv_LiteDebug.v
// ../../../fork/caravel_mgmt_soc_litex/verilog/rtl/VexRiscv_MinDebugCache.v
// ../../../fork/caravel_mgmt_soc_litex/verilog/rtl/VexRiscv_MinDebug.v
   ../src/VexRiscv_MinDebug.v

   ../../../fork/caravel/verilog/rtl/mprj_logic_high.v
   ../../../fork/caravel/verilog/rtl/mprj2_logic_high.v

// ../../../fork/caravel_mgmt_soc_litex/verilog/rtl/mgmt_core.v
// ../src/mgmt_core.v
// ../../caravel_user_project/mgmt_core_wrapper/verilog/rtl/mgmt_core.v
   ../src/mgmt_core.patrick.v
//
// ../../../fork/caravel_mgmt_soc_litex/verilog/rtl/mgmt_core_wrapper.v
// ../src/mgmt_core_wrapper.v
   ../../caravel_user_project/mgmt_core_wrapper/verilog/rtl/mgmt_core_wrapper.v

   ../../../fork/caravel/verilog/rtl/pads.v

   ../../../fork/caravel/verilog/rtl/mprj_io_buffer.v
// ../../../fork/caravel/verilog/rtl/mprj_io.v
   ../src/mprj_io.v
   ../../../fork/caravel/verilog/rtl/chip_io.v

   ../../../fork/caravel/verilog/rtl/gpio_defaults_block.v
// ../../../fork/caravel/verilog/rtl/gpio_control_block.v
   ../src/gpio_control_block.v

   ../../../fork/caravel/verilog/rtl/constant_block.v
   ../../../fork/caravel/verilog/rtl/user_id_programming.v
   ../../../fork/caravel/verilog/rtl/simple_por.v
   ../../../fork/caravel/verilog/rtl/xres_buf.v
   ../../../fork/caravel/verilog/rtl/spare_logic_block.v
   ../../../fork/caravel/verilog/rtl/caravel_power_routing.v
   ../../../fork/caravel/verilog/rtl/copyright_block.v
   ../../../fork/caravel/verilog/rtl/caravel_motto.v
   ../../../fork/caravel/verilog/rtl/caravel_logo.v
   ../../../fork/caravel/verilog/rtl/open_source.v
   ../../../fork/caravel/verilog/rtl/user_id_textblock.v

   ../../../fork/caravel/verilog/rtl/empty_macro.v
   ../../../fork/caravel/verilog/rtl/manual_power_connections.v
// ../../../fork/caravel/verilog/rtl/caravel_core.v
// ../src/caravel_core.v
// ../../../fork/caravel/verilog/rtl/caravel.v
//tony_debug use caravel.v in local  ../../caravel_user_project/caravel/verilog/rtl/caravel.v
