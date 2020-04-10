
/******************************************************************************/
/******************************************************************************/
/** 	 				                                                     **/
/**                           MOVIE SYNC APP                                 **/
/**                                                                          **/
/******************************************************************************/
/******************************************************************************/
/*
 * TCPEchoClient example from Digilent was used as reference
 *
 */

#include "PmodWIFI.h"
#include "xil_cache.h"
#include <math.h>
#include "platform.h"
#include "xil_printf.h"

#ifdef __MICROBLAZE__
#define PMODWIFI_VEC_ID XPAR_INTC_0_PMODWIFI_0_VEC_ID
#else
#define PMODWIFI_VEC_ID XPAR_FABRIC_PMODWIFI_0_WF_INTERRUPT_INTR
#endif

#define FILTER_BASE XPAR_FILTER_0_CTRL_BASEADDR
#define WHICH_FILTER_OFFSET 0x0C
#define AVG_BASE XPAR_AVERAGER_0_S00_AXI_BASEADDR

/************************************************************************/
/*                                                                      */
/*                    SET HUE BRIDGE FOR NETWORK                        */
/*                                                                      */
/************************************************************************/

const char* szIPServer = "192.168.0.11"; // Hue Bridge IP
uint16_t portServer = 80; // HTTP

// WLAN
const char* szSsid = "********";
const char* szPassPhrase = "********";
#define WiFiConnectMacro() deIPcK.wfConnect(szSsid, szPassPhrase, &status)

/************************************************************************/
/************************************************************************/

typedef enum {
    NONE = 0,
    CONNECT,
    TCPCONNECT,
    WRITE,
    CLOSE,
    GETCOLOR,
    DONE,
} STATE;

STATE state = CONNECT;

unsigned tStart = 0;
unsigned tRefresh = 0;
unsigned tWait = 1000;

TCPSocket tcpSocket;

char rgbWriteStream1[] = "PUT /api/849-c5I-gcMl0vyXajQe-XbO7z1iP4FfvodLJi0t/lights/4/state HTTP/1.1\nHost: 192.168.0.24\nAccept: text/html, */*\nAccept-Language: en-us\nUser-Agent: Mozilla/4.0 \nContent-Type: text/plain\nContent-Length: 30\n\n {\"xy\":[0.500,0.500],\"bri\":200}"; //
char rgbWriteStream2[] = "PUT /api/849-c5I-gcMl0vyXajQe-XbO7z1iP4FfvodLJi0t/lights/5/state HTTP/1.1\nHost: 192.168.0.24\nAccept: text/html, */*\nAccept-Language: en-us\nUser-Agent: Mozilla/4.0 \nContent-Type: text/plain\nContent-Length: 30\n\n {\"xy\":[0.700,0.700]}"; //
byte rgbRead[] = "PUT /api/849-c5I-gcMl0vyXajQe-XbO7z1iP4FfvodLJi0t/lights/4/state HTTP/1.1\nHost: 192.168.0.24\nAccept: text/html, */*\nAccept-Language: en-us\nUser-Agent: Mozilla/4.0 \nContent-Type: text/plain\nContent-Length: 30\n\n {\"xy\":[0.700,0.700]}"; //

byte rgbWriteStream_begin[] = "PUT /api/849-c5I-gcMl0vyXajQe-XbO7z1iP4FfvodLJi0t/lights/4/state HTTP/1.1\nHost: 192.168.0.24\nAccept: text/html, */*\nAccept-Language: en-us\nUser-Agent: Mozilla/4.0 \nContent-Type: text/plain\nContent-Length: 35\n\n {\"xy\":["; //
byte rgbWriteStream_begin2[] = "PUT /api/849-c5I-gcMl0vyXajQe-XbO7z1iP4FfvodLJi0t/lights/5/state HTTP/1.1\nHost: 192.168.0.24\nAccept: text/html, */*\nAccept-Language: en-us\nUser-Agent: Mozilla/4.0 \nContent-Type: text/plain\nContent-Length: 35\n\n {\"xy\":["; //

