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
// The sv_test_factory is used to create the tests defined by
// the `SV_TEST() and `SV_TEST_F() macros.  The test runner
// uses the factory to instantiate the defined test class before
// running the unit test.
//
// Test writers do not need to know about the factory. It should
// be completely abstracted away from the test writing aspect.

typedef class sv_test_fixture;

virtual class sv_test_factory;
    pure virtual function sv_test_fixture create(unit_test_pkg::unit_test_runner tr);
endclass


class sv_test_instantiator #(type T = sv_test_fixture) extends sv_test_factory;

    virtual function sv_test_fixture create(unit_test_pkg::unit_test_runner tr);
        T   test = new(tr);
        return sv_test_fixture'(test);
    endfunction

    static function sv_test_factory get_creator();
        sv_test_instantiator #(T)   creator = new();
        return creator;
    endfunction

endclass
