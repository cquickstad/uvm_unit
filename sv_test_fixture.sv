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
// The RTL Fixture is the unit test fixture for tests that use
// the `SV_TEST() and `SV_TEST_F() test macros inside of a
// module.  The test macros define a test class that inherits
// from the fixture class and allow the test_body() method to be
// populated.
//
// See the 'examples' and 'tests' directories for usage examples.


class sv_test_fixture;
    protected unit_test_runner              __tr;
    protected unit_test_logger              __logger;
    protected unit_test_pkg::unit_test_info __ut_info;

    function new(unit_test_runner tr);
        __tr = tr;
        __logger = __tr.get_logger();
    endfunction

    virtual task setup();
    endtask

    virtual task test_body();
    endtask

    virtual task teardown();
    endtask

    // Called by the unit test runner
    virtual task run_test();
        setup();
        test_body();
        teardown();
    endtask

    // The assertion macros (`ASSERT_EQ() for example, call this method)
    virtual function void handle_error(string err_msg, string file, int line);
        __logger.log_err_msg(err_msg, file, line);
    endfunction

    // Runs before setup()
    virtual function void pre_unit_test();
        unit_test_pkg::unit_test_info::running_ut_name = __ut_info.ut_name;
        unit_test_pkg::unit_test_info::property_pass_count.delete();
        unit_test_pkg::unit_test_info::property_fail_count.delete();
    endfunction

    // Runs after teardown()
    virtual function void post_unit_test();
        // Nothing here right now, but as part of the fixture, it could be
        // extended by the test writer.
    endfunction
endclass
