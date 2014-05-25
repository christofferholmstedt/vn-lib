with Ada.Text_IO;
with VN.Message;
use VN.Message;
with VN.Message.Local_Hello;
with VN.Message.Assign_Address;
with VN.Message.Request_Address_Block;

package body Logging.Print_Out is

   procedure Log(This: in out Print_Out_Logger;
                 Message: out VN.Message.VN_Message_Basic) is
      use Ada.Text_IO;
      Local_Hello_Msg: VN.Message.Local_Hello.VN_Message_Local_Hello;
      Assign_Address_Msg: VN.Message.Assign_Address.VN_Message_Assign_Address;
      Request_Address_Block_Msg:
            VN.Message.Request_Address_Block.VN_Message_Request_Address_Block;
   begin

      if Message.Header.Opcode = OPCODE_LOCAL_HELLO then

         VN.Message.Local_Hello.To_Local_Hello(Message, Local_Hello_Msg);
         Put("Local Hello from:" &
             VN.VN_Logical_Address'Image(Local_Hello_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Local_Hello_Msg.Header.Destination) &
            " (logical addresses), Comp_Type is " &
            VN.Message.VN_Component_Type'Image(Local_Hello_Msg.Component_Type) &
            ", CUUID is " &
            Local_Hello_Msg.CUUID(1)'Img);
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_LOCAL_ACK then
         Put_Line("Local_Ack");

      elsif Message.Header.Opcode = OPCODE_ASSIGN_ADDR then
         VN.Message.Assign_Address.To_Assign_Address(Message, Assign_Address_Msg);
         Put("Assign Address from:" &
             VN.VN_Logical_Address'Image(Assign_Address_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Assign_Address_Msg.Header.Destination) &
            " (logical addresses), CUUID " &
            Assign_Address_Msg.CUUID(1)'Img &
            " gets logical address " &
            Assign_Address_Msg.Assigned_Address'Img);
         Put_Line("");

      elsif Message.Header.Opcode = OPCODE_REQUEST_ADDR_BLOCK then
         VN.Message.Request_Address_Block.To_Request_Address_Block(Message, Request_Address_Block_Msg);
         Put("Request Address Block from:" &
             VN.VN_Logical_Address'Image(Request_Address_Block_Msg.Header.Source) &
            " to " &
            VN.VN_Logical_Address'Image(Request_Address_Block_Msg.Header.Destination) &
            " (logical addresses), from CUUID " &
            Request_Address_Block_Msg.CUUID(1)'Img);
         Put_Line("");

      end if;
   end Log;

end Logging.Print_Out;
