// Copyright 2020 OpenHW Group
// Copyright 2020 Datum Technology Corporation
// Copyright 2020 Silicon Labs, Inc.
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://solderpad.org/licenses/
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


`ifndef __UVME_CV32E40P_CFG_SV__
`define __UVME_CV32E40P_CFG_SV__


import cv32e40p_pkg::*;
/**
 * Object encapsulating all parameters for creating, connecting and running
 * CV32E40P environment (uvme_cv32e40p_env_c) components.
 */
class uvme_cv32e40p_cfg_c extends uvma_core_cntrl_cfg_c;

   // Integrals
   rand bit                      scoreboarding_enabled;
   rand bit                      cov_model_enabled;
   rand bit                      trn_log_enabled;
   rand int unsigned             sys_clk_period;
   //rand int unsigned             debug_clk_period;

   // Random knobs
   rand bit                   zero_stall_sim; // When randomized to 1, clears is_stall_sim in step and compare
   bit                        max_data_zero_instr_stall; // state variable set by plusarg +max_data_zero_instr_stall

   // Agent cfg handles
   rand uvma_clknrst_cfg_c          clknrst_cfg;
   rand uvma_interrupt_cfg_c        interrupt_cfg;
   rand uvma_debug_cfg_c            debug_cfg;
   rand uvma_obi_memory_cfg_c       obi_memory_instr_cfg;
   rand uvma_obi_memory_cfg_c       obi_memory_data_cfg;
   rand uvma_rvfi_cfg_c#(ILEN,XLEN) rvfi_cfg;
   rand uvma_rvvi_cfg_c#(ILEN,XLEN) rvvi_cfg;
   // Objects
   // TODO Add scoreboard configuration handles
   //      Ex: rand uvml_sb_cfg_c  sb_egress_cfg;
   //          rand uvml_sb_cfg_c  sb_ingress_cfg;


   `uvm_object_utils_begin(uvme_cv32e40p_cfg_c)
      `uvm_field_int (                         enabled                     , UVM_DEFAULT          )
      `uvm_field_enum(uvm_active_passive_enum, is_active                   , UVM_DEFAULT          )
      `uvm_field_int (                         scoreboarding_enabled     , UVM_DEFAULT          )
      `uvm_field_int (                         cov_model_enabled         , UVM_DEFAULT          )
      `uvm_field_int (                         trn_log_enabled           , UVM_DEFAULT          )
      `uvm_field_int (                         sys_clk_period            , UVM_DEFAULT + UVM_DEC)
      //`uvm_field_int (                         debug_clk_period            , UVM_DEFAULT + UVM_DEC)

      `uvm_field_object(clknrst_cfg          , UVM_DEFAULT)
      `uvm_field_object(interrupt_cfg        , UVM_DEFAULT)
      `uvm_field_object(debug_cfg            , UVM_DEFAULT)
      `uvm_field_object(obi_memory_instr_cfg , UVM_DEFAULT)
      `uvm_field_object(obi_memory_data_cfg  , UVM_DEFAULT)
      `uvm_field_object(rvfi_cfg             , UVM_DEFAULT)
      `uvm_field_object(rvvi_cfg             , UVM_DEFAULT)
      // TODO Add scoreboard cfg field macros
      //      Ex: `uvm_field_object(sb_egress_cfg , UVM_DEFAULT)
      //          `uvm_field_object(sb_ingress_cfg, UVM_DEFAULT)
   `uvm_object_utils_end


   constraint defaults_cons {
      soft enabled                == 0;
      soft is_active              == UVM_PASSIVE;
      soft scoreboarding_enabled  == 1;
      soft cov_model_enabled      == 1;
      soft trn_log_enabled        == 1;
      soft sys_clk_period         == uvme_cv32e40p_sys_default_clk_period; // see uvme_cv32e40p_constants.sv
      //soft debug_clk_period       == uvme_cv32e40p_debug_default_clk_period;
   }

   constraint zero_stall_sim_dist_cons {
      zero_stall_sim dist { 0 :/ 2,  1 :/ 1};
   }

   constraint zero_stall_sim_cons {
      if (zero_stall_sim) {
         obi_memory_instr_cfg.drv_slv_gnt_mode    == UVMA_OBI_MEMORY_DRV_SLV_GNT_MODE_CONSTANT;
         obi_memory_instr_cfg.drv_slv_rvalid_mode == UVMA_OBI_MEMORY_DRV_SLV_RVALID_MODE_CONSTANT;
         obi_memory_data_cfg.drv_slv_gnt_mode     == UVMA_OBI_MEMORY_DRV_SLV_GNT_MODE_CONSTANT;
         obi_memory_data_cfg.drv_slv_rvalid_mode  == UVMA_OBI_MEMORY_DRV_SLV_RVALID_MODE_CONSTANT;
      }
   }

   constraint max_data_zero_instr_stall_sim_cons {
      if (max_data_zero_instr_stall) {
         obi_memory_instr_cfg.drv_slv_gnt_mode    == UVMA_OBI_MEMORY_DRV_SLV_GNT_MODE_CONSTANT;
         obi_memory_instr_cfg.drv_slv_rvalid_mode == UVMA_OBI_MEMORY_DRV_SLV_RVALID_MODE_CONSTANT;

         obi_memory_data_cfg.drv_slv_gnt_mode    == UVMA_OBI_MEMORY_DRV_SLV_GNT_MODE_RANDOM_LATENCY;
         obi_memory_data_cfg.drv_slv_gnt_random_latency_min == 0;
         obi_memory_data_cfg.drv_slv_gnt_random_latency_max == 8;

         obi_memory_data_cfg.drv_slv_rvalid_mode == UVMA_OBI_MEMORY_DRV_SLV_RVALID_MODE_RANDOM_LATENCY;
         obi_memory_data_cfg.drv_slv_rvalid_random_latency_min == 0;
         obi_memory_data_cfg.drv_slv_rvalid_random_latency_max == 8;
      }
   }

   constraint cv32e40p_riscv_cons {

      ext_i_supported        == 1;
      ext_c_supported        == 1;
      ext_m_supported        == 1;
      ext_zifencei_supported == 1;
      ext_zicsr_supported    == 1;
      ext_a_supported        == 0;
      ext_p_supported        == 0;
      ext_v_supported        == 0;
      ext_f_supported        == 0;
      ext_d_supported        == 0;

      ext_zba_supported == 0;
      ext_zbb_supported == 0;
      ext_zbc_supported == 0;
      ext_zbs_supported == 0;
      ext_zbe_supported == 0;
      ext_zbf_supported == 0;
      ext_zbm_supported == 0;
      ext_zbp_supported == 0;
      ext_zbr_supported == 0;
      ext_zbt_supported == 0;

      mode_s_supported == 0;
      mode_u_supported == 0;
      pmp_supported == 0;
      debug_supported == 1;

      priv_spec_version       == PRIV_VERSION_MASTER;
      endianness              == ENDIAN_LITTLE;

   }

   constraint default_cv32e40p_boot_cons {
      (!mhartid_plusarg_valid)           -> (mhartid           == 'h0000_0000);
      (!mimpid_patch_plusarg_valid)      -> (mimpid_patch      == 'h0        );
      // (!mimpid_plusarg_valid)            -> (mimpid            == {12'b0, MIMPID_MAJOR, 4'b0, MIMPID_MINOR, 4'b0, mimpid_patch[3:0]}); TODO
      (!mimpid_plusarg_valid)            -> (mimpid            == {12'b0, 4'h0, 4'b0, 4'h0, 4'b0, mimpid_patch[3:0]});
      (!boot_addr_plusarg_valid)         -> (boot_addr         == 'h0000_0080);
      (!mtvec_addr_plusarg_valid)        -> (mtvec_addr        == 'h0000_0000);
      (!dm_halt_addr_plusarg_valid)      -> (dm_halt_addr      == 'h1A11_0800);
      (!dm_exception_addr_plusarg_valid) -> (dm_exception_addr == 'h1A11_1000);
   }

   constraint agent_cfg_cons {
      if (enabled) {
         clknrst_cfg.enabled           == 1;
         interrupt_cfg.enabled         == 1;
         debug_cfg.enabled             == 1;
         rvfi_cfg.enabled              == 1;
         rvvi_cfg.enabled              == use_iss;
         obi_memory_instr_cfg.enabled  == 1;
         obi_memory_data_cfg.enabled   == 1;
      }

      obi_memory_instr_cfg.version       == UVMA_OBI_MEMORY_VERSION_1P1;
      obi_memory_instr_cfg.drv_mode      == UVMA_OBI_MEMORY_MODE_SLV;
      obi_memory_instr_cfg.write_enabled == 0;
      obi_memory_instr_cfg.addr_width    == 32;
      obi_memory_instr_cfg.data_width    == 32;
      obi_memory_instr_cfg.id_width      == 0;
      obi_memory_instr_cfg.achk_width    == 0;
      obi_memory_instr_cfg.rchk_width    == 0;
      obi_memory_instr_cfg.auser_width   == 0;
      obi_memory_instr_cfg.ruser_width   == 0;
      obi_memory_instr_cfg.wuser_width   == 0;
      soft obi_memory_instr_cfg.drv_slv_gnt_random_latency_max    <= 2;
      soft obi_memory_instr_cfg.drv_slv_gnt_fixed_latency         <= 2;
      soft obi_memory_instr_cfg.drv_slv_rvalid_random_latency_max <= 3;
      soft obi_memory_instr_cfg.drv_slv_rvalid_fixed_latency      <= 3;

      obi_memory_data_cfg.version        == UVMA_OBI_MEMORY_VERSION_1P1;
      obi_memory_data_cfg.drv_mode       == UVMA_OBI_MEMORY_MODE_SLV;
      obi_memory_data_cfg.addr_width     == 32;
      obi_memory_data_cfg.data_width     == 32;
      obi_memory_data_cfg.id_width       == 0;
      obi_memory_data_cfg.achk_width     == 0;
      obi_memory_data_cfg.rchk_width     == 0;
      obi_memory_data_cfg.auser_width    == 0;
      obi_memory_data_cfg.ruser_width    == 0;
      obi_memory_data_cfg.wuser_width    == 0;
      soft obi_memory_data_cfg.drv_slv_gnt_random_latency_max    <= 2;
      soft obi_memory_data_cfg.drv_slv_gnt_fixed_latency         <= 2;
      soft obi_memory_data_cfg.drv_slv_rvalid_random_latency_max <= 3;
      soft obi_memory_data_cfg.drv_slv_rvalid_fixed_latency      <= 3;

      rvfi_cfg.nret == uvme_cv32e40p_pkg::RVFI_NRET;
      rvfi_cfg.nmi_load_fault_enabled      == 1;
      rvfi_cfg.nmi_load_fault_cause        == 11'h400;//cv32e40p_pkg::INT_CAUSE_LSU_LOAD_FAULT; TODO
      rvfi_cfg.nmi_store_fault_enabled     == 1;
      rvfi_cfg.nmi_store_fault_cause       == 11'h401;//cv32e40p_pkg::INT_CAUSE_LSU_STORE_FAULT; TODO
      rvfi_cfg.insn_bus_fault_enabled      == 1;
      rvfi_cfg.insn_bus_fault_cause        == 11'h01;//cv32e40p_pkg::EXC_CAUSE_INSTR_BUS_FAULT; TODO

      if (is_active == UVM_ACTIVE) {
         clknrst_cfg.is_active          == UVM_ACTIVE;
         interrupt_cfg.is_active        == UVM_ACTIVE;
         debug_cfg.is_active            == UVM_ACTIVE;
         obi_memory_instr_cfg.is_active == UVM_ACTIVE;
         obi_memory_data_cfg.is_active  == UVM_ACTIVE;
         rvfi_cfg.is_active             == UVM_PASSIVE;
         rvvi_cfg.is_active             == UVM_ACTIVE;
      }

      if (trn_log_enabled) {
         clknrst_cfg.trn_log_enabled           == 1;
         interrupt_cfg.trn_log_enabled         == 1;
         debug_cfg.trn_log_enabled             == 1;
         obi_memory_instr_cfg.trn_log_enabled  == 1;
         obi_memory_data_cfg.trn_log_enabled   == 1;
         rvfi_cfg.trn_log_enabled              == 1;
         rvvi_cfg.trn_log_enabled              == 1;
      }

      if (cov_model_enabled) {
         obi_memory_instr_cfg.cov_model_enabled  == 1;
         obi_memory_data_cfg.cov_model_enabled   == 1;
      }

   }

   /**
    * Creates sub-configuration objects.
    */
   extern function new(string name="uvme_cv32e40p_cfg");

   /**
    * Run before randomizing this class
    */
   extern function void pre_randomize();

   /**
    * Run after randomizing this class
    */
   extern function void post_randomize();

   /**
    * Sample the parameters of the DUT via the virtual interface in a context
    */
   extern virtual function void sample_parameters(uvma_core_cntrl_cntxt_c cntxt);

   /**
    * Detect if a CSR check is disabled
    */
   extern virtual function bit is_csr_check_disabled(string name);

   /**
    * Configure CSR checks in the scoreboard
    */
   extern virtual function void configure_disable_csr_checks();

   /**
    * Set unsupported_csr_mask based on extensions/modes supported
    */
   extern virtual function void set_unsupported_csr_mask();

endclass : uvme_cv32e40p_cfg_c

function uvme_cv32e40p_cfg_c::new(string name="uvme_cv32e40p_cfg");

   super.new(name);

   core_name = "CV32E40P";

   clknrst_cfg           = uvma_clknrst_cfg_c   ::type_id::create("clknrst_cfg"         );
   interrupt_cfg         = uvma_interrupt_cfg_c ::type_id::create("interrupt_cfg"       );
   debug_cfg             = uvma_debug_cfg_c     ::type_id::create("debug_cfg"           );
   obi_memory_instr_cfg  = uvma_obi_memory_cfg_c::type_id::create("obi_memory_instr_cfg");
   obi_memory_data_cfg   = uvma_obi_memory_cfg_c::type_id::create("obi_memory_data_cfg" );

   rvfi_cfg = uvma_rvfi_cfg_c#(ILEN,XLEN)::type_id::create("rvfi_cfg");
   rvvi_cfg = uvma_rvvi_ovpsim_cfg_c#(ILEN,XLEN)::type_id::create("rvvi_cfg");

   rvfi_cfg.core_cfg = this;
   rvvi_cfg.core_cfg = this;

endfunction : new

function void uvme_cv32e40p_cfg_c::pre_randomize();

   if ($test$plusargs("rand_stall_obi_disable")) begin
      int retval;

      zero_stall_sim = 1;
      zero_stall_sim.rand_mode(0);

      // Hack-set is_stall_sim bit in step_compare
      retval = uvm_hdl_deposit("uvmt_cv32e40p_tb.step_compare.is_stall_sim", 0);
      if (!retval) begin
         `uvm_fatal("ZEROSTALL", "Cannot set is_stall_sim in step_compare")
      end
   end
   else if ($test$plusargs("max_data_zero_instr_stall")) begin
      // No stalls on the I bus, max on D bus
      max_data_zero_instr_stall = 1;
   end

