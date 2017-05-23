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
// The unit_test_runner provides the common interface and
// functionality to both sv_test_runner and
// uvm_unit_test_runner.
//
// Test writers do not need to know about the test runner.
// It should be completely abstracted away from the test writing
// aspect.


typedef unit_test_info ut_info_q_t[$];

virtual class unit_test_runner;
    protected unit_test_info    running_test_info;
    protected unit_test_logger  logger;

    function new(unit_test_logger logger);
        this.logger = logger;
    endfunction

    virtual function unit_test_logger get_logger();
        return logger;
    endfunction

    virtual function int get_num_unit_tests();
        unit_test_info  ut_info_q[$] = get_unit_test_info_q();
        return ut_info_q.size();
    endfunction

    virtual task run_all_unit_tests();
        unit_test_info  ut_info_q[$] = get_unit_test_info_q();
        foreach (ut_info_q[i]) begin
            running_test_info = ut_info_q[i];
            logger.log_pre_test_message(running_test_info);
            run_the_unit_test();
            logger.log_post_test_message();
        end
    endtask

    pure virtual function ut_info_q_t get_unit_test_info_q();

    pure virtual task run_the_unit_test();
endclass
