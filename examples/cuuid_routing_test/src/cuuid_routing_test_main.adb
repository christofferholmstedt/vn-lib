-- Copyright (c) 2014 All Rights Reserved
-- Author: Nils Brynedal Ignell
-- Date: 2014-XX-XX
-- Summary:
-- Test implementation of VN.Communication.CUUID_Routing.

pragma Profile (Ravenscar);

with GNAT.IO;

with VN;
use VN;

with Ada.Real_Time;
use Ada.Real_Time;

with VN.Communication.CAN;
use VN.Communication.CAN;

with Interfaces;
with VN.Communication.CUUID_Routing;

--  with System.BB.Interrupts; -- Remove when compiling for PC, keep when compiling for SmartFusion2

procedure CUUID_Routing_Test_Main is

  package CAN_CUUID_Routing is new VN.Communication.CUUID_Routing(VN.Communication.CAN.CAN_Address_Sender);

   routingTable : CAN_CUUID_Routing.Table_Type;

   c : array(1..127) of VN.VN_CUUID;
   a : array(c'Range) of VN.Communication.CAN.CAN_Address_Sender;
   b : array(c'Range) of VN.Communication.CAN.CAN_Address_Sender;

   d : array(1..127) of VN.VN_CUUID;

   found : boolean;

   wait : Ada.Real_Time.Time_Span := Ada.Real_Time.Seconds(2);
   now  : Ada.Real_Time.Time;

begin


   now := Ada.Real_Time.Clock;
   delay until now + wait;

   GNAT.IO.New_Line(2);
   GNAT.IO.Put_Line("CUUID routing table test started");

   now := Ada.Real_Time.Clock;
   delay until now + wait;

   for i in c'Range loop
      c(i) := (others => Interfaces.Unsigned_8(i));
      d(i) := (others => Interfaces.Unsigned_8(i + 127));

      a(i) := VN.Communication.CAN.CAN_Address_Sender(i);
      b(i) := VN.Communication.CAN.CAN_Address_Sender(0);
      CAN_CUUID_Routing.Insert(routingTable, c(i), a(i));

      if CAN_CUUID_Routing.Number_Of_Entries(routingTable) /= i then
          GNAT.IO.Put_Line("Number_Of_Entries was incorrect");
      end if;

   end loop;

   for i in c'Range loop
      CAN_CUUID_Routing.Search(routingTable, c(i), b(i), found);

      if a(i) /= b(i) and found then
         GNAT.IO.Put_Line("Index " & i'Img & " is incorrect");
      end if;

      CAN_CUUID_Routing.Search(routingTable, d(i), b(i), found);
      if found then
         GNAT.IO.Put_Line("Index " & i'Img & " was incorrectly found");
      end if;
   end loop;

   GNAT.IO.Put_Line("Test comlete");

   loop
      now := Ada.Real_Time.Clock;
      delay until now + wait;
   end loop;

end CUUID_Routing_Test_Main;
