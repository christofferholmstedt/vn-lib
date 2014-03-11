package VN_Message is

   type VN_Header is private;
   type VN_Payload is mod 2 ** 16;
   type VN_Footer is private;

   type VN_Logical_Address is mod 2 ** 32;

   type VN_Version is mod 2 ** 8;
   type VN_Priority is mod 2 ** 8;
   type VN_Length is mod 2 ** 16;
   type VN_Flags is mod 2 ** 16;
   type VN_Opcode is mod 2 ** 8;

   type VN_Checksum is mod 2 ** 16;

   type Serializiation_Type is (TXT, XML);

   -- VN_Message
   type VN_Message is abstract tagged private;
   type VN_Message_Access is access all VN_Message'Class;

   -- VN_Version
   function Get_Version(Message: VN_Message'Class) return VN_Version;
   procedure Set_Version(Message: out VN_Message'Class; Version: VN_Version);

   -- VN_Checksum
   function Get_Checksum(Message: VN_Message'Class) return VN_Checksum;
   procedure Update_Checksum(Message: in out VN_Message'Class);

   -- VN_Payload
   function Get_Payload(Message: VN_Message'Class) return VN_Payload is abstract;
   procedure Set_Payload(Message: VN_Message'Class; Payload: VN_Payload) is abstract;

--   function Serialize_VN_Message(Message: in VN_Message'Class;
--                                 Output_Format: in Serializiation_Type)
--                              return Natural;
--
--   function Deserialize_VN_Message(Data: in Natural) -- TODO: How is Data represented? String?
--                                 return Natural;
--                                 -- return VN_Message'Class;

private
   type VN_Message is abstract tagged
      record
         Header   : VN_Header;
         Payload  : VN_Payload;
         Footer   : VN_Footer;
      end record;

   type VN_Header is
      record
         Version        : VN_Version:= 1;
         Priority       : VN_Priority;
         Payload_Length : VN_Length;
         Destination    : VN_Logical_Address;
         Source         : VN_Logical_Address;
         Flags          : VN_Flags := 0;
         Opcode         : VN_Opcode;
         Value          : Positive := 1;
         -- Extended Header not implemented.
      end record;

   type VN_Footer is
      record
         Checksum : VN_Checksum := 0;
      end record;

end VN_Message;
