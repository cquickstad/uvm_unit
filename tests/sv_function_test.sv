// This test demonstrates and confirms the ability to use sv_test
// on functions outside of a module.

`include "sv_test.svh"

function automatic string fizzbuzz(int i);
    bit     divisible_by_3 = ((i % 3) == 0);
    bit     divisible_by_5 = ((i % 5) == 0);
    if (divisible_by_3 && divisible_by_5) return "fizzbuzz";
    if (divisible_by_5) return "buzz";
    if (divisible_by_3) return "fizz";
    return $sformatf("%0d", i);
endfunction

`SV_TEST(zero_one_two_cases)
    `ASSERT_STR_EQ(fizzbuzz(1), "1")
    `ASSERT_STR_EQ(fizzbuzz(2), "2")
    `ASSERT_STR_EQ(fizzbuzz(4), "4")
`END_SV_TEST

`SV_TEST(fizz_cases)
    `ASSERT_STR_EQ(fizzbuzz(3), "fizz")
    `ASSERT_STR_EQ(fizzbuzz(6), "fizz")
`END_SV_TEST

`SV_TEST(buzz_cases)
    `ASSERT_STR_EQ(fizzbuzz(5), "buzz")
    `ASSERT_STR_EQ(fizzbuzz(10), "buzz")
`END_SV_TEST

`SV_TEST(fizzbuzz_cases)
    `ASSERT_STR_EQ(fizzbuzz(15), "fizzbuzz")
    `ASSERT_STR_EQ(fizzbuzz(30), "fizzbuzz")
`END_SV_TEST
