with Ada.Real_Time;
with System;
with Logging.Print_Out;
with VN.Message.Factory;
with VN.Communication.PO;
with VN.Communication.PO_Wrapper;
with VN.Communication.PO_Routing;
-- with VN.Communication.Temp_Protocol_Routing;
with VN.Communication.Protocol_Routing;

package Global_Settings is

   -- Common start time for all applications.
   protected Start_time is
      procedure Get(Time: out Ada.Real_Time.Time);
   private
      pragma Priority(System.Priority'Last);
      Start: Ada.Real_Time.Time;
      First_Time: Boolean := True;
   end Start_Time;

   Logger: aliased Logging.Print_Out.Print_Out_Logger;

   CUUID_CAS   : aliased VN.VN_CUUID := (others => 11);
   CUUID_SM    : aliased VN.VN_CUUID := (others => 22);
   CUUID_LS    : aliased VN.VN_CUUID := (others => 33);
   CUUID_App   : aliased VN.VN_CUUID := (others => 44);
   CUUID_SM_X  : aliased VN.VN_CUUID := (others => 55);
   CUUID_App2  : aliased VN.VN_CUUID := (others => 66);
   CUUID_SM_H  : aliased VN.VN_CUUID := (others => 77);

   Cycle_Time_Applications : constant Positive := 2110000;
   Cycle_Time_SM_L         : constant Positive := 500000;

   -- Communication between Application, CAS, LS and SM-L
   PO_To_Application : aliased VN.Communication.PO.VN_PO;
   PO_To_CAS         : aliased VN.Communication.PO.VN_PO;
   PO_To_LS          : aliased VN.Communication.PO.VN_PO;
   PO_To_SM_X        : aliased VN.Communication.PO.VN_PO;
   PO_To_App2        : aliased VN.Communication.PO.VN_PO;
   PO_To_SM_H        : aliased VN.Communication.PO.VN_PO;

   -- Communication object for Application
   Com_Application   : VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_Application'Access,
                                                            CUUID_App'Access,
                                                            VN.Message.Other,
                                                            False);

   Com_CAS           : VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_CAS'Access,
                                                            CUUID_CAS'Access,
                                                            VN.Message.CAS,
                                                            False);

   Com_LS            : VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_LS'Access,
                                                            CUUID_LS'Access,
                                                            VN.Message.LS,
                                                            False);

   Com_App2            : VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_App2'Access,
                                                            CUUID_App2'Access,
                                                            VN.Message.Other,
                                                            False);

   -- Communication object for SM-L
   -- 1. Create a VN.Communication.Protocol_Routing.Protocol_Routing_Type
   --    for routing between protocols.
   Com_SM_L : VN.Communication.Protocol_Routing.Protocol_Routing_Type;
   Com_SM_X : VN.Communication.Protocol_Routing.Protocol_Routing_Type;
   Com_SM_H : VN.Communication.Protocol_Routing.Protocol_Routing_Type;

   -- 2. Create a VN.Communication.Protocol_Routing.Protocol_Routing_Type
   --    for routing within Protected Object Subnet (PO_Router)
   PO_Router: aliased VN.Communication.Protocol_Routing.Protocol_Routing_Type;
   PO_Router_SM_X: aliased VN.Communication.Protocol_Routing.Protocol_Routing_Type;
   PO_Router_SM_H: aliased VN.Communication.Protocol_Routing.Protocol_Routing_Type;

   -- 3. Create all needed PO_Wrappers for the SM-L
   PO_Wrapper_To_Application: aliased VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_Application'Access,
                                                            CUUID_SM'Access,
                                                            VN.Message.SM_L,
                                                            True);

   PO_Wrapper_To_CAS: aliased VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_CAS'Access,
                                                            CUUID_SM'Access,
                                                            VN.Message.SM_L,
                                                            True);

   PO_Wrapper_To_LS: aliased VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_LS'Access,
                                                            CUUID_SM'Access,
                                                            VN.Message.SM_L,
                                                            True);

   PO_Wrapper_To_SM_X: aliased VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_SM_X'Access,
                                                            CUUID_SM'Access,
                                                            VN.Message.SM_L,
                                                            True);

   PO_Wrapper_To_SM_L: aliased VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_SM_X'Access,
                                                            CUUID_SM_X'Access,
                                                            VN.Message.SM_x,
                                                            False);

   PO_Wrapper_To_App2: aliased VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_App2'Access,
                                                            CUUID_SM_x'Access,
                                                            VN.Message.SM_L,
                                                            True);
   -- 4. Add PO_Router to Protocol_Router (during run time, main.adb).
   -- 5. Add all PO_Wrappers to the PO_Router (during run time, main.adb).

   PO_Wrapper_SM_X_To_SM_H: aliased VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_SM_H'Access,
                                                            CUUID_SM_X'Access,
                                                            VN.Message.SM_L,
                                                            True);

   PO_Wrapper_SM_H_To_SM_X: aliased VN.Communication.PO_Wrapper.VN_PO_Wrapper(
                                                            PO_To_SM_H'Access,
                                                            CUUID_SM_H'Access,
                                                            VN.Message.SM_x,
                                                            False);

end Global_Settings;
