//----------------------------------------------------------------------
//   Copyright 2017 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

// This file was added to UVM in order to provide uvm_unit a single
// function call to destroy (nearly) all UVM object instances and
// global state. It leaves behind the UVM objects registered with the
// factory, as uvm_unit will need this to be kept around.
//
// This function also shows why the singleton design pattern is actually
// an anti-pattern that should not be used.
// * Singletons are really just global state, which is one of the code
//   smells (see https://en.wikipedia.org/wiki/Code_smell).
// * Singletons violate the single responsibility principle (the ’S’ in
//   the S.O.L.I.D. design principles) because they control their own
//   creation and life cycle
// * Singletons cause code to be tightly coupled. Good software should
//   loosely coupled with high cohesion. (See
//   https://en.wikipedia.org/wiki/Coupling_(computer_programming)  )
// * Singletons carry state around for the lifetime of the application,
//   thereby breaking unit-testing, which needs each test to be
//   independent with no dependence on test order.
// It is a shame OVM and UVM make extensive use of this anti-pattern.

function void destroy_uvm();
    uvm_coreservice_t cs;
    uvm_factory f;

    uvm_phase::destroy();
    uvm_domain::destroy();
    uvm_root::destroy();

    // Keep the factory around because it remembers registered types.
    // uvm_coreservice_t::destroy();
    // But do delete the type overrides
    cs = uvm_coreservice_t::get();
    f = cs.get_factory();
    cs.clear_state();
    f.reset_overrides();

    // Destroy common phases
    uvm_build_phase::destroy();
    uvm_connect_phase::destroy();
    uvm_end_of_elaboration_phase::destroy();
    uvm_start_of_simulation_phase::destroy();
    uvm_run_phase::destroy();
    uvm_extract_phase::destroy();
    uvm_check_phase::destroy();
    uvm_report_phase::destroy();
    uvm_final_phase::destroy();

    // Destroy runtime phases
    uvm_pre_reset_phase::destroy();
    uvm_reset_phase::destroy();
    uvm_post_reset_phase::destroy();
    uvm_pre_configure_phase::destroy();
    uvm_configure_phase::destroy();
    uvm_post_configure_phase::destroy();
    uvm_pre_main_phase::destroy();
    uvm_main_phase::destroy();
    uvm_post_main_phase::destroy();
    uvm_pre_shutdown_phase::destroy();
    uvm_shutdown_phase::destroy();
    uvm_post_shutdown_phase::destroy();

    // Destroy UVM types in the uvm_config_db
    uvm_config_db#(uvm_object)::destroy();
    uvm_config_db#(uvm_object_wrapper)::destroy();
    uvm_config_db#(uvm_sequence_library_cfg)::destroy();
    uvm_config_db#(uvm_sequence_lib_mode)::destroy();
    uvm_config_db#(uvm_sequence_base)::destroy();

    // Destroy SystemVerilog built-in types in the uvm_config_db
    uvm_config_db#(int)::destroy();
    uvm_config_db#(int unsigned)::destroy();
    uvm_config_db#(string)::destroy();
    uvm_config_db#(real)::destroy();
    uvm_config_db#(shortreal)::destroy();
    // uvm_config_db#(event)::destroy();   // Cadence Incisiv does not support events in parameter types
    // uvm_config_db#(chandle)::destroy(); // Cadence Incisiv does not support chandle in parameter types
    uvm_config_db#(byte)::destroy();
    uvm_config_db#(byte unsigned)::destroy();
    uvm_config_db#(shortint)::destroy();
    uvm_config_db#(shortint unsigned)::destroy();
    uvm_config_db#(integer)::destroy();
    uvm_config_db#(integer unsigned)::destroy();
    uvm_config_db#(reg)::destroy();
    uvm_config_db#(logic)::destroy();
    uvm_config_db#(bit)::destroy();
    uvm_config_db#(longint)::destroy();
    uvm_config_db#(longint unsigned)::destroy();
    uvm_config_db#(time)::destroy();
    uvm_config_db#(realtime)::destroy();

    // Destroy UVM types using uvm_resource
    uvm_resource#(uvm_active_passive_enum)::destroy();
    uvm_resource#(uvm_integral_t)::destroy();
    uvm_resource#(uvm_bitstream_t)::destroy();
    uvm_resource#(uvm_reg_block)::destroy();
    uvm_resource#(uvm_sequence_base)::destroy();
    uvm_resource#(uvm_object_wrapper)::destroy();
    uvm_resource#(uvm_config_object_wrapper)::destroy();
    uvm_resource#(uvm_object)::destroy();

    // Destroy SystemVerilog built-in types using uvm_resource
    uvm_resource#(int)::destroy();
    uvm_resource#(int unsigned)::destroy();
    uvm_resource#(string)::destroy();
    uvm_resource#(real)::destroy();
    uvm_resource#(shortreal)::destroy();
    // uvm_resource#(event)::destroy();   // Cadence Incisiv does not support events in parameter types
    // uvm_resource#(chandle)::destroy(); // Cadence Incisiv does not support chandle in parameter types
    uvm_resource#(byte)::destroy();
    uvm_resource#(byte unsigned)::destroy();
    uvm_resource#(shortint)::destroy();
    uvm_resource#(shortint unsigned)::destroy();
    uvm_resource#(integer)::destroy();
    uvm_resource#(integer unsigned)::destroy();
    uvm_resource#(reg)::destroy();
    uvm_resource#(logic)::destroy();
    uvm_resource#(bit)::destroy();
    uvm_resource#(longint)::destroy();
    uvm_resource#(longint unsigned)::destroy();
    uvm_resource#(time)::destroy();
    uvm_resource#(realtime)::destroy();


    uvm_report_catcher::destroy();

    // Destroy UVM types using uvm_queue
    uvm_queue#()::destroy_global_queue();
    uvm_queue#(uvm_callback)::destroy_global_queue();
    uvm_queue#(uvm_resource_base)::destroy_global_queue();
    uvm_queue#(m_uvm_waiter)::destroy_global_queue();
    uvm_queue#(uvm_hdl_path_concat)::destroy_global_queue();

    // Destroy SystemVerilog built-in types using uvm_queue
    uvm_queue#(int)::destroy_global_queue();
    uvm_queue#(int unsigned)::destroy_global_queue();
    uvm_queue#(string)::destroy_global_queue();
    uvm_queue#(real)::destroy_global_queue();
    uvm_queue#(shortreal)::destroy_global_queue();
    // uvm_queue#(event)::destroy_global_queue();   // Cadence Incisiv does not support events in parameter types
    // uvm_queue#(chandle)::destroy_global_queue(); // Cadence Incisiv does not support chandle in parameter types
    uvm_queue#(byte)::destroy_global_queue();
    uvm_queue#(byte unsigned)::destroy_global_queue();
    uvm_queue#(shortint)::destroy_global_queue();
    uvm_queue#(shortint unsigned)::destroy_global_queue();
    uvm_queue#(integer)::destroy_global_queue();
    uvm_queue#(integer unsigned)::destroy_global_queue();
    uvm_queue#(reg)::destroy_global_queue();
    uvm_queue#(logic)::destroy_global_queue();
    uvm_queue#(bit)::destroy_global_queue();
    uvm_queue#(longint)::destroy_global_queue();
    uvm_queue#(longint unsigned)::destroy_global_queue();
    uvm_queue#(time)::destroy_global_queue();
    uvm_queue#(realtime)::destroy_global_queue();

    uvm_heartbeat_cbs_t::destroy();
    uvm_objection_cbs_t::destroy();
    uvm_phase_cb_pool::destroy();
    uvm_report_cb::destroy();
    uvm_reg_cb::destroy();
    uvm_reg_bd_cb::destroy();
    uvm_mem_cb::destroy();
    uvm_reg_field_cb::destroy();
    uvm_vreg_cb::destroy();
    uvm_vreg_field_cb::destroy();
    uvm_callbacks#()::destroy();
    uvm_run_test_callback::destroy();

    uvm_reg_map::destroy_backdoor();

    uvm_cmdline_processor::reset();

    // The is actually recreating uvm_root, but we can't let
    // this global state remain without being reset
    uvm_top = uvm_root::get();
endfunction