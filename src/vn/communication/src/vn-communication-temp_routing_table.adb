-- Copyright (c) 2014 All Rights Reserved
-- Author: Nils Brynedal Ignell
-- Date: 2014-XX-XX
-- Summary:
-- Simple implementation of routing table. A logical address is mapped to 
-- a generic type of address, for example a CAN address, UDP-port, etc.
-- A better implementation is recommended in the future.

-- ToDo: Only a simple implementation, could be optimized.

with Interfaces;
use Interfaces;

package body VN.Communication.Temp_Routing_Table is

   function NumberOfEntries(this : in Table_Type) return Natural is
   begin
      return this.count;
   end NumberOfEntries;

   procedure Insert(this : in out Table_Type;
                    Logical_Address : VN.VN_Logical_Address;
                    Generic_Address : Generic_Address_Type) is

      ROUTING_TABLE_OVERFLOW : exception;
      index : VN.VN_Logical_Address := Logical_Address rem this.Capacity;
   begin
      for i in index..this.Values'Last loop
         if not this.Values(i).isUsed or else
           this.Values(i).Logical_Address = Logical_Address then

            this.Values(i).isUsed := true;
            this.Values(i).Logical_Address := Logical_Address;
            this.Values(i).Generic_Address := Generic_Address;
            this.count := this.count + 1;

            return;
         end if;
      end loop;

      raise ROUTING_TABLE_OVERFLOW;
   end Insert;

   procedure Search(this : in Table_Type;
                    Logical_Address : VN.VN_Logical_Address;
                    Generic_Address : out Generic_Address_Type;
                    found : out Boolean) is

      index : VN.VN_Logical_Address := Logical_Address rem this.Capacity;
   begin
      for i in index..this.Values'Last loop
         if this.Values(i).isUsed then
            if this.Values(i).Logical_Address = Logical_Address then
               Generic_Address := this.Values(i).Generic_Address;
               found := true;

               return;
            end if;
         end if;
      end loop;
      found := false;
   end Search;

end VN.Communication.Temp_Routing_Table;
