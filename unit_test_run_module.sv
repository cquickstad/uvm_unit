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
// The unit_test_run_module is a top-level-module for the unit
// test framework's sv_test and uvm_unit test runners.
//
// Most tests will not need to concern themselves with this
// module. However, a savvy test writer who needs to slip
// something inside this top-level-module can use the
// UNIT_TEST_RUN_MODULE_BODY define to do so.


`ifndef __UNIT_TEST_RUN_MODULE_SV__
`define __UNIT_TEST_RUN_MODULE_SV__



`ifndef SV_TEST_RUNNER_TYPE
`define SV_TEST_RUNNER_TYPE sv_test_pkg::sv_test_runner
`endif

`ifndef UVM_UNIT_TEST_RUNNER_TYPE
`define UVM_UNIT_TEST_RUNNER_TYPE uvm_unit_pkg::uvm_unit_test_runner
`endif

`ifndef UNIT_TEST_LOGGER_TYPE
`define UNIT_TEST_LOGGER_TYPE unit_test_pkg::unit_test_logger
`endif

`ifdef UNIT_TEST_TIMESCALE
    `UNIT_TEST_TIMESCALE
`else
    `ifdef USE_DEFAULT_UNIT_TEST_TIMESCALE
        `timescale 1ps/1ps
    `endif
`endif


module unit_test_run_module;

    `ifdef UNIT_TEST_RUN_MODULE_BODY
        `UNIT_TEST_RUN_MODULE_BODY
    `endif

    initial begin
        automatic `UNIT_TEST_LOGGER_TYPE        logger = new();

        logger.start_logger();

        begin
            automatic `SV_TEST_RUNNER_TYPE    tr = new(logger);
            tr.run_all_unit_tests();
        end

        `ifdef __UVM_UNIT_SVH__
        begin
            automatic `UVM_UNIT_TEST_RUNNER_TYPE    tr = new(logger);
            tr.run_all_unit_tests();
        end
        `endif

        logger.stop_logger();

        // WARNING: Cadence's Xcelium will print the line of code that exits the simulator.
        //          It does this even if $finish() is called to successfully exit.
        //          Also, some projects may have a scripting environment that grep for
        //          words like "fatal" or "ERROR" in the output to determine success.
        //          If one of those bad words appears on the $finish() line, such as in a
        //          code comment or in a string, a script may have a false negative,
        //          flagging a failure when actually the unit tests all passed.
        //
        if (logger.all_passing()) begin
            $finish(0);
        end else begin
            $fatal(0, $sformatf(" ****** UVM_UNIT EXITING WITH %0d ERROR(S) ****** ", logger.get_num_errors()));
        end
    end
endmodule

`endif // __UNIT_TEST_RUN_MODULE_SV__
