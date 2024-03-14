// -------------------------------------------------------------
//    Copyright 2017 XtremeEDA
//    Copyright 2020 Andes Technology
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
// The unit_test_pkg brings in objects common to both the
// sv_test and uvm_unit unit test frameworks.
//
// The test writer should not need to include this file.

`ifndef __UNIT_TEST_PKG_SVH__
`define __UNIT_TEST_PKG_SVH__

`define __UVM_UNIT_VERSION      1.13

package unit_test_pkg;
    `include "unit_test_info.sv"
    `include "unit_test_logger.sv"
    `include "unit_test_runner.sv"
endpackage

`endif // __UNIT_TEST_PKG_SVH__

