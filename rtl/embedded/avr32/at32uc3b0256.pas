unit at32uc3b0256;

(*****************************************************************************
 *
 * Copyright (C) 2012 Michel Catudal
 *
 ****************************************************************************)
interface

const
{ Memories }
AVR32_CPU_RAM_ADDRESS =          $00000000;
AVR32_FLASH_ADDRESS =            $80000000;
AVR32_FLASHC_USER_PAGE_ADDRESS_ADDRESS = $80800000;
AVR32_USBB_SLAVE_ADDRESS =       $D0000000;

{ Interrupt Controller }
AVR32_INTC_ADDRESS =             $FFFF0800;
AVR32_INTC_NUM_INT_GRPS =        18;
{ ADC }
AVR32_ADC_ADDRESS =              $FFFF3C00;
{ EIC }
AVR32_EIC_ADDRESS =              $FFFF0D80;
{ FLASHC }
AVR32_FLASHC_ADDRESS =           $FFFE1400;
{ FREQM }
AVR32_FREQM_ADDRESS =            $FFFF0D50;
{ GPIO }
AVR32_GPIO_ADDRESS =             $FFFF1000;
AVR32_GPIO_LOCAL_ADDRESS =       $40000000;
AVR32_GPIO_PORT_LENGTH =         2;
{ HMATRIX }
AVR32_HMATRIX_ADDRESS =          $FFFE1000;
{ PDCA }
AVR32_PDCA_ADDRESS =             $FFFF0000;
AVR32_PDCA_CHANNEL_LENGTH =      7;
{ PM }
AVR32_PM_ADDRESS =               $FFFF0C00;
{ PWM }
AVR32_PWM_ADDRESS =              $FFFF3000;
AVR32_PWM_CHANNEL_LENGTH =       7;
{ RTC }
AVR32_RTC_ADDRESS =              $FFFF0D00;
{ SPI }
AVR32_SPI_ADDRESS =              $FFFF2400;
{ SSC }
AVR32_SSC_ADDRESS =              $FFFF3400;
{ TC }
AVR32_TC_ADDRESS =               $FFFF3800;
{ TWI }
AVR32_TWI_ADDRESS =              $FFFF2C00;
{ USART0 }
AVR32_USART0_ADDRESS =           $FFFF1400;
{ USART1 }
AVR32_USART1_ADDRESS =           $FFFF1800;
{ USART2 }
AVR32_USART2_ADDRESS =           $FFFF1C00;
{ USBB }
AVR32_USBB_ADDRESS =             $FFFE0000;
{ WDT }
AVR32_WDT_ADDRESS =              $FFFF0D30;

{ Interrupt Controller }
var
INTC_ipr: array[0..(AVR32_INTC_NUM_INT_GRPS-1)] of LongInt absolute AVR32_INTC_ADDRESS;
INTC_irr: array[0..(AVR32_INTC_NUM_INT_GRPS-1)] of LongInt absolute AVR32_INTC_ADDRESS+$0100;
INTC_icr: array[0..3] of LongInt absolute AVR32_INTC_ADDRESS+$0200;
{ ADC }
ADC_cr:        LongInt absolute AVR32_ADC_ADDRESS;
ADC_mr:        LongInt absolute AVR32_ADC_ADDRESS+$0004;
ADC_cher:      LongInt absolute AVR32_ADC_ADDRESS+$0010;
ADC_chdr:      LongInt absolute AVR32_ADC_ADDRESS+$0014;
ADC_chsr:      LongInt absolute AVR32_ADC_ADDRESS+$0018;
ADC_sr:        LongInt absolute AVR32_ADC_ADDRESS+$001c;
ADC_lcdr:      LongInt absolute AVR32_ADC_ADDRESS+$0020;
ADC_ier:       LongInt absolute AVR32_ADC_ADDRESS+$0024;
ADC_idr:       LongInt absolute AVR32_ADC_ADDRESS+$0028;
ADC_imr:       LongInt absolute AVR32_ADC_ADDRESS+$002c;
ADC_cdr0:      LongInt absolute AVR32_ADC_ADDRESS+$0030;
ADC_cdr1:      LongInt absolute AVR32_ADC_ADDRESS+$0034;
ADC_cdr2:      LongInt absolute AVR32_ADC_ADDRESS+$0038;
ADC_cdr3:      LongInt absolute AVR32_ADC_ADDRESS+$003c;
ADC_cdr4:      LongInt absolute AVR32_ADC_ADDRESS+$0040;
ADC_cdr5:      LongInt absolute AVR32_ADC_ADDRESS+$0044;
ADC_cdr6:      LongInt absolute AVR32_ADC_ADDRESS+$0048;
ADC_cdr7:      LongInt absolute AVR32_ADC_ADDRESS+$004c;
ADC_version:   LongInt absolute AVR32_ADC_ADDRESS+$00fc;
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
EIC_scan:      LongInt absolute AVR32_EIC_ADDRESS+$002c;
EIC_en:        LongInt absolute AVR32_EIC_ADDRESS+$0030;
EIC_dis:       LongInt absolute AVR32_EIC_ADDRESS+$0034;
EIC_ctrl:      LongInt absolute AVR32_EIC_ADDRESS+$0038;
{ FLASHC }
FLASHC_fcr:     LongInt absolute AVR32_FLASHC_ADDRESS;
FLASHC_fcmd:    LongInt absolute AVR32_FLASHC_ADDRESS+$0004;
FLASHC_fsr:     LongInt absolute AVR32_FLASHC_ADDRESS+$0008;
FLASHC_fgpfrhi: LongInt absolute AVR32_FLASHC_ADDRESS+$000c;
FLASHC_fgpfrlo: LongInt absolute AVR32_FLASHC_ADDRESS+$0010;
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
{ GPIO }
type
 Tavr32_gpio_local_port_t = packed record
 res0: array[0..15] of LongInt;
 oder,oders,oderc,odert,ovr,ovrs,ovrc,ovrt,pvr: LongInt;
 res1: array[0..38] of LongInt;
