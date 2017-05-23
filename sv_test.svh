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
// The sv_test.svh file can be included from a unit test file
// to bring in the sv_test unit test framework without the
// uvm_unit unit test framework.  This is useful when your test
// interacts with a module-under-test and has not need for
// working with UVM objects.
//
// See the 'examples' and 'tests' directories for usage examples.

`ifndef __SV_TEST_SVH__
`define __SV_TEST_SVH__

`include "unit_test_macros.sv"
`include "unit_test_pkg.svh"

package sv_test_pkg;
    import unit_test_pkg::*;
    `include "sv_test_factory.sv"
    `include "sv_test_runner.sv"
    `include "sv_test_fixture.sv"
endpackage

`include "unit_test_run_module.sv"


`endif // __SV_TEST_SVH__
