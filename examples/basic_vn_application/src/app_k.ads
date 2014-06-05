with VN.Message;
with System;
with Ada.Text_IO;

package App_K is

   task type VN_Application(Pri : System.Priority;
                     Cycle_Time : Positive;
                     Task_ID : Positive;
                     Increment_By : Positive) is
      pragma Priority(Pri);
   end VN_Application;

end App_K;
