-- Converted from mpsoc_msi_wb_pkg.v
-- by verilog2vhdl - QueenField

--//////////////////////////////////////////////////////////////////////////////
--                                            __ _      _     _               //
--                                           / _(_)    | |   | |              //
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
--                  | |                                                       //
--                  |_|                                                       //
--                                                                            //
--                                                                            //
--              MPSoC-RISCV CPU                                               //
--              Master Slave Interface                                        //
--              Wishbone Bus Interface                                        //
--                                                                            //
--//////////////////////////////////////////////////////////////////////////////

-- Copyright (c) 2018-2019 by the author(s)
-- *
-- * Permission is hereby granted, free of charge, to any person obtaining a copy
-- * of this software and associated documentation files (the "Software"), to deal
-- * in the Software without restriction, including without limitation the rights
-- * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- * copies of the Software, and to permit persons to whom the Software is
-- * furnished to do so, subject to the following conditions:
-- *
-- * The above copyright notice and this permission notice shall be included in
-- * all copies or substantial portions of the Software.
-- *
-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- * THE SOFTWARE.
-- *
-- * =============================================================================
-- * Author(s):
-- *   Francisco Javier Reina Campo <frareicam@gmail.com>
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mpsoc_msi_wb_pkg is
  --////////////////////////////////////////////////////////////////
  --
  -- Constants
  --
  constant CLASSIC_CYCLE : std_logic := '0';
  constant BURST_CYCLE   : std_logic := '1';

  constant READ  : std_logic := '0';
  constant WRITE : std_logic := '1';

  constant CTI_CLASSIC      : std_logic_vector(2 downto 0) := "000";
  constant CTI_CONST_BURST  : std_logic_vector(2 downto 0) := "001";
  constant CTI_INC_BURST    : std_logic_vector(2 downto 0) := "010";
  constant CTI_END_OF_BURST : std_logic_vector(2 downto 0) := "111";

  constant BTE_LINEAR  : std_logic_vector(2 downto 0) := "000";
  constant BTE_WRAP_4  : std_logic_vector(2 downto 0) := "001";
  constant BTE_WRAP_8  : std_logic_vector(2 downto 0) := "010";
  constant BTE_WRAP_16 : std_logic_vector(2 downto 0) := "011";
end mpsoc_msi_wb_pkg;

package body mpsoc_msi_wb_pkg is
  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --
  function get_cycle_type (
    cti : std_logic_vector(2 downto 0)
    ) return std_logic is
    variable get_cycle_type_return : std_logic;
  begin
    if (cti = CTI_CLASSIC) then
      get_cycle_type_return := CLASSIC_CYCLE;
    else
      get_cycle_type_return := BURST_CYCLE;
    end if;

    return get_cycle_type_return;
  end get_cycle_type;

  function wb_is_last (
    cti : std_logic_vector(2 downto 0)
    ) return std_logic is
    variable wb_is_last_return : std_logic;
  begin
    case (cti) is
      when CTI_CLASSIC =>
        wb_is_last_return := '1';
      when CTI_CONST_BURST =>
        wb_is_last_return := '0';
      when CTI_INC_BURST =>
        wb_is_last_return := '0';
      when CTI_END_OF_BURST =>
        wb_is_last_return := '1';
      when others =>
        null;
    end case;

    return wb_is_last_return;
  end wb_is_last;

  function wb_next_adr (
    adr_i : std_logic_vector(31 downto 0);
    cti_i : std_logic_vector(2 downto 0);
    bte_i : std_logic_vector(2 downto 0);

    dw : integer
    ) return std_logic_vector is
    variable wb_next_adr_return : std_logic_vector (31 downto 0);

    variable adr : std_logic_vector(31 downto 0);

    variable shift : integer;
  begin
    if (dw = 64) then
      shift := 3;
    elsif (dw = 32) then
      shift := 2;
    elsif (dw = 16) then
      shift := 1;
    else
      shift := 0;
    end if;
    adr := std_logic_vector(unsigned(adr_i) srl shift);
    if (cti_i = CTI_INC_BURST) then
      case (bte_i) is
        when BTE_LINEAR =>
          adr := std_logic_vector(unsigned(adr)+X"00000001");
        when BTE_WRAP_4 =>
          adr := (adr(31 downto 2) & std_logic_vector(unsigned(adr(1 downto 0))+"01"));
        when BTE_WRAP_8 =>
          adr := (adr(31 downto 3) & std_logic_vector(unsigned(adr(2 downto 0))+"001"));
        when BTE_WRAP_16 =>
          adr := (adr(31 downto 4) & std_logic_vector(unsigned(adr(3 downto 0))+"0001"));
        when others =>
          null;
      end case;
    end if;
    -- case (burst_type_i)
    wb_next_adr_return := std_logic_vector(unsigned(adr) sll shift);
    return wb_next_adr_return;
  end wb_next_adr;
end mpsoc_msi_wb_pkg;