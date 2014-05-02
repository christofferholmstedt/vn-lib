-- Copyright (c) 2014 All Rights Reserved
-- Author: Nils Brynedal Ignell
-- Date: 2014-XX-XX
-- Summary:
-- CAN_Address_Reception will be activated by an SM-CAN if it is assigned as
-- slave. CAN_Address_Reception will remain unactivated if the SM-CAN wins the
-- SM-CAN master negotiation process.
-- CAN_Address_Reception will be assigned a CAN address from the SM-CAN master
-- on the CAN network.

with VN.Communication.CAN.Logic.Message_Utils;

package body VN.Communication.CAN.Logic.CAN_Address_Reception is

   overriding procedure Update(this : in out CAN_Assignment_Node; msgIn : VN.Communication.CAN.CAN_Message_Logical; bMsgReceived : boolean;
                               msgOut : out VN.Communication.CAN.CAN_Message_Logical; bWillSend : out boolean) is
      msgUCID : VN.Communication.CAN.UCID;
      msgCANAddr : VN.Communication.CAN.CAN_Address_Sender;

      use Ada.Real_Time;

   begin
      case this.currentState is
         when Unactivated =>
            bWillSend:=false;

         when Start =>

            if bMsgReceived then
               if msgIn.isNormal then

                  VN.Communication.CAN.Logic.Message_Utils.RequestCANAddressToMessage(msgOut, this.myUCID, false);
                  bWillSend:= true;
                  this.currentState := Started;
                  VN.Communication.CAN.Logic.DebugOutput(Integer(this.myUCID)'Img & ": Requested CAN address", 4);

                 this.timer := Ada.Real_Time.Clock;

                  return;
               end if;
            end if;
            bWillSend:=false;

         when Started =>

            if bMsgReceived then

               if msgIn.isNormal and then msgIn.msgType = VN.Communication.CAN.Logic.ASSIGN_CAN_ADDRESS then
                  VN.Communication.CAN.Logic.Message_Utils.AssignCANAddressFromMessage(msgIn, msgUCID, msgCANAddr);

                  if msgUCID = this.myUCID then
                     this.myCANAddress := msgCANAddr;
                     this.currentState := Assigned;

                     VN.Communication.CAN.Logic.DebugOutput(Integer(this.myUCID)'Img & ": Was assigned CAN address " & this.myCANAddress'img, 4);
                     bWillSend:=false;
                     return;
                  else
                     VN.Communication.CAN.Logic.DebugOutput(this.myUCID'Img & ": message NOT for me, msgUCID=" & msgUCID'Img, 4);
                  end if;
               end if;
            end if;

            if Ada.Real_Time.Clock - this.timer > TIME_TO_WAIT_FOR_ADDRESS then
               VN.Communication.CAN.Logic.Message_Utils.RequestCANAddressToMessage(msgOut, this.myUCID, false);
               bWillSend:= true;
               VN.Communication.CAN.Logic.DebugOutput(Integer(this.myUCID)'Img & ": Requested CAN address", 4);
               this.timer := Ada.Real_Time.Clock;
            end if;
            bWillSend := false;

         when Assigned =>
            bWillSend:=false;
      end case;
   end Update;

   procedure Activate(this : in out CAN_Assignment_Node) is
   begin
      if this.currentState = Unactivated then
         DebugOutput("CAN address receiver activated", 5);
         this.currentState := Start;
      end if;
   end Activate;

   procedure Address(this : in out CAN_Assignment_Node; address : out CAN_Address_Sender; isAssigned : out boolean) is
   begin
      if this.currentState = Assigned then
         address := this.myCANAddress;
         isAssigned := true;
      else
         isAssigned := false;
      end if;
   end Address;

end VN.Communication.CAN.Logic.CAN_Address_Reception;

