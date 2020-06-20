----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/07/2020 03:35:38 PM
-- Design Name: 
-- Module Name: Router_Board - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

entity Router_Board is
  Port ( 
  clock:     in  std_logic;
  reset:     in  std_logic;  
  -- connected to the zedboad
  dip_i   : in  std_logic_vector(7 downto 0);
  send_i  : in  std_logic_vector(3 downto 0);
  end_i   : in  std_logic;
  led_o   : out std_logic_vector(3 downto 0);
  -- AXI Stream slave interfaces: E, W, N, S, Local ports
  rxL_i:     in  std_logic;
  dataL_i:   in  std_logic_vector(31 downto 0); -- the local ports have 32 bits
  creditL_o: out std_logic;    

  -- AXI Stream master interfaces: E, W, N, S, Local ports
  txL_o:     out std_logic;
  dataL_o:   out std_logic_vector(31 downto 0); -- the local ports have 32 bits
  creditL_i: in  std_logic  
  
  );
end Router_Board;

architecture Behavioral of Router_Board is
    -- signals connected to the slave ports
    signal s_validE:  std_logic;
    signal s_dataE:   std_logic_vector(15 downto 0);
    signal s_readyE:  std_logic;    
    
    signal s_validW:  std_logic;
    signal s_dataW:   std_logic_vector(15 downto 0);
    signal s_readyW:  std_logic;    
    
    signal s_validN:  std_logic;
    signal s_dataN:   std_logic_vector(15 downto 0);
    signal s_readyN:  std_logic;    
    
    signal s_validS:  std_logic;
    signal s_dataS:   std_logic_vector(15 downto 0);
    signal s_readyS:  std_logic;
    
    -- signals connected to the master ports
    signal m_validE:  std_logic;
    signal m_dataE:   std_logic_vector(15 downto 0);
    signal m_readyE:  std_logic;
    
    signal m_validW:  std_logic;
    signal m_dataW:   std_logic_vector(15 downto 0);
    signal m_readyW:  std_logic;
    
    signal m_validN:  std_logic;
    signal m_dataN:   std_logic_vector(15 downto 0);
    signal m_readyN:  std_logic;
    
    signal m_validS:  std_logic;
    signal m_dataS:   std_logic_vector(15 downto 0);
    signal m_readyS:  std_logic;
    
    
    signal dataL_o_s: std_logic_vector(15 downto 0);
    signal reset_s : std_logic;
    signal clock_s : std_logic;

begin

reset_s <= not reset; -- AXI uses active low reset but hermes uses active high
clock_s <= not clock; -- AXI uses rising edge
dataL_o <= x"0000" & dataL_o_s; 

router: entity work.RouterCC
port map(
	clock      => clock_s,
	reset      => reset_s,
	-- AXI Stream slave interfaces  E, W, N, S, Local ports
	rxE_i      => s_validE,
	dataE_i    => s_dataE,
	creditE_o  => s_readyE,    

	rxW_i      => s_validW,
	dataW_i    => s_dataW, 
	creditW_o  => s_readyW,

	rxN_i      => s_validN,
	dataN_i    => s_dataN, 
	creditN_o  => s_readyN,
				  
	rxS_i      => s_validS,
	dataS_i    => s_dataS, 
	creditS_o  => s_readyS,
						   
	rxL_i      => rxL_i    ,
	dataL_i    => dataL_i(15 downto 0)  ,
	creditL_o  => creditL_o,
				  
	txE_o      => m_validE,
	dataE_o    => m_dataE, 
	creditE_i  => m_readyE,
					         
	txW_o      => m_validW,
	dataW_o    => m_dataW, 
	creditW_i  => m_readyW,
				           
	txN_o      => m_validN,
	dataN_o    => m_dataN, 
	creditN_i  => m_readyN,
					         
	txS_o      => m_validS,
	dataS_o    => m_dataS, 
	creditS_i  => m_readyS,
				  
	txL_o      => txL_o    ,
	dataL_o    => dataL_o_s  ,
	creditL_i  => creditL_i
);

source_E: entity work.Router_Source
port map(
	clock   => clock  ,
	reset   => reset_s  ,
	dip_i   => dip_i  ,
	send_i  => send_i(0) ,
	end_i   => end_i  ,
	valid_o => s_validE,
	ready_i => s_readyE, 
	data_o  => s_dataE
);

source_W: entity work.Router_Source
port map(
	clock   => clock  ,
	reset   => reset_s  ,
	dip_i   => dip_i  ,
	send_i  => send_i(1) ,
	end_i   => end_i  ,
	valid_o => s_validW,
	ready_i => s_readyW,
	data_o  => s_dataW  
);

source_N: entity work.Router_Source
port map(
	clock   => clock  ,
	reset   => reset_s  ,
	dip_i   => dip_i  ,
	send_i  => send_i(2) ,
	end_i   => end_i  ,
	valid_o => s_validN,
	ready_i => s_readyN,
	data_o  => s_dataN  
);

source_S: entity work.Router_Source
port map(
	clock   => clock  ,
	reset   => reset_s  ,
	dip_i   => dip_i  ,
	send_i  => send_i(3) ,
	end_i   => end_i  ,
	valid_o => s_validS,
	ready_i => s_readyS,
	data_o  => s_dataS  
);

-- sinks to LEDs

sink_E: entity work.Router_Sink
port map ( 
	clock   => clock_s,
	reset   => reset_s,
	led_o   => led_o(0),
	valid_i => m_validE,
	ready_o => m_readyE,
	data_i  => m_dataE  
);

sink_W: entity work.Router_Sink
port map ( 
	clock   => clock_s,
	reset   => reset_s,
	led_o   => led_o(1),
	valid_i => m_validW,
	ready_o => m_readyW,
	data_i  => m_dataW  
);

sink_N: entity work.Router_Sink
port map ( 
	clock   => clock_s,
	reset   => reset_s,
	led_o   => led_o(2),
	valid_i => m_validN,
	ready_o => m_readyN,
	data_i  => m_dataN  
);

sink_S: entity work.Router_Sink
port map ( 
	clock   => clock_s,
	reset   => reset_s,
	led_o   => led_o(3),
	valid_i => m_validS,
	ready_o => m_readyS,
	data_i  => m_dataS  
);


end Behavioral;
