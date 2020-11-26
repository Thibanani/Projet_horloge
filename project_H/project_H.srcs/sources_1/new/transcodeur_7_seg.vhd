----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.11.2020 15:17:21
-- Design Name: 
-- Module Name: transcodeur_7_seg - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transcodeur_7_seg is
    Port ( sw_in : in STD_LOGIC_VECTOR (3 downto 0);
           n_a : out STD_LOGIC;
           n_b : out STD_LOGIC;
           n_c : out STD_LOGIC;
           n_d : out STD_LOGIC;
           n_e : out STD_LOGIC;
           n_f : out STD_LOGIC;
           n_g : out STD_LOGIC;
           n_dp : out STD_LOGIC;
           n_commun : out STD_LOGIC_VECTOR (3 downto 0));
end transcodeur_7_seg;

architecture Behavioral of transcodeur_7_seg is

begin


end Behavioral;
