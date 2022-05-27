-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xlencs00
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK : in std_logic;
   RST : in std_logic;
   DIN : in std_logic;
   READING_D : out std_logic;
   ST_CLK_CNT : in std_logic_vector(4 downto 0);--skip 24 counter
   ST_CLK_CNT_EN : out std_logic;
   BIT_CNT : in std_logic_vector(3 downto 0);
   STOP_CNT : in std_logic_vector(3 downto 0);
   STOP_CNT_EN : out std_logic;
   BIT_CNT_EN : out std_logic;
   DOUT_VLD : out std_logic;
   DOUT : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type STATE_TYPE is (START_POS,SKIP_BIT,READ_DIN,STOP_BIT,END_NRST);
signal state : STATE_TYPE := START_POS;
begin
      STOP_CNT_EN <= '1' when state = STOP_BIT else '0';
      ST_CLK_CNT_EN <= '1' when state = SKIP_BIT or state = READ_DIN else '0';
      DOUT_VLD <= '1' when state = END_NRST else '0';
      READING_D <= '1' when state = READ_DIN else '0';
      BIT_CNT_EN <= '1' when state = READ_DIN else '0';
      process(CLK) begin
        if rising_edge(CLK) then
          if RST = '1' then
            state <= START_POS;
          else
            case state is
            when START_POS =>
                    if DIN = '0' then
                        state <= SKIP_BIT;
                    end if;
            when SKIP_BIT =>
                    if ST_CLK_CNT = "01000" then
                        state <= READ_DIN;
                    end if;
            when READ_DIN =>
                    if BIT_CNT = "1000" then
                      state <= STOP_BIT;
                    end if;
              
            when STOP_BIT => 
                    if STOP_CNT = "1000" then
                      state <= END_NRST;
                    end if;
            when END_NRST => state <= START_POS;
            when others => null;
            end case;
          end if;
        end if;
    end process;
end behavioral;
