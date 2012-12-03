unit at32uc3c1512c;

(*****************************************************************************
 *
 * Copyright (C) 2012 Michel Catudal
 *
 ****************************************************************************)
interface

const
(* Memories *)
AVR32_CPU_RAM_ADDRESS =          $00000000;
AVR32_FLASH_ADDRESS =            $80000000;
AVR32_FLASHC_USER_PAGE_ADDRESS = $80800000;
AVR32_FLASHC_CALIBRATION_FIRST_WORD_ADDRESS =  $80800200;
AVR32_FLASHC_CALIBRATION_SECOND_WORD_ADDRESS = $80800204;
AVR32_FLASHC_CALIBRATION_THIRD_WORD_ADDRESS =  $80800208;
AVR32_SAU_HSB_ADDRESS =     $90000000;
AVR32_SAU_SLAVE_ADDRESS =   $90000000;
AVR32_HRAMC0_ADDRESS =      $A0000000;
AVR32_HTOP2_ADDRESS =       $FFFD0000;
AVR32_HTOP1_ADDRESS =       $FFFE0000;
AVR32_HTOP0_ADDRESS =       $FFFF0000;

(* Interrupt Controller *)
AVR32_INTC_ADDRESS =        $FFFF0000;
AVR32_INTC_NUM_INT_GRPS =   47;
(* ADCIFA *)
AVR32_ADCIFA_ADDRESS =      $FFFD2400;
(* ACIFA0 *)
AVR32_ACIFA0_ADDRESS =      $FFFF6000;
(* ACIFA1 *)
AVR32_ACIFA1_ADDRESS =      $FFFF6400;
(* DACIFB0 *)
AVR32_DACIFB0_ADDRESS =     $FFFF6800;
(* DACIFB1 *)
AVR32_DACIFB1_ADDRESS =     $FFFF6C00;
(* AST *)
AVR32_AST_ADDRESS =         $FFFF0C00;
(* EIC *)
AVR32_EIC_ADDRESS =         $FFFF1400;
(* CANIF *)
AVR32_CANIF_ADDRESS =       $FFFD1C00;
AVR32_CANIF_CAN_NB =        2;
(* AW *)
AVR32_AW_ADDRESS =          $FFFF7000;
(* FLASHC *)
AVR32_FLASHC_ADDRESS =      $FFFE0000;
(* FREQM *)
AVR32_FREQM_ADDRESS =       $FFFF1800;
(* GPIO *)
AVR32_GPIO_ADDRESS =        $FFFF2000;
AVR32_GPIO_PORT_LENGTH =    3;
(* HMATRIX *)
AVR32_HMATRIXB_ADDRESS =    $FFFE2000;
(* IISC *)
AVR32_IISC_ADDRESS =        $FFFF4800;
(* MACB *)
AVR32_MACB_ADDRESS =        $FFFE3000;
(* MDMA *)
AVR32_MDMA_ADDRESS =        $FFFD1000;
(* PDCA *)
AVR32_PDCA_ADDRESS =        $FFFD0000;
AVR32_PDCA_CHANNEL_LENGTH = 16;
(* PEVC *)
AVR32_PEVC_ADDRESS =        $FFFF5C00;
AVR32_PEVC_TRIGOUT_BITS =   22;
AVR32_PEVC_EVS_BITS =       24;
(* PM *)
AVR32_PM_ADDRESS =          $FFFF0400;
(* PWM *)
AVR32_PWM_ADDRESS =         $FFFF4C00;
AVR32_PWM_EVT_NUM =         2;
AVR32_PWM_CMP_NUM =         8;
AVR32_PWM_CHANNEL_NUM =     4;
(* QDEC0 *)
AVR32_QDEC0_ADDRESS =       $FFFF5000;
(* QDEC1 *)
AVR32_QDEC1_ADDRESS =       $FFFF5400;
(* SAU *)
AVR32_SAU_ADDRESS =         $FFFE2400;
AVR32_SAU_CHANNELS =        16;
(* SCIF *)
AVR32_SCIF_ADDRESS =        $FFFF0800;
(* SPI0 *)
AVR32_SPI0_ADDRESS =        $FFFD1800;
(* SPI1 *)
AVR32_SPI1_ADDRESS =        $FFFF3400;
(* TC0 *)
AVR32_TC0_ADDRESS =         $FFFD2000;
(* TC1 *)
AVR32_TC1_ADDRESS =         $FFFF5800;
(* TWIM0 *)
AVR32_TWIM0_ADDRESS =       $FFFF3800;
(* TWIM1 *)
AVR32_TWIM1_ADDRESS =       $FFFF3C00;
(* TWIM2 *)
AVR32_TWIM2_ADDRESS =       $FFFD2C00;
(* TWIS0 *)
AVR32_TWIS0_ADDRESS =       $FFFF4000;
(* TWIS1 *)
AVR32_TWIS1_ADDRESS =       $FFFF4400;
(* TWIS2 *)
AVR32_TWIS2_ADDRESS =       $FFFD3000;
(* USART0 *)
AVR32_USART0_ADDRESS =      $FFFF2800;
(* USART1 *)
AVR32_USART1_ADDRESS =      $FFFD1400;
(* USART2 *)
AVR32_USART2_ADDRESS =      $FFFF2C00;
(* USART3 *)
AVR32_USART3_ADDRESS =      $FFFF3000;
(* USART4 *)
AVR32_USART4_ADDRESS =      $FFFD2800;
(* USBC *)
AVR32_USBC_ADDRESS =        $FFFE1000;
(* WDT *)
AVR32_WDT_ADDRESS =         $FFFF1000;
(* GPIO_LOCAL *)
AVR32_GPIO_LOCAL_ADDRESS =  $40000000;