end;

type
 Tavr32_gpio_port_t = packed record
    gper,gpers,gperc,gpert,pmr0,pmr0s,pmr0c,pmr0t,
    pmr1,pmr1s,pmr1c,pmr1t: LongInt;
    res0: array[0..3] of LongInt;
    oder,oders,oderc,odert,ovr,ovrs,ovrc,ovrt,pvr: LongInt;
    res1: array[0..2] of LongInt;
    puer,puers,puerc,puert,odmer,odmers,odmerc,odmert,
    ier,iers,ierc,iert,imr0,imr0s,imr0c,imr0t,imr1,
    imr1s,imr1c,imr1t,gfer,gfers,gferc,gfert,ifr: LongInt;
    res2: LongInt;
    ifrc: LongInt;
    res3: array[0..8] of LongInt;
end;

var
  GPIO_local_port: array[0..(AVR32_GPIO_PORT_LENGTH-1)]  of Tavr32_gpio_local_port_t absolute AVR32_GPIO_LOCAL_ADDRESS;
  GPIO_port: array[0..(AVR32_GPIO_PORT_LENGTH-1)]  of Tavr32_gpio_port_t absolute AVR32_GPIO_ADDRESS;
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
PM_mcctrl:    LongInt absolute AVR32_PM_ADDRESS;
PM_cksel:     LongInt absolute AVR32_PM_ADDRESS+$0004;
PM_clkmask:   array[0..3] of LongInt absolute AVR32_PM_ADDRESS+$0008;
PM_cpumask:   LongInt absolute AVR32_PM_ADDRESS+$0008;
PM_hsbmask:   LongInt absolute AVR32_PM_ADDRESS+$000c;
PM_pbamask:   LongInt absolute AVR32_PM_ADDRESS+$0010;
PM_pbbmask:   LongInt absolute AVR32_PM_ADDRESS+$0014;
PM_pll:       array[0..1] of LongInt absolute AVR32_PM_ADDRESS+$0020;
PM_oscctrl0:  LongInt absolute AVR32_PM_ADDRESS+$0028;
PM_oscctrl1:  LongInt absolute AVR32_PM_ADDRESS+$002c;
PM_oscctrl32: LongInt absolute AVR32_PM_ADDRESS+$0030;
PM_ier:       LongInt absolute AVR32_PM_ADDRESS+$0040;
PM_idr:       LongInt absolute AVR32_PM_ADDRESS+$0044;
PM_imr:       LongInt absolute AVR32_PM_ADDRESS+$0048;
PM_isr:       LongInt absolute AVR32_PM_ADDRESS+$004c;
PM_icr:       LongInt absolute AVR32_PM_ADDRESS+$0050;
PM_poscsr:    LongInt absolute AVR32_PM_ADDRESS+$0054;
PM_gcctrl:    array[0..5] of LongInt absolute AVR32_PM_ADDRESS+$0060;
PM_rccr:      LongInt absolute AVR32_PM_ADDRESS+$00c0;
PM_bgcr:      LongInt absolute AVR32_PM_ADDRESS+$00c4;
PM_vregcr:    LongInt absolute AVR32_PM_ADDRESS+$00c8;
PM_bod:       LongInt absolute AVR32_PM_ADDRESS+$00d0;
PM_rcause:    LongInt absolute AVR32_PM_ADDRESS+$0140;
PM_awen:      LongInt absolute AVR32_PM_ADDRESS+$0144;
PM_gplp:      array[0..1] of LongInt absolute AVR32_PM_ADDRESS+$0200;
{ PWM }
type
Tavr32_pwm_channel_t = packed record
    cmr,cdty,cprd,ccnt,cupd: LongInt;
    res0: array[0..2] of LongInt;
end;

