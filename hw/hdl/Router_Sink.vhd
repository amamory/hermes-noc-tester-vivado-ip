----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/07/2020 05:41:32 PM
-- Design Name: 
-- Module Name: Router_Sink - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- very simple packet sink to connect to the Hermes master ports
-- it receives a packet and blink a LED for 1 second
--
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.HeMPS_defaults.all;

entity Router_Sink is
Port ( 
	clock   : in  std_logic;
	reset   : in  std_logic;  
	-- connected to the zedboard
	led_o   : out std_logic;
	-- axi slave streaming interface
	valid_i : in  std_logic;
	ready_o : out std_logic;
	data_i  : in  std_logic_vector(15 downto 0)
);
end Router_Sink;

architecture Behavioral of Router_Sink is

type State_type IS (IDLE, TURN_LED_ON); 
signal state : State_Type;    

signal led_cnt : std_logic_vector(28 downto 0);    
signal led_r : std_logic;


--attribute KEEP : string;
--attribute MARK_DEBUG : string;
--
--attribute KEEP of state : signal is "TRUE";
---- in verilog: (* keep = "true" *) wire signal_name;
--attribute MARK_DEBUG of state : signal is "TRUE";
--
--attribute KEEP of valid_i : signal is "TRUE";
--attribute MARK_DEBUG of valid_i : signal is "TRUE";
--
--attribute KEEP of ready_o : signal is "TRUE";
--attribute MARK_DEBUG of ready_o : signal is "TRUE";
--
--attribute KEEP of data_i : signal is "TRUE";
--attribute MARK_DEBUG of data_i : signal is "TRUE";
--
--attribute KEEP of led_o : signal is "TRUE";
--attribute MARK_DEBUG of led_o : signal is "TRUE";
--
--attribute KEEP of led_cnt : signal is "TRUE";
--attribute MARK_DEBUG of led_cnt : signal is "TRUE";

begin

    process(clock, reset)
    begin
        if (reset = '1') then 
            state <= IDLE;
            led_cnt <= (others => '0');
            led_r <= '0';
        elsif (clock'event and clock = '0') then
            case state is
                when IDLE =>
                    led_r <= '0';
                    led_cnt <= (others => '0');
                    if valid_i = '1' then
                        state <= TURN_LED_ON;
                    end if; 
                when TURN_LED_ON =>
                        led_r <= '1';
                        if led_cnt < 100000000 then -- assuming 100MHz, this will cause a 1s delay
                        --if led_cnt < 100 then -- use this line for simulation
                            led_cnt <= led_cnt + 1;
                        else
                            state <= IDLE;
                        end if;            
            end case;
        end if; 
	end process;

	led_o <= led_r;
	ready_o <= '1';

end Behavioral;
