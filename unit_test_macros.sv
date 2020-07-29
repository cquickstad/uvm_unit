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
// The unit test macros are used to define the different types
// of unit tests, check for correct behavior in a test, and to
// set any expectations for UVM warnings, errors, or fatals.
//
// See the 'examples' and 'tests' directories for usage examples.


`ifndef __UNIT_TEST_MACROS_SV__
`define __UNIT_TEST_MACROS_SV__


`define __HANDLE_ERROR(ERR_MSG) \
    this.handle_error(ERR_MSG, `__FILE__, `__LINE__);

// Warning, due to SystemVerilog shortcomings, do not put a statement with
// quotes in the `ASSERT_TRUE() macro.  e.g. `ASSERT_TRUE(obj.has_child("foo")).
// Use `ASSERT_TRUE_LOG() instead.
`define ASSERT_TRUE(STATEMENT)                      \
    if (!(STATEMENT)) begin                         \
        `__HANDLE_ERROR(`"ASSERT_TRUE(STATEMENT)`") \
    end

`define ASSERT_TRUE_LOG(STATEMENT, MSG)                          \
    if (!(STATEMENT)) begin                                      \
        `__HANDLE_ERROR($sformatf("ASSERT_TRUE_LOG(): %s", MSG)) \
    end

// Warning, due to SystemVerilog shortcomings, do not put a statement with
// quotes in the `ASSERT_FALSE() macro.  e.g. `ASSERT_FALSE(obj.has_child("foo")).
// Use `ASSERT_FALSE_LOG() instead.
`define ASSERT_FALSE(STATEMENT)                         \
    if (STATEMENT) begin                                \
        `__HANDLE_ERROR(`"ASSERT_FALSE(STATEMENT)`")    \
    end

`define ASSERT_FALSE_LOG(STATEMENT, MSG)                            \
    if (STATEMENT) begin                                            \
        `__HANDLE_ERROR($sformatf("ASSERT_FALSE_LOG(): %s", MSG))   \
    end

// (EQ)ual
`define ASSERT_EQ(A, B)                                                         \
    if ((A) !== (B)) begin                                                      \
        `__HANDLE_ERROR($sformatf(`"ASSERT_EQ(A, B): 'h%0x !== 'h%0x`", A, B))  \
    end

// (N)ot (E)qual
`define ASSERT_NE(A, B)                                                         \
    if ((A) === (B)) begin                                                      \
        `__HANDLE_ERROR($sformatf(`"ASSERT_NE(A, B): 'h%0x === 'h%0x`", A, B))  \
    end

// (STR)ing (EQ)ual
`define ASSERT_STR_EQ(A, B)                                                                   \
    begin                                                                                     \
        string __a_str = (A);                                                                 \
        string __b_str = (B);                                                                 \
        if (__a_str != __b_str) begin                                                         \
            `__HANDLE_ERROR($sformatf("ASSERT_STR_EQ(): \"%s\" != \"%s\"", __a_str, __b_str)) \
        end                                                                                   \
    end

// (STR)ing (EQ)ual
`define ASSERT_STR_NE(A, B)                                                                   \
    begin                                                                                     \
        string __a_str = (A);                                                                 \
        string __b_str = (B);                                                                 \
        if (__a_str == __b_str) begin                                                         \
            `__HANDLE_ERROR($sformatf("ASSERT_STR_NE(): \"%s\" == \"%s\"", __a_str, __b_str)) \
        end                                                                                   \
    end

// Assert that (A)ssignment (P)atterns are (EQ)ual
`define ASSERT_AP_EQ(A, B)                                                         \
    begin                                                                          \
        string __ap_a = $sformatf("%p", (A));                                      \
        string __ap_b = $sformatf("%p", (B));                                      \
        `ifdef VCS                                                                 \
        __ap_a = __ap_a.substr(0, __ap_a.len() - 2); // VCS has a trailing space   \
        __ap_b = __ap_b.substr(0, __ap_b.len() - 2); // VCS has a trailing space   \
        `endif                                                                     \
        if (__ap_a != __ap_b) begin                                                \
            `__HANDLE_ERROR($sformatf("ASSERT_AP_EQ(): %s != %s", __ap_a, __ap_b)) \
        end                                                                        \
    end

// Assert that (A)ssignment (P)attern is (EQ)ual to (STR)ing
`define ASSERT_AP_EQ_STR(A, B_STR)                                                      \
    begin                                                                               \
        string __ap_a = $sformatf("%p", (A));                                           \
        string __b_str = (B_STR);                                                       \
        `ifdef VCS                                                                      \
        __ap_a = __ap_a.substr(0, __ap_a.len() - 2); // VCS has a trailing space        \
        `endif                                                                          \
        if (__ap_a != __b_str) begin                                                    \
            `__HANDLE_ERROR($sformatf("ASSERT_AP_EQ_STR(): %s != %s", __ap_a, __b_str)) \
        end                                                                             \
    end

`define ASSERT_NULL(STATEMENT)                                  \
    if ((STATEMENT) != null) begin                              \
        `__HANDLE_ERROR($sformatf(`"ASSERT_NULL(STATEMENT)`"))  \
    end

`define ASSERT_NOT_NULL(STATEMENT)                                  \
    if ((STATEMENT) == null) begin                                  \
        `__HANDLE_ERROR($sformatf(`"ASSERT_NOT_NULL(STATEMENT)`"))  \
    end

// (G)reater (T)han
`define ASSERT_GT(A, B)                                                         \
    if ((A) <= (B)) begin                                                       \
        `__HANDLE_ERROR($sformatf(`"ASSERT_GT(A, B): 'h%0x <= 'h%0x`", A, B))   \
    end

// (G)reater-than or (E)qual-to
`define ASSERT_GE(A, B)                                                         \
    if ((A) < (B)) begin                                                        \
        `__HANDLE_ERROR($sformatf(`"ASSERT_GE(A, B): 'h%0x < 'h%0x`", A, B))    \
    end

// (L)ess (T)han
`define ASSERT_LT(A, B)                                                         \
    if ((A) >= (B)) begin                                                       \
        `__HANDLE_ERROR($sformatf(`"ASSERT_LT(A, B): 'h%0x >= 'h%0x`", A, B))   \
    end

// (L)ess-than or (E)qual-to
`define ASSERT_LE(A, B)                                                         \
    if ((A) > (B)) begin                                                        \
        `__HANDLE_ERROR($sformatf(`"ASSERT_LE(A, B): 'h%0x > 'h%0x`", A, B))    \
    end

// Warning, due to SystemVerilog shortcomings, do not put a statement with
// quotes in the `ASSERT_HAS() macro.
// e.g. `ASSERT_HAS(string, item == "foo", string_queue)
// or
// `ASSERT_HAS(string, item == my_str, '{"a", "b", "c"})
`define ASSERT_HAS(TYPE, ARRAY, EXPRESSION)                                                     \
    begin                                                                                       \
        TYPE __array_to_search[] = ARRAY;                                                       \
        TYPE __find_first_result[$] = __array_to_search.find_first with (EXPRESSION);           \
        if (__find_first_result.size() == 0) begin                                              \
            `__HANDLE_ERROR(`"ASSERT_HAS(TYPE, ARRAY, EXPRESSION): 'EXPRESSION' not in ARRAY`") \
        end                                                                                     \
    end

// Warning, due to SystemVerilog shortcomings, do not put a statement with
// quotes in the `ASSERT_HAS() macro.
// e.g. `ASSERT_HAS(string, item == "foo", string_queue)
// or
// `ASSERT_HAS(string, item == my_str, '{"a", "b", "c"})
`define ASSERT_DOES_NOT_HAVE(TYPE, ARRAY, EXPRESSION)                                                   \
    begin                                                                                               \
        TYPE __array_to_search[] = ARRAY;                                                               \
        TYPE __find_first_result[$] = __array_to_search.find_first with (EXPRESSION);                   \
        if (__find_first_result.size() > 0) begin                                                       \
            `__HANDLE_ERROR(`"ASSERT_DOES_NOT_HAVE(TYPE, ARRAY, EXPRESSION): 'EXPRESSION' in ARRAY`")   \
        end                                                                                             \
    end


// Allows a property to be instantiated in an assertion in a unit-test module, with proper connections
// to the pass/fail infrastructure provided by the unit-test framework.
`define SV_TEST_ASSERT_PROPERTY(NAME, PARAMETERS) \
    ``NAME``_unit_test_assertion: \
        assert property (NAME PARAMETERS) begin \
            unit_test_pkg::unit_test_info::property_pass_count[`"NAME`"]++; \
        end else begin \
            unit_test_pkg::unit_test_info::property_fail_count[`"NAME`"]++; \
        end

`define ASSERT_PROPERTY_PASS_COUNT(PROPERTY_NAME, EXPECTED_PASS_COUNT) \
    begin \
        int __property_pass_count = unit_test_pkg::unit_test_info::property_pass_count[`"PROPERTY_NAME`"]; \
        if (__property_pass_count != (EXPECTED_PASS_COUNT)) begin \
            `__HANDLE_ERROR($sformatf(`"ASSERT_PROPERTY_PASS_COUNT(PROPERTY_NAME, EXPECTED_PASS_COUNT): %0d !== %0d`", \
                __property_pass_count, (EXPECTED_PASS_COUNT))) \
        end \
    end

`define ASSERT_PROPERTY_FAIL_COUNT(PROPERTY_NAME, EXPECTED_FAIL_COUNT) \
    begin \
        int __property_fail_count = unit_test_pkg::unit_test_info::property_fail_count[`"PROPERTY_NAME`"]; \
        if (__property_fail_count != (EXPECTED_FAIL_COUNT)) begin \
            `__HANDLE_ERROR($sformatf(`"ASSERT_PROPERTY_FAIL_COUNT(PROPERTY_NAME, EXPECTED_FAIL_COUNT): %0d !== %0d`", \
                __property_fail_count, (EXPECTED_FAIL_COUNT))) \
        end \
    end

`define ASSERT_PROPERTY_PASS_FAIL_COUNT(PROPERTY_NAME, EXPECTED_PASS_COUNT, EXPECTED_FAIL_COUNT) \
    `ASSERT_PROPERTY_PASS_COUNT(PROPERTY_NAME, EXPECTED_PASS_COUNT) \
    `ASSERT_PROPERTY_FAIL_COUNT(PROPERTY_NAME, EXPECTED_FAIL_COUNT)


// Expectations for warnings, errors, and fatal UVM messages that should be seen
// in a unit-test can be set using these `EXPECT_* macros.
//
// Messages can be matched against expectations by ID alone, by message contents
// alone, or by both ID and message contents.
//
// Messages are expected in the order in which the expectation was set (FIFO).
//
// It should be noted that uvm_fatal messages will be prevented from ending the
// unit test, so go ahead and test your fatal messages in your unit tests.

`define EXPECT_WARNING_ID(ID) \
    expect_msg(.sev(UVM_WARNING), .id(ID), .fname(`__FILE__), .line(`__LINE__));

`define EXPECT_WARNING_MSG(MSG) \
    expect_msg(.sev(UVM_WARNING), .msg(MSG), .fname(`__FILE__), .line(`__LINE__));

`define EXPECT_WARNING_ID_MSG(ID, MSG) \
    expect_msg(.sev(UVM_WARNING), .id(ID), .msg(MSG), .fname(`__FILE__), .line(`__LINE__));

`define EXPECT_ERROR_ID(ID) \
    expect_msg(.sev(UVM_ERROR), .id(ID), .fname(`__FILE__), .line(`__LINE__));

`define EXPECT_ERROR_MSG(MSG) \
    expect_msg(.sev(UVM_ERROR), .msg(MSG), .fname(`__FILE__), .line(`__LINE__));

`define EXPECT_ERROR_ID_MSG(ID, MSG) \
    expect_msg(.sev(UVM_ERROR), .id(ID), .msg(MSG), .fname(`__FILE__), .line(`__LINE__));

`define EXPECT_FATAL_ID(ID) \
    expect_msg(.sev(UVM_FATAL), .id(ID), .fname(`__FILE__), .line(`__LINE__));

`define EXPECT_FATAL_MSG(MSG) \
    expect_msg(.sev(UVM_FATAL), .msg(MSG), .fname(`__FILE__), .line(`__LINE__));

`define EXPECT_FATAL_ID_MSG(ID, MSG) \
    expect_msg(.sev(UVM_FATAL), .id(ID), .msg(MSG), .fname(`__FILE__), .line(`__LINE__));




`define UVM_TEST_F(FIXTURE, UNIT_TEST_NAME)                                         \
    class UNIT_TEST_NAME extends FIXTURE;                                           \
        `uvm_component_utils(UNIT_TEST_NAME)                                        \
        static unit_test_pkg::unit_test_info   __only_need_side_effect =            \
            uvm_unit_pkg::uvm_unit_test_runner::register_uvm_unit_test(             \
                `"UNIT_TEST_NAME`", `__FILE__, `__LINE__);                          \
        function new(string name=`"UNIT_TEST_NAME`", uvm_component parent=null);    \
            super.new(name, parent);                                                \
            __ut_info = new(`"UNIT_TEST_NAME`", `__FILE__, `__LINE__);              \
        endfunction

`define UVM_TEST(UNIT_TEST_NAME) \
    `UVM_TEST_F(uvm_unit_pkg::uvm_unit_fixture, UNIT_TEST_NAME)

`define END_UVM_TEST \
    endclass

`define RUN_PHASE_TEST_F(FIXTURE, UNIT_TEST_NAME)   \
    `UVM_TEST_F(FIXTURE, UNIT_TEST_NAME)            \
    virtual task run_phase(uvm_phase phase);        \
        super.run_phase(phase);                     \
        phase.raise_objection(this);                \
        begin

`define END_RUN_PHASE_TEST          \
        end                         \
        phase.drop_objection(this); \
    endtask                         \
    `END_UVM_TEST

`define RUN_PHASE_TEST(UNIT_TEST_NAME)          \
    `UVM_TEST(UNIT_TEST_NAME)                   \
    virtual task run_phase(uvm_phase phase);    \
        super.run_phase(phase);                 \
        phase.raise_objection(this);            \
        begin

`define SV_TEST_F(FIXTURE, UNIT_TEST_NAME)                                              \
    class UNIT_TEST_NAME extends FIXTURE;                                               \
        typedef sv_test_pkg::sv_test_instantiator #(UNIT_TEST_NAME)   creator_t;        \
        static sv_test_pkg::sv_test_factory  __only_need_side_effect =                  \
            sv_test_pkg::sv_test_runner::register_sv_test_creator(                      \
                creator_t::get_creator(), `"UNIT_TEST_NAME`", `__FILE__, `__LINE__);    \
        function new(unit_test_pkg::unit_test_runner tr);                               \
            super.new(tr);                                                              \
            __ut_info = new(`"UNIT_TEST_NAME`", `__FILE__, `__LINE__);                  \
        endfunction                                                                     \
        virtual task test_body();

`define END_SV_TEST \
        endtask     \
    endclass

`define SV_TEST(UNIT_TEST_NAME) \
    `SV_TEST_F(sv_test_pkg::sv_test_fixture, UNIT_TEST_NAME)


`endif // __UNIT_TEST_MACROS_SV__
