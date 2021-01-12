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
    Port ( sw_faster : in STD_LOGIC_VECTOR (1 downto 0);                -- Switch accélérant l'incrémentation de l'horloge
           sw_aff : in STD_LOGIC;                                       -- Switch modifiant l'affichage de l'horloge
           sw_cumul : in STD_LOGIC;                                     -- Switch permettant l'affichage du cumul des secondes
           sw_animation : in STD_LOGIC;                                 -- Switch permettant d'activer ou non l'animation des secondes
           bp_droit : in STD_LOGIC;                                     -- Switch permettant l'incrémentation des minutes au rythme de 4 Hz
           bp_gauche : in STD_LOGIC;                                    -- Switch permettant la décrémentation des minutes au rythme de 4 Hz
           bp_bas : in STD_LOGIC;                                       -- Switch permettant la décrémentation des minutes au rythme de 60 Hz
           bp_haut : in STD_LOGIC;                                      -- Switch permettant l'incrémentation des minutes au rythme de 60 Hz
           clk : in STD_LOGIC;                                          -- Horloge du système a 100 MHz
           secondes : out STD_LOGIC_VECTOR (9 downto 0);                -- Signal permettant l'affichage des secondes
           n_pointdecimal : out STD_LOGIC;                              -- Signal permettant le clignotement du point décimal en logique négative
           n_seg : out STD_LOGIC_VECTOR (6 downto 0);                   -- Signal permettant le contrôle des 7 segments en logique négative
           n_commun : out STD_LOGIC_VECTOR (3 downto 0);                -- Signal contrôlant l'allumage des 7 segments
           n_bargraphcommun : out STD_LOGIC_VECTOR (5 downto 0));       -- Signal contrôlant l'allumage des 6 bargraphs de 10 leds des secondes
end transcodeur_7_seg;

architecture Behavioral of transcodeur_7_seg is  

signal seg : STD_LOGIC_VECTOR (6 downto 0);                             -- Signal permettant de comtrôler les segments d'un 7 segments
signal commun : STD_LOGIC_VECTOR (3 downto 0);                          -- Signal contrôlant l'allumage des 7 segments
signal nombre : UNSIGNED (3 downto 0);                                  -- Variable permttant de savoir le nombre a afficher sur le 7 segment
signal comp_hz : UNSIGNED (26 downto 0);                                -- Variable du compteur pour la clock 3600 Hz
signal comp_en : UNSIGNED (11 downto 0);                                -- Variable du compteur des signaux enables
signal digitactif : UNSIGNED (1 downto 0);                              -- Variable permettant de savoir quel afficheur 7 segments nous utilisons
signal bargraphactif : UNSIGNED (2 downto 0);                           -- Variable permettant de savoir quel bargraph nous utilisons
signal bargraphcommun : STD_LOGIC_VECTOR (5 downto 0);                  -- Signal permettant l'allumage des 6 bargraphs
signal hz3600 : STD_LOGIC;                                              -- Signal de la clock a 3600 Hz 
signal pointdecimal : STD_LOGIC;                                        -- Signal pour faire clignoter le point décimal
signal inter_pointdecimal : STD_LOGIC;                                  -- Signal intermédiaire du point décimal
signal hz1_en : STD_LOGIC;                                              -- Signal enable pour obtenir une clock a 1 Hz
signal hz2_en : STD_LOGIC;                                              -- Signal enable pour obtenir une clock a 2 Hz
signal hz4_en : STD_LOGIC;                                              -- Signal enable pour obtenir une clock a 4 Hz
signal hz10_en : STD_LOGIC;                                             -- Signal enable pour obtenir une clock a 10 Hz
signal hz60_en : STD_LOGIC;                                             -- Signal enable pour obtenir une clock a 60 Hz
signal hz200_en : STD_LOGIC;                                            -- Signal enable pour obtenir une clock a 200 Hz
signal hz400_en : STD_LOGIC;                                            -- Signal enable pour obtenir une clock a 400 Hz
signal hz600_en : STD_LOGIC;                                            -- Signal enable pour obtenir une clock a 600 Hz
signal enable : STD_LOGIC;                                              -- Signal intermédiaire pour connaitre la vitesse de la clock actuelle
signal dh : UNSIGNED (3 downto 0);                                      -- Variable des dizaines des heures
signal uh : UNSIGNED (3 downto 0);                                      -- Variable des unités des heures
signal dm : UNSIGNED (3 downto 0);                                      -- Variable des dizaines des minutes
signal um : UNSIGNED (3 downto 0);                                      -- Variable des unités des minutes
signal ds : UNSIGNED (3 downto 0);                                      -- Variable des dizaines des secondes
signal us : UNSIGNED (3 downto 0);                                      -- Variable des unités des secondes
signal bp_droitfiltre : STD_LOGIC;                                      -- Signal intermédiaire du bouton droit après filtrage
signal bp_gauchefiltre : STD_LOGIC;                                     -- Signal intermédiaire du bouton gauche après filtrage
signal bp_basfiltre : STD_LOGIC;                                        -- Signal intermédiaire du bouton bas après filtrage
signal bp_hautfiltre : STD_LOGIC;                                       -- Signal intermédiaire du bouton haut après filtrage
signal danime : UNSIGNED (3 downto 0);                                  -- Variable des dizaines pour les leds d'animation
signal uanime : UNSIGNED (3 downto 0);                                  -- Variable des unités pour les leds d'animation
signal tempo : UNSIGNED (11 downto 0);                                  -- Variable donnant le temps d'affichage de chaque led pour l'animation
signal compteur : UNSIGNED (11 downto 0);                               -- Variable intermédiaire pour l'animation
component Filtre
    port (hz10_en,clk,bp : in STD_LOGIC; bpfiltre : out STD_LOGIC);     -- Permet d'utiliser le fichier source filtre dans le code principale