var
(* Interrupt Controller *)
INTC_ipr: array[0..(AVR32_INTC_NUM_INT_GRPS-1)] of LongInt absolute AVR32_INTC_ADDRESS;
INTC_irr: array[0..(AVR32_INTC_NUM_INT_GRPS-1)] of LongInt absolute AVR32_INTC_ADDRESS+$0100;
INTC_icr: array[0..3] of LongInt absolute AVR32_INTC_ADDRESS+$0200;
(* ADCIFA *)
ADCIFA_cr:        LongInt absolute AVR32_ADCIFA_ADDRESS;
ADCIFA_cfg:       LongInt absolute AVR32_ADCIFA_ADDRESS+$0004;
ADCIFA_sr:        LongInt absolute AVR32_ADCIFA_ADDRESS+$0008;
ADCIFA_scr:       LongInt absolute AVR32_ADCIFA_ADDRESS+$000c;
ADCIFA_ssr:       LongInt absolute AVR32_ADCIFA_ADDRESS+$0010;
ADCIFA_seqcfg0 :  LongInt absolute AVR32_ADCIFA_ADDRESS+$0014;
ADCIFA_seqcfg1 :  LongInt absolute AVR32_ADCIFA_ADDRESS+$0018;
ADCIFA_shg0:      LongInt absolute AVR32_ADCIFA_ADDRESS+$001c;
ADCIFA_shg1:      LongInt absolute AVR32_ADCIFA_ADDRESS+$0020;
ADCIFA_inpsel00:  LongInt absolute AVR32_ADCIFA_ADDRESS+$0024;
ADCIFA_inpsel01:  LongInt absolute AVR32_ADCIFA_ADDRESS+$0028;
ADCIFA_inpsel10:  LongInt absolute AVR32_ADCIFA_ADDRESS+$002c;
ADCIFA_inpsel11:  LongInt absolute AVR32_ADCIFA_ADDRESS+$0030;
ADCIFA_innsel00:  LongInt absolute AVR32_ADCIFA_ADDRESS+$0034;
ADCIFA_innsel01:  LongInt absolute AVR32_ADCIFA_ADDRESS+$0038;
ADCIFA_innsel10:  LongInt absolute AVR32_ADCIFA_ADDRESS+$003c;
ADCIFA_innsel11:  LongInt absolute AVR32_ADCIFA_ADDRESS+$0040;
ADCIFA_ckdiv:     LongInt absolute AVR32_ADCIFA_ADDRESS+$0044;
ADCIFA_itimer:    LongInt absolute AVR32_ADCIFA_ADDRESS+$0048;
ADCIFA_tsscfg:    LongInt absolute AVR32_ADCIFA_ADDRESS+$004c;
ADCIFA_tsswseq0:  LongInt absolute AVR32_ADCIFA_ADDRESS+$0050;
ADCIFA_tsswseq1:  LongInt absolute AVR32_ADCIFA_ADDRESS+$0054;
ADCIFA_wcfg0:     LongInt absolute AVR32_ADCIFA_ADDRESS+$0058;
ADCIFA_wcfg1:     LongInt absolute AVR32_ADCIFA_ADDRESS+$005c;
ADCIFA_lcv0:      LongInt absolute AVR32_ADCIFA_ADDRESS+$0060;
ADCIFA_lcv1:      LongInt absolute AVR32_ADCIFA_ADDRESS+$0064;
ADCIFA_adccal:    LongInt absolute AVR32_ADCIFA_ADDRESS+$0068;
ADCIFA_shcal:     LongInt absolute AVR32_ADCIFA_ADDRESS+$006c;
ADCIFA_ier:       LongInt absolute AVR32_ADCIFA_ADDRESS+$0070;
ADCIFA_idr:       LongInt absolute AVR32_ADCIFA_ADDRESS+$0074;
ADCIFA_imr:       LongInt absolute AVR32_ADCIFA_ADDRESS+$0078;
ADCIFA_version:   LongInt absolute AVR32_ADCIFA_ADDRESS+$007c;
ADCIFA_parameter: LongInt absolute AVR32_ADCIFA_ADDRESS+$0080;
ADCIFA_resx: array[0..15] of LongInt absolute AVR32_ADCIFA_ADDRESS+$0084;
(* ACIFA0 *)
ACIFA0_confa:     LongInt absolute AVR32_ACIFA0_ADDRESS;
ACIFA0_confb:     LongInt absolute AVR32_ACIFA0_ADDRESS+$0004;
ACIFA0_wconf:     LongInt absolute AVR32_ACIFA0_ADDRESS+$0008;
ACIFA0_evsrc0:    LongInt absolute AVR32_ACIFA0_ADDRESS+$000c;
ACIFA0_evsrc1:    LongInt absolute AVR32_ACIFA0_ADDRESS+$0010;
ACIFA0_scfa:      LongInt absolute AVR32_ACIFA0_ADDRESS+$0014;
ACIFA0_scfb:      LongInt absolute AVR32_ACIFA0_ADDRESS+$0018;
ACIFA0_en:        LongInt absolute AVR32_ACIFA0_ADDRESS+$001c;
ACIFA0_dis:       LongInt absolute AVR32_ACIFA0_ADDRESS+$0020;
ACIFA0_sut:       LongInt absolute AVR32_ACIFA0_ADDRESS+$0024;
ACIFA0_ier:       LongInt absolute AVR32_ACIFA0_ADDRESS+$0028;
ACIFA0_idr:       LongInt absolute AVR32_ACIFA0_ADDRESS+$002c;
ACIFA0_imr:       LongInt absolute AVR32_ACIFA0_ADDRESS+$0030;
ACIFA0_eve:       LongInt absolute AVR32_ACIFA0_ADDRESS+$0034;
ACIFA0_evd:       LongInt absolute AVR32_ACIFA0_ADDRESS+$0038;
ACIFA0_evm:       LongInt absolute AVR32_ACIFA0_ADDRESS+$003c;
ACIFA0_sr:        LongInt absolute AVR32_ACIFA0_ADDRESS+$0040;
ACIFA0_scr:       LongInt absolute AVR32_ACIFA0_ADDRESS+$0044;
ACIFA0_version:   LongInt absolute AVR32_ACIFA0_ADDRESS+$0048;
ACIFA0_parameter: LongInt absolute AVR32_ACIFA0_ADDRESS+$004c;
(* ACIFA1 *)
ACIFA1_confa:     LongInt absolute AVR32_ACIFA1_ADDRESS;
ACIFA1_confb:     LongInt absolute AVR32_ACIFA1_ADDRESS+$0004;
ACIFA1_wconf:     LongInt absolute AVR32_ACIFA1_ADDRESS+$0008;
ACIFA1_evsrc0:    LongInt absolute AVR32_ACIFA1_ADDRESS+$000c;
ACIFA1_evsrc1:    LongInt absolute AVR32_ACIFA1_ADDRESS+$0010;
ACIFA1_scfa:      LongInt absolute AVR32_ACIFA1_ADDRESS+$0014;
ACIFA1_scfb:      LongInt absolute AVR32_ACIFA1_ADDRESS+$0018;
ACIFA1_en:        LongInt absolute AVR32_ACIFA1_ADDRESS+$001c;
ACIFA1_dis:       LongInt absolute AVR32_ACIFA1_ADDRESS+$0020;
ACIFA1_sut:       LongInt absolute AVR32_ACIFA1_ADDRESS+$0024;
ACIFA1_ier:       LongInt absolute AVR32_ACIFA1_ADDRESS+$0028;
ACIFA1_idr:       LongInt absolute AVR32_ACIFA1_ADDRESS+$002c;
ACIFA1_imr:       LongInt absolute AVR32_ACIFA1_ADDRESS+$0030;
ACIFA1_eve:       LongInt absolute AVR32_ACIFA1_ADDRESS+$0034;
ACIFA1_evd:       LongInt absolute AVR32_ACIFA1_ADDRESS+$0038;
ACIFA1_evm:       LongInt absolute AVR32_ACIFA1_ADDRESS+$003c;
ACIFA1_sr:        LongInt absolute AVR32_ACIFA1_ADDRESS+$0040;
ACIFA1_scr:       LongInt absolute AVR32_ACIFA1_ADDRESS+$0044;
ACIFA1_version:   LongInt absolute AVR32_ACIFA1_ADDRESS+$0048;
ACIFA1_parameter: LongInt absolute AVR32_ACIFA1_ADDRESS+$004c;
(* DACIFB0 *)
DACIFB0_cr:       LongInt absolute AVR32_DACIFB0_ADDRESS;
DACIFB0_cfr:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0004;
DACIFB0_ecr:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0008;
DACIFB0_tcr:      LongInt absolute AVR32_DACIFB0_ADDRESS+$000c;
DACIFB0_ier:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0010;
DACIFB0_idr:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0014;
DACIFB0_imr:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0018;
DACIFB0_sr:       LongInt absolute AVR32_DACIFB0_ADDRESS+$001c;
DACIFB0_scr:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0020;
DACIFB0_drca:     LongInt absolute AVR32_DACIFB0_ADDRESS+$0024;
DACIFB0_drcb:     LongInt absolute AVR32_DACIFB0_ADDRESS+$0028;
DACIFB0_dr0:      LongInt absolute AVR32_DACIFB0_ADDRESS+$002c;
DACIFB0_dr1:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0030;
DACIFB0_goc:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0034;
DACIFB0_tra:      LongInt absolute AVR32_DACIFB0_ADDRESS+$0038;
DACIFB0_trb:      LongInt absolute AVR32_DACIFB0_ADDRESS+$003c;
DACIFB0_version:  LongInt absolute AVR32_DACIFB0_ADDRESS+$0040;
(* DACIFB1 *)
DACIFB1_cr:       LongInt absolute AVR32_DACIFB1_ADDRESS;
DACIFB1_cfr:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0004;
DACIFB1_ecr:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0008;
DACIFB1_tcr:      LongInt absolute AVR32_DACIFB1_ADDRESS+$000c;
DACIFB1_ier:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0010;
DACIFB1_idr:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0014;
DACIFB1_imr:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0018;
DACIFB1_sr:       LongInt absolute AVR32_DACIFB1_ADDRESS+$001c;
DACIFB1_scr:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0020;
DACIFB1_drca:     LongInt absolute AVR32_DACIFB1_ADDRESS+$0024;
DACIFB1_drcb:     LongInt absolute AVR32_DACIFB1_ADDRESS+$0028;
DACIFB1_dr0:      LongInt absolute AVR32_DACIFB1_ADDRESS+$002c;
DACIFB1_dr1:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0030;
DACIFB1_goc:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0034;
DACIFB1_tra:      LongInt absolute AVR32_DACIFB1_ADDRESS+$0038;
DACIFB1_trb:      LongInt absolute AVR32_DACIFB1_ADDRESS+$003c;
DACIFB1_version:  LongInt absolute AVR32_DACIFB1_ADDRESS+$0040;
(* AST *)
AST_cr:         LongInt absolute AVR32_AST_ADDRESS;
AST_cv:         LongInt absolute AVR32_AST_ADDRESS+$0004;
AST_sr:         LongInt absolute AVR32_AST_ADDRESS+$0008;
AST_scr:        LongInt absolute AVR32_AST_ADDRESS+$000c;
AST_ier:        LongInt absolute AVR32_AST_ADDRESS+$0010;
AST_idr:        LongInt absolute AVR32_AST_ADDRESS+$0014;
AST_imr:        LongInt absolute AVR32_AST_ADDRESS+$0018;
AST_wer:        LongInt absolute AVR32_AST_ADDRESS+$001c;
AST_ar0:        LongInt absolute AVR32_AST_ADDRESS+$0020;
AST_ar1:        LongInt absolute AVR32_AST_ADDRESS+$0024;
AST_pir0:       LongInt absolute AVR32_AST_ADDRESS+$0030;
AST_pir1:       LongInt absolute AVR32_AST_ADDRESS+$0034;
AST_clock:      LongInt absolute AVR32_AST_ADDRESS+$0040;
AST_dtr:        LongInt absolute AVR32_AST_ADDRESS+$0044;
AST_eve:        LongInt absolute AVR32_AST_ADDRESS+$0048;
AST_evd:        LongInt absolute AVR32_AST_ADDRESS+$004c;
AST_evm:        LongInt absolute AVR32_AST_ADDRESS+$0050;
AST_calv:       LongInt absolute AVR32_AST_ADDRESS+$0054;
AST_parameter:  LongInt absolute AVR32_AST_ADDRESS+$00f0;
AST_version:    LongInt absolute AVR32_AST_ADDRESS+$00fc;
(* EIC *)
EIC_ier:       LongInt absolute AVR32_EIC_ADDRESS;
EIC_idr:       LongInt absolute AVR32_EIC_ADDRESS+$0004;
EIC_imr:       LongInt absolute AVR32_EIC_ADDRESS+$0008;
EIC_isr:       LongInt absolute AVR32_EIC_ADDRESS+$000c;
EIC_icr:       LongInt absolute AVR32_EIC_ADDRESS+$0010;
EIC_mode:      LongInt absolute AVR32_EIC_ADDRESS+$0014;
EIC_edge:      LongInt absolute AVR32_EIC_ADDRESS+$0018;
EIC_level:     LongInt absolute AVR32_EIC_ADDRESS+$001c;
EIC_filter:    LongInt absolute AVR32_EIC_ADDRESS+$0020;
EIC_test:      LongInt absolute AVR32_EIC_ADDRESS+$0024;
EIC_async:     LongInt absolute AVR32_EIC_ADDRESS+$0028;
EIC_en:        LongInt absolute AVR32_EIC_ADDRESS+$0030;
EIC_dis:       LongInt absolute AVR32_EIC_ADDRESS+$0034;
EIC_ctrl:      LongInt absolute AVR32_EIC_ADDRESS+$0038;
EIC_version:   LongInt absolute AVR32_EIC_ADDRESS+$00ff;
(* CANIF *)
type
 Tavr32_canif_channel_t = packed record
    canramb,cancfg,canctrl,cansr,canfc,canier,canidr,
    canimr,caniscr,canisr,mobsch,mober,mobdr,mobesr,
    mobier,mobidr,mobimr,mrxiscr,mrxisr,mtxiscr,mtxisr,
    mobctrl,mobscr,mobsr: LongInt;
    res0: array[0..103] of LongInt;
end;

var
    CANIF_version:   LongInt absolute AVR32_CANIF_ADDRESS;
    CANIF_parameter: LongInt absolute AVR32_CANIF_ADDRESS+4;
    CANIF_channel: array[0..(AVR32_CANIF_CAN_NB-1)] of LongInt absolute AVR32_CANIF_ADDRESS+8;

(* AW *)
AW_ctrl:      LongInt absolute AVR32_AW_ADDRESS;
AW_sr:        LongInt absolute AVR32_AW_ADDRESS+$0004;
AW_scr:       LongInt absolute AVR32_AW_ADDRESS+$0008;
AW_ier:       LongInt absolute AVR32_AW_ADDRESS+$000c;
AW_idr:       LongInt absolute AVR32_AW_ADDRESS+$0010;
AW_imr:       LongInt absolute AVR32_AW_ADDRESS+$0014;
AW_rhr:       LongInt absolute AVR32_AW_ADDRESS+$0018;
AW_thr:       LongInt absolute AVR32_AW_ADDRESS+$001c;
AW_brr:       LongInt absolute AVR32_AW_ADDRESS+$0020;
AW_version:   LongInt absolute AVR32_AW_ADDRESS+$0024;
AW_clkr:      LongInt absolute AVR32_AW_ADDRESS+$0028;
(* FLASHC *)
FLASHC_fcr:      LongInt absolute AVR32_FLASHC_ADDRESS;
FLASHC_fcmd:     LongInt absolute AVR32_FLASHC_ADDRESS+$0004;
FLASHC_fsr:      LongInt absolute AVR32_FLASHC_ADDRESS+$0008;
FLASHC_pr:       LongInt absolute AVR32_FLASHC_ADDRESS+$000c;
FLASHC_vr:       LongInt absolute AVR32_FLASHC_ADDRESS+$0010;
FLASHC_fgpfrhi:  LongInt absolute AVR32_FLASHC_ADDRESS+$0014;
FLASHC_fgpfrlo:  LongInt absolute AVR32_FLASHC_ADDRESS+$0018;
(* FREQM *)
FREQM_ctrl:      LongInt absolute AVR32_FREQM_ADDRESS;
FREQM_mode:      LongInt absolute AVR32_FREQM_ADDRESS+$0004;
FREQM_status:    LongInt absolute AVR32_FREQM_ADDRESS+$0008;
FREQM_value:     LongInt absolute AVR32_FREQM_ADDRESS+$000c;
FREQM_ier:       LongInt absolute AVR32_FREQM_ADDRESS+$0010;
FREQM_idr:       LongInt absolute AVR32_FREQM_ADDRESS+$0014;
FREQM_imr:       LongInt absolute AVR32_FREQM_ADDRESS+$0018;
FREQM_isr:       LongInt absolute AVR32_FREQM_ADDRESS+$001c;
FREQM_icr:       LongInt absolute AVR32_FREQM_ADDRESS+$0020;
FREQM_version:   LongInt absolute AVR32_FREQM_ADDRESS+$03fc;
(* GPIO *)
type
 Tavr32_gpio_port_t = packed record
    gper,gpers,gperc,gpert,pmr0,pmr0s,pmr0c,pmr0t,
    pmr1,pmr1s,pmr1c,pmr1t,pmr2,pmr2s,pmr2c,pmr2t,
    oder,oders,oderc,odert,ovr,ovrs,ovrc,ovrt,pvr: LongInt;
    res0: array[0..2] of LongInt;
    puer,puers,puerc,puert,pder,pders,pderc,pdert,
    ier,iers,ierc,iert,imr0,imr0s,imr0c,imr0t,imr1,
    imr1s,imr1c,imr1t,gfer,gfers,gferc,gfert,ifr: LongInt;
    res1: LongInt;
    ifrc: LongInt;
    res2: LongInt;
    odmer,odmers,odmerc,odmert : LongInt;
    res3: array[0..3] of LongInt;
    odcr0,odcr0s,odcr0c,odcr0t,odcr1,odcr1s,odcr1c,odcr1t: LongInt;
    res4: array[0..3] of LongInt;
    osrr0,osrr0s,osrr0c,osrr0t: LongInt;
    res5: array[0..7] of LongInt;
    ster,sters,sterc,stert: LongInt;
    res6: array[0..3] of LongInt;
    ever,evers,everc,evert: LongInt;
    res7: array[0..3] of LongInt;
    lock,locks,lockc,lockt: LongInt;
    res8: array[0..11] of LongInt;
    unlock,asr: LongInt;
    res9: array[0..3] of LongInt;
    parameter,version: LongInt;
 end;

