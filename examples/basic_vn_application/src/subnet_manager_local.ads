with VN.Message;
with System;
with Ada.Text_IO;
with Buffers;
with Global_Settings;
with VN;
with VN.Application_Information;
with VN.Message.Factory;
with VN.Message.Local_Hello;
with VN.Message.Assign_Address;
with VN.Message.Assign_Address_Block;
with VN.Message.Request_Address_Block;
with VN.Message.Request_LS_Probe;
with VN.Message.Distribute_Route;
with Interfaces;

package Subnet_Manager_Local is

   task type SM_L(Pri : System.Priority;
                     Cycle_Time : Positive;
                     Task_ID : Positive;
                     Increment_By : Positive) is
      pragma Priority(Pri);
   end SM_L;

end Subnet_Manager_Local;
