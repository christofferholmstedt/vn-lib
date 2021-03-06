-- Copyright (c) 2014 All Rights Reserved
-- Author: Nils Brynedal Ignell
-- Date: 2014-XX-XX
-- Summary:
-- ComponentType_Responder responds to the DiscoveryRequest message. Shall be used by all units (nodes or SM-CANs).
-- ComponentType_Responder shall be activated once one has been assigned a CAN address.

pragma Profile (Ravenscar);


with VN.Communication.CAN.CAN_Filtering;
with VN.Communication.CAN.Logic;

package VN.Communication.CAN.Logic.ComponentType_Responder is

   type ComponentType_Responder is
     new VN.Communication.CAN.Logic.Duty with private;

   type ComponentType_Responder_ptr is access all ComponentType_Responder'Class;

   overriding procedure Update(this : in out ComponentType_Responder; msgIn : VN.Communication.CAN.CAN_Message_Logical; bMsgReceived : boolean;
                               msgOut : out VN.Communication.CAN.CAN_Message_Logical; bWillSend : out boolean);

   procedure Activate(this : in out ComponentType_Responder; theCUUID : VN.VN_CUUID;
                      CANAddress : VN.Communication.CAN.CAN_Address_Sender; isSM_CAN : boolean);

private

   type ComponentType_Responder_State is (Unactivated, Activated);

   type ComponentType_Responder is
     new VN.Communication.CAN.Logic.Duty with
      record
         currentState 	: ComponentType_Responder_State := Unactivated;
         myCUUID 	: VN.VN_CUUID;
         myCANAddress   : VN.Communication.CAN.CAN_Address_Sender;
         isSM_CAN	: boolean;
      end record;
end VN.Communication.CAN.Logic.ComponentType_Responder;
