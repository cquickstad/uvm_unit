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
// The uvm_unit_fixture is the unit test fixture for tests that
// use `UVM_TEST() and `UVM_TEST_F() test macros, as well as the
// `RUN_PHASE_TEST() and `RUN_PHASE_TEST_F() macros.  The test
// macros define a test class that inherits from the fixture
// class and allow the test contents to be populated.
//
// The uvm_unit_fixture inherits from uvm_test (of a modified
// version of UVM used by uvm_unit).  Instead of setup() and
// teardown() methods used by most unit test frameworks'
// fixtures, uvm_unit_fixture uses the UVM phases already
// available.
//
// In addition to providing a handle_error() method to be used
// the the unit-test assertion macros, the fixture also provides
// an expect_msg method to be used by the `EXPECT_* message
// macros.
//
// By default, warnings, errors and fatals are not expected and
// tests will fail if such messages happen without any
// expectation set in the unit-test.
//
//
// See the 'examples' and 'tests' directories for usage examples.


typedef class uvm_unit_test_runner;


virtual class uvm_unit_fixture extends uvm_test;

    protected uvm_unit_test_runner          __tr;
    protected unit_test_logger              __logger;
    protected uvm_unit_report_catcher       __report_catcher;
    protected unit_test_pkg::unit_test_info __ut_info;

    function new(string name="", uvm_component parent=null);
        super.new(name, parent);
        __get_test_runner();
        __logger = __tr.get_logger();
        __connect_to_test_runner();
        __create_report_catcher();
        __connect_report_catcher();
    endfunction

    virtual function void phase_started(uvm_phase phase);
        super.phase_started(phase);
        if (phase.get_name() == "build") pre_unit_test();
    endfunction

    function void handle_error(string err_msg, string file, int line);
        __logger.log_err_msg(err_msg, file, line);
    endfunction

    virtual function void expect_msg(
        uvm_severity    sev,
        string          id ="*",
        string          msg="*",
        string          fname="<?file?>",
        int             line=-1
    );
        __report_catcher.add_expected_report(sev, id, msg, fname, line);
    endfunction

    virtual function void report_unexpected_msg(uvm_unit_msg_info m);
        string err_msg;

        if (m == null) return;
        err_msg = {"UNEXPECTED ", m.str(1)};

        // Report unexpected messages as having occurred at the first line of the unit
        // test, since we can't say where in the test the problem occurred.
        // The line of the UVM message will also be shown in err_msg.
        handle_error(err_msg, __ut_info.ut_file, __ut_info.ut_line);
    endfunction

    // Runs before UVM's build_phase starts, from the phase_started() method.
    virtual function void pre_unit_test();
        unit_test_pkg::unit_test_info::running_ut_name = __ut_info.ut_name;
        unit_test_pkg::unit_test_info::property_pass_count.delete();
        unit_test_pkg::unit_test_info::property_fail_count.delete();
    endfunction

    // Runs after all UVM phases are complete
    virtual function void post_unit_test();
        uvm_unit_msg_info q[$] = __report_catcher.get_unobserved_expected_messages();
        foreach (q[i]) handle_error({"UNOBSERVED ", q[i].str()}, q[i].fname, q[i].line);
    endfunction

    protected virtual function void __get_test_runner();
        bit result = uvm_config_db#(uvm_unit_test_runner)::get(null, "", "uvm_unit_test_runner", __tr);
        if (!result) begin
            $display("UVM_UNIT FATAL ERROR (%s:%0d): Test Runner instance was not found!", `__FILE__, `__LINE__);
            $finish();
        end
        if (__tr == null) begin
            $display("UVM_UNIT FATAL ERROR (%s:%0d): Test Runner instance was null!", `__FILE__, `__LINE__);
            $finish();
        end
    endfunction

    protected virtual function void __connect_to_test_runner();
        __tr.set_handle_to_running_test(this);
    endfunction

    protected virtual function void __create_report_catcher();
        __report_catcher = new("__report_catcher", this);
    endfunction

    protected virtual function void __connect_report_catcher();
        uvm_report_cb::add(null, __report_catcher);
    endfunction

endclass

