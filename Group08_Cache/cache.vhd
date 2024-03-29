--Written by Michael Frajman and  Shi Tong Li from template provided by Professor Amin Emad

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0); --bits 0-3 - offset, 4-8 - index, 9-14 - tag, ignore upper 15 bits
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is
  TYPE cache IS ARRAY(31 downto 0) OF STD_LOGIC_VECTOR(134 DOWNTO 0); --32 block cache, bit 134 - valid bit, bit 133 - dirty bit, bits 127 to 132 - tag, bits 0-31, 32-63, 64-95 and 96-127 - 4 words
  SIGNAL cache_block: cache;
  SIGNAL cache_hit : integer; --0 if not hit, 1 if hit
  SIGNAL cache_index : integer; --holds index of inputted cache address
  SIGNAL counter: integer; --counter for read and write to memory
 	SIGNAL read_address_reg: INTEGER RANGE 0 to 31;
	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';
	TYPE state_type is (idle, read, write, write_to_mem_read, read_from_mem, write_to_mem_write, get_from_mem_write);
	SIGNAL z : state_type; 

begin
  
process (clock, reset)
begin
  
    s_waitrequest <= '1'; 
  
    if (reset = '1') or (m_waitrequest = '1') then
      for i in 0 to 31 loop
        cache_block(i)(134 downto 0) <= (others => '0'); --set all blocks to 0
      end loop;
      z<=idle;
      
    elsif (rising_edge(clock)) then
      
      case z is
               
        when idle=>

          if m_waitrequest = '1' then
            z<=idle;
          elsif s_read = '1' then
            z<=read;
          elsif s_write = '1' then
            z<=write;
          end if;
          
        when read=>
            cache_hit <= 0;
            for i in 0 to 31 loop --loop for attempting a cache hit
              if ((cache_block(i)(134 downto 134) = "1") and (cache_block(i)(132 downto 127) = s_addr(14 downto 9)))then --check valid and tag
                if (cache_block(i)(3 downto 2) = s_addr(3 downto 2)) then --check offsets for correct word and return that word
                  s_readdata <= cache_block(i) (31 downto 0);
                elsif (cache_block(i)(35 downto 34) = s_addr(3 downto 2)) then
                  s_readdata <= cache_block(i) (63 downto 32);
                elsif (cache_block(i)(67 downto 66) = s_addr(3 downto 2)) then
                  s_readdata <= cache_block(i) (95 downto 64);
                elsif (cache_block(i)(99 downto 98) = s_addr(3 downto 2)) then
                  s_readdata <= cache_block(i) (127 downto 96);
                end if;
                cache_hit <= 1;
              end if;
            end loop;
            
            if cache_hit = 0 then --cache miss
              cache_index <= to_integer(unsigned(s_addr(8 downto 4)));
              if (cache_block(cache_index)(133 downto 133) = "1" and cache_block(cache_index)(134 downto 134) = "1") then --dirty need to write back before reading new memory
                counter <= 0;
                z<= write_to_mem_read;
              else
                counter <=0;
                z<= read_from_mem;
              end if;
            end if;

            z<=idle;

        when write_to_mem_read=>
          if counter < 15 and m_waitrequest = '0' then -- 16 bytes to write, loop using states
            m_write <= '1';
            m_read <= '0';
            m_addr <= to_integer(unsigned(cache_block(cache_index)(132 downto 127)) & unsigned(s_addr(8 downto 4)) & "0000") + counter; --address is tag + index + offset
            m_writedata <= cache_block(cache_index)(counter * 8 + 7 downto counter * 8);
            counter <= counter+1;
            z<=write_to_mem_read;
          elsif counter = 15 then -- finished writing 16 bytes, read from memory
            counter <= 0;
            z<=read_from_mem;
          elsif m_waitrequest = '1' then
            z<=write_to_mem_read;
          end if;

        when read_from_mem=>
          if counter < 15 and m_waitrequest = '0' then
            m_write <= '0';
            m_read <= '1';
            m_addr <= to_integer(unsigned(cache_block(cache_index)(132 downto 127)) & unsigned(s_addr(8 downto 4)) & "0000") + counter; --address is tag + index + offset
            cache_block(cache_index)(counter * 8 + 7 downto counter * 8) <= m_readdata;
            counter <=counter+1;
            z<=read_from_mem;
          elsif counter = 15 then
            cache_block(cache_index)(134 downto 134)<= "1"; --set valid to 1
            cache_block(cache_index)(133 downto 133)<= "0"; --set dirty to 0
            if (cache_block(cache_index)(3 downto 2)) = s_addr(3 downto 2) then --check offsets for correct word and return that word
              s_readdata <= cache_block(cache_index) (31 downto 0);
            elsif (cache_block(cache_index)(35 downto 34)) = s_addr(3 downto 2) then
              s_readdata <= cache_block(cache_index) (63 downto 32);
            elsif (cache_block(cache_index)(67 downto 66)) = s_addr(3 downto 2) then
              s_readdata <= cache_block(cache_index) (95 downto 64);
            elsif (cache_block(cache_index)(99 downto 98)) = s_addr(3 downto 2) then
              s_readdata <= cache_block(cache_index) (127 downto 96);
            end if;
            z<= idle;
          elsif m_waitrequest = '1' then
            z<=read_from_mem;
          end if;

        when write=>
          cache_hit <= 0;
            for i in 0 to 31 loop --loop for attempting a cache hit
              if (cache_block(i)(134 downto 134) = "1") and (cache_block(i)(132 downto 127) = s_addr(14 downto 9))then --check valid and tag
                if (cache_block(i)(3 downto 2)) = s_addr(3 downto 2) then --check offsets for correct word and return that word
                  cache_block(i) (31 downto 0) <=s_writedata;
                elsif (cache_block(i)(35 downto 34))= s_addr(3 downto 2) then
                  cache_block(i) (63 downto 32) <=s_writedata;
                elsif (cache_block(i)(67 downto 66)) = s_addr(3 downto 2) then
                  cache_block(i) (95 downto 64) <=s_writedata;
                elsif (cache_block(i)(99 downto 98)) = s_addr(3 downto 2) then
                  cache_block(i) (127 downto 96) <=s_writedata;
                end if;
                cache_hit <= 1;
                cache_block(i)(133 downto 133) <= "1"; --dirty block
              end if;
            end loop;
            
            if cache_hit = 0 then --cache miss
              cache_index <= to_integer(unsigned(s_addr(8 downto 4)));
              if (cache_block(cache_index)(133 downto 133) = "1" and cache_block(cache_index)(134 downto 134) = "1") then --dirty need to write back before reading new memory
                counter <= 0;
                z<= write_to_mem_write;
              elsif (cache_block(cache_index)(134 downto 134) = "1" and cache_block(cache_index)(133 downto 133) = "0")then --not dirty, valid, overwrite, no need to write to mem
                if (cache_block(cache_index)(3 downto 2)) = s_addr(3 downto 2) then --check offsets for correct word and return that word
                  cache_block(cache_index) (31 downto 0) <=s_writedata;
                elsif (cache_block(cache_index)(35 downto 34)) = s_addr(3 downto 2) then
                  cache_block(cache_index) (63 downto 32) <=s_writedata;
                elsif (cache_block(cache_index)(67 downto 66)) = s_addr(3 downto 2) then
                  cache_block(cache_index) (95 downto 64) <=s_writedata;
                elsif (cache_block(cache_index)(99 downto 98)) = s_addr(3 downto 2) then
                  cache_block(cache_index) (127 downto 96) <=s_writedata;
                end if;
                cache_block(cache_index)(133 downto 133) <= "1"; --dirty block
              else --not valid, need to get block from mem
                counter <=0;
                z<= get_from_mem_write;
              end if;
            end if;
            
            s_waitrequest <= '0';
            z<=idle;
                

        when write_to_mem_write=>
          if counter < 15 and m_waitrequest = '0' then --16 bytes to write
            m_write <= '1';
            m_read <= '0';
            m_addr <= to_integer(unsigned(cache_block(cache_index)(132 downto 127)) & unsigned(s_addr(8 downto 4)) & "0000") + counter; --address is tag + index + offset
            m_writedata <= cache_block(cache_index)(counter * 8 + 7 DOWNTO counter * 8);
            counter <= counter+1;
            z<=write_to_mem_write;
          elsif counter = 15 then --finished writing 16 bytes, 
            if (cache_block(cache_index)(3 downto 2)) = s_addr(3 downto 2) then --check offsets for correct word and return that word
              cache_block(cache_index) (31 downto 0) <=s_writedata;
            elsif (cache_block(cache_index)(35 downto 34)) = s_addr(3 downto 2) then
              cache_block(cache_index) (63 downto 32) <=s_writedata;
            elsif (cache_block(cache_index)(67 downto 66)) = s_addr(3 downto 2) then
              cache_block(cache_index) (95 downto 64) <=s_writedata;
            elsif (cache_block(cache_index)(99 downto 98)) = s_addr(3 downto 2) then
              cache_block(cache_index) (127 downto 96) <=s_writedata;
            end if;
            cache_block(cache_index)(133 downto 133) <= "1"; --dirty block
            z<=idle;
          elsif m_waitrequest = '1' then
            z<=write_to_mem_write;
          end if;

        when get_from_mem_write=>
          if counter < 15 and m_waitrequest = '0' then
            m_write <= '0';
            m_read <= '1';
            m_addr <= to_integer(unsigned(cache_block(cache_index)(132 downto 127)) & unsigned(s_addr(8 downto 4)) & "0000") + counter; --address is tag + index + offset
            cache_block(cache_index)(counter * 8 + 7 downto counter * 8) <= m_readdata;
            counter <=counter+1;
            z<=get_from_mem_write;
          elsif counter = 15 then
            cache_block(cache_index)(134 downto 134)<= "1"; --set valid to 1
            cache_block(cache_index)(133 downto 133) <= "1"; --dirty block
            if (cache_block(cache_index)(3 downto 2)) = s_addr(3 downto 2) then --check offsets for correct word and return that word
                  cache_block(cache_index) (31 downto 0) <=s_writedata;
                elsif (cache_block(cache_index)(35 downto 34)) = s_addr(3 downto 2) then
                  cache_block(cache_index) (63 downto 32) <=s_writedata;
                elsif (cache_block(cache_index)(67 downto 66)) = s_addr(3 downto 2) then
                  cache_block(cache_index) (95 downto 64) <=s_writedata;
                elsif (cache_block(cache_index)(99 downto 98)) = s_addr(3 downto 2) then
                  cache_block(cache_index) (127 downto 96) <=s_writedata;
                end if;
            z<= idle;
          elsif m_waitrequest = '1' then
            z<=get_from_mem_write;
          end if;
        
      end case;
  end if;

end process;

end arch;