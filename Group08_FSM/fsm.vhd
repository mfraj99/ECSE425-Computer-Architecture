--Written by Michael Frajman and Shi Tong Li from template provided by Professor Amin Emad

library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Do not modify the port map of this structure
entity comments_fsm is
port (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
end comments_fsm;

architecture behavioral of comments_fsm is

-- The ASCII value for the '/', '*' and end-of-line characters
constant SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
constant STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
constant NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

type State_type is (notComment, possibleComment, willBeSingleLine, willBeMultiLine, isSingleLine, isMultiLine, multiLineMayEnd, commentWillEnd);
signal z : State_type;

begin

process (clk, reset)
begin
  
    if ((reset = '1') and (input /= SLASH_CHARACTER)) then
      z<=notComment;
      
    elsif ((reset = '1') and (input = SLASH_CHARACTER)) then
      z<=possibleComment;
      
    elsif (rising_edge(clk)) then
      
      case z is
        
        when notComment=> 
          if input = SLASH_CHARACTER then
            z<=possibleComment;
          else
            z<=notComment;
          end if;
          
        when possibleComment=>
          if input = SLASH_CHARACTER then
            z<=willBeSingleLine;
          elsif input = STAR_CHARACTER then
            z<=willBeMultiLine;
          else
            z<=notComment;
          end if;
          
        when willBeSingleLine=>
          if input = NEW_LINE_CHARACTER then
            z<=commentWillEnd;
          else
            z<=isSingleLine;
          end if;
          
        when willBeMultiLine=>
          if input = STAR_CHARACTER then
            z<=multiLineMayEnd;
          else
            z<=isMultiLine;
          end if;
          
        when isSingleLine=>
          if input = NEW_LINE_CHARACTER then
            z<=commentWillEnd;
          else
            z<=isSingleLine;
          end if;
          
        when isMultiLine=>
          if input = STAR_CHARACTER then
            z<=multiLineMayEnd;
          else
            z<=isMultiLine;
          end if;
          
        when multiLineMayEnd=>
          if input = SLASH_CHARACTER then
            z<=commentWillEnd;
          else
            z<=isMultiLine;
          end if;
          
        when commentWillEnd=>
          if input = SLASH_CHARACTER then
            z<=possibleComment;
          else
            z<=notComment;
          end if;
          
        end case;
        
      end if;
    
end process;

output<=
  '0' when z = notComment else
  '0' when z = possibleComment else
  '0' when z = willBeSingleLine else
  '0' when z = willBeMultiLine else
  '1' when z = isSingleLine else
  '1' when z = isMultiLine else
  '1' when z = multiLineMayEnd else
  '1' when z = commentWillEnd;

end behavioral;