int cbWriteStream = sizeof(rgbWriteStream1);

void MovieSyncInitialize();
void Run();
void getRGBtoXY(float R, float G, float B, float* xy);
void num2string(float v, char* buffer);
char* itoa(int i, char b[]);

int main(void)
{
    Xil_ICacheEnable();
    Xil_DCacheEnable();
    init_platform();

    xil_printf("\r===============================\r");
    xil_printf("===========  MovieSync  ===========\r");
    xil_printf("===============================\r");
    xil_printf("\n\nConnecting to network...\r\n");

    MovieSyncInitialize();
    Run();

    cleanup_platform();
    return 0;
}

void MovieSyncInitialize()
{
    setPmodWifiAddresses(
        XPAR_PMODWIFI_0_AXI_LITE_SPI_BASEADDR,
        XPAR_PMODWIFI_0_AXI_LITE_WFGPIO_BASEADDR,
        XPAR_PMODWIFI_0_AXI_LITE_WFCS_BASEADDR,
        XPAR_PMODWIFI_0_S_AXI_TIMER_BASEADDR);
    setPmodWifiIntVector(PMODWIFI_VEC_ID);
}

void Run()
{
    bool on = false;
    volatile int* which_filter = (int*)(XPAR_FILTER_0_CTRL_BASEADDR + WHICH_FILTER_OFFSET);
    volatile int* sw_state = (int*)XPAR_AXI_GPIO_0_BASEADDR;
    volatile unsigned int* avg_color = (unsigned int*)(XPAR_AVERAGER_0_S00_AXI_BASEADDR);
    int avg, R, G, B, Y;
    char bri_buffer[4];

    while (1) {
        switch (state) {
        case CONNECT:
            IPSTATUS status;
            if (deIPcK.wfConnect(szSsid, szPassPhrase, &status)) {
                xil_printf("WiFi connected\r\n");
                deIPcK.begin();
                state = TCPCONNECT;
            }
            else if (IsIPStatusAnError(status)) {
                xil_printf("Unable to connect, status: %d\r\nTrying again...\r\n", status);
                deIPcK.end();
                deIPcK.wfDisconnect();
                state = CONNECT;
            }
            tStart = (unsigned)SYSGetMilliSecond();
            break;

        case TCPCONNECT:
            if (deIPcK.tcpConnect(szIPServer, portServer, tcpSocket)) {
                xil_printf("Refresh rate: %d milliseconds", ((unsigned)SYSGetMilliSecond() - tRefresh));
                tRefresh = (unsigned)SYSGetMilliSecond();
                state = WRITE;
            }
            break;

        // Write out the strings
        case WRITE:
            if (tcpSocket.isEstablished()) {
                if (on) {
                    tcpSocket.writeStream((uint8_t*)rgbWriteStream1, cbWriteStream);
                    on = false;
                }
                else {
                    tcpSocket.writeStream((uint8_t*)rgbWriteStream2, cbWriteStream);
                    on = true;
                }
                state = CLOSE;
            }
            break;

        case CLOSE:
            tcpSocket.close();
            state = GETCOLOR;
            break;

        case GETCOLOR:

            *which_filter = *sw_state & 15;
            avg = *avg_color;
            R = (avg >> 16) & 0x00FF;
            G = (avg >> 8) & 0x00FF;
            B = (avg >> 0) & 0x00FF;
            //xil_printf("Average color:\n");
            //xil_printf("\tR = 0x%0x;  ", R);
            //xil_printf("\tG = 0x%0x;  ", G);
            //xil_printf("\tB = 0x%0x\n", B);
            //xil_printf("\n");

            // Transform to xy color
            float xy[2];
            getRGBtoXY(R, G, B, xy);

            if (*sw_state > 15) {
                Y = (R + R + R + B + G + G + G + G) >> 1;
            }
            else {
                Y = (R + R + R + B + G + G + G + G) >> 2;
            }

            itoa(Y, bri_buffer);

            xil_printf(" \t\t bri: %s \n", bri_buffer);
            char xy_str[250];
            char xy_str2[242];
            //sprintf(rgbWriteStream1, "[%1.3f,%1.3f]}", xy[0], xy[1]);

            char buffer_x[5];
            char buffer_y[5];

            // First light
            num2string(xy[0], buffer_x);
            num2string(xy[1], buffer_y);
            strcpy(xy_str, (char*)rgbWriteStream_begin2);
            strcat(xy_str, buffer_x);
            strcat(xy_str, ",");
            strcat(xy_str, buffer_y);
            strcat(xy_str, "], \"bri\":");
            strcat(xy_str, bri_buffer);
            strcat(xy_str, "}\0000");

            // Second light
            strcpy(xy_str2, (char*)rgbWriteStream_begin);
            strcat(xy_str2, buffer_x);
            strcat(xy_str2, ",");
            strcat(xy_str2, buffer_y);
            strcat(xy_str2, "]}\0000");

            strcpy(rgbWriteStream1, xy_str);
            strcpy(rgbWriteStream2, xy_str2);
            //xil_printf("\n string to send:\n %s", rgbWriteStream1);

            state = TCPCONNECT;
            break;

        case DONE:
            break;
        default:
            break;
        }

        DEIPcK::periodicTasks();
    }
}

