-- Copyright (c) 2014 All Rights Reserved
-- Author: Nils Brynedal Ignell
-- Date: 2014-XX-XX
-- Summary:
-- CUUID_Responder responds to the RequestCUUID message. Shall be used by all units (nodes or SM-CANs).
-- CUUID_Responder shall be activated once one has been assigned a CAN address.

with VN.Communication.CAN.Logic.Message_Utils;

package body VN.Communication.CAN.Logic.ComponentType_Responder is

   overriding procedure Update(this : in out ComponentType_Responder; msgIn : VN.Communication.CAN.CAN_Message_Logical; bMsgReceived : boolean;
                               msgOut : out VN.Communication.CAN.CAN_Message_Logical; bWillSend : out boolean) is
   begin
      case this.currentState is
         when Unactivated =>
            bWillSend := false;

         when Activated =>
            if bMsgReceived and then msgIn.isNormal and then msgIn.msgType = VN.Communication.CAN.Logic.DISCOVERY_REQUEST then

               VN.Communication.CAN.Logic.Message_Utils.ComponentTypeToMessage(msgOut, this.myCANAddress, 0, this.isSM_CAN); --ToDo: prio???
               bWillSend := true;
               this.currentState := Activated;
               VN.Communication.CAN.Logic.DebugOutput("Sent component type (node or SM-CAN) from CAN address " & this.myCANAddress'img, 5);
            else
               bWillSend := false;
            end if;
      end case;
   end Update;

   procedure Activate(this : in out ComponentType_Responder; theCUUID : VN.VN_CUUID; CANAddress : VN.Communication.CAN.CAN_Address_Sender; isSM_CAN : boolean) is
   begin
      if this.currentState = Unactivated then
         VN.Communication.CAN.Logic.DebugOutput("CUUID_Responder at address " & CANAddress'Img & " activated", 5);
         this.myCANAddress := CANAddress;
         this.currentState := Activated;
         this.myCUUID 	   := theCUUID;
         this.isSM_CAN     := isSM_CAN;
      end if;
   end Activate;
end VN.Communication.CAN.Logic.ComponentType_Responder;