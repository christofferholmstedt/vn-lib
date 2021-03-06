-- Copyright (c) 2014 All Rights Reserved
-- Author: Nils Brynedal Ignell
-- Date: 2014-XX-XX
-- Summary:
-- Protocol_Routing_Node_Test is testing the functionality of a node

with System;
with Ada.Real_Time;

with Interfaces;
use Interfaces;

with VN;

with VN.Communication;
with VN.Communication.CAN;
use VN.Communication.CAN;
with VN.Communication.CAN.Can_Task;
with VN.Communication.CAN.CAN_Interface;
with VN.Communication.CAN.CAN_Filtering;

with VN.Communication.PO;
with VN.Communication.PO_Wrapper;

with VN.Communication.Protocol_Routing;

with Protocol_Routing_Second_Task;

package Protocol_Routing_Node_Test is

   theFilter : aliased VN.Communication.CAN.CAN_Filtering.CAN_Filter_Type;

   CANPeriod : aliased Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(100);

   identifier : constant Integer := 1;
   U1 : aliased VN.Communication.CAN.UCID := VN.Communication.CAN.UCID(identifier * 10);
   C1 : aliased VN.VN_CUUID := (Interfaces.Unsigned_8(1 + identifier * 10), others => 5);

   CANInterface : aliased VN.Communication.CAN.CAN_Interface.CAN_Interface_Type
     (U1'Unchecked_Access, C1'Unchecked_Access,
      theFilter'Unchecked_Access, VN.Communication.CAN.CAN_Interface.Node);

   myCANTask : aliased VN.Communication.CAN.Can_Task.CAN_Task_Type
     (CANInterface'Access, System.Priority'Last, CANPeriod'Access, theFilter'Unchecked_Access);

  -- mainTask : Protocol_Routing_Second_Task.Second_Task_Type(C1'Access, CANInterface'Access, System.Priority'Last, CANPeriod'Access);

end Protocol_Routing_Node_Test;