// Transform from RGB to XY color format
void getRGBtoXY(float R, float G, float B, float* xy)
{
    // For the hue bulb the corners of the triangle are:
    // -Red: 0.675, 0.322
    // -Green: 0.4091, 0.518
    // -Blue: 0.167, 0.04
    double normalizedToOne[3];
    float cred, cgreen, cblue;
    cred = R;
    cgreen = G;
    cblue = B;
    normalizedToOne[0] = (cred / 255);
    normalizedToOne[1] = (cgreen / 255);
    normalizedToOne[2] = (cblue / 255);
    float red, green, blue;

    // Make red more vivid
    if (normalizedToOne[0] > 0.04045) {
        red = (float)std::pow((normalizedToOne[0] + 0.055) / (1.0 + 0.055), 2.4);
    }
    else {
        red = (float)(normalizedToOne[0] / 12.92);
    }

    // Make green more vivid
    if (normalizedToOne[1] > 0.04045) {
        green = (float)std::pow((normalizedToOne[1] + 0.055) / (1.0 + 0.055), 2.4);
    }
    else {
        green = (float)(normalizedToOne[1] / 12.92);
    }

    // Make blue more vivid
    if (normalizedToOne[2] > 0.04045) {
        blue = (float)std::pow((normalizedToOne[2] + 0.055) / (1.0 + 0.055), 2.4);
    }
    else {
        blue = (float)(normalizedToOne[2] / 12.92);
    }

    float X = (float)(red * 0.649926 + green * 0.103455 + blue * 0.197109);
    float Y = (float)(red * 0.234327 + green * 0.743075 + blue * 0.022598);
    float Z = (float)(red * 0.0000000 + green * 0.053077 + blue * 1.035763);

    float x = X / (X + Y + Z);
    float y = Y / (X + Y + Z);

    xy[0] = x;
    xy[1] = y;
}

// For rational numbers
void num2string(float v, char* buffer)
{

    buffer[0] = '0';
    buffer[1] = '.';
    int nI = 2;

    if (v) {
        static float pMods[] = { 10, 100, 1000 };
        for (int i = 0; i < 3; i++) {
            int d = v * pMods[i];
            buffer[nI++] = '0' + d;
            v = v - d / pMods[i];
        }
    }
    else
        buffer[nI++] = '0';

    buffer[nI] = 0;
}

// For integers
char* itoa(int i, char b[])
{
    char const digit[] = "0123456789";
    char* p = b;
    if (i < 0) {
        *p++ = '-';
        i *= -1;
    }
    int shifter = i;
    do { //Move to where representation ends
        ++p;
        shifter = shifter / 10;
    } while (shifter);
    *p = '\0';
    do { //Move back, inserting digits as u go
        *--p = digit[i % 10];
        i = i / 10;
    } while (i);
    return b;
}
