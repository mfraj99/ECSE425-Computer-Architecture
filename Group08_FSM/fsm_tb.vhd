--Written by Michael Frajman and Shi Tong Li from template provided by Professor Amin Emad

LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY fsm_tb IS
END fsm_tb;

ARCHITECTURE behaviour OF fsm_tb IS

COMPONENT comments_fsm IS
PORT (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
END COMPONENT;

--The input signals with their initial values
SIGNAL clk, s_reset, s_output: STD_LOGIC := '0';
SIGNAL s_input: std_logic_vector(7 downto 0) := (others => '0');

CONSTANT clk_period : time := 1 ns;
CONSTANT SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
CONSTANT STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
CONSTANT NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

BEGIN
dut: comments_fsm
PORT MAP(
clk=>clk, 
reset=>s_reset, 
input=>s_input, 
output=>s_output);

 --clock process
clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;
 
--TODO: Thoroughly test your FSM
stim_process: PROCESS
BEGIN    
	REPORT "Example case, reading a meaningless character";
	s_input <= "01011000";
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "When reading a meaningless character, the output should be '0'" SEVERITY ERROR;
	REPORT "_______________________";
	
	WAIT FOR 1 * clk_period;
	
  REPORT "Test 1, single line comment"; --tests noComment->possibleComment->willBeSingleLine->isSingleLine->commentWillEnd->noComment
	s_input <= "01011000";
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output should be '0'" SEVERITY ERROR;
	s_input <= "01011000";
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output should be '0'" SEVERITY ERROR;
	s_input <= "01011000";
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output should be '1'" SEVERITY ERROR;
	s_input <= "01011000";
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output should be '1'" SEVERITY ERROR;
	s_input <= NEW_LINE_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output should be '1'" SEVERITY ERROR;
	s_input <= "01011000";
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output should be '0'" SEVERITY ERROR;
	REPORT "_______________________";
	
	--testing multi line comments
	
	--testing reset
	
	--testing if it is immediately a "possibleComment" out of the intitial state
	
	--testing if after commentWillEnd it is a possibleComment
	    
	WAIT;
END PROCESS stim_process;
END;
