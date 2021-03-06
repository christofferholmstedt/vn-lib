with Global_Settings;
with Subnet_Manager_Local;
with Subnet_Manager_Local_H;
with Subnet_Manager_Local_K;
with Subnet_Manager_Local_X;
with Central_Addressing_Service;
with Lookup_Service;
with Application;
with App2;
with App_K;

procedure Boot_Up_Procedure is
begin
   null;
   Global_Settings.Com_Application.Init;
   Global_Settings.Com_CAS.Init;
   Global_Settings.Com_LS.Init;
   Global_Settings.Com_App2.Init;
   Global_Settings.Com_App_K.Init;
   Global_Settings.PO_Wrapper_To_SM_L.Init;
   Global_Settings.PO_Wrapper_SM_H_To_SM_X.Init;
   Global_Settings.PO_Wrapper_SM_K_To_SM_X.Init;

   Global_Settings.Com_SM_L.Add_Interface(Global_Settings.PO_Router'Access);
   Global_Settings.PO_Router.Add_Interface(Global_Settings.PO_Wrapper_To_Application'Access);
   Global_Settings.PO_Router.Add_Interface(Global_Settings.PO_Wrapper_To_CAS'Access);
   Global_Settings.PO_Router.Add_Interface(Global_Settings.PO_Wrapper_To_LS'Access);
   Global_Settings.PO_Router.Add_Interface(Global_Settings.PO_Wrapper_To_SM_X'Access);

   Global_Settings.Com_SM_x.Add_Interface(Global_Settings.PO_Router_SM_x'Access);
   Global_Settings.PO_Router_SM_X.Add_Interface(Global_Settings.PO_Wrapper_To_App2'Access);
   Global_Settings.PO_Router_SM_X.Add_Interface(Global_Settings.PO_Wrapper_To_SM_L'Access);
   Global_Settings.PO_Router_SM_X.Add_Interface(Global_Settings.PO_Wrapper_SM_X_To_SM_H'Access);
   Global_Settings.PO_Router_SM_X.Add_Interface(Global_Settings.PO_Wrapper_SM_X_To_SM_K'Access);

   Global_Settings.Com_SM_H.Add_Interface(Global_Settings.PO_Router_SM_H'Access);
   Global_Settings.PO_Router_SM_H.Add_Interface(Global_Settings.PO_Wrapper_SM_H_To_SM_X'Access);

   Global_Settings.Com_SM_K.Add_Interface(Global_Settings.PO_Router_SM_K'Access);
   Global_Settings.PO_Router_SM_K.Add_Interface(Global_Settings.PO_Wrapper_SM_K_To_SM_X'Access);
   Global_Settings.PO_Router_SM_K.Add_Interface(Global_Settings.PO_Wrapper_SM_K_To_App_K'Access);
end Boot_Up_Procedure;
