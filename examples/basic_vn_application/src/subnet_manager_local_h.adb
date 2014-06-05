with Ada.Real_Time;
with Global_Settings;
with VN;
with VN.Message;
with VN.SM_Application_Layer_Logic;

package body Subnet_Manager_Local_H is

   task body SM_L is
      use Ada.Real_Time;
      Counter_For_Testing: Integer := 1;

      Next_Period : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span :=
                           Ada.Real_Time.Microseconds(Cycle_Time);

      -------------------------------
      --- Subnet Manager Settings ---
      -------------------------------
      SM_Logic : VN.SM_Application_Layer_Logic.SM_Logic_Type(
                        Global_Settings.Com_SM_H'Access,
                        Global_Settings.CUUID_SM_H,
                        "jojo",
                        Global_Settings.Logger);

   begin

      Global_Settings.Start_Time.Get(Next_Period);
      VN.Text_IO.Put_Line(SM_Logic.Debug_ID_String & "STAT: Starts.");

      loop
         delay until Next_Period;

         -- Receive messages
         SM_Logic.Receive_Loop;

         -- Send messages
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

end Subnet_Manager_Local_H;
