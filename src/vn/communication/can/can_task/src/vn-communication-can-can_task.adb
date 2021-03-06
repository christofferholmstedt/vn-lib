-- Copyright (c) 2014 All Rights Reserved
-- Author: Nils Brynedal Ignell
-- Date: 2014-XX-XX
-- Summary:
-- CAN_Task is the lowlevel task that accesses the CAN_Interface object.
-- It reads CAN messages from the lowlevel read buffer, runs the Update
-- function of CAN_Interface and writes CAN messages to the lowlevel send buffer.
-- Each task that accesses an instance of CAN_Interface will do so using an
-- access variable (pointer).

with Ada.Real_Time;

with VN;
with VN.Communication.CAN;
with VN.Communication.CAN.Logic.SM;
with VN.Communication.CAN.CAN_Driver;
--  with BBB_CAN;

with Ada.Exceptions;

package body VN.Communication.CAN.CAN_Task is

   package buf renames VN.Communication.CAN.CAN_Message_Buffers;

   task body CAN_Task_Type is
      use Ada.Real_Time;

      myPeriod : Ada.Real_Time.Time_Span;

      Next_Period : Ada.Real_Time.Time;

      BUFFER_SIZE : constant integer := 100; --ToDO: Put this in a config file of some sort
      msgsIn, msgsOut : buf.Buffer(BUFFER_SIZE);

      procedure Input is
         status  : VN.Receive_Status;
         msgLog  : VN.Communication.CAN.CAN_Message_Logical;
      begin

         --  BBB_CAN.Get(msgPhys, hasReceived, b);
       CAN_Driver.Receive(msgLog, status);

         while not buf.Full(msgsIn) and
           (status = VN.MSG_RECEIVED_NO_MORE_AVAILABLE or status = VN.MSG_RECEIVED_MORE_AVAILABLE) loop -- ToDo: Update if more options of VN.Receive_Status are added

            buf.Insert(msgLog, msgsIn);

            --   BBB_CAN.Get(msgPhys, hasReceived, b);
            CAN_Driver.Receive(msgLog, status);
         end loop;
      end Input;

      procedure Output is
         msgLog  : VN.Communication.CAN.CAN_Message_Logical;
         status : VN.Send_Status;
      begin

         while not buf.Empty(msgsOut) and not CAN_Driver.Send_Buffer_Full loop
            buf.Remove(msgLog, msgsOut);
            --       BBB_CAN.Send(msgPhys);
            CAN_Driver.Send(msgLog, status);
         end loop;
      end Output;

   begin

      VN.Text_IO.Put_Line("CAN_Task started");

      myPeriod := thePeriod.all;
      Next_Period := Ada.Real_Time.Clock;

      --  BBB_CAN.Init(port.all, UartWrapper.B115200);

      loop
         Next_Period := Next_Period + myPeriod;
         delay until Next_Period;

--           VN.Text_IO.Put_Line("CAN_Task input start");

         Input;

--           VN.Text_IO.Put_Line("CAN_Task input ended, update start");

         myAccess.Update(msgsIn, msgsOut);

        -- CAN_Driver.Update_Filters(CANFilter);

--           VN.Text_IO.Put_Line("CAN_Task update ended");

         Output;

        -- VN.Text_IO.Put_Line("CAN_Task loop ended");
      end loop;

   end CAN_Task_Type;
end VN.Communication.CAN.CAN_Task;