var
  GPIO_port: array[0..(AVR32_GPIO_PORT_LENGTH-1)]  of Tavr32_gpio_port_t absolute AVR32_GPIO_ADDRESS;
{ HMATRIX }
type
 Tavr32_hmatrixb_prs_t = packed record
    pras,prbs: LongInt;
 end;

(* HMATRIX *)
var
HMATRIX_mcfg: array[0..15] of LongInt absolute     AVR32_HMATRIXB_ADDRESS;
HMATRIX_scfg: array[0..15] of LongInt absolute     AVR32_HMATRIXB_ADDRESS+$0040;
HMATRIX_prs: array[0..15] of Tavr32_hmatrixb_prs_t absolute AVR32_HMATRIXB_ADDRESS+$0080;
HMATRIX_mrcr: LongInt absolute                     AVR32_HMATRIXB_ADDRESS+$0100;
HMATRIX_sfr: array[0..15] of LongInt absolute      AVR32_HMATRIXB_ADDRESS+$0110;
HMATRIX_version: LongInt absolute                  AVR32_HMATRIXB_ADDRESS+$01fc;
(* IISC *)
IISC_cr:        LongInt absolute AVR32_IISC_ADDRESS;
IISC_mr:        LongInt absolute AVR32_IISC_ADDRESS+$0004;
IISC_sr:        LongInt absolute AVR32_IISC_ADDRESS+$0008;
IISC_scr:       LongInt absolute AVR32_IISC_ADDRESS+$000c;
IISC_ssr:       LongInt absolute AVR32_IISC_ADDRESS+$0010;
IISC_ier:       LongInt absolute AVR32_IISC_ADDRESS+$0014;
IISC_idr:       LongInt absolute AVR32_IISC_ADDRESS+$0018;
IISC_imr:       LongInt absolute AVR32_IISC_ADDRESS+$001c;
IISC_rhr:       LongInt absolute AVR32_IISC_ADDRESS+$0020;
IISC_thr:       LongInt absolute AVR32_IISC_ADDRESS+$0024;
IISC_version:   LongInt absolute AVR32_IISC_ADDRESS+$0028;
IISC_parameter: LongInt absolute AVR32_IISC_ADDRESS+$002c;
(* MACB *)
MACB_ncr:     LongInt absolute AVR32_MACB_ADDRESS;
MACB_ncfgr:   LongInt absolute AVR32_MACB_ADDRESS+$0004;
MACB_nsr:     LongInt absolute AVR32_MACB_ADDRESS+$0008;
MACB_tsr:     LongInt absolute AVR32_MACB_ADDRESS+$0014;
MACB_rbqp:    LongInt absolute AVR32_MACB_ADDRESS+$0018;
MACB_tbqp:    LongInt absolute AVR32_MACB_ADDRESS+$001c;
MACB_rsr:     LongInt absolute AVR32_MACB_ADDRESS+$0020;
MACB_isr:     LongInt absolute AVR32_MACB_ADDRESS+$0024;
MACB_ier:     LongInt absolute AVR32_MACB_ADDRESS+$0028;
MACB_idr:     LongInt absolute AVR32_MACB_ADDRESS+$002c;
MACB_imr:     LongInt absolute AVR32_MACB_ADDRESS+$0030;
MACB_man:     LongInt absolute AVR32_MACB_ADDRESS+$0034;
MACB_ptr:     LongInt absolute AVR32_MACB_ADDRESS+$0038;
MACB_pfr:     LongInt absolute AVR32_MACB_ADDRESS+$003c;
MACB_fto:     LongInt absolute AVR32_MACB_ADDRESS+$0040;
MACB_scf:     LongInt absolute AVR32_MACB_ADDRESS+$0044;
MACB_mcf:     LongInt absolute AVR32_MACB_ADDRESS+$0048;
MACB_fro:     LongInt absolute AVR32_MACB_ADDRESS+$004c;
MACB_fcse:    LongInt absolute AVR32_MACB_ADDRESS+$0050;
MACB_ale:     LongInt absolute AVR32_MACB_ADDRESS+$0054;
MACB_dtf:     LongInt absolute AVR32_MACB_ADDRESS+$0058;
MACB_lcol:    LongInt absolute AVR32_MACB_ADDRESS+$005c;
MACB_excol:   LongInt absolute AVR32_MACB_ADDRESS+$0060;
MACB_tund:    LongInt absolute AVR32_MACB_ADDRESS+$0064;
MACB_cse:     LongInt absolute AVR32_MACB_ADDRESS+$0068;
MACB_rre:     LongInt absolute AVR32_MACB_ADDRESS+$006c;
MACB_rovr:    LongInt absolute AVR32_MACB_ADDRESS+$0070;
MACB_rse:     LongInt absolute AVR32_MACB_ADDRESS+$0074;
MACB_ele:     LongInt absolute AVR32_MACB_ADDRESS+$0078;
MACB_rja:     LongInt absolute AVR32_MACB_ADDRESS+$007c;
MACB_usf:     LongInt absolute AVR32_MACB_ADDRESS+$0080;
MACB_ste:     LongInt absolute AVR32_MACB_ADDRESS+$0084;
MACB_rle:     LongInt absolute AVR32_MACB_ADDRESS+$0088;
MACB_tpf:     LongInt absolute AVR32_MACB_ADDRESS+$008c;
MACB_hrb:     LongInt absolute AVR32_MACB_ADDRESS+$0090;
MACB_hrt:     LongInt absolute AVR32_MACB_ADDRESS+$0094;
MACB_sa1b:    LongInt absolute AVR32_MACB_ADDRESS+$0098;
MACB_sa1t:    LongInt absolute AVR32_MACB_ADDRESS+$009c;
MACB_sa2b:    LongInt absolute AVR32_MACB_ADDRESS+$00a0;
MACB_sa2t:    LongInt absolute AVR32_MACB_ADDRESS+$00a4;
MACB_sa3b:    LongInt absolute AVR32_MACB_ADDRESS+$00a8;
MACB_sa3t:    LongInt absolute AVR32_MACB_ADDRESS+$00ac;
MACB_sa4b:    LongInt absolute AVR32_MACB_ADDRESS+$00b0;
MACB_sa4t:    LongInt absolute AVR32_MACB_ADDRESS+$00b4;
MACB_tid:     LongInt absolute AVR32_MACB_ADDRESS+$00b8;
MACB_tpq:     LongInt absolute AVR32_MACB_ADDRESS+$00bc;
MACB_usrio:   LongInt absolute AVR32_MACB_ADDRESS+$00c0;
MACB_wol:     LongInt absolute AVR32_MACB_ADDRESS+$00c4;
MACB_version: LongInt absolute AVR32_MACB_ADDRESS+$00fc;
(* MDMA *)
type
 Tavr32_mdma_channel_t = packed record
    cdar,rar,war,ccr: LongInt;
end;

var
MDMA_cr:       LongInt absolute AVR32_MDMA_ADDRESS;
MDMA_ier:      LongInt absolute AVR32_MDMA_ADDRESS+$0004;
MDMA_idr:      LongInt absolute AVR32_MDMA_ADDRESS+$0008;
MDMA_imr:      LongInt absolute AVR32_MDMA_ADDRESS+$000c;
MDMA_isr:      LongInt absolute AVR32_MDMA_ADDRESS+$0010;
MDMA_icr:      LongInt absolute AVR32_MDMA_ADDRESS+$0014;
MDMA_pr:       LongInt absolute AVR32_MDMA_ADDRESS+$0018;
MDMA_vr:       LongInt absolute AVR32_MDMA_ADDRESS+$001c;
MDMA_descriptor_channel: array[0..3] of LongInt absolute AVR32_MDMA_ADDRESS+$0020;
MDMA_channel: array[0..3] of Tavr32_mdma_channel_t  absolute AVR32_MDMA_ADDRESS+$0040;
(* PDCA *)
type
Tavr32_pdca_channel_t = packed record
    mar,psr,tcr,marr,tcrr,cr,mr,
    sr,ier,idr,imr,isr : LongInt;
    res0: array[0..3] of LongInt;
    end;

