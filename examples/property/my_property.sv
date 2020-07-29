property a_and_b_together(reg valid, reg a, reg b);
  @(posedge clock)
    disable iff (reset === 1)
    valid && a |-> b;
endproperty

property a_and_b_no_args;
  @(posedge clock)
    disable iff (reset === 1)
    valid && a |-> b;
endproperty