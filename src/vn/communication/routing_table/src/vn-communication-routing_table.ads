-- Copyright (c) 2014 All Rights Reserved
-- Author: Nils Brynedal Ignell
-- Date: 2014-XX-XX
-- Summary:
-- Simple implementation of routing table. A logical address is mapped to 
-- a generic type of address, for example a CAN address, UDP-port, etc.
-- A better implementation is recommended in the future.

-- ToDo: Only a simple implementation, could be optimized.

generic
   type Generic_Address_Type is private; -- e.g. CAN address, UDP-port, etc.
package VN.Communication.Routing_Table is
   pragma Elaborate_Body;

   type Table_Type (Capacity : VN.VN_Logical_Address) is private;

   function NumberOfEntries(this : in Table_Type) return Natural;

   procedure Insert(this : in out Table_Type;
                    Logical_Address : VN.VN_Logical_Address;
                    Generic_Address : Generic_Address_Type;
                    isDirect 	    : Boolean := false);

   procedure Search(this : in Table_Type;
                    Logical_Address : VN.VN_Logical_Address;
                    Generic_Address : out Generic_Address_Type;
                    found    : out Boolean;
                    isDirect : access Boolean := null);
private

   type Element_Type is
      record
         isUsed 	 : Boolean := false;
         Logical_Address : VN.VN_Logical_Address;
         Generic_Address : Generic_Address_Type;
         isDirect	 : Boolean := false;
      end record;

   type Content is array (VN.VN_Logical_Address range <>) of Element_Type;

   type Table_Type (Capacity : VN.VN_Logical_Address) is
      record
         count  : Natural := 0;
         Values : Content (0 .. Capacity); --and yes, the length of Values will be Capacity+1
      end record;

end VN.Communication.Routing_Table;
