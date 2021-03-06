-- very simple tb to create an inboud and an outbound transactions.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL; 

entity tb is
end tb;

architecture tb of tb is
    -- change here if you want to send more packets
    constant N_PACKETS : integer := 3; 
    -- change here if you want to send longer packets
    constant MAX_FLITS : integer := 3;

	signal clock:    std_logic := '0';
	signal reset:    std_logic;  

	-- connected to the board
	signal dip_i   : std_logic_vector(7 downto 0);
	signal send_i  : std_logic_vector(3 downto 0);
	signal end_i   : std_logic;
	signal led_o   : std_logic_vector(3 downto 0);

	-- slave local port
	signal rxL_i:    std_logic;
	signal dataL_i:  std_logic_vector(31 downto 0);
	signal creditL_o:std_logic;    
	-- master local port
	signal txL_o:    std_logic;
	signal dataL_o:  std_logic_vector(31 downto 0);
	signal creditL_i:std_logic; 
	
	-- send one work according to the AXI Streaming master protocol
	procedure SendFlit(signal clock  : in  std_logic;
	                   constant flit : in  std_logic_vector(31 downto 0);
	                   --- AXI master streaming 
	                   signal data   : out std_logic_vector(31 downto 0);
	                   signal valid  : out std_logic;
	                   signal ready  : in  std_logic
	                   ) is
	begin
		wait until rising_edge(clock);
		-- If both the AXI interface and the router runs at the rising edge, then it is necessary to add 
		--   a delay at the inputs. The solution was to put an inverted in the clock in the Router_Board entity. 
		-- This way the delay is not necessary and it is also not necessary to change the router's vhdl   
        --wait for 8ns; -- simulate delay at the primary inputs
        data <= flit;
        valid <= '1';
        while ready /= '1' loop
             wait until falling_edge(clock); -- data is buffered at the falling edge
        end loop;	
	end procedure;
	
	
begin

	reset <= '0', '1' after 100 ns; -- active low

    -- 100 MHz, as the default freq generated by the PS
	process
	begin
		clock <= not clock;
		wait for 5 ns;
		clock <= not clock;
		wait for 5 ns;
	end process;

    ----------------------------------------------------
    -- testing the flow from East dip to master port
    -- this should fire a packet from the slave east port to the master local port
    ----------------------------------------------------
	process
	begin
	    creditL_i <= '0';
	    dip_i <= x"00";
        send_i <= (others => '0');
        end_i <= '0';
        wait until reset = '1';
        
        -- the master interface always has credit
        creditL_i <= '1';
        
        -- send a packet from hermes' east port to the zynq via hermes' local master interface
        dip_i <= x"55";
        send_i <= (others => '0');
        end_i <= '0';
        wait for 250 ns;
        send_i(0) <= '1';
        wait for 100 ns;
        send_i(0) <= '0';
        wait for 100 ns;
        end_i <= '1';
        wait for 100 ns;
        end_i <= '0';
        wait for 200 ns;
        -- send another packet again, similar to the previous one
        dip_i <= x"AA";
        send_i <= (others => '0');
        end_i <= '0';
        wait for 250 ns;
        send_i(0) <= '1';
        wait for 100 ns;
        send_i(0) <= '0';
        wait for 100 ns;
        end_i <= '1';
        wait for 100 ns;
        end_i <= '0';
        wait for 200 ns;
        -- send a packet from hermes' west port to the zynq via hermes' local master interface
        dip_i <= x"12";
        send_i <= (others => '0');
        end_i <= '0';
        wait for 250 ns;
        send_i(1) <= '1';
        wait for 100 ns;
        send_i(1) <= '0';
        wait for 100 ns;
        end_i <= '1';
        wait for 100 ns;
        end_i <= '0';
        wait for 200 ns;
        
        -- send two packets from hermes' north and south ports to the zynq via hermes' local master interface
        dip_i <= x"21";
        send_i <= (others => '0');
        end_i <= '0';
        wait for 250 ns;
        send_i(2) <= '1';
        send_i(3) <= '1';
        wait for 100 ns;
        send_i(2) <= '0';
        send_i(3) <= '0';
        wait for 100 ns;
        end_i <= '1';
        wait for 100 ns;
        end_i <= '0';
        wait for 200 ns;

		
		wait;
	end process;


    ----------------------------------------------------
    -- testing the flow from the slave port to the Sink LEDs
    ----------------------------------------------------
    process
        -- it sends N_PACKETS packets of max size of of MAX_FLITS 
        type packet_vet_t is array (0 to N_PACKETS-1, 0 to MAX_FLITS+1) of std_logic_vector(31 downto 0);
        constant packet_vet : packet_vet_t := 
            (
                (x"00000021", x"00000001", x"00001234", x"00000000", x"00000000"), -- send it to the east
                (x"00000021", x"00000001", x"00004321", x"00000000", x"00000000"), -- send it to the east
                (x"00000001", x"00000003", x"00001234", x"00002341", x"00003412")  -- send it to the west
            );
         variable num_flits : integer;
	begin
		rxL_i <= '0';
		dataL_i <= (others => '0');
		wait for 4000 ns;
		wait until rising_edge(clock);
		
		for p in 0 to N_PACKETS-1 loop
		  -- send header
		  SendFlit(clock,packet_vet(p,0),dataL_i,rxL_i,creditL_o);
		  -- send size
		  SendFlit(clock,packet_vet(p,1),dataL_i,rxL_i,creditL_o);
		  num_flits := to_integer(signed(packet_vet(p,1))) ;
		  -- send payload
		  for f in 2 to num_flits+1 loop
		      SendFlit(clock,packet_vet(p,f),dataL_i,rxL_i,creditL_o);
		  end loop;
		-- end of the packet transfer
          wait until rising_edge(clock);
          wait for 4 ns;
          rxL_i <= '0';
          dataL_i <= (others => '0');
          -- wait a while to start the next packet transfer 
          wait for 500 ns;
		end loop;
		
		-- blobk here. do not send it again
		wait;
	end process;

 router: entity work.Router_Board
  port map ( 
	  clock     => clock    ,
	  reset     => reset    ,
	  dip_i     => dip_i    ,
	  send_i    => send_i   ,
	  end_i     => end_i    ,
	  led_o     => led_o    ,
	  -- slave
	  rxL_i     => rxL_i    ,
	  dataL_i   => dataL_i  ,
	  creditL_o => creditL_o,
	  -- master
	  txL_o     => txL_o    ,
	  dataL_o   => dataL_o  ,
	  creditL_i => creditL_i
  );	
	
	
end tb;

