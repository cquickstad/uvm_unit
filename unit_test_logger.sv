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
// The unit test logger is a single entity to control all
// aspects of text output from the unit test framework.
// It can optionally redirect output to a file when the
// +uvm_unit_log_file=some_file_name.out
// plusarg is set on the command line.
//
// Test writers do not need to know about the logger most of the
// time. However, an advanced user could inherit and
// extend/alter the behavior if absolutely required.


class unit_test_logger;

    protected int                   err_per_ut[unit_test_info]; // Number of failures in each test
    protected unit_test_info        ut_with_errors[$]; // Maintain the order of failure in "PER-TEST ERROR COUNTS"

    protected string                log_fname;
    protected bit                   log_to_file = 0;
    protected int                   log_file_descriptor;

    protected string                log_separator        = "----------------------------------------------------------------";
    protected string                start_stop_separator = "================================================================";

    protected unit_test_info        current_test_info;
    protected int                   num_unit_tests;

    function new();
        num_unit_tests = 0;
    endfunction

    virtual function void start_logger();
        open_log_file();
        log(get_start_message());
    endfunction

    virtual function void stop_logger();
        log(get_uvm_unit_summary());
        close_log_file();
    endfunction

    virtual function int get_log_file_descriptor();
        return log_file_descriptor;
    endfunction

    virtual function void log_err_msg(string err_msg, string file, int line);
        inc_err_count();
        log($sformatf("UVM_UNIT: ERROR: %s:%0d @ %0t: %s", file, line, $time, err_msg));
    endfunction

    virtual function void inc_err_count();
        if (err_per_ut.exists(current_test_info)) begin
            err_per_ut[current_test_info]++;
        end else begin
            ut_with_errors.push_back(current_test_info);
            err_per_ut[current_test_info] = 1;
        end
    endfunction

    virtual function void log(string str);
        if (log_to_file) $fdisplay(log_file_descriptor, str); else $display(str);
    endfunction

    virtual function bit logging_to_file();
        return log_to_file;
    endfunction

    virtual function string get_start_message();
        return {start_stop_separator, "\n", $sformatf("UVM_UNIT v%0.2f", `__UVM_UNIT_VERSION)};
    endfunction

    virtual function string get_pre_test_message();
        return {log_separator, "\nUVM_UNIT TEST STARTING: ", current_test_info.str()};
    endfunction

    virtual function string get_post_test_message();
        bit     failed = err_per_ut.exists(current_test_info) &&
                         (err_per_ut[current_test_info] > 0);

        string  pass_fail = failed ? "FAILED" : "PASSED";

        return {"UVM_UNIT TEST FINISHED: ", current_test_info.str(), " -- ", pass_fail};
    endfunction

    virtual function string get_uvm_unit_summary();
        int             num_failing_unit_tests = err_per_ut.size();
        int             num_passing_unit_tests = num_unit_tests - num_failing_unit_tests;
        int             total_errors = 0;
        string          summary = $sformatf("%s\nUVM_UNIT: ALL TESTS COMPLETE (%0d tests)",
                                            start_stop_separator, num_unit_tests);

        if (ut_with_errors.size() > 0) begin
            summary = {summary, "\n", log_separator, "\nUVM_UNIT PER-TEST ERROR COUNTS:"};
        end
        foreach (ut_with_errors[i]) begin
            unit_test_info  ti = ut_with_errors[i];
            int num_errs = err_per_ut[ti];
            summary = {summary, "\n", ti.str(), ": ", $sformatf("%0d", num_errs), " error"};
            if (num_errs > 1) summary = {summary, "s"};
            total_errors += num_errs;
        end

        summary = {summary, "\n", log_separator};
        summary = {summary, "\nUVM_UNIT TEST SUMMARY:"};
        summary = {summary, "\n", $sformatf("%0d ERROR", total_errors), (total_errors == 1) ? "" : "S"};
        summary = {summary, "\n", $sformatf("%0d of %0d TESTS FAILED", num_failing_unit_tests, num_unit_tests)};
        summary = {summary, "\n", $sformatf("%0d of %0d TESTS PASSED", num_passing_unit_tests, num_unit_tests)};

        summary = {summary, "\n", log_separator};
        summary = {summary, "\nUVM_UNIT RESULT: ", (num_failing_unit_tests > 0) ? "FAIL" : "PASS"};
        summary = {summary, "\n", start_stop_separator};

        return summary;
    endfunction

    virtual function void log_start_message();     log(get_start_message());     endfunction
    virtual function void log_post_test_message(); log(get_post_test_message()); endfunction
    virtual function void log_uvm_unit_summar();   log(get_uvm_unit_summary());  endfunction

    virtual function void log_pre_test_message(unit_test_info ut_info);
        num_unit_tests++;
        current_test_info = ut_info;
        log(get_pre_test_message());
    endfunction

    protected virtual function void open_log_file();
        determine_log_fname();
        if (log_fname == "") begin
            log_to_file = 0;
            log_file_descriptor = -1;
        end else begin
            log_to_file = 1;
            log_file_descriptor = $fopen(log_fname, "ab+");
        end
    endfunction

    protected virtual function void determine_log_fname();
        if (!$value$plusargs("uvm_unit_log_file=%s", log_fname)) log_fname = "";
    endfunction

    protected virtual function void close_log_file();
        if (log_to_file) $fclose(log_file_descriptor);
    endfunction

endclass
