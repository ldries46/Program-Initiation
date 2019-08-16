-----------------------------------------------------------------------
--             Program_Init A package to create INI files            --
--                                                                   --
--                   Copyright (C) 2019 L. Dries                     --
--                                                                   --
-- This library is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 3 of the License, or (at your option) any later version.  --
--                                                                   --
-- This library is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this library; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- This Library creates the possibility to use initiation files for  --
-- ADA programs. Multiple files are possible. The purpose of INI --
-- files is to save values used in a program or a number of programs --
-- to use the next time when one of these programs are used again.   --
-- As an example: A program needs a file with general information.   --
-- When is not practical to put the location in the program it can be--
-- pratctical if the first time the location is asked and next times --
-- the program just knows where to look.                             --                                                         --
-- Two alternate locations for the INI files can be created:         --
-- 1: The home directory of the program (std)                        --
-- 2: A location in another directory                                --
-- The first location is in general for the program itself, the      --
-- can be used for INI files that can be used by various programs,   --
-- for instance the location of a file containing conversion factors --
-- for dimensions say from km to miles etc.                          --
--                                                                   --
-- V 1.00  L. Dries, Rotterdam, The Netherlands 15-5-2009            --
--         Original                                                  --
-- V 1.01  L. Dries, Rotterdam, The Netherlands 29-7-2016            --
--         Booleans Added                                            --
-- V 1.02  L. Dries, Rotterdam, The Netherlands 7-5-2018             --
--         Long Integers added                                       --
-----------------------------------------------------------------------

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

-- with Unchecked_Deallocation;
-----------------------------------------------------------------------
--                                                                   --
-- The GNAT.OS_Lib package is used to make the package as operating  --
-- system independent as possible                                    --
--                                                                   --
-----------------------------------------------------------------------
with GNAT.OS_Lib;

package Program_Init is
   type Waarde is limited private;
   type Waarde_Pointer is access Waarde;
   type Categorie is limited private;
   type Categorie_Pointer is access Categorie;
   ---------------------------------------------------------------------------
   --                                                                       --
   -- The Record File_ID consits of the name of the file (without the       --
   -- extension, an File ID number, a boolean std for the location of the   --
   -- directory and the start of a list of categories. The record is        --
   -- organized as a list                                                   --
   --                                                                       --
   ---------------------------------------------------------------------------
   type File_ID;
   type File_Pointer is access File_ID;
   type File_ID is
      record
         ID   : integer := -1;
         name : Unbounded_string;
         cat  : Categorie_Pointer := null;
         next : File_Pointer := null;
      end record;
   ---------------------------------------------------------------------------
   --                                                                       --
   -- To create an operating system independent filename the directory      --
   -- separator comes from then GNAT.OS_Lib package                         --
   ---------------------------------------------------------------------------
   DS         : character := GNAT.OS_Lib.Directory_Separator;

   ---------------------------------------------------------------------------
   -- I function to which defines the name and the type of the INI file     --
   -- used.
   -- Name      The name of the file (without its .INI extension            --
   --           in the case standard is false The complete file name        --
   --           including the directories wher the file is located must     --
   --           be given                                                    --
   -- The return value is a file identifier lateron used in the program to  --
   -- get or set variables                                                  --
   ---------------------------------------------------------------------------
   function use_file(Name : in string) return integer;
   ---------------------------------------------------------------------------
   --                                                                       --
   -- A procedure which sets for a given Category nad Value name a value    --
   -- The type of values to be used are string, integer or float
   -- ID        idenrifies the file                                         --
   -- Cat_Name  Name of the catagory                                        --
   -- Val_Name  Name of the value                                           --
   -- Val       Value to be set                                             --
   ---------------------------------------------------------------------------
   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in string);
   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in integer);
   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in long_integer);
   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in float);
   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in boolean);
   ---------------------------------------------------------------------------
   --                                                                       --
   -- A  which returns for a given Category and Value name a value  --
   -- The types of values to be used are string, integer or float           --
   -- If a the Category or the Value does not exists the function returns the --
   -- default value and sets the default value                              --
   -- ID             idenrifies the file                                    --
   -- Cat_Name       Name of the catagory                                   --
   -- Val_Name       Name of the value                                      --
   -- Default_Value  Value to be set                                        --
   ---------------------------------------------------------------------------
   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in string) return string;
   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in integer) return integer;
   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in long_integer) return long_integer;
   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in float) return float;
   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in boolean) return boolean;
   ---------------------------------------------------------------------------
   --                                                                       --
   -- A procedure which creates a new INI file with the values inserted in  --
   -- it                                                                    --
   -- If a the Category of the Value do not exists the function returns the --
   -- default value and sets the default value                              --
   ---------------------------------------------------------------------------
   procedure Close_ini;

private
   ---------------------------------------------------------------------
   --                                                                 --
   -- The Record "Waarde" (Dutch word for Value) consits of the name  --
   -- of the value and the value itself. This value is saved in the   --
   -- format of an unbounded string. The record is organized as at    --
   -- list                                                            --
   --                                                                 --
   ---------------------------------------------------------------------
   type Waarde is
      record
         Name : Unbounded_string;
         Waarde : Unbounded_String;
         next : Waarde_Pointer;
      end record;
   ---------------------------------------------------------------------------
   --                                                                       --
   -- The Record "Categorie" (Dutch word for Category) consists of the name --
   -- of the category and the start of a list of Waarde records. The record --
   -- is organized as a list                                                --
   --                                                                       --
   ---------------------------------------------------------------------------
   type Categorie is
      record
         Name : Unbounded_string;
         waarde : Waarde_Pointer := null;
         next : Categorie_Pointer := null;
      end record;
   ---------------------------------------------------------------------------
   --                                                                       --
   -- Startpoint for the files list                                         --
   --                                                                       --
   ---------------------------------------------------------------------------
   Start_File : File_Pointer := null;
   engine     : constant integer := 1;

end Program_Init;
