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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transcodeur_7_seg is
    Port ( sw_aff : in STD_LOGIC_VECTOR (1 downto 0);
           clk : in STD_LOGIC; 
           clkhz : out STD_LOGIC;
           n_seg : out STD_LOGIC_VECTOR (6 downto 0);
           n_commun : out STD_LOGIC_VECTOR (3 downto 0));
end transcodeur_7_seg;

architecture Behavioral of transcodeur_7_seg is  

signal seg : STD_LOGIC_VECTOR (6 downto 0);
signal commun : STD_LOGIC_VECTOR (3 downto 0);
signal nombre : STD_LOGIC_VECTOR (3 downto 0);
signal comp_hz : UNSIGNED (26 downto 0);
signal hz3600 : STD_LOGIC;
signal hz1_en : STD_LOGIC;
signal hz2_en : STD_LOGIC;
signal hz4_en : STD_LOGIC;
signal hz10_en : STD_LOGIC;
signal hz60_en : STD_LOGIC;
signal hz200_en : STD_LOGIC;
signal hz400_en : STD_LOGIC;
signal hz600_en : STD_LOGIC;

begin

    process (sw_aff) -- Allumage digits
    begin
        case (sw_aff) is
            when "00" =>
                commun <= "1000";
            when "01" =>
                commun <= "0100";
            when "10" =>
                commun <= "0010";
            when "11" =>
                commun <= "0001";
         end case;
    end process;

    process (sw_aff) -- Multiplexage
    begin
        case (sw_aff) is
            when "00" =>
                nombre <= "0001";
            when "01" =>
                nombre <= "0010";
            when "10" =>
                nombre <= "0011";
            when "11" =>
                nombre <= "0100";
        end case;
    end process;
    
    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (comp_hz >= 27777) then
                comp_hz <= (others => '0');
                hz3600 <= not(hz3600);
            else
                comp_hz <= comp_hz + 1;
            end if;
        end if;
    end process;

    process (nombre) -- 7segments
    begin
        case (nombre) is
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
    end process;
    
n_seg <= not(seg);
n_commun <= not(commun);
clkhz <= hz3600;

end Behavioral;
