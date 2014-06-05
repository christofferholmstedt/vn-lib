with Ada.Real_Time;
with Buffers;
with VN.SM_Application_Layer_Logic;
with VN.Message.Factory;
with VN.Message.Local_Hello;
with VN.Message.Assign_Address;
with VN.Message.Assign_Address_Block;
with VN.Message.Request_Address_Block;
with VN.Message.Distribute_Route;
with Interfaces;
with Logging.Print_Out;

package body VN.SM_Application_Layer_Logic is

   procedure Receive_Loop(This: in out SM_Logic_Type) is
      use VN;
      use VN.Message;
      use VN.Message.Local_Hello;
      use VN.Message.Assign_Address;
      use VN.Message.Assign_Address_Block;
      use VN.Message.Request_Address_Block;
      use VN.Message.Request_LS_Probe;
      use VN.Message.Distribute_Route;
      use Interfaces;

   begin
      This.Component_Type := VN.Message.SM_L;

      This.Com.Receive(This.Basic_Msg, This.Recv_Status);

      if This.Recv_Status = VN.NO_MSG_RECEIVED then
         VN.Text_IO.Put_Line(This.Debug_ID_String & "RECV: Empty.");

      elsif This.Recv_Status = VN.MSG_RECEIVED_NO_MORE_AVAILABLE or
         This.Recv_Status = VN.MSG_RECEIVED_MORE_AVAILABLE    then

         -- Print debug text.
         VN.Text_IO.Put(This.Debug_ID_String & "RECV: ");
         This.Logger.Log(This.Basic_Msg);

         -- Process incoming message.
         if This.Basic_Msg.Header.Opcode = VN.Message.OPCODE_LOCAL_HELLO then
            To_Local_Hello(This.Basic_Msg, This.Local_Hello_Msg);

            if (This.Local_Hello_Msg.Component_Type = VN.Message.Other or
               This.Local_Hello_Msg.Component_Type = VN.Message.LS) then

                  Unsigned_8_Buffer.Insert(This.Local_Hello_Msg.CUUID(1), This.Assign_Address_Buffer);

                  if This.Local_Hello_Msg.Component_Type = VN.Message.LS then
                     This.LS_CUUID := This.Local_Hello_Msg.CUUID(1);
                  end if;

            elsif (This.Local_Hello_Msg.Component_Type = VN.Message.SM_L or
                  This.Local_Hello_Msg.Component_Type = VN.Message.SM_x) then
                  Unsigned_8_Buffer.Insert(This.Local_Hello_Msg.CUUID(1), This.Request_Address_Block_Buffer);

            elsif (This.Local_Hello_Msg.Component_Type = VN.Message.CAS) then
                  This.CAS_CUUID := This.Local_Hello_Msg.CUUID(1);
            end if;

         elsif This.Basic_Msg.Header.Opcode = VN.Message.OPCODE_ASSIGN_ADDR_BLOCK then
               To_Assign_Address_Block(This.Basic_Msg, This.Assign_Address_Block_Msg);

               if This.Assign_Address_Block_Msg.Response_Type = VN.Message.Valid and
                  This.Assign_Address_Block_Msg.CUUID = This.CUUID then

                  This.Received_Address_Block := This.Assign_Address_Block_Msg.Assigned_Base_Address;
                  This.Logical_Address := This.Received_Address_Block;
                  -- This.Assigned_Address := Received_Address_Block; -- This is correct
                  This.Assigned_Address := This.Received_Address_Block - 1; -- This is for debugging

                  -- TODO: Change this so CAS address could be dynamic
                  -- It's hard coded in CAS logic as well.
                  if This.Assign_Address_Block_Msg.Header.Source = VN.CAS_LOGICAL_ADDRESS then
                     This.CAS_Logical_Address := This.Assign_Address_Block_Msg.Header.Source;
                  end if;

               elsif This.Assign_Address_Block_Msg.Response_Type = VN.Message.Valid and
                  This.Assign_Address_Block_Msg.CUUID /= This.CUUID then

                     -- TODO: Remove this send so it's not coupled with
                     -- receive.
                     To_Basic(This.Assign_Address_Block_Msg, This.Basic_Msg);
                     This.Basic_Msg.Header.Destination := VN.LOGICAL_ADDRES_UNKNOWN;
                     This.Basic_Msg.Header.Source := This.Logical_Address;

                     VN.Text_IO.Put(This.Debug_ID_String & "SEND: ");
                     This.Logger.Log(This.Basic_Msg);
                     This.Com.Send(This.Basic_Msg, This.Send_Status);

                     Unsigned_8_Buffer.Insert(This.Assign_Address_Block_Msg.CUUID(1), This.Distribute_Route_Buffer);

                     -- TODO: Temporary fix for only one SM-x
                     -- Need to map CUUIDs to assigned addresses to be
                     -- able to send distribute route messages.
                     -- SM_x_Logical_Address := This.Assign_Address_Block_Msg.Assigned_Base_Address;
                     VN_Logical_Address_Buffer.Insert(This.Assign_Address_Block_Msg.Assigned_Base_Address, This.Distribute_Route_Buffer_Addresses);
               end if;

         elsif This.Basic_Msg.Header.Opcode = VN.Message.OPCODE_DISTRIBUTE_ROUTE then
               To_Distribute_Route(This.Basic_Msg, This.Distribute_Route_Msg);

               if This.Distribute_Route_Msg.Component_Type = VN.Message.CAS then
                  This.CAS_Logical_Address := This.Distribute_Route_Msg.Component_Address;
                  This.CAS_CUUID := This.Distribute_Route_Msg.CUUID(1);

               elsif This.Distribute_Route_Msg.Component_Type = VN.Message.LS then
                  This.LS_Logical_Address := This.Distribute_Route_Msg.Component_Address;
                  This.LS_CUUID := This.Distribute_Route_Msg.CUUID(1);
               end if;

         end if;
      end if;

   end Receive_Loop;

   procedure Send_Loop(This: in out SM_Logic_Type) is
      use VN;
      use VN.Message;
      use VN.Message.Local_Hello;
      use VN.Message.Assign_Address;
      use VN.Message.Assign_Address_Block;
      use VN.Message.Request_Address_Block;
      use VN.Message.Request_LS_Probe;
      use VN.Message.Distribute_Route;
      use Interfaces;
   begin

      -- Assign Address Blocks to other SM:s on the subnet
      if not Unsigned_8_Buffer.Empty(This.Request_Address_Block_Buffer) and
               This.Has_Received_Address_Block and
               This.CAS_Logical_Address /= VN.LOGICAL_ADDRES_UNKNOWN then

         Unsigned_8_Buffer.Remove(This.Temp_Uint8, This.Request_Address_Block_Buffer);

         This.Basic_Msg := VN.Message.Factory.Create(VN.Message.Type_Request_Address_Block);
         This.Basic_Msg.Header.Source := This.Logical_Address;
         This.Basic_Msg.Header.Destination := This.CAS_Logical_Address;

         To_Request_Address_Block(This.Basic_Msg, This.Request_Address_Block_Msg);
         This.Request_Address_Block_Msg.CUUID := (others => This.Temp_Uint8);
         To_Basic(This.Request_Address_Block_Msg, This.Basic_Msg);

         VN.Text_IO.Put(This.Debug_ID_String & "SEND: ");
         This.Logger.Log(This.Basic_Msg);
         This.Com.Send(This.Basic_Msg, This.Send_Status);

      -- Distribute route, assumes that the LS and CAS are co-located.
      elsif not Unsigned_8_Buffer.Empty(This.Distribute_Route_Buffer) and
               This.CAS_Logical_Address /= VN.LOGICAL_ADDRES_UNKNOWN and
               This.LS_Logical_Address /= VN.LOGICAL_ADDRES_UNKNOWN then

         Unsigned_8_Buffer.Remove(This.Temp_Uint8, This.Distribute_Route_Buffer);
         VN_Logical_Address_Buffer.Remove(This.Temp_Logical_Address, This.Distribute_Route_Buffer_Addresses);

         -- CAS
         This.Basic_Msg := VN.Message.Factory.Create(VN.Message.Type_Distribute_Route);
         This.Basic_Msg.Header.Source := This.Logical_Address;
         This.Basic_Msg.Header.Destination := This.Temp_Logical_Address;
         To_Distribute_Route(This.Basic_Msg, This.Distribute_Route_Msg);
         This.Distribute_Route_Msg.CUUID := (others => This.CAS_CUUID);
         This.Distribute_Route_Msg.Component_Address := This.CAS_Logical_Address;
         This.Distribute_Route_Msg.Component_Type:= VN.Message.CAS;

         To_Basic(This.Distribute_Route_Msg, This.Basic_Msg);

         VN.Text_IO.Put(This.Debug_ID_String & "SEND: ");
         This.Logger.Log(This.Basic_Msg);
         This.Com.Send(This.Basic_Msg, This.Send_Status);

         -- LS
         This.Distribute_Route_Msg.CUUID := (others => This.LS_CUUID);
         This.Distribute_Route_Msg.Component_Address := This.LS_Logical_Address;
         This.Distribute_Route_Msg.Component_Type:= VN.Message.LS;

         To_Basic(This.Distribute_Route_Msg, This.Basic_Msg);

         VN.Text_IO.Put(This.Debug_ID_String & "SEND: ");
         This.Logger.Log(This.Basic_Msg);
         This.Com.Send(This.Basic_Msg, This.Send_Status);

      elsif not Unsigned_8_Buffer.Empty(This.Assign_Address_Buffer) and
               This.Has_Received_Address_Block then

         Unsigned_8_Buffer.Remove(This.Temp_Uint8, This.Assign_Address_Buffer);

         This.Basic_Msg := VN.Message.Factory.Create(VN.Message.Type_Assign_Address);
         This.Basic_Msg.Header.Source := This.Logical_Address;
         This.Basic_Msg.Header.Destination := VN.LOGICAL_ADDRES_UNKNOWN;
         To_Assign_Address(This.Basic_Msg, This.Assign_Address_Msg);
         This.Assign_Address_Msg.CUUID := (others => This.Temp_Uint8);
         This.Get_Address_To_Assign(This.Temp_Uint8, This.Temp_Logical_Address);
         This.Assign_Address_Msg.Assigned_Address := This.Temp_Logical_Address;

         To_Basic(This.Assign_Address_Msg, This.Basic_Msg);

         VN.Text_IO.Put(This.Debug_ID_String & "SEND: ");
         This.Logger.Log(This.Basic_Msg);
         This.Com.Send(This.Basic_Msg, This.Send_Status);

         -- TODO: Fix proper lookup table to keep track of LS, CAS and
         -- other SM-x
         if This.Temp_Uint8 = This.LS_CUUID then
               This.LS_Logical_Address := This.Assign_Address_Msg.Assigned_Address;
            else
               VN_Logical_Address_Buffer.Insert(This.Assign_Address_Msg.Assigned_Address, This.Request_LS_Probe_Buffer);
         end if;

         -- TODO: How will this work with multiple Subnet Managers?
         -- Will distribute route messages arrive before this runs?
         if This.Sent_CAS_Request_LS_Probe = false and
            This.CAS_Logical_Address /= VN.LOGICAL_ADDRES_UNKNOWN then

               VN_Logical_Address_Buffer.Insert(This.CAS_Logical_Address, This.Request_LS_Probe_Buffer);
               This.Sent_CAS_Request_LS_Probe := true;
         end if;

      elsif not VN_Logical_Address_Buffer.Empty(This.Request_LS_Probe_Buffer) then
         VN_Logical_Address_Buffer.Remove(This.Temp_Logical_Address, This.Request_LS_Probe_Buffer);

         This.Basic_Msg := VN.Message.Factory.Create(VN.Message.Type_Request_LS_Probe);
         This.Basic_Msg.Header.Source := This.Logical_Address;
         This.Basic_Msg.Header.Destination := This.LS_Logical_Address;
         To_Request_LS_Probe(This.Basic_Msg, This.Request_LS_Probe_Msg);
         This.Request_LS_Probe_Msg.Component_Address := This.Temp_Logical_Address;

         To_Basic(This.Request_LS_Probe_Msg, This.Basic_Msg);

         VN.Text_IO.Put(This.Debug_ID_String & "SEND: ");
         This.Logger.Log(This.Basic_Msg);
         This.Com.Send(This.Basic_Msg, This.Send_Status);

      end if;
   end Send_Loop;

   ----------------------------
   -- Helper functions below
   ----------------------------
   procedure Get_Address_To_Assign(This: in out SM_Logic_Type;
                                   CUUID_Uint8: in Interfaces.Unsigned_8;
                                   Log_Address: out VN.VN_Logical_Address)
   is
      use VN;
   begin
      -- TODO: This function doesn't take into account the CUUID, which it
      -- should.
      This.Assigned_Address := This.Assigned_Address + 1;
      Log_Address := This.Assigned_Address + 1;
   end Get_Address_To_Assign;

   function Has_Received_Address_Block(This: in SM_Logic_Type)
                              return Boolean is
      use VN;
   begin
      if This.Received_Address_Block /= VN.LOGICAL_ADDRES_UNKNOWN then
         return true;
      else
         return false;
      end if;
   end Has_Received_Address_Block;

end VN.SM_Application_Layer_Logic;
