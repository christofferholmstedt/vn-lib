with Ada.Real_Time;
with Buffers;
with Global_Settings;
with VN.Application_Information;
with VN.SM_Application_Layer_Logic;
with VN.Message.Factory;
with VN.Message.Local_Hello;
with VN.Message.Assign_Address;
with VN.Message.Assign_Address_Block;
with VN.Message.Request_Address_Block;
with VN.Message.Distribute_Route;
with Interfaces;

package body Subnet_Manager_Local is

   task body SM_L is
      use Ada.Real_Time;
      use VN;
      use VN.Message;
      use VN.Message.Local_Hello;
      use VN.Message.Assign_Address;
      use VN.Message.Assign_Address_Block;
      use VN.Message.Request_Address_Block;
      use VN.Message.Request_LS_Probe;
      use VN.Message.Distribute_Route;
      use Interfaces;
      Counter_For_Testing: Integer := 1;

      Next_Period : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span :=
                           Ada.Real_Time.Microseconds(Cycle_Time);

      SM_Logic : VN.SM_Application_Layer_Logic.SM_Logic_Type :=
                       (Com => Global_Settings.Com_SM_L'Access,
                        CUUID => Global_Settings.CUUID_SM,
                        Debug_ID_String => "SM_L ",
                        Logical_Address => 16#0000_0000#,
                        Component_Type => VN.Message.SM_L,
                        Logger => Global_Settings.Logger);

   begin

      Global_Settings.Start_Time.Get(Next_Period);
      VN.Text_IO.Put_Line(SM_Logic.Debug_ID_String & "STAT: Starts.");

      ----------------------------
      loop
         delay until Next_Period;

         ----------------------------
         -- Receive loop
         ----------------------------
         SM_Logic.Receive_Loop;

         ----------------------------
         -- Send loop
         ----------------------------
         SM_Logic.Send_Loop;

         Next_Period := Next_Period + Period;
         Counter_For_Testing := Counter_For_Testing + 1;
         exit when Counter_For_Testing = 60;
      end loop;
      ----------------------------

      VN.Text_IO.Put_Line(SM_Logic.Debug_ID_String & "STAT: Stop. Logical Address: " &
                                 SM_Logic.Logical_Address'Img);

   end SM_L;

   -- Start one instance of the SM-L
   SM_L1: SM_L(20, Global_Settings.Cycle_Time_SM_L, 80, 3);

end Subnet_Manager_Local;
