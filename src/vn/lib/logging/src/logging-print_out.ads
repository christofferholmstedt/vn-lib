with VN.Message;

package Logging.Print_Out is

   type Print_Out_Logger is new Message_Logger with null record;

   procedure Log(This: in out Print_Out_Logger;
                 Message: out VN.Message.VN_Message_Basic);

end Logging.Print_Out;
