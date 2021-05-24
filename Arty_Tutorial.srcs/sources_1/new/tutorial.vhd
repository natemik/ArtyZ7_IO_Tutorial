----------------------------------------------------------------------------------
-- Engineer: Nathan Mikhail
-- 
-- Create Date: 05/18/2021 04:18:43 PM
-- Design Name: Tutorial
-- Module Name: tutorial - Behavioral
-- Project Name: 
-- Target Devices: Arty Z7 7020 Board
-- Tool Versions: 
-- Description: Tutorial for Arty Z7 7020 Board
-- 
-- Dependencies: 
-- 
-- Revision:
--      0.01 - File Created
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tutorial is
  Port ( 
    clk : IN    std_logic;
  
    btn0 : IN   std_logic;
    btn1 : IN   std_logic;
    btn2 : IN   std_logic;
    btn3 : IN   std_logic;
    
    led0 : OUT  std_logic;
    led1 : OUT  std_logic;
    led2 : OUT  std_logic;
    led3 : OUT  std_logic;
    
    sw0 : IN std_logic;
    sw1 : IN std_logic;
    
    led0_RGB : OUT std_logic_vector(2 downto 0) := "000";
    led1_RGB : OUT std_logic_vector(2 downto 0) := "000"
  );
end tutorial;

architecture Behavioral of tutorial is

-- Frequency = 1/8ns = 125MHz
CONSTANT clk_period : integer := 125000000;


begin

-- Defining led0 behaviour using "if" conditional statements
btn0_proc : process (btn0) -- When the value of btn0 changes...
begin
    if (btn0 = '1') then -- If the button is pressed
        led0 <= '1'; -- Turn the LED ON
    else
        led0 <= '0'; -- Otherwise turn the LED OFF
    end if;
end process;

-- Defining led1 behaviour using "if" conditional statements
btn1_proc : process (btn1) -- When the value of btn1 changes...
begin
    if (btn1 = '1') then
        led1 <= '1';
    else
        led1 <= '0';
    end if;
end process;

-- Defining led2 behaviour using conditional signal assignment
btn2_proc : process (btn2) -- When the value of btn2 changes...
begin
    -- Turn the LED ON when the button is pressed, otherwise turn the LED OFF
    led2 <= '1' when btn2 = '1' else '0';
end process;

-- Defining led3 behaviour using conditional signal assignment
btn3_proc : process (btn3) -- When the value of btn3 changes...
begin
    led3 <= '1' when btn3 = '1' else '0';
end process;

-- Process to control RGB LED 0
led0_RBG_green_proc : process
variable red_counter : integer := 0;
variable green_counter : integer := 0;
variable blue_counter : integer := 0;
begin
    -- Evaluate on rising edge of 8 ns clock
    if rising_edge(clk) then
        -- If the switch is in the ON position, allow the bits to be evaluated
        if sw0 = '1' then 
            -- Update RED once a clock cycle
            if red_counter = clk_period-1 then
                led0_RGB(2) <= NOT led0_RGB(2);
                red_counter := 0;
            else
                red_counter := red_counter + 1;
            end if;
            
            -- Toggle GREEN once every 2 clock cycles 
            if green_counter = (2*clk_period)-1 then
                led0_RGB(1) <= NOT led0_RGB(1);
                green_counter := 0;
            else
                green_counter := green_counter + 1;
            end if;
            
            -- Toggle BLUE once every 4 clock cycles
            if blue_counter = (4*clk_period)-1 then
                led0_RGB(0) <= NOT led0_RGB(0);
                blue_counter := 0;
            else
                blue_counter := blue_counter + 1;
            end if;   
        else
            -- If switch if OFF, turn RGB LED OFF
            led0_RGB <= "000";
        end if; 
    end if;
end process;

-- Process to control RGB LED 1
led1_RBG_green_proc : process
variable red_counter : integer := 0;
variable green_counter : integer := 0;
variable blue_counter : integer := 0;
begin
    if rising_edge(clk) then
        -- If the switch is in the ON position, allow the bits to be evaluated
        if sw1 = '1' then
            -- Update RED once a clock cycle
            if red_counter = clk_period-1 then
                led1_RGB(2) <= NOT led1_RGB(2);
                red_counter := 0;
            else
                red_counter := red_counter + 1;
            end if;
            
            -- Toggle GREEN once every 2 clock cycles
            if green_counter = (2*clk_period)-1 then
                led1_RGB(1) <= NOT led1_RGB(1);
                green_counter := 0;
            else
                green_counter := green_counter + 1;
            end if;
            
            -- Toggle BLUE once every 4 clock cycles
            if blue_counter = (4*clk_period)-1 then
                led1_RGB(0) <= NOT led1_RGB(0);
                blue_counter := 0;
            else
                blue_counter := blue_counter + 1;
            end if;   
        else
            -- If switch if OFF, turn RGB LED OFF
            led1_RGB <= "000";
        end if; 
    end if;
end process;

end Behavioral;
