
with Interfaces;
with System;

package VN.Message is

   -- Enum of different VN_Messages types.
   type VN_Message_Type is (Type_Basic,
                            Type_Local_Hello,
                            Type_Local_Ack,
                            Type_Request_Address_Block,
                            Type_Assign_Address_Block,
                            Type_Assign_Address,
                            Type_Distribute_Route);
   for VN_Message_Type'Size use 8;

   type VN_Serializiation_Type is (TXT, XML);
   for VN_Serializiation_Type'Size use 8;

   type VN_Component_Type is (CAS, LS, SM_L, SM_x, SM_Gateway, Other);
   for VN_Component_Type'Size use 8;

   type VN_Version is mod 2 ** 8;
   for VN_Version'Size use 8;

   type VN_Priority is mod 2 ** 8;
   for VN_Priority'Size use 8;

   type VN_Length is mod 2 ** 16;
   for VN_Length'Size use 16;

   type VN_Flags is mod 2 ** 16;
   for VN_Flags'Size use 16;

   type VN_Opcode is mod 2 ** 8;
   for VN_Opcode'Size use 8;
   
   type VN_Payload is mod 2 ** 8;
   for VN_Payload'Size use 8;

   type VN_Checksum is mod 2 ** 16;
   for VN_Checksum'Size use 16;

   type VN_Ext_Header_Length is mod 2 ** 8;
   for VN_Ext_Header_Length'Size use 8;

   -- Other VN fields used in multiple derived types
   type VN_Status is mod 2 ** 8;
   for VN_Status'Size use 8;
   ACK_OK 	: constant VN_Status := 0;
   ACK_ERROR 	: constant VN_Status := 1;



   type VN_Response_Type is (Valid, Invalid);
   for VN_Response_Type'Size use 8;

   HEADER_SIZE      : constant integer := 17;
   CHECKSUM_SIZE    : constant integer := 2;
   MAX_PAYLOAD_SIZE : constant integer := 1024;

   COMPONENT_TYPE_SIZE     : constant integer := 1;
   CUUID_SIZE              : constant integer := 16;
   STATUS_SIZE             : constant integer := 1;
   RESPONSE_TYPE_SIZE      : constant integer := 1;
   VN_LOGICAL_ADDRESS_SIZE : constant integer := 4;

   OPCODE_LOCAL_HELLO 		: constant VN_Opcode := 16#20#;
   OPCODE_LOCAL_ACK 		: constant VN_Opcode := 16#21#;  
   OPCODE_DISTRIBUTE_ROUTE 	: constant VN_Opcode := 16#72#;  
   OPCODE_ASSIGN_ADDR_BLOCK	: constant VN_Opcode := 16#4D#;
   OPCODE_ASSIGN_ADDR		: constant VN_Opcode := 16#7B#;
   OPCODE_REQUEST_ADDR_BLOCK	: constant VN_Opcode := 16#4C#;

   type VN_Header is
      record
         Message_Type   : VN_Message_Type := Type_Basic;
         Version        : VN_Version := 16#01#;
         Priority       : VN_Priority;
         Payload_Length : VN_Length;
         Destination    : VN_Logical_Address;
         Source         : VN_Logical_Address;
         Flags          : VN_Flags := 16#0000#;
         Opcode         : VN_Opcode;
         Ext_Header     : VN_Ext_Header_Length := 16#00#;
      end record;

   for VN_Header use record
      Message_Type      at 0 range 0 .. 7;
      Version           at 0 range 8 .. 15;
      Priority          at 0 range 16 .. 23;
      Payload_Length    at 0 range 24 .. 39;
      Destination       at 0 range 40 .. 71;
      Source            at 0 range 72 .. 103;
      Flags             at 0 range 104 .. 119;
      Opcode            at 0 range 120 .. 127;
      Ext_Header        at 0 range 128 .. 135;
   end record;

  for VN_Header'Alignment use 2;
  -- for VN_Header'Bit_Order use High_Order_First;

   type VN_Payload_Byte_Array is array (1 .. MAX_PAYLOAD_SIZE)
                                    of Interfaces.Unsigned_8;

   type VN_Message_Basic is
      record
         Header   : VN_Header;
         Payload  : VN_Payload_Byte_Array;
         Checksum : VN_Checksum;
      end record;

   for VN_Message_Basic use record
      Header        at 0 range 0 .. (HEADER_SIZE * 8 - 1);
      Payload       at 0 range (HEADER_SIZE * 8) ..
                               (HEADER_SIZE * 8 + MAX_PAYLOAD_SIZE * 8 - 1);
      Checksum      at 0 range (HEADER_SIZE + MAX_PAYLOAD_SIZE) * 8 .. 
                               (HEADER_SIZE + MAX_PAYLOAD_SIZE + CHECKSUM_SIZE) * 8 - 1;
   end record;
   
   for VN_Message_Basic'Alignment use 2;


   type VN_Message_Byte_Array is array (1 .. VN_Message_Basic'Size / 8) --VN_Message_Basic'Size is in bits
                                          of Interfaces.Unsigned_8;
   for VN_Message_Byte_Array'Alignment use 2;

   type Word_Array_Type is array(1 .. (VN_Message_Basic'Size / 16 + 1)) of Interfaces.Unsigned_16;
   for Word_Array_Type'Alignment use 2;

   VN_CHECKSUM_ERROR : exception;

   procedure Serialize(Message : in VN_Message_Basic;
                       buffer : out VN_Message_Byte_Array);

   procedure Deserialize(Message : out VN_Message_Basic;
                         buffer : in VN_Message_Byte_Array);

   procedure Update_Checksum(Message: in out VN_Message_Basic);

end VN.Message;
