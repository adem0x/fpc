unit at32uc3l132;

(*****************************************************************************
 *
 * Copyright (C) 2012 Michel Catudal
 *
 ****************************************************************************)
interface

const
{ Memories }
AVR32_SRAM_ADDRESS =        $00000000;
AVR32_FLASH_ADDRESS =       $80000000;
AVR32_FLASHCDW_USER_PAGE_ADDRESS =  $80800000;
AVR32_SAU_SLAVE =           $90000000;
AVR32_SAU_HSB_ADDRESS =     $90000000;

{ Interrupt Controller }
AVR32_INTC_ADDRESS =        $FFFF1000;
AVR32_INTC_NUM_INT_GRPS =   31;
{ ACIFB }
AVR32_ACIFB_ADDRESS =       $FFFF6400;
{ ADCIFB }
AVR32_ADCIFB_ADDRESS =      $FFFF6000;
{ AST }
AVR32_AST_ADDRESS =         $FFFF1C00;
{ AW }
AVR32_AW_ADDRESS =          $FFFF6C00;
{ CAT }
AVR32_CAT_ADDRESS =         $FFFF6800;
{ EIC }
AVR32_EIC_ADDRESS =         $FFFF2400;
{ FLASHCDW }
AVR32_FLASHCDW_ADDRESS =    $FFFE0000;
{ FREQM }
AVR32_FREQM_ADDRESS =       $FFFF2800;
{ GPIO }
AVR32_GPIO_ADDRESS =        $FFFF2C00;
AVR32_GPIO_PORT_LENGTH =    1;
{ HMATRIX }
AVR32_HMATRIX_ADDRESS =     $FFFE0400;
{ PDCA }
AVR32_PDCA_ADDRESS =        $FFFF0000;
AVR32_PDCA_CHANNEL_LENGTH = 12;
{ PM }
AVR32_PM_ADDRESS =          $FFFF1400;
{ PWMA }
AVR32_PWMA_ADDRESS =        $FFFF5400;
{ SAU }
AVR32_SAU_ADDRESS =         $FFFE0800;
AVR32_SAU_CHANNELS =        16;
{ SCIF }
AVR32_SCIF_ADDRESS =        $FFFF1800;
{ SPI }
AVR32_SPI_ADDRESS =         $FFFF4000;
{ TC0 }
AVR32_TC0_ADDRESS =         $FFFF5800;
{ TWIM0 }
AVR32_TWIM0_ADDRESS =       $FFFF4400;
{ TWIM1 }
AVR32_TWIM1_ADDRESS =       $FFFF4800;
{ TWIS0 }
AVR32_TWIS0_ADDRESS =       $FFFF4C00;
{ TWIS1 }
AVR32_TWIS1_ADDRESS =       $FFFF5000;
{ USART0 }
AVR32_USART0_ADDRESS =      $FFFF3000;
{ USART1 }
AVR32_USART1_ADDRESS =      $FFFF3400;
{ USART2 }
AVR32_USART2_ADDRESS =      $FFFF3800;
{ WDT }
AVR32_WDT_ADDRESS =         $FFFF2000;
{ GPIO_LOCAL }
AVR32_GPIO_LOCAL_ADDRESS =  $40000000;
var
{ Interrupt Controller }
INTC_ipr: array[0..(AVR32_INTC_NUM_INT_GRPS-1)] of LongInt absolute AVR32_INTC_ADDRESS;
INTC_irr: array[0..(AVR32_INTC_NUM_INT_GRPS-1)] of LongInt absolute AVR32_INTC_ADDRESS+$0100;
INTC_icr: array[0..3] of LongInt absolute AVR32_INTC_ADDRESS+$0200;
{ ACIFB }
ACIFB_ctrl:       LongInt absolute AVR32_ACIFB_ADDRESS;
ACIFB_sr:         LongInt absolute AVR32_ACIFB_ADDRESS+$0004;
ACIFB_ier:        LongInt absolute AVR32_ACIFB_ADDRESS+$0010;
ACIFB_idr:        LongInt absolute AVR32_ACIFB_ADDRESS+$0014;
ACIFB_imr:        LongInt absolute AVR32_ACIFB_ADDRESS+$0018;
ACIFB_isr:        LongInt absolute AVR32_ACIFB_ADDRESS+$001c;
ACIFB_icr:        LongInt absolute AVR32_ACIFB_ADDRESS+$0020;
ACIFB_tr:         LongInt absolute AVR32_ACIFB_ADDRESS+$0024;
ACIFB_parameter:  LongInt absolute AVR32_ACIFB_ADDRESS+$0030;
ACIFB_version:    LongInt absolute AVR32_ACIFB_ADDRESS+$0034;
ACIFB_confw0:     LongInt absolute AVR32_ACIFB_ADDRESS+$0080;
ACIFB_confw1:     LongInt absolute AVR32_ACIFB_ADDRESS+$0084;
ACIFB_confw2:     LongInt absolute AVR32_ACIFB_ADDRESS+$0088;
ACIFB_confw3:     LongInt absolute AVR32_ACIFB_ADDRESS+$008c;
ACIFB_conf0:      LongInt absolute AVR32_ACIFB_ADDRESS+$00d0;
ACIFB_conf1:      LongInt absolute AVR32_ACIFB_ADDRESS+$00d4;
ACIFB_conf2:      LongInt absolute AVR32_ACIFB_ADDRESS+$00d8;
ACIFB_conf3:      LongInt absolute AVR32_ACIFB_ADDRESS+$00dc;
ACIFB_conf4:      LongInt absolute AVR32_ACIFB_ADDRESS+$00e0;
ACIFB_conf5:      LongInt absolute AVR32_ACIFB_ADDRESS+$00e4;
ACIFB_conf6:      LongInt absolute AVR32_ACIFB_ADDRESS+$00e8;
ACIFB_conf7:      LongInt absolute AVR32_ACIFB_ADDRESS+$00ec;
{ ADCIFB }
ADCIFB_cr:        LongInt absolute AVR32_ADCIFB_ADDRESS;
ADCIFB_mr:        LongInt absolute AVR32_ADCIFB_ADDRESS+$0004;
ADCIFB_acr:       LongInt absolute AVR32_ADCIFB_ADDRESS+$0008;
ADCIFB_trgr:      LongInt absolute AVR32_ADCIFB_ADDRESS+$000c;
ADCIFB_cvr:       LongInt absolute AVR32_ADCIFB_ADDRESS+$0010;
ADCIFB_sr:        LongInt absolute AVR32_ADCIFB_ADDRESS+$0014;
ADCIFB_isr:       LongInt absolute AVR32_ADCIFB_ADDRESS+$0018;
ADCIFB_icr:       LongInt absolute AVR32_ADCIFB_ADDRESS+$001c;
ADCIFB_ier:       LongInt absolute AVR32_ADCIFB_ADDRESS+$0020;
ADCIFB_idr:       LongInt absolute AVR32_ADCIFB_ADDRESS+$0024;
ADCIFB_imr:       LongInt absolute AVR32_ADCIFB_ADDRESS+$0028;
ADCIFB_lcdr:      LongInt absolute AVR32_ADCIFB_ADDRESS+$002c;
ADCIFB_parameter: LongInt absolute AVR32_ADCIFB_ADDRESS+$0030;
ADCIFB_version:   LongInt absolute AVR32_ADCIFB_ADDRESS+$0034;
ADCIFB_cher:      LongInt absolute AVR32_ADCIFB_ADDRESS+$0040;
ADCIFB_chdr:      LongInt absolute AVR32_ADCIFB_ADDRESS+$0044;
ADCIFB_chsr:      LongInt absolute AVR32_ADCIFB_ADDRESS+$0048;
{ AST }
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
{ AW }
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
{ CAT }
CAT_ctrl:          LongInt absolute AVR32_CAT_ADDRESS;
CAT_atpins:        LongInt absolute AVR32_CAT_ADDRESS+$0004;
CAT_pinmode0:      LongInt absolute AVR32_CAT_ADDRESS+$0008;
CAT_pinmode1:      LongInt absolute AVR32_CAT_ADDRESS+$000c;
CAT_atcfg0:        LongInt absolute AVR32_CAT_ADDRESS+$0010;
CAT_atcfg1:        LongInt absolute AVR32_CAT_ADDRESS+$0014;
CAT_atcfg2:        LongInt absolute AVR32_CAT_ADDRESS+$0018;
CAT_atcfg3:        LongInt absolute AVR32_CAT_ADDRESS+$001c;
CAT_tgacfg0:       LongInt absolute AVR32_CAT_ADDRESS+$0020;
CAT_tgacfg1:       LongInt absolute AVR32_CAT_ADDRESS+$0024;
CAT_tgbcfg0:       LongInt absolute AVR32_CAT_ADDRESS+$0028;
CAT_tgbcfg1:       LongInt absolute AVR32_CAT_ADDRESS+$002c;
CAT_mgcfg0:        LongInt absolute AVR32_CAT_ADDRESS+$0030;
CAT_mgcfg1:        LongInt absolute AVR32_CAT_ADDRESS+$0034;
CAT_mgcfg2:        LongInt absolute AVR32_CAT_ADDRESS+$0038;
CAT_sr:            LongInt absolute AVR32_CAT_ADDRESS+$003c;
CAT_scr:           LongInt absolute AVR32_CAT_ADDRESS+$0040;
CAT_ier:           LongInt absolute AVR32_CAT_ADDRESS+$0044;
CAT_idr:           LongInt absolute AVR32_CAT_ADDRESS+$0048;
CAT_imr:           LongInt absolute AVR32_CAT_ADDRESS+$004c;
CAT_aisr:          LongInt absolute AVR32_CAT_ADDRESS+$0050;
CAT_acount:        LongInt absolute AVR32_CAT_ADDRESS+$0054;
CAT_mblen:         LongInt absolute AVR32_CAT_ADDRESS+$0058;
CAT_dics:          LongInt absolute AVR32_CAT_ADDRESS+$005c;
CAT_sscfg:         LongInt absolute AVR32_CAT_ADDRESS+$0060;
CAT_csares:        LongInt absolute AVR32_CAT_ADDRESS+$0064;
CAT_csbres:        LongInt absolute AVR32_CAT_ADDRESS+$0068;
CAT_parameter:     LongInt absolute AVR32_CAT_ADDRESS+$00f8;
CAT_version:       LongInt absolute AVR32_CAT_ADDRESS+$00fc;
{ EIC }
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
{ FLASHCDW }
FLASHCW_fcr:      LongInt absolute AVR32_FLASHCDW_ADDRESS;
FLASHCW_fcmd:     LongInt absolute AVR32_FLASHCDW_ADDRESS+$0004;
FLASHCW_fsr:      LongInt absolute AVR32_FLASHCDW_ADDRESS+$0008;
FLASHCW_pr:       LongInt absolute AVR32_FLASHCDW_ADDRESS+$000c;
FLASHCW_vr:       LongInt absolute AVR32_FLASHCDW_ADDRESS+$0010;
FLASHCW_fgpfrhi:  LongInt absolute AVR32_FLASHCDW_ADDRESS+$0014;
FLASHCW_fgpfrlo:  LongInt absolute AVR32_FLASHCDW_ADDRESS+$0018;
{ FREQM }
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
{ GPIO }
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
  GPIO_port: Tavr32_gpio_port_t absolute AVR32_GPIO_ADDRESS;
{ HMATRIX }
type
 Tavr32_hmatrix_prs_t = packed record
    pras,prbs: LongInt;
 end;