var
PDCA_channel: array[0..(AVR32_PDCA_CHANNEL_LENGTH-1)] of Tavr32_pdca_channel_t absolute AVR32_PDCA_ADDRESS;
PDCA_pcontrol: LongInt absolute AVR32_PDCA_ADDRESS+$0800;
PDCA_prdata0:  LongInt absolute AVR32_PDCA_ADDRESS+$0804;
PDCA_prstall0: LongInt absolute AVR32_PDCA_ADDRESS+$0808;
PDCA_prlat0:   LongInt absolute AVR32_PDCA_ADDRESS+$080c;
PDCA_pwdata0:  LongInt absolute AVR32_PDCA_ADDRESS+$0810;
PDCA_pwstall0: LongInt absolute AVR32_PDCA_ADDRESS+$0814;
PDCA_pwlat0:   LongInt absolute AVR32_PDCA_ADDRESS+$0818;
PDCA_prdata1:  LongInt absolute AVR32_PDCA_ADDRESS+$081c;
PDCA_prstall1: LongInt absolute AVR32_PDCA_ADDRESS+$0820;
PDCA_prlat1:   LongInt absolute AVR32_PDCA_ADDRESS+$0824;
PDCA_pwdata1:  LongInt absolute AVR32_PDCA_ADDRESS+$0828;
PDCA_pwstall1: LongInt absolute AVR32_PDCA_ADDRESS+$082c;
PDCA_pwlat1:   LongInt absolute AVR32_PDCA_ADDRESS+$0830;
PDCA_version:  LongInt absolute AVR32_PDCA_ADDRESS+$0834;
(* PEVC *)
PEVC_version:   LongInt absolute AVR32_PEVC_ADDRESS;
PEVC_parameter: LongInt absolute AVR32_PEVC_ADDRESS+$0004;
PEVC_igfdr:     LongInt absolute AVR32_PEVC_ADDRESS+$0008;
PEVC_chsr0:     LongInt absolute AVR32_PEVC_ADDRESS+$0010;
PEVC_chsr1:     LongInt absolute AVR32_PEVC_ADDRESS+$0014;
PEVC_cher0:     LongInt absolute AVR32_PEVC_ADDRESS+$0020;
PEVC_cher1:     LongInt absolute AVR32_PEVC_ADDRESS+$0024;
PEVC_chdr0:     LongInt absolute AVR32_PEVC_ADDRESS+$0030;
PEVC_chdr1:     LongInt absolute AVR32_PEVC_ADDRESS+$0034;
PEVC_sev0:      LongInt absolute AVR32_PEVC_ADDRESS+$0040;
PEVC_sev1:      LongInt absolute AVR32_PEVC_ADDRESS+$0044;
PEVC_busy0:     LongInt absolute AVR32_PEVC_ADDRESS+$0050;
PEVC_busy1:     LongInt absolute AVR32_PEVC_ADDRESS+$0054;
PEVC_trsr0:     LongInt absolute AVR32_PEVC_ADDRESS+$0060;
PEVC_trsr1:     LongInt absolute AVR32_PEVC_ADDRESS+$0064;
PEVC_trscr0:    LongInt absolute AVR32_PEVC_ADDRESS+$0070;
PEVC_trscr1:    LongInt absolute AVR32_PEVC_ADDRESS+$0074;
PEVC_trimr0:    LongInt absolute AVR32_PEVC_ADDRESS+$0080;
PEVC_trimr1:    LongInt absolute AVR32_PEVC_ADDRESS+$0084;
PEVC_trier0:    LongInt absolute AVR32_PEVC_ADDRESS+$0090;
PEVC_trier1:    LongInt absolute AVR32_PEVC_ADDRESS+$0094;
PEVC_tridr0:    LongInt absolute AVR32_PEVC_ADDRESS+$00a0;
PEVC_tridr1:    LongInt absolute AVR32_PEVC_ADDRESS+$00a4;
PEVC_ovsr0:     LongInt absolute AVR32_PEVC_ADDRESS+$00b0;
PEVC_ovsr1:     LongInt absolute AVR32_PEVC_ADDRESS+$00b4;
PEVC_ovscr0:    LongInt absolute AVR32_PEVC_ADDRESS+$00c0;
PEVC_ovscr1:    LongInt absolute AVR32_PEVC_ADDRESS+$00c4;
PEVC_ovimr0:    LongInt absolute AVR32_PEVC_ADDRESS+$00d0;
PEVC_ovimr1:    LongInt absolute AVR32_PEVC_ADDRESS+$00d4;
PEVC_ovier0:    LongInt absolute AVR32_PEVC_ADDRESS+$00e0;
PEVC_ovier1:    LongInt absolute AVR32_PEVC_ADDRESS+$00e4;
PEVC_ovidr0:    LongInt absolute AVR32_PEVC_ADDRESS+$00f0;
PEVC_ovidr1:    LongInt absolute AVR32_PEVC_ADDRESS+$00f4;
PEVC_chmx:      array[0..(AVR32_PEVC_TRIGOUT_BITS-1)] of LongInt absolute AVR32_PEVC_ADDRESS+$0100;
PEVC_evs:       array[0..(AVR32_PEVC_EVS_BITS-1)] of LongInt absolute AVR32_PEVC_ADDRESS+$0200;
(* PM *)
PM_mcctrl:     LongInt absolute AVR32_PM_ADDRESS;
PM_cpusel:     LongInt absolute AVR32_PM_ADDRESS+$0004;
PM_hsbsel:     LongInt absolute AVR32_PM_ADDRESS+$0008;
PM_pbasel:     LongInt absolute AVR32_PM_ADDRESS+$000c;
PM_pbbsel:     LongInt absolute AVR32_PM_ADDRESS+$0010;
PM_pbcsel:     LongInt absolute AVR32_PM_ADDRESS+$0014;
PM_cpumask:    LongInt absolute AVR32_PM_ADDRESS+$0020;
PM_hsbmask:    LongInt absolute AVR32_PM_ADDRESS+$0024;
PM_pbamask:    LongInt absolute AVR32_PM_ADDRESS+$0028;
PM_pbbmask:    LongInt absolute AVR32_PM_ADDRESS+$002c;
PM_pbcmask:    LongInt absolute AVR32_PM_ADDRESS+$0030;
PM_pbadivmask: LongInt absolute AVR32_PM_ADDRESS+$0040;
PM_pbbdivmask: LongInt absolute AVR32_PM_ADDRESS+$0044;
PM_pbcdivmask: LongInt absolute AVR32_PM_ADDRESS+$0048;
PM_cfdctrl:    LongInt absolute AVR32_PM_ADDRESS+$0054;
PM_unlock:     LongInt absolute AVR32_PM_ADDRESS+$0058;
PM_ier:        LongInt absolute AVR32_PM_ADDRESS+$00c0;
PM_idr:        LongInt absolute AVR32_PM_ADDRESS+$00c4;
PM_imr:        LongInt absolute AVR32_PM_ADDRESS+$00c8;
PM_isr:        LongInt absolute AVR32_PM_ADDRESS+$00cc;
PM_icr:        LongInt absolute AVR32_PM_ADDRESS+$00d0;
PM_sr:         LongInt absolute AVR32_PM_ADDRESS+$00d4;
PM_ppcr:       LongInt absolute AVR32_PM_ADDRESS+$0160;
PM_rcause:     LongInt absolute AVR32_PM_ADDRESS+$0180;
PM_wcause:     LongInt absolute AVR32_PM_ADDRESS+$0184;
PM_awen:       LongInt absolute AVR32_PM_ADDRESS+$0188;
PM_config:     LongInt absolute AVR32_PM_ADDRESS+$03f8;
PM_version:    LongInt absolute AVR32_PM_ADDRESS+$03fc;
(* PWM *)
type
Tavr32_pwm_channel_t = packed record
    cmr,cdty,cdtyupd,cprd,cprdupd,ccnt,dt,dtupd: LongInt;
end;

type
Tavr32_pwm_comp_t = packed record
    cmp0v,cmp0vupd,cmp0m,cmp0mupd: LongInt;
end;

