----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.12.2020 12:32:18
-- Design Name: 
-- Module Name: FILTRE - Behavioral
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

entity FILTRE is
    Port ( hz10_en : in STD_LOGIC;
           clk : in STD_LOGIC;
           bp : in STD_LOGIC;
           bpfiltre : out STD_LOGIC);
end FILTRE;

architecture Behavioral of FILTRE is
    
signal bp_precedent : STD_LOGIC;
    
begin
    Filtre : process (clk,hz10_en)
    begin
        if (clk'event and clk = '1' and hz10_en = '1') then     
            if (bp = '1' and bp_precedent = '1') then           -- Lors d'un front montant d'horloge nous comparons la valeur actuel et la valeur pr�c�dente du bouton (toute les 100 ms)
                bpfiltre <= '1';
            end if;
            if (bp = '1') then                      -- Nous associons la valeur actuelle du bouton � la valeur pr�c�dente
                bp_precedent <= '1';
            end if;
            if (bp = '0') then
                bp_precedent <= '0';
                bpfiltre <= '0';
            end if;
        end if;
    end process;
end Behavioral;
