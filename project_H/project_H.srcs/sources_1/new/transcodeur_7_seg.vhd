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
           n_seg : out STD_LOGIC_VECTOR (6 downto 0);
           n_commun : out STD_LOGIC_VECTOR (3 downto 0));
end transcodeur_7_seg;

architecture Behavioral of transcodeur_7_seg is  

signal seg : STD_LOGIC_VECTOR (6 downto 0);
signal commun : STD_LOGIC_VECTOR (3 downto 0);

begin

process (sw_in)
begin
    commun <= "1111";
    case (sw_in) is
        when "0000" =>
            seg <= "0111111";
        when "0001" => 
            seg <= "0000110";
        when "0010" =>
            seg <= "1011011";
        when "0011" =>
            seg <= "1001111";
        when "0100" =>
            seg <= "1100110";
        when "0101" =>
            seg <= "1101101";
        when "0110" =>
            seg <= "1111100";
        when "0111" =>
            seg <= "0000111";
        when "1000" =>
            seg <= "1111111";
        when "1001" =>
            seg <= "1101111";
        when others =>
            seg <= "1111001";      
    end case;
    n_seg <= not(seg);
    n_commun <= not(commun); 
end process;

end Behavioral;
