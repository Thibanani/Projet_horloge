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
    Port ( sw_faster : in STD_LOGIC_VECTOR (1 downto 0);
           sw_aff : in STD_LOGIC;
           bp_droit : in STD_LOGIC;
           bp_gauche : in STD_LOGIC;
           bp_bas : in STD_LOGIC;
           bp_haut : in STD_LOGIC;
           clk : in STD_LOGIC; 
           clkhz : out STD_LOGIC;
           n_seg : out STD_LOGIC_VECTOR (6 downto 0);
           n_commun : out STD_LOGIC_VECTOR (3 downto 0));
end transcodeur_7_seg;

architecture Behavioral of transcodeur_7_seg is  

signal seg : STD_LOGIC_VECTOR (6 downto 0);
signal commun : STD_LOGIC_VECTOR (3 downto 0);
signal nombre : UNSIGNED (3 downto 0);
signal comp_hz : UNSIGNED (26 downto 0);
signal comp_en : UNSIGNED (11 downto 0);
signal digitactif : UNSIGNED (1 downto 0);
signal hz3600 : STD_LOGIC;
signal hz1 : STD_LOGIC;
signal hz1_en : STD_LOGIC;
signal hz2_en : STD_LOGIC;
signal hz4_en : STD_LOGIC;
signal hz10_en : STD_LOGIC;
signal hz60_en : STD_LOGIC;
signal hz200_en : STD_LOGIC;
signal hz400_en : STD_LOGIC;
signal hz600_en : STD_LOGIC;
signal enable : STD_LOGIC;
signal dh : UNSIGNED (3 downto 0);
signal uh : UNSIGNED (3 downto 0);
signal dm : UNSIGNED (3 downto 0);
signal um : UNSIGNED (3 downto 0);
signal ds : UNSIGNED (3 downto 0);
signal us : UNSIGNED (3 downto 0);

