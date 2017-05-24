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
// The uvm_unit_test_runner uses UVM's uvm_pkg::run_test()
// function to instantiate and run each unit test class.
// It almost completely destroys all of UVM between tests,
// leaving behind UVM objects registered with the UVM Factory,
// since that is used by uvm_pkg::run_test().
//
// It is important to note that a modified version of UVM is needed to
// provide the functionality to destroy UVM and it's use of the
// singleton design pattern.
//
// The singleton design pattern is actually an anti-pattern that
// should not be used.
// * Singletons are really just global state, which is one of the code
//   smells (see https://en.wikipedia.org/wiki/Code_smell).
// * Singletons violate the single responsibility principle (the ’S’ in
//   the S.O.L.I.D. design principles) because they control their own
//   creation and life cycle
// * Singletons cause code to be tightly coupled. Good software should
//   loosely coupled with high cohesion. (See
//   https://en.wikipedia.org/wiki/Coupling_(computer_programming)  )
// * Carry state around for the lifetime of the application, thereby
//   breaking unit-testing, which needs each test to be independent
//   with no dependence on test order.
// It is a shame OVM and UVM make extensive use of this anti-pattern.
//
// Test writers do not need to know about the test runner.
// It should be completely abstracted away from the test writing
// aspect.


class uvm_unit_test_runner extends unit_test_pkg::unit_test_runner;
    protected static unit_test_pkg::unit_test_info  uvm_ut_info_q[$];
    protected uvm_unit_fixture                      running_test;

    function new(unit_test_logger logger);
        super.new(logger);
    endfunction

    static function unit_test_pkg::unit_test_info register_uvm_unit_test(string ut_name, string ut_file, int ut_line);
        unit_test_pkg::unit_test_info  i = new(ut_name, ut_file, ut_line);
        uvm_ut_info_q.push_back(i);
        return i;
    endfunction

    // Because uvm_pkg::uvm_root::run_test() instantiates the test, the handle to
    // the running test will have to be passed by the test once run_test() creates
    // it and runs it.
    virtual function void set_handle_to_running_test(uvm_unit_fixture running_test);
        this.running_test = running_test;
    endfunction

    protected virtual function void pass_unit_test_runner_to_test();
        // The normal way to pass such things would be through the constructor, but UVM
        // creates and starts the unit test (a child of uvm_test) with the run_test()
        // function and denies us access to the constructor. The UVM way around this is
        // the uvm_config_db, so we will use this to pass the test runner to the
        // fixture/test instance.
        uvm_config_db#(uvm_unit_test_runner)::set(null, "", "uvm_unit_test_runner", this);
    endfunction

    virtual function unit_test_pkg::ut_info_q_t get_unit_test_info_q();
        return uvm_ut_info_q;
    endfunction

    virtual task run_the_unit_test();
        pass_unit_test_runner_to_test();
        uvm_pkg::uvm_report_server::uvm_test_file_handle = logger.get_log_file_descriptor();
        uvm_pkg::run_test(running_test_info.ut_name);
        running_test.post_unit_test_checks();
        uvm_pkg::destroy_uvm();
    endtask
endclass