var
PWM_mr:       LongInt absolute AVR32_PWM_ADDRESS;
PWM_ena:      LongInt absolute AVR32_PWM_ADDRESS+$0004;
PWM_dis:      LongInt absolute AVR32_PWM_ADDRESS+$0008;
PWM_sr:       LongInt absolute AVR32_PWM_ADDRESS+$000c;
PWM_ier:      LongInt absolute AVR32_PWM_ADDRESS+$0010;
PWM_idr:      LongInt absolute AVR32_PWM_ADDRESS+$0014;
PWM_imr:      LongInt absolute AVR32_PWM_ADDRESS+$0018;
PWM_isr:      LongInt absolute AVR32_PWM_ADDRESS+$001c;
PWM_version:  LongInt absolute AVR32_PWM_ADDRESS+$00fc;
PWM_channel:  array[0..(AVR32_PWM_CHANNEL_LENGTH-1)] of Tavr32_pwm_channel_t absolute AVR32_PWM_ADDRESS+$0200;
{ RTC }
RTC_ctrl:      LongInt absolute AVR32_RTC_ADDRESS;
RTC_val:       LongInt absolute AVR32_RTC_ADDRESS+$0004;
RTC_top:       LongInt absolute AVR32_RTC_ADDRESS+$0008;
RTC_ier:       LongInt absolute AVR32_RTC_ADDRESS+$0010;
RTC_idr:       LongInt absolute AVR32_RTC_ADDRESS+$0014;
RTC_imr:       LongInt absolute AVR32_RTC_ADDRESS+$0018;
RTC_isr:       LongInt absolute AVR32_RTC_ADDRESS+$001c;
RTC_icr:       LongInt absolute AVR32_RTC_ADDRESS+$0020;
{ SPI }
SPI_cr:        LongInt absolute AVR32_SPI_ADDRESS;
SPI_mr:        LongInt absolute AVR32_SPI_ADDRESS+$0004;
SPI_rdr:       LongInt absolute AVR32_SPI_ADDRESS+$0008;
SPI_tdr:       LongInt absolute AVR32_SPI_ADDRESS+$000c;
SPI_sr :       LongInt absolute AVR32_SPI_ADDRESS+$0010;
SPI_ier:       LongInt absolute AVR32_SPI_ADDRESS+$0014;
SPI_idr:       LongInt absolute AVR32_SPI_ADDRESS+$0018;
SPI_imr:       LongInt absolute AVR32_SPI_ADDRESS+$001c;
SPI_csr0:      LongInt absolute AVR32_SPI_ADDRESS+$0030;
SPI_csr1:      LongInt absolute AVR32_SPI_ADDRESS+$0034;
SPI_csr2:      LongInt absolute AVR32_SPI_ADDRESS+$0038;
SPI_csr3:      LongInt absolute AVR32_SPI_ADDRESS+$003c;
SPI_version:   LongInt absolute AVR32_SPI_ADDRESS+$00fc;
{ SSC }
SSC_cr:       LongInt absolute AVR32_SSC_ADDRESS;
SSC_cmr:      LongInt absolute AVR32_SSC_ADDRESS+$0004;
SSC_rcmr:     LongInt absolute AVR32_SSC_ADDRESS+$0010;
SSC_rfmr:     LongInt absolute AVR32_SSC_ADDRESS+$0014;
SSC_tcmr:     LongInt absolute AVR32_SSC_ADDRESS+$0018;
SSC_tfmr:     LongInt absolute AVR32_SSC_ADDRESS+$001c;
SSC_rhr:      LongInt absolute AVR32_SSC_ADDRESS+$0020;
SSC_thr:      LongInt absolute AVR32_SSC_ADDRESS+$0024;
SSC_rshr:     LongInt absolute AVR32_SSC_ADDRESS+$0030;
SSC_tshr:     LongInt absolute AVR32_SSC_ADDRESS+$0034;
SSC_rc0r:     LongInt absolute AVR32_SSC_ADDRESS+$0038;
SSC_rc1r:     LongInt absolute AVR32_SSC_ADDRESS+$003c;
SSC_sr:       LongInt absolute AVR32_SSC_ADDRESS+$0040;
SSC_ier:      LongInt absolute AVR32_SSC_ADDRESS+$0044;
SSC_idr:      LongInt absolute AVR32_SSC_ADDRESS+$0048;
SSC_imr:      LongInt absolute AVR32_SSC_ADDRESS+$004c;
SSC_version:  LongInt absolute AVR32_SSC_ADDRESS+$00fc;
{ TC }
type
Tavr32_tc_channel_t = packed record
  ccr,cmr: LongInt;
  res0: array[0..1] of LongInt;
  cv,ra,rb,rc,sr,ier,idr,imr : LongInt;
  res1: array[0..3] of LongInt;
end;

