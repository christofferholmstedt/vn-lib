/*******************************************************************************
 *
 * This code is based on code from:
 * SmartFusion2 MSSCAN example demonstrating the Data transmission and Reception
 * using MSSCAN (FullCAN) by Microsemi SoC Products Group.
 *
 * No rights reserved regarding this code file.
 */

 /*----------------------------------------------------------------------------
 * include files
 */
#include "mss_can.h"
//#include "drivers/mss_can/mss_can.h"
#include<stdio.h>
#include<stdlib.h>


/*------------------------------------------------------------------------------
  Static Variables.
 */
CAN_FILTEROBJECT pFilter;
CAN_MSGOBJECT pMsg;
CAN_MSGOBJECT rx_buf;
CAN_RXMSGOBJECT rx_msg;

/*------------------------------------------------------------------------------
  Macros.
 */
#define   SYSTEM_CLOCK        32000000
#define   ENTER               0x0D


typedef struct C_CAN_Msg_T {
   uint32_t ID;
   uint32_t data_length;
   int8_t DATA[8];

} C_CAN_Message_Type;


int test() {return 42;}

int Send_CAN_Message(C_CAN_Message_Type *msg) {
    int i;

    pMsg.ID  = msg->ID;
    pMsg.DLC = msg->data_length;

    for(i=0; i < msg->data_length-1; i++) {
          pMsg.DATA[i] = msg->DATA[i];
    }

    pMsg.NA0 = 1; // ToDo. ???????????? "[0..15] Message Valid Bit, 0 == Not valid."
    pMsg.IDE = 1; //use extended message IDs
    pMsg.RTR = 1; //regular message (not remote frame)
    pMsg.NA1 = 0; //padding?

    return MSS_CAN_send_message_n(&g_can0, 6, &pMsg);
}

int Receive_CAN_Message(C_CAN_Message_Type *msg) { //returns 1 if message was received, 0 otherwise

    if(CAN_VALID_MSG == MSS_CAN_get_message_n(&g_can0, 0, &rx_buf)) {
        int i;

        msg->ID = pMsg.ID;
        msg->data_length = pMsg.DLC;

        for(i=0; i < msg->data_length-1; i++) {
            msg->DATA[i] = pMsg.DATA[i];
        }

        return 1;
    } else {
        return 0;
    }
}

void Test_Send() {
    CAN_MSGOBJECT pMsg;
    pMsg.ID=0x20;
    pMsg.DATALOW = 0x11111111;
    pMsg.DATAHIGH = 0x22222222;
    pMsg.NA0 = 1;
    pMsg.DLC = 4;
    pMsg.IDE = 1;
    pMsg.RTR = 0;
    pMsg.NA1 = 0; //???

    MSS_CAN_send_message_n(&g_can0, 0, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 1, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 2, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 3, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 4, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 5, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 6, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 7, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 8, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 9, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 10, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 11, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 12, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 13, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 14, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 15, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 16, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 17, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 18, &pMsg);
    MSS_CAN_send_message_n(&g_can0, 19, &pMsg);
}

int Init_CAN() {

    int ret;

    MSS_CAN_init(&g_can0,
                 CAN_SET_BITRATE(24)|CAN_SET_TSEG1(12)|CAN_SET_TSEG2(1), //CAN_SPEED_32M_50K, //CAN_SPEED_32M_1M,
                 (PCAN_CONFIG_REG)0,
                 6,
                 6);

    MSS_CAN_set_mode(&g_can0, CANOP_MODE_NORMAL);

    MSS_CAN_start(&g_can0);

    /* Configure for receive */
    /* Initialize the rx mailbox */
    rx_msg.ID = 0x200;
    rx_msg.DATAHIGH = 0u;
    rx_msg.DATALOW = 0u;
    rx_msg.RXB.DLC = 8u;
    rx_msg.RXB.IDE = 1;
    rx_msg.RXB.RTR = 0;

   // rx_msg.AMR.L = 0x00000000; //0xFFFFFFFF;
    rx_msg.AMR.RTR = 0;
    rx_msg.AMR.IDE = 1;
    rx_msg.AMR.ID  = 0;

    rx_msg.ACR.RTR = 0;
    rx_msg.ACR.IDE = 1;
    rx_msg.ACR.ID  = 0;
    //rx_msg.ACR.L = 0x00000000;
    rx_msg.ACR_D = 0x00000000;
    rx_msg.AMR_D = 0xFFFFFFFF;

    ret = MSS_CAN_config_buffer_n(&g_can0, 0, &rx_msg);

    MSS_CAN_set_int_ebl(&g_can0, CAN_INT_RX_MSG);
    MSS_CAN_set_int_ebl(&g_can0, CAN_INT_TX_MSG);

    return ret;
}

