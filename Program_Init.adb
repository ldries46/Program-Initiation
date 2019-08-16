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

with Program_Init;          use Program_Init;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Text_IO;               use Text_IO;
with Unchecked_Deallocation;

package body Program_Init is

--   procedure Free_File_Pointer is new Unchecked_Deallocation(File_ID, File_Pointer);

   function use_file(Name : in string) return integer is
      tFile_ID  : File_pointer;
      Ctemp     : Categorie_Pointer;
      Wtemp     : Waarde_Pointer;
      Ini_File  : File_Type;
      n         : integer;
      nr        : integer;
      eof       : boolean := false;
      File_Name : Unbounded_string;
      In_String : Unbounded_string;
   begin
      tFile_ID := Start_File;
      n := 1;
      if tFile_ID = null then
         tFile_ID := new File_ID;
      else
         while tFile_ID.next /= null loop
            tFile_ID := tFile_ID.next;
            n := tFile_ID.ID;
         end loop;
         n := n + 1;
         tFile_ID.next := new File_ID;
         tFile_ID := tFile_ID.next;
      end if;
      tFile_ID.ID := n;
      tFile_ID.name := To_Unbounded_String(Name);
      File_Name := To_Unbounded_String(Name & ".ini");
      Open ( Ini_File, In_File, To_String(File_Name));
      In_String := To_Unbounded_String(Get_Line (Ini_File));
      if To_String(In_String) = "INI" then
         nr := integer'value(Get_Line(Ini_File));
         if nr <= 1 then
            while not eof loop
               In_String := To_Unbounded_String(Get_Line (Ini_File));
               eof := To_String(In_String) = "EOF";
               if not eof then
                  if In_String = "CAT" then
                     if tFile_ID.cat = null then
                        tFile_ID.cat := new Categorie;
                        Ctemp := tFile_ID.cat;
                     else
                        Ctemp.next := new Categorie;
                        Ctemp := Ctemp.next;
                     end if;
                     In_String := To_Unbounded_String(Get_Line (Ini_File));
                     Ctemp.Name := In_String;
                     In_String := To_Unbounded_String(Get_Line (Ini_File));
                  end if;
                  if In_String = "VAL" then
                     if Ctemp.waarde = null then
                        Ctemp.waarde := new Waarde;
                        Wtemp := Ctemp.waarde;
                     else
                        Wtemp.next := new Waarde;
                        Wtemp := Wtemp.next;
                     end if;
                     In_String := To_Unbounded_String(Get_Line (Ini_File));
                     Wtemp.Name := In_String;
                     In_String := To_Unbounded_String(Get_Line (Ini_File));
                     Wtemp.Waarde := In_String;
                  end if;
               end if;
            end loop;
         else
            Close( Ini_File );
            raise CONSTRAINT_ERROR;
         end if;
      else
         Close ( Ini_File );
         raise NAME_ERROR;
      end if;
      Close ( Ini_File );
      if n = 1 then
         Start_File := tFile_ID;
      end if;
      return n;
   exception
      when NAME_ERROR =>
         if n = 1 then
            Start_File := tFile_ID;
         end if;
         return n;
   end use_file;

   function Get_File( ID : in integer) return File_Pointer is
      tFile_ID : File_Pointer := Start_File;
   begin
      if tFile_ID /= null then
         loop
            exit when tFile_ID.ID = ID;
            tFile_ID := tFile_ID.next;
            exit when tFile_ID = null;
         end loop;
      end if;
      return tFile_ID;
   end Get_File;

   function Get_Cat ( tFile_ID : in File_Pointer; Cat_Name : string) return Categorie_Pointer is
      tCat : Categorie_Pointer := tFile_ID.cat;
   begin
      if tCat /= null then
         loop
            exit when To_String(tCat.Name) = Cat_Name;
            tCat := tCat.next;
            exit when tCat = null;
         end loop;
      end if;
      return tCat;
   end Get_Cat;

   function Get_Waarde ( tCat : in Categorie_Pointer; Val_Name : string) return Waarde_Pointer is
      tVal : Waarde_Pointer := tCat.waarde;
   begin
      if tVal /= null then
         loop
            exit when To_String(tVal.Name) = Val_Name;
            tVal := tVal.next;
            exit when tVal = null;
         end loop;
      end if;
      return tVal;
   end Get_Waarde;

   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in string) is
      tFile_ID : File_Pointer;
      tCat : Categorie_Pointer;
      tVal : Waarde_Pointer;
   begin
      tFile_ID := Get_File ( ID );
      if tFile_ID /= null then
         tCat := Get_Cat(tFile_ID, Cat_Name);
         if tCat = null then
            if tFile_ID.cat = null then
               tFile_ID.cat := new Categorie;
               tCat := tFile_ID.cat;
            else
               tCat := tFile_ID.cat;
               while tCat.next /= null loop
                  tCat := tCat.next;
               end loop;
               tCat.next := new Categorie;
               tCat := tCat.next;
            end if;
            tCat.Name := To_Unbounded_String(Cat_Name);
         end if;
         tVal := Get_Waarde ( tCat, Val_Name);
         if tVal = null then
            if tCat.waarde = null then
               tCat.waarde := new Waarde;
               tVal := tCat.waarde;
            else
               tVal := tCat.waarde;
               while tVal.next /= null loop
                  tVal := tVal.next;
               end loop;
               tVal.next := new Waarde;
               tVal := tVal.next;
            end if;
            tVal.Name := To_Unbounded_String(Val_Name);
         end if;
         tVal.Waarde := To_Unbounded_String(Val);
      end if;
   end Set_Value;

   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in integer) is
   begin
      Set_Value(ID, Cat_Name, Val_Name, Integer'image(Val));
   end Set_Value;

   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in long_integer) is
   begin
      Set_Value(ID, Cat_Name, Val_Name, long_integer'image(Val));
   end Set_Value;

   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in float) is
   begin
      Set_Value(ID, Cat_Name, Val_Name, Float'image(Val));
   end Set_Value;

   procedure Set_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Val : in boolean) is
   begin
      Set_Value(ID, Cat_Name, Val_Name, boolean'image(Val));
   end Set_Value;

   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in string) return string is
      Value : unbounded_string;
      tFile_ID : File_Pointer;
      tCat     : Categorie_Pointer;
      tVal     : Waarde_Pointer;
      exist    : boolean := false;
   begin
      Value := To_Unbounded_string(Default_Value);
      tFile_ID := Get_File ( ID );
      if tFile_ID /= null then
         tCat := Get_Cat(tFile_ID, Cat_Name);
         if tCat /= null then
            tVal := Get_Waarde ( tCat, Val_Name);
            if tVal /= null then
               Value := tVal.Waarde;
               exist := true;
            end if;
         end if;
      end if;
      if not exist then
         Set_Value( ID, Cat_Name, Val_Name, Default_Value );
      end if;
      return To_String(Value);
   end Get_Value;

   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in integer) return integer is
      Value : integer;
   begin
      Value := integer'value(Get_Value( ID, Cat_Name, Val_Name, Integer'image(Default_Value)));
      return Value;
   end Get_Value;

   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in long_integer) return long_integer is
      Value : long_integer;
   begin
      Value := long_integer'value(Get_Value( ID, Cat_Name, Val_Name, long_Integer'image(Default_Value)));
      return Value;
   end Get_Value;

   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in float) return float is
      Value : float;
   begin
      Value := float'value(Get_Value( ID, Cat_Name, Val_Name, float'image(Default_Value)));
      return Value;
   end Get_Value;

   function Get_Value( ID : in integer; Cat_Name : in string; Val_Name : in string; Default_Value : in boolean) return boolean is
      Value : boolean;
   begin
      Value := boolean'value(Get_Value( ID, Cat_Name, Val_Name, boolean'image(Default_Value)));
      return Value;
   end Get_Value;

   procedure Close_Ini is
      Ini_File   : File_Type;
      tFile_ID   : File_pointer;
      temp       : File_Pointer := null;
      Ctemp      : Categorie_Pointer;
      Wtemp      : Waarde_Pointer;
      File_Name  : Unbounded_string;
      Out_String : Unbounded_string;
   begin
      tFile_ID := Start_File;
      while tFile_ID /= null loop
         temp := tFile_ID;
         tFile_ID := tFile_ID.next;
         if temp /= null then
            File_Name := temp.name & ".ini";
            Create ( Ini_File, Out_File, To_String(File_Name));
            Put_Line (Ini_File, "INI");
            Put_Line (Ini_File, Integer'image(engine));
            Ctemp := temp.cat;
            while Ctemp /= null loop
               Put_Line ( Ini_File, "CAT" );
               Put_Line ( Ini_File, To_String(Ctemp.Name));
               Wtemp := Ctemp.waarde;
               while Wtemp /= null loop
                  Put_Line ( Ini_File, "VAL" );
                  Put_Line ( Ini_File, To_String(Wtemp.Name));
                  Put_Line ( Ini_File, To_String(Wtemp.Waarde));
                  Wtemp := wTemp.next;
               end loop;
               Ctemp := Ctemp.next;
            end loop;
            Put_Line (Ini_File, "EOF");
            Close ( Ini_File );
--            Free_File_Pointer(temp);
         end if;
      end loop;
   end Close_Ini;

end Program_Init;
