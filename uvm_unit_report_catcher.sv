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
// The uvm_unit_report_catcher interfaces to UVM's report
// catcher infrastructure.  It is used by uvm_unit to intercept
// warnings, errors, and fatals and check those messages against
// expectations set in the unit test.
//
// Test writers do not need to know about this object.
// It should be completely abstracted away from the test writing
// aspect.


typedef class uvm_unit_fixture;

class uvm_unit_report_catcher extends uvm_report_catcher;

    uvm_unit_msg_info   expected_report_q[$];
    uvm_unit_msg_info   observed_msg;
    uvm_severity        severities_to_catch[$];
    uvm_unit_fixture    fxtr;

    function new(string name, uvm_unit_fixture fxtr);
        super.new(name);
        severities_to_catch = {UVM_WARNING, UVM_ERROR, UVM_FATAL};
        this.fxtr = fxtr;
    endfunction

    // Desired behavior for what gets printed can be overridden in a child class.
    // * THROW allows the message to go through the UVM message printing process.
    // * CAUGHT stops the message and it does not get printed.
    virtual function action_e expected_msg_action();   return CAUGHT; endfunction
    virtual function action_e unexpected_msg_action(); return CAUGHT; endfunction
    virtual function action_e uncaught_msg_action();   return THROW; endfunction

    virtual function action_e catch();
        observed_msg = new(get_severity(), get_id(), get_message(), get_fname(), get_line());
        if (observed_msg.sev inside {severities_to_catch}) begin
            if (msg_match()) begin
                pop_expected_msg();
                return expected_msg_action();
            end else begin
                fxtr.report_unexpected_msg(observed_msg);
                return unexpected_msg_action();
            end
        end
        return uncaught_msg_action();
    endfunction

    virtual function bit msg_match();
        return (expected_report_q.size() > 0) && observed_msg.match(expected_report_q[0]);
    endfunction

    virtual function void pop_expected_msg();
        if (expected_report_q.size() < 1) return;
        void'(expected_report_q.pop_front());
    endfunction

    virtual function void add_expected_report(uvm_severity sev, string id, string msg, string fname, int line);
        uvm_unit_msg_info   m = new(sev, id, msg, fname, line);
        expected_report_q.push_back(m);
    endfunction

    virtual function uvm_unit_msg_info_q get_unobserved_expected_messages();
        get_unobserved_expected_messages = expected_report_q;
    endfunction
endclass
