#ifdef __cplusplus
extern "C" {
#endif
#include <starlet.h>
#include <descrip.h>
#include <prvdef.h>
#include <dvidef.h>
#include <uaidef.h>
#include <ssdef.h>
#include <stsdef.h>
#include <devdef.h>
#include <ttcdef.h>
#include <ucbdef.h>
#include <dcdef.h>
#include <dvsdef.h>
  
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

typedef  struct {short   buflen,          /* Length of output buffer */
                         itmcode;         /* Item code */
                 void    *buffer;         /* Buffer address */
                 void    *retlen;         /* Return length address */
               } ITMLST;

typedef struct {char  *ItemName;         /* Name of the item we're getting */
                unsigned short *ReturnLength; /* Pointer to the return */
                                              /* buffer length */
                void  *ReturnBuffer;     /* generic pointer to the returned */
                                         /* data */
                int   ReturnType;        /* The type of data in the return */
                                         /* buffer */
                int   ItemListEntry;     /* Index of the entry in the item */
                                         /* list we passed to GETDVI */
              } FetchedItem; /* Use this keep track of the items in the */
                             /* 'grab everything' GETDVI call */ 

#define dev_bit_test(a, b, c) \
{ \
    if (c && DEV$M_##b) \
    hv_store(a, #b, strlen(#b), &sv_yes, 0); \
    else \
    hv_store(a, #b, strlen(#b), &sv_no, 0);}   

#define ucb_bit_test(a, b, c) \
{ \
    if (c && UCB$M_##b) \
    hv_store(a, #b, strlen(#b), &sv_yes, 0); \
    else \
    hv_store(a, #b, strlen(#b), &sv_no, 0);}   

#define ttc_bit_test(a, b, c) \
{ \
    if (c && TTC$M_##b) \
    hv_store(a, #b, strlen(#b), &sv_yes, 0); \
    else \
    hv_store(a, #b, strlen(#b), &sv_no, 0);}   

#define DVI_ENT(a, b, c) {#a, DVI$_##a, b, c}
#define DC_ENT(a) {#a, DC$_##a}
#define DT_ENT(a) {#a, DT$_##a}

/* Macro to expand out entries for generic_bitmap_encode */
#define BME_D(a) { if (!strncmp(FlagName, #a, FlagLen)) { \
                       EncodedValue = EncodedValue | DVI$M_##a; \
                       break; \
                     } \
                 }

#define IS_STRING 1
#define IS_LONGWORD 2
#define IS_QUADWORD 3
#define IS_WORD 4
#define IS_BYTE 5
#define IS_VMSDATE 6
#define IS_BITMAP 7   /* Each bit in the return value indicates something */
#define IS_ENUM 8     /* Each returned value has a name, and we ought to */
                      /* return the name instead of the value */

#define FOR_DISK     (1<<0)
#define FOR_TAPE     (1<<1)
#define FOR_SCOM     (1<<2)
#define FOR_CARD     (1<<3)
#define FOR_TERM     (1<<4)
#define FOR_LP       (1<<5)
#define FOR_REALTIME (1<<6)
#define FOR_MAILBOX  (1<<7)
#define FOR_MISC     (1<<8)
#define FOR_STORAGE  (FOR_DISK | FOR_TAPE)
#define FOR_ALL      (FOR_DISK | FOR_TAPE | FOR_SCOM | FOR_CARD | FOR_TERM \
                      | FOR_LP | FOR_REALTIME | FOR_MAILBOX | FOR_MISC)

struct DevClassID {
  char *DevClassName;
  int  DevClassValue;
};

/* These were all hand-generated (with help from emacs' replace-regex) */
struct DevClassID DevClassList[] =
{
  DC_ENT(DISK),
  DC_ENT(TAPE),
  DC_ENT(SCOM),
  DC_ENT(CARD),
  DC_ENT(TERM),
  DC_ENT(LP),
  DC_ENT(WORKSTATION),
  DC_ENT(REALTIME),
  DC_ENT(DECVOICE),
  DC_ENT(AUDIO),
  DC_ENT(VIDEO),
  DC_ENT(BUS),
  DC_ENT(MAILBOX),
  DC_ENT(REMCSL_STORAGE),
  DC_ENT(MISC),
  {NULL, 0}
};

struct DevTypeID {
  char *DevTypeName;
  int  DevTypeValue;
};

/* These were all hand-generated (with help from emacs' replace-regex) */
struct DevTypeID DevTypeList[] =
{
  DT_ENT(RK06),
  DT_ENT(RK07),
  DT_ENT(RP04),
  DT_ENT(RP05),
  DT_ENT(RP06),
  DT_ENT(RM03),
  DT_ENT(RP07),
  DT_ENT(RP07HT),
  DT_ENT(RL01),
  DT_ENT(RL02),
  DT_ENT(RX02),
  DT_ENT(RX04),
  DT_ENT(RM80),
  DT_ENT(TU58),
  DT_ENT(RM05),
  DT_ENT(RX01),
  DT_ENT(ML11),
  DT_ENT(RB02),
  DT_ENT(RB80),
  DT_ENT(RA80),
  DT_ENT(RA81),
  DT_ENT(RA60),
  DT_ENT(RZ01),
  DT_ENT(RC25),
  DT_ENT(RZF01),
  DT_ENT(RCF25),
  DT_ENT(RD51),
  DT_ENT(RX50),
  DT_ENT(RD52),
  DT_ENT(RD53),
  DT_ENT(RD26),
  DT_ENT(RA82),
  DT_ENT(RD31),
  DT_ENT(RD54),
  DT_ENT(CRX50),
  DT_ENT(RRD50),
  DT_ENT(GENERIC_DU),
  DT_ENT(RX33),
  DT_ENT(RX18),
  DT_ENT(RA70),
  DT_ENT(RA90),
  DT_ENT(RD32),
  DT_ENT(DISK9),
  DT_ENT(RX35),
  DT_ENT(RF30),
  DT_ENT(RF70),
  DT_ENT(RF71),
  DT_ENT(RD33),
  DT_ENT(ESE20),
  DT_ENT(TU56),
  DT_ENT(RZ22),
  DT_ENT(RZ23),
  DT_ENT(RZ24),
  DT_ENT(RZ55),
  DT_ENT(RRD40S),
  DT_ENT(RRD40),
  DT_ENT(GENERIC_DK),
  DT_ENT(RX23),
  DT_ENT(RF31),
  DT_ENT(RF72),
  DT_ENT(RAM_DISK),
  DT_ENT(RZ25),
  DT_ENT(RZ56),
  DT_ENT(RZ57),
  DT_ENT(RX23S),
  DT_ENT(RX33S),
  DT_ENT(RA92),
  DT_ENT(SSTRIPE),
  DT_ENT(RZ23L),
  DT_ENT(RX26),
  DT_ENT(RZ57I),
  DT_ENT(RZ31),
  DT_ENT(RZ58),
  DT_ENT(SCSI_MO),
  DT_ENT(RWZ01),
  DT_ENT(RRD42),
  DT_ENT(CD_LOADER_1),
  DT_ENT(ESE25),
  DT_ENT(RFH31),
  DT_ENT(RFH72),
  DT_ENT(RF73),
  DT_ENT(RFH73),
  DT_ENT(RA72),
  DT_ENT(RA71),
  DT_ENT(RAH72),
  DT_ENT(RF32),
  DT_ENT(RF35),
  DT_ENT(RFH32),
  DT_ENT(RFH35),
  DT_ENT(RFF31),
  DT_ENT(RF31F),
  DT_ENT(RZ72),
  DT_ENT(RZ73),
  DT_ENT(RZ35),
  DT_ENT(RZ24L),
  DT_ENT(RZ25L),
  DT_ENT(RZ55L),
  DT_ENT(RZ56L),
  DT_ENT(RZ57L),
  DT_ENT(RA73),
  DT_ENT(RZ26),
  DT_ENT(RZ36),
  DT_ENT(RZ74),
  DT_ENT(ESE52),
  DT_ENT(ESE56),
  DT_ENT(ESE58),
  DT_ENT(RZ27),
  DT_ENT(RZ37),
  DT_ENT(RZ34L),
  DT_ENT(RZ35L),
  DT_ENT(RZ36L),
  DT_ENT(RZ38),
  DT_ENT(RZ75),
  DT_ENT(RZ59),
  DT_ENT(RZ13),
  DT_ENT(RZ14),
  DT_ENT(RZ15),
  DT_ENT(RZ16),
  DT_ENT(RZ17),
  DT_ENT(RZ18),
  DT_ENT(EZ51),
  DT_ENT(EZ52),
  DT_ENT(EZ53),
  DT_ENT(EZ54),
  DT_ENT(EZ58),
  DT_ENT(EF51),
  DT_ENT(EF52),
  DT_ENT(EF53),
  DT_ENT(EF54),
  DT_ENT(EF58),
  DT_ENT(RF36),
  DT_ENT(RF37),
  DT_ENT(RF74),
  DT_ENT(RF75),
  DT_ENT(HSZ10),
  DT_ENT(RZ28),
  DT_ENT(GENERIC_RX),
  DT_ENT(FD1),
  DT_ENT(FD2),
  DT_ENT(FD3),
  DT_ENT(FD4),
  DT_ENT(FD5),
  DT_ENT(FD6),
  DT_ENT(FD7),
  DT_ENT(FD8),
  DT_ENT(RZ29),
  DT_ENT(RZ26L),
  DT_ENT(RRD43),
  DT_ENT(RRD44),
  DT_ENT(HSX00),
  DT_ENT(HSX01),
  DT_ENT(RZ26B),
  DT_ENT(RZ27B),
  DT_ENT(RZ28B),
  DT_ENT(RZ29B),
  DT_ENT(RZ73B),
  DT_ENT(RZ74B),
  DT_ENT(RZ75B),
  DT_ENT(RWZ21),
  DT_ENT(RZ27L),
  DT_ENT(HSZ20),
  DT_ENT(HSZ40),
  DT_ENT(HSZ15),
  DT_ENT(RZ26M),
  DT_ENT(RW504),
  DT_ENT(RW510),
  DT_ENT(RW514),
  DT_ENT(RW516),
  DT_ENT(RWZ52),
  DT_ENT(RWZ53),
  DT_ENT(RWZ54),
  DT_ENT(RWZ31),
  DT_ENT(EZ31),
  DT_ENT(EZ32),
  DT_ENT(EZ33),
  DT_ENT(EZ34),
  DT_ENT(EZ35),
  DT_ENT(EZ31L),
  DT_ENT(EZ32L),
  DT_ENT(EZ33L),
  DT_ENT(RZ28L),
  DT_ENT(RWZ51),
  DT_ENT(EZ56R),
  DT_ENT(RAID0),
  DT_ENT(RAID5),
  DT_ENT(CONSOLE_CALLBACK),
  DT_ENT(FILES_64),
  DT_ENT(SWXCR),
  DT_ENT(TE16),
  DT_ENT(TU45),
  DT_ENT(TU77),
  DT_ENT(TS11),
  DT_ENT(TU78),
  DT_ENT(TA78),
  DT_ENT(TU80),
  DT_ENT(TU81),
  DT_ENT(TA81),
  DT_ENT(TK50),
  DT_ENT(MR_TU70),
  DT_ENT(MR_TU72),
  DT_ENT(MW_TSU05),
  DT_ENT(MW_TSV05),
  DT_ENT(TK70),
  DT_ENT(RV20),
  DT_ENT(RV80),
  DT_ENT(TK60),
  DT_ENT(GENERIC_TU),
  DT_ENT(TA79),
  DT_ENT(TAPE9),
  DT_ENT(TA90),
  DT_ENT(TF30),
  DT_ENT(TF85),
  DT_ENT(TF70),
  DT_ENT(RV60),
  DT_ENT(TZ30),
  DT_ENT(TM32),
  DT_ENT(TZX0),
  DT_ENT(TSZ05),
  DT_ENT(GENERIC_MK),
  DT_ENT(TK50S),
  DT_ENT(TZ30S),
  DT_ENT(TK70L),
  DT_ENT(TLZ04),
  DT_ENT(TZK10),
  DT_ENT(TSZ07),
  DT_ENT(TSZ08),
  DT_ENT(TA90E),
  DT_ENT(TZK11),
  DT_ENT(TZ85),
  DT_ENT(TZ86),
  DT_ENT(TZ87),
  DT_ENT(TZ857),
  DT_ENT(EXABYTE),
  DT_ENT(TAPE_LOADER_1),
  DT_ENT(TA91),
  DT_ENT(TLZ06),
  DT_ENT(TA85),
  DT_ENT(TKZ60),
  DT_ENT(TLZ6),
  DT_ENT(TZ867),
  DT_ENT(TZ877),
  DT_ENT(TAD85),
  DT_ENT(TF86),
  DT_ENT(TKZ09),
  DT_ENT(TA86),
  DT_ENT(TA87),
  DT_ENT(TD34),
  DT_ENT(TD44),
  DT_ENT(HST00),
  DT_ENT(HST01),
  DT_ENT(TLZ07),
  DT_ENT(TLZ7),
  DT_ENT(TZ88),
  DT_ENT(TZ885),
  DT_ENT(TZ887),
  DT_ENT(TZ89),
  DT_ENT(TZ895),
  DT_ENT(TZ897),
  DT_ENT(TZ875),
  DT_ENT(TL810),
  DT_ENT(TL820),
  DT_ENT(TZ865),
  DT_ENT(TTYUNKN),
  DT_ENT(VT05),
  DT_ENT(FT1),
  DT_ENT(FT2),
  DT_ENT(FT3),
  DT_ENT(FT4),
  DT_ENT(FT5),
  DT_ENT(FT6),
  DT_ENT(FT7),
  DT_ENT(FT8),
  DT_ENT(LAX),
  DT_ENT(LA36),
  DT_ENT(LA120),
  DT_ENT(VT5X),
  DT_ENT(VT52),
  DT_ENT(VT55),
  DT_ENT(TQ_BTS),
  DT_ENT(TEK401X),
  DT_ENT(VT100),
  DT_ENT(VK100),
  DT_ENT(VT173),
  DT_ENT(LA34),
  DT_ENT(LA38),
  DT_ENT(LA12),
  DT_ENT(LA24),
  DT_ENT(LA100),
  DT_ENT(LQP02),
  DT_ENT(VT101),
  DT_ENT(VT102),
  DT_ENT(VT105),
  DT_ENT(VT125),
  DT_ENT(VT131),
  DT_ENT(VT132),
  DT_ENT(DZ11),
  DT_ENT(DZ32),
  DT_ENT(DZ730),
  DT_ENT(DMZ32),
  DT_ENT(DHV),
  DT_ENT(DHU),
  DT_ENT(SLU),
  DT_ENT(TERM9),
  DT_ENT(LAT),
  DT_ENT(VS100),
  DT_ENT(VS125),
  DT_ENT(VL_VS8200),
  DT_ENT(VD),
  DT_ENT(DECW_OUTPUT),
  DT_ENT(DECW_INPUT),
  DT_ENT(DECW_PSEUDO),
  DT_ENT(DMC11),
  DT_ENT(DMR11),
  DT_ENT(XK_3271),
  DT_ENT(XJ_2780),
  DT_ENT(NW_X25),
  DT_ENT(NV_X29),
  DT_ENT(SB_ISB11),
  DT_ENT(MX_MUX200),
  DT_ENT(DMP11),
  DT_ENT(DMF32),
  DT_ENT(XV_3271),
  DT_ENT(CI),
  DT_ENT(NI),
  DT_ENT(UNA11),
  DT_ENT(DEUNA),
  DT_ENT(YN_X25),
  DT_ENT(YO_X25),
  DT_ENT(YP_ADCCP),
  DT_ENT(YQ_3271),
  DT_ENT(YR_DDCMP),
  DT_ENT(YS_SDLC),
  DT_ENT(UK_KTC32),
  DT_ENT(DEQNA),
  DT_ENT(DMV11),
  DT_ENT(ES_LANCE),
  DT_ENT(DELUA),
  DT_ENT(NQ_3271),
  DT_ENT(DMB32),
  DT_ENT(YI_KMS11K),
  DT_ENT(ET_DEBNT),
  DT_ENT(ET_DEBNA),
  DT_ENT(SJ_DSV11),
  DT_ENT(SL_DSB32),
  DT_ENT(ZS_DST32),
  DT_ENT(XQ_DELQA),
  DT_ENT(ET_DEBNI),
  DT_ENT(EZ_SGEC),
  DT_ENT(EX_DEMNA),
  DT_ENT(DIV32),
  DT_ENT(XQ_DEQTA),
  DT_ENT(FT_NI),
  DT_ENT(EP_LANCE),
  DT_ENT(KWV32),
  DT_ENT(SM_DSF32),
  DT_ENT(FX_DEMFA),
  DT_ENT(SF_DSF32),
  DT_ENT(SE_DUP11),
  DT_ENT(SE_DPV11),
  DT_ENT(ZT_DSW),
  DT_ENT(FC_DEFZA),
  DT_ENT(EC_PMAD),
  DT_ENT(EZ_TGEC),
  DT_ENT(EA_DEANA),
  DT_ENT(EY_NITC2),
  DT_ENT(ER_DE422),
  DT_ENT(ER_DE200),
  DT_ENT(EW_TULIP),
  DT_ENT(FA_DEFAA),
  DT_ENT(FC_DEFTA),
  DT_ENT(FQ_DEFQA),
  DT_ENT(FR_DEFEA),
  DT_ENT(FW_DEFPA),
  DT_ENT(IC_DETRA),
  DT_ENT(IQ_DEQRA),
  DT_ENT(IR_DW300),
  DT_ENT(ZR_SCC),
  DT_ENT(ZY_DSYT1),
  DT_ENT(ZE_DNSES),
  DT_ENT(ER_DE425),
  DT_ENT(EW_DE435),
  DT_ENT(ER_DE205),
  DT_ENT(HC_OTTO),
  DT_ENT(ZS_PBXDI),
  DT_ENT(EL_ELAN),
  DT_ENT(HW_OTTO),
  DT_ENT(EO_3C598),
  DT_ENT(IW_TC4048),
  DT_ENT(EW_DE450),
  DT_ENT(EW_DE500),
  DT_ENT(CL_CLIP),
  DT_ENT(ZW_PBXDP),
  DT_ENT(HW_METEOR),
  DT_ENT(LP11),
  DT_ENT(LA11),
  DT_ENT(LA180),
  DT_ENT(LC_DMF32),
  DT_ENT(LI_DMB32),
  DT_ENT(PRTR9),
  DT_ENT(SCSI_SCANNER_1),
  DT_ENT(PC_PRINTER),
  DT_ENT(CR11),
  DT_ENT(MBX),
  DT_ENT(SHRMBX),
  DT_ENT(NULL),
  DT_ENT(PIPE),
  DT_ENT(DAP_DEVICE),
  DT_ENT(LPA11),
  DT_ENT(DR780),
  DT_ENT(DR750),
  DT_ENT(DR11W),
  DT_ENT(PCL11R),
  DT_ENT(PCL11T),
  DT_ENT(DR11C),
  DT_ENT(BS_DT07),
  DT_ENT(XP_PCL11B),
  DT_ENT(IX_IEX11),
  DT_ENT(FP_FEPCM),
  DT_ENT(TK_FCM),
  DT_ENT(XI_DR11C),
  DT_ENT(XA_DRV11WA),
  DT_ENT(DRB32),
  DT_ENT(HX_DRQ3B),
  DT_ENT(DECVOICE),
  DT_ENT(DTC04),
  DT_ENT(DTC05),
  DT_ENT(DTCN5),
  DT_ENT(AMD79C30A),
  DT_ENT(CI780),
  DT_ENT(CI750),
  DT_ENT(UQPORT),
  DT_ENT(UDA50),
  DT_ENT(UDA50A),
  DT_ENT(LESI),
  DT_ENT(TU81P),
  DT_ENT(RDRX),
  DT_ENT(TK50P),
  DT_ENT(RUX50P),
  DT_ENT(RC26P),
  DT_ENT(QDA50),
  DT_ENT(KDA50),
  DT_ENT(BDA50),
  DT_ENT(KDB50),
  DT_ENT(RRD50P),
  DT_ENT(QDA25),
  DT_ENT(KDA25),
  DT_ENT(BCI750),
  DT_ENT(BCA),
  DT_ENT(RQDX3),
  DT_ENT(NISCA),
  DT_ENT(AIO),
  DT_ENT(KFBTA),
  DT_ENT(AIE),
  DT_ENT(DEBNT),
  DT_ENT(BSA),
  DT_ENT(KSB50),
  DT_ENT(TK70P),
  DT_ENT(RV20P),
  DT_ENT(RV80P),
  DT_ENT(TK60P),
  DT_ENT(SII),
  DT_ENT(KFSQSA),
  DT_ENT(KFQSA),
  DT_ENT(SHAC),
  DT_ENT(CIXCD),
  DT_ENT(N5380),
  DT_ENT(SCSII),
  DT_ENT(HSX50),
  DT_ENT(KDM70),
  DT_ENT(TM32P),
  DT_ENT(TK7LP),
  DT_ENT(SWIFT),
  DT_ENT(N53C94),
  DT_ENT(KFMSA),
  DT_ENT(SCSI_XTENDR),
  DT_ENT(FT_TRACE_RAM),
  DT_ENT(XVIB),
  DT_ENT(XZA_SCSI),
  DT_ENT(XZA_DSSI),
  DT_ENT(N710_SCSI),
  DT_ENT(N710_DSSI),
  DT_ENT(AHA1742A),
  DT_ENT(TZA_SCSI),
  DT_ENT(N810_SCSI),
  DT_ENT(CIPCA),
  DT_ENT(ISP1020),
  DT_ENT(MC_SPUR),
  DT_ENT(PZA_SCSI),
  DT_ENT(DN11),
  DT_ENT(PV),
  DT_ENT(SFUN9),
  DT_ENT(USER9),
  DT_ENT(GENERIC_SCSI),
  DT_ENT(DMA_520),
  DT_ENT(T3270),
  {NULL, 0}
};

struct DevInfoID {
  char *DevInfoName; /* Pointer to the item name */
  int  DVIValue;      /* Value to use in the getDVI item list */
  int  BufferLen;     /* Length the return va buf needs to be. (no nul */
                      /* terminators, so must be careful with the return */
                      /* values. */
  int  ReturnType;    /* Type of data the item returns */
};

struct DevInfoID DevInfoList[] =
{
  DVI_ENT(ACPPID, 4, IS_LONGWORD),
  DVI_ENT(ACPTYPE, 4, IS_ENUM),
  DVI_ENT(ALLDEVNAM, 64, IS_STRING),
  DVI_ENT(ALLOCLASS, 4, IS_LONGWORD),
  DVI_ENT(ALT_HOST_AVAIL, 4, IS_LONGWORD),
  DVI_ENT(ALT_HOST_NAME, 64, IS_STRING),
  DVI_ENT(ALT_HOST_TYPE, 64, IS_STRING),
  DVI_ENT(CLUSTER, 4, IS_LONGWORD),
  DVI_ENT(CYLINDERS, 4, IS_LONGWORD),
  DVI_ENT(DEVBUFSIZ, 4, IS_LONGWORD),
  DVI_ENT(DEVCHAR, 4, IS_BITMAP),
  DVI_ENT(DEVCLASS, 4, IS_ENUM),
  DVI_ENT(DEVDEPEND, 4, IS_BITMAP),
  DVI_ENT(DEVDEPEND2, 4, IS_BITMAP),
  DVI_ENT(DEVICE_TYPE_NAME, 64, IS_STRING),
  DVI_ENT(DEVLOCKNAM, 64, IS_STRING),
  DVI_ENT(DEVNAM, 64, IS_STRING),
  DVI_ENT(DEVSTS, 4, IS_BITMAP),
  DVI_ENT(DEVTYPE, 4, IS_LONGWORD),
  DVI_ENT(DFS_ACCESS, 4, IS_LONGWORD),
  DVI_ENT(DISPLAY_DEVNAM, 256, IS_STRING),
  DVI_ENT(ERRCNT, 4, IS_LONGWORD),
  DVI_ENT(FREEBLOCKS, 4, IS_LONGWORD),
  DVI_ENT(FULLDEVNAM, 64, IS_STRING),
  DVI_ENT(HOST_AVAIL, 4, IS_LONGWORD),
  DVI_ENT(HOST_COUNT, 4, IS_LONGWORD),
  DVI_ENT(HOST_NAME, 64, IS_STRING),
  DVI_ENT(HOST_TYPE, 64, IS_STRING),
  DVI_ENT(LOCKID, 4, IS_LONGWORD),
  DVI_ENT(LOGVOLNAM, 64, IS_STRING),
  DVI_ENT(MAXBLOCK, 4, IS_LONGWORD),
  DVI_ENT(MAXFILES, 4, IS_LONGWORD),
  DVI_ENT(MEDIA_ID, 4, IS_LONGWORD),
  DVI_ENT(MEDIA_NAME, 64, IS_STRING),
  DVI_ENT(MEDIA_TYPE, 64, IS_STRING),
  DVI_ENT(MOUNTCNT, 4, IS_LONGWORD),
  DVI_ENT(MSCP_UNIT_NUMBER, 4, IS_LONGWORD),
  DVI_ENT(NEXTDEVNAM, 64, IS_STRING),
  DVI_ENT(OPCNT, 4, IS_LONGWORD),
  DVI_ENT(OWNUIC, 4, IS_LONGWORD),
  DVI_ENT(PID, 4, IS_LONGWORD),
  DVI_ENT(RECSIZ, 4, IS_LONGWORD),
  DVI_ENT(REFCNT, 4, IS_LONGWORD),
  DVI_ENT(REMOTE_DEVICE, 4, IS_LONGWORD),
  DVI_ENT(ROOTDEVNAM, 64, IS_STRING),
  DVI_ENT(SECTORS, 4, IS_LONGWORD),
  DVI_ENT(SERIALNUM, 4, IS_LONGWORD),
  DVI_ENT(SERVED_DEVICE, 4, IS_LONGWORD),
  DVI_ENT(SHDW_CATCHUP_COPYING, 4, IS_LONGWORD),
  DVI_ENT(SHDW_FAILED_MEMBER, 4, IS_LONGWORD),
  DVI_ENT(SHDW_MASTER, 4, IS_LONGWORD),
  DVI_ENT(SHDW_MASTER_NAME, 64, IS_STRING),
  DVI_ENT(SHDW_MEMBER, 4, IS_LONGWORD),
  DVI_ENT(SHDW_MERGE_COPYING, 4, IS_LONGWORD),
  DVI_ENT(SHDW_NEXT_MBR_NAME, 64, IS_STRING),
  DVI_ENT(STS, 4, IS_BITMAP),
  DVI_ENT(TRACKS, 4, IS_LONGWORD),
  DVI_ENT(TRANSCNT, 4, IS_LONGWORD),
  DVI_ENT(TT_ACCPORNAM, 64, IS_STRING),
  DVI_ENT(TT_CHARSET, 4, IS_BITMAP),
  DVI_ENT(TT_CS_HANGUL, 4, IS_LONGWORD),
  DVI_ENT(TT_CS_HANYU, 4, IS_LONGWORD),
  DVI_ENT(TT_CS_HANZI, 4, IS_LONGWORD),
  DVI_ENT(TT_CS_KANA, 4, IS_LONGWORD),
  DVI_ENT(TT_CS_KANJI, 4, IS_LONGWORD),
  DVI_ENT(TT_CS_THAI, 4, IS_LONGWORD),
  DVI_ENT(TT_PHYDEVNAM, 64, IS_STRING),
  DVI_ENT(UNIT, 4, IS_LONGWORD),
  DVI_ENT(VOLCOUNT, 4, IS_LONGWORD),
  DVI_ENT(VOLNAM, 12, IS_STRING),
  DVI_ENT(VOLNUMBER, 4, IS_LONGWORD),
  DVI_ENT(VOLSETMEM, 4, IS_LONGWORD),
  DVI_ENT(VPROT, 4, IS_LONGWORD),
  DVI_ENT(TT_NOECHO, 4, IS_LONGWORD),
  DVI_ENT(TT_NOTYPEAHD, 4, IS_LONGWORD),
  DVI_ENT(TT_HOSTSYNC, 4, IS_LONGWORD),
  DVI_ENT(TT_TTSYNC, 4, IS_LONGWORD),
  DVI_ENT(TT_ESCAPE, 4, IS_LONGWORD),
  DVI_ENT(TT_LOWER, 4, IS_LONGWORD),
  DVI_ENT(TT_MECHTAB, 4, IS_LONGWORD),
  DVI_ENT(TT_WRAP, 4, IS_LONGWORD),
  DVI_ENT(TT_LFFILL, 4, IS_LONGWORD),
  DVI_ENT(TT_SCOPE, 4, IS_LONGWORD),
  DVI_ENT(TT_CRFILL, 4, IS_LONGWORD),
  DVI_ENT(TT_SETSPEED, 4, IS_LONGWORD),
  DVI_ENT(TT_EIGHTBIT, 4, IS_LONGWORD),
  DVI_ENT(TT_MBXDSABL, 4, IS_LONGWORD),
  DVI_ENT(TT_READSYNC, 4, IS_LONGWORD),
  DVI_ENT(TT_MECHFORM, 4, IS_LONGWORD),
  DVI_ENT(TT_NOBRDCST, 4, IS_LONGWORD),
  DVI_ENT(TT_HALFDUP, 4, IS_LONGWORD),
  DVI_ENT(TT_MODEM, 4, IS_LONGWORD),
  DVI_ENT(TT_OPER, 4, IS_LONGWORD),
  DVI_ENT(TT_LOCALECHO, 4, IS_LONGWORD),
  DVI_ENT(TT_AUTOBAUD, 4, IS_LONGWORD),
  DVI_ENT(TT_PAGE, 4, IS_LONGWORD),
  DVI_ENT(TT_HANGUP, 4, IS_LONGWORD),
  DVI_ENT(TT_MODHANGUP, 4, IS_LONGWORD),
  DVI_ENT(TT_BRDCSTMBX, 4, IS_LONGWORD),
  DVI_ENT(TT_DMA, 4, IS_LONGWORD),
  DVI_ENT(TT_ALTYPEAHD, 4, IS_LONGWORD),
  DVI_ENT(TT_ANSICRT, 4, IS_LONGWORD),
  DVI_ENT(TT_REGIS, 4, IS_LONGWORD),
  DVI_ENT(TT_AVO, 4, IS_LONGWORD),
  DVI_ENT(TT_EDIT, 4, IS_LONGWORD),
  DVI_ENT(TT_BLOCK, 4, IS_LONGWORD),
  DVI_ENT(TT_DECCRT, 4, IS_LONGWORD),
  DVI_ENT(TT_EDITING, 4, IS_LONGWORD),
  DVI_ENT(TT_INSERT, 4, IS_LONGWORD),
  DVI_ENT(TT_DIALUP, 4, IS_LONGWORD),
  DVI_ENT(TT_SECURE, 4, IS_LONGWORD),
  DVI_ENT(TT_FALLBACK, 4, IS_LONGWORD),
  DVI_ENT(TT_DISCONNECT, 4, IS_LONGWORD),
  DVI_ENT(TT_PASTHRU, 4, IS_LONGWORD),
  DVI_ENT(TT_SIXEL, 4, IS_LONGWORD),
  DVI_ENT(TT_PRINTER, 4, IS_LONGWORD),
  DVI_ENT(TT_APP_KEYPAD, 4, IS_LONGWORD),
  DVI_ENT(TT_DRCS, 4, IS_LONGWORD),
  DVI_ENT(TT_SYSPWD, 4, IS_LONGWORD),
  DVI_ENT(TT_DECCRT2, 4, IS_LONGWORD),
  DVI_ENT(TT_DECCRT3, 4, IS_LONGWORD),
  DVI_ENT(TT_DECCRT4, 4, IS_LONGWORD),
  {NULL, 0, 0, 0}
};

char *MonthNames[12] = {
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
  "Oct", "Nov", "Dec"} ;

/* Globals to track how many different pieces of info we can return, as */
/* well as how much space we'd need to grab to store it. */
static int DevInfoCount = 0;
static int DevInfoMallocSize = 0;

/* Macro to fill in a 'traditional' item-list entry */
#define init_itemlist(ile, length, code, bufaddr, retlen_addr) \
{ \
    (ile)->buflen = (length); \
    (ile)->itmcode = (code); \
    (ile)->buffer = (bufaddr); \
    (ile)->retlen = (retlen_addr) ;}

/* take a class name and return the corresponding code */
int
dev_class_decode(SV *ClassNameSV)
{
  int ClassCode = -1;
  char *ClassName = NULL;
  int i;
  
  /* Is it undef? If so, return 0 */
  if (ClassNameSV == &sv_undef) {
    ClassCode = 0;
  } else {
    ClassName = SvPV(ClassNameSV, na);
    for (i=0; DevClassList[i].DevClassName; i++) {
      if (!strcmp(ClassName, DevClassList[i].DevClassName)) {
        ClassCode = DevClassList[i].DevClassValue;
        break;
      }
    }
  }
  
  return ClassCode;
}

/* take a type name and return the corresponding code */
int
dev_type_decode(SV *TypeNameSV)
{
  int TypeCode = -1;
  char *TypeName;
  int i;
  
  /* Is it undef? If so, return 0 */
  if (TypeNameSV == &sv_undef) {
    TypeCode = 0;
  } else {
    TypeName = SvPV(TypeNameSV, na);
    for (i=0; DevTypeList[i].DevTypeName; i++) {
      if (!strcmp(TypeName, DevTypeList[i].DevTypeName)) {
        TypeCode = DevTypeList[i].DevTypeValue;
        break;
      }
    }
  }

  return TypeCode;
}

/* Take a pointer to a bitmap hash (like decode_bitmap gives) and turn it */
/* into an integer */
int
generic_bitmap_encode(HV * FlagHV, int ItemCode)
{
  char *FlagName;
  I32 FlagLen;
  int EncodedValue = 0;

  /* Shut Dec C up */
  FlagName = NULL;

  /* Initialize our hash iterator */
  hv_iterinit(FlagHV);

  /* Rip through the hash */
  while (hv_iternextsv(FlagHV, &FlagName, &FlagLen)) {
  
    switch (ItemCode) {
/*    case QUI$_SEARCH_FLAGS:
      BME_D(SEARCH_WILDCARD);
      break; */
    default:
      croak("Invalid item specified");
    }
  }
  
  return EncodedValue;
  
}

/* Take a pointer to an itemlist, a hashref, and some flags, and build up */
/* an itemlist from what's in the hashref. Buffer space for the items is */
/* allocated, as are the length shorts and stuff. If the hash entries have */
/* values, those values are copied into the buffers, too. Returns the */
/* number of items stuck in the itemlist */
int build_itemlist(ITMLST *ItemList, HV *HashRef)
{
  /* standard, dopey index variable */
  int i = 0, ItemListIndex = 0;
  char *TempCharPointer;
  unsigned int TempStrLen;
  
  int TempNameLen;
  SV *TempSV;
  unsigned short *TempLen;
  int ItemCode;
  char *TempBuffer;
  long TempLong;
  struct dsc$descriptor_s TimeStringDesc;
  int Status;

  for(i = 0; DevInfoList[i].DevInfoName; i++) {
    TempNameLen = strlen(DevInfoList[i].DevInfoName);
    if (hv_exists(HashRef, DevInfoList[i].DevInfoName, TempNameLen)) {
      /* Figure out some stuff. Avoids duplication, and makes the macro */
      /* expansion of init_itemlist a little easier */
      ItemCode = DevInfoList[i].DVIValue;
      switch(DevInfoList[i].ReturnType) {
        /* Quadwords are treated as strings for right now */
      case IS_QUADWORD:
      case IS_STRING:
        TempSV = *hv_fetch(HashRef,
                           DevInfoList[i].DevInfoName,
                           TempNameLen, FALSE);
        TempCharPointer = SvPV(TempSV, TempStrLen);
        
        /* Allocate us some buffer space */
        New(NULL, TempBuffer, DevInfoList[i].BufferLen, char);
        Newz(NULL, TempLen, 1, unsigned short);
        
        /* Set the string buffer to spaces */
        memset(TempBuffer, ' ', DevInfoList[i].BufferLen);
        
        /* If there was something in the SV, then copy it over */
        if (TempStrLen) {
          Copy(TempCharPointer, TempBuffer, TempStrLen <
               DevInfoList[i].BufferLen ? TempStrLen :
               DevInfoList[i].BufferLen, char);
        }
        
        init_itemlist(&ItemList[ItemListIndex],
                      DevInfoList[i].BufferLen,
                      ItemCode,
                      TempBuffer,
                      TempLen);
        break;
      case IS_VMSDATE:
        TempSV = *hv_fetch(HashRef,
                           DevInfoList[i].DevInfoName,
                           TempNameLen, FALSE);
        TempCharPointer = SvPV(TempSV, TempStrLen);
        
        /* Allocate us some buffer space */
        New(NULL, TempBuffer, DevInfoList[i].BufferLen, char);
        Newz(NULL, TempLen, 1, unsigned short);
        
        /* Fill in the time string descriptor */
        TimeStringDesc.dsc$a_pointer = TempCharPointer;
        TimeStringDesc.dsc$w_length = TempStrLen;
        TimeStringDesc.dsc$b_dtype = DSC$K_DTYPE_T;
        TimeStringDesc.dsc$b_class = DSC$K_CLASS_S;
        
        /* Convert from an ascii rep to a VMS quadword date structure */
        Status = sys$bintim(&TimeStringDesc, TempBuffer);
        if (Status != SS$_NORMAL) {
          croak("Error converting time!");
        }
        
        init_itemlist(&ItemList[ItemListIndex],
                      DevInfoList[i].BufferLen,
                      ItemCode,
                      TempBuffer,
                      TempLen);
        break;
        
      case IS_LONGWORD:
        TempSV = *hv_fetch(HashRef,
                           DevInfoList[i].DevInfoName,
                           TempNameLen, FALSE);
        TempLong = SvIVX(TempSV);
        
        /* Allocate us some buffer space */
        New(NULL, TempBuffer, DevInfoList[i].BufferLen, char);
        Newz(NULL, TempLen, 1, unsigned short);
        
        
        /* Set the value */
        *TempBuffer = TempLong;
        
        init_itemlist(&ItemList[ItemListIndex],
                      DevInfoList[i].BufferLen,
                      ItemCode,
                      TempBuffer,
                      TempLen);
        break;
        
      case IS_BITMAP:
        TempSV = *hv_fetch(HashRef,
                           DevInfoList[i].DevInfoName,
                           TempNameLen, FALSE);
        
        /* Is the SV an integer? If so, then we'll use that value. */
        /* Otherwise we'll assume that it's a hashref of the sort that */
        /* generic_bitmap_decode gives */
        if (SvIOK(TempSV)) {
          TempLong = SvIVX(TempSV);
        } else {
          TempLong = generic_bitmap_encode((HV *)SvRV(TempSV), ItemCode);
        }
        
        /* Allocate us some buffer space */
        New(NULL, TempBuffer, DevInfoList[i].BufferLen, char);
        Newz(NULL, TempLen, 1, unsigned short);
        
        
        /* Set the value */
        *TempBuffer = TempLong;
        
        init_itemlist(&ItemList[ItemListIndex],
                      DevInfoList[i].BufferLen,
                      ItemCode,
                      TempBuffer,
                      TempLen);
        break;
        
      default:
        croak("Unknown item type found!");
        break;
      }
      ItemListIndex++;
    }
  }

  return(ItemListIndex);
}

/* Takes an item list pointer and a count of items, and frees the buffer */
/* memory and length buffer memory */
void
tear_down_itemlist(ITMLST *ItemList, int NumItems)
{
  int i;

  for(i=0; i < NumItems; i++) {
    if(ItemList[i].buffer != NULL)
      Safefree(ItemList[i].buffer);
    if(ItemList[i].retlen != NULL)
      Safefree(ItemList[i].retlen);
  }
}
         
int
de_enum(int PSCANVal, char *EnumName)
{
  int ReturnVal = 0;
  switch(PSCANVal) {
/*  case PSCAN$_JOBTYPE:
    if (!strcmp(EnumName, "LOCAL"))
      ReturnVal = DVI$K_LOCAL;
    else if (!strcmp(EnumName, "DIALUP"))
      ReturnVal = DVI$K_DIALUP;
    else if (!strcmp(EnumName, "REMOTE"))
      ReturnVal = DVI$K_REMOTE;
    else if (!strcmp(EnumName, "BATCH"))
      ReturnVal = DVI$K_BATCH;
    else if (!strcmp(EnumName, "NETWORK"))
      ReturnVal = DVI$K_NETWORK;
    else if (!strcmp(EnumName, "DETACHED"))
      ReturnVal = DVI$K_DETACHED;
    break;
  case PSCAN$_MODE:
    if (!strcmp(EnumName, "INTERACTIVE"))
      ReturnVal = DVI$K_INTERACTIVE;
    else if (!strcmp(EnumName, "BATCH"))
      ReturnVal = DVI$K_BATCH;
    else if (!strcmp(EnumName, "NETWORK"))
      ReturnVal = DVI$K_NETWORK;
    else if (!strcmp(EnumName, "OTHER"))
      ReturnVal = DVI$K_OTHER;
    break;
  case PSCAN$_STATE:
    if (!strcmp(EnumName, "CEF"))
      ReturnVal = SCH$C_CEF;
    else if (!strcmp(EnumName, "COM"))
      ReturnVal = SCH$C_COM;
    else if (!strcmp(EnumName, "COMO"))
      ReturnVal = SCH$C_COMO;
    else if (!strcmp(EnumName, "CUR"))
      ReturnVal = SCH$C_CUR;
    else if (!strcmp(EnumName, "COLPG"))
      ReturnVal = SCH$C_COLPG;
    else if (!strcmp(EnumName, "FPG"))
      ReturnVal = SCH$C_FPG;
    else if (!strcmp(EnumName, "HIB"))
      ReturnVal = SCH$C_HIB;
    else if (!strcmp(EnumName, "HIBO"))
      ReturnVal = SCH$C_HIBO;
    else if (!strcmp(EnumName, "LEF"))
      ReturnVal = SCH$C_LEF;
    else if (!strcmp(EnumName, "LEFO"))
      ReturnVal = SCH$C_LEFO;
    else if (!strcmp(EnumName, "MWAIT"))
      ReturnVal = SCH$C_MWAIT;
    else if (!strcmp(EnumName, "PFW"))
      ReturnVal = SCH$C_PFW;
    else if (!strcmp(EnumName, "SUSP"))
      ReturnVal = SCH$C_SUSP;
    else if (!strcmp(EnumName, "SUSPO"))
      ReturnVal = SCH$C_SUSPO;
    break;
    */
  default:
    ReturnVal = 0;
  }

  return ReturnVal;
}

void
tote_up_info_count()
{
  for(DevInfoCount = 0; DevInfoList[DevInfoCount].DevInfoName;
      DevInfoCount++) {
    /* While we're here, we might as well get a generous estimate of how */
    /* much space we'll need for all the buffers */
    DevInfoMallocSize += DevInfoList[DevInfoCount].BufferLen;
    /* Add in a couple extra, just to be safe */
    DevInfoMallocSize += 8;
  }
}    

/* This routine takes a DVI item list ID and the value that wants to be */
/* de-enumerated and returns a pointer to an SV with the de-enumerated name */
/* in it */
SV *
enum_name(long DVI_entry, long val_to_deenum)
{
  SV *WorkingSV = newSV(10);
  switch (DVI_entry) {
  case DVI$_ACPTYPE:
    switch (val_to_deenum) {
    case DVI$C_ACP_F11V1:
      sv_setpv(WorkingSV, "Files-11 Level 1");
      break;
    case DVI$C_ACP_F11V2:
      sv_setpv(WorkingSV, "Files-11 Level 2");
      break;
    case DVI$C_ACP_MTA:
      sv_setpv(WorkingSV, "Magnetic Tape");
      break;
    case DVI$C_ACP_NET:
      sv_setpv(WorkingSV, "Networks");
      break;
    case DVI$C_ACP_REM:
      sv_setpv(WorkingSV, "Remote I/O");
      break;
    default:
      sv_setpv(WorkingSV, "Unknown");
      break;
    }
    break;
  default:
    sv_setpv(WorkingSV, "Unknown");
    break;
  }

  return WorkingSV;
}


MODULE = VMS::Device		PACKAGE = VMS::Device		

SV *
device_info(device_name)
     SV *device_name
   CODE:
{
  ITMLST *ListOItems;
  unsigned short *ReturnLengths;
  long *TempLongPointer;
#ifdef __ALPHA
  __int64 *TempQuadPointer;
#endif
  FetchedItem *OurDataList;
  int i, status;
  HV *AllPurposeHV;
  unsigned short ReturnedTime[7];
  char AsciiTime[100];
  char *DeviceName;
  unsigned int DeviceNameLen;
  struct dsc$descriptor_s DevNameDesc;
  char QuadWordString[65];
     
  /* If we've not gotten the count of items, go get it now */
  if (DevInfoCount == 0) {
    tote_up_info_count();
  }

  DeviceName = SvPV(device_name, DeviceNameLen);
  DevNameDesc.dsc$a_pointer = DeviceName;
  DevNameDesc.dsc$w_length = DeviceNameLen;
  DevNameDesc.dsc$b_dtype = DSC$K_DTYPE_T;
  DevNameDesc.dsc$b_class = DSC$K_CLASS_S;
  
  /* We need room for our item list */
  ListOItems = malloc(sizeof(ITMLST) * (DevInfoCount + 1));
  memset(ListOItems, 0, sizeof(ITMLST) * (DevInfoCount + 1));
  OurDataList = malloc(sizeof(FetchedItem) * DevInfoCount);
  
  /* We also need room for the buffer lengths */
  ReturnLengths = malloc(sizeof(short) * DevInfoCount);
  
  /* Fill in the item list and the tracking list */
  for (i = 0; i < DevInfoCount; i++) {
    /* Allocate the return data buffer and zero it. Can be oddly
       sized, so we use the system malloc instead of New */
    OurDataList[i].ReturnBuffer = malloc(DevInfoList[i].BufferLen);
    memset(OurDataList[i].ReturnBuffer, 0, DevInfoList[i].BufferLen);
    
    /* Note some important stuff (like what we're doing) in our local */
    /* tracking array */
    OurDataList[i].ItemName = DevInfoList[i].DevInfoName;
    OurDataList[i].ReturnLength = &ReturnLengths[i];
    OurDataList[i].ReturnType = DevInfoList[i].ReturnType;
    OurDataList[i].ItemListEntry = i;
    
    /* Fill in the item list */
    init_itemlist(&ListOItems[i], DevInfoList[i].BufferLen,
                  DevInfoList[i].DVIValue, OurDataList[i].ReturnBuffer,
                  &ReturnLengths[i]);
    
  }
  
  /* Make the GETDVIW call */
  status = sys$getdviw(NULL, NULL, &DevNameDesc, ListOItems, NULL, NULL, 0);
  /* Did it go OK? */
  if (status == SS$_NORMAL) {
    /* Looks like it */
    AllPurposeHV = newHV();
    for (i = 0; i < DevInfoCount; i++) {
      switch(OurDataList[i].ReturnType) {
      case IS_STRING:
        hv_store(AllPurposeHV, OurDataList[i].ItemName,
                 strlen(OurDataList[i].ItemName),
                 newSVpv(OurDataList[i].ReturnBuffer,
                         *OurDataList[i].ReturnLength), 0);
        break;
      case IS_VMSDATE:
        sys$numtim(ReturnedTime, OurDataList[i].ReturnBuffer);
        sprintf(AsciiTime, "%02hi-%s-%hi %02hi:%02hi:%02hi.%hi",
                ReturnedTime[2], MonthNames[ReturnedTime[1] - 1],
                ReturnedTime[0], ReturnedTime[3], ReturnedTime[4],
                ReturnedTime[5], ReturnedTime[6]);
        hv_store(AllPurposeHV, OurDataList[i].ItemName,
                 strlen(OurDataList[i].ItemName),
                 newSVpv(AsciiTime, 0), 0);
        break;
      case IS_ENUM:
        TempLongPointer = OurDataList[i].ReturnBuffer;
        hv_store(AllPurposeHV, OurDataList[i].ItemName,
                 strlen(OurDataList[i].ItemName),
                 enum_name(DevInfoList[i].DVIValue,
                           *TempLongPointer), 0);
        break;
      case IS_BITMAP:
      case IS_LONGWORD:
        TempLongPointer = OurDataList[i].ReturnBuffer;
        hv_store(AllPurposeHV, OurDataList[i].ItemName,
                 strlen(OurDataList[i].ItemName),
                 newSViv(*TempLongPointer),
                 0);
        break;
#ifdef __ALPHA
      case IS_QUADWORD:
        TempQuadPointer = OurDataList[i].ReturnBuffer;
        sprintf(QuadWordString, "%llu", *TempQuadPointer);
        hv_store(AllPurposeHV, OurDataList[i].ItemName,
                 strlen(OurDataList[i].ItemName),
                 newSVpv(QuadWordString, 0), 0);
        break;
#endif
        
      }
    }
    ST(0) = newRV_noinc((SV *) AllPurposeHV);
  } else {
    /* I think we failed */
    SETERRNO(EVMSERR, status);
    ST(0) = &sv_undef;
  }
  
  /* Free up our allocated memory */
  for(i = 0; i < DevInfoCount; i++) {
    free(OurDataList[i].ReturnBuffer);
  }
  free(OurDataList);
  free(ReturnLengths);
  free(ListOItems);
}

void
device_types()
   PPCODE:
{
  int i;
  for (i=0; DevTypeList[i].DevTypeName; i++) {
    XPUSHs(sv_2mortal(newSVpv(DevTypeList[i].DevTypeName, 0)));
  }
}

void
device_classes()
   PPCODE:
{
  int i;
  for (i=0; DevClassList[i].DevClassName; i++) {
    XPUSHs(sv_2mortal(newSVpv(DevClassList[i].DevClassName, 0)));
  }
}

void
device_list(DeviceName,DevClass=&sv_undef,DevType=&sv_undef)
     SV *DeviceName
     SV *DevClass
     SV *DevType
   PPCODE:
{
  ITMLST *ListList;
  int ItmlistIndex;
  unsigned short DevNameLen, DevReturnLen;
  unsigned int DevSearchNameLen;
  unsigned int DeviceClass, DeviceType;
  struct dsc$descriptor_s DevNameDesc, DevSearchNameDesc;
  char Context[8] = {0,0,0,0,0,0,0,0};
  char ReturnedDevName[64];
  char *SearchName;

  /* Decode the class and type */
  DeviceClass = dev_class_decode(DevClass);
  DeviceType = dev_type_decode(DevType);

  /* Do we need to allocate an item list? */
  if (DeviceClass || DeviceType) {
    ListList = malloc(sizeof(ITMLST) * 3);
    memset(ListList, 0, sizeof(ITMLST) * 3);
    ItmlistIndex = 0;
    if (DeviceClass) {
      init_itemlist(&ListList[ItmlistIndex], sizeof(DeviceClass),
                    DVS$_DEVCLASS, &DeviceClass, NULL);
      ItmlistIndex++;
    }
    if (DeviceType) {
      init_itemlist(&ListList[ItmlistIndex], sizeof(DeviceType),
                    DVS$_DEVTYPE, &DeviceType, NULL);
      ItmlistIndex++;
    }
  } else {
    ListList = NULL;
  }

  /* The returned name descriptor */
  DevNameDesc.dsc$a_pointer = ReturnedDevName;
  DevNameDesc.dsc$w_length = 64;
  DevNameDesc.dsc$b_dtype = DSC$K_DTYPE_T;
  DevNameDesc.dsc$b_class = DSC$K_CLASS_S;

  /* The search name descriptor */
  DevSearchNameDesc.dsc$a_pointer = SvPV(DeviceName, DevSearchNameLen);
  DevSearchNameDesc.dsc$w_length = DevSearchNameLen;
  DevSearchNameDesc.dsc$b_dtype = DSC$K_DTYPE_T;
  DevSearchNameDesc.dsc$b_class = DSC$K_CLASS_S;
  
  while( SS$_NORMAL == sys$device_scan(&DevNameDesc, &DevReturnLen,
                                       &DevSearchNameDesc, ListList,
                                       Context)) {
    XPUSHs(sv_2mortal(newSVpv(ReturnedDevName, DevReturnLen)));
  }

  if (NULL != ListList) {
    free(ListList);
  }
}
            

SV *
decode_device_bitmap(InfoName, BitmapValue)
     char *InfoName
     int BitmapValue
   PPCODE:
{
  HV *AllPurposeHV;
  if (!strcmp(InfoName, "DEVCHAR")) {
    AllPurposeHV = newHV();
    dev_bit_test(AllPurposeHV, REC, BitmapValue);
    dev_bit_test(AllPurposeHV, CCL, BitmapValue);
    dev_bit_test(AllPurposeHV, TRM, BitmapValue);
    dev_bit_test(AllPurposeHV, DIR, BitmapValue);
    dev_bit_test(AllPurposeHV, SDI, BitmapValue);
    dev_bit_test(AllPurposeHV, SQD, BitmapValue);
    dev_bit_test(AllPurposeHV, SPL, BitmapValue);
    dev_bit_test(AllPurposeHV, OPR, BitmapValue);
    dev_bit_test(AllPurposeHV, RCT, BitmapValue);
    dev_bit_test(AllPurposeHV, NET, BitmapValue);
    dev_bit_test(AllPurposeHV, FOD, BitmapValue);
    dev_bit_test(AllPurposeHV, DUA, BitmapValue);
    dev_bit_test(AllPurposeHV, SHR, BitmapValue);
    dev_bit_test(AllPurposeHV, GEN, BitmapValue);
    dev_bit_test(AllPurposeHV, AVL, BitmapValue);
    dev_bit_test(AllPurposeHV, MNT, BitmapValue);
    dev_bit_test(AllPurposeHV, MBX, BitmapValue);
    dev_bit_test(AllPurposeHV, DMT, BitmapValue);
    dev_bit_test(AllPurposeHV, ELG, BitmapValue);
    dev_bit_test(AllPurposeHV, ALL, BitmapValue);
    dev_bit_test(AllPurposeHV, FOR, BitmapValue);
    dev_bit_test(AllPurposeHV, SWL, BitmapValue);
    dev_bit_test(AllPurposeHV, IDV, BitmapValue);
    dev_bit_test(AllPurposeHV, ODV, BitmapValue);
    dev_bit_test(AllPurposeHV, RND, BitmapValue);
    dev_bit_test(AllPurposeHV, RTM, BitmapValue);
    dev_bit_test(AllPurposeHV, RCK, BitmapValue);
    dev_bit_test(AllPurposeHV, WCK, BitmapValue);
  } else {
  if (!strcmp(InfoName, "DEVCHAR2")) {
    AllPurposeHV = newHV();
    dev_bit_test(AllPurposeHV, CLU, BitmapValue);
    dev_bit_test(AllPurposeHV, DET, BitmapValue);
    dev_bit_test(AllPurposeHV, RTT, BitmapValue);
    dev_bit_test(AllPurposeHV, CDP, BitmapValue);
    dev_bit_test(AllPurposeHV, 2P, BitmapValue);
    dev_bit_test(AllPurposeHV, MSCP, BitmapValue);
    dev_bit_test(AllPurposeHV, SSM, BitmapValue);
    dev_bit_test(AllPurposeHV, SRV, BitmapValue);
    dev_bit_test(AllPurposeHV, RED, BitmapValue);
    dev_bit_test(AllPurposeHV, NNM, BitmapValue);
    dev_bit_test(AllPurposeHV, WBC, BitmapValue);
    dev_bit_test(AllPurposeHV, WTC, BitmapValue);
    dev_bit_test(AllPurposeHV, HOC, BitmapValue);
    dev_bit_test(AllPurposeHV, LOC, BitmapValue);
    dev_bit_test(AllPurposeHV, DFS, BitmapValue);
    dev_bit_test(AllPurposeHV, DAP, BitmapValue);
    dev_bit_test(AllPurposeHV, NLT, BitmapValue);
    dev_bit_test(AllPurposeHV, SEX, BitmapValue);
    dev_bit_test(AllPurposeHV, SHD, BitmapValue);
    dev_bit_test(AllPurposeHV, VRT, BitmapValue);
    dev_bit_test(AllPurposeHV, LDR, BitmapValue);
    dev_bit_test(AllPurposeHV, NOLB, BitmapValue);
    dev_bit_test(AllPurposeHV, NOCLU, BitmapValue);
    dev_bit_test(AllPurposeHV, VMEM, BitmapValue);
    dev_bit_test(AllPurposeHV, SCSI, BitmapValue);
    dev_bit_test(AllPurposeHV, WLG, BitmapValue);
    dev_bit_test(AllPurposeHV, NOFE, BitmapValue);
  } else {
  if (!strcmp(InfoName, "STS")) {
    AllPurposeHV = newHV();
    ucb_bit_test(AllPurposeHV, TIM, BitmapValue)
    ucb_bit_test(AllPurposeHV, INT, BitmapValue)
    ucb_bit_test(AllPurposeHV, ERLOGIP, BitmapValue)
    ucb_bit_test(AllPurposeHV, CANCEL, BitmapValue)
    ucb_bit_test(AllPurposeHV, ONLINE, BitmapValue)
    ucb_bit_test(AllPurposeHV, POWER, BitmapValue)
    ucb_bit_test(AllPurposeHV, TIMOUT, BitmapValue)
    ucb_bit_test(AllPurposeHV, INTTYPE, BitmapValue)
    ucb_bit_test(AllPurposeHV, BSY, BitmapValue)
    ucb_bit_test(AllPurposeHV, MOUNTING, BitmapValue)
    ucb_bit_test(AllPurposeHV, DEADMO, BitmapValue)
    ucb_bit_test(AllPurposeHV, VALID, BitmapValue)
    ucb_bit_test(AllPurposeHV, UNLOAD, BitmapValue)
    ucb_bit_test(AllPurposeHV, TEMPLATE, BitmapValue)
    ucb_bit_test(AllPurposeHV, MNTVERIP, BitmapValue)
    ucb_bit_test(AllPurposeHV, WRONGVOL, BitmapValue)
    ucb_bit_test(AllPurposeHV, DELETEUCB, BitmapValue)
  } else {
  if (!strcmp(InfoName, "TT_CHARSET")) {
    AllPurposeHV = newHV();
    ttc_bit_test(AllPurposeHV, HANGUL, BitmapValue);
    ttc_bit_test(AllPurposeHV, HANYU, BitmapValue);
    ttc_bit_test(AllPurposeHV, HANZI, BitmapValue);
    ttc_bit_test(AllPurposeHV, KANA, BitmapValue);
    ttc_bit_test(AllPurposeHV, KANJI, BitmapValue);
    ttc_bit_test(AllPurposeHV, THAI, BitmapValue);
  }}}}
  if (AllPurposeHV) {
    XPUSHs(newRV((SV *)AllPurposeHV));
  } else {
    XPUSHs(&sv_undef);
  }
}
