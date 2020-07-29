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
// unit_test_info packages unit-test name, file name, and file
// line number into a single object.
//
// Test writers do not need to know about this object.
// It should be completely abstracted away from the test writing
// aspect.


class unit_test_info;

    static int property_pass_count[string];
    static int property_fail_count[string];
    static string running_ut_name;

    string ut_name;
    string ut_file;
    int ut_line;

    function new(string ut_name, string ut_file, int ut_line);
        this.ut_name = ut_name;
        this.ut_file = ut_file;
        this.ut_line = ut_line;
    endfunction

    virtual function string str();
        return $sformatf("%s (%s:%0d)", ut_name, ut_file, ut_line);
    endfunction

endclass