var
PWM_clk:       LongInt absolute AVR32_PWM_ADDRESS+$0000;
PWM_ena:       LongInt absolute AVR32_PWM_ADDRESS+$0004;
PWM_dis:       LongInt absolute AVR32_PWM_ADDRESS+$0008;
PWM_sr:        LongInt absolute AVR32_PWM_ADDRESS+$000c;
PWM_ier1:      LongInt absolute AVR32_PWM_ADDRESS+$0010;
PWM_idr1:      LongInt absolute AVR32_PWM_ADDRESS+$0014;
PWM_imr1:      LongInt absolute AVR32_PWM_ADDRESS+$0018;
PWM_isr1:      LongInt absolute AVR32_PWM_ADDRESS+$001c;
PWM_scm:       LongInt absolute AVR32_PWM_ADDRESS+$0020;
PWM_pdcdata:   LongInt absolute AVR32_PWM_ADDRESS+$0024;
PWM_scuc:      LongInt absolute AVR32_PWM_ADDRESS+$0028;
PWM_scup:      LongInt absolute AVR32_PWM_ADDRESS+$002c;
PWM_scupupd:   LongInt absolute AVR32_PWM_ADDRESS+$0030;
PWM_ier2:      LongInt absolute AVR32_PWM_ADDRESS+$0034;
PWM_idr2:      LongInt absolute AVR32_PWM_ADDRESS+$0038;
PWM_imr2:      LongInt absolute AVR32_PWM_ADDRESS+$003c;
PWM_isr2:      LongInt absolute AVR32_PWM_ADDRESS+$0040;
PWM_oov:       LongInt absolute AVR32_PWM_ADDRESS+$0044;
PWM_os:        LongInt absolute AVR32_PWM_ADDRESS+$0048;
PWM_oss:       LongInt absolute AVR32_PWM_ADDRESS+$004c;
PWM_osc:       LongInt absolute AVR32_PWM_ADDRESS+$0050;
PWM_ossupd:    LongInt absolute AVR32_PWM_ADDRESS+$0054;
PWM_oscupd:    LongInt absolute AVR32_PWM_ADDRESS+$0058;
PWM_fmr:       LongInt absolute AVR32_PWM_ADDRESS+$005c;
PWM_fsr:       LongInt absolute AVR32_PWM_ADDRESS+$0060;
PWM_fcr:       LongInt absolute AVR32_PWM_ADDRESS+$0064;
PWM_fpv:       LongInt absolute AVR32_PWM_ADDRESS+$0068;
PWM_fpe1:      LongInt absolute AVR32_PWM_ADDRESS+$006c;
PWM_elxmr:     array [0..(AVR32_PWM_EVT_NUM-1)] of LongInt absolute AVR32_PWM_ADDRESS+$007c;
PWM_smmr:      LongInt absolute AVR32_PWM_ADDRESS+$00b0;
PWM_wpcr:      LongInt absolute AVR32_PWM_ADDRESS+$00e4;
PWM_wpsr:      LongInt absolute AVR32_PWM_ADDRESS+$00e8;
PWM_version:   LongInt absolute AVR32_PWM_ADDRESS+$00fc;
PWM_tpr:       LongInt absolute AVR32_PWM_ADDRESS+$0108;
PWM_tcr:       LongInt absolute AVR32_PWM_ADDRESS+$010c;
PWM_tnpr:      LongInt absolute AVR32_PWM_ADDRESS+$0118;
PWM_tncr:      LongInt absolute AVR32_PWM_ADDRESS+$011c;
PWM_ptcr:      LongInt absolute AVR32_PWM_ADDRESS+$0120;
PWM_ptsr:      LongInt absolute AVR32_PWM_ADDRESS+$0124;
PWM_comp:      array[0..(AVR32_PWM_CMP_NUM-1)] of Tavr32_pwm_comp_t absolute AVR32_PWM_ADDRESS+$130;
PWM_channel:   array[0..(AVR32_PWM_CHANNEL_NUM-1)] of Tavr32_pwm_channel_t absolute AVR32_PWM_ADDRESS+$200;
(* QDEC0 *)
QDEC0_ctrl:      LongInt absolute AVR32_QDEC0_ADDRESS;
QDEC0_cf:        LongInt absolute AVR32_QDEC0_ADDRESS+$0004;
QDEC0_cnt:       LongInt absolute AVR32_QDEC0_ADDRESS+$0008;
QDEC0_top:       LongInt absolute AVR32_QDEC0_ADDRESS+$000c;
QDEC0_cmp:       LongInt absolute AVR32_QDEC0_ADDRESS+$0010;
QDEC0_cap:       LongInt absolute AVR32_QDEC0_ADDRESS+$0014;
QDEC0_sr :       LongInt absolute AVR32_QDEC0_ADDRESS+$0018;
QDEC0_scr:       LongInt absolute AVR32_QDEC0_ADDRESS+$001c;
QDEC0_imr:       LongInt absolute AVR32_QDEC0_ADDRESS+$0020;
QDEC0_ier:       LongInt absolute AVR32_QDEC0_ADDRESS+$0024;
QDEC0_idr:       LongInt absolute AVR32_QDEC0_ADDRESS+$0028;
QDEC0_parameter: LongInt absolute AVR32_QDEC0_ADDRESS+$002c;
QDEC0_version:   LongInt absolute AVR32_QDEC0_ADDRESS+$0030;
(* QDEC1 *)
QDEC1_ctrl:      LongInt absolute AVR32_QDEC1_ADDRESS;
QDEC1_cf:        LongInt absolute AVR32_QDEC1_ADDRESS+$0004;
QDEC1_cnt:       LongInt absolute AVR32_QDEC1_ADDRESS+$0008;
QDEC1_top:       LongInt absolute AVR32_QDEC1_ADDRESS+$000c;
QDEC1_cmp:       LongInt absolute AVR32_QDEC1_ADDRESS+$0010;
QDEC1_cap:       LongInt absolute AVR32_QDEC1_ADDRESS+$0014;
QDEC1_sr :       LongInt absolute AVR32_QDEC1_ADDRESS+$0018;
QDEC1_scr:       LongInt absolute AVR32_QDEC1_ADDRESS+$001c;
QDEC1_imr:       LongInt absolute AVR32_QDEC1_ADDRESS+$0020;
QDEC1_ier:       LongInt absolute AVR32_QDEC1_ADDRESS+$0024;
QDEC1_idr:       LongInt absolute AVR32_QDEC1_ADDRESS+$0028;
QDEC1_parameter: LongInt absolute AVR32_QDEC1_ADDRESS+$002c;
QDEC1_version:   LongInt absolute AVR32_QDEC1_ADDRESS+$0030;
(* SAU *)
SAU_cr:        LongInt absolute AVR32_SAU_ADDRESS;
SAU_config:    LongInt absolute AVR32_SAU_ADDRESS+$0004;
SAU_cerh:      LongInt absolute AVR32_SAU_ADDRESS+$0008;
SAU_cerl:      LongInt absolute AVR32_SAU_ADDRESS+$000c;
SAU_sr:        LongInt absolute AVR32_SAU_ADDRESS+$0010;
SAU_ier:       LongInt absolute AVR32_SAU_ADDRESS+$0014;
SAU_idr:       LongInt absolute AVR32_SAU_ADDRESS+$0018;
SAU_imr:       LongInt absolute AVR32_SAU_ADDRESS+$001c;
SAU_icr:       LongInt absolute AVR32_SAU_ADDRESS+$0020;
SAU_parameter: LongInt absolute AVR32_SAU_ADDRESS+$0024;
SAU_version:   LongInt absolute AVR32_SAU_ADDRESS+$0028;
SAU_rtr:       array[0..(AVR32_SAU_CHANNELS-1)] of LongInt absolute AVR32_SAU_HSB_ADDRESS;
SAU_ur:        LongInt absolute AVR32_SAU_HSB_ADDRESS+$00fc;
(* SCIF *)
SCIF_ier:           LongInt absolute AVR32_SCIF_ADDRESS;
SCIF_idr:           LongInt absolute AVR32_SCIF_ADDRESS+$0004;
SCIF_imr:           LongInt absolute AVR32_SCIF_ADDRESS+$0008;
SCIF_isr:           LongInt absolute AVR32_SCIF_ADDRESS+$000c;
SCIF_icr:           LongInt absolute AVR32_SCIF_ADDRESS+$0010;
SCIF_pclksr:        LongInt absolute AVR32_SCIF_ADDRESS+$0014;
SCIF_unlock:        LongInt absolute AVR32_SCIF_ADDRESS+$0018;
SCIF_pll:           array [0..12] of LongInt absolute AVR32_SCIF_ADDRESS+$001c;
SCIF_oscctrl:       array [0..12] of LongInt absolute AVR32_SCIF_ADDRESS+$0024;
SCIF_bod:           LongInt absolute AVR32_SCIF_ADDRESS+$002c;
SCIF_bgcr:          LongInt absolute AVR32_SCIF_ADDRESS+$0030;
SCIF_bod33:         LongInt absolute AVR32_SCIF_ADDRESS+$0034;
SCIF_bod50:         LongInt absolute AVR32_SCIF_ADDRESS+$0038;
SCIF_vregcr:        LongInt absolute AVR32_SCIF_ADDRESS+$003c;
SCIF_vregctrl:      LongInt absolute AVR32_SCIF_ADDRESS+$0040;
SCIF_rccr:          LongInt absolute AVR32_SCIF_ADDRESS+$0044;
SCIF_rccr8:         LongInt absolute AVR32_SCIF_ADDRESS+$0048;
SCIF_oscctrl32:     LongInt absolute AVR32_SCIF_ADDRESS+$004c;
SCIF_tsens:         LongInt absolute AVR32_SCIF_ADDRESS+$0050;
SCIF_criposc:       LongInt absolute AVR32_SCIF_ADDRESS+$0054;
SCIF_rc120mcr:      LongInt absolute AVR32_SCIF_ADDRESS+$0058;
SCIF_gplp:          array[0..1]  of LongInt absolute AVR32_SCIF_ADDRESS+$005c;
SCIF_gcctrl:        array[0..10] of LongInt absolute AVR32_SCIF_ADDRESS+$0064;
SCIF_pllversion:    LongInt absolute AVR32_SCIF_ADDRESS+$03c8;
SCIF_oscversion:    LongInt absolute AVR32_SCIF_ADDRESS+$03cc;
SCIF_bodversion:    LongInt absolute AVR32_SCIF_ADDRESS+$03d0;
SCIF_bodbversion:   LongInt absolute AVR32_SCIF_ADDRESS+$03d4;
SCIF_vregversion:   LongInt absolute AVR32_SCIF_ADDRESS+$03d8;
SCIF_rccrversion:   LongInt absolute AVR32_SCIF_ADDRESS+$03dc;
SCIF_rccr8version:  LongInt absolute AVR32_SCIF_ADDRESS+$03e0;
SCIF_osc32version:  LongInt absolute AVR32_SCIF_ADDRESS+$03e4;
SCIF_tsensversion:  LongInt absolute AVR32_SCIF_ADDRESS+$03e8;
SCIF_criposcversion:LongInt absolute AVR32_SCIF_ADDRESS+$03ec;
SCIF_rc120mversion: LongInt absolute AVR32_SCIF_ADDRESS+$03f0;
SCIF_gplpversion:   LongInt absolute AVR32_SCIF_ADDRESS+$03f4;
SCIF_gclkversion:   LongInt absolute AVR32_SCIF_ADDRESS+$03f8;
SCIF_version:       LongInt absolute AVR32_SCIF_ADDRESS+$03fc;
(* SPI0 *)
SPI0_cr:        LongInt absolute AVR32_SPI0_ADDRESS;
SPI0_mr:        LongInt absolute AVR32_SPI0_ADDRESS+$0004;
SPI0_rdr:       LongInt absolute AVR32_SPI0_ADDRESS+$0008;
SPI0_tdr:       LongInt absolute AVR32_SPI0_ADDRESS+$000c;
SPI0_sr:        LongInt absolute AVR32_SPI0_ADDRESS+$0010;
SPI0_ier:       LongInt absolute AVR32_SPI0_ADDRESS+$0014;
SPI0_idr:       LongInt absolute AVR32_SPI0_ADDRESS+$0018;
SPI0_imr:       LongInt absolute AVR32_SPI0_ADDRESS+$001c;
SPI0_csr0:      LongInt absolute AVR32_SPI0_ADDRESS+$0030;
SPI0_csr1:      LongInt absolute AVR32_SPI0_ADDRESS+$0034;
SPI0_csr2:      LongInt absolute AVR32_SPI0_ADDRESS+$0038;
SPI0_csr3:      LongInt absolute AVR32_SPI0_ADDRESS+$003c;
SPI0_wpcr:      LongInt absolute AVR32_SPI0_ADDRESS+$00e4;
SPI0_wpsr:      LongInt absolute AVR32_SPI0_ADDRESS+$00e8;
SPI0_version:   LongInt absolute AVR32_SPI0_ADDRESS+$00fc;
(* SPI1 *)
SPI1_cr:        LongInt absolute AVR32_SPI1_ADDRESS;
SPI1_mr:        LongInt absolute AVR32_SPI1_ADDRESS+$0004;
SPI1_rdr:       LongInt absolute AVR32_SPI1_ADDRESS+$0008;
SPI1_tdr:       LongInt absolute AVR32_SPI1_ADDRESS+$000c;
SPI1_sr:        LongInt absolute AVR32_SPI1_ADDRESS+$0010;
SPI1_ier:       LongInt absolute AVR32_SPI1_ADDRESS+$0014;
SPI1_idr:       LongInt absolute AVR32_SPI1_ADDRESS+$0018;
SPI1_imr:       LongInt absolute AVR32_SPI1_ADDRESS+$001c;
SPI1_csr0:      LongInt absolute AVR32_SPI1_ADDRESS+$0030;
SPI1_csr1:      LongInt absolute AVR32_SPI1_ADDRESS+$0034;
SPI1_csr2:      LongInt absolute AVR32_SPI1_ADDRESS+$0038;
SPI1_csr3:      LongInt absolute AVR32_SPI1_ADDRESS+$003c;
SPI1_wpcr:      LongInt absolute AVR32_SPI1_ADDRESS+$00e4;
SPI1_wpsr:      LongInt absolute AVR32_SPI1_ADDRESS+$00e8;
SPI1_version:   LongInt absolute AVR32_SPI1_ADDRESS+$00fc;
{ TC }
type
Tavr32_tc_channel_t = packed record
  ccr,cmr: LongInt;
  res0: array[0..1] of LongInt;
  cv,ra,rb,rc,sr,ier,idr,imr : LongInt;
  res1: array[0..3] of LongInt;
