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
// The sv_test_runner uses the sv_test_factory to
// instantiate and run each unit test class.
//
// Test writers do not need to know about the test runner.
// It should be completely abstracted away from the test writing
// aspect.


class sv_test_runner extends unit_test_pkg::unit_test_runner;
    protected static unit_test_pkg::unit_test_info  sv_ut_info_q[$];
    protected static sv_test_factory                test_creators[string]; // [test_name]
    protected sv_test_fixture                       running_test;

    function new(unit_test_logger logger);
        super.new(logger);
    endfunction

    static function sv_test_factory register_sv_test_creator(sv_test_factory creator, string ut_name, string ut_file, int ut_line);
        unit_test_pkg::unit_test_info  i = new(ut_name, ut_file, ut_line);
        test_creators[ut_name] = creator;
        sv_ut_info_q.push_back(i);
        return creator;
    endfunction

    protected virtual function void create_test();
        if (test_creators.exists(running_test_info.ut_name)) begin
            running_test = test_creators[running_test_info.ut_name].create(this);
        end else begin
            $stacktrace;
            $display("Did not find %s in factory", running_test_info.ut_name);
            $finish;
        end
    endfunction

    virtual function unit_test_pkg::ut_info_q_t get_unit_test_info_q();
        return sv_ut_info_q;
    endfunction

    protected virtual task run_the_unit_test();
        create_test();
        running_test.run_test();
        running_test.post_unit_test_checks();
    endtask
endclass
