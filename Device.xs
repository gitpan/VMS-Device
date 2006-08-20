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
#include <psldef.h>
#include <initdef.h>
#include <mntdef.h>
#include <dmtdef.h>
  
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
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

#define IS_INPUT (1<<0)
#define IS_OUTPUT (1<<1)

#define dev_bit_test(a, b, c) \
{ \
    if (c & DEV$M_##b) \
    hv_store(a, #b, strlen(#b), &PL_sv_yes, 0); \
    else \
    hv_store(a, #b, strlen(#b), &PL_sv_no, 0);}   

#define ucb_bit_test(a, b, c) \
{ \
    if (c & UCB$M_##b) \
    hv_store(a, #b, strlen(#b), &PL_sv_yes, 0); \
    else \
    hv_store(a, #b, strlen(#b), &PL_sv_no, 0);}   

#define ttc_bit_test(a, b, c) \
{ \
    if (c & TTC$M_##b) \
    hv_store(a, #b, strlen(#b), &PL_sv_yes, 0); \
    else \
    hv_store(a, #b, strlen(#b), &PL_sv_no, 0);}   

#define DVI_ENT(a, b, c) {#a, DVI$_##a, b, c, IS_OUTPUT}
#define MNT_ENT(a, b, c) {#a, MNT$_##a, b, c, IS_INPUT}
#define INI_ENT(a, b, c) {#a, INIT$_##a, b, c, IS_INPUT}
#define DC_ENT(a) {#a, DC$_##a}
#define DT_ENT(a) {#a, DT$_##a}

/* The fake item code for generic_bitmap_decode */
#define SYSCALL_DISMOU 42424242

/* Macro to expand out entries for generic_bitmap_encode */
#define DMT_D(a) { if (!strncmp(FlagName, #a, FlagLen)) { \
                       EncodedValue[0] = EncodedValue[0] | DMT$M_##a; \
                       break; \
                     } \
                 }
#define BME_D(a) { if (!strncmp(FlagName, #a, FlagLen)) { \
                       EncodedValue[0] = EncodedValue[0] | MNT$M_##a; \
                       break; \
                     } \
                 }
#define BME2_D(a) { if (!strncmp(FlagName, #a, FlagLen)) { \
                       EncodedValue[1] = EncodedValue[1] | MNT2$M_##a; \
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
#define IS_ODD 9      /* A catchall */

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
#ifdef DC$_DISK
  DC_ENT(DISK),
#endif
#ifdef DC$_TAPE
  DC_ENT(TAPE),
#endif
#ifdef DC$_SCOM
  DC_ENT(SCOM),
#endif
#ifdef DC$_CARD
  DC_ENT(CARD),
#endif
#ifdef DC$_TERM
  DC_ENT(TERM),
#endif
#ifdef DC$_LP
  DC_ENT(LP),
#endif
#ifdef DC$_WORKSTATION
  DC_ENT(WORKSTATION),
#endif
#ifdef DC$_REALTIME
  DC_ENT(REALTIME),
#endif
#ifdef DC$_DECVOICE
  DC_ENT(DECVOICE),
#endif
#ifdef DC$_AUDIO
  DC_ENT(AUDIO),
#endif
#ifdef DC$_VIDEO
  DC_ENT(VIDEO),
#endif
#ifdef DC$_BUS
  DC_ENT(BUS),
#endif
#ifdef DC$_MAILBOX
  DC_ENT(MAILBOX),
#endif
#ifdef DC$_REMCSL_STORAGE
  DC_ENT(REMCSL_STORAGE),
#endif
#ifdef DC$_MISC
  DC_ENT(MISC),
#endif
#ifdef DC$_DISK
  DC_ENT(DISK),
#endif
#ifdef DC$_TAPE
  DC_ENT(TAPE),
#endif
#ifdef DC$_SCOM
  DC_ENT(SCOM),
#endif
#ifdef DC$_CARD
  DC_ENT(CARD),
#endif
#ifdef DC$_TERM
  DC_ENT(TERM),
#endif
#ifdef DC$_LP
  DC_ENT(LP),
#endif
#ifdef DC$_WORKSTATION
  DC_ENT(WORKSTATION),
#endif
#ifdef DC$_REALTIME
  DC_ENT(REALTIME),
#endif
#ifdef DC$_DECVOICE
  DC_ENT(DECVOICE),
#endif
#ifdef DC$_AUDIO
  DC_ENT(AUDIO),
#endif
#ifdef DC$_VIDEO
  DC_ENT(VIDEO),
#endif
#ifdef DC$_BUS
  DC_ENT(BUS),
#endif
#ifdef DC$_MAILBOX
  DC_ENT(MAILBOX),
#endif
#ifdef DC$_REMCSL_STORAGE
  DC_ENT(REMCSL_STORAGE),
#endif
#ifdef DC$_MISC
  DC_ENT(MISC),
#endif
  {NULL, 0}
};

struct DevTypeID {
  char *DevTypeName;
  int  DevTypeValue;
};

/* These were all hand-generated (with help from emacs' replace-regex) */
struct DevTypeID DevTypeList[] =
{
#ifdef DT$_RA80
  DT_ENT(RA80),
#endif
#ifdef DT$_RA81
  DT_ENT(RA81),
#endif
#ifdef DT$_RA60
  DT_ENT(RA60),
#endif
#ifdef DT$_RZ01
  DT_ENT(RZ01),
#endif
#ifdef DT$_RC25
  DT_ENT(RC25),
#endif
#ifdef DT$_RZF01
  DT_ENT(RZF01),
#endif
#ifdef DT$_RCF25
  DT_ENT(RCF25),
#endif
#ifdef DT$_RD51
  DT_ENT(RD51),
#endif
#ifdef DT$_RX50
  DT_ENT(RX50),
#endif
#ifdef DT$_RD52
  DT_ENT(RD52),
#endif
#ifdef DT$_RD53
  DT_ENT(RD53),
#endif
#ifdef DT$_RD26
  DT_ENT(RD26),
#endif
#ifdef DT$_RA82
  DT_ENT(RA82),
#endif
#ifdef DT$_RD31
  DT_ENT(RD31),
#endif
#ifdef DT$_RD54
  DT_ENT(RD54),
#endif
#ifdef DT$_CRX50
  DT_ENT(CRX50),
#endif
#ifdef DT$_RRD50
  DT_ENT(RRD50),
#endif
#ifdef DT$_GENERIC_DU
  DT_ENT(GENERIC_DU),
#endif
#ifdef DT$_RX33
  DT_ENT(RX33),
#endif
#ifdef DT$_RX18
  DT_ENT(RX18),
#endif
#ifdef DT$_RA70
  DT_ENT(RA70),
#endif
#ifdef DT$_RA90
  DT_ENT(RA90),
#endif
#ifdef DT$_RD32
  DT_ENT(RD32),
#endif
#ifdef DT$_DISK9
  DT_ENT(DISK9),
#endif
#ifdef DT$_RX35
  DT_ENT(RX35),
#endif
#ifdef DT$_RF30
  DT_ENT(RF30),
#endif
#ifdef DT$_RF70
  DT_ENT(RF70),
#endif
#ifdef DT$_RF71
  DT_ENT(RF71),
#endif
#ifdef DT$_RD33
  DT_ENT(RD33),
#endif
#ifdef DT$_ESE20
  DT_ENT(ESE20),
#endif
#ifdef DT$_TU56
  DT_ENT(TU56),
#endif
#ifdef DT$_RZ22
  DT_ENT(RZ22),
#endif
#ifdef DT$_RZ23
  DT_ENT(RZ23),
#endif
#ifdef DT$_RZ24
  DT_ENT(RZ24),
#endif
#ifdef DT$_RZ55
  DT_ENT(RZ55),
#endif
#ifdef DT$_RRD40S
  DT_ENT(RRD40S),
#endif
#ifdef DT$_RRD40
  DT_ENT(RRD40),
#endif
#ifdef DT$_GENERIC_DK
  DT_ENT(GENERIC_DK),
#endif
#ifdef DT$_RX23
  DT_ENT(RX23),
#endif
#ifdef DT$_RF31
  DT_ENT(RF31),
#endif
#ifdef DT$_RF72
  DT_ENT(RF72),
#endif
#ifdef DT$_RAM_DISK
  DT_ENT(RAM_DISK),
#endif
#ifdef DT$_RZ25
  DT_ENT(RZ25),
#endif
#ifdef DT$_RZ56
  DT_ENT(RZ56),
#endif
#ifdef DT$_RZ57
  DT_ENT(RZ57),
#endif
#ifdef DT$_RX23S
  DT_ENT(RX23S),
#endif
#ifdef DT$_RX33S
  DT_ENT(RX33S),
#endif
#ifdef DT$_RA92
  DT_ENT(RA92),
#endif
#ifdef DT$_SSTRIPE
  DT_ENT(SSTRIPE),
#endif
#ifdef DT$_RZ23L
  DT_ENT(RZ23L),
#endif
#ifdef DT$_RX26
  DT_ENT(RX26),
#endif
#ifdef DT$_RZ57I
  DT_ENT(RZ57I),
#endif
#ifdef DT$_RZ31
  DT_ENT(RZ31),
#endif
#ifdef DT$_RZ58
  DT_ENT(RZ58),
#endif
#ifdef DT$_SCSI_MO
  DT_ENT(SCSI_MO),
#endif
#ifdef DT$_RWZ01
  DT_ENT(RWZ01),
#endif
#ifdef DT$_RRD42
  DT_ENT(RRD42),
#endif
#ifdef DT$_CD_LOADER_1
  DT_ENT(CD_LOADER_1),
#endif
#ifdef DT$_ESE25
  DT_ENT(ESE25),
#endif
#ifdef DT$_RFH31
  DT_ENT(RFH31),
#endif
#ifdef DT$_RFH72
  DT_ENT(RFH72),
#endif
#ifdef DT$_RF73
  DT_ENT(RF73),
#endif
#ifdef DT$_RFH73
  DT_ENT(RFH73),
#endif
#ifdef DT$_RA72
  DT_ENT(RA72),
#endif
#ifdef DT$_RA71
  DT_ENT(RA71),
#endif
#ifdef DT$_RAH72
  DT_ENT(RAH72),
#endif
#ifdef DT$_RF32
  DT_ENT(RF32),
#endif
#ifdef DT$_RF35
  DT_ENT(RF35),
#endif
#ifdef DT$_RFH32
  DT_ENT(RFH32),
#endif
#ifdef DT$_RFH35
  DT_ENT(RFH35),
#endif
#ifdef DT$_RFF31
  DT_ENT(RFF31),
#endif
#ifdef DT$_RF31F
  DT_ENT(RF31F),
#endif
#ifdef DT$_RZ72
  DT_ENT(RZ72),
#endif
#ifdef DT$_RZ73
  DT_ENT(RZ73),
#endif
#ifdef DT$_RZ35
  DT_ENT(RZ35),
#endif
#ifdef DT$_RZ24L
  DT_ENT(RZ24L),
#endif
#ifdef DT$_RZ25L
  DT_ENT(RZ25L),
#endif
#ifdef DT$_RZ55L
  DT_ENT(RZ55L),
#endif
#ifdef DT$_RZ56L
  DT_ENT(RZ56L),
#endif
#ifdef DT$_RZ57L
  DT_ENT(RZ57L),
#endif
#ifdef DT$_RA73
  DT_ENT(RA73),
#endif
#ifdef DT$_RZ26
  DT_ENT(RZ26),
#endif
#ifdef DT$_RZ36
  DT_ENT(RZ36),
#endif
#ifdef DT$_RZ74
  DT_ENT(RZ74),
#endif
#ifdef DT$_ESE52
  DT_ENT(ESE52),
#endif
#ifdef DT$_ESE56
  DT_ENT(ESE56),
#endif
#ifdef DT$_ESE58
  DT_ENT(ESE58),
#endif
#ifdef DT$_RZ27
  DT_ENT(RZ27),
#endif
#ifdef DT$_RZ37
  DT_ENT(RZ37),
#endif
#ifdef DT$_RZ34L
  DT_ENT(RZ34L),
#endif
#ifdef DT$_RZ35L
  DT_ENT(RZ35L),
#endif
#ifdef DT$_RZ36L
  DT_ENT(RZ36L),
#endif
#ifdef DT$_RZ38
  DT_ENT(RZ38),
#endif
#ifdef DT$_RZ75
  DT_ENT(RZ75),
#endif
#ifdef DT$_RZ59
  DT_ENT(RZ59),
#endif
#ifdef DT$_RZ13
  DT_ENT(RZ13),
#endif
#ifdef DT$_RZ14
  DT_ENT(RZ14),
#endif
#ifdef DT$_RZ15
  DT_ENT(RZ15),
#endif
#ifdef DT$_RZ16
  DT_ENT(RZ16),
#endif
#ifdef DT$_RZ17
  DT_ENT(RZ17),
#endif
#ifdef DT$_RZ18
  DT_ENT(RZ18),
#endif
#ifdef DT$_EZ51
  DT_ENT(EZ51),
#endif
#ifdef DT$_EZ52
  DT_ENT(EZ52),
#endif
#ifdef DT$_EZ53
  DT_ENT(EZ53),
#endif
#ifdef DT$_EZ54
  DT_ENT(EZ54),
#endif
#ifdef DT$_EZ58
  DT_ENT(EZ58),
#endif
#ifdef DT$_EF51
  DT_ENT(EF51),
#endif
#ifdef DT$_EF52
  DT_ENT(EF52),
#endif
#ifdef DT$_EF53
  DT_ENT(EF53),
#endif
#ifdef DT$_EF54
  DT_ENT(EF54),
#endif
#ifdef DT$_EF58
  DT_ENT(EF58),
#endif
#ifdef DT$_RF36
  DT_ENT(RF36),
#endif
#ifdef DT$_RF37
  DT_ENT(RF37),
#endif
#ifdef DT$_RF74
  DT_ENT(RF74),
#endif
#ifdef DT$_RF75
  DT_ENT(RF75),
#endif
#ifdef DT$_HSZ10
  DT_ENT(HSZ10),
#endif
#ifdef DT$_RZ28
  DT_ENT(RZ28),
#endif
#ifdef DT$_GENERIC_RX
  DT_ENT(GENERIC_RX),
#endif
#ifdef DT$_FD1
  DT_ENT(FD1),
#endif
#ifdef DT$_FD2
  DT_ENT(FD2),
#endif
#ifdef DT$_FD3
  DT_ENT(FD3),
#endif
#ifdef DT$_FD4
  DT_ENT(FD4),
#endif
#ifdef DT$_FD5
  DT_ENT(FD5),
#endif
#ifdef DT$_FD6
  DT_ENT(FD6),
#endif
#ifdef DT$_FD7
  DT_ENT(FD7),
#endif
#ifdef DT$_FD8
  DT_ENT(FD8),
#endif
#ifdef DT$_RZ29
  DT_ENT(RZ29),
#endif
#ifdef DT$_RZ26L
  DT_ENT(RZ26L),
#endif
#ifdef DT$_RRD43
  DT_ENT(RRD43),
#endif
#ifdef DT$_RRD44
  DT_ENT(RRD44),
#endif
#ifdef DT$_HSX00
  DT_ENT(HSX00),
#endif
#ifdef DT$_HSX01
  DT_ENT(HSX01),
#endif
#ifdef DT$_RZ26B
  DT_ENT(RZ26B),
#endif
#ifdef DT$_RZ27B
  DT_ENT(RZ27B),
#endif
#ifdef DT$_RZ28B
  DT_ENT(RZ28B),
#endif
#ifdef DT$_RZ29B
  DT_ENT(RZ29B),
#endif
#ifdef DT$_RZ73B
  DT_ENT(RZ73B),
#endif
#ifdef DT$_RZ74B
  DT_ENT(RZ74B),
#endif
#ifdef DT$_RZ75B
  DT_ENT(RZ75B),
#endif
#ifdef DT$_RWZ21
  DT_ENT(RWZ21),
#endif
#ifdef DT$_RZ27L
  DT_ENT(RZ27L),
#endif
#ifdef DT$_HSZ20
  DT_ENT(HSZ20),
#endif
#ifdef DT$_HSZ40
  DT_ENT(HSZ40),
#endif
#ifdef DT$_HSZ15
  DT_ENT(HSZ15),
#endif
#ifdef DT$_RZ26M
  DT_ENT(RZ26M),
#endif
#ifdef DT$_RW504
  DT_ENT(RW504),
#endif
#ifdef DT$_RW510
  DT_ENT(RW510),
#endif
#ifdef DT$_RW514
  DT_ENT(RW514),
#endif
#ifdef DT$_RW516
  DT_ENT(RW516),
#endif
#ifdef DT$_RWZ52
  DT_ENT(RWZ52),
#endif
#ifdef DT$_RWZ53
  DT_ENT(RWZ53),
#endif
#ifdef DT$_RWZ54
  DT_ENT(RWZ54),
#endif
#ifdef DT$_RWZ31
  DT_ENT(RWZ31),
#endif
#ifdef DT$_EZ31
  DT_ENT(EZ31),
#endif
#ifdef DT$_EZ32
  DT_ENT(EZ32),
#endif
#ifdef DT$_EZ33
  DT_ENT(EZ33),
#endif
#ifdef DT$_EZ34
  DT_ENT(EZ34),
#endif
#ifdef DT$_EZ35
  DT_ENT(EZ35),
#endif
#ifdef DT$_EZ31L
  DT_ENT(EZ31L),
#endif
#ifdef DT$_EZ32L
  DT_ENT(EZ32L),
#endif
#ifdef DT$_EZ33L
  DT_ENT(EZ33L),
#endif
#ifdef DT$_RZ28L
  DT_ENT(RZ28L),
#endif
#ifdef DT$_RWZ51
  DT_ENT(RWZ51),
#endif
#ifdef DT$_EZ56R
  DT_ENT(EZ56R),
#endif
#ifdef DT$_RAID0
  DT_ENT(RAID0),
#endif
#ifdef DT$_RAID5
  DT_ENT(RAID5),
#endif
#ifdef DT$_CONSOLE_CALLBACK
  DT_ENT(CONSOLE_CALLBACK),
#endif
#ifdef DT$_FILES_64
  DT_ENT(FILES_64),
#endif
#ifdef DT$_SWXCR
  DT_ENT(SWXCR),
#endif
#ifdef DT$_TE16
  DT_ENT(TE16),
#endif
#ifdef DT$_TU45
  DT_ENT(TU45),
#endif
#ifdef DT$_TU77
  DT_ENT(TU77),
#endif
#ifdef DT$_TS11
  DT_ENT(TS11),
#endif
#ifdef DT$_TU78
  DT_ENT(TU78),
#endif
#ifdef DT$_TA78
  DT_ENT(TA78),
#endif
#ifdef DT$_TU80
  DT_ENT(TU80),
#endif
#ifdef DT$_TU81
  DT_ENT(TU81),
#endif
#ifdef DT$_TA81
  DT_ENT(TA81),
#endif
#ifdef DT$_TK50
  DT_ENT(TK50),
#endif
#ifdef DT$_MR_TU70
  DT_ENT(MR_TU70),
#endif
#ifdef DT$_MR_TU72
  DT_ENT(MR_TU72),
#endif
#ifdef DT$_MW_TSU05
  DT_ENT(MW_TSU05),
#endif
#ifdef DT$_MW_TSV05
  DT_ENT(MW_TSV05),
#endif
#ifdef DT$_TK70
  DT_ENT(TK70),
#endif
#ifdef DT$_RV20
  DT_ENT(RV20),
#endif
#ifdef DT$_RV80
  DT_ENT(RV80),
#endif
#ifdef DT$_TK60
  DT_ENT(TK60),
#endif
#ifdef DT$_GENERIC_TU
  DT_ENT(GENERIC_TU),
#endif
#ifdef DT$_TA79
  DT_ENT(TA79),
#endif
#ifdef DT$_TAPE9
  DT_ENT(TAPE9),
#endif
#ifdef DT$_TA90
  DT_ENT(TA90),
#endif
#ifdef DT$_TF30
  DT_ENT(TF30),
#endif
#ifdef DT$_TF85
  DT_ENT(TF85),
#endif
#ifdef DT$_TF70
  DT_ENT(TF70),
#endif
#ifdef DT$_RV60
  DT_ENT(RV60),
#endif
#ifdef DT$_TZ30
  DT_ENT(TZ30),
#endif
#ifdef DT$_TM32
  DT_ENT(TM32),
#endif
#ifdef DT$_TZX0
  DT_ENT(TZX0),
#endif
#ifdef DT$_TSZ05
  DT_ENT(TSZ05),
#endif
#ifdef DT$_GENERIC_MK
  DT_ENT(GENERIC_MK),
#endif
#ifdef DT$_TK50S
  DT_ENT(TK50S),
#endif
#ifdef DT$_TZ30S
  DT_ENT(TZ30S),
#endif
#ifdef DT$_TK70L
  DT_ENT(TK70L),
#endif
#ifdef DT$_TLZ04
  DT_ENT(TLZ04),
#endif
#ifdef DT$_TZK10
  DT_ENT(TZK10),
#endif
#ifdef DT$_TSZ07
  DT_ENT(TSZ07),
#endif
#ifdef DT$_TSZ08
  DT_ENT(TSZ08),
#endif
#ifdef DT$_TA90E
  DT_ENT(TA90E),
#endif
#ifdef DT$_TZK11
  DT_ENT(TZK11),
#endif
#ifdef DT$_TZ85
  DT_ENT(TZ85),
#endif
#ifdef DT$_TZ86
  DT_ENT(TZ86),
#endif
#ifdef DT$_TZ87
  DT_ENT(TZ87),
#endif
#ifdef DT$_TZ857
  DT_ENT(TZ857),
#endif
#ifdef DT$_EXABYTE
  DT_ENT(EXABYTE),
#endif
#ifdef DT$_TAPE_LOADER_1
  DT_ENT(TAPE_LOADER_1),
#endif
#ifdef DT$_TA91
  DT_ENT(TA91),
#endif
#ifdef DT$_TLZ06
  DT_ENT(TLZ06),
#endif
#ifdef DT$_TA85
  DT_ENT(TA85),
#endif
#ifdef DT$_TKZ60
  DT_ENT(TKZ60),
#endif
#ifdef DT$_TLZ6
  DT_ENT(TLZ6),
#endif
#ifdef DT$_TZ867
  DT_ENT(TZ867),
#endif
#ifdef DT$_TZ877
  DT_ENT(TZ877),
#endif
#ifdef DT$_TAD85
  DT_ENT(TAD85),
#endif
#ifdef DT$_TF86
  DT_ENT(TF86),
#endif
#ifdef DT$_TKZ09
  DT_ENT(TKZ09),
#endif
#ifdef DT$_TA86
  DT_ENT(TA86),
#endif
#ifdef DT$_TA87
  DT_ENT(TA87),
#endif
#ifdef DT$_TD34
  DT_ENT(TD34),
#endif
#ifdef DT$_TD44
  DT_ENT(TD44),
#endif
#ifdef DT$_HST00
  DT_ENT(HST00),
#endif
#ifdef DT$_HST01
  DT_ENT(HST01),
#endif
#ifdef DT$_TLZ07
  DT_ENT(TLZ07),
#endif
#ifdef DT$_TLZ7
  DT_ENT(TLZ7),
#endif
#ifdef DT$_TZ88
  DT_ENT(TZ88),
#endif
#ifdef DT$_TZ885
  DT_ENT(TZ885),
#endif
#ifdef DT$_TZ887
  DT_ENT(TZ887),
#endif
#ifdef DT$_TZ89
  DT_ENT(TZ89),
#endif
#ifdef DT$_TZ895
  DT_ENT(TZ895),
#endif
#ifdef DT$_TZ897
  DT_ENT(TZ897),
#endif
#ifdef DT$_TZ875
  DT_ENT(TZ875),
#endif
#ifdef DT$_TL810
  DT_ENT(TL810),
#endif
#ifdef DT$_TL820
  DT_ENT(TL820),
#endif
#ifdef DT$_TZ865
  DT_ENT(TZ865),
#endif
#ifdef DT$_TTYUNKN
  DT_ENT(TTYUNKN),
#endif
#ifdef DT$_VT05
  DT_ENT(VT05),
#endif
#ifdef DT$_FT1
  DT_ENT(FT1),
#endif
#ifdef DT$_FT2
  DT_ENT(FT2),
#endif
#ifdef DT$_FT3
  DT_ENT(FT3),
#endif
#ifdef DT$_FT4
  DT_ENT(FT4),
#endif
#ifdef DT$_FT5
  DT_ENT(FT5),
#endif
#ifdef DT$_FT6
  DT_ENT(FT6),
#endif
#ifdef DT$_FT7
  DT_ENT(FT7),
#endif
#ifdef DT$_FT8
  DT_ENT(FT8),
#endif
#ifdef DT$_LAX
  DT_ENT(LAX),
#endif
#ifdef DT$_LA36
  DT_ENT(LA36),
#endif
#ifdef DT$_LA120
  DT_ENT(LA120),
#endif
#ifdef DT$_VT5X
  DT_ENT(VT5X),
#endif
#ifdef DT$_VT52
  DT_ENT(VT52),
#endif
#ifdef DT$_VT55
  DT_ENT(VT55),
#endif
#ifdef DT$_TQ_BTS
  DT_ENT(TQ_BTS),
#endif
#ifdef DT$_TEK401X
  DT_ENT(TEK401X),
#endif
#ifdef DT$_VT100
  DT_ENT(VT100),
#endif
#ifdef DT$_VK100
  DT_ENT(VK100),
#endif
#ifdef DT$_VT173
  DT_ENT(VT173),
#endif
#ifdef DT$_LA34
  DT_ENT(LA34),
#endif
#ifdef DT$_LA38
  DT_ENT(LA38),
#endif
#ifdef DT$_LA12
  DT_ENT(LA12),
#endif
#ifdef DT$_LA24
  DT_ENT(LA24),
#endif
#ifdef DT$_LA100
  DT_ENT(LA100),
#endif
#ifdef DT$_LQP02
  DT_ENT(LQP02),
#endif
#ifdef DT$_VT101
  DT_ENT(VT101),
#endif
#ifdef DT$_VT102
  DT_ENT(VT102),
#endif
#ifdef DT$_VT105
  DT_ENT(VT105),
#endif
#ifdef DT$_VT125
  DT_ENT(VT125),
#endif
#ifdef DT$_VT131
  DT_ENT(VT131),
#endif
#ifdef DT$_VT132
  DT_ENT(VT132),
#endif
#ifdef DT$_DZ11
  DT_ENT(DZ11),
#endif
#ifdef DT$_DZ32
  DT_ENT(DZ32),
#endif
#ifdef DT$_DZ730
  DT_ENT(DZ730),
#endif
#ifdef DT$_DMZ32
  DT_ENT(DMZ32),
#endif
#ifdef DT$_DHV
  DT_ENT(DHV),
#endif
#ifdef DT$_DHU
  DT_ENT(DHU),
#endif
#ifdef DT$_SLU
  DT_ENT(SLU),
#endif
#ifdef DT$_TERM9
  DT_ENT(TERM9),
#endif
#ifdef DT$_LAT
  DT_ENT(LAT),
#endif
#ifdef DT$_VS100
  DT_ENT(VS100),
#endif
#ifdef DT$_VS125
  DT_ENT(VS125),
#endif
#ifdef DT$_VL_VS8200
  DT_ENT(VL_VS8200),
#endif
#ifdef DT$_VD
  DT_ENT(VD),
#endif
#ifdef DT$_DECW_OUTPUT
  DT_ENT(DECW_OUTPUT),
#endif
#ifdef DT$_DECW_INPUT
  DT_ENT(DECW_INPUT),
#endif
#ifdef DT$_DECW_PSEUDO
  DT_ENT(DECW_PSEUDO),
#endif
#ifdef DT$_DMC11
  DT_ENT(DMC11),
#endif
#ifdef DT$_DMR11
  DT_ENT(DMR11),
#endif
#ifdef DT$_XK_3271
  DT_ENT(XK_3271),
#endif
#ifdef DT$_XJ_2780
  DT_ENT(XJ_2780),
#endif
#ifdef DT$_NW_X25
  DT_ENT(NW_X25),
#endif
#ifdef DT$_NV_X29
  DT_ENT(NV_X29),
#endif
#ifdef DT$_SB_ISB11
  DT_ENT(SB_ISB11),
#endif
#ifdef DT$_MX_MUX200
  DT_ENT(MX_MUX200),
#endif
#ifdef DT$_DMP11
  DT_ENT(DMP11),
#endif
#ifdef DT$_DMF32
  DT_ENT(DMF32),
#endif
#ifdef DT$_XV_3271
  DT_ENT(XV_3271),
#endif
#ifdef DT$_CI
  DT_ENT(CI),
#endif
#ifdef DT$_NI
  DT_ENT(NI),
#endif
#ifdef DT$_UNA11
  DT_ENT(UNA11),
#endif
#ifdef DT$_DEUNA
  DT_ENT(DEUNA),
#endif
#ifdef DT$_YN_X25
  DT_ENT(YN_X25),
#endif
#ifdef DT$_YO_X25
  DT_ENT(YO_X25),
#endif
#ifdef DT$_YP_ADCCP
  DT_ENT(YP_ADCCP),
#endif
#ifdef DT$_YQ_3271
  DT_ENT(YQ_3271),
#endif
#ifdef DT$_YR_DDCMP
  DT_ENT(YR_DDCMP),
#endif
#ifdef DT$_YS_SDLC
  DT_ENT(YS_SDLC),
#endif
#ifdef DT$_UK_KTC32
  DT_ENT(UK_KTC32),
#endif
#ifdef DT$_DEQNA
  DT_ENT(DEQNA),
#endif
#ifdef DT$_DMV11
  DT_ENT(DMV11),
#endif
#ifdef DT$_ES_LANCE
  DT_ENT(ES_LANCE),
#endif
#ifdef DT$_DELUA
  DT_ENT(DELUA),
#endif
#ifdef DT$_NQ_3271
  DT_ENT(NQ_3271),
#endif
#ifdef DT$_DMB32
  DT_ENT(DMB32),
#endif
#ifdef DT$_YI_KMS11K
  DT_ENT(YI_KMS11K),
#endif
#ifdef DT$_ET_DEBNT
  DT_ENT(ET_DEBNT),
#endif
#ifdef DT$_ET_DEBNA
  DT_ENT(ET_DEBNA),
#endif
#ifdef DT$_SJ_DSV11
  DT_ENT(SJ_DSV11),
#endif
#ifdef DT$_SL_DSB32
  DT_ENT(SL_DSB32),
#endif
#ifdef DT$_ZS_DST32
  DT_ENT(ZS_DST32),
#endif
#ifdef DT$_XQ_DELQA
  DT_ENT(XQ_DELQA),
#endif
#ifdef DT$_ET_DEBNI
  DT_ENT(ET_DEBNI),
#endif
#ifdef DT$_EZ_SGEC
  DT_ENT(EZ_SGEC),
#endif
#ifdef DT$_EX_DEMNA
  DT_ENT(EX_DEMNA),
#endif
#ifdef DT$_DIV32
  DT_ENT(DIV32),
#endif
#ifdef DT$_XQ_DEQTA
  DT_ENT(XQ_DEQTA),
#endif
#ifdef DT$_FT_NI
  DT_ENT(FT_NI),
#endif
#ifdef DT$_EP_LANCE
  DT_ENT(EP_LANCE),
#endif
#ifdef DT$_KWV32
  DT_ENT(KWV32),
#endif
#ifdef DT$_SM_DSF32
  DT_ENT(SM_DSF32),
#endif
#ifdef DT$_FX_DEMFA
  DT_ENT(FX_DEMFA),
#endif
#ifdef DT$_SF_DSF32
  DT_ENT(SF_DSF32),
#endif
#ifdef DT$_SE_DUP11
  DT_ENT(SE_DUP11),
#endif
#ifdef DT$_SE_DPV11
  DT_ENT(SE_DPV11),
#endif
#ifdef DT$_ZT_DSW
  DT_ENT(ZT_DSW),
#endif
#ifdef DT$_FC_DEFZA
  DT_ENT(FC_DEFZA),
#endif
#ifdef DT$_EC_PMAD
  DT_ENT(EC_PMAD),
#endif
#ifdef DT$_EZ_TGEC
  DT_ENT(EZ_TGEC),
#endif
#ifdef DT$_EA_DEANA
  DT_ENT(EA_DEANA),
#endif
#ifdef DT$_EY_NITC2
  DT_ENT(EY_NITC2),
#endif
#ifdef DT$_ER_DE422
  DT_ENT(ER_DE422),
#endif
#ifdef DT$_ER_DE200
  DT_ENT(ER_DE200),
#endif
#ifdef DT$_EW_TULIP
  DT_ENT(EW_TULIP),
#endif
#ifdef DT$_FA_DEFAA
  DT_ENT(FA_DEFAA),
#endif
#ifdef DT$_FC_DEFTA
  DT_ENT(FC_DEFTA),
#endif
#ifdef DT$_FQ_DEFQA
  DT_ENT(FQ_DEFQA),
#endif
#ifdef DT$_FR_DEFEA
  DT_ENT(FR_DEFEA),
#endif
#ifdef DT$_FW_DEFPA
  DT_ENT(FW_DEFPA),
#endif
#ifdef DT$_IC_DETRA
  DT_ENT(IC_DETRA),
#endif
#ifdef DT$_IQ_DEQRA
  DT_ENT(IQ_DEQRA),
#endif
#ifdef DT$_IR_DW300
  DT_ENT(IR_DW300),
#endif
#ifdef DT$_ZR_SCC
  DT_ENT(ZR_SCC),
#endif
#ifdef DT$_ZY_DSYT1
  DT_ENT(ZY_DSYT1),
#endif
#ifdef DT$_ZE_DNSES
  DT_ENT(ZE_DNSES),
#endif
#ifdef DT$_ER_DE425
  DT_ENT(ER_DE425),
#endif
#ifdef DT$_EW_DE435
  DT_ENT(EW_DE435),
#endif
#ifdef DT$_ER_DE205
  DT_ENT(ER_DE205),
#endif
#ifdef DT$_HC_OTTO
  DT_ENT(HC_OTTO),
#endif
#ifdef DT$_ZS_PBXDI
  DT_ENT(ZS_PBXDI),
#endif
#ifdef DT$_EL_ELAN
  DT_ENT(EL_ELAN),
#endif
#ifdef DT$_HW_OTTO
  DT_ENT(HW_OTTO),
#endif
#ifdef DT$_EO_3C598
  DT_ENT(EO_3C598),
#endif
#ifdef DT$_IW_TC4048
  DT_ENT(IW_TC4048),
#endif
#ifdef DT$_EW_DE450
  DT_ENT(EW_DE450),
#endif
#ifdef DT$_EW_DE500
  DT_ENT(EW_DE500),
#endif
#ifdef DT$_CL_CLIP
  DT_ENT(CL_CLIP),
#endif
#ifdef DT$_ZW_PBXDP
  DT_ENT(ZW_PBXDP),
#endif
#ifdef DT$_HW_METEOR
  DT_ENT(HW_METEOR),
#endif
#ifdef DT$_LP11
  DT_ENT(LP11),
#endif
#ifdef DT$_LA11
  DT_ENT(LA11),
#endif
#ifdef DT$_LA180
  DT_ENT(LA180),
#endif
#ifdef DT$_LC_DMF32
  DT_ENT(LC_DMF32),
#endif
#ifdef DT$_LI_DMB32
  DT_ENT(LI_DMB32),
#endif
#ifdef DT$_PRTR9
  DT_ENT(PRTR9),
#endif
#ifdef DT$_SCSI_SCANNER_1
  DT_ENT(SCSI_SCANNER_1),
#endif
#ifdef DT$_PC_PRINTER
  DT_ENT(PC_PRINTER),
#endif
#ifdef DT$_CR11
  DT_ENT(CR11),
#endif
#ifdef DT$_MBX
  DT_ENT(MBX),
#endif
#ifdef DT$_SHRMBX
  DT_ENT(SHRMBX),
#endif
#ifdef DT$_NULL
  DT_ENT(NULL),
#endif
#ifdef DT$_PIPE
  DT_ENT(PIPE),
#endif
#ifdef DT$_DAP_DEVICE
  DT_ENT(DAP_DEVICE),
#endif
#ifdef DT$_LPA11
  DT_ENT(LPA11),
#endif
#ifdef DT$_DR780
  DT_ENT(DR780),
#endif
#ifdef DT$_DR750
  DT_ENT(DR750),
#endif
#ifdef DT$_DR11W
  DT_ENT(DR11W),
#endif
#ifdef DT$_PCL11R
  DT_ENT(PCL11R),
#endif
#ifdef DT$_PCL11T
  DT_ENT(PCL11T),
#endif
#ifdef DT$_DR11C
  DT_ENT(DR11C),
#endif
#ifdef DT$_BS_DT07
  DT_ENT(BS_DT07),
#endif
#ifdef DT$_XP_PCL11B
  DT_ENT(XP_PCL11B),
#endif
#ifdef DT$_IX_IEX11
  DT_ENT(IX_IEX11),
#endif
#ifdef DT$_FP_FEPCM
  DT_ENT(FP_FEPCM),
#endif
#ifdef DT$_TK_FCM
  DT_ENT(TK_FCM),
#endif
#ifdef DT$_XI_DR11C
  DT_ENT(XI_DR11C),
#endif
#ifdef DT$_XA_DRV11WA
  DT_ENT(XA_DRV11WA),
#endif
#ifdef DT$_DRB32
  DT_ENT(DRB32),
#endif
#ifdef DT$_HX_DRQ3B
  DT_ENT(HX_DRQ3B),
#endif
#ifdef DT$_DECVOICE
  DT_ENT(DECVOICE),
#endif
#ifdef DT$_DTC04
  DT_ENT(DTC04),
#endif
#ifdef DT$_DTC05
  DT_ENT(DTC05),
#endif
#ifdef DT$_DTCN5
  DT_ENT(DTCN5),
#endif
#ifdef DT$_AMD79C30A
  DT_ENT(AMD79C30A),
#endif
#ifdef DT$_CI780
  DT_ENT(CI780),
#endif
#ifdef DT$_CI750
  DT_ENT(CI750),
#endif
#ifdef DT$_UQPORT
  DT_ENT(UQPORT),
#endif
#ifdef DT$_UDA50
  DT_ENT(UDA50),
#endif
#ifdef DT$_UDA50A
  DT_ENT(UDA50A),
#endif
#ifdef DT$_LESI
  DT_ENT(LESI),
#endif
#ifdef DT$_TU81P
  DT_ENT(TU81P),
#endif
#ifdef DT$_RDRX
  DT_ENT(RDRX),
#endif
#ifdef DT$_TK50P
  DT_ENT(TK50P),
#endif
#ifdef DT$_RUX50P
  DT_ENT(RUX50P),
#endif
#ifdef DT$_RC26P
  DT_ENT(RC26P),
#endif
#ifdef DT$_QDA50
  DT_ENT(QDA50),
#endif
#ifdef DT$_KDA50
  DT_ENT(KDA50),
#endif
#ifdef DT$_BDA50
  DT_ENT(BDA50),
#endif
#ifdef DT$_KDB50
  DT_ENT(KDB50),
#endif
#ifdef DT$_RRD50P
  DT_ENT(RRD50P),
#endif
#ifdef DT$_QDA25
  DT_ENT(QDA25),
#endif
#ifdef DT$_KDA25
  DT_ENT(KDA25),
#endif
#ifdef DT$_BCI750
  DT_ENT(BCI750),
#endif
#ifdef DT$_BCA
  DT_ENT(BCA),
#endif
#ifdef DT$_RQDX3
  DT_ENT(RQDX3),
#endif
#ifdef DT$_NISCA
  DT_ENT(NISCA),
#endif
#ifdef DT$_AIO
  DT_ENT(AIO),
#endif
#ifdef DT$_KFBTA
  DT_ENT(KFBTA),
#endif
#ifdef DT$_AIE
  DT_ENT(AIE),
#endif
#ifdef DT$_DEBNT
  DT_ENT(DEBNT),
#endif
#ifdef DT$_BSA
  DT_ENT(BSA),
#endif
#ifdef DT$_KSB50
  DT_ENT(KSB50),
#endif
#ifdef DT$_TK70P
  DT_ENT(TK70P),
#endif
#ifdef DT$_RV20P
  DT_ENT(RV20P),
#endif
#ifdef DT$_RV80P
  DT_ENT(RV80P),
#endif
#ifdef DT$_TK60P
  DT_ENT(TK60P),
#endif
#ifdef DT$_SII
  DT_ENT(SII),
#endif
#ifdef DT$_KFSQSA
  DT_ENT(KFSQSA),
#endif
#ifdef DT$_KFQSA
  DT_ENT(KFQSA),
#endif
#ifdef DT$_SHAC
  DT_ENT(SHAC),
#endif
#ifdef DT$_CIXCD
  DT_ENT(CIXCD),
#endif
#ifdef DT$_N5380
  DT_ENT(N5380),
#endif
#ifdef DT$_SCSII
  DT_ENT(SCSII),
#endif
#ifdef DT$_HSX50
  DT_ENT(HSX50),
#endif
#ifdef DT$_KDM70
  DT_ENT(KDM70),
#endif
#ifdef DT$_TM32P
  DT_ENT(TM32P),
#endif
#ifdef DT$_TK7LP
  DT_ENT(TK7LP),
#endif
#ifdef DT$_SWIFT
  DT_ENT(SWIFT),
#endif
#ifdef DT$_N53C94
  DT_ENT(N53C94),
#endif
#ifdef DT$_KFMSA
  DT_ENT(KFMSA),
#endif
#ifdef DT$_SCSI_XTENDR
  DT_ENT(SCSI_XTENDR),
#endif
#ifdef DT$_FT_TRACE_RAM
  DT_ENT(FT_TRACE_RAM),
#endif
#ifdef DT$_XVIB
  DT_ENT(XVIB),
#endif
#ifdef DT$_XZA_SCSI
  DT_ENT(XZA_SCSI),
#endif
#ifdef DT$_XZA_DSSI
  DT_ENT(XZA_DSSI),
#endif
#ifdef DT$_N710_SCSI
  DT_ENT(N710_SCSI),
#endif
#ifdef DT$_N710_DSSI
  DT_ENT(N710_DSSI),
#endif
#ifdef DT$_AHA1742A
  DT_ENT(AHA1742A),
#endif
#ifdef DT$_TZA_SCSI
  DT_ENT(TZA_SCSI),
#endif
#ifdef DT$_N810_SCSI
  DT_ENT(N810_SCSI),
#endif
#ifdef DT$_CIPCA
  DT_ENT(CIPCA),
#endif
#ifdef DT$_ISP1020
  DT_ENT(ISP1020),
#endif
#ifdef DT$_MC_SPUR
  DT_ENT(MC_SPUR),
#endif
#ifdef DT$_PZA_SCSI
  DT_ENT(PZA_SCSI),
#endif
#ifdef DT$_DN11
  DT_ENT(DN11),
#endif
#ifdef DT$_PV
  DT_ENT(PV),
#endif
#ifdef DT$_SFUN9
  DT_ENT(SFUN9),
#endif
#ifdef DT$_USER9
  DT_ENT(USER9),
#endif
#ifdef DT$_GENERIC_SCSI
  DT_ENT(GENERIC_SCSI),
#endif
#ifdef DT$_DMA_520
  DT_ENT(DMA_520),
#endif
#ifdef DT$_T3270
  DT_ENT(T3270),
#endif
  {NULL, 0}
};

struct GenericID {
  char *GenericName; /* Pointer to the item name */
  int  SyscallValue;      /* Value to use in the getDVI item list */
  int  BufferLen;     /* Length the return va buf needs to be. (no nul */
                      /* terminators, so must be careful with the return */
                      /* values. */
  int  ReturnType;    /* Type of data the item returns */
  int  InOrOut;       /* Is this an input or an output item? */
};

struct GenericID DevInfoList[] =
{
#ifdef DVI$_ACPPID
  DVI_ENT(ACPPID, 4, IS_LONGWORD),
#endif
#ifdef DVI$_ACPTYPE
  DVI_ENT(ACPTYPE, 4, IS_ENUM),
#endif
#ifdef DVI$_ALLDEVNAM
  DVI_ENT(ALLDEVNAM, 64, IS_STRING),
#endif
#ifdef DVI$_ALLOCLASS
  DVI_ENT(ALLOCLASS, 4, IS_LONGWORD),
#endif
#ifdef DVI$_ALT_HOST_AVAIL
  DVI_ENT(ALT_HOST_AVAIL, 4, IS_LONGWORD),
#endif
#ifdef DVI$_ALT_HOST_NAME
  DVI_ENT(ALT_HOST_NAME, 64, IS_STRING),
#endif
#ifdef DVI$_ALT_HOST_TYPE
  DVI_ENT(ALT_HOST_TYPE, 64, IS_STRING),
#endif
#ifdef DVI$_CLUSTER
  DVI_ENT(CLUSTER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_CYLINDERS
  DVI_ENT(CYLINDERS, 4, IS_LONGWORD),
#endif
#ifdef DVI$_DEVBUFSIZ
  DVI_ENT(DEVBUFSIZ, 4, IS_LONGWORD),
#endif
#ifdef DVI$_DEVCHAR
  DVI_ENT(DEVCHAR, 4, IS_BITMAP),
#endif
#ifdef DVI$_DEVCLASS
  DVI_ENT(DEVCLASS, 4, IS_ENUM),
#endif
#ifdef DVI$_DEVDEPEND
  DVI_ENT(DEVDEPEND, 4, IS_BITMAP),
#endif
#ifdef DVI$_DEVDEPEND2
  DVI_ENT(DEVDEPEND2, 4, IS_BITMAP),
#endif
#ifdef DVI$_DEVICE_TYPE_NAME
  DVI_ENT(DEVICE_TYPE_NAME, 64, IS_STRING),
#endif
#ifdef DVI$_DEVLOCKNAM
  DVI_ENT(DEVLOCKNAM, 64, IS_STRING),
#endif
#ifdef DVI$_DEVNAM
  DVI_ENT(DEVNAM, 64, IS_STRING),
#endif
#ifdef DVI$_DEVSTS
  DVI_ENT(DEVSTS, 4, IS_BITMAP),
#endif
#ifdef DVI$_DEVTYPE
  DVI_ENT(DEVTYPE, 4, IS_LONGWORD),
#endif
#ifdef DVI$_DFS_ACCESS
  DVI_ENT(DFS_ACCESS, 4, IS_LONGWORD),
#endif
#ifdef DVI$_DISPLAY_DEVNAM
  DVI_ENT(DISPLAY_DEVNAM, 256, IS_STRING),
#endif
#ifdef DVI$_ERRCNT
  DVI_ENT(ERRCNT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_FREEBLOCKS
  DVI_ENT(FREEBLOCKS, 4, IS_LONGWORD),
#endif
#ifdef DVI$_FULLDEVNAM
  DVI_ENT(FULLDEVNAM, 64, IS_STRING),
#endif
#ifdef DVI$_HOST_AVAIL
  DVI_ENT(HOST_AVAIL, 4, IS_LONGWORD),
#endif
#ifdef DVI$_HOST_COUNT
  DVI_ENT(HOST_COUNT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_HOST_NAME
  DVI_ENT(HOST_NAME, 64, IS_STRING),
#endif
#ifdef DVI$_HOST_TYPE
  DVI_ENT(HOST_TYPE, 64, IS_STRING),
#endif
#ifdef DVI$_LOCKID
  DVI_ENT(LOCKID, 4, IS_LONGWORD),
#endif
#ifdef DVI$_LOGVOLNAM
  DVI_ENT(LOGVOLNAM, 64, IS_STRING),
#endif
#ifdef DVI$_MAXBLOCK
  DVI_ENT(MAXBLOCK, 4, IS_LONGWORD),
#endif
#ifdef DVI$_MAXFILES
  DVI_ENT(MAXFILES, 4, IS_LONGWORD),
#endif
#ifdef DVI$_MEDIA_ID
  DVI_ENT(MEDIA_ID, 4, IS_LONGWORD),
#endif
#ifdef DVI$_MEDIA_NAME
  DVI_ENT(MEDIA_NAME, 64, IS_STRING),
#endif
#ifdef DVI$_MEDIA_TYPE
  DVI_ENT(MEDIA_TYPE, 64, IS_STRING),
#endif
#ifdef DVI$_MOUNTCNT
  DVI_ENT(MOUNTCNT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_MSCP_UNIT_NUMBER
  DVI_ENT(MSCP_UNIT_NUMBER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_NEXTDEVNAM
  DVI_ENT(NEXTDEVNAM, 64, IS_STRING),
#endif
#ifdef DVI$_OPCNT
  DVI_ENT(OPCNT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_OWNUIC
  DVI_ENT(OWNUIC, 4, IS_LONGWORD),
#endif
#ifdef DVI$_PID
  DVI_ENT(PID, 4, IS_LONGWORD),
#endif
#ifdef DVI$_RECSIZ
  DVI_ENT(RECSIZ, 4, IS_LONGWORD),
#endif
#ifdef DVI$_REFCNT
  DVI_ENT(REFCNT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_REMOTE_DEVICE
  DVI_ENT(REMOTE_DEVICE, 4, IS_LONGWORD),
#endif
#ifdef DVI$_ROOTDEVNAM
  DVI_ENT(ROOTDEVNAM, 64, IS_STRING),
#endif
#ifdef DVI$_SECTORS
  DVI_ENT(SECTORS, 4, IS_LONGWORD),
#endif
#ifdef DVI$_SERIALNUM
  DVI_ENT(SERIALNUM, 4, IS_LONGWORD),
#endif
#ifdef DVI$_SERVED_DEVICE
  DVI_ENT(SERVED_DEVICE, 4, IS_LONGWORD),
#endif
#ifdef DVI$_SHDW_CATCHUP_COPYING
  DVI_ENT(SHDW_CATCHUP_COPYING, 4, IS_LONGWORD),
#endif
#ifdef DVI$_SHDW_FAILED_MEMBER
  DVI_ENT(SHDW_FAILED_MEMBER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_SHDW_MASTER
  DVI_ENT(SHDW_MASTER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_SHDW_MASTER_NAME
  DVI_ENT(SHDW_MASTER_NAME, 64, IS_STRING),
#endif
#ifdef DVI$_SHDW_MEMBER
  DVI_ENT(SHDW_MEMBER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_SHDW_MERGE_COPYING
  DVI_ENT(SHDW_MERGE_COPYING, 4, IS_LONGWORD),
#endif
#ifdef DVI$_SHDW_NEXT_MBR_NAME
  DVI_ENT(SHDW_NEXT_MBR_NAME, 64, IS_STRING),
#endif
#ifdef DVI$_STS
  DVI_ENT(STS, 4, IS_BITMAP),
#endif
#ifdef DVI$_TRACKS
  DVI_ENT(TRACKS, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TRANSCNT
  DVI_ENT(TRANSCNT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_ACCPORNAM
  DVI_ENT(TT_ACCPORNAM, 64, IS_STRING),
#endif
#ifdef DVI$_TT_CHARSET
  DVI_ENT(TT_CHARSET, 4, IS_BITMAP),
#endif
#ifdef DVI$_TT_CS_HANGUL
  DVI_ENT(TT_CS_HANGUL, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_CS_HANYU
  DVI_ENT(TT_CS_HANYU, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_CS_HANZI
  DVI_ENT(TT_CS_HANZI, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_CS_KANA
  DVI_ENT(TT_CS_KANA, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_CS_KANJI
  DVI_ENT(TT_CS_KANJI, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_CS_THAI
  DVI_ENT(TT_CS_THAI, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_PHYDEVNAM
  DVI_ENT(TT_PHYDEVNAM, 64, IS_STRING),
#endif
#ifdef DVI$_UNIT
  DVI_ENT(UNIT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_VOLCOUNT
  DVI_ENT(VOLCOUNT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_VOLNAM
  DVI_ENT(VOLNAM, 12, IS_STRING),
#endif
#ifdef DVI$_VOLNUMBER
  DVI_ENT(VOLNUMBER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_VOLSETMEM
  DVI_ENT(VOLSETMEM, 4, IS_LONGWORD),
#endif
#ifdef DVI$_VPROT
  DVI_ENT(VPROT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_NOECHO
  DVI_ENT(TT_NOECHO, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_NOTYPEAHD
  DVI_ENT(TT_NOTYPEAHD, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_HOSTSYNC
  DVI_ENT(TT_HOSTSYNC, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_TTSYNC
  DVI_ENT(TT_TTSYNC, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_ESCAPE
  DVI_ENT(TT_ESCAPE, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_LOWER
  DVI_ENT(TT_LOWER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_MECHTAB
  DVI_ENT(TT_MECHTAB, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_WRAP
  DVI_ENT(TT_WRAP, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_LFFILL
  DVI_ENT(TT_LFFILL, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_SCOPE
  DVI_ENT(TT_SCOPE, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_CRFILL
  DVI_ENT(TT_CRFILL, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_SETSPEED
  DVI_ENT(TT_SETSPEED, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_EIGHTBIT
  DVI_ENT(TT_EIGHTBIT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_MBXDSABL
  DVI_ENT(TT_MBXDSABL, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_READSYNC
  DVI_ENT(TT_READSYNC, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_MECHFORM
  DVI_ENT(TT_MECHFORM, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_NOBRDCST
  DVI_ENT(TT_NOBRDCST, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_HALFDUP
  DVI_ENT(TT_HALFDUP, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_MODEM
  DVI_ENT(TT_MODEM, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_OPER
  DVI_ENT(TT_OPER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_LOCALECHO
  DVI_ENT(TT_LOCALECHO, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_AUTOBAUD
  DVI_ENT(TT_AUTOBAUD, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_PAGE
  DVI_ENT(TT_PAGE, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_HANGUP
  DVI_ENT(TT_HANGUP, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_MODHANGUP
  DVI_ENT(TT_MODHANGUP, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_BRDCSTMBX
  DVI_ENT(TT_BRDCSTMBX, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_DMA
  DVI_ENT(TT_DMA, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_ALTYPEAHD
  DVI_ENT(TT_ALTYPEAHD, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_ANSICRT
  DVI_ENT(TT_ANSICRT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_REGIS
  DVI_ENT(TT_REGIS, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_AVO
  DVI_ENT(TT_AVO, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_EDIT
  DVI_ENT(TT_EDIT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_BLOCK
  DVI_ENT(TT_BLOCK, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_DECCRT
  DVI_ENT(TT_DECCRT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_EDITING
  DVI_ENT(TT_EDITING, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_INSERT
  DVI_ENT(TT_INSERT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_DIALUP
  DVI_ENT(TT_DIALUP, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_SECURE
  DVI_ENT(TT_SECURE, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_FALLBACK
  DVI_ENT(TT_FALLBACK, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_DISCONNECT
  DVI_ENT(TT_DISCONNECT, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_PASTHRU
  DVI_ENT(TT_PASTHRU, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_SIXEL
  DVI_ENT(TT_SIXEL, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_PRINTER
  DVI_ENT(TT_PRINTER, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_APP_KEYPAD
  DVI_ENT(TT_APP_KEYPAD, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_DRCS
  DVI_ENT(TT_DRCS, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_SYSPWD
  DVI_ENT(TT_SYSPWD, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_DECCRT2
  DVI_ENT(TT_DECCRT2, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_DECCRT3
  DVI_ENT(TT_DECCRT3, 4, IS_LONGWORD),
#endif
#ifdef DVI$_TT_DECCRT4
  DVI_ENT(TT_DECCRT4, 4, IS_LONGWORD),
#endif
  {NULL, 0, 0, 0}
};


struct GenericID MountList[] =
{
  MNT_ENT(ACCESSED, 4, IS_LONGWORD),
  MNT_ENT(BLOCKSIZE, 4, IS_LONGWORD),
  MNT_ENT(COMMENT, 78, IS_STRING),
  MNT_ENT(DENSITY, 4, IS_LONGWORD),
  MNT_ENT(DEVNAM, 64, IS_STRING),
  MNT_ENT(EXTENSION, 4, IS_LONGWORD),
  MNT_ENT(EXTENT, 4, IS_LONGWORD),
  MNT_ENT(FILEID, 4, IS_LONGWORD),
  MNT_ENT(FLAGS, 8, IS_BITMAP),
  MNT_ENT(LIMIT, 4, IS_LONGWORD),
  MNT_ENT(LOGNAM, 64, IS_STRING),
  MNT_ENT(OWNER, 4, IS_LONGWORD),
  MNT_ENT(PROCESSOR, 255, IS_STRING),
  MNT_ENT(QUOTA, 4, IS_LONGWORD),
  MNT_ENT(RECORDSIZ, 4, IS_LONGWORD),
  MNT_ENT(SHAMEM, 64, IS_STRING),
  MNT_ENT(SHANAM, 64, IS_STRING),
  MNT_ENT(UNDEFINED_FAT, 4, IS_LONGWORD),
  MNT_ENT(VOLNAM, 64, IS_STRING),
  MNT_ENT(VOLSET, 128, IS_STRING),
  MNT_ENT(VPROT, 4, IS_LONGWORD),
  MNT_ENT(WINDOW, 4, IS_LONGWORD),
  {NULL, 0, 0, 0}
};

struct GenericID InitList[] =
{
  INI_ENT(ACCESSED, 4, IS_LONGWORD),
  INI_ENT(BADBLOCKS_LBN, 512, IS_STRING),
  INI_ENT(BADBLOCKS_SEC, 512, IS_STRING),
  INI_ENT(CLUSTERSIZE, 4, IS_LONGWORD),
  INI_ENT(COMPACTION, 4, IS_LONGWORD),
  INI_ENT(NO_COMPACTION, 4, IS_LONGWORD),
  INI_ENT(DENSITY, 4, IS_ENUM),
  INI_ENT(DIRECTORIES, 4, IS_LONGWORD),
  INI_ENT(ERASE, 4, IS_LONGWORD),
  INI_ENT(NO_ERASE, 4, IS_LONGWORD),
  INI_ENT(EXTENSION, 4, IS_LONGWORD),
  INI_ENT(FPROT, 4, IS_LONGWORD),
  INI_ENT(HEADERS, 4, IS_LONGWORD),
  INI_ENT(HIGHWATER, 4, IS_LONGWORD),
  INI_ENT(NO_HIGHWATER, 4, IS_LONGWORD),
  INI_ENT(HOMEBLOCKS, 4, IS_ENUM),
  INI_ENT(INDEX_BEGINNING, 4, IS_LONGWORD),
  INI_ENT(INDEX_BLOCK, 4, IS_LONGWORD),
  INI_ENT(INDEX_END, 4, IS_LONGWORD),
  INI_ENT(INDEX_MIDDLE, 4, IS_LONGWORD),
  INI_ENT(INTERCHANGE, 4, IS_LONGWORD),
  INI_ENT(LABEL_ACCESS, 1, IS_STRING),
  INI_ENT(LABEL_VOLO, 14, IS_STRING),
  INI_ENT(MAXFILES, 4, IS_LONGWORD),
  INI_ENT(OVR_ACCESS, 4, IS_LONGWORD),
  INI_ENT(NO_OVR_ACCESS, 4, IS_LONGWORD),
  INI_ENT(OVR_EXP, 4, IS_LONGWORD),
  INI_ENT(NO_OVR_EXP, 4, IS_LONGWORD),
  INI_ENT(OVR_VOLO, 4, IS_LONGWORD),
  INI_ENT(NO_OVR_VOLO, 4, IS_LONGWORD),
  INI_ENT(OWNER, 4, IS_LONGWORD),
  INI_ENT(READCHECK, 4, IS_LONGWORD),
  INI_ENT(NO_READCHECK, 4, IS_LONGWORD),
  INI_ENT(SIZE, 4, IS_LONGWORD),
  INI_ENT(STRUCTURE_LEVEL_1, 4, IS_LONGWORD),
  INI_ENT(STRUCTURE_LEVEL_2, 4, IS_LONGWORD),
  INI_ENT(USER_NAME, 12, IS_STRING),
  INI_ENT(VERIFIED, 4, IS_LONGWORD),
  INI_ENT(NO_VERIFIED, 4, IS_LONGWORD),
  INI_ENT(VPROT, 4, IS_LONGWORD),
  INI_ENT(WINDOW, 4, IS_LONGWORD),
  INI_ENT(WRITECHECK, 4, IS_LONGWORD),
  INI_ENT(NO_WRITECHECK, 4, IS_LONGWORD),
  {NULL, 0, 0, 0, 0}
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

/* Take an access mode SV and return the real mode */
int
decode_accmode(SV *AccMode)
{
  char *AccessString;

  if (AccMode == &PL_sv_undef) {
    return 0;
  } else {
    AccessString = SvPV(AccMode, PL_na);
    if (!strcmp(AccessString, "KERNEL")) {
      return(PSL$C_KERNEL);
    }
    if (!strcmp(AccessString, "EXEC")) {
      return(PSL$C_EXEC);
    }
    if (!strcmp(AccessString, "SUPER")) {
      return(PSL$C_SUPER);
    }
    if (!strcmp(AccessString, "USER")) {
      return(PSL$C_USER);
    }
  }

  return 0;
}
  
/* take a class name and return the corresponding code */
int
dev_class_decode(SV *ClassNameSV)
{
  int ClassCode = -1;
  char *ClassName = NULL;
  int i;
  
  /* Is it undef? If so, return 0 */
  if (ClassNameSV == &PL_sv_undef) {
    ClassCode = 0;
  } else {
    ClassName = SvPV(ClassNameSV, PL_na);
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
  if (TypeNameSV == &PL_sv_undef) {
    TypeCode = 0;
  } else {
    TypeName = SvPV(TypeNameSV, PL_na);
    for (i=0; DevTypeList[i].DevTypeName; i++) {
      if (!strcmp(TypeName, DevTypeList[i].DevTypeName)) {
        TypeCode = DevTypeList[i].DevTypeValue;
        break;
      }
    }
  }

  return TypeCode;
}

/* Take a pointer to a bitmap hash (like decode_bitmap gives), an item */
/* code, and a pointer to the output buffer and encode the bitmap */
void
generic_bitmap_encode(HV * FlagHV, int ItemCode, void *Buffer)
{
  char *FlagName;
  I32 FlagLen;
  int *EncodedValue; /* Pointer to an integer

  /* Shut Dec C up */
  FlagName = NULL;

  /* Buffer's a pointer to an integer array, really it is */
  EncodedValue = Buffer;

  /* Initialize our hash iterator */
  hv_iterinit(FlagHV);

  /* Rip through the hash */
  while (hv_iternextsv(FlagHV, &FlagName, &FlagLen)) {
    
    switch (ItemCode) {
    case MNT$_FLAGS:
      BME_D(CLUSTER);
      BME_D(FOREIGN);
      BME_D(GROUP);
/*      BME_D(INCLUDE); */
      BME_D(INIT_CONT);
      BME_D(MESSAGE);
      BME_D(MULTI_VOL);
      BME_D(NOASSIST);
      BME_D(NOAUTO);
      BME_D(NOCACHE);
      BME_D(NOCOPY);
      BME_D(NODISKQ);
      BME_D(NOHDR3);
      BME_D(NOLABEL);
      BME_D(NOMNTVER);
      BME_D(NOREBUILD);
      BME_D(NOUNLOAD);
      BME_D(NOWRITE);
      BME_D(OVR_ACCESS);
      BME_D(OVR_EXP);
      BME_D(OVR_IDENT);
      BME_D(OVR_LOCK);
      BME_D(OVR_SETID);
      BME_D(OVR_SHAMEM);
      BME_D(OVR_VOLO);
      BME_D(READCHECK);
      BME_D(SHARE);
      BME_D(SYSTEM);
      BME_D(TAPE_DATA_WRITE);
      BME_D(WRITECHECK);
      BME_D(WRITETHRU);
      BME2_D(CDROM);
      BME2_D(COMPACTION);
      BME2_D(DISKQ);
      BME2_D(DSI);
      BME2_D(INCLUDE);
      BME2_D(NOCOMPACTION);
      BME2_D(OVR_LIMITED_SEARCH);
      BME2_D(OVR_NOFE);
      BME2_D(OVR_SECURITY);
      BME2_D(SUBSYSTEM);
      BME2_D(XAR);
      break;
    case SYSCALL_DISMOU:
      DMT_D(ABORT);
      DMT_D(CLUSTER);
      DMT_D(NOUNLOAD);
      DMT_D(OVR_CHECKS);
      DMT_D(UNIT);
      DMT_D(UNLOAD);
    default:
      croak("Invalid item specified");
    }
  }
}

/* Take a pointer to an itemlist, a hashref, and some flags, and build up */
/* an itemlist from what's in the hashref. Buffer space for the items is */
/* allocated, as are the length shorts and stuff. If the hash entries have */
/* values, those values are copied into the buffers, too. Returns the */
/* number of items stuck in the itemlist */
int build_itemlist(struct GenericID InfoList[], ITMLST *ItemList, HV *HashRef)
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
  int BufferLength;
  long TempLong;
  struct dsc$descriptor_s TimeStringDesc;
  int Status;
  int CopyData;

  for(i = 0; InfoList[i].GenericName; i++) {
    TempNameLen = strlen(InfoList[i].GenericName);
    /* If they've provided the info, or we're going to get it back, we */
    /* allocate some space */
    if ((hv_exists(HashRef, InfoList[i].GenericName, TempNameLen)) ||
        (InfoList[i].InOrOut & IS_OUTPUT)) {
      /* Figure out some stuff. Avoids duplication, and makes the macro */
      /* expansion of init_itemlist a little easier */
      ItemCode = InfoList[i].SyscallValue;
      CopyData = InfoList[i].InOrOut & IS_INPUT;
      switch(InfoList[i].ReturnType) {
        /* Quadwords are treated as strings for right now */
      case IS_QUADWORD:
      case IS_STRING:
        /* Allocate us some buffer space */
        Newz(NULL, TempBuffer, InfoList[i].BufferLen, char);
        Newz(NULL, TempLen, 1, unsigned short);

        BufferLength = InfoList[i].BufferLen;
        
        /* Set the string buffer to spaces */
        memset(TempBuffer, ' ', InfoList[i].BufferLen);
        
        /* If we're copying data, then fetch it and stick it in the buffer */
        if (CopyData) {
          TempSV = *hv_fetch(HashRef,
                             InfoList[i].GenericName,
                             TempNameLen, FALSE);
          TempCharPointer = SvPV(TempSV, TempStrLen);
          
          /* If there was something in the SV, then copy it over */
          if (TempStrLen) {
            BufferLength = TempStrLen < InfoList[i].BufferLen
                         ? TempStrLen : InfoList[i].BufferLen;
            Copy(TempCharPointer, TempBuffer, BufferLength, char);
          }
        }

        init_itemlist(&ItemList[ItemListIndex],
                      BufferLength,
                      ItemCode,
                      TempBuffer,
                      TempLen);
        break;
      case IS_VMSDATE:
        /* Allocate us some buffer space */
        Newz(NULL, TempBuffer, InfoList[i].BufferLen, char);
        Newz(NULL, TempLen, 1, unsigned short);
        
        if (CopyData) {
          TempSV = *hv_fetch(HashRef,
                             InfoList[i].GenericName,
                             TempNameLen, FALSE);
          TempCharPointer = SvPV(TempSV, TempStrLen);
          
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
        }

        init_itemlist(&ItemList[ItemListIndex],
                      InfoList[i].BufferLen,
                      ItemCode,
                      TempBuffer,
                      TempLen);
        break;
        
      case IS_LONGWORD:
        /* Allocate us some buffer space */
        Newz(NULL, TempBuffer, InfoList[i].BufferLen, char);
        Newz(NULL, TempLen, 1, unsigned short);
        
        if (CopyData) {
          TempSV = *hv_fetch(HashRef,
                             InfoList[i].GenericName,
                             TempNameLen, FALSE);
          TempLong = SvIVX(TempSV);
          
          /* Set the value */
          *TempBuffer = TempLong;
        }
        
        init_itemlist(&ItemList[ItemListIndex],
                      InfoList[i].BufferLen,
                      ItemCode,
                      TempBuffer,
                      TempLen);
        break;
        
      case IS_BITMAP:
        /* Allocate us some buffer space */
        Newz(NULL, TempBuffer, InfoList[i].BufferLen, char);
        Newz(NULL, TempLen, 1, unsigned short);
        
        if (CopyData) {
          TempSV = *hv_fetch(HashRef,
                             InfoList[i].GenericName,
                             TempNameLen, FALSE);
          
          /* Is the SV an integer? If so, then we'll use that value. */
          /* Otherwise we'll assume that it's a hashref of the sort that */
          /* generic_bitmap_decode gives */
          if (SvIOK(TempSV)) {
            TempLong = SvIVX(TempSV);
            /* Set the value */
            *TempBuffer = TempLong;
          } else {
            generic_bitmap_encode((HV *)SvRV(TempSV), ItemCode, TempBuffer);
          }
        }
        
        init_itemlist(&ItemList[ItemListIndex],
                      InfoList[i].BufferLen,
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
  for(DevInfoCount = 0; DevInfoList[DevInfoCount].GenericName;
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
  case DVI$_DEVCLASS:
    switch (val_to_deenum) {
    case DC$_DISK:
      sv_setpv(WorkingSV, "DISK");
      break;
    case DC$_TAPE:
      sv_setpv(WorkingSV, "TAPE");
      break;
    case DC$_SCOM:
      sv_setpv(WorkingSV, "SCOM");
      break;
    case DC$_CARD:
      sv_setpv(WorkingSV, "CARD");
      break;
    case DC$_TERM:
      sv_setpv(WorkingSV, "TERM");
      break;
    case DC$_LP:
      sv_setpv(WorkingSV, "LP");
      break;
    case DC$_WORKSTATION:
      sv_setpv(WorkingSV, "WORKSTATION");
      break;
    case DC$_REALTIME:
      sv_setpv(WorkingSV, "REALTIME");
      break;
    case DC$_DECVOICE:
      sv_setpv(WorkingSV, "DECVOICE");
      break;
    case DC$_AUDIO:
      sv_setpv(WorkingSV, "AUDIO");
      break;
    case DC$_VIDEO:
      sv_setpv(WorkingSV, "VIDEO");
      break;
    case DC$_BUS:
      sv_setpv(WorkingSV, "BUS");
      break;
    case DC$_MAILBOX:
      sv_setpv(WorkingSV, "MAILBOX");
      break;
    case DC$_REMCSL_STORAGE:
      sv_setpv(WorkingSV, "REMCSL_STORAGE");
      break;
    case DC$_MISC:
      sv_setpv(WorkingSV, "MISC");
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
    OurDataList[i].ItemName = DevInfoList[i].GenericName;
    OurDataList[i].ReturnLength = &ReturnLengths[i];
    OurDataList[i].ReturnType = DevInfoList[i].ReturnType;
    OurDataList[i].ItemListEntry = i;
    
    /* Fill in the item list */
    init_itemlist(&ListOItems[i], DevInfoList[i].BufferLen,
                  DevInfoList[i].SyscallValue, OurDataList[i].ReturnBuffer,
                  &ReturnLengths[i]);
    
  }
  
  /* Make the GETDVIW call */
  status = sys$getdviw(0, 0, &DevNameDesc, ListOItems, NULL, NULL, NULL, NULL);
  /* Did it go OK? */
  if (status == SS$_NORMAL) {
    /* Looks like it */
    AllPurposeHV = (HV*)sv_2mortal((SV*)newHV());
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
        sprintf(AsciiTime, "%02hi-%s-%hi %02hi:%02hi:%02hi.%02hi",
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
                 enum_name(DevInfoList[i].SyscallValue,
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
    ST(0) = &PL_sv_undef;
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
device_list(DeviceName,DevClass=&PL_sv_undef,DevType=&PL_sv_undef)
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
    AllPurposeHV = (HV*)sv_2mortal((SV*)newHV());
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
    AllPurposeHV = (HV*)sv_2mortal((SV*)newHV());
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
    AllPurposeHV = (HV*)sv_2mortal((SV*)newHV());
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
    AllPurposeHV = (HV*)sv_2mortal((SV*)newHV());
    ttc_bit_test(AllPurposeHV, HANGUL, BitmapValue);
    ttc_bit_test(AllPurposeHV, HANYU, BitmapValue);
    ttc_bit_test(AllPurposeHV, HANZI, BitmapValue);
    ttc_bit_test(AllPurposeHV, KANA, BitmapValue);
    ttc_bit_test(AllPurposeHV, KANJI, BitmapValue);
    ttc_bit_test(AllPurposeHV, THAI, BitmapValue);
  }}}}
  if (AllPurposeHV) {
    XPUSHs(newRV_noinc((SV *)AllPurposeHV));
  } else {
    XPUSHs(&PL_sv_undef);
  }
}

SV *
initialize(DevName, VolName, ItemHash=&PL_sv_undef)
     SV *DevName
     SV *VolName
     SV *ItemHash
   CODE:
{
  ITMLST InitItemList[99];
  int Status, NumItems = 0;
  unsigned int DevNameLen, VolNameLen;
  struct dsc$descriptor_s DevNameDesc;
  struct dsc$descriptor_s VolNameDesc;
  
  DevNameDesc.dsc$a_pointer = SvPV(DevName, DevNameLen);
  DevNameDesc.dsc$w_length = DevNameLen;
  DevNameDesc.dsc$b_dtype = DSC$K_DTYPE_T;
  DevNameDesc.dsc$b_class = DSC$K_CLASS_S;

  VolNameDesc.dsc$a_pointer = SvPV(VolName, VolNameLen);
  VolNameDesc.dsc$w_length = VolNameLen;
  VolNameDesc.dsc$b_dtype = DSC$K_DTYPE_T;
  VolNameDesc.dsc$b_class = DSC$K_CLASS_S;

  /* Did we get an item list hash? */
  if (ItemHash != &PL_sv_undef) {
    /* Okay, then is it a hash ref? */
    if (SvROK(ItemHash)) {
      if (SvTYPE(SvRV(ItemHash)) == SVt_PVHV) {
        /* Hey, it's a hashref. Go hit build_itemlist */
        /* Clear the item list */
        memset(InitItemList, 0, sizeof(ITMLST) * 99);
        NumItems = build_itemlist(InitList, InitItemList,
                                  (HV *)SvRV(ItemHash));
      } else {
        croak("Arg 3 should be a hash reference");
      }
    } else {
      croak("Arg 3 should be a hash reference");
    }
  }
    
  if (NumItems) {
    Status = sys$init_vol(&DevNameDesc, &VolNameDesc, InitItemList);
    tear_down_itemlist(InitItemList, NumItems);
  } else {
    Status = sys$init_vol(&DevNameDesc, &VolNameDesc, NULL);
  }
  if (SS$_NORMAL == Status) {
    XSRETURN_YES;
  } else {
    SETERRNO(EVMSERR, Status);
    XSRETURN_UNDEF;
  }
}

SV *
dismount(DevName, ItemHash=&PL_sv_undef)
     SV *DevName
     SV *ItemHash
   CODE:
{
  ITMLST InitItemList[99];
  int Status, NumItems = 0;
  int Flags = 0;
  unsigned int DevNameLen, VolNameLen;
  struct dsc$descriptor_s DevNameDesc;
  struct dsc$descriptor_s VolNameDesc;
  
  DevNameDesc.dsc$a_pointer = SvPV(DevName, DevNameLen);
  DevNameDesc.dsc$w_length = DevNameLen;
  DevNameDesc.dsc$b_dtype = DSC$K_DTYPE_T;
  DevNameDesc.dsc$b_class = DSC$K_CLASS_S;

  /* Did we get an item list hash? */
  if (ItemHash != &PL_sv_undef) {
    /* Okay, then is it a hash ref? */
    if (SvROK(ItemHash)) {
      if (SvTYPE(SvRV(ItemHash)) == SVt_PVHV) {
        /* Hey, it's a hashref. Go turn it into an integer */
        generic_bitmap_encode((HV *)SvRV(ItemHash), SYSCALL_DISMOU, &Flags);
      } else {
        croak("Arg 2 should be a hash reference");
      }
    } else {
      croak("Arg 2 should be a hash reference");
    }
  }
    
  Status = sys$dismou(&DevNameDesc, Flags);
  if (SS$_NORMAL == Status) {
    XSRETURN_YES;
  } else {
    SETERRNO(EVMSERR, Status);
    XSRETURN_UNDEF;
  }
}

SV *
mount(ItemHash=&PL_sv_undef)
     SV *ItemHash
   CODE:
{
  ITMLST MountItemList[99];
  int Status, NumItems = 0;
  /* Did we get an item list hash? */
  if (ItemHash != &PL_sv_undef) {
    /* Okay, then is it a hash ref? */
    if (SvROK(ItemHash)) {
      if (SvTYPE(SvRV(ItemHash)) == SVt_PVHV) {
        /* Hey, it's a hashref. Go hit build_itemlist */
        /* Clear the item list */
        Zero(MountItemList, 99, ITMLST);
        NumItems = build_itemlist(MountList, MountItemList,
                                  (HV *)SvRV(ItemHash));
      } else {
        croak("mount requires a hash reference");
      }
    } else {
      croak("mount requires a hash reference");
    }
  }
    
  if (NumItems) {
    Status = sys$mount(MountItemList);
    tear_down_itemlist(MountItemList, NumItems);
  } else {
    SETERRNO(EVMSERR, SS$_BADPARAM);
    XSRETURN_UNDEF;
  }

  if (SS$_NORMAL == Status) {
    XSRETURN_YES;
  } else {
    SETERRNO(EVMSERR, Status);
    XSRETURN_UNDEF;
  }
}

SV *
allocate(DevName, FirstAvail=&PL_sv_undef, AccMode=&PL_sv_undef)
     SV *DevName
     SV *FirstAvail
     SV *AccMode
   CODE:
{
  char ReturnName[65];
  char *AccessString;
  unsigned short ReturnNameLen;
  int AccessMode, Flags, Status;
  unsigned int DevNameLen;
  struct dsc$descriptor_s DevNameDesc;
  struct dsc$descriptor_s RetName;
  
  RetName.dsc$a_pointer = ReturnName;
  RetName.dsc$w_length = 64;
  RetName.dsc$b_dtype = DSC$K_DTYPE_T;
  RetName.dsc$b_class = DSC$K_CLASS_S;
  
  DevNameDesc.dsc$a_pointer = SvPV(DevName, DevNameLen);
  DevNameDesc.dsc$w_length = DevNameLen;
  DevNameDesc.dsc$b_dtype = DSC$K_DTYPE_T;
  DevNameDesc.dsc$b_class = DSC$K_CLASS_S;

  Flags = SvTRUE(FirstAvail);
  AccessMode = decode_accmode(AccMode);

  Status = sys$alloc(&DevNameDesc, &ReturnNameLen, &RetName, AccessMode,
                     Flags);
  if (SS$_NORMAL == Status) {
    ST(0) = sv_2mortal(newSVpv(ReturnName, ReturnNameLen));
  } else {
    SETERRNO(EVMSERR, Status);
    ST(0) = &PL_sv_undef;
  }
}

SV *
deallocate(DevName, AccMode=&PL_sv_undef)
     SV *DevName
     SV *AccMode
   CODE:
{
  struct dsc$descriptor_s DevNameDesc;
  int AccessMode, Status;
  unsigned int DevNameLen;

  DevNameDesc.dsc$a_pointer = SvPV(DevName, DevNameLen);
  DevNameDesc.dsc$w_length = DevNameLen;
  DevNameDesc.dsc$b_dtype = DSC$K_DTYPE_T;
  DevNameDesc.dsc$b_class = DSC$K_CLASS_S;

  AccessMode = decode_accmode(AccMode);

  Status = sys$dalloc(&DevNameDesc, AccessMode);
  if (SS$_NORMAL == Status) {
    ST(0) = &PL_sv_yes;
  } else {
    SETERRNO(EVMSERR, Status);
    ST(0) = &PL_sv_undef;
  }
}
