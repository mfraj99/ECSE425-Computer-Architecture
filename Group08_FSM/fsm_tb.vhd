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
CONSTANT A : std_logic_vector(7 downto 0) := "01000001";
CONSTANT ONE : std_logic_vector(7 downto 0) := "00110001";
CONSTANT SPACE : std_logic_vector(7 downto 0) := "00100000";

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
 
--all tests end in a "noComment" state in order to not affect the proceesing test
--if tests did not end in "noComment", it would requrie the use of the reset bit as proceeding tests may start within a comment when it is not desired

stim_process: PROCESS
BEGIN    
  REPORT "***TEST 1, single line comment***"; 
  --tests noComment->possibleComment->willBeSingleLine->isSingleLine->commentWillEnd->noComment
  --sequence "A1// A\n "
  --output 00001110
	s_input <= A;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(1) should be '0'" SEVERITY ERROR;
	s_input <= ONE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(2) should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(3) should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(4) should be '0'" SEVERITY ERROR;
	s_input <= SPACE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(5) should be '1'" SEVERITY ERROR;
	s_input <= A;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(6) should be '1'" SEVERITY ERROR;
	s_input <= NEW_LINE_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(7) should be '1'" SEVERITY ERROR;
	s_input <= SPACE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(8) should be '0'" SEVERITY ERROR;
	REPORT "_______________________";
	
	WAIT FOR 1 * clk_period;
	
  REPORT "***TEST 2, multi line comment***";
  --tests noComment->possibleComment->willBeMultiLine->isMultiLine->multiLineMayEnd->commentWillEnd->noComment
  --sequence " 1/*11\n*/A"
  --output 0000111110
	s_input <= SPACE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(1) should be '0'" SEVERITY ERROR;
	s_input <= ONE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(2) should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(3) should be '0'" SEVERITY ERROR;
	s_input <= STAR_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(4) should be '0'" SEVERITY ERROR;
	s_input <= ONE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(5) should be '1'" SEVERITY ERROR;
	s_input <= ONE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(6) should be '1'" SEVERITY ERROR;
	s_input <= NEW_LINE_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(7) should be '1'" SEVERITY ERROR;
	s_input <= STAR_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(8) should be '1'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(9) should be '1'" SEVERITY ERROR;
	s_input <= A;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(10) should be '0'" SEVERITY ERROR;
	REPORT "_______________________";
	
	WAIT FOR 1 * clk_period;
	
  REPORT "***TEST 3, reset***"; --tests the reset bit
  --tests noComment->possibleComment->willBeSingleLine->isSingleLine->reset->possibleComment->willBeMultiLine->isMultiLine->multiLineMayEnd->commentWillEnd->noComment
  --sequence " 1//1<reset>/**A*/1"
  --output 000010011110
	s_input <= SPACE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(1) should be '0'" SEVERITY ERROR;
	s_input <= ONE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(2) should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(3) should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(4) should be '0'" SEVERITY ERROR;
	s_input <= ONE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(5) should be '1'" SEVERITY ERROR;
	s_reset <= '1';
	s_input <= SLASH_CHARACTER; 
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(6) should be '0'" SEVERITY ERROR;
	s_reset <= '0';
	s_input <= STAR_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(7) should be '0'" SEVERITY ERROR;
	s_input <= STAR_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(8) should be '1'" SEVERITY ERROR;
	s_input <= A;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(9) should be '1'" SEVERITY ERROR;
	s_input <= STAR_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(10) should be '1'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(11) should be '1'" SEVERITY ERROR;
	s_input <= ONE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(12) should be '0'" SEVERITY ERROR;
	REPORT "_______________________";
	
	WAIT FOR 1 * clk_period;
	
  REPORT "***TEST 4, first character is a possible comment***";--testing if it is immediately a "possibleComment" out of the intitial state
  --also tests if reset will go to a "noComment"
  --tests possibleComment->willBeSingleLine->isSingleLine->reset->noComment
  --sequence "//*A<reset>\nA"
  --output 001100
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(1) should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(2) should be '0'" SEVERITY ERROR;
	s_input <= STAR_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(3) should be '1'" SEVERITY ERROR;
	s_input <= A;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(4) should be '1'" SEVERITY ERROR;
	s_reset <= '1';
	s_input <= NEW_LINE_CHARACTER; 
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(5) should be '0'" SEVERITY ERROR;
	s_reset <= '0';
	s_input <= A;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(6) should be '0'" SEVERITY ERROR;
	REPORT "_______________________";
	
	WAIT FOR 1 * clk_period;
	
  REPORT "***TEST 5, possible comment after termination of previous comment***";--testing if after "commentWillEnd" it is a "possibleComment"
  --tests possibleComment->willBeSingleLine->commentWillEnd->possibleComment->willBeSingleLine->isSingleLine->commentWillEnd->possibleComment->noComment
  --sequence "//\n//A\n/1"
  --output 001001100
  s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(1) should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(2) should be '0'" SEVERITY ERROR;
	s_input <= NEW_LINE_CHARACTER; 
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(3) should be '1'" SEVERITY ERROR;
	 s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(4) should be '0'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(5) should be '0'" SEVERITY ERROR;
	s_input <= A;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(6) should be '1'" SEVERITY ERROR;
	s_input <= NEW_LINE_CHARACTER; 
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "The output(7) should be '1'" SEVERITY ERROR;
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(8) should be '0'" SEVERITY ERROR;
  s_input <= ONE;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "The output(9) should be '0'" SEVERITY ERROR;
	REPORT "_______________________";
	
	REPORT "***TESTS COMPLETE***";
	    
	WAIT;
END PROCESS stim_process;
END;
