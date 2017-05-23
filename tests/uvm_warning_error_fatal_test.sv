`include "uvm_unit.svh"
import uvm_unit_pkg::*;

class my_checker extends uvm_scoreboard;
    `uvm_component_utils(my_checker)
    function new(string name="my_cut", uvm_component parent=null);
        super.new(name, parent);
    endfunction
    virtual function void wrn(string id, string msg);
        `uvm_warning(id, msg)
    endfunction
    virtual function void err(string id, string msg);
        `uvm_error(id, msg)
    endfunction
    virtual function void ftl(string id, string msg);
        `uvm_fatal(id, msg)
    endfunction
endclass

class fxtr extends uvm_unit_fixture;
    `uvm_component_utils(fxtr)
    my_checker      chkr;
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        chkr = my_checker::type_id::create("chkr", this);
    endfunction
endclass

`RUN_PHASE_TEST_F(fxtr, a_test_with_an_unexpected_warning_should_fail)
    #1;
    chkr.wrn("ID1", "Msg1");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_an_unexpected_error_should_fail)
    #1;
    chkr.err("E1", "Err1");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_an_unexpected_fatal_should_fail)
    #1;
    chkr.ftl("F1", "Ftl1");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_warning_id_that_does_not_match_the_expected_warning_id_should_fail)
    `EXPECT_WARNING_ID("blah blah")
    #1;
    chkr.wrn("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_error_id_that_does_not_match_the_expected_error_id_should_fail)
    `EXPECT_ERROR_ID("blah blah")
    #1;
    chkr.err("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_fatal_id_that_does_not_match_the_expected_fatal_id_should_fail)
    `EXPECT_FATAL_ID("blah blah")
    #1;
    chkr.ftl("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_warning_msg_that_does_not_match_the_expected_warning_msg_should_fail)
    `EXPECT_WARNING_MSG("blah blah")
    #1;
    chkr.wrn("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_error_msg_that_does_not_match_the_expected_error_msg_should_fail)
    `EXPECT_ERROR_MSG("blah blah")
    #1;
    chkr.err("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_fatal_msg_that_does_not_match_the_expected_fatal_msg_should_fail)
    `EXPECT_FATAL_MSG("blah blah")
    #1;
    chkr.ftl("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_warning_id_msg_that_does_not_match_the_expected_warning_id_msg_should_fail)
    `EXPECT_WARNING_ID_MSG("BAR", "FOO")
    #1;
    chkr.wrn("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_error_id_msg_that_does_not_match_the_expected_error_id_msg_should_fail)
    `EXPECT_ERROR_ID_MSG("BAR", "FOO")
    #1;
    chkr.err("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_a_fatal_id_msg_that_does_not_match_the_expected_fatal_id_msg_should_fail)
    `EXPECT_FATAL_ID_MSG("BAR", "FOO")
    #1;
    chkr.ftl("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, an_expected_warning_that_never_happens_should_fail)
    `EXPECT_WARNING_ID("FOO")
    #10;
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, an_expected_error_that_never_happens_should_fail)
    `EXPECT_ERROR_ID("BAR")
    #10;
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, an_expected_fatal_that_never_happens_should_fail)
    `EXPECT_FATAL_ID("BAZ")
    #10;
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, messages_of_different_severity_seen_out_of_the_expected_order_should_fail)
    `EXPECT_FATAL_ID("FOO")
    `EXPECT_ERROR_ID("BAR")
    #10;
    chkr.err("BAR", "x");
    chkr.ftl("FOO", "x");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, id_and_msg_expected_for_a_different_severity_should_fail)
    `EXPECT_FATAL_ID_MSG("FOO", "BAR")
    #10;
    chkr.err("FOO", "BAR");
`END_RUN_PHASE_TEST

`RUN_PHASE_TEST_F(fxtr, a_test_with_expected_mesages_in_the_expected_order_should_pass)
    `EXPECT_WARNING_ID("ID1")
    `EXPECT_WARNING_MSG("Msg2")
    `EXPECT_WARNING_ID_MSG("ID3", "Msg3")
    `EXPECT_ERROR_ID("ID4")
    `EXPECT_ERROR_MSG("Msg5")
    `EXPECT_ERROR_ID_MSG("ID6", "Msg6")
    `EXPECT_FATAL_ID("ID7")
    `EXPECT_FATAL_MSG("Msg8")
    `EXPECT_FATAL_ID_MSG("ID9", "Msg9")
    chkr.wrn("ID1", "Msg1");
    chkr.wrn("ID2", "Msg2");
    chkr.wrn("ID3", "Msg3");
    chkr.err("ID4", "Msg4");
    chkr.err("ID5", "Msg5");
    chkr.err("ID6", "Msg6");
    chkr.ftl("ID7", "Msg7");
    chkr.ftl("ID8", "Msg8");
    chkr.ftl("ID9", "Msg9");
`END_RUN_PHASE_TEST