end;
(* TC0 *)
var
TC0_channel: array[0..2] of Tavr32_tc_channel_t absolute AVR32_TC0_ADDRESS;
TC0_bcr:     LongInt absolute AVR32_TC0_ADDRESS+$00c0;
TC0_bmr:     LongInt absolute AVR32_TC0_ADDRESS+$00c4;
TC0_version: LongInt absolute AVR32_TC0_ADDRESS+$00fc;
(* TC1 *)
TC1_channel: array[0..2] of Tavr32_tc_channel_t absolute AVR32_TC1_ADDRESS;
TC1_bcr:     LongInt absolute AVR32_TC1_ADDRESS+$00c0;
TC1_bmr:     LongInt absolute AVR32_TC1_ADDRESS+$00c4;
TC1_version: LongInt absolute AVR32_TC1_ADDRESS+$00fc;
(* TWIM0 *)
TWIM0_cr:        LongInt absolute AVR32_TWIM0_ADDRESS;
TWIM0_cwgr:      LongInt absolute AVR32_TWIM0_ADDRESS+$0004;
TWIM0_smbtr:     LongInt absolute AVR32_TWIM0_ADDRESS+$0008;
TWIM0_cmdr:      LongInt absolute AVR32_TWIM0_ADDRESS+$000c;
TWIM0_ncmdr:     LongInt absolute AVR32_TWIM0_ADDRESS+$0010;
TWIM0_rhr:       LongInt absolute AVR32_TWIM0_ADDRESS+$0014;
TWIM0_thr:       LongInt absolute AVR32_TWIM0_ADDRESS+$0018;
TWIM0_sr:        LongInt absolute AVR32_TWIM0_ADDRESS+$001c;
TWIM0_ier:       LongInt absolute AVR32_TWIM0_ADDRESS+$0020;
TWIM0_idr:       LongInt absolute AVR32_TWIM0_ADDRESS+$0024;
TWIM0_imr:       LongInt absolute AVR32_TWIM0_ADDRESS+$0028;
TWIM0_scr:       LongInt absolute AVR32_TWIM0_ADDRESS+$002c;
TWIM0_pr:        LongInt absolute AVR32_TWIM0_ADDRESS+$0030;
TWIM0_vr:        LongInt absolute AVR32_TWIM0_ADDRESS+$0034;
(* TWIM1 *)
TWIM1_cr:        LongInt absolute AVR32_TWIM1_ADDRESS;
TWIM1_cwgr:      LongInt absolute AVR32_TWIM1_ADDRESS+$0004;
TWIM1_smbtr:     LongInt absolute AVR32_TWIM1_ADDRESS+$0008;
TWIM1_cmdr:      LongInt absolute AVR32_TWIM1_ADDRESS+$000c;
TWIM1_ncmdr:     LongInt absolute AVR32_TWIM1_ADDRESS+$0010;
TWIM1_rhr:       LongInt absolute AVR32_TWIM1_ADDRESS+$0014;
TWIM1_thr:       LongInt absolute AVR32_TWIM1_ADDRESS+$0018;
TWIM1_sr:        LongInt absolute AVR32_TWIM1_ADDRESS+$001c;
TWIM1_ier:       LongInt absolute AVR32_TWIM1_ADDRESS+$0020;
TWIM1_idr:       LongInt absolute AVR32_TWIM1_ADDRESS+$0024;
TWIM1_imr:       LongInt absolute AVR32_TWIM1_ADDRESS+$0028;
TWIM1_scr:       LongInt absolute AVR32_TWIM1_ADDRESS+$002c;
TWIM1_pr:        LongInt absolute AVR32_TWIM1_ADDRESS+$0030;
TWIM1_vr:        LongInt absolute AVR32_TWIM1_ADDRESS+$0034;
(* TWIM2 *)
TWIM2_cr:        LongInt absolute AVR32_TWIM2_ADDRESS;
TWIM2_cwgr:      LongInt absolute AVR32_TWIM2_ADDRESS+$0004;
TWIM2_smbtr:     LongInt absolute AVR32_TWIM2_ADDRESS+$0008;
TWIM2_cmdr:      LongInt absolute AVR32_TWIM2_ADDRESS+$000c;
TWIM2_ncmdr:     LongInt absolute AVR32_TWIM2_ADDRESS+$0010;
TWIM2_rhr:       LongInt absolute AVR32_TWIM2_ADDRESS+$0014;
TWIM2_thr:       LongInt absolute AVR32_TWIM2_ADDRESS+$0018;
TWIM2_sr:        LongInt absolute AVR32_TWIM2_ADDRESS+$001c;
TWIM2_ier:       LongInt absolute AVR32_TWIM2_ADDRESS+$0020;
TWIM2_idr:       LongInt absolute AVR32_TWIM2_ADDRESS+$0024;
TWIM2_imr:       LongInt absolute AVR32_TWIM2_ADDRESS+$0028;
TWIM2_scr:       LongInt absolute AVR32_TWIM2_ADDRESS+$002c;
TWIM2_pr:        LongInt absolute AVR32_TWIM2_ADDRESS+$0030;
TWIM2_vr:        LongInt absolute AVR32_TWIM2_ADDRESS+$0034;
(* TWIS0 *)
TWIS0_cr:        LongInt absolute AVR32_TWIS0_ADDRESS;
TWIS0_nbytes:    LongInt absolute AVR32_TWIS0_ADDRESS+$0004;
TWIS0_tr:        LongInt absolute AVR32_TWIS0_ADDRESS+$0008;
TWIS0_rhr:       LongInt absolute AVR32_TWIS0_ADDRESS+$000c;
TWIS0_thr:       LongInt absolute AVR32_TWIS0_ADDRESS+$0010;
TWIS0_pecr:      LongInt absolute AVR32_TWIS0_ADDRESS+$0014;
TWIS0_sr:        LongInt absolute AVR32_TWIS0_ADDRESS+$0018;
TWIS0_ier:       LongInt absolute AVR32_TWIS0_ADDRESS+$001c;
TWIS0_idr:       LongInt absolute AVR32_TWIS0_ADDRESS+$0020;
TWIS0_imr:       LongInt absolute AVR32_TWIS0_ADDRESS+$0024;
TWIS0_scr:       LongInt absolute AVR32_TWIS0_ADDRESS+$0028;
TWIS0_pr:        LongInt absolute AVR32_TWIS0_ADDRESS+$002c;
TWIS0_vr:        LongInt absolute AVR32_TWIS0_ADDRESS+$0030;
(* TWIS1 *)
TWIS1_cr:        LongInt absolute AVR32_TWIS1_ADDRESS;
TWIS1_nbytes:    LongInt absolute AVR32_TWIS1_ADDRESS+$0004;
TWIS1_tr:        LongInt absolute AVR32_TWIS1_ADDRESS+$0008;
TWIS1_rhr:       LongInt absolute AVR32_TWIS1_ADDRESS+$000c;
TWIS1_thr:       LongInt absolute AVR32_TWIS1_ADDRESS+$0010;
TWIS1_pecr:      LongInt absolute AVR32_TWIS1_ADDRESS+$0014;
TWIS1_sr:        LongInt absolute AVR32_TWIS1_ADDRESS+$0018;
TWIS1_ier:       LongInt absolute AVR32_TWIS1_ADDRESS+$001c;
TWIS1_idr:       LongInt absolute AVR32_TWIS1_ADDRESS+$0020;
TWIS1_imr:       LongInt absolute AVR32_TWIS1_ADDRESS+$0024;
TWIS1_scr:       LongInt absolute AVR32_TWIS1_ADDRESS+$0028;
TWIS1_pr:        LongInt absolute AVR32_TWIS1_ADDRESS+$002c;
TWIS1_vr:        LongInt absolute AVR32_TWIS1_ADDRESS+$0030;
(* TWIS2 *)
TWIS2_cr:        LongInt absolute AVR32_TWIS2_ADDRESS;
TWIS2_nbytes:    LongInt absolute AVR32_TWIS2_ADDRESS+$0004;
TWIS2_tr:        LongInt absolute AVR32_TWIS2_ADDRESS+$0008;
TWIS2_rhr:       LongInt absolute AVR32_TWIS2_ADDRESS+$000c;
TWIS2_thr:       LongInt absolute AVR32_TWIS2_ADDRESS+$0010;
TWIS2_pecr:      LongInt absolute AVR32_TWIS2_ADDRESS+$0014;
TWIS2_sr:        LongInt absolute AVR32_TWIS2_ADDRESS+$0018;
TWIS2_ier:       LongInt absolute AVR32_TWIS2_ADDRESS+$001c;
TWIS2_idr:       LongInt absolute AVR32_TWIS2_ADDRESS+$0020;
TWIS2_imr:       LongInt absolute AVR32_TWIS2_ADDRESS+$0024;
TWIS2_scr:       LongInt absolute AVR32_TWIS2_ADDRESS+$0028;
TWIS2_pr:        LongInt absolute AVR32_TWIS2_ADDRESS+$002c;
TWIS2_vr:        LongInt absolute AVR32_TWIS2_ADDRESS+$0030;
(* USART0 *)
UART0_cr:        LongInt absolute AVR32_USART0_ADDRESS;
UART0_mr:        LongInt absolute AVR32_USART0_ADDRESS+$0004;
UART0_ier:       LongInt absolute AVR32_USART0_ADDRESS+$0008;
UART0_idr:       LongInt absolute AVR32_USART0_ADDRESS+$000c;
UART0_imr:       LongInt absolute AVR32_USART0_ADDRESS+$0010;
UART0_csr:       LongInt absolute AVR32_USART0_ADDRESS+$0014;
UART0_rhr:       LongInt absolute AVR32_USART0_ADDRESS+$0018;
UART0_thr:       LongInt absolute AVR32_USART0_ADDRESS+$001c;
UART0_brgr:      LongInt absolute AVR32_USART0_ADDRESS+$0020;
UART0_rtor:      LongInt absolute AVR32_USART0_ADDRESS+$0024;
UART0_ttgr:      LongInt absolute AVR32_USART0_ADDRESS+$0028;
UART0_fidi:      LongInt absolute AVR32_USART0_ADDRESS+$0040;
UART0_ner:       LongInt absolute AVR32_USART0_ADDRESS+$0044;
UART0_xxr:       LongInt absolute AVR32_USART0_ADDRESS+$0048;
UART0_ifr:       LongInt absolute AVR32_USART0_ADDRESS+$004c;
UART0_man:       LongInt absolute AVR32_USART0_ADDRESS+$0050;
UART0_linmr:     LongInt absolute AVR32_USART0_ADDRESS+$0054;
UART0_linir:     LongInt absolute AVR32_USART0_ADDRESS+$0058;
UART0_linbrr:    LongInt absolute AVR32_USART0_ADDRESS+$005c;
UART0_wpmr:      LongInt absolute AVR32_USART0_ADDRESS+$00e4;
UART0_wpsr:      LongInt absolute AVR32_USART0_ADDRESS+$00e8;
UART0_features:  LongInt absolute AVR32_USART0_ADDRESS+$00f8;
UART0_version:   LongInt absolute AVR32_USART0_ADDRESS+$00fc;
(* USART1 *)
UART1_cr:        LongInt absolute AVR32_USART1_ADDRESS;
UART1_mr:        LongInt absolute AVR32_USART1_ADDRESS+$0004;
UART1_ier:       LongInt absolute AVR32_USART1_ADDRESS+$0008;
UART1_idr:       LongInt absolute AVR32_USART1_ADDRESS+$000c;
UART1_imr:       LongInt absolute AVR32_USART1_ADDRESS+$0010;
UART1_csr:       LongInt absolute AVR32_USART1_ADDRESS+$0014;
UART1_rhr:       LongInt absolute AVR32_USART1_ADDRESS+$0018;
UART1_thr:       LongInt absolute AVR32_USART1_ADDRESS+$001c;
UART1_brgr:      LongInt absolute AVR32_USART1_ADDRESS+$0020;
UART1_rtor:      LongInt absolute AVR32_USART1_ADDRESS+$0024;
UART1_ttgr:      LongInt absolute AVR32_USART1_ADDRESS+$0028;
UART1_fidi:      LongInt absolute AVR32_USART1_ADDRESS+$0040;
UART1_ner:       LongInt absolute AVR32_USART1_ADDRESS+$0044;
UART1_xxr:       LongInt absolute AVR32_USART1_ADDRESS+$0048;
UART1_ifr:       LongInt absolute AVR32_USART1_ADDRESS+$004c;
UART1_man:       LongInt absolute AVR32_USART1_ADDRESS+$0050;
UART1_linmr:     LongInt absolute AVR32_USART1_ADDRESS+$0054;
UART1_linir:     LongInt absolute AVR32_USART1_ADDRESS+$0058;
UART1_linbrr:    LongInt absolute AVR32_USART1_ADDRESS+$005c;
UART1_wpmr:      LongInt absolute AVR32_USART1_ADDRESS+$00e4;
UART1_wpsr:      LongInt absolute AVR32_USART1_ADDRESS+$00e8;
UART1_features:  LongInt absolute AVR32_USART1_ADDRESS+$00f8;
UART1_version:   LongInt absolute AVR32_USART1_ADDRESS+$00fc;
(* USART2 *)
UART2_cr:        LongInt absolute AVR32_USART2_ADDRESS;
UART2_mr:        LongInt absolute AVR32_USART2_ADDRESS+$0004;
UART2_ier:       LongInt absolute AVR32_USART2_ADDRESS+$0008;
UART2_idr:       LongInt absolute AVR32_USART2_ADDRESS+$000c;
UART2_imr:       LongInt absolute AVR32_USART2_ADDRESS+$0010;
UART2_csr:       LongInt absolute AVR32_USART2_ADDRESS+$0014;
UART2_rhr:       LongInt absolute AVR32_USART2_ADDRESS+$0018;
UART2_thr:       LongInt absolute AVR32_USART2_ADDRESS+$001c;
UART2_brgr:      LongInt absolute AVR32_USART2_ADDRESS+$0020;
UART2_rtor:      LongInt absolute AVR32_USART2_ADDRESS+$0024;
UART2_ttgr:      LongInt absolute AVR32_USART2_ADDRESS+$0028;
UART2_fidi:      LongInt absolute AVR32_USART2_ADDRESS+$0040;
UART2_ner:       LongInt absolute AVR32_USART2_ADDRESS+$0044;
UART2_xxr:       LongInt absolute AVR32_USART2_ADDRESS+$0048;
UART2_ifr:       LongInt absolute AVR32_USART2_ADDRESS+$004c;
UART2_man:       LongInt absolute AVR32_USART2_ADDRESS+$0050;
UART2_linmr:     LongInt absolute AVR32_USART2_ADDRESS+$0054;
UART2_linir:     LongInt absolute AVR32_USART2_ADDRESS+$0058;
UART2_linbrr:    LongInt absolute AVR32_USART2_ADDRESS+$005c;
UART2_wpmr:      LongInt absolute AVR32_USART2_ADDRESS+$00e4;
UART2_wpsr:      LongInt absolute AVR32_USART2_ADDRESS+$00e8;
UART2_features:  LongInt absolute AVR32_USART2_ADDRESS+$00f8;
UART2_version:   LongInt absolute AVR32_USART2_ADDRESS+$00fc;
(* USART3 *)
UART3_cr:        LongInt absolute AVR32_USART3_ADDRESS;
UART3_mr:        LongInt absolute AVR32_USART3_ADDRESS+$0004;
UART3_ier:       LongInt absolute AVR32_USART3_ADDRESS+$0008;
UART3_idr:       LongInt absolute AVR32_USART3_ADDRESS+$000c;
UART3_imr:       LongInt absolute AVR32_USART3_ADDRESS+$0010;
UART3_csr:       LongInt absolute AVR32_USART3_ADDRESS+$0014;
UART3_rhr:       LongInt absolute AVR32_USART3_ADDRESS+$0018;
UART3_thr:       LongInt absolute AVR32_USART3_ADDRESS+$001c;
UART3_brgr:      LongInt absolute AVR32_USART3_ADDRESS+$0020;
UART3_rtor:      LongInt absolute AVR32_USART3_ADDRESS+$0024;
UART3_ttgr:      LongInt absolute AVR32_USART3_ADDRESS+$0028;
UART3_fidi:      LongInt absolute AVR32_USART3_ADDRESS+$0040;
UART3_ner:       LongInt absolute AVR32_USART3_ADDRESS+$0044;
UART3_xxr:       LongInt absolute AVR32_USART3_ADDRESS+$0048;
UART3_ifr:       LongInt absolute AVR32_USART3_ADDRESS+$004c;
UART3_man:       LongInt absolute AVR32_USART3_ADDRESS+$0050;
UART3_linmr:     LongInt absolute AVR32_USART3_ADDRESS+$0054;
UART3_linir:     LongInt absolute AVR32_USART3_ADDRESS+$0058;
UART3_linbrr:    LongInt absolute AVR32_USART3_ADDRESS+$005c;
UART3_wpmr:      LongInt absolute AVR32_USART3_ADDRESS+$00e4;
UART3_wpsr:      LongInt absolute AVR32_USART3_ADDRESS+$00e8;
UART3_features:  LongInt absolute AVR32_USART3_ADDRESS+$00f8;
UART3_version:   LongInt absolute AVR32_USART3_ADDRESS+$00fc;
(* USART4 *)
UART4_cr:        LongInt absolute AVR32_USART4_ADDRESS;
UART4_mr:        LongInt absolute AVR32_USART4_ADDRESS+$0004;
UART4_ier:       LongInt absolute AVR32_USART4_ADDRESS+$0008;
UART4_idr:       LongInt absolute AVR32_USART4_ADDRESS+$000c;
UART4_imr:       LongInt absolute AVR32_USART4_ADDRESS+$0010;
UART4_csr:       LongInt absolute AVR32_USART4_ADDRESS+$0014;
UART4_rhr:       LongInt absolute AVR32_USART4_ADDRESS+$0018;
UART4_thr:       LongInt absolute AVR32_USART4_ADDRESS+$001c;
UART4_brgr:      LongInt absolute AVR32_USART4_ADDRESS+$0020;
UART4_rtor:      LongInt absolute AVR32_USART4_ADDRESS+$0024;
UART4_ttgr:      LongInt absolute AVR32_USART4_ADDRESS+$0028;
UART4_fidi:      LongInt absolute AVR32_USART4_ADDRESS+$0040;
UART4_ner:       LongInt absolute AVR32_USART4_ADDRESS+$0044;
UART4_xxr:       LongInt absolute AVR32_USART4_ADDRESS+$0048;
UART4_ifr:       LongInt absolute AVR32_USART4_ADDRESS+$004c;
UART4_man:       LongInt absolute AVR32_USART4_ADDRESS+$0050;
UART4_linmr:     LongInt absolute AVR32_USART4_ADDRESS+$0054;
UART4_linir:     LongInt absolute AVR32_USART4_ADDRESS+$0058;
UART4_linbrr:    LongInt absolute AVR32_USART4_ADDRESS+$005c;
UART4_wpmr:      LongInt absolute AVR32_USART4_ADDRESS+$00e4;
UART4_wpsr:      LongInt absolute AVR32_USART4_ADDRESS+$00e8;
UART4_features:  LongInt absolute AVR32_USART4_ADDRESS+$00f8;
UART4_version:   LongInt absolute AVR32_USART4_ADDRESS+$00fc;
(* USBC *)
USBC_udcon:     LongInt absolute AVR32_USBC_ADDRESS;
USBC_udint:     LongInt absolute AVR32_USBC_ADDRESS+$0004;
USBC_udintclr:  LongInt absolute AVR32_USBC_ADDRESS+$0008;
USBC_udintset:  LongInt absolute AVR32_USBC_ADDRESS+$000c;
USBC_udinte:    LongInt absolute AVR32_USBC_ADDRESS+$0010;
USBC_udinteclr: LongInt absolute AVR32_USBC_ADDRESS+$0014;
USBC_udinteset: LongInt absolute AVR32_USBC_ADDRESS+$0018;
USBC_uerst:     LongInt absolute AVR32_USBC_ADDRESS+$001c;
USBC_udfnum:    LongInt absolute AVR32_USBC_ADDRESS+$0020;
USBC_uecfg0:    LongInt absolute AVR32_USBC_ADDRESS+$0100;
USBC_uecfg1:    LongInt absolute AVR32_USBC_ADDRESS+$0104;
USBC_uecfg2:    LongInt absolute AVR32_USBC_ADDRESS+$0108;
USBC_uecfg3:    LongInt absolute AVR32_USBC_ADDRESS+$010c;
USBC_uecfg4:    LongInt absolute AVR32_USBC_ADDRESS+$0110;
USBC_uecfg5:    LongInt absolute AVR32_USBC_ADDRESS+$0114;
USBC_uecfg6:    LongInt absolute AVR32_USBC_ADDRESS+$0118;
USBC_uecfg7:    LongInt absolute AVR32_USBC_ADDRESS+$011c;
USBC_uesta0:    LongInt absolute AVR32_USBC_ADDRESS+$0130;
USBC_uesta1:    LongInt absolute AVR32_USBC_ADDRESS+$0134;
USBC_uesta2:    LongInt absolute AVR32_USBC_ADDRESS+$0138;
USBC_uesta3:    LongInt absolute AVR32_USBC_ADDRESS+$013c;
USBC_uesta4:    LongInt absolute AVR32_USBC_ADDRESS+$0140;
USBC_uesta5:    LongInt absolute AVR32_USBC_ADDRESS+$0144;
USBC_uesta6:    LongInt absolute AVR32_USBC_ADDRESS+$0148;
USBC_uesta7:    LongInt absolute AVR32_USBC_ADDRESS+$014c;
USBC_uesta0clr: LongInt absolute AVR32_USBC_ADDRESS+$0160;
USBC_uesta1clr: LongInt absolute AVR32_USBC_ADDRESS+$0164;
USBC_uesta2clr: LongInt absolute AVR32_USBC_ADDRESS+$0168;
USBC_uesta3clr: LongInt absolute AVR32_USBC_ADDRESS+$016c;
USBC_uesta4clr: LongInt absolute AVR32_USBC_ADDRESS+$0170;
USBC_uesta5clr: LongInt absolute AVR32_USBC_ADDRESS+$0174;
USBC_uesta6clr: LongInt absolute AVR32_USBC_ADDRESS+$0178;
USBC_uesta7clr: LongInt absolute AVR32_USBC_ADDRESS+$017c;
USBC_uesta0set: LongInt absolute AVR32_USBC_ADDRESS+$0190;
USBC_uesta1set: LongInt absolute AVR32_USBC_ADDRESS+$0194;
USBC_uesta2set: LongInt absolute AVR32_USBC_ADDRESS+$0198;
USBC_uesta3set: LongInt absolute AVR32_USBC_ADDRESS+$019c;
USBC_uesta4set: LongInt absolute AVR32_USBC_ADDRESS+$01a0;
USBC_uesta5set: LongInt absolute AVR32_USBC_ADDRESS+$01a4;
USBC_uesta6set: LongInt absolute AVR32_USBC_ADDRESS+$01a8;
USBC_uesta7set: LongInt absolute AVR32_USBC_ADDRESS+$01ac;
USBC_uecon0:    LongInt absolute AVR32_USBC_ADDRESS+$01c0;
USBC_uecon1:    LongInt absolute AVR32_USBC_ADDRESS+$01c4;
USBC_uecon2:    LongInt absolute AVR32_USBC_ADDRESS+$01c8;
USBC_uecon3:    LongInt absolute AVR32_USBC_ADDRESS+$01cc;
USBC_uecon4:    LongInt absolute AVR32_USBC_ADDRESS+$01d0;
USBC_uecon5:    LongInt absolute AVR32_USBC_ADDRESS+$01d4;
USBC_uecon6:    LongInt absolute AVR32_USBC_ADDRESS+$01d8;
USBC_uecon7:    LongInt absolute AVR32_USBC_ADDRESS+$01dc;
USBC_uecon0se:  LongInt absolute AVR32_USBC_ADDRESS+$01f0;
USBC_uecon1se:  LongInt absolute AVR32_USBC_ADDRESS+$01f4;
USBC_uecon2se:  LongInt absolute AVR32_USBC_ADDRESS+$01f8;
USBC_uecon3se:  LongInt absolute AVR32_USBC_ADDRESS+$01fc;
USBC_uecon4se:  LongInt absolute AVR32_USBC_ADDRESS+$0200;
USBC_uecon5se:  LongInt absolute AVR32_USBC_ADDRESS+$0204;
USBC_uecon6se:  LongInt absolute AVR32_USBC_ADDRESS+$0208;
USBC_uecon7se:  LongInt absolute AVR32_USBC_ADDRESS+$020c;
USBC_uecon0cl:  LongInt absolute AVR32_USBC_ADDRESS+$0220;
USBC_uecon1cl:  LongInt absolute AVR32_USBC_ADDRESS+$0224;
USBC_uecon2cl:  LongInt absolute AVR32_USBC_ADDRESS+$0228;
USBC_uecon3cl:  LongInt absolute AVR32_USBC_ADDRESS+$022c;
USBC_uecon4cl:  LongInt absolute AVR32_USBC_ADDRESS+$0230;
USBC_uecon5cl:  LongInt absolute AVR32_USBC_ADDRESS+$0234;
USBC_uecon6cl:  LongInt absolute AVR32_USBC_ADDRESS+$0238;
USBC_uecon7clr: LongInt absolute AVR32_USBC_ADDRESS+$023c;
USBC_uhcon:     LongInt absolute AVR32_USBC_ADDRESS+$0400;
USBC_uhint:     LongInt absolute AVR32_USBC_ADDRESS+$0404;
USBC_uhintclr:  LongInt absolute AVR32_USBC_ADDRESS+$0408;
USBC_uhintset:  LongInt absolute AVR32_USBC_ADDRESS+$040c;
USBC_uhinte:    LongInt absolute AVR32_USBC_ADDRESS+$0410;
USBC_uhinteclr: LongInt absolute AVR32_USBC_ADDRESS+$0414;
USBC_uhinteset: LongInt absolute AVR32_USBC_ADDRESS+$0418;
USBC_uprst:     LongInt absolute AVR32_USBC_ADDRESS+$041c;
USBC_uhfnum:    LongInt absolute AVR32_USBC_ADDRESS+$0420;
USBC_upcfg0:    LongInt absolute AVR32_USBC_ADDRESS+$0500;
USBC_upcfg1:    LongInt absolute AVR32_USBC_ADDRESS+$0504;
USBC_upcfg2:    LongInt absolute AVR32_USBC_ADDRESS+$0508;
USBC_upcfg3:    LongInt absolute AVR32_USBC_ADDRESS+$050c;
USBC_upcfg4:    LongInt absolute AVR32_USBC_ADDRESS+$0510;
USBC_upcfg5:    LongInt absolute AVR32_USBC_ADDRESS+$0514;
USBC_upcfg6:    LongInt absolute AVR32_USBC_ADDRESS+$0518;
USBC_upcfg7:    LongInt absolute AVR32_USBC_ADDRESS+$051c;
USBC_upsta0:    LongInt absolute AVR32_USBC_ADDRESS+$0530;
USBC_upsta1:    LongInt absolute AVR32_USBC_ADDRESS+$0534;
USBC_upsta2:    LongInt absolute AVR32_USBC_ADDRESS+$0538;
USBC_upsta3:    LongInt absolute AVR32_USBC_ADDRESS+$053c;
USBC_upsta4:    LongInt absolute AVR32_USBC_ADDRESS+$0540;
USBC_upsta5:    LongInt absolute AVR32_USBC_ADDRESS+$0544;
USBC_upsta6:    LongInt absolute AVR32_USBC_ADDRESS+$0548;
USBC_upsta7:    LongInt absolute AVR32_USBC_ADDRESS+$054c;
USBC_upsta0clr: LongInt absolute AVR32_USBC_ADDRESS+$0560;
USBC_upsta1clr: LongInt absolute AVR32_USBC_ADDRESS+$0564;
USBC_upsta2clr: LongInt absolute AVR32_USBC_ADDRESS+$0568;
USBC_upsta3clr: LongInt absolute AVR32_USBC_ADDRESS+$056c;
USBC_upsta4clr: LongInt absolute AVR32_USBC_ADDRESS+$0570;
USBC_upsta5clr: LongInt absolute AVR32_USBC_ADDRESS+$0574;
USBC_upsta6clr: LongInt absolute AVR32_USBC_ADDRESS+$0578;
USBC_upsta7clr: LongInt absolute AVR32_USBC_ADDRESS+$057c;
USBC_upsta0set: LongInt absolute AVR32_USBC_ADDRESS+$0590;
USBC_upsta1set: LongInt absolute AVR32_USBC_ADDRESS+$0594;
USBC_upsta2set: LongInt absolute AVR32_USBC_ADDRESS+$0598;
USBC_upsta3set: LongInt absolute AVR32_USBC_ADDRESS+$059c;
USBC_upsta4set: LongInt absolute AVR32_USBC_ADDRESS+$05a0;
USBC_upsta5set: LongInt absolute AVR32_USBC_ADDRESS+$05a4;
USBC_upsta6set: LongInt absolute AVR32_USBC_ADDRESS+$05a8;
USBC_upsta7set: LongInt absolute AVR32_USBC_ADDRESS+$05ac;
USBC_upcon0:    LongInt absolute AVR32_USBC_ADDRESS+$05c0;
USBC_upcon1:    LongInt absolute AVR32_USBC_ADDRESS+$05c4;
USBC_upcon2:    LongInt absolute AVR32_USBC_ADDRESS+$05c8;
USBC_upcon3:    LongInt absolute AVR32_USBC_ADDRESS+$05cc;
USBC_upcon4:    LongInt absolute AVR32_USBC_ADDRESS+$05d0;
USBC_upcon5:    LongInt absolute AVR32_USBC_ADDRESS+$05d4;
USBC_upcon6:    LongInt absolute AVR32_USBC_ADDRESS+$05d8;
USBC_upcon7:    LongInt absolute AVR32_USBC_ADDRESS+$05dc;
USBC_upcon0set: LongInt absolute AVR32_USBC_ADDRESS+$05f0;
USBC_upcon1set: LongInt absolute AVR32_USBC_ADDRESS+$05f4;
USBC_upcon2set: LongInt absolute AVR32_USBC_ADDRESS+$05f8;
USBC_upcon3set: LongInt absolute AVR32_USBC_ADDRESS+$05fc;
USBC_upcon4set: LongInt absolute AVR32_USBC_ADDRESS+$0600;
USBC_upcon5set: LongInt absolute AVR32_USBC_ADDRESS+$0604;
USBC_upcon6set: LongInt absolute AVR32_USBC_ADDRESS+$0608;
USBC_upcon7set: LongInt absolute AVR32_USBC_ADDRESS+$060c;
USBC_upcon0clr: LongInt absolute AVR32_USBC_ADDRESS+$0620;
USBC_upcon1clr: LongInt absolute AVR32_USBC_ADDRESS+$0624;
USBC_upcon2clr: LongInt absolute AVR32_USBC_ADDRESS+$0628;
USBC_upcon3clr: LongInt absolute AVR32_USBC_ADDRESS+$062c;
USBC_upcon4clr: LongInt absolute AVR32_USBC_ADDRESS+$0630;
USBC_upcon5clr: LongInt absolute AVR32_USBC_ADDRESS+$0634;
USBC_upcon6clr: LongInt absolute AVR32_USBC_ADDRESS+$0638;
USBC_upcon7clr: LongInt absolute AVR32_USBC_ADDRESS+$063c;
USBC_upinrq0:   LongInt absolute AVR32_USBC_ADDRESS+$0650;
USBC_upinrq1:   LongInt absolute AVR32_USBC_ADDRESS+$0654;
USBC_upinrq2:   LongInt absolute AVR32_USBC_ADDRESS+$0658;
USBC_upinrq3:   LongInt absolute AVR32_USBC_ADDRESS+$065c;
USBC_upinrq4:   LongInt absolute AVR32_USBC_ADDRESS+$0660;
USBC_upinrq5:   LongInt absolute AVR32_USBC_ADDRESS+$0664;
USBC_upinrq6:   LongInt absolute AVR32_USBC_ADDRESS+$0668;
USBC_upinrq7:   LongInt absolute AVR32_USBC_ADDRESS+$066c;
USBC_updat0:    LongInt absolute AVR32_USBC_ADDRESS+$06b0;
USBC_updat1:    LongInt absolute AVR32_USBC_ADDRESS+$06b4;
USBC_updat2:    LongInt absolute AVR32_USBC_ADDRESS+$06b8;
USBC_updat3:    LongInt absolute AVR32_USBC_ADDRESS+$06bc;
USBC_updat4:    LongInt absolute AVR32_USBC_ADDRESS+$06c0;
USBC_updat5:    LongInt absolute AVR32_USBC_ADDRESS+$06c4;
USBC_updat6:    LongInt absolute AVR32_USBC_ADDRESS+$06c8;
USBC_updat7:    LongInt absolute AVR32_USBC_ADDRESS+$06cc;
USBC_usbcon:    LongInt absolute AVR32_USBC_ADDRESS+$0800;
USBC_usbsta:    LongInt absolute AVR32_USBC_ADDRESS+$0804;
USBC_usbstaclr: LongInt absolute AVR32_USBC_ADDRESS+$0808;
USBC_usbstaset: LongInt absolute AVR32_USBC_ADDRESS+$080c;
USBC_uatst1:    LongInt absolute AVR32_USBC_ADDRESS+$0810;
USBC_uatst2:    LongInt absolute AVR32_USBC_ADDRESS+$0814;
USBC_uvers:     LongInt absolute AVR32_USBC_ADDRESS+$0818;
USBC_ufeatures: LongInt absolute AVR32_USBC_ADDRESS+$081c;
USBC_uaddrsize: LongInt absolute AVR32_USBC_ADDRESS+$0820;
USBC_uname1:    LongInt absolute AVR32_USBC_ADDRESS+$0824;
USBC_uname2:    LongInt absolute AVR32_USBC_ADDRESS+$0828;
USBC_usbfsm:    LongInt absolute AVR32_USBC_ADDRESS+$082c;
USBC_udesc:     LongInt absolute AVR32_USBC_ADDRESS+$0830;
(* WDT *)
WDT_ctrl:      LongInt absolute AVR32_WDT_ADDRESS;
WDT_clr:       LongInt absolute AVR32_WDT_ADDRESS+$0004;
WDT_sr:        LongInt absolute AVR32_WDT_ADDRESS+$0008;
WDT_version:   LongInt absolute AVR32_WDT_ADDRESS+$03fc;
(* GPIO_LOCAL *)
type
Tavr32_gpio_local_port_t = packed record
    res0: array[0..15] of LongInt;
    oder,oders,oderc,odert,ovr,ovrs,ovrc,ovrt,pvr: LongInt;
    res1: array[0..102] of LongInt;