begin

    Horloge : process (hz3600)
    begin
        if (hz3600'event and hz3600 = '1') then
            if (bp_droit = '1' or bp_haut = '1') then   --incrémentation
                if (bp_droit = '1') then
                    enable <= hz4_en;
                elsif (bp_haut = '1') then
                    enable <= hz60_en;
                end if;
                if (enable = '1') then
                        us <= (others => '0');
                        ds <= (others => '0');
                        if (um >= 9) then
                            um <= (others => '0');
                            if (dm >= 5 and um >= 9) then
                                dm <= (others => '0');
                                if (uh >= 9) then
                                    uh <= (others => '0');     
                                    dh <= dh + 1;
                                elsif (dh >= 2 and uh >= 3) then
                                    dh <= (others => '0');
                                    uh <= (others => '0');
                                else
                                    uh <= uh + 1;
                                end if;
                            else
                                dm <= dm + 1;
                            end if;
                        else
                            um <= um + 1;
                        end if;
                    end if;
            elsif (bp_gauche = '1' or bp_bas = '1') then    --décrémentation
                if (bp_gauche = '1') then
                    enable <= hz4_en;
                elsif (bp_bas = '1') then
                    enable <= hz60_en;
                end if;
                if (enable = '1') then
                    us <= (others => '0');
                    ds <= (others => '0');
                    if (um <= 0) then
                        um <= "1001";
                        if (dm <= 0 and um <= 0) then
                            dm <= "0101";
                            if (uh <= 0) then
                                uh <= "1001";
                                if (dh <= 0) then    
                                    dh <= "0010";
                                    uh <= "0011";
                                else
                                    dh <= dh - 1;
                                end if;
                            else
                                uh <= uh - 1;
                            end if;
                        else
                            dm <= dm - 1;
                        end if;
                    else
                        um <= um - 1;
                    end if;
                end if;
            else
                case (sw_faster)is                  -- normal
                    when "00" =>
                        enable <= hz1_en;
                    when "01" =>
                        enable <= hz10_en;
                    when "10" =>
                        enable <= hz200_en;
                    when "11" =>
                        enable <= '1';
                end case;
                if (enable = '1')then
                    if (us >= 9) then
                        us <= (others => '0');
                        if (ds >= 5 and us >= 9) then
                            ds <= (others => '0');
                            if (um >= 9) then
                                um <= (others => '0');
                                if (dm >= 5 and um >= 9) then
                                    dm <= (others => '0');
                                    if (uh >= 9) then
                                        uh <= (others => '0');     
                                        dh <= dh + 1;
                                    elsif (dh >= 2 and uh >= 3) then
                                        dh <= (others => '0');
                                        uh <= (others => '0');
                                    else
                                        uh <= uh + 1;
                                    end if;
                                else
                                    dm <= dm + 1;
                                end if;
                            else
                                um <= um + 1;
                            end if;
                        else
                            ds <= ds + 1;
                        end if;
                    else 
                        us <= us + 1;
                    end if;
                end if;
            end if;
        end if;
    end process Horloge;

    Compteur_affichage : process (hz3600)
    begin
        if (hz3600'event and hz3600 = '1' and hz400_en = '1') then
            if (digitactif >= 3) then
                digitactif <= (others => '0');
            else 
                digitactif <= digitactif + 1;
            end if;
        end if;
    end process Compteur_affichage;

    choix_allumage : process (digitactif) -- Allumage digits
    begin
        case (digitactif) is -- Choix du segment a afficher
            when "00" =>
                commun <= "1000";   -- segment le plus a gauche
            when "01" =>
                commun <= "0100";
            when "10" =>
                commun <= "0010";
            when "11" =>
                commun <= "0001";   -- segment le plus a droite
         end case;
    end process choix_allumage;

    affichage :process (digitactif,sw_aff) -- Multiplexage
    begin
        if (sw_aff = '0') then
            case (digitactif) is    
                when "00" =>
                    nombre <= dm;
                when "01" =>
                    nombre <= um;
                when "10" =>
                    nombre <= ds;
                when "11" =>
                    nombre <= us;
            end case;
        end if;
        if (sw_aff = '1') then
            case (digitactif) is    
                when "00" =>
                    if (dh = 0)then
                        nombre <= "1111";
                    else
                        nombre <= dh;
                    end if;
                when "01" =>
                    nombre <= uh;
                when "10" =>
                    nombre <= dm;
                when "11" =>
                    nombre <= um;
            end case; 
        end if;
    end process affichage;
    
    clock : process (clk)   -- création de la clock en 3600hz à partir de 100MHz
    begin
        if (clk'event and clk = '1') then
            if (comp_hz >= 13889) then  -- Utilisation d'un compteur pour "diviser" la clock
                comp_hz <= (others => '0');
                hz3600 <= not(hz3600);  -- création d'une clock 
            else
                comp_hz <= comp_hz + 1; -- incrémentation du compteur
            end if;
        end if;
    end process clock;

    differente_horloge : process (hz3600)   -- création des différents signaux enables permettant d'avoir duifférentes clock
    begin
        if (hz3600'event and hz3600 = '1') then -- Mise en place d'un compteur de 3600
            if (comp_en > 3598) then        
                comp_en <= (others => '0');
            else
                comp_en <= comp_en + 1;
            end if;
            if (to_integer(comp_en)mod 3600 = 0) then   -- Utilisation du modulo pour obtenir la clock désirer (1hz)
                hz1_en <= '1';
            else
                hz1_en <= '0';
            end if;
            if (to_integer(comp_en)mod 1800 = 0) then   -- Utilisation du modulo pour obtenir la clock désirer (2hz)
                hz2_en <= '1';
            else
                hz2_en <= '0';
            end if;
            if (to_integer(comp_en)mod 900 = 0) then   -- Utilisation du modulo pour obtenir la clock désirer (4hz)
                hz4_en <= '1';
            else
                hz4_en <= '0';
            end if;
            if (to_integer(comp_en)mod 360 = 0) then   -- Utilisation du modulo pour obtenir la clock désirer (10hz)
                hz10_en <= '1';
            else
                hz10_en <= '0';
            end if;
            if (to_integer(comp_en)mod 60 = 0) then   -- Utilisation du modulo pour obtenir la clock désirer (60hz)
                hz60_en <= '1';
            else
                hz60_en <= '0';
            end if;
            if (to_integer(comp_en)mod 18 = 0) then   -- Utilisation du modulo pour obtenir la clock désirer (200hz)
                hz200_en <= '1';
            else
                hz200_en <= '0';
            end if;
            if (to_integer(comp_en)mod 9 = 0) then   -- Utilisation du modulo pour obtenir la clock désirer (400hz)
                hz400_en <= '1';
            else
                hz400_en <= '0';
            end if;
            if (to_integer(comp_en)mod 6 = 0) then   -- Utilisation du modulo pour obtenir la clock désirer (600hz)
                hz600_en <= '1';
            else
                hz600_en <= '0';
            end if;
        end if;
    end process differente_horloge;
    
    test : process (hz3600)
    begin
            if (hz3600'event and hz3600 = '1' and hz1_en = '1') then
                hz1 <= not(hz1);
            end if;
    end process test;

    affichage_nombre : process (nombre) -- 7segments
    begin
        case (nombre) is    --Paramétrage des 7 segments pour afficher le nombre désiré
            when "0000" =>
                seg <= "0111111";   -- affichage de 0
            when "0001" => 
                seg <= "0000110";   -- affichage de 1
            when "0010" =>
                seg <= "1011011";   -- affichage de 2
            when "0011" =>
                seg <= "1001111";   -- affichage de 3
            when "0100" =>
                seg <= "1100110";   -- affichage de 4
            when "0101" =>
                seg <= "1101101";   -- affichage de 5
            when "0110" =>
                seg <= "1111101";   -- affichage de 6
            when "0111" =>
                seg <= "0000111";   -- affichage de 7
            when "1000" =>
                seg <= "1111111";   -- affichage de 8
            when "1001" =>
                seg <= "1101111";   -- affichage de 9
            when "1111" =>
                seg <= "0000000";   -- affichage nul
            when others =>
                seg <= "1111001";    -- affichage de E lorsque le chiffre demandé est supérieur a 9     
        end case; 
    end process affichage_nombre;
    
n_seg <= not(seg);
n_commun <= not(commun);
clkhz <= hz1;

end Behavioral;