end component;    

begin

    E0 : FILTRE port map(hz10_en, clk, bp_droit, bp_droitfiltre);       -- Filtrage du bouton droit
    E1 : FILTRE port map(hz10_en, clk, bp_gauche, bp_gauchefiltre);     -- Filtrage du bouton gauche
    E2 : FILTRE port map(hz10_en, clk, bp_bas, bp_basfiltre);           -- Filtrage du bouton bas
    E3 : FILTRE port map(hz10_en, clk, bp_haut, bp_hautfiltre);         -- Filtrage du bouton haut

    Horloge : process (hz3600)                  -- Process permettant le fonctionnement de l'Horloge en fonction des différentes fréquences de clock
    begin
        if (hz3600'event and hz3600 = '1') then                     -- Lors d'un front montant de clock 
            if (bp_droitfiltre = '1' or bp_hautfiltre = '1') then   -- Changement du signal enable en fonction de la fréquence de la clock voulu
                if (bp_droitfiltre = '1') then
                    enable <= hz4_en;
                elsif (bp_hautfiltre = '1') then
                    enable <= hz60_en;
                end if;
                if (enable = '1') then                  -- Incrémentation de l'Horloge en fonction de la fréquence choisie (minutes, heures)
                        us <= (others => '0');          -- Mise a 0 des secondes
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
            elsif (bp_gauchefiltre = '1' or bp_basfiltre = '1') then    -- Changement du signal enable en fonction de la fréquence de la clock voulu
                if (bp_gauchefiltre = '1') then
                    enable <= hz4_en;
                elsif (bp_basfiltre = '1') then
                    enable <= hz60_en;
                end if;
                if (enable = '1') then                                  -- Décrémentation de l'Horloge en fonction de la fréquence choisie (minutes, heures)
                    us <= (others => '0');                              -- Mise a 0 des secondes
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
                case (sw_faster)is                  -- Changement de la fréquence de la clock en fonction de la valeur du switch
                    when "00" =>
                        enable <= hz1_en;
                    when "01" =>
                        enable <= hz10_en;
                    when "10" =>
                        enable <= hz200_en;
                    when "11" =>
                        enable <= '1';
                end case;
                if (enable = '1')then               -- Incrémentation de l'Horloge en fonction de la fréquence choisie par le switch (secondes, minutes, heures)
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

    Compteur_affichage : process (hz3600)   -- Process permettant de changer le digit à allumé
    begin
        if (hz3600'event and hz3600 = '1' and hz400_en = '1') then      -- Lors d'un front montant de clock et du signal enable a 400 Hz nous incrémentons digitactif pour change le digit à allumé 
            if (digitactif >= 3) then
                digitactif <= (others => '0');                          -- Remise a 0 lorsque nous arrivons à 3
            else 
                digitactif <= digitactif + 1;
            end if;
        end if;
    end process Compteur_affichage;
    
    Compteur_Bargraph : process (hz3600)    -- Process permettant de changer le bargraph à alummé
    begin
        if (hz3600'event and hz3600 = '1' and hz600_en = '1') then  -- Lors d'un front montant de clock et du signal enable a 600 Hz nous incrémentons bargraphactif pour changer le bargraph à allumé
            if (bargraphactif >= 5) then
                bargraphactif <= (others => '0');                   -- Remise a 0 lorsque nous arrivons à 5
            else
                bargraphactif <= bargraphactif + 1;
            end if;
        end if;
    end process Compteur_Bargraph;
    
    Allumage_Bargraph : process (bargraphactif) -- Process permettant d'allumé le bargraph en fonction de la valeur de bargraphactif
    begin
        case (bargraphactif) is     -- Choix du bargraph à allumer
            when "000" =>
                bargraphcommun <= "100000";
            when "001" =>
                bargraphcommun <= "010000";
            when "010" =>
                bargraphcommun <= "001000";
            when "011" =>
                bargraphcommun <= "000100";
            when "100" =>
                bargraphcommun <= "000010";
            when "101" =>
                bargraphcommun <= "000001";
            when others =>
                bargraphcommun <= "000000";
        end case;
    end process Allumage_Bargraph;
    
--    Animation : process (hz3600)              -- Process permettant l'affichage de l'animation 
--    begin
--        if (sw_animation = '1') then          -- Contrôle de l'animation par un switch
--            tempo <= (others => '0');
--            if (ds = 0) then
--                if (us = 0) then
--                    tempo <= tempo + 60;      -- Calcul du temps d'affichage d'une led en fonction du nombre de seconde actuel
--                elsif (us = 1) then
--                    tempo <= tempo + 61;
--                elsif (us = 2) then
--                    tempo <= tempo + 62;
--                elsif (us = 3) then
--                    tempo <= tempo + 63;
--                elsif (us = 4) then
--                    tempo <= tempo + 64;
--                elsif (us = 5) then
--                    tempo <= tempo + 65;
--                elsif (us = 6) then
--                    tempo <= tempo + 67;
--                elsif (us = 7) then
--                    tempo <= tempo + 68;
--                elsif (us = 8) then
--                    tempo <= tempo + 69;
--                elsif (us = 9) then
--                    tempo <= tempo + 70;
--                end if;
--            end if;
--            if (ds = 1) then
--                if (us = 0) then
--                    tempo <= tempo + 72;
--                elsif (us = 1) then
--                    tempo <= tempo + 73;
--                elsif (us = 2) then
--                    tempo <= tempo + 75;
--                elsif (us = 3) then
--                    tempo <= tempo + 77;
--                elsif (us = 4) then
--                    tempo <= tempo + 78;
--                elsif (us = 5) then
--                    tempo <= tempo + 80;
--                elsif (us = 6) then
--                    tempo <= tempo + 82;
--                elsif (us = 7) then
--                    tempo <= tempo + 84;
--                elsif (us = 8) then
--                    tempo <= tempo + 86;
--                elsif (us = 9) then
--                    tempo <= tempo + 88;
--                end if;
--            end if;
--            if (ds = 2) then
--                if (us = 0) then
--                    tempo <= tempo + 90;
--                elsif (us = 1) then
--                    tempo <= tempo + 92;
--                elsif (us = 2) then
--                    tempo <= tempo + 95;
--                elsif (us = 3) then
--                    tempo <= tempo + 97;
--                elsif (us = 4) then
--                    tempo <= tempo + 100;
--                elsif (us = 5) then
--                    tempo <= tempo + 102;
--                elsif (us = 6) then
--                    tempo <= tempo + 105;
--                elsif (us = 7) then
--                    tempo <= tempo + 109;
--                elsif (us = 8) then
--                    tempo <= tempo + 112;
--                elsif (us = 9) then
--                    tempo <= tempo + 116;
--                end if;
--            end if;
--            if (ds = 3) then
--                if (us = 0) then
--                    tempo <= tempo + 120;
--                elsif (us = 1) then
--                    tempo <= tempo + 124;
--                elsif (us = 2) then
--                    tempo <= tempo + 128;
--                elsif (us = 3) then
--                    tempo <= tempo + 133;
--                elsif (us = 4) then
--                    tempo <= tempo + 138;
--                elsif (us = 5) then
--                    tempo <= tempo + 144;
--                elsif (us = 6) then
--                    tempo <= tempo + 150;
--                elsif (us = 7) then
--                    tempo <= tempo + 156;
--                elsif (us = 8) then
--                    tempo <= tempo + 164;
--                elsif (us = 9) then
--                    tempo <= tempo + 171;
--                end if;
--            end if;
--            if (ds = 4) then
--                if (us = 0) then
--                    tempo <= tempo + 180;
--                elsif (us = 1) then
--                    tempo <= tempo + 189;
--                elsif (us = 2) then
--                    tempo <= tempo + 200;
--                elsif (us = 3) then
--                    tempo <= tempo + 212;
--                elsif (us = 4) then
--                    tempo <= tempo + 225;
--                elsif (us = 5) then
--                    tempo <= tempo + 240;
--                elsif (us = 6) then
--                    tempo <= tempo + 257;
--                elsif (us = 7) then
--                    tempo <= tempo + 277;
--                elsif (us = 8) then
--                    tempo <= tempo + 300;
--                elsif (us = 9) then
--                    tempo <= tempo + 327;
--                end if;
--            end if;
--            if (ds = 5) then
--                if (us = 0) then
--                    tempo <= tempo + 360;
--                elsif (us = 1) then
--                    tempo <= tempo + 400;
--                elsif (us = 2) then
--                    tempo <= tempo + 450;
--                elsif (us = 3) then
--                    tempo <= tempo + 514;
--                elsif (us = 4) then
--                    tempo <= tempo + 600;
--                elsif (us = 5) then
--                    tempo <= tempo + 720;
--                elsif (us = 6) then
--                    tempo <= tempo + 900;
--                elsif (us = 7) then
--                    tempo <= tempo + 1200;
--                elsif (us = 8) then
--                    tempo <= tempo + 1800;
--                elsif (us = 9) then
--                    tempo <= tempo + 3600;
--                end if;
--            end if;
--            if (hz3600'event and hz3600 = '1') then       -- Lors d'un front montant d'horloge nous incrémentons le compteur
--                if (compteur >= tempo) then
--                    compteur <= (others => '0');
--                    if (uanime >= 9) then                 -- Nous incrémentons les unité d'animation et les dizaines des animations en fonction de l'avance de l'heure actuel
--                        uanime <= (others => '0');
--                        if (danime >= (5-ds) and uanime >= (9-us)) then
--                            danime <= (others => '0');
--                            end if;
--                        else
--                            danime <= danime + 1;
--                        end if;
--                    else 
--                        uanime <= uanime + 1;
--                    end if;
--                else
--                    compteur <= compteur + 1;
--                end if;
--            end if; 
--        end if;
--    end process Animation;
    
    Gestion_secondes : process (bargraphactif,sw_cumul,us,ds)                 -- Process permettant la gestion des secondes sur les bargraphs
    begin
        if (sw_cumul = '1') then                        -- Condition permettant d'activer le cumul des secondes en fonction du switch cumul
            case (bargraphactif) is
            when "000" =>
                if (ds = 0) then
                    case (us) is                        -- Pilotage des bargraphs avec la valeur des secondes et des dizaines de secondes dans le sens inverse car le câblage est différents suivant les bargraphs
                        when "0000" =>
                            secondes <= "0000000001";
                        when "0001" =>
                            secondes <= "0000000011";
                        when "0010" =>
                            secondes <= "0000000111";
                        when "0011" =>
                            secondes <= "0000001111";
                        when "0100" =>
                            secondes <= "0000011111";
                        when "0101" =>
                            secondes <= "0000111111";
                        when "0110" =>
                            secondes <= "0001111111";
                        when "0111" =>
                            secondes <= "0011111111";
                        when "1000" =>
                            secondes <= "0111111111";
                        when "1001" =>
                            secondes <= "1111111111";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                else
                    secondes <= "1111111111";
                end if;
            when "001" =>
                if (ds = 1) then
                    case (us) is                            -- Pilotage des bargraph avec la valeur des secondes et des dizaines de secondes 
                        when "0000" =>
                            secondes <= "1000000000";
                        when "0001" =>
                            secondes <= "1100000000";
                        when "0010" =>
                            secondes <= "1110000000";
                        when "0011" =>
                            secondes <= "1111000000";
                        when "0100" =>
                            secondes <= "1111100000";
                        when "0101" =>
                            secondes <= "1111110000";
                        when "0110" =>
                            secondes <= "1111111000";
                        when "0111" =>
                            secondes <= "1111111100";
                        when "1000" =>
                            secondes <= "1111111110";
                        when "1001" =>
                            secondes <= "1111111111";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                elsif (ds > 1) then
                    secondes <= "1111111111";
                else
                    secondes <= "0000000000";
                end if;
            when "010" =>
                if (ds = 2) then
                    case (us) is
                        when "0000" =>
                            secondes <= "0000000001";
                        when "0001" =>
                            secondes <= "0000000011";
                        when "0010" =>
                            secondes <= "0000000111";
                        when "0011" =>
                            secondes <= "0000001111";
                        when "0100" =>
                            secondes <= "0000011111";
                        when "0101" =>
                            secondes <= "0000111111";
                        when "0110" =>
                            secondes <= "0001111111";
                        when "0111" =>
                            secondes <= "0011111111";
                        when "1000" =>
                            secondes <= "0111111111";
                        when "1001" =>
                            secondes <= "1111111111";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                elsif (ds > 2) then
                    secondes <= "1111111111";
                else
                    secondes <= "0000000000";
                end if;
            when "011" =>
                if (ds = 3) then
                    case (us) is
                        when "0000" =>
                            secondes <= "0000000001";
                        when "0001" =>
                            secondes <= "0000000011";
                        when "0010" =>
                            secondes <= "0000000111";
                        when "0011" =>
                            secondes <= "0000001111";
                        when "0100" =>
                            secondes <= "0000011111";
                        when "0101" =>
                            secondes <= "0000111111";
                        when "0110" =>
                            secondes <= "0001111111";
                        when "0111" =>
                            secondes <= "0011111111";
                        when "1000" =>
                            secondes <= "0111111111";
                        when "1001" =>
                            secondes <= "1111111111";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                elsif (ds > 3) then
                    secondes <= "1111111111";
                else
                    secondes <= "0000000000";
                end if;
            when "100" =>
                if (ds = 4) then
                    case (us) is
                        when "0000" =>
                            secondes <= "1000000000";
                        when "0001" =>
                            secondes <= "1100000000";
                        when "0010" =>
                            secondes <= "1110000000";
                        when "0011" =>
                            secondes <= "1111000000";
                        when "0100" =>
                            secondes <= "1111100000";
                        when "0101" =>
                            secondes <= "1111110000";
                        when "0110" =>
                            secondes <= "1111111000";
                        when "0111" =>
                            secondes <= "1111111100";
                        when "1000" =>
                            secondes <= "1111111110";
                        when "1001" =>
                            secondes <= "1111111111";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                elsif (ds > 4) then
                    secondes <= "1111111111";
                else
                    secondes <= "0000000000";
                end if;
            when "101" =>
                if (ds = 5) then
                    case (us) is
                        when "0000" =>
                            secondes <= "0000000001";
                        when "0001" =>
                            secondes <= "0000000011";
                        when "0010" =>
                            secondes <= "0000000111";
                        when "0011" =>
                            secondes <= "0000001111";
                        when "0100" =>
                            secondes <= "0000011111";
                        when "0101" =>
                            secondes <= "0000111111";
                        when "0110" =>
                            secondes <= "0001111111";
                        when "0111" =>
                            secondes <= "0011111111";
                        when "1000" =>
                            secondes <= "0111111111";
                        when "1001" =>
                            secondes <= "1111111111";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                elsif (ds > 5) then
                    secondes <= "1111111111";
                else
                    secondes <= "0000000000";
                end if;
            when others =>
                secondes <= "0000000000";
            end case;
        else 
            case (bargraphactif) is             -- Affichage des secondes sans le cumul 
            when "000" =>
                if (ds = 0) then
                    case (us) is
                        when "0000" =>
                            secondes <= "0000000001";
                        when "0001" =>
                            secondes <= "0000000010";
                        when "0010" =>
                            secondes <= "0000000100";
                        when "0011" =>
                            secondes <= "0000001000";
                        when "0100" =>
                            secondes <= "0000010000";
                        when "0101" =>
                            secondes <= "0000100000";
                        when "0110" =>
                            secondes <= "0001000000";
                        when "0111" =>
                            secondes <= "0010000000";
                        when "1000" =>
                            secondes <= "0100000000";
                        when "1001" =>
                            secondes <= "1000000000";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                else
                    secondes <= "0000000000";
                end if;
            when "001" =>
                if (ds = 1) then
                    case (us) is
                        when "0000" =>
                            secondes <= "1000000000";
                        when "0001" =>
                            secondes <= "0100000000";
                        when "0010" =>
                            secondes <= "0010000000";
                        when "0011" =>
                            secondes <= "0001000000";
                        when "0100" =>
                            secondes <= "0000100000";
                        when "0101" =>
                            secondes <= "0000010000";
                        when "0110" =>
                            secondes <= "0000001000";
                        when "0111" =>
                            secondes <= "0000000100";
                        when "1000" =>
                            secondes <= "0000000010";
                        when "1001" =>
                            secondes <= "0000000001";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                else
                    secondes <= "0000000000";
                end if;
            when "010" =>
                if (ds = 2) then
                    case (us) is
                        when "0000" =>
                            secondes <= "0000000001";
                        when "0001" =>
                            secondes <= "0000000010";
                        when "0010" =>
                            secondes <= "0000000100";
                        when "0011" =>
                            secondes <= "0000001000";
                        when "0100" =>
                            secondes <= "0000010000";
                        when "0101" =>
                            secondes <= "0000100000";
                        when "0110" =>
                            secondes <= "0001000000";
                        when "0111" =>
                            secondes <= "0010000000";
                        when "1000" =>
                            secondes <= "0100000000";
                        when "1001" =>
                            secondes <= "1000000000";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                else
                    secondes <= "0000000000";
                end if;
            when "011" =>
                if (ds = 3) then
                    case (us) is
                        when "0000" =>
                            secondes <= "0000000001";
                        when "0001" =>
                            secondes <= "0000000010";
                        when "0010" =>
                            secondes <= "0000000100";
                        when "0011" =>
                            secondes <= "0000001000";
                        when "0100" =>
                            secondes <= "0000010000";
                        when "0101" =>
                            secondes <= "0000100000";
                        when "0110" =>
                            secondes <= "0001000000";
                        when "0111" =>
                            secondes <= "0010000000";
                        when "1000" =>
                            secondes <= "0100000000";
                        when "1001" =>
                            secondes <= "1000000000";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                else
                    secondes <= "0000000000";
                end if;
            when "100" =>
                if (ds = 4) then
                    case (us) is
                        when "0000" =>
                            secondes <= "1000000000";
                        when "0001" =>
                            secondes <= "0100000000";
                        when "0010" =>
                            secondes <= "0010000000";
                        when "0011" =>
                            secondes <= "0001000000";
                        when "0100" =>
                            secondes <= "0000100000";
                        when "0101" =>
                            secondes <= "0000010000";
                        when "0110" =>
                            secondes <= "0000001000";
                        when "0111" =>
                            secondes <= "0000000100";
                        when "1000" =>
                            secondes <= "0000000010";
                        when "1001" =>
                            secondes <= "0000000001";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                else
                    secondes <= "0000000000";
                end if;
            when "101" =>
                if (ds = 5) then
                    case (us) is
                        when "0000" =>
                            secondes <= "0000000001";
                        when "0001" =>
                            secondes <= "0000000010";
                        when "0010" =>
                            secondes <= "0000000100";
                        when "0011" =>
                            secondes <= "0000001000";
                        when "0100" =>
                            secondes <= "0000010000";
                        when "0101" =>
                            secondes <= "0000100000";
                        when "0110" =>
                            secondes <= "0001000000";
                        when "0111" =>
                            secondes <= "0010000000";
                        when "1000" =>
                            secondes <= "0100000000";
                        when "1001" =>
                            secondes <= "1000000000";
                        when others =>
                            secondes <= "0000000000";
                    end case;
                else
                    secondes <= "0000000000";
                end if;
            when others =>
                secondes <= "0000000000";
            end case;
        end if;
    end process Gestion_secondes;

    choix_allumage : process (digitactif) -- Process permettant d'allumé un digit en fonction de la valeur de digitactif
    begin
        case (digitactif) is -- Choix du segment à allumer
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

    affichage :process (digitactif,sw_aff) -- Process permettant d'associer une valeur a chaque digit et de selectionner l'affichage (hh/mm ou mm/ss)
    begin
        if (sw_aff = '0') then              -- Si le switch est a 0 nous avons un affichage mm/ss
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
        if (sw_aff = '1') then              -- Si le switch est a 1 nousb avons un affichage hh/mm
            case (digitactif) is    
                when "00" =>
                    if (dh = 0)then
                        nombre <= "1111";   -- Lorsque nous avons la dizaines des heures a 0 nous devons rien afficher, nous avons donc associer un état hors cycle permettant cet affichage
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
    
    clock : process (clk)   -- Création de la clock en 3600hz à partir de 100MHz
    begin
        if (clk'event and clk = '1') then
            if (comp_hz >= 13889) then  -- Utilisation d'un compteur pour "diviser" la clock
                comp_hz <= (others => '0');
                hz3600 <= not(hz3600);  -- Création d'une clock 
            else
                comp_hz <= comp_hz + 1; -- Incrémentation du compteur
            end if;
        end if;
    end process clock;

    differente_horloge : process (hz3600)   -- Création des différents signaux enables permettant d'avoir duifférentes clock
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
    
    Point_décimal : process (hz3600)        -- Process permettant le clignottement d'un point décimal à la vitesse des secondes
    begin
        if (hz3600'event and hz3600 = '1' and hz2_en = '1') then    -- A chaque front montant de clock et du signal enable a 2 Hz nous inversons le signal inte_pointdecimal
            inter_pointdecimal <= not(inter_pointdecimal);
        end if;
    end process Point_décimal;
    
    Affichage_Point_décimal : process (digitactif,inter_pointdecimal)  -- Process permettant l'affichage du point décimal à l'aide du signal inter_pointdecimal
    begin
        if (digitactif = "01") then
            pointdecimal <= inter_pointdecimal;
        else
            pointdecimal <= '0';
        end if;
    end process Affichage_Point_décimal;

    affichage_nombre : process (nombre) -- Process permettant la configuration des 7 segments en fonction du nombre demander ainsi que l'état hors cycle permettant un affichage nul
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
    
n_seg <= not(seg);                          -- Inversion des sorties pour les signaux en logique négative
n_commun <= not(commun);
n_pointdecimal <= not(pointdecimal);
n_bargraphcommun <= not(bargraphcommun);

end Behavioral;