var
HMATRIX_mcfg: array[0..15] of LongInt absolute    AVR32_HMATRIX_ADDRESS;
HMATRIX_scfg: array[0..15] of LongInt absolute    AVR32_HMATRIX_ADDRESS+$0040;
HMATRIX_prs: array[0..15] of Tavr32_hmatrix_prs_t absolute AVR32_HMATRIX_ADDRESS+$0080;
HMATRIX_mrcr: LongInt absolute                    AVR32_HMATRIX_ADDRESS+$0100;
HMATRIX_sfr: array[0..15] of LongInt absolute     AVR32_HMATRIX_ADDRESS+$0110;
HMATRIX_version: LongInt absolute                 AVR32_HMATRIX_ADDRESS+$01fc;
{ PDCA }
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
{ PM }
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
{ PWM }
type
Tavr32_pwm_channel_t = packed record
    cmr,cdty,cdtyupd,cprd,cprdupd,ccnt,dt,dtupd: LongInt;
end;

type
Tavr32_pwm_comp_t = packed record
    cmp0v,cmp0vupd,cmp0m,cmp0mupd: LongInt;
end;

var
PWA_cr:        LongInt absolute AVR32_PWMA_ADDRESS;
PWA_isduty:    LongInt absolute AVR32_PWMA_ADDRESS+$0004;
PWA_imduty:    LongInt absolute AVR32_PWMA_ADDRESS+$0008;
PWA_imchsel:   LongInt absolute AVR32_PWMA_ADDRESS+$000c;
PWA_ier:       LongInt absolute AVR32_PWMA_ADDRESS+$0010;
PWA_idr:       LongInt absolute AVR32_PWMA_ADDRESS+$0014;
PWA_imr:       LongInt absolute AVR32_PWMA_ADDRESS+$0018;
PWA_sr:        LongInt absolute AVR32_PWMA_ADDRESS+$001c;
PWA_scr:       LongInt absolute AVR32_PWMA_ADDRESS+$0020;
PWA_parameter: LongInt absolute AVR32_PWMA_ADDRESS+$0024;
PWA_version:   LongInt absolute AVR32_PWMA_ADDRESS+$0028;
PWA_ischset0:  LongInt absolute AVR32_PWMA_ADDRESS+$0030;
PWA_cheer0:    LongInt absolute AVR32_PWMA_ADDRESS+$0038;
PWA_ischset1:  LongInt absolute AVR32_PWMA_ADDRESS+$0040;
PWA_cheer1:    LongInt absolute AVR32_PWMA_ADDRESS+$0048;
{ SAU }
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
{ SCIF }
SCIF_ier:                   LongInt absolute AVR32_SCIF_ADDRESS;
SCIF_idr:                   LongInt absolute AVR32_SCIF_ADDRESS+$0004;
SCIF_imr:                   LongInt absolute AVR32_SCIF_ADDRESS+$0008;
SCIF_isr:                   LongInt absolute AVR32_SCIF_ADDRESS+$000c;
SCIF_icr:                   LongInt absolute AVR32_SCIF_ADDRESS+$0010;
SCIF_pclksr:                LongInt absolute AVR32_SCIF_ADDRESS+$0014;
SCIF_unlock:                LongInt absolute AVR32_SCIF_ADDRESS+$0018;
SCIF_oscctrl0:              LongInt absolute AVR32_SCIF_ADDRESS+$001c;
SCIF_oscctrl32:             LongInt absolute AVR32_SCIF_ADDRESS+$0020;
SCIF_dfll0conf:             LongInt absolute AVR32_SCIF_ADDRESS+$0024;
SCIF_dfll0fmul:             LongInt absolute AVR32_SCIF_ADDRESS+$0028;
SCIF_dfll0ssg:              LongInt absolute AVR32_SCIF_ADDRESS+$0030;
SCIF_dfll0ratio:            LongInt absolute AVR32_SCIF_ADDRESS+$0034;
SCIF_dfll0sync:             LongInt absolute AVR32_SCIF_ADDRESS+$0038;
SCIF_bod:                   LongInt absolute AVR32_SCIF_ADDRESS+$003c;
SCIF_bgcr:                  LongInt absolute AVR32_SCIF_ADDRESS+$0040;
SCIF_vregcr:                LongInt absolute AVR32_SCIF_ADDRESS+$0044;
SCIF_rccr:                  LongInt absolute AVR32_SCIF_ADDRESS+$0048;
SCIF_sm33:                  LongInt absolute AVR32_SCIF_ADDRESS+$004c;
SCIF_tsens:                 LongInt absolute AVR32_SCIF_ADDRESS+$0050;
SCIF_stilo:                 LongInt absolute AVR32_SCIF_ADDRESS+$0054;
SCIF_rc120mcr:              LongInt absolute AVR32_SCIF_ADDRESS+$0058;
SCIF_br:     array[0..3] of LongInt absolute AVR32_SCIF_ADDRESS+$005c;
SCIF_rc32kcr:               LongInt absolute AVR32_SCIF_ADDRESS+$006c;
SCIF_gcctrl: array[0..4] of LongInt absolute AVR32_SCIF_ADDRESS+$0070;
SCIF_osc0version:           LongInt absolute AVR32_SCIF_ADDRESS+$03c8;
SCIF_osc32version:          LongInt absolute AVR32_SCIF_ADDRESS+$03cc;
SCIF_dfllifversion:         LongInt absolute AVR32_SCIF_ADDRESS+$03d0;
SCIF_bodifaversion:         LongInt absolute AVR32_SCIF_ADDRESS+$03d4;
SCIF_vregifbversion:        LongInt absolute AVR32_SCIF_ADDRESS+$03d8;
SCIF_rcoscifaversion:       LongInt absolute AVR32_SCIF_ADDRESS+$03dc;
SCIF_sm33ifaversion:        LongInt absolute AVR32_SCIF_ADDRESS+$03e0;
SCIF_tsensifaversion:       LongInt absolute AVR32_SCIF_ADDRESS+$03e4;
SCIF_stiloversion:          LongInt absolute AVR32_SCIF_ADDRESS+$03e8;
SCIF_rc120mifaversion:      LongInt absolute AVR32_SCIF_ADDRESS+$03ec;
SCIF_brifaversion:          LongInt absolute AVR32_SCIF_ADDRESS+$03f0;
SCIF_rc32kifaversion:       LongInt absolute AVR32_SCIF_ADDRESS+$03f4;
SCIF_gclkversion:           LongInt absolute AVR32_SCIF_ADDRESS+$03f8;
SCIF_version:               LongInt absolute AVR32_SCIF_ADDRESS+$03fc;
{ SPI }
SPI_cr:        LongInt absolute AVR32_SPI_ADDRESS;
SPI_mr:        LongInt absolute AVR32_SPI_ADDRESS+$0004;
SPI_rdr:       LongInt absolute AVR32_SPI_ADDRESS+$0008;
SPI_tdr:       LongInt absolute AVR32_SPI_ADDRESS+$000c;
SPI_sr:        LongInt absolute AVR32_SPI_ADDRESS+$0010;
SPI_ier:       LongInt absolute AVR32_SPI_ADDRESS+$0014;
SPI_idr:       LongInt absolute AVR32_SPI_ADDRESS+$0018;
SPI_imr:       LongInt absolute AVR32_SPI_ADDRESS+$001c;
SPI_csr0:      LongInt absolute AVR32_SPI_ADDRESS+$0030;
SPI_csr1:      LongInt absolute AVR32_SPI_ADDRESS+$0034;
SPI_csr2:      LongInt absolute AVR32_SPI_ADDRESS+$0038;
SPI_csr3:      LongInt absolute AVR32_SPI_ADDRESS+$003c;
SPI_wpcr:      LongInt absolute AVR32_SPI_ADDRESS+$00e4;
SPI_wpsr:      LongInt absolute AVR32_SPI_ADDRESS+$00e8;
SPI_version:   LongInt absolute AVR32_SPI_ADDRESS+$00fc;
{ TC }
type
Tavr32_tc_channel_t = packed record
  ccr,cmr: LongInt;
  res0: array[0..1] of LongInt;
  cv,ra,rb,rc,sr,ier,idr,imr : LongInt;
  res1: array[0..3] of LongInt;
end;
{ TC0 }
var
TC0_channel: array[0..2] of Tavr32_tc_channel_t absolute AVR32_TC0_ADDRESS;
TC0_bcr:     LongInt absolute AVR32_TC0_ADDRESS+$00c0;
TC0_bmr:     LongInt absolute AVR32_TC0_ADDRESS+$00c4;
TC0_version: LongInt absolute AVR32_TC0_ADDRESS+$00fc;
{ TWIM0 }
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
{ TWIM1 }
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
{ TWIS0 }
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
{ TWIS1 }
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
{ USART0 }
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
{ USART1 }
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
{ USART2 }
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
{ WDT }
WDT_ctrl:      LongInt absolute AVR32_WDT_ADDRESS;
WDT_clr:       LongInt absolute AVR32_WDT_ADDRESS+$0004;
WDT_sr:        LongInt absolute AVR32_WDT_ADDRESS+$0008;
WDT_version:   LongInt absolute AVR32_WDT_ADDRESS+$03fc;
{ GPIO_LOCAL }
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