end;

var
  GPIO_local_port: array[0..(AVR32_GPIO_PORT_LENGTH-1)]  of Tavr32_gpio_local_port_t absolute AVR32_GPIO_LOCAL_ADDRESS;

implementation

procedure PASCALMAIN; external name 'PASCALMAIN';

var
 _data: record end; external name '_data';
 _edata: record end; external name '_edata';
 _etext: record end; external name '_etext';
 _bss_start: record end; external name '_bss_start';
 _bss_end: record end; external name '_bss_end';
 _stack_top: record end; external name '_stack_top';

procedure _FPC_haltproc; assembler; nostackframe; public name '_haltproc';
asm
.Lhalt:
    rjmp .Lhalt
end;

procedure DefaultHandler; assembler; nostackframe; public name 'DefaultHandler';
asm
end;

procedure StartCode; nostackframe; assembler; [public, alias: '_START'];// interrupt 0;
asm
   .init
   lda.w pc, .Lstart

   .text
.Lstart:
   // Update stack
   ld.w sp, .L_stack_top

   // Set EVBA
   ld.w r0, .L_evba_base
   mtsr 4, r0 // EVBA

   // copy initialized data from flash to ram
   ld.w r1,.L_etext
   ld.w r2,.L_data
   ld.w r3,.L_edata
.Lcopyloop:
   cp.w r2,r3
   brhi .Lecopyloop
   ld.w r0, r1++
   st.w r2++, r0
   bral .Lcopyloop
.Lecopyloop:

   // clear onboard ram
   ld.w r1,.L_bss_start
   ld.w r2,.L_bss_end
   mov r0, 0
.Lzeroloop:
   cp.w r1,r2
   brhi .Lezeroloop
   st.w r1++, r0
   bral .Lzeroloop
.Lezeroloop:

   bral PASCALMAIN

.L_bss_start:
   .long _bss_start
.L_bss_end:
   .long _bss_end
.L_etext:
   .long _etext
.L_data:
   .long _data
.L_edata:
   .long _edata
.L_evba_base:
   .long 0x0
.L_stack_top:
   .long _stack_top
end;

end.


