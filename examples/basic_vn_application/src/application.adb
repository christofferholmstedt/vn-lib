with Ada.Real_Time;
with Ada.Text_IO;
with Global_Settings;
with VN.Application_Information;
with VN.Message.Factory;
with VN.Message.Local_Hello;

package body Application is

   task body VN_Application is
      use Ada.Real_Time;
      use VN;
      use VN.Message.Local_Hello;

      i: Integer := 1;

      App_Info: VN.Application_Information.VN_Application_Information;

      Basic_Msg: VN.Message.VN_Message_Basic;
      Local_Hello_Msg: VN.Message.Local_Hello.VN_Message_Local_Hello;

      Send_Status: VN.Send_Status;

      Next_Period : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span :=
                           Ada.Real_Time.Microseconds(Cycle_Time);
   begin
      App_Info.Component_Type := VN.Message.Other;
      -- App_Info.CUUID := ???;

      Ada.Text_IO.Put_Line("Task type VN_Application - Start, ID: "
                              & Integer'Image(Task_ID));

      Global_Settings.Start_Time.Get(Next_Period);


      loop
         delay until Next_Period;
         ----------------------------

         if App_Info.Has_Logical_Address then
            null;
         else
            Ada.Text_IO.Put_Line("Logical address not found "
                                       & Integer'Image(Task_ID));

            -- Prepare message to be sent
            Basic_Msg := VN.Message.Factory.Create(VN.Message.Type_Local_Hello);
            To_Local_Hello(Basic_Msg, Local_Hello_Msg);
            App_Info.Get_Application_Information(Local_Hello_Msg);
            To_Basic(Local_Hello_Msg, Basic_Msg);

            -- Send message
            Global_Settings.Com_Application.Send(Basic_Msg, Send_Status);
         end if;

         ----------------------------
         Next_Period := Next_Period + Period;
         i := i + 1;
         exit when i = 6;
      end loop;
      Ada.Text_IO.Put_Line("Task type VN_Application - End, ID:"
                              & Integer'Image(Task_ID));
   end VN_Application;

   -- Start one instance of the SM-L
   App: VN_Application(20, 500000, 30, 3);

end Application;