var
TC_channel: array[0..2] of Tavr32_tc_channel_t absolute AVR32_TC_ADDRESS;
TC_bcr:     LongInt absolute AVR32_TC_ADDRESS+$00c0;
TC_bmr:     LongInt absolute AVR32_TC_ADDRESS+$00c4;
TC_version: LongInt absolute AVR32_TC_ADDRESS+$00fc;
{ TWI }
TWI_cr:        LongInt absolute AVR32_TWI_ADDRESS;
TWI_mmr:       LongInt absolute AVR32_TWI_ADDRESS+$0004;
TWI_smr:       LongInt absolute AVR32_TWI_ADDRESS+$0008;
TWI_iadr:      LongInt absolute AVR32_TWI_ADDRESS+$000c;
TWI_cwgr:      LongInt absolute AVR32_TWI_ADDRESS+$0010;
TWI_sr:        LongInt absolute AVR32_TWI_ADDRESS+$0020;
TWI_ier:       LongInt absolute AVR32_TWI_ADDRESS+$0024;
TWI_idr:       LongInt absolute AVR32_TWI_ADDRESS+$0028;
TWI_imr:       LongInt absolute AVR32_TWI_ADDRESS+$002c;
TWI_rhr:       LongInt absolute AVR32_TWI_ADDRESS+$0030;
TWI_thr:       LongInt absolute AVR32_TWI_ADDRESS+$0034;
{ USART0 }
USART0_cr:       LongInt absolute AVR32_USART0_ADDRESS;
USART0_mr:       LongInt absolute AVR32_USART0_ADDRESS+$0004;
USART0_ier:      LongInt absolute AVR32_USART0_ADDRESS+$0008;
USART0_idr:      LongInt absolute AVR32_USART0_ADDRESS+$000c;
USART0_imr:      LongInt absolute AVR32_USART0_ADDRESS+$0010;
USART0_csr:      LongInt absolute AVR32_USART0_ADDRESS+$0014;
USART0_rhr:      LongInt absolute AVR32_USART0_ADDRESS+$0018;
USART0_thr:      LongInt absolute AVR32_USART0_ADDRESS+$001c;
USART0_brgr:     LongInt absolute AVR32_USART0_ADDRESS+$0020;
USART0_rtor:     LongInt absolute AVR32_USART0_ADDRESS+$0024;
USART0_ttgr:     LongInt absolute AVR32_USART0_ADDRESS+$0028;
USART0_fidi:     LongInt absolute AVR32_USART0_ADDRESS+$0040;
USART0_ner:      LongInt absolute AVR32_USART0_ADDRESS+$0044;
USART0_ifr:      LongInt absolute AVR32_USART0_ADDRESS+$004c;
USART0_man:      LongInt absolute AVR32_USART0_ADDRESS+$0050;
USART0_linmr:    LongInt absolute AVR32_USART0_ADDRESS+$0054;
USART0_linir:    LongInt absolute AVR32_USART0_ADDRESS+$0058;
USART0_version:  LongInt absolute AVR32_USART0_ADDRESS+$00fc;
{ USART1 }
USART1_cr:       LongInt absolute AVR32_USART1_ADDRESS;
USART1_mr:       LongInt absolute AVR32_USART1_ADDRESS+$0004;
USART1_ier:      LongInt absolute AVR32_USART1_ADDRESS+$0008;
USART1_idr:      LongInt absolute AVR32_USART1_ADDRESS+$000c;
USART1_imr:      LongInt absolute AVR32_USART1_ADDRESS+$0010;
USART1_csr:      LongInt absolute AVR32_USART1_ADDRESS+$0014;
USART1_rhr:      LongInt absolute AVR32_USART1_ADDRESS+$0018;
USART1_thr:      LongInt absolute AVR32_USART1_ADDRESS+$001c;
USART1_brgr:     LongInt absolute AVR32_USART1_ADDRESS+$0020;
USART1_rtor:     LongInt absolute AVR32_USART1_ADDRESS+$0024;
USART1_ttgr:     LongInt absolute AVR32_USART1_ADDRESS+$0028;
USART1_fidi:     LongInt absolute AVR32_USART1_ADDRESS+$0040;
USART1_ner:      LongInt absolute AVR32_USART1_ADDRESS+$0044;
USART1_ifr:      LongInt absolute AVR32_USART1_ADDRESS+$004c;
USART1_man:      LongInt absolute AVR32_USART1_ADDRESS+$0050;
USART1_linmr:    LongInt absolute AVR32_USART1_ADDRESS+$0054;
USART1_linir:    LongInt absolute AVR32_USART1_ADDRESS+$0058;
USART1_version:  LongInt absolute AVR32_USART1_ADDRESS+$00fc;
{ USART2 }
USART2_cr:       LongInt absolute AVR32_USART2_ADDRESS;
USART2_mr:       LongInt absolute AVR32_USART2_ADDRESS+$0004;
USART2_ier:      LongInt absolute AVR32_USART2_ADDRESS+$0008;
USART2_idr:      LongInt absolute AVR32_USART2_ADDRESS+$000c;
USART2_imr:      LongInt absolute AVR32_USART2_ADDRESS+$0010;
USART2_csr:      LongInt absolute AVR32_USART2_ADDRESS+$0014;
USART2_rhr:      LongInt absolute AVR32_USART2_ADDRESS+$0018;
USART2_thr:      LongInt absolute AVR32_USART2_ADDRESS+$001c;
USART2_brgr:     LongInt absolute AVR32_USART2_ADDRESS+$0020;
USART2_rtor:     LongInt absolute AVR32_USART2_ADDRESS+$0024;
USART2_ttgr:     LongInt absolute AVR32_USART2_ADDRESS+$0028;
USART2_fidi:     LongInt absolute AVR32_USART2_ADDRESS+$0040;
USART2_ner:      LongInt absolute AVR32_USART2_ADDRESS+$0044;
USART2_ifr:      LongInt absolute AVR32_USART2_ADDRESS+$004c;
USART2_man:      LongInt absolute AVR32_USART2_ADDRESS+$0050;
USART2_linmr:    LongInt absolute AVR32_USART2_ADDRESS+$0054;
USART2_linir:    LongInt absolute AVR32_USART2_ADDRESS+$0058;
USART2_version:  LongInt absolute AVR32_USART2_ADDRESS+$00fc;
{ USBB }
USBB_udcon:            LongInt absolute AVR32_USBB_ADDRESS;
USBB_udint:            LongInt absolute AVR32_USBB_ADDRESS+$0004;
USBB_udintclr:         LongInt absolute AVR32_USBB_ADDRESS+$0008;
USBB_udintset:         LongInt absolute AVR32_USBB_ADDRESS+$000c;
USBB_udinte:           LongInt absolute AVR32_USBB_ADDRESS+$0010;
USBB_udinteclr:        LongInt absolute AVR32_USBB_ADDRESS+$0014;
USBB_udinteset:        LongInt absolute AVR32_USBB_ADDRESS+$0018;
USBB_uerst:            LongInt absolute AVR32_USBB_ADDRESS+$001c;
USBB_udfnum:           LongInt absolute AVR32_USBB_ADDRESS+$0020;
USBB_udtst1:           LongInt absolute AVR32_USBB_ADDRESS+$0024;
USBB_udtst2:           LongInt absolute AVR32_USBB_ADDRESS+$0028;
USBB_udvers:           LongInt absolute AVR32_USBB_ADDRESS+$002c;
USBB_udfeatures:       LongInt absolute AVR32_USBB_ADDRESS+$0030;
USBB_udaddrsize:       LongInt absolute AVR32_USBB_ADDRESS+$0034;
USBB_udname1:          LongInt absolute AVR32_USBB_ADDRESS+$0038;
USBB_udname2:          LongInt absolute AVR32_USBB_ADDRESS+$003c;
USBB_uecfg0:           LongInt absolute AVR32_USBB_ADDRESS+$0100;
USBB_uecfg1:           LongInt absolute AVR32_USBB_ADDRESS+$0104;
USBB_uecfg2:           LongInt absolute AVR32_USBB_ADDRESS+$0108;
USBB_uecfg3:           LongInt absolute AVR32_USBB_ADDRESS+$010c;
USBB_uecfg4:           LongInt absolute AVR32_USBB_ADDRESS+$0110;
USBB_uecfg5:           LongInt absolute AVR32_USBB_ADDRESS+$0114;
USBB_uecfg6:           LongInt absolute AVR32_USBB_ADDRESS+$0118;
USBB_uesta0:           LongInt absolute AVR32_USBB_ADDRESS+$0130;
USBB_uesta1:           LongInt absolute AVR32_USBB_ADDRESS+$0134;
USBB_uesta2:           LongInt absolute AVR32_USBB_ADDRESS+$0138;
USBB_uesta3:           LongInt absolute AVR32_USBB_ADDRESS+$013c;
USBB_uesta4:           LongInt absolute AVR32_USBB_ADDRESS+$0140;
USBB_uesta5:           LongInt absolute AVR32_USBB_ADDRESS+$0144;
USBB_uesta6:           LongInt absolute AVR32_USBB_ADDRESS+$0148;
USBB_uesta0clr:        LongInt absolute AVR32_USBB_ADDRESS+$0160;
USBB_uesta1clr:        LongInt absolute AVR32_USBB_ADDRESS+$0164;
USBB_uesta2clr:        LongInt absolute AVR32_USBB_ADDRESS+$0168;
USBB_uesta3clr:        LongInt absolute AVR32_USBB_ADDRESS+$016c;
USBB_uesta4clr:        LongInt absolute AVR32_USBB_ADDRESS+$0170;
USBB_uesta5clr:        LongInt absolute AVR32_USBB_ADDRESS+$0174;
USBB_uesta6clr:        LongInt absolute AVR32_USBB_ADDRESS+$0178;
USBB_uesta0set:        LongInt absolute AVR32_USBB_ADDRESS+$0190;
USBB_uesta1set:        LongInt absolute AVR32_USBB_ADDRESS+$0194;
USBB_uesta2set:        LongInt absolute AVR32_USBB_ADDRESS+$0198;
USBB_uesta3set:        LongInt absolute AVR32_USBB_ADDRESS+$019c;
USBB_uesta4set:        LongInt absolute AVR32_USBB_ADDRESS+$01a0;
USBB_uesta5set:        LongInt absolute AVR32_USBB_ADDRESS+$01a4;
USBB_uesta6set:        LongInt absolute AVR32_USBB_ADDRESS+$01a8;
USBB_uecon0:           LongInt absolute AVR32_USBB_ADDRESS+$01c0;
USBB_uecon1:           LongInt absolute AVR32_USBB_ADDRESS+$01c4;
USBB_uecon2:           LongInt absolute AVR32_USBB_ADDRESS+$01c8;
USBB_uecon3:           LongInt absolute AVR32_USBB_ADDRESS+$01cc;
USBB_uecon4:           LongInt absolute AVR32_USBB_ADDRESS+$01d0;
USBB_uecon5:           LongInt absolute AVR32_USBB_ADDRESS+$01d4;
USBB_uecon6:           LongInt absolute AVR32_USBB_ADDRESS+$01d8;
USBB_uecon0set:        LongInt absolute AVR32_USBB_ADDRESS+$01f0;
USBB_uecon1set:        LongInt absolute AVR32_USBB_ADDRESS+$01f4;
USBB_uecon2set:        LongInt absolute AVR32_USBB_ADDRESS+$01f8;
USBB_uecon3set:        LongInt absolute AVR32_USBB_ADDRESS+$01fc;
USBB_uecon4set:        LongInt absolute AVR32_USBB_ADDRESS+$0200;
USBB_uecon5set:        LongInt absolute AVR32_USBB_ADDRESS+$0204;
USBB_uecon6set:        LongInt absolute AVR32_USBB_ADDRESS+$0208;
USBB_uecon0clr:        LongInt absolute AVR32_USBB_ADDRESS+$0220;
USBB_uecon1clr:        LongInt absolute AVR32_USBB_ADDRESS+$0224;
USBB_uecon2clr:        LongInt absolute AVR32_USBB_ADDRESS+$0228;
USBB_uecon3clr:        LongInt absolute AVR32_USBB_ADDRESS+$022c;
USBB_uecon4clr:        LongInt absolute AVR32_USBB_ADDRESS+$0230;
USBB_uecon5clr:        LongInt absolute AVR32_USBB_ADDRESS+$0234;
USBB_uecon6clr:        LongInt absolute AVR32_USBB_ADDRESS+$0238;
USBB_uedat0:           LongInt absolute AVR32_USBB_ADDRESS+$0250;
USBB_uedat1:           LongInt absolute AVR32_USBB_ADDRESS+$0254;
USBB_uedat2:           LongInt absolute AVR32_USBB_ADDRESS+$0258;
USBB_uedat3:           LongInt absolute AVR32_USBB_ADDRESS+$025c;
USBB_uedat4:           LongInt absolute AVR32_USBB_ADDRESS+$0260;
USBB_uedat5:           LongInt absolute AVR32_USBB_ADDRESS+$0264;
USBB_uedat6:           LongInt absolute AVR32_USBB_ADDRESS+$0268;
USBB_uddma1_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0310;
USBB_uddma1_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0314;
USBB_uddma1_control:   LongInt absolute AVR32_USBB_ADDRESS+$0318;
USBB_uddma1_status:    LongInt absolute AVR32_USBB_ADDRESS+$031c;
USBB_uddma2_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0320;
USBB_uddma2_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0324;
USBB_uddma2_control:   LongInt absolute AVR32_USBB_ADDRESS+$0328;
USBB_uddma2_status:    LongInt absolute AVR32_USBB_ADDRESS+$032c;
USBB_uddma3_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0330;
USBB_uddma3_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0334;
USBB_uddma3_control:   LongInt absolute AVR32_USBB_ADDRESS+$0338;
USBB_uddma3_status:    LongInt absolute AVR32_USBB_ADDRESS+$033c;
USBB_uddma4_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0340;
USBB_uddma4_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0344;
USBB_uddma4_control:   LongInt absolute AVR32_USBB_ADDRESS+$0348;
USBB_uddma4_status:    LongInt absolute AVR32_USBB_ADDRESS+$034c;
USBB_uddma5_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0350;
USBB_uddma5_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0354;
USBB_uddma5_control:   LongInt absolute AVR32_USBB_ADDRESS+$0358;
USBB_uddma5_status:    LongInt absolute AVR32_USBB_ADDRESS+$035c;
USBB_uddma6_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0360;
USBB_uddma6_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0364;
USBB_uddma6_control:   LongInt absolute AVR32_USBB_ADDRESS+$0368;
USBB_uddma6_status:    LongInt absolute AVR32_USBB_ADDRESS+$036c;
USBB_uhcon:            LongInt absolute AVR32_USBB_ADDRESS+$0400;
USBB_uhint:            LongInt absolute AVR32_USBB_ADDRESS+$0404;
USBB_uhintclr:         LongInt absolute AVR32_USBB_ADDRESS+$0408;
USBB_uhintset:         LongInt absolute AVR32_USBB_ADDRESS+$040c;
USBB_uhinte:           LongInt absolute AVR32_USBB_ADDRESS+$0410;
USBB_uhinteclr:        LongInt absolute AVR32_USBB_ADDRESS+$0414;
USBB_uhinteset:        LongInt absolute AVR32_USBB_ADDRESS+$0418;
USBB_uprst:            LongInt absolute AVR32_USBB_ADDRESS+$041c;
USBB_uhfnum:           LongInt absolute AVR32_USBB_ADDRESS+$0420;
USBB_uhaddr1:          LongInt absolute AVR32_USBB_ADDRESS+$0424;
USBB_uhaddr2:          LongInt absolute AVR32_USBB_ADDRESS+$0428;
USBB_uhaddr3:          LongInt absolute AVR32_USBB_ADDRESS+$042c;
USBB_upcfg0:           LongInt absolute AVR32_USBB_ADDRESS+$0500;
USBB_upcfg1:           LongInt absolute AVR32_USBB_ADDRESS+$0504;
USBB_upcfg2:           LongInt absolute AVR32_USBB_ADDRESS+$0508;
USBB_upcfg3:           LongInt absolute AVR32_USBB_ADDRESS+$050c;
USBB_upcfg4:           LongInt absolute AVR32_USBB_ADDRESS+$0510;
USBB_upcfg5:           LongInt absolute AVR32_USBB_ADDRESS+$0514;
USBB_upcfg6:           LongInt absolute AVR32_USBB_ADDRESS+$0518;
USBB_upsta0:           LongInt absolute AVR32_USBB_ADDRESS+$0530;
USBB_upsta1:           LongInt absolute AVR32_USBB_ADDRESS+$0534;
USBB_upsta2:           LongInt absolute AVR32_USBB_ADDRESS+$0538;
USBB_upsta3:           LongInt absolute AVR32_USBB_ADDRESS+$053c;
USBB_upsta4:           LongInt absolute AVR32_USBB_ADDRESS+$0540;
USBB_upsta5:           LongInt absolute AVR32_USBB_ADDRESS+$0544;
USBB_upsta6:           LongInt absolute AVR32_USBB_ADDRESS+$0548;
USBB_upsta0clr:        LongInt absolute AVR32_USBB_ADDRESS+$0560;
USBB_upsta1clr:        LongInt absolute AVR32_USBB_ADDRESS+$0564;
USBB_upsta2clr:        LongInt absolute AVR32_USBB_ADDRESS+$0568;
USBB_upsta3clr:        LongInt absolute AVR32_USBB_ADDRESS+$056c;
USBB_upsta4clr:        LongInt absolute AVR32_USBB_ADDRESS+$0570;
USBB_upsta5clr:        LongInt absolute AVR32_USBB_ADDRESS+$0574;
USBB_upsta6clr:        LongInt absolute AVR32_USBB_ADDRESS+$0578;
USBB_upsta0set:        LongInt absolute AVR32_USBB_ADDRESS+$0590;
USBB_upsta1set:        LongInt absolute AVR32_USBB_ADDRESS+$0594;
USBB_upsta2set:        LongInt absolute AVR32_USBB_ADDRESS+$0598;
USBB_upsta3set:        LongInt absolute AVR32_USBB_ADDRESS+$059c;
USBB_upsta4set:        LongInt absolute AVR32_USBB_ADDRESS+$05a0;
USBB_upsta5set:        LongInt absolute AVR32_USBB_ADDRESS+$05a4;
USBB_upsta6set:        LongInt absolute AVR32_USBB_ADDRESS+$05a8;
USBB_upcon0:           LongInt absolute AVR32_USBB_ADDRESS+$05c0;
USBB_upcon1:           LongInt absolute AVR32_USBB_ADDRESS+$05c4;
USBB_upcon2:           LongInt absolute AVR32_USBB_ADDRESS+$05c8;
USBB_upcon3:           LongInt absolute AVR32_USBB_ADDRESS+$05cc;
USBB_upcon4:           LongInt absolute AVR32_USBB_ADDRESS+$05d0;
USBB_upcon5:           LongInt absolute AVR32_USBB_ADDRESS+$05d4;
USBB_upcon6:           LongInt absolute AVR32_USBB_ADDRESS+$05d8;
USBB_upcon0set:        LongInt absolute AVR32_USBB_ADDRESS+$05f0;
USBB_upcon1set:        LongInt absolute AVR32_USBB_ADDRESS+$05f4;
USBB_upcon2set:        LongInt absolute AVR32_USBB_ADDRESS+$05f8;
USBB_upcon3set:        LongInt absolute AVR32_USBB_ADDRESS+$05fc;
USBB_upcon4set:        LongInt absolute AVR32_USBB_ADDRESS+$0600;
USBB_upcon5set:        LongInt absolute AVR32_USBB_ADDRESS+$0604;
USBB_upcon6set:        LongInt absolute AVR32_USBB_ADDRESS+$0608;
USBB_upcon0clr:        LongInt absolute AVR32_USBB_ADDRESS+$0620;
USBB_upcon1clr:        LongInt absolute AVR32_USBB_ADDRESS+$0624;
USBB_upcon2clr:        LongInt absolute AVR32_USBB_ADDRESS+$0628;
USBB_upcon3clr:        LongInt absolute AVR32_USBB_ADDRESS+$062c;
USBB_upcon4clr:        LongInt absolute AVR32_USBB_ADDRESS+$0630;
USBB_upcon5clr:        LongInt absolute AVR32_USBB_ADDRESS+$0634;
USBB_upcon6clr:        LongInt absolute AVR32_USBB_ADDRESS+$0638;
USBB_upinrq0:          LongInt absolute AVR32_USBB_ADDRESS+$0650;
USBB_upinrq1:          LongInt absolute AVR32_USBB_ADDRESS+$0654;
USBB_upinrq2:          LongInt absolute AVR32_USBB_ADDRESS+$0658;
USBB_upinrq3:          LongInt absolute AVR32_USBB_ADDRESS+$065c;
USBB_upinrq4:          LongInt absolute AVR32_USBB_ADDRESS+$0660;
USBB_upinrq5:          LongInt absolute AVR32_USBB_ADDRESS+$0664;
USBB_upinrq6:          LongInt absolute AVR32_USBB_ADDRESS+$0668;
USBB_uperr0:           LongInt absolute AVR32_USBB_ADDRESS+$0680;
USBB_uperr1:           LongInt absolute AVR32_USBB_ADDRESS+$0684;
USBB_uperr2:           LongInt absolute AVR32_USBB_ADDRESS+$0688;
USBB_uperr3:           LongInt absolute AVR32_USBB_ADDRESS+$068c;
USBB_uperr4:           LongInt absolute AVR32_USBB_ADDRESS+$0690;
USBB_uperr5:           LongInt absolute AVR32_USBB_ADDRESS+$0694;
USBB_uperr6:           LongInt absolute AVR32_USBB_ADDRESS+$0698;
USBB_updat0:           LongInt absolute AVR32_USBB_ADDRESS+$06b0;
USBB_updat1:           LongInt absolute AVR32_USBB_ADDRESS+$06b4;
USBB_updat2:           LongInt absolute AVR32_USBB_ADDRESS+$06b8;
USBB_updat3:           LongInt absolute AVR32_USBB_ADDRESS+$06bc;
USBB_updat4:           LongInt absolute AVR32_USBB_ADDRESS+$06c0;
USBB_updat5:           LongInt absolute AVR32_USBB_ADDRESS+$06c4;
USBB_updat6:           LongInt absolute AVR32_USBB_ADDRESS+$06c8;
USBB_uhdma1_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0710;
USBB_uhdma1_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0714;
USBB_uhdma1_control:   LongInt absolute AVR32_USBB_ADDRESS+$0718;
USBB_uhdma1_status:    LongInt absolute AVR32_USBB_ADDRESS+$071c;
USBB_uhdma2_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0720;
USBB_uhdma2_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0724;
USBB_uhdma2_control:   LongInt absolute AVR32_USBB_ADDRESS+$0728;
USBB_uhdma2_status:    LongInt absolute AVR32_USBB_ADDRESS+$072c;
USBB_uhdma3_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0730;
USBB_uhdma3_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0734;
USBB_uhdma3_control:   LongInt absolute AVR32_USBB_ADDRESS+$0738;
USBB_uhdma3_status:    LongInt absolute AVR32_USBB_ADDRESS+$073c;
USBB_uhdma4_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0740;
USBB_uhdma4_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0744;
USBB_uhdma4_control:   LongInt absolute AVR32_USBB_ADDRESS+$0748;
USBB_uhdma4_status:    LongInt absolute AVR32_USBB_ADDRESS+$074c;
USBB_uhdma5_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0750;
USBB_uhdma5_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0754;
USBB_uhdma5_control:   LongInt absolute AVR32_USBB_ADDRESS+$0758;
USBB_uhdma5_status:    LongInt absolute AVR32_USBB_ADDRESS+$075c;
USBB_uhdma6_nextdesc:  LongInt absolute AVR32_USBB_ADDRESS+$0760;
USBB_uhdma6_addr:      LongInt absolute AVR32_USBB_ADDRESS+$0764;
USBB_uhdma6_control:   LongInt absolute AVR32_USBB_ADDRESS+$0768;
USBB_uhdma6_status:    LongInt absolute AVR32_USBB_ADDRESS+$076c;
USBB_usbcon:           LongInt absolute AVR32_USBB_ADDRESS+$0800;
USBB_usbsta:           LongInt absolute AVR32_USBB_ADDRESS+$0804;
USBB_usbstaclr:        LongInt absolute AVR32_USBB_ADDRESS+$0808;
USBB_usbstaset:        LongInt absolute AVR32_USBB_ADDRESS+$080c;
USBB_uatst1:           LongInt absolute AVR32_USBB_ADDRESS+$0810;
USBB_uatst2:           LongInt absolute AVR32_USBB_ADDRESS+$0814;
USBB_uvers:            LongInt absolute AVR32_USBB_ADDRESS+$0818;
USBB_ufeatures:        LongInt absolute AVR32_USBB_ADDRESS+$081c;
USBB_uaddrsize:        LongInt absolute AVR32_USBB_ADDRESS+$0820;
USBB_uname1:           LongInt absolute AVR32_USBB_ADDRESS+$0824;
USBB_uname2:           LongInt absolute AVR32_USBB_ADDRESS+$0828;
USBB_usbfsm:           LongInt absolute AVR32_USBB_ADDRESS+$082c;
{ WDT }
WDT_ctrl:      LongInt absolute AVR32_WDT_ADDRESS;
WDT_clr:       LongInt absolute AVR32_WDT_ADDRESS+$0004;


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



