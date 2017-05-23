// -------------------------------------------------------------
//    Copyright 2017 XtremeEDA
//    All Rights Reserved Worldwide
//
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
//
// The uvm_unit.svh file can be included from a unit test file
// to bring in both the sv_test unit test framework and the
// uvm_unit unit test framework.
//
// See the 'examples' and 'tests' directories for usage examples.


`ifndef __UVM_UNIT_SVH__
`define __UVM_UNIT_SVH__


`include "uvm_pkg.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "unit_test_macros.sv"
`include "unit_test_pkg.svh"
package uvm_unit_pkg;
    import uvm_pkg::*;
    import unit_test_pkg::*;
    `include "uvm_unit_msg_info.sv"
    `include "uvm_unit_report_catcher.sv"
    `include "uvm_unit_fixture.sv"
    `include "uvm_unit_test_runner.sv"
endpackage

`include "sv_test.svh"

`include "unit_test_run_module.sv"

`endif // __UVM_UNIT_SVH__

