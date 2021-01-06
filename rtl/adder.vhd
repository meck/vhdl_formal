
library IEEE;
  use IEEE.std_logic_1164.ALL;
  use IEEE.numeric_std.ALL;

entity adder is
  generic (
    formal : boolean := true
  );
  port (
    clk     : in    std_logic;
    reset_n : in    std_logic;
    i0      : in    std_logic;
    i1      : in    std_logic;
    ci      : in    std_logic;
    s       : out   std_logic;
    co      : out   std_logic
  );
end entity adder;

architecture rtl of adder is

begin

  proc_add : process (clk, reset_n) is
  begin

    if (reset_n = '0') then
      s  <= '0';
      co <= '0';
    elsif (clk'event and clk = '1') then
      s  <= i0 xor i1 xor ci;
      co <= (i0 and i1) or (i0 and ci) or (i1 and ci);
    end if;

  end process proc_add;

  formalgen : if formal generate

    default clock is rising_edge(clk);

    -- input series start in reset for 3
    -- cycles and run for 10 cycles
    input_val : restrict {{ (reset_n = '0')[* 3]; (reset_n = '1')[* 60]}[+]};

    -- reset output shall be low on reset
    -- and one cycle after
    output_reset : assert always {reset_n = '0' } |-> {(not s and not co)[* 2] };

    -- Sum high and low
    sum_high : assert always ((i0 xor i1 xor ci) and reset_n) -> next (s = '1') abort reset_n = '0';
    sum_low  : assert always not (i0 xor i1 xor ci) -> next (s = '0');

    -- Carry out high and low
    co_high : assert always (((i0 and i1) or (i0 and ci) or (i1 and ci)) and reset_n) |=> (co) abort reset_n = '0';
    co_low : assert always not ((i0 and i1) or (i0 and ci) or (i1 and ci)) |=> (co = '0');

  end generate formalgen;

end architecture rtl;
