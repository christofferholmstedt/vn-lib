with VN.Message;
with System;
with Ada.Text_IO;
with Buffers;
with VN;
-- with VN.SM_Hidden_Variables;
with VN.Communication;
with VN.Message.Factory;
with VN.Message.Local_Hello;
with VN.Message.Assign_Address;
with VN.Message.Assign_Address_Block;
with VN.Message.Request_Address_Block;
with VN.Message.Request_LS_Probe;
with VN.Message.Distribute_Route;
with Interfaces;
with Logging.Print_Out;

package VN.SM_Application_Layer_Logic is

   type SM_Logic_Type(Com_Object       : VN.Communication.Com_Access;
                      CUUID_In         : access VN.VN_CUUID;
                      Debug_ID_String2 : access String;
                      Logger2          : access Logging.Print_Out.Print_Out_Logger)
      is tagged limited private;

   procedure Receive_Loop(This: in out SM_Logic_Type);
   procedure Send_Loop(This: in out SM_Logic_Type);

   private

      package VN_Logical_Address_Buffer is
         new Buffers(VN.VN_Logical_Address);

      package Unsigned_8_Buffer is
         new Buffers(Interfaces.Unsigned_8);

   type SM_Logic_Type(Com_Object       : VN.Communication.Com_Access;
                      CUUID_In         : access VN.VN_CUUID;
                      Debug_ID_String2 : access String;
                      Logger2          : access Logging.Print_Out.Print_Out_Logger)
         is tagged limited
      record
         Com               : VN.Communication.Com_Access := Com_Object;
         CUUID             : VN.VN_CUUID := CUUID_In.all;
         Debug_ID_String   : String(1 .. 5) := Debug_ID_String2.all;
         Logical_Address   : VN.VN_Logical_Address;
         Component_Type    : VN.Message.VN_Component_Type;
         Logger            : Logging.Print_Out.Print_Out_Logger := Logger2.all;


      Basic_Msg: VN.Message.VN_Message_Basic;
      Local_Hello_Msg: VN.Message.Local_Hello.VN_Message_Local_Hello;
      Assign_Address_Msg: VN.Message.Assign_Address.VN_Message_Assign_Address;
      Assign_Address_Block_Msg: VN.Message.Assign_Address_Block.VN_Message_Assign_Address_Block;
      Request_Address_Block_Msg: VN.Message.Request_Address_Block.VN_Message_Request_Address_Block;
      Request_LS_Probe_Msg: VN.Message.Request_LS_Probe.VN_Message_Request_LS_Probe;
      Distribute_Route_Msg: VN.Message.Distribute_Route.VN_Message_Distribute_Route;

      Recv_Status: VN.Receive_Status;
      Send_Status: VN.Send_Status;

      Version: VN.Message.VN_Version;

      Sent_CAS_Request_LS_Probe : boolean := false;
      CAS_CUUID: Interfaces.Unsigned_8;
      CAS_Logical_Address: VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      LS_CUUID: Interfaces.Unsigned_8;
      LS_Logical_Address: VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      -- TODO: Change this buffer to some kind of data store.
      -- Map Logical address to CUUID. Only maping now is that they are
      -- added and removed at the same time from separate FIFO queues.
      Distribute_Route_Buffer_Addresses: VN_Logical_Address_Buffer.Buffer(10);
      -- SM_Logical_Address: VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      Temp_Uint8: Interfaces.Unsigned_8;
      Temp_Logical_Address: VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      Received_Address_Block : VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;
      Assigned_Address : VN.VN_Logical_Address := VN.LOGICAL_ADDRES_UNKNOWN;

      -- TODO: Change this buffer to some kind of data store.
      Assign_Address_Buffer: Unsigned_8_Buffer.Buffer(10);

      -- TODO: Change this buffer to some kind of data store.
      Request_LS_Probe_Buffer: VN_Logical_Address_Buffer.Buffer(10);

      -- TODO: Change this buffer to some kind of data store.
      Distribute_Route_Buffer: Unsigned_8_Buffer.Buffer(10);

      -- TODO: Change this buffer to some kind of data store.
      Request_Address_Block_Buffer: Unsigned_8_Buffer.Buffer(10);

      end record;

      procedure Get_Address_To_Assign(This: in out SM_Logic_Type;
                                   CUUID_Uint8: in Interfaces.Unsigned_8;
                                   Log_Address: out VN.VN_Logical_Address);

      function Has_Received_Address_Block(This: in SM_Logic_Type)
                     return Boolean;

end VN.SM_Application_Layer_Logic;
