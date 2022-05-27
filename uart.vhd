-- uart.vhd: UART controller - receiving part
-- Author(s): xlencs00
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
  CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0);
	DOUT_VLD: 	out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal bit_cnt : std_logic_vector(3 downto 0);
signal reading_d : std_logic;
signal st_clk_cnt_en : std_logic;
signal st_clk_cnt : std_logic_vector(4 downto 0);
signal bit_cnt_en : std_logic;
signal last_state : std_logic;
signal stop_cnt_en : std_logic;
signal stop_cnt : std_logic_vector(3 downto 0);
begin
    FSM: entity work.UART_FSM(behavioral)
    port map(
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        READING_D => reading_d,
        ST_CLK_CNT => st_clk_cnt,
        ST_CLK_CNT_EN => st_clk_cnt_en,
        BIT_CNT => bit_cnt,
        BIT_CNT_EN => bit_cnt_en,
        STOP_CNT_EN => stop_cnt_en,
        STOP_CNT => stop_cnt,
        DOUT_VLD => dout_vld
    );
    process(CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                DOUT <= "00000000";
                st_clk_cnt <= "00000";
                bit_cnt <= "0000";
                stop_cnt <= "0000";
            else 
                if st_clk_cnt_en = '1' then
                    st_clk_cnt <= st_clk_cnt + 1;
                else
                    st_clk_cnt <= "00000";
                end if;
        --read din
             if reading_d = '1' then
               if st_clk_cnt(4) = '1' then 
                  case bit_cnt is
                    when "0000" => DOUT(0) <= DIN; 
                    when "0001" => DOUT(1) <= DIN; 
                    when "0010" => DOUT(2) <= DIN; 
                    when "0011" => DOUT(3) <= DIN; 
                    when "0100" => DOUT(4) <= DIN; 
                    when "0101" => DOUT(5) <= DIN;  
                    when "0110" => DOUT(6) <= DIN; 
                    when "0111" => DOUT(7) <= DIN;  
                  when others => null;
                end case;
                bit_cnt <= bit_cnt + 1;
                st_clk_cnt <= "00000";
                
              end if;
            else
               bit_cnt <= "0000";
            end if;
            if stop_cnt_en = '1' then
              stop_cnt <= stop_cnt + 1;
            end if;
          end if;
        end if;
    end process;
end behavioral;
