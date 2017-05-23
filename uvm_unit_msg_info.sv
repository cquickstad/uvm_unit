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
// The uvm_unit_msg_info object packages all of the needed
// information about UVM messages that can happen in unit tests
// in order to:
//  1) set expectations for messages (such as uvm_errors) that
//     should happen in a unit test so that unit test errors
//     can be logged if those expected messages are not seen.
//  2) collect information about messages that have happened in
//     the unit test so that the observed messages can be
//     checked against the set of expected messages;
//  3) provide information about any unexpected error so that
//     the unit test logger can provide plenty of detail about
//     any unexpected message that happened in a test or any
//     expectation of a message that was not met.
//
// Test writers do not need to know about the test runner.
// It should be completely abstracted away from the test writing
// aspect.


class uvm_unit_msg_info;
    uvm_severity    sev;
    string          id;
    string          msg;
    string          fname;
    int             line;

    function new(uvm_severity sev, string id="", string msg="", string fname="", int line=-1);
        this.sev = sev;
        this.id = id;
        this.msg = msg;
        this.fname = fname;
        this.line = line;
    endfunction

    virtual function bit match(uvm_unit_msg_info other);
        bit sev_match, id_match, msg_match;
        if (other == null) return 0;
        sev_match = (this.sev == other.sev);
        id_match = match_pattern(this.id, other.id);
        msg_match = match_pattern(this.msg, other.msg);
        return sev_match && id_match && msg_match;
    endfunction

    virtual function string str(bit include_file_info=0);
        return $sformatf("%s:%s [%s] %s", sev.name(),
            ((include_file_info) ? $sformatf(" %s:%0d", fname, line) : ""),
            id, msg);
    endfunction

    virtual protected function bit match_pattern(string a, string b);
        return a=="*" || b=="*" || a==b;
    endfunction
endclass

typedef uvm_unit_msg_info uvm_unit_msg_info_q[$];