endfunction : pre_randomize

function void uvme_cv32e40p_cfg_c::post_randomize();

   super.post_randomize();

   rvfi_cfg.instr_name[0] = "INSTR";

   // Set volatile locations for virtual peripherals
   rvvi_cfg.add_volatile_mem_addr_range(CV_VP_REGISTER_BASE, CV_VP_REGISTER_BASE + CV_VP_REGISTER_SIZE - 1);

   // Disable some CSR checks from all tests
   configure_disable_csr_checks();

endfunction : post_randomize

function void uvme_cv32e40p_cfg_c::sample_parameters(uvma_core_cntrl_cntxt_c cntxt);

   uvma_cv32e40p_core_cntrl_cntxt_c e40p_cntxt;

   if (!$cast(e40p_cntxt, cntxt)) begin
      `uvm_fatal("SAMPLECNTXT", "Could not cast cntxt to uvma_cv32e40p_core_cntrl_cntxt_c");
   end

   num_mhpmcounters = e40p_cntxt.core_cntrl_vif.num_mhpmcounters;
   // pma_regions      = new[e40p_cntxt.core_cntrl_vif.pma_cfg.size()]; // TODO check PMA
   // b_ext            = e40p_cntxt.core_cntrl_vif.b_ext;

   // foreach (pma_regions[i]) begin //TODO check PMA
      // pma_regions[i] = uvma_core_cntrl_pma_region_c::type_id::create($sformatf("pma_region%0d", i));
      // pma_regions[i].word_addr_low  = e40p_cntxt.core_cntrl_vif.pma_cfg[i].word_addr_low;
      // pma_regions[i].word_addr_high = e40p_cntxt.core_cntrl_vif.pma_cfg[i].word_addr_high;
      // pma_regions[i].main           = e40p_cntxt.core_cntrl_vif.pma_cfg[i].main;
      // pma_regions[i].bufferable     = e40p_cntxt.core_cntrl_vif.pma_cfg[i].bufferable;
      // pma_regions[i].cacheable      = e40p_cntxt.core_cntrl_vif.pma_cfg[i].cacheable;
      // pma_regions[i].atomic         = e40p_cntxt.core_cntrl_vif.pma_cfg[i].atomic;
   // end

   // Copy to the pma_configuration
   // pma_cfg.regions = new[pma_regions.size()]; //TODO check PMA
   // foreach (pma_cfg.regions[i])
      // pma_cfg.regions[i] = pma_regions[i];

endfunction : sample_parameters

function bit uvme_cv32e40p_cfg_c::is_csr_check_disabled(string name);

   // Fatal error if passed a CSR check which is non-existent
   if (!csr_name2addr.exists(name)) begin
      `uvm_fatal("CV32E40PCFG", $sformatf("CSR [%s] does not exist", name));
   end

   return disable_csr_check_mask[csr_name2addr[name]];

endfunction : is_csr_check_disabled

function void uvme_cv32e40p_cfg_c::configure_disable_csr_checks();

   // Not possible to test on a cycle-by-cycle basis
   disable_csr_check("mip");

   // These are not implemented in the ISS
   disable_csr_check("mcycle");
   disable_csr_check("mcycleh");
   disable_csr_check("mtval");

   for (int i = 3; i < 32; i++) begin
      disable_csr_check($sformatf("mhpmcounter%0d", i));
      disable_csr_check($sformatf("mhpmcounter%0dh", i));
      disable_csr_check($sformatf("mhpmevent%0d", i));
   end
endfunction : configure_disable_csr_checks

function void uvme_cv32e40p_cfg_c::set_unsupported_csr_mask();
   super.set_unsupported_csr_mask();
   unsupported_csr_mask[TCONTROL] = 1;
   unsupported_csr_mask[MCONFIGPTR] = 1;
   unsupported_csr_mask[MSTATUSH] = 1;
endfunction : set_unsupported_csr_mask


`endif // __UVME_CV32E40P_CFG_SV__
