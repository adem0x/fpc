unit pic32mx320f128h;
interface
{$goto on}
{$modeswitch advancedrecords}
{$INLINE ON}
{$OPTIMIZATION STACKFRAME}
{$L startup.o}
{$PACKRECORDS 2}
type
  TBits_1 = 0..1;
  TBits_2 = 0..3;
  TBits_3 = 0..7;
  TBits_4 = 0..15;
  TBits_5 = 0..31;
  TBits_6 = 0..63;
  TBits_7 = 0..127;
  TBits_8 = 0..255;
  TBits_9 = 0..511;
  TBits_10 = 0..1023;
  TBits_11 = 0..2047;
  TBits_12 = 0..4095;
  TBits_13 = 0..8191;
  TBits_14 = 0..16383;
  TBits_15 = 0..32767;
  TBits_16 = 0..65535;
  TBits_17 = 0..131071;
  TBits_18 = 0..262143;
  TBits_19 = 0..524287;
  TBits_20 = 0..1048575;
  TBits_21 = 0..2097151;
  TBits_22 = 0..4194303;
  TBits_23 = 0..8388607;
  TBits_24 = 0..16777215;
  TBits_25 = 0..33554431;
  TBits_26 = 0..67108863;
  TBits_27 = 0..134217727;
  TBits_28 = 0..268435455;
  TBits_29 = 0..536870911;
  TBits_30 = 0..1073741823;
  TBits_31 = 0..2147483647;
  TBits_32 = 0..4294967295;
  TWDT_WDTCON = record
  private
    function  getON : TBits_1; inline;
    function  getSWDTPS : TBits_5; inline;
    function  getSWDTPS0 : TBits_1; inline;
    function  getSWDTPS1 : TBits_1; inline;
    function  getSWDTPS2 : TBits_1; inline;
    function  getSWDTPS3 : TBits_1; inline;
    function  getSWDTPS4 : TBits_1; inline;
    function  getWDTCLR : TBits_1; inline;
    function  getWDTPS : TBits_5; inline;
    function  getWDTPSTA : TBits_5; inline;
    function  getw : TBits_32; inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSWDTPS(thebits : TBits_5); inline;
    procedure setSWDTPS0(thebits : TBits_1); inline;
    procedure setSWDTPS1(thebits : TBits_1); inline;
    procedure setSWDTPS2(thebits : TBits_1); inline;
    procedure setSWDTPS3(thebits : TBits_1); inline;
    procedure setSWDTPS4(thebits : TBits_1); inline;
    procedure setWDTCLR(thebits : TBits_1); inline;
    procedure setWDTPS(thebits : TBits_5); inline;
    procedure setWDTPSTA(thebits : TBits_5); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearON; inline;
    procedure clearSWDTPS0; inline;
    procedure clearSWDTPS1; inline;
    procedure clearSWDTPS2; inline;
    procedure clearSWDTPS3; inline;
    procedure clearSWDTPS4; inline;
    procedure clearWDTCLR; inline;
    procedure setON; inline;
    procedure setSWDTPS0; inline;
    procedure setSWDTPS1; inline;
    procedure setSWDTPS2; inline;
    procedure setSWDTPS3; inline;
    procedure setSWDTPS4; inline;
    procedure setWDTCLR; inline;
    property ON : TBits_1 read getON write setON;
    property SWDTPS : TBits_5 read getSWDTPS write setSWDTPS;
    property SWDTPS0 : TBits_1 read getSWDTPS0 write setSWDTPS0;
    property SWDTPS1 : TBits_1 read getSWDTPS1 write setSWDTPS1;
    property SWDTPS2 : TBits_1 read getSWDTPS2 write setSWDTPS2;
    property SWDTPS3 : TBits_1 read getSWDTPS3 write setSWDTPS3;
    property SWDTPS4 : TBits_1 read getSWDTPS4 write setSWDTPS4;
    property WDTCLR : TBits_1 read getWDTCLR write setWDTCLR;
    property WDTPS : TBits_5 read getWDTPS write setWDTPS;
    property WDTPSTA : TBits_5 read getWDTPSTA write setWDTPSTA;
    property w : TBits_32 read getw write setw;
  end;
type
  TWDTRegisters = record
    WDTCONbits : TWDT_WDTCON;
    WDTCON : longWord;
    WDTCONCLR : longWord;
    WDTCONSET : longWord;
    WDTCONINV : longWord;
  end;
  TRTCC_RTCCON = record
  private
    function  getCAL : TBits_10; inline;
    function  getHALFSEC : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getRTCCLKON : TBits_1; inline;
    function  getRTCOE : TBits_1; inline;
    function  getRTCSYNC : TBits_1; inline;
    function  getRTCWREN : TBits_1; inline;
    function  getRTSECSEL : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCAL(thebits : TBits_10); inline;
    procedure setHALFSEC(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setRTCCLKON(thebits : TBits_1); inline;
    procedure setRTCOE(thebits : TBits_1); inline;
    procedure setRTCSYNC(thebits : TBits_1); inline;
    procedure setRTCWREN(thebits : TBits_1); inline;
    procedure setRTSECSEL(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearHALFSEC; inline;
    procedure clearON; inline;
    procedure clearRTCCLKON; inline;
    procedure clearRTCOE; inline;
    procedure clearRTCSYNC; inline;
    procedure clearRTCWREN; inline;
    procedure clearRTSECSEL; inline;
    procedure clearSIDL; inline;
    procedure setHALFSEC; inline;
    procedure setON; inline;
    procedure setRTCCLKON; inline;
    procedure setRTCOE; inline;
    procedure setRTCSYNC; inline;
    procedure setRTCWREN; inline;
    procedure setRTSECSEL; inline;
    procedure setSIDL; inline;
    property CAL : TBits_10 read getCAL write setCAL;
    property HALFSEC : TBits_1 read getHALFSEC write setHALFSEC;
    property ON : TBits_1 read getON write setON;
    property RTCCLKON : TBits_1 read getRTCCLKON write setRTCCLKON;
    property RTCOE : TBits_1 read getRTCOE write setRTCOE;
    property RTCSYNC : TBits_1 read getRTCSYNC write setRTCSYNC;
    property RTCWREN : TBits_1 read getRTCWREN write setRTCWREN;
    property RTSECSEL : TBits_1 read getRTSECSEL write setRTSECSEL;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
  TRTCC_RTCALRM = record
  private
    function  getALRMEN : TBits_1; inline;
    function  getALRMSYNC : TBits_1; inline;
    function  getAMASK : TBits_4; inline;
    function  getARPT : TBits_8; inline;
    function  getCHIME : TBits_1; inline;
    function  getPIV : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setALRMEN(thebits : TBits_1); inline;
    procedure setALRMSYNC(thebits : TBits_1); inline;
    procedure setAMASK(thebits : TBits_4); inline;
    procedure setARPT(thebits : TBits_8); inline;
    procedure setCHIME(thebits : TBits_1); inline;
    procedure setPIV(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearALRMEN; inline;
    procedure clearALRMSYNC; inline;
    procedure clearCHIME; inline;
    procedure clearPIV; inline;
    procedure setALRMEN; inline;
    procedure setALRMSYNC; inline;
    procedure setCHIME; inline;
    procedure setPIV; inline;
    property ALRMEN : TBits_1 read getALRMEN write setALRMEN;
    property ALRMSYNC : TBits_1 read getALRMSYNC write setALRMSYNC;
    property AMASK : TBits_4 read getAMASK write setAMASK;
    property ARPT : TBits_8 read getARPT write setARPT;
    property CHIME : TBits_1 read getCHIME write setCHIME;
    property PIV : TBits_1 read getPIV write setPIV;
    property w : TBits_32 read getw write setw;
  end;
  TRTCC_RTCTIME = record
  private
    function  getHR01 : TBits_4; inline;
    function  getHR10 : TBits_4; inline;
    function  getMIN01 : TBits_4; inline;
    function  getMIN10 : TBits_4; inline;
    function  getSEC01 : TBits_4; inline;
    function  getSEC10 : TBits_4; inline;
    function  getw : TBits_32; inline;
    procedure setHR01(thebits : TBits_4); inline;
    procedure setHR10(thebits : TBits_4); inline;
    procedure setMIN01(thebits : TBits_4); inline;
    procedure setMIN10(thebits : TBits_4); inline;
    procedure setSEC01(thebits : TBits_4); inline;
    procedure setSEC10(thebits : TBits_4); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    property HR01 : TBits_4 read getHR01 write setHR01;
    property HR10 : TBits_4 read getHR10 write setHR10;
    property MIN01 : TBits_4 read getMIN01 write setMIN01;
    property MIN10 : TBits_4 read getMIN10 write setMIN10;
    property SEC01 : TBits_4 read getSEC01 write setSEC01;
    property SEC10 : TBits_4 read getSEC10 write setSEC10;
    property w : TBits_32 read getw write setw;
  end;
  TRTCC_RTCDATE = record
  private
    function  getDAY01 : TBits_4; inline;
    function  getDAY10 : TBits_4; inline;
    function  getMONTH01 : TBits_4; inline;
    function  getMONTH10 : TBits_4; inline;
    function  getWDAY01 : TBits_4; inline;
    function  getYEAR01 : TBits_4; inline;
    function  getYEAR10 : TBits_4; inline;
    function  getw : TBits_32; inline;
    procedure setDAY01(thebits : TBits_4); inline;
    procedure setDAY10(thebits : TBits_4); inline;
    procedure setMONTH01(thebits : TBits_4); inline;
    procedure setMONTH10(thebits : TBits_4); inline;
    procedure setWDAY01(thebits : TBits_4); inline;
    procedure setYEAR01(thebits : TBits_4); inline;
    procedure setYEAR10(thebits : TBits_4); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    property DAY01 : TBits_4 read getDAY01 write setDAY01;
    property DAY10 : TBits_4 read getDAY10 write setDAY10;
    property MONTH01 : TBits_4 read getMONTH01 write setMONTH01;
    property MONTH10 : TBits_4 read getMONTH10 write setMONTH10;
    property WDAY01 : TBits_4 read getWDAY01 write setWDAY01;
    property YEAR01 : TBits_4 read getYEAR01 write setYEAR01;
    property YEAR10 : TBits_4 read getYEAR10 write setYEAR10;
    property w : TBits_32 read getw write setw;
  end;
  TRTCC_ALRMTIME = record
  private
    function  getHR01 : TBits_4; inline;
    function  getHR10 : TBits_4; inline;
    function  getMIN01 : TBits_4; inline;
    function  getMIN10 : TBits_4; inline;
    function  getSEC01 : TBits_4; inline;
    function  getSEC10 : TBits_4; inline;
    function  getw : TBits_32; inline;
    procedure setHR01(thebits : TBits_4); inline;
    procedure setHR10(thebits : TBits_4); inline;
    procedure setMIN01(thebits : TBits_4); inline;
    procedure setMIN10(thebits : TBits_4); inline;
    procedure setSEC01(thebits : TBits_4); inline;
    procedure setSEC10(thebits : TBits_4); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    property HR01 : TBits_4 read getHR01 write setHR01;
    property HR10 : TBits_4 read getHR10 write setHR10;
    property MIN01 : TBits_4 read getMIN01 write setMIN01;
    property MIN10 : TBits_4 read getMIN10 write setMIN10;
    property SEC01 : TBits_4 read getSEC01 write setSEC01;
    property SEC10 : TBits_4 read getSEC10 write setSEC10;
    property w : TBits_32 read getw write setw;
  end;
  TRTCC_ALRMDATE = record
  private
    function  getDAY01 : TBits_4; inline;
    function  getDAY10 : TBits_4; inline;
    function  getMONTH01 : TBits_4; inline;
    function  getMONTH10 : TBits_4; inline;
    function  getWDAY01 : TBits_4; inline;
    function  getw : TBits_32; inline;
    procedure setDAY01(thebits : TBits_4); inline;
    procedure setDAY10(thebits : TBits_4); inline;
    procedure setMONTH01(thebits : TBits_4); inline;
    procedure setMONTH10(thebits : TBits_4); inline;
    procedure setWDAY01(thebits : TBits_4); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    property DAY01 : TBits_4 read getDAY01 write setDAY01;
    property DAY10 : TBits_4 read getDAY10 write setDAY10;
    property MONTH01 : TBits_4 read getMONTH01 write setMONTH01;
    property MONTH10 : TBits_4 read getMONTH10 write setMONTH10;
    property WDAY01 : TBits_4 read getWDAY01 write setWDAY01;
    property w : TBits_32 read getw write setw;
  end;
type
  TRTCCRegisters = record
    RTCCONbits : TRTCC_RTCCON;
    RTCCON : longWord;
    RTCCONCLR : longWord;
    RTCCONSET : longWord;
    RTCCONINV : longWord;
    RTCALRMbits : TRTCC_RTCALRM;
    RTCALRM : longWord;
    RTCALRMCLR : longWord;
    RTCALRMSET : longWord;
    RTCALRMINV : longWord;
    RTCTIMEbits : TRTCC_RTCTIME;
    RTCTIME : longWord;
    RTCTIMECLR : longWord;
    RTCTIMESET : longWord;
    RTCTIMEINV : longWord;
    RTCDATEbits : TRTCC_RTCDATE;
    RTCDATE : longWord;
    RTCDATECLR : longWord;
    RTCDATESET : longWord;
    RTCDATEINV : longWord;
    ALRMTIMEbits : TRTCC_ALRMTIME;
    ALRMTIME : longWord;
    ALRMTIMECLR : longWord;
    ALRMTIMESET : longWord;
    ALRMTIMEINV : longWord;
    ALRMDATEbits : TRTCC_ALRMDATE;
    ALRMDATE : longWord;
    ALRMDATECLR : longWord;
    ALRMDATESET : longWord;
    ALRMDATEINV : longWord;
  end;
  TTMR1_T1CON = record
  private
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getTCKPS : TBits_2; inline;
    function  getTCKPS0 : TBits_1; inline;
    function  getTCKPS1 : TBits_1; inline;
    function  getTCS : TBits_1; inline;
    function  getTGATE : TBits_1; inline;
    function  getTON : TBits_1; inline;
    function  getTSIDL : TBits_1; inline;
    function  getTSYNC : TBits_1; inline;
    function  getTWDIS : TBits_1; inline;
    function  getTWIP : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setTCKPS(thebits : TBits_2); inline;
    procedure setTCKPS0(thebits : TBits_1); inline;
    procedure setTCKPS1(thebits : TBits_1); inline;
    procedure setTCS(thebits : TBits_1); inline;
    procedure setTGATE(thebits : TBits_1); inline;
    procedure setTON(thebits : TBits_1); inline;
    procedure setTSIDL(thebits : TBits_1); inline;
    procedure setTSYNC(thebits : TBits_1); inline;
    procedure setTWDIS(thebits : TBits_1); inline;
    procedure setTWIP(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure clearTCKPS0; inline;
    procedure clearTCKPS1; inline;
    procedure clearTCS; inline;
    procedure clearTGATE; inline;
    procedure clearTON; inline;
    procedure clearTSIDL; inline;
    procedure clearTSYNC; inline;
    procedure clearTWDIS; inline;
    procedure clearTWIP; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    procedure setTCKPS0; inline;
    procedure setTCKPS1; inline;
    procedure setTCS; inline;
    procedure setTGATE; inline;
    procedure setTON; inline;
    procedure setTSIDL; inline;
    procedure setTSYNC; inline;
    procedure setTWDIS; inline;
    procedure setTWIP; inline;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property TCKPS : TBits_2 read getTCKPS write setTCKPS;
    property TCKPS0 : TBits_1 read getTCKPS0 write setTCKPS0;
    property TCKPS1 : TBits_1 read getTCKPS1 write setTCKPS1;
    property TCS : TBits_1 read getTCS write setTCS;
    property TGATE : TBits_1 read getTGATE write setTGATE;
    property TON : TBits_1 read getTON write setTON;
    property TSIDL : TBits_1 read getTSIDL write setTSIDL;
    property TSYNC : TBits_1 read getTSYNC write setTSYNC;
    property TWDIS : TBits_1 read getTWDIS write setTWDIS;
    property TWIP : TBits_1 read getTWIP write setTWIP;
    property w : TBits_32 read getw write setw;
  end;
type
  TTMR1Registers = record
    T1CONbits : TTMR1_T1CON;
    T1CON : longWord;
    T1CONCLR : longWord;
    T1CONSET : longWord;
    T1CONINV : longWord;
    TMR1 : longWord;
    TMR1CLR : longWord;
    TMR1SET : longWord;
    TMR1INV : longWord;
    PR1 : longWord;
    PR1CLR : longWord;
    PR1SET : longWord;
    PR1INV : longWord;
  end;
  TTMR23_T2CON = record
  private
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getT32 : TBits_1; inline;
    function  getTCKPS : TBits_3; inline;
    function  getTCKPS0 : TBits_1; inline;
    function  getTCKPS1 : TBits_1; inline;
    function  getTCKPS2 : TBits_1; inline;
    function  getTCS : TBits_1; inline;
    function  getTGATE : TBits_1; inline;
    function  getTON : TBits_1; inline;
    function  getTSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setT32(thebits : TBits_1); inline;
    procedure setTCKPS(thebits : TBits_3); inline;
    procedure setTCKPS0(thebits : TBits_1); inline;
    procedure setTCKPS1(thebits : TBits_1); inline;
    procedure setTCKPS2(thebits : TBits_1); inline;
    procedure setTCS(thebits : TBits_1); inline;
    procedure setTGATE(thebits : TBits_1); inline;
    procedure setTON(thebits : TBits_1); inline;
    procedure setTSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure clearT32; inline;
    procedure clearTCKPS0; inline;
    procedure clearTCKPS1; inline;
    procedure clearTCKPS2; inline;
    procedure clearTCS; inline;
    procedure clearTGATE; inline;
    procedure clearTON; inline;
    procedure clearTSIDL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    procedure setT32; inline;
    procedure setTCKPS0; inline;
    procedure setTCKPS1; inline;
    procedure setTCKPS2; inline;
    procedure setTCS; inline;
    procedure setTGATE; inline;
    procedure setTON; inline;
    procedure setTSIDL; inline;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property T32 : TBits_1 read getT32 write setT32;
    property TCKPS : TBits_3 read getTCKPS write setTCKPS;
    property TCKPS0 : TBits_1 read getTCKPS0 write setTCKPS0;
    property TCKPS1 : TBits_1 read getTCKPS1 write setTCKPS1;
    property TCKPS2 : TBits_1 read getTCKPS2 write setTCKPS2;
    property TCS : TBits_1 read getTCS write setTCS;
    property TGATE : TBits_1 read getTGATE write setTGATE;
    property TON : TBits_1 read getTON write setTON;
    property TSIDL : TBits_1 read getTSIDL write setTSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TTMR23Registers = record
    T2CONbits : TTMR23_T2CON;
    T2CON : longWord;
    T2CONCLR : longWord;
    T2CONSET : longWord;
    T2CONINV : longWord;
    TMR2 : longWord;
    TMR2CLR : longWord;
    TMR2SET : longWord;
    TMR2INV : longWord;
    PR2 : longWord;
    PR2CLR : longWord;
    PR2SET : longWord;
    PR2INV : longWord;
  end;
  TTMR3_T3CON = record
  private
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getTCKPS : TBits_3; inline;
    function  getTCKPS0 : TBits_1; inline;
    function  getTCKPS1 : TBits_1; inline;
    function  getTCKPS2 : TBits_1; inline;
    function  getTCS : TBits_1; inline;
    function  getTGATE : TBits_1; inline;
    function  getTON : TBits_1; inline;
    function  getTSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setTCKPS(thebits : TBits_3); inline;
    procedure setTCKPS0(thebits : TBits_1); inline;
    procedure setTCKPS1(thebits : TBits_1); inline;
    procedure setTCKPS2(thebits : TBits_1); inline;
    procedure setTCS(thebits : TBits_1); inline;
    procedure setTGATE(thebits : TBits_1); inline;
    procedure setTON(thebits : TBits_1); inline;
    procedure setTSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure clearTCKPS0; inline;
    procedure clearTCKPS1; inline;
    procedure clearTCKPS2; inline;
    procedure clearTCS; inline;
    procedure clearTGATE; inline;
    procedure clearTON; inline;
    procedure clearTSIDL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    procedure setTCKPS0; inline;
    procedure setTCKPS1; inline;
    procedure setTCKPS2; inline;
    procedure setTCS; inline;
    procedure setTGATE; inline;
    procedure setTON; inline;
    procedure setTSIDL; inline;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property TCKPS : TBits_3 read getTCKPS write setTCKPS;
    property TCKPS0 : TBits_1 read getTCKPS0 write setTCKPS0;
    property TCKPS1 : TBits_1 read getTCKPS1 write setTCKPS1;
    property TCKPS2 : TBits_1 read getTCKPS2 write setTCKPS2;
    property TCS : TBits_1 read getTCS write setTCS;
    property TGATE : TBits_1 read getTGATE write setTGATE;
    property TON : TBits_1 read getTON write setTON;
    property TSIDL : TBits_1 read getTSIDL write setTSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TTMR3Registers = record
    T3CONbits : TTMR3_T3CON;
    T3CON : longWord;
    T3CONCLR : longWord;
    T3CONSET : longWord;
    T3CONINV : longWord;
    TMR3 : longWord;
    TMR3CLR : longWord;
    TMR3SET : longWord;
    TMR3INV : longWord;
    PR3 : longWord;
    PR3CLR : longWord;
    PR3SET : longWord;
    PR3INV : longWord;
  end;
  TTMR4_T4CON = record
  private
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getT32 : TBits_1; inline;
    function  getTCKPS : TBits_3; inline;
    function  getTCKPS0 : TBits_1; inline;
    function  getTCKPS1 : TBits_1; inline;
    function  getTCKPS2 : TBits_1; inline;
    function  getTCS : TBits_1; inline;
    function  getTGATE : TBits_1; inline;
    function  getTON : TBits_1; inline;
    function  getTSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setT32(thebits : TBits_1); inline;
    procedure setTCKPS(thebits : TBits_3); inline;
    procedure setTCKPS0(thebits : TBits_1); inline;
    procedure setTCKPS1(thebits : TBits_1); inline;
    procedure setTCKPS2(thebits : TBits_1); inline;
    procedure setTCS(thebits : TBits_1); inline;
    procedure setTGATE(thebits : TBits_1); inline;
    procedure setTON(thebits : TBits_1); inline;
    procedure setTSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure clearT32; inline;
    procedure clearTCKPS0; inline;
    procedure clearTCKPS1; inline;
    procedure clearTCKPS2; inline;
    procedure clearTCS; inline;
    procedure clearTGATE; inline;
    procedure clearTON; inline;
    procedure clearTSIDL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    procedure setT32; inline;
    procedure setTCKPS0; inline;
    procedure setTCKPS1; inline;
    procedure setTCKPS2; inline;
    procedure setTCS; inline;
    procedure setTGATE; inline;
    procedure setTON; inline;
    procedure setTSIDL; inline;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property T32 : TBits_1 read getT32 write setT32;
    property TCKPS : TBits_3 read getTCKPS write setTCKPS;
    property TCKPS0 : TBits_1 read getTCKPS0 write setTCKPS0;
    property TCKPS1 : TBits_1 read getTCKPS1 write setTCKPS1;
    property TCKPS2 : TBits_1 read getTCKPS2 write setTCKPS2;
    property TCS : TBits_1 read getTCS write setTCS;
    property TGATE : TBits_1 read getTGATE write setTGATE;
    property TON : TBits_1 read getTON write setTON;
    property TSIDL : TBits_1 read getTSIDL write setTSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TTMR4Registers = record
    T4CONbits : TTMR4_T4CON;
    T4CON : longWord;
    T4CONCLR : longWord;
    T4CONSET : longWord;
    T4CONINV : longWord;
    TMR4 : longWord;
    TMR4CLR : longWord;
    TMR4SET : longWord;
    TMR4INV : longWord;
    PR4 : longWord;
    PR4CLR : longWord;
    PR4SET : longWord;
    PR4INV : longWord;
  end;
  TTMR5_T5CON = record
  private
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getTCKPS : TBits_3; inline;
    function  getTCKPS0 : TBits_1; inline;
    function  getTCKPS1 : TBits_1; inline;
    function  getTCKPS2 : TBits_1; inline;
    function  getTCS : TBits_1; inline;
    function  getTGATE : TBits_1; inline;
    function  getTON : TBits_1; inline;
    function  getTSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setTCKPS(thebits : TBits_3); inline;
    procedure setTCKPS0(thebits : TBits_1); inline;
    procedure setTCKPS1(thebits : TBits_1); inline;
    procedure setTCKPS2(thebits : TBits_1); inline;
    procedure setTCS(thebits : TBits_1); inline;
    procedure setTGATE(thebits : TBits_1); inline;
    procedure setTON(thebits : TBits_1); inline;
    procedure setTSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure clearTCKPS0; inline;
    procedure clearTCKPS1; inline;
    procedure clearTCKPS2; inline;
    procedure clearTCS; inline;
    procedure clearTGATE; inline;
    procedure clearTON; inline;
    procedure clearTSIDL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    procedure setTCKPS0; inline;
    procedure setTCKPS1; inline;
    procedure setTCKPS2; inline;
    procedure setTCS; inline;
    procedure setTGATE; inline;
    procedure setTON; inline;
    procedure setTSIDL; inline;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property TCKPS : TBits_3 read getTCKPS write setTCKPS;
    property TCKPS0 : TBits_1 read getTCKPS0 write setTCKPS0;
    property TCKPS1 : TBits_1 read getTCKPS1 write setTCKPS1;
    property TCKPS2 : TBits_1 read getTCKPS2 write setTCKPS2;
    property TCS : TBits_1 read getTCS write setTCS;
    property TGATE : TBits_1 read getTGATE write setTGATE;
    property TON : TBits_1 read getTON write setTON;
    property TSIDL : TBits_1 read getTSIDL write setTSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TTMR5Registers = record
    T5CONbits : TTMR5_T5CON;
    T5CON : longWord;
    T5CONCLR : longWord;
    T5CONSET : longWord;
    T5CONINV : longWord;
    TMR5 : longWord;
    TMR5CLR : longWord;
    TMR5SET : longWord;
    TMR5INV : longWord;
    PR5 : longWord;
    PR5CLR : longWord;
    PR5SET : longWord;
    PR5INV : longWord;
  end;
  TICAP1_IC1CON = record
  private
    function  getC32 : TBits_1; inline;
    function  getFEDGE : TBits_1; inline;
    function  getICBNE : TBits_1; inline;
    function  getICI : TBits_2; inline;
    function  getICI0 : TBits_1; inline;
    function  getICI1 : TBits_1; inline;
    function  getICM : TBits_3; inline;
    function  getICM0 : TBits_1; inline;
    function  getICM1 : TBits_1; inline;
    function  getICM2 : TBits_1; inline;
    function  getICOV : TBits_1; inline;
    function  getICSIDL : TBits_1; inline;
    function  getICTMR : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setC32(thebits : TBits_1); inline;
    procedure setFEDGE(thebits : TBits_1); inline;
    procedure setICBNE(thebits : TBits_1); inline;
    procedure setICI(thebits : TBits_2); inline;
    procedure setICI0(thebits : TBits_1); inline;
    procedure setICI1(thebits : TBits_1); inline;
    procedure setICM(thebits : TBits_3); inline;
    procedure setICM0(thebits : TBits_1); inline;
    procedure setICM1(thebits : TBits_1); inline;
    procedure setICM2(thebits : TBits_1); inline;
    procedure setICOV(thebits : TBits_1); inline;
    procedure setICSIDL(thebits : TBits_1); inline;
    procedure setICTMR(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearC32; inline;
    procedure clearFEDGE; inline;
    procedure clearICBNE; inline;
    procedure clearICI0; inline;
    procedure clearICI1; inline;
    procedure clearICM0; inline;
    procedure clearICM1; inline;
    procedure clearICM2; inline;
    procedure clearICOV; inline;
    procedure clearICSIDL; inline;
    procedure clearICTMR; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setC32; inline;
    procedure setFEDGE; inline;
    procedure setICBNE; inline;
    procedure setICI0; inline;
    procedure setICI1; inline;
    procedure setICM0; inline;
    procedure setICM1; inline;
    procedure setICM2; inline;
    procedure setICOV; inline;
    procedure setICSIDL; inline;
    procedure setICTMR; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property C32 : TBits_1 read getC32 write setC32;
    property FEDGE : TBits_1 read getFEDGE write setFEDGE;
    property ICBNE : TBits_1 read getICBNE write setICBNE;
    property ICI : TBits_2 read getICI write setICI;
    property ICI0 : TBits_1 read getICI0 write setICI0;
    property ICI1 : TBits_1 read getICI1 write setICI1;
    property ICM : TBits_3 read getICM write setICM;
    property ICM0 : TBits_1 read getICM0 write setICM0;
    property ICM1 : TBits_1 read getICM1 write setICM1;
    property ICM2 : TBits_1 read getICM2 write setICM2;
    property ICOV : TBits_1 read getICOV write setICOV;
    property ICSIDL : TBits_1 read getICSIDL write setICSIDL;
    property ICTMR : TBits_1 read getICTMR write setICTMR;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TICAP1Registers = record
    IC1CONbits : TICAP1_IC1CON;
    IC1CON : longWord;
    IC1CONCLR : longWord;
    IC1CONSET : longWord;
    IC1CONINV : longWord;
    IC1BUF : longWord;
  end;
  TICAP2_IC2CON = record
  private
    function  getC32 : TBits_1; inline;
    function  getFEDGE : TBits_1; inline;
    function  getICBNE : TBits_1; inline;
    function  getICI : TBits_2; inline;
    function  getICI0 : TBits_1; inline;
    function  getICI1 : TBits_1; inline;
    function  getICM : TBits_3; inline;
    function  getICM0 : TBits_1; inline;
    function  getICM1 : TBits_1; inline;
    function  getICM2 : TBits_1; inline;
    function  getICOV : TBits_1; inline;
    function  getICSIDL : TBits_1; inline;
    function  getICTMR : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setC32(thebits : TBits_1); inline;
    procedure setFEDGE(thebits : TBits_1); inline;
    procedure setICBNE(thebits : TBits_1); inline;
    procedure setICI(thebits : TBits_2); inline;
    procedure setICI0(thebits : TBits_1); inline;
    procedure setICI1(thebits : TBits_1); inline;
    procedure setICM(thebits : TBits_3); inline;
    procedure setICM0(thebits : TBits_1); inline;
    procedure setICM1(thebits : TBits_1); inline;
    procedure setICM2(thebits : TBits_1); inline;
    procedure setICOV(thebits : TBits_1); inline;
    procedure setICSIDL(thebits : TBits_1); inline;
    procedure setICTMR(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearC32; inline;
    procedure clearFEDGE; inline;
    procedure clearICBNE; inline;
    procedure clearICI0; inline;
    procedure clearICI1; inline;
    procedure clearICM0; inline;
    procedure clearICM1; inline;
    procedure clearICM2; inline;
    procedure clearICOV; inline;
    procedure clearICSIDL; inline;
    procedure clearICTMR; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setC32; inline;
    procedure setFEDGE; inline;
    procedure setICBNE; inline;
    procedure setICI0; inline;
    procedure setICI1; inline;
    procedure setICM0; inline;
    procedure setICM1; inline;
    procedure setICM2; inline;
    procedure setICOV; inline;
    procedure setICSIDL; inline;
    procedure setICTMR; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property C32 : TBits_1 read getC32 write setC32;
    property FEDGE : TBits_1 read getFEDGE write setFEDGE;
    property ICBNE : TBits_1 read getICBNE write setICBNE;
    property ICI : TBits_2 read getICI write setICI;
    property ICI0 : TBits_1 read getICI0 write setICI0;
    property ICI1 : TBits_1 read getICI1 write setICI1;
    property ICM : TBits_3 read getICM write setICM;
    property ICM0 : TBits_1 read getICM0 write setICM0;
    property ICM1 : TBits_1 read getICM1 write setICM1;
    property ICM2 : TBits_1 read getICM2 write setICM2;
    property ICOV : TBits_1 read getICOV write setICOV;
    property ICSIDL : TBits_1 read getICSIDL write setICSIDL;
    property ICTMR : TBits_1 read getICTMR write setICTMR;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TICAP2Registers = record
    IC2CONbits : TICAP2_IC2CON;
    IC2CON : longWord;
    IC2CONCLR : longWord;
    IC2CONSET : longWord;
    IC2CONINV : longWord;
    IC2BUF : longWord;
  end;
  TICAP3_IC3CON = record
  private
    function  getC32 : TBits_1; inline;
    function  getFEDGE : TBits_1; inline;
    function  getICBNE : TBits_1; inline;
    function  getICI : TBits_2; inline;
    function  getICI0 : TBits_1; inline;
    function  getICI1 : TBits_1; inline;
    function  getICM : TBits_3; inline;
    function  getICM0 : TBits_1; inline;
    function  getICM1 : TBits_1; inline;
    function  getICM2 : TBits_1; inline;
    function  getICOV : TBits_1; inline;
    function  getICSIDL : TBits_1; inline;
    function  getICTMR : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setC32(thebits : TBits_1); inline;
    procedure setFEDGE(thebits : TBits_1); inline;
    procedure setICBNE(thebits : TBits_1); inline;
    procedure setICI(thebits : TBits_2); inline;
    procedure setICI0(thebits : TBits_1); inline;
    procedure setICI1(thebits : TBits_1); inline;
    procedure setICM(thebits : TBits_3); inline;
    procedure setICM0(thebits : TBits_1); inline;
    procedure setICM1(thebits : TBits_1); inline;
    procedure setICM2(thebits : TBits_1); inline;
    procedure setICOV(thebits : TBits_1); inline;
    procedure setICSIDL(thebits : TBits_1); inline;
    procedure setICTMR(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearC32; inline;
    procedure clearFEDGE; inline;
    procedure clearICBNE; inline;
    procedure clearICI0; inline;
    procedure clearICI1; inline;
    procedure clearICM0; inline;
    procedure clearICM1; inline;
    procedure clearICM2; inline;
    procedure clearICOV; inline;
    procedure clearICSIDL; inline;
    procedure clearICTMR; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setC32; inline;
    procedure setFEDGE; inline;
    procedure setICBNE; inline;
    procedure setICI0; inline;
    procedure setICI1; inline;
    procedure setICM0; inline;
    procedure setICM1; inline;
    procedure setICM2; inline;
    procedure setICOV; inline;
    procedure setICSIDL; inline;
    procedure setICTMR; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property C32 : TBits_1 read getC32 write setC32;
    property FEDGE : TBits_1 read getFEDGE write setFEDGE;
    property ICBNE : TBits_1 read getICBNE write setICBNE;
    property ICI : TBits_2 read getICI write setICI;
    property ICI0 : TBits_1 read getICI0 write setICI0;
    property ICI1 : TBits_1 read getICI1 write setICI1;
    property ICM : TBits_3 read getICM write setICM;
    property ICM0 : TBits_1 read getICM0 write setICM0;
    property ICM1 : TBits_1 read getICM1 write setICM1;
    property ICM2 : TBits_1 read getICM2 write setICM2;
    property ICOV : TBits_1 read getICOV write setICOV;
    property ICSIDL : TBits_1 read getICSIDL write setICSIDL;
    property ICTMR : TBits_1 read getICTMR write setICTMR;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TICAP3Registers = record
    IC3CONbits : TICAP3_IC3CON;
    IC3CON : longWord;
    IC3CONCLR : longWord;
    IC3CONSET : longWord;
    IC3CONINV : longWord;
    IC3BUF : longWord;
  end;
  TICAP4_IC4CON = record
  private
    function  getC32 : TBits_1; inline;
    function  getFEDGE : TBits_1; inline;
    function  getICBNE : TBits_1; inline;
    function  getICI : TBits_2; inline;
    function  getICI0 : TBits_1; inline;
    function  getICI1 : TBits_1; inline;
    function  getICM : TBits_3; inline;
    function  getICM0 : TBits_1; inline;
    function  getICM1 : TBits_1; inline;
    function  getICM2 : TBits_1; inline;
    function  getICOV : TBits_1; inline;
    function  getICSIDL : TBits_1; inline;
    function  getICTMR : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setC32(thebits : TBits_1); inline;
    procedure setFEDGE(thebits : TBits_1); inline;
    procedure setICBNE(thebits : TBits_1); inline;
    procedure setICI(thebits : TBits_2); inline;
    procedure setICI0(thebits : TBits_1); inline;
    procedure setICI1(thebits : TBits_1); inline;
    procedure setICM(thebits : TBits_3); inline;
    procedure setICM0(thebits : TBits_1); inline;
    procedure setICM1(thebits : TBits_1); inline;
    procedure setICM2(thebits : TBits_1); inline;
    procedure setICOV(thebits : TBits_1); inline;
    procedure setICSIDL(thebits : TBits_1); inline;
    procedure setICTMR(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearC32; inline;
    procedure clearFEDGE; inline;
    procedure clearICBNE; inline;
    procedure clearICI0; inline;
    procedure clearICI1; inline;
    procedure clearICM0; inline;
    procedure clearICM1; inline;
    procedure clearICM2; inline;
    procedure clearICOV; inline;
    procedure clearICSIDL; inline;
    procedure clearICTMR; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setC32; inline;
    procedure setFEDGE; inline;
    procedure setICBNE; inline;
    procedure setICI0; inline;
    procedure setICI1; inline;
    procedure setICM0; inline;
    procedure setICM1; inline;
    procedure setICM2; inline;
    procedure setICOV; inline;
    procedure setICSIDL; inline;
    procedure setICTMR; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property C32 : TBits_1 read getC32 write setC32;
    property FEDGE : TBits_1 read getFEDGE write setFEDGE;
    property ICBNE : TBits_1 read getICBNE write setICBNE;
    property ICI : TBits_2 read getICI write setICI;
    property ICI0 : TBits_1 read getICI0 write setICI0;
    property ICI1 : TBits_1 read getICI1 write setICI1;
    property ICM : TBits_3 read getICM write setICM;
    property ICM0 : TBits_1 read getICM0 write setICM0;
    property ICM1 : TBits_1 read getICM1 write setICM1;
    property ICM2 : TBits_1 read getICM2 write setICM2;
    property ICOV : TBits_1 read getICOV write setICOV;
    property ICSIDL : TBits_1 read getICSIDL write setICSIDL;
    property ICTMR : TBits_1 read getICTMR write setICTMR;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TICAP4Registers = record
    IC4CONbits : TICAP4_IC4CON;
    IC4CON : longWord;
    IC4CONCLR : longWord;
    IC4CONSET : longWord;
    IC4CONINV : longWord;
    IC4BUF : longWord;
  end;
  TICAP5_IC5CON = record
  private
    function  getC32 : TBits_1; inline;
    function  getFEDGE : TBits_1; inline;
    function  getICBNE : TBits_1; inline;
    function  getICI : TBits_2; inline;
    function  getICI0 : TBits_1; inline;
    function  getICI1 : TBits_1; inline;
    function  getICM : TBits_3; inline;
    function  getICM0 : TBits_1; inline;
    function  getICM1 : TBits_1; inline;
    function  getICM2 : TBits_1; inline;
    function  getICOV : TBits_1; inline;
    function  getICSIDL : TBits_1; inline;
    function  getICTMR : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setC32(thebits : TBits_1); inline;
    procedure setFEDGE(thebits : TBits_1); inline;
    procedure setICBNE(thebits : TBits_1); inline;
    procedure setICI(thebits : TBits_2); inline;
    procedure setICI0(thebits : TBits_1); inline;
    procedure setICI1(thebits : TBits_1); inline;
    procedure setICM(thebits : TBits_3); inline;
    procedure setICM0(thebits : TBits_1); inline;
    procedure setICM1(thebits : TBits_1); inline;
    procedure setICM2(thebits : TBits_1); inline;
    procedure setICOV(thebits : TBits_1); inline;
    procedure setICSIDL(thebits : TBits_1); inline;
    procedure setICTMR(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearC32; inline;
    procedure clearFEDGE; inline;
    procedure clearICBNE; inline;
    procedure clearICI0; inline;
    procedure clearICI1; inline;
    procedure clearICM0; inline;
    procedure clearICM1; inline;
    procedure clearICM2; inline;
    procedure clearICOV; inline;
    procedure clearICSIDL; inline;
    procedure clearICTMR; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setC32; inline;
    procedure setFEDGE; inline;
    procedure setICBNE; inline;
    procedure setICI0; inline;
    procedure setICI1; inline;
    procedure setICM0; inline;
    procedure setICM1; inline;
    procedure setICM2; inline;
    procedure setICOV; inline;
    procedure setICSIDL; inline;
    procedure setICTMR; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property C32 : TBits_1 read getC32 write setC32;
    property FEDGE : TBits_1 read getFEDGE write setFEDGE;
    property ICBNE : TBits_1 read getICBNE write setICBNE;
    property ICI : TBits_2 read getICI write setICI;
    property ICI0 : TBits_1 read getICI0 write setICI0;
    property ICI1 : TBits_1 read getICI1 write setICI1;
    property ICM : TBits_3 read getICM write setICM;
    property ICM0 : TBits_1 read getICM0 write setICM0;
    property ICM1 : TBits_1 read getICM1 write setICM1;
    property ICM2 : TBits_1 read getICM2 write setICM2;
    property ICOV : TBits_1 read getICOV write setICOV;
    property ICSIDL : TBits_1 read getICSIDL write setICSIDL;
    property ICTMR : TBits_1 read getICTMR write setICTMR;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TICAP5Registers = record
    IC5CONbits : TICAP5_IC5CON;
    IC5CON : longWord;
    IC5CONCLR : longWord;
    IC5CONSET : longWord;
    IC5CONINV : longWord;
    IC5BUF : longWord;
  end;
  TOCMP1_OC1CON = record
  private
    function  getOC32 : TBits_1; inline;
    function  getOCFLT : TBits_1; inline;
    function  getOCM : TBits_3; inline;
    function  getOCM0 : TBits_1; inline;
    function  getOCM1 : TBits_1; inline;
    function  getOCM2 : TBits_1; inline;
    function  getOCSIDL : TBits_1; inline;
    function  getOCTSEL : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setOC32(thebits : TBits_1); inline;
    procedure setOCFLT(thebits : TBits_1); inline;
    procedure setOCM(thebits : TBits_3); inline;
    procedure setOCM0(thebits : TBits_1); inline;
    procedure setOCM1(thebits : TBits_1); inline;
    procedure setOCM2(thebits : TBits_1); inline;
    procedure setOCSIDL(thebits : TBits_1); inline;
    procedure setOCTSEL(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearOC32; inline;
    procedure clearOCFLT; inline;
    procedure clearOCM0; inline;
    procedure clearOCM1; inline;
    procedure clearOCM2; inline;
    procedure clearOCSIDL; inline;
    procedure clearOCTSEL; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setOC32; inline;
    procedure setOCFLT; inline;
    procedure setOCM0; inline;
    procedure setOCM1; inline;
    procedure setOCM2; inline;
    procedure setOCSIDL; inline;
    procedure setOCTSEL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property OC32 : TBits_1 read getOC32 write setOC32;
    property OCFLT : TBits_1 read getOCFLT write setOCFLT;
    property OCM : TBits_3 read getOCM write setOCM;
    property OCM0 : TBits_1 read getOCM0 write setOCM0;
    property OCM1 : TBits_1 read getOCM1 write setOCM1;
    property OCM2 : TBits_1 read getOCM2 write setOCM2;
    property OCSIDL : TBits_1 read getOCSIDL write setOCSIDL;
    property OCTSEL : TBits_1 read getOCTSEL write setOCTSEL;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TOCMP1Registers = record
    OC1CONbits : TOCMP1_OC1CON;
    OC1CON : longWord;
    OC1CONCLR : longWord;
    OC1CONSET : longWord;
    OC1CONINV : longWord;
    OC1R : longWord;
    OC1RCLR : longWord;
    OC1RSET : longWord;
    OC1RINV : longWord;
    OC1RS : longWord;
    OC1RSCLR : longWord;
    OC1RSSET : longWord;
    OC1RSINV : longWord;
  end;
  TOCMP2_OC2CON = record
  private
    function  getOC32 : TBits_1; inline;
    function  getOCFLT : TBits_1; inline;
    function  getOCM : TBits_3; inline;
    function  getOCM0 : TBits_1; inline;
    function  getOCM1 : TBits_1; inline;
    function  getOCM2 : TBits_1; inline;
    function  getOCSIDL : TBits_1; inline;
    function  getOCTSEL : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setOC32(thebits : TBits_1); inline;
    procedure setOCFLT(thebits : TBits_1); inline;
    procedure setOCM(thebits : TBits_3); inline;
    procedure setOCM0(thebits : TBits_1); inline;
    procedure setOCM1(thebits : TBits_1); inline;
    procedure setOCM2(thebits : TBits_1); inline;
    procedure setOCSIDL(thebits : TBits_1); inline;
    procedure setOCTSEL(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearOC32; inline;
    procedure clearOCFLT; inline;
    procedure clearOCM0; inline;
    procedure clearOCM1; inline;
    procedure clearOCM2; inline;
    procedure clearOCSIDL; inline;
    procedure clearOCTSEL; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setOC32; inline;
    procedure setOCFLT; inline;
    procedure setOCM0; inline;
    procedure setOCM1; inline;
    procedure setOCM2; inline;
    procedure setOCSIDL; inline;
    procedure setOCTSEL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property OC32 : TBits_1 read getOC32 write setOC32;
    property OCFLT : TBits_1 read getOCFLT write setOCFLT;
    property OCM : TBits_3 read getOCM write setOCM;
    property OCM0 : TBits_1 read getOCM0 write setOCM0;
    property OCM1 : TBits_1 read getOCM1 write setOCM1;
    property OCM2 : TBits_1 read getOCM2 write setOCM2;
    property OCSIDL : TBits_1 read getOCSIDL write setOCSIDL;
    property OCTSEL : TBits_1 read getOCTSEL write setOCTSEL;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TOCMP2Registers = record
    OC2CONbits : TOCMP2_OC2CON;
    OC2CON : longWord;
    OC2CONCLR : longWord;
    OC2CONSET : longWord;
    OC2CONINV : longWord;
    OC2R : longWord;
    OC2RCLR : longWord;
    OC2RSET : longWord;
    OC2RINV : longWord;
    OC2RS : longWord;
    OC2RSCLR : longWord;
    OC2RSSET : longWord;
    OC2RSINV : longWord;
  end;
  TOCMP3_OC3CON = record
  private
    function  getOC32 : TBits_1; inline;
    function  getOCFLT : TBits_1; inline;
    function  getOCM : TBits_3; inline;
    function  getOCM0 : TBits_1; inline;
    function  getOCM1 : TBits_1; inline;
    function  getOCM2 : TBits_1; inline;
    function  getOCSIDL : TBits_1; inline;
    function  getOCTSEL : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setOC32(thebits : TBits_1); inline;
    procedure setOCFLT(thebits : TBits_1); inline;
    procedure setOCM(thebits : TBits_3); inline;
    procedure setOCM0(thebits : TBits_1); inline;
    procedure setOCM1(thebits : TBits_1); inline;
    procedure setOCM2(thebits : TBits_1); inline;
    procedure setOCSIDL(thebits : TBits_1); inline;
    procedure setOCTSEL(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearOC32; inline;
    procedure clearOCFLT; inline;
    procedure clearOCM0; inline;
    procedure clearOCM1; inline;
    procedure clearOCM2; inline;
    procedure clearOCSIDL; inline;
    procedure clearOCTSEL; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setOC32; inline;
    procedure setOCFLT; inline;
    procedure setOCM0; inline;
    procedure setOCM1; inline;
    procedure setOCM2; inline;
    procedure setOCSIDL; inline;
    procedure setOCTSEL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property OC32 : TBits_1 read getOC32 write setOC32;
    property OCFLT : TBits_1 read getOCFLT write setOCFLT;
    property OCM : TBits_3 read getOCM write setOCM;
    property OCM0 : TBits_1 read getOCM0 write setOCM0;
    property OCM1 : TBits_1 read getOCM1 write setOCM1;
    property OCM2 : TBits_1 read getOCM2 write setOCM2;
    property OCSIDL : TBits_1 read getOCSIDL write setOCSIDL;
    property OCTSEL : TBits_1 read getOCTSEL write setOCTSEL;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TOCMP3Registers = record
    OC3CONbits : TOCMP3_OC3CON;
    OC3CON : longWord;
    OC3CONCLR : longWord;
    OC3CONSET : longWord;
    OC3CONINV : longWord;
    OC3R : longWord;
    OC3RCLR : longWord;
    OC3RSET : longWord;
    OC3RINV : longWord;
    OC3RS : longWord;
    OC3RSCLR : longWord;
    OC3RSSET : longWord;
    OC3RSINV : longWord;
  end;
  TOCMP4_OC4CON = record
  private
    function  getOC32 : TBits_1; inline;
    function  getOCFLT : TBits_1; inline;
    function  getOCM : TBits_3; inline;
    function  getOCM0 : TBits_1; inline;
    function  getOCM1 : TBits_1; inline;
    function  getOCM2 : TBits_1; inline;
    function  getOCSIDL : TBits_1; inline;
    function  getOCTSEL : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setOC32(thebits : TBits_1); inline;
    procedure setOCFLT(thebits : TBits_1); inline;
    procedure setOCM(thebits : TBits_3); inline;
    procedure setOCM0(thebits : TBits_1); inline;
    procedure setOCM1(thebits : TBits_1); inline;
    procedure setOCM2(thebits : TBits_1); inline;
    procedure setOCSIDL(thebits : TBits_1); inline;
    procedure setOCTSEL(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearOC32; inline;
    procedure clearOCFLT; inline;
    procedure clearOCM0; inline;
    procedure clearOCM1; inline;
    procedure clearOCM2; inline;
    procedure clearOCSIDL; inline;
    procedure clearOCTSEL; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setOC32; inline;
    procedure setOCFLT; inline;
    procedure setOCM0; inline;
    procedure setOCM1; inline;
    procedure setOCM2; inline;
    procedure setOCSIDL; inline;
    procedure setOCTSEL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property OC32 : TBits_1 read getOC32 write setOC32;
    property OCFLT : TBits_1 read getOCFLT write setOCFLT;
    property OCM : TBits_3 read getOCM write setOCM;
    property OCM0 : TBits_1 read getOCM0 write setOCM0;
    property OCM1 : TBits_1 read getOCM1 write setOCM1;
    property OCM2 : TBits_1 read getOCM2 write setOCM2;
    property OCSIDL : TBits_1 read getOCSIDL write setOCSIDL;
    property OCTSEL : TBits_1 read getOCTSEL write setOCTSEL;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TOCMP4Registers = record
    OC4CONbits : TOCMP4_OC4CON;
    OC4CON : longWord;
    OC4CONCLR : longWord;
    OC4CONSET : longWord;
    OC4CONINV : longWord;
    OC4R : longWord;
    OC4RCLR : longWord;
    OC4RSET : longWord;
    OC4RINV : longWord;
    OC4RS : longWord;
    OC4RSCLR : longWord;
    OC4RSSET : longWord;
    OC4RSINV : longWord;
  end;
  TOCMP5_OC5CON = record
  private
    function  getOC32 : TBits_1; inline;
    function  getOCFLT : TBits_1; inline;
    function  getOCM : TBits_3; inline;
    function  getOCM0 : TBits_1; inline;
    function  getOCM1 : TBits_1; inline;
    function  getOCM2 : TBits_1; inline;
    function  getOCSIDL : TBits_1; inline;
    function  getOCTSEL : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setOC32(thebits : TBits_1); inline;
    procedure setOCFLT(thebits : TBits_1); inline;
    procedure setOCM(thebits : TBits_3); inline;
    procedure setOCM0(thebits : TBits_1); inline;
    procedure setOCM1(thebits : TBits_1); inline;
    procedure setOCM2(thebits : TBits_1); inline;
    procedure setOCSIDL(thebits : TBits_1); inline;
    procedure setOCTSEL(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearOC32; inline;
    procedure clearOCFLT; inline;
    procedure clearOCM0; inline;
    procedure clearOCM1; inline;
    procedure clearOCM2; inline;
    procedure clearOCSIDL; inline;
    procedure clearOCTSEL; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setOC32; inline;
    procedure setOCFLT; inline;
    procedure setOCM0; inline;
    procedure setOCM1; inline;
    procedure setOCM2; inline;
    procedure setOCSIDL; inline;
    procedure setOCTSEL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property OC32 : TBits_1 read getOC32 write setOC32;
    property OCFLT : TBits_1 read getOCFLT write setOCFLT;
    property OCM : TBits_3 read getOCM write setOCM;
    property OCM0 : TBits_1 read getOCM0 write setOCM0;
    property OCM1 : TBits_1 read getOCM1 write setOCM1;
    property OCM2 : TBits_1 read getOCM2 write setOCM2;
    property OCSIDL : TBits_1 read getOCSIDL write setOCSIDL;
    property OCTSEL : TBits_1 read getOCTSEL write setOCTSEL;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TOCMP5Registers = record
    OC5CONbits : TOCMP5_OC5CON;
    OC5CON : longWord;
    OC5CONCLR : longWord;
    OC5CONSET : longWord;
    OC5CONINV : longWord;
    OC5R : longWord;
    OC5RCLR : longWord;
    OC5RSET : longWord;
    OC5RINV : longWord;
    OC5RS : longWord;
    OC5RSCLR : longWord;
    OC5RSSET : longWord;
    OC5RSINV : longWord;
  end;
  TI2C1_I2C1CON = record
  private
    function  getA10M : TBits_1; inline;
    function  getACKDT : TBits_1; inline;
    function  getACKEN : TBits_1; inline;
    function  getDISSLW : TBits_1; inline;
    function  getGCEN : TBits_1; inline;
    function  getI2CEN : TBits_1; inline;
    function  getI2CSIDL : TBits_1; inline;
    function  getIPMIEN : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getPEN : TBits_1; inline;
    function  getRCEN : TBits_1; inline;
    function  getRSEN : TBits_1; inline;
    function  getSCLREL : TBits_1; inline;
    function  getSEN : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getSMEN : TBits_1; inline;
    function  getSTREN : TBits_1; inline;
    function  getSTRICT : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setA10M(thebits : TBits_1); inline;
    procedure setACKDT(thebits : TBits_1); inline;
    procedure setACKEN(thebits : TBits_1); inline;
    procedure setDISSLW(thebits : TBits_1); inline;
    procedure setGCEN(thebits : TBits_1); inline;
    procedure setI2CEN(thebits : TBits_1); inline;
    procedure setI2CSIDL(thebits : TBits_1); inline;
    procedure setIPMIEN(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setPEN(thebits : TBits_1); inline;
    procedure setRCEN(thebits : TBits_1); inline;
    procedure setRSEN(thebits : TBits_1); inline;
    procedure setSCLREL(thebits : TBits_1); inline;
    procedure setSEN(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setSMEN(thebits : TBits_1); inline;
    procedure setSTREN(thebits : TBits_1); inline;
    procedure setSTRICT(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearA10M; inline;
    procedure clearACKDT; inline;
    procedure clearACKEN; inline;
    procedure clearDISSLW; inline;
    procedure clearGCEN; inline;
    procedure clearI2CEN; inline;
    procedure clearI2CSIDL; inline;
    procedure clearIPMIEN; inline;
    procedure clearON; inline;
    procedure clearPEN; inline;
    procedure clearRCEN; inline;
    procedure clearRSEN; inline;
    procedure clearSCLREL; inline;
    procedure clearSEN; inline;
    procedure clearSIDL; inline;
    procedure clearSMEN; inline;
    procedure clearSTREN; inline;
    procedure clearSTRICT; inline;
    procedure setA10M; inline;
    procedure setACKDT; inline;
    procedure setACKEN; inline;
    procedure setDISSLW; inline;
    procedure setGCEN; inline;
    procedure setI2CEN; inline;
    procedure setI2CSIDL; inline;
    procedure setIPMIEN; inline;
    procedure setON; inline;
    procedure setPEN; inline;
    procedure setRCEN; inline;
    procedure setRSEN; inline;
    procedure setSCLREL; inline;
    procedure setSEN; inline;
    procedure setSIDL; inline;
    procedure setSMEN; inline;
    procedure setSTREN; inline;
    procedure setSTRICT; inline;
    property A10M : TBits_1 read getA10M write setA10M;
    property ACKDT : TBits_1 read getACKDT write setACKDT;
    property ACKEN : TBits_1 read getACKEN write setACKEN;
    property DISSLW : TBits_1 read getDISSLW write setDISSLW;
    property GCEN : TBits_1 read getGCEN write setGCEN;
    property I2CEN : TBits_1 read getI2CEN write setI2CEN;
    property I2CSIDL : TBits_1 read getI2CSIDL write setI2CSIDL;
    property IPMIEN : TBits_1 read getIPMIEN write setIPMIEN;
    property ON : TBits_1 read getON write setON;
    property PEN : TBits_1 read getPEN write setPEN;
    property RCEN : TBits_1 read getRCEN write setRCEN;
    property RSEN : TBits_1 read getRSEN write setRSEN;
    property SCLREL : TBits_1 read getSCLREL write setSCLREL;
    property SEN : TBits_1 read getSEN write setSEN;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property SMEN : TBits_1 read getSMEN write setSMEN;
    property STREN : TBits_1 read getSTREN write setSTREN;
    property STRICT : TBits_1 read getSTRICT write setSTRICT;
    property w : TBits_32 read getw write setw;
  end;
  TI2C1_I2C1STAT = record
  private
    function  getACKSTAT : TBits_1; inline;
    function  getADD10 : TBits_1; inline;
    function  getBCL : TBits_1; inline;
    function  getD_A : TBits_1; inline;
    function  getGCSTAT : TBits_1; inline;
    function  getI2COV : TBits_1; inline;
    function  getI2CPOV : TBits_1; inline;
    function  getIWCOL : TBits_1; inline;
    function  getP : TBits_1; inline;
    function  getRBF : TBits_1; inline;
    function  getR_W : TBits_1; inline;
    function  getS : TBits_1; inline;
    function  getTBF : TBits_1; inline;
    function  getTRSTAT : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setACKSTAT(thebits : TBits_1); inline;
    procedure setADD10(thebits : TBits_1); inline;
    procedure setBCL(thebits : TBits_1); inline;
    procedure setD_A(thebits : TBits_1); inline;
    procedure setGCSTAT(thebits : TBits_1); inline;
    procedure setI2COV(thebits : TBits_1); inline;
    procedure setI2CPOV(thebits : TBits_1); inline;
    procedure setIWCOL(thebits : TBits_1); inline;
    procedure setP(thebits : TBits_1); inline;
    procedure setRBF(thebits : TBits_1); inline;
    procedure setR_W(thebits : TBits_1); inline;
    procedure setS(thebits : TBits_1); inline;
    procedure setTBF(thebits : TBits_1); inline;
    procedure setTRSTAT(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearACKSTAT; inline;
    procedure clearADD10; inline;
    procedure clearBCL; inline;
    procedure clearD_A; inline;
    procedure clearGCSTAT; inline;
    procedure clearI2COV; inline;
    procedure clearI2CPOV; inline;
    procedure clearIWCOL; inline;
    procedure clearP; inline;
    procedure clearRBF; inline;
    procedure clearR_W; inline;
    procedure clearS; inline;
    procedure clearTBF; inline;
    procedure clearTRSTAT; inline;
    procedure setACKSTAT; inline;
    procedure setADD10; inline;
    procedure setBCL; inline;
    procedure setD_A; inline;
    procedure setGCSTAT; inline;
    procedure setI2COV; inline;
    procedure setI2CPOV; inline;
    procedure setIWCOL; inline;
    procedure setP; inline;
    procedure setRBF; inline;
    procedure setR_W; inline;
    procedure setS; inline;
    procedure setTBF; inline;
    procedure setTRSTAT; inline;
    property ACKSTAT : TBits_1 read getACKSTAT write setACKSTAT;
    property ADD10 : TBits_1 read getADD10 write setADD10;
    property BCL : TBits_1 read getBCL write setBCL;
    property D_A : TBits_1 read getD_A write setD_A;
    property GCSTAT : TBits_1 read getGCSTAT write setGCSTAT;
    property I2COV : TBits_1 read getI2COV write setI2COV;
    property I2CPOV : TBits_1 read getI2CPOV write setI2CPOV;
    property IWCOL : TBits_1 read getIWCOL write setIWCOL;
    property P : TBits_1 read getP write setP;
    property RBF : TBits_1 read getRBF write setRBF;
    property R_W : TBits_1 read getR_W write setR_W;
    property S : TBits_1 read getS write setS;
    property TBF : TBits_1 read getTBF write setTBF;
    property TRSTAT : TBits_1 read getTRSTAT write setTRSTAT;
    property w : TBits_32 read getw write setw;
  end;
type
  TI2C1Registers = record
    I2C1CONbits : TI2C1_I2C1CON;
    I2C1CON : longWord;
    I2C1CONCLR : longWord;
    I2C1CONSET : longWord;
    I2C1CONINV : longWord;
    I2C1STATbits : TI2C1_I2C1STAT;
    I2C1STAT : longWord;
    I2C1STATCLR : longWord;
    I2C1STATSET : longWord;
    I2C1STATINV : longWord;
    I2C1ADD : longWord;
    I2C1ADDCLR : longWord;
    I2C1ADDSET : longWord;
    I2C1ADDINV : longWord;
    I2C1MSK : longWord;
    I2C1MSKCLR : longWord;
    I2C1MSKSET : longWord;
    I2C1MSKINV : longWord;
    I2C1BRG : longWord;
    I2C1BRGCLR : longWord;
    I2C1BRGSET : longWord;
    I2C1BRGINV : longWord;
    I2C1TRN : longWord;
    I2C1TRNCLR : longWord;
    I2C1TRNSET : longWord;
    I2C1TRNINV : longWord;
    I2C1RCV : longWord;
  end;
  TI2C2_I2C2CON = record
  private
    function  getA10M : TBits_1; inline;
    function  getACKDT : TBits_1; inline;
    function  getACKEN : TBits_1; inline;
    function  getDISSLW : TBits_1; inline;
    function  getGCEN : TBits_1; inline;
    function  getI2CEN : TBits_1; inline;
    function  getI2CSIDL : TBits_1; inline;
    function  getIPMIEN : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getPEN : TBits_1; inline;
    function  getRCEN : TBits_1; inline;
    function  getRSEN : TBits_1; inline;
    function  getSCLREL : TBits_1; inline;
    function  getSEN : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getSMEN : TBits_1; inline;
    function  getSTREN : TBits_1; inline;
    function  getSTRICT : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setA10M(thebits : TBits_1); inline;
    procedure setACKDT(thebits : TBits_1); inline;
    procedure setACKEN(thebits : TBits_1); inline;
    procedure setDISSLW(thebits : TBits_1); inline;
    procedure setGCEN(thebits : TBits_1); inline;
    procedure setI2CEN(thebits : TBits_1); inline;
    procedure setI2CSIDL(thebits : TBits_1); inline;
    procedure setIPMIEN(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setPEN(thebits : TBits_1); inline;
    procedure setRCEN(thebits : TBits_1); inline;
    procedure setRSEN(thebits : TBits_1); inline;
    procedure setSCLREL(thebits : TBits_1); inline;
    procedure setSEN(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setSMEN(thebits : TBits_1); inline;
    procedure setSTREN(thebits : TBits_1); inline;
    procedure setSTRICT(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearA10M; inline;
    procedure clearACKDT; inline;
    procedure clearACKEN; inline;
    procedure clearDISSLW; inline;
    procedure clearGCEN; inline;
    procedure clearI2CEN; inline;
    procedure clearI2CSIDL; inline;
    procedure clearIPMIEN; inline;
    procedure clearON; inline;
    procedure clearPEN; inline;
    procedure clearRCEN; inline;
    procedure clearRSEN; inline;
    procedure clearSCLREL; inline;
    procedure clearSEN; inline;
    procedure clearSIDL; inline;
    procedure clearSMEN; inline;
    procedure clearSTREN; inline;
    procedure clearSTRICT; inline;
    procedure setA10M; inline;
    procedure setACKDT; inline;
    procedure setACKEN; inline;
    procedure setDISSLW; inline;
    procedure setGCEN; inline;
    procedure setI2CEN; inline;
    procedure setI2CSIDL; inline;
    procedure setIPMIEN; inline;
    procedure setON; inline;
    procedure setPEN; inline;
    procedure setRCEN; inline;
    procedure setRSEN; inline;
    procedure setSCLREL; inline;
    procedure setSEN; inline;
    procedure setSIDL; inline;
    procedure setSMEN; inline;
    procedure setSTREN; inline;
    procedure setSTRICT; inline;
    property A10M : TBits_1 read getA10M write setA10M;
    property ACKDT : TBits_1 read getACKDT write setACKDT;
    property ACKEN : TBits_1 read getACKEN write setACKEN;
    property DISSLW : TBits_1 read getDISSLW write setDISSLW;
    property GCEN : TBits_1 read getGCEN write setGCEN;
    property I2CEN : TBits_1 read getI2CEN write setI2CEN;
    property I2CSIDL : TBits_1 read getI2CSIDL write setI2CSIDL;
    property IPMIEN : TBits_1 read getIPMIEN write setIPMIEN;
    property ON : TBits_1 read getON write setON;
    property PEN : TBits_1 read getPEN write setPEN;
    property RCEN : TBits_1 read getRCEN write setRCEN;
    property RSEN : TBits_1 read getRSEN write setRSEN;
    property SCLREL : TBits_1 read getSCLREL write setSCLREL;
    property SEN : TBits_1 read getSEN write setSEN;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property SMEN : TBits_1 read getSMEN write setSMEN;
    property STREN : TBits_1 read getSTREN write setSTREN;
    property STRICT : TBits_1 read getSTRICT write setSTRICT;
    property w : TBits_32 read getw write setw;
  end;
  TI2C2_I2C2STAT = record
  private
    function  getACKSTAT : TBits_1; inline;
    function  getADD10 : TBits_1; inline;
    function  getBCL : TBits_1; inline;
    function  getD_A : TBits_1; inline;
    function  getGCSTAT : TBits_1; inline;
    function  getI2COV : TBits_1; inline;
    function  getI2CPOV : TBits_1; inline;
    function  getIWCOL : TBits_1; inline;
    function  getP : TBits_1; inline;
    function  getRBF : TBits_1; inline;
    function  getR_W : TBits_1; inline;
    function  getS : TBits_1; inline;
    function  getTBF : TBits_1; inline;
    function  getTRSTAT : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setACKSTAT(thebits : TBits_1); inline;
    procedure setADD10(thebits : TBits_1); inline;
    procedure setBCL(thebits : TBits_1); inline;
    procedure setD_A(thebits : TBits_1); inline;
    procedure setGCSTAT(thebits : TBits_1); inline;
    procedure setI2COV(thebits : TBits_1); inline;
    procedure setI2CPOV(thebits : TBits_1); inline;
    procedure setIWCOL(thebits : TBits_1); inline;
    procedure setP(thebits : TBits_1); inline;
    procedure setRBF(thebits : TBits_1); inline;
    procedure setR_W(thebits : TBits_1); inline;
    procedure setS(thebits : TBits_1); inline;
    procedure setTBF(thebits : TBits_1); inline;
    procedure setTRSTAT(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearACKSTAT; inline;
    procedure clearADD10; inline;
    procedure clearBCL; inline;
    procedure clearD_A; inline;
    procedure clearGCSTAT; inline;
    procedure clearI2COV; inline;
    procedure clearI2CPOV; inline;
    procedure clearIWCOL; inline;
    procedure clearP; inline;
    procedure clearRBF; inline;
    procedure clearR_W; inline;
    procedure clearS; inline;
    procedure clearTBF; inline;
    procedure clearTRSTAT; inline;
    procedure setACKSTAT; inline;
    procedure setADD10; inline;
    procedure setBCL; inline;
    procedure setD_A; inline;
    procedure setGCSTAT; inline;
    procedure setI2COV; inline;
    procedure setI2CPOV; inline;
    procedure setIWCOL; inline;
    procedure setP; inline;
    procedure setRBF; inline;
    procedure setR_W; inline;
    procedure setS; inline;
    procedure setTBF; inline;
    procedure setTRSTAT; inline;
    property ACKSTAT : TBits_1 read getACKSTAT write setACKSTAT;
    property ADD10 : TBits_1 read getADD10 write setADD10;
    property BCL : TBits_1 read getBCL write setBCL;
    property D_A : TBits_1 read getD_A write setD_A;
    property GCSTAT : TBits_1 read getGCSTAT write setGCSTAT;
    property I2COV : TBits_1 read getI2COV write setI2COV;
    property I2CPOV : TBits_1 read getI2CPOV write setI2CPOV;
    property IWCOL : TBits_1 read getIWCOL write setIWCOL;
    property P : TBits_1 read getP write setP;
    property RBF : TBits_1 read getRBF write setRBF;
    property R_W : TBits_1 read getR_W write setR_W;
    property S : TBits_1 read getS write setS;
    property TBF : TBits_1 read getTBF write setTBF;
    property TRSTAT : TBits_1 read getTRSTAT write setTRSTAT;
    property w : TBits_32 read getw write setw;
  end;
type
  TI2C2Registers = record
    I2C2CONbits : TI2C2_I2C2CON;
    I2C2CON : longWord;
    I2C2CONCLR : longWord;
    I2C2CONSET : longWord;
    I2C2CONINV : longWord;
    I2C2STATbits : TI2C2_I2C2STAT;
    I2C2STAT : longWord;
    I2C2STATCLR : longWord;
    I2C2STATSET : longWord;
    I2C2STATINV : longWord;
    I2C2ADD : longWord;
    I2C2ADDCLR : longWord;
    I2C2ADDSET : longWord;
    I2C2ADDINV : longWord;
    I2C2MSK : longWord;
    I2C2MSKCLR : longWord;
    I2C2MSKSET : longWord;
    I2C2MSKINV : longWord;
    I2C2BRG : longWord;
    I2C2BRGCLR : longWord;
    I2C2BRGSET : longWord;
    I2C2BRGINV : longWord;
    I2C2TRN : longWord;
    I2C2TRNCLR : longWord;
    I2C2TRNSET : longWord;
    I2C2TRNINV : longWord;
    I2C2RCV : longWord;
  end;
  TSPI1_SPI1CON = record
  private
    function  getCKE : TBits_1; inline;
    function  getCKP : TBits_1; inline;
    function  getDISSDO : TBits_1; inline;
    function  getFRMEN : TBits_1; inline;
    function  getFRMPOL : TBits_1; inline;
    function  getFRMSYNC : TBits_1; inline;
    function  getMODE16 : TBits_1; inline;
    function  getMODE32 : TBits_1; inline;
    function  getMSTEN : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getSMP : TBits_1; inline;
    function  getSPIFE : TBits_1; inline;
    function  getSSEN : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCKE(thebits : TBits_1); inline;
    procedure setCKP(thebits : TBits_1); inline;
    procedure setDISSDO(thebits : TBits_1); inline;
    procedure setFRMEN(thebits : TBits_1); inline;
    procedure setFRMPOL(thebits : TBits_1); inline;
    procedure setFRMSYNC(thebits : TBits_1); inline;
    procedure setMODE16(thebits : TBits_1); inline;
    procedure setMODE32(thebits : TBits_1); inline;
    procedure setMSTEN(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setSMP(thebits : TBits_1); inline;
    procedure setSPIFE(thebits : TBits_1); inline;
    procedure setSSEN(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCKE; inline;
    procedure clearCKP; inline;
    procedure clearDISSDO; inline;
    procedure clearFRMEN; inline;
    procedure clearFRMPOL; inline;
    procedure clearFRMSYNC; inline;
    procedure clearMODE16; inline;
    procedure clearMODE32; inline;
    procedure clearMSTEN; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure clearSMP; inline;
    procedure clearSPIFE; inline;
    procedure clearSSEN; inline;
    procedure setCKE; inline;
    procedure setCKP; inline;
    procedure setDISSDO; inline;
    procedure setFRMEN; inline;
    procedure setFRMPOL; inline;
    procedure setFRMSYNC; inline;
    procedure setMODE16; inline;
    procedure setMODE32; inline;
    procedure setMSTEN; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    procedure setSMP; inline;
    procedure setSPIFE; inline;
    procedure setSSEN; inline;
    property CKE : TBits_1 read getCKE write setCKE;
    property CKP : TBits_1 read getCKP write setCKP;
    property DISSDO : TBits_1 read getDISSDO write setDISSDO;
    property FRMEN : TBits_1 read getFRMEN write setFRMEN;
    property FRMPOL : TBits_1 read getFRMPOL write setFRMPOL;
    property FRMSYNC : TBits_1 read getFRMSYNC write setFRMSYNC;
    property MODE16 : TBits_1 read getMODE16 write setMODE16;
    property MODE32 : TBits_1 read getMODE32 write setMODE32;
    property MSTEN : TBits_1 read getMSTEN write setMSTEN;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property SMP : TBits_1 read getSMP write setSMP;
    property SPIFE : TBits_1 read getSPIFE write setSPIFE;
    property SSEN : TBits_1 read getSSEN write setSSEN;
    property w : TBits_32 read getw write setw;
  end;
  TSPI1_SPI1STAT = record
  private
    function  getSPIBUSY : TBits_1; inline;
    function  getSPIRBF : TBits_1; inline;
    function  getSPIROV : TBits_1; inline;
    function  getSPITBE : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setSPIBUSY(thebits : TBits_1); inline;
    procedure setSPIRBF(thebits : TBits_1); inline;
    procedure setSPIROV(thebits : TBits_1); inline;
    procedure setSPITBE(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearSPIBUSY; inline;
    procedure clearSPIRBF; inline;
    procedure clearSPIROV; inline;
    procedure clearSPITBE; inline;
    procedure setSPIBUSY; inline;
    procedure setSPIRBF; inline;
    procedure setSPIROV; inline;
    procedure setSPITBE; inline;
    property SPIBUSY : TBits_1 read getSPIBUSY write setSPIBUSY;
    property SPIRBF : TBits_1 read getSPIRBF write setSPIRBF;
    property SPIROV : TBits_1 read getSPIROV write setSPIROV;
    property SPITBE : TBits_1 read getSPITBE write setSPITBE;
    property w : TBits_32 read getw write setw;
  end;
type
  TSPI1Registers = record
    SPI1CONbits : TSPI1_SPI1CON;
    SPI1CON : longWord;
    SPI1CONCLR : longWord;
    SPI1CONSET : longWord;
    SPI1CONINV : longWord;
    SPI1STATbits : TSPI1_SPI1STAT;
    SPI1STAT : longWord;
    SPI1STATCLR : longWord;
    SPI1STATSET : longWord;
    SPI1STATINV : longWord;
    SPI1BUF : longWord;
    SPI1BRG : longWord;
    SPI1BRGCLR : longWord;
    SPI1BRGSET : longWord;
    SPI1BRGINV : longWord;
  end;
  TSPI2_SPI2CON = record
  private
    function  getCKE : TBits_1; inline;
    function  getCKP : TBits_1; inline;
    function  getDISSDO : TBits_1; inline;
    function  getFRMEN : TBits_1; inline;
    function  getFRMPOL : TBits_1; inline;
    function  getFRMSYNC : TBits_1; inline;
    function  getMODE16 : TBits_1; inline;
    function  getMODE32 : TBits_1; inline;
    function  getMSTEN : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getSMP : TBits_1; inline;
    function  getSPIFE : TBits_1; inline;
    function  getSSEN : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCKE(thebits : TBits_1); inline;
    procedure setCKP(thebits : TBits_1); inline;
    procedure setDISSDO(thebits : TBits_1); inline;
    procedure setFRMEN(thebits : TBits_1); inline;
    procedure setFRMPOL(thebits : TBits_1); inline;
    procedure setFRMSYNC(thebits : TBits_1); inline;
    procedure setMODE16(thebits : TBits_1); inline;
    procedure setMODE32(thebits : TBits_1); inline;
    procedure setMSTEN(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setSMP(thebits : TBits_1); inline;
    procedure setSPIFE(thebits : TBits_1); inline;
    procedure setSSEN(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCKE; inline;
    procedure clearCKP; inline;
    procedure clearDISSDO; inline;
    procedure clearFRMEN; inline;
    procedure clearFRMPOL; inline;
    procedure clearFRMSYNC; inline;
    procedure clearMODE16; inline;
    procedure clearMODE32; inline;
    procedure clearMSTEN; inline;
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure clearSMP; inline;
    procedure clearSPIFE; inline;
    procedure clearSSEN; inline;
    procedure setCKE; inline;
    procedure setCKP; inline;
    procedure setDISSDO; inline;
    procedure setFRMEN; inline;
    procedure setFRMPOL; inline;
    procedure setFRMSYNC; inline;
    procedure setMODE16; inline;
    procedure setMODE32; inline;
    procedure setMSTEN; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    procedure setSMP; inline;
    procedure setSPIFE; inline;
    procedure setSSEN; inline;
    property CKE : TBits_1 read getCKE write setCKE;
    property CKP : TBits_1 read getCKP write setCKP;
    property DISSDO : TBits_1 read getDISSDO write setDISSDO;
    property FRMEN : TBits_1 read getFRMEN write setFRMEN;
    property FRMPOL : TBits_1 read getFRMPOL write setFRMPOL;
    property FRMSYNC : TBits_1 read getFRMSYNC write setFRMSYNC;
    property MODE16 : TBits_1 read getMODE16 write setMODE16;
    property MODE32 : TBits_1 read getMODE32 write setMODE32;
    property MSTEN : TBits_1 read getMSTEN write setMSTEN;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property SMP : TBits_1 read getSMP write setSMP;
    property SPIFE : TBits_1 read getSPIFE write setSPIFE;
    property SSEN : TBits_1 read getSSEN write setSSEN;
    property w : TBits_32 read getw write setw;
  end;
  TSPI2_SPI2STAT = record
  private
    function  getSPIBUSY : TBits_1; inline;
    function  getSPIRBF : TBits_1; inline;
    function  getSPIROV : TBits_1; inline;
    function  getSPITBE : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setSPIBUSY(thebits : TBits_1); inline;
    procedure setSPIRBF(thebits : TBits_1); inline;
    procedure setSPIROV(thebits : TBits_1); inline;
    procedure setSPITBE(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearSPIBUSY; inline;
    procedure clearSPIRBF; inline;
    procedure clearSPIROV; inline;
    procedure clearSPITBE; inline;
    procedure setSPIBUSY; inline;
    procedure setSPIRBF; inline;
    procedure setSPIROV; inline;
    procedure setSPITBE; inline;
    property SPIBUSY : TBits_1 read getSPIBUSY write setSPIBUSY;
    property SPIRBF : TBits_1 read getSPIRBF write setSPIRBF;
    property SPIROV : TBits_1 read getSPIROV write setSPIROV;
    property SPITBE : TBits_1 read getSPITBE write setSPITBE;
    property w : TBits_32 read getw write setw;
  end;
type
  TSPI2Registers = record
    SPI2CONbits : TSPI2_SPI2CON;
    SPI2CON : longWord;
    SPI2CONCLR : longWord;
    SPI2CONSET : longWord;
    SPI2CONINV : longWord;
    SPI2STATbits : TSPI2_SPI2STAT;
    SPI2STAT : longWord;
    SPI2STATCLR : longWord;
    SPI2STATSET : longWord;
    SPI2STATINV : longWord;
    SPI2BUF : longWord;
    SPI2BRG : longWord;
    SPI2BRGCLR : longWord;
    SPI2BRGSET : longWord;
    SPI2BRGINV : longWord;
  end;
  TUART1_U1MODE = record
  private
    function  getABAUD : TBits_1; inline;
    function  getBRGH : TBits_1; inline;
    function  getIREN : TBits_1; inline;
    function  getLPBACK : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getPDSEL : TBits_2; inline;
    function  getPDSEL0 : TBits_1; inline;
    function  getPDSEL1 : TBits_1; inline;
    function  getRTSMD : TBits_1; inline;
    function  getRXINV : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getSTSEL : TBits_1; inline;
    function  getUARTEN : TBits_1; inline;
    function  getUEN : TBits_2; inline;
    function  getUEN0 : TBits_1; inline;
    function  getUEN1 : TBits_1; inline;
    function  getUSIDL : TBits_1; inline;
    function  getWAKE : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setABAUD(thebits : TBits_1); inline;
    procedure setBRGH(thebits : TBits_1); inline;
    procedure setIREN(thebits : TBits_1); inline;
    procedure setLPBACK(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setPDSEL(thebits : TBits_2); inline;
    procedure setPDSEL0(thebits : TBits_1); inline;
    procedure setPDSEL1(thebits : TBits_1); inline;
    procedure setRTSMD(thebits : TBits_1); inline;
    procedure setRXINV(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setSTSEL(thebits : TBits_1); inline;
    procedure setUARTEN(thebits : TBits_1); inline;
    procedure setUEN(thebits : TBits_2); inline;
    procedure setUEN0(thebits : TBits_1); inline;
    procedure setUEN1(thebits : TBits_1); inline;
    procedure setUSIDL(thebits : TBits_1); inline;
    procedure setWAKE(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearABAUD; inline;
    procedure clearBRGH; inline;
    procedure clearIREN; inline;
    procedure clearLPBACK; inline;
    procedure clearON; inline;
    procedure clearPDSEL0; inline;
    procedure clearPDSEL1; inline;
    procedure clearRTSMD; inline;
    procedure clearRXINV; inline;
    procedure clearSIDL; inline;
    procedure clearSTSEL; inline;
    procedure clearUARTEN; inline;
    procedure clearUEN0; inline;
    procedure clearUEN1; inline;
    procedure clearUSIDL; inline;
    procedure clearWAKE; inline;
    procedure setABAUD; inline;
    procedure setBRGH; inline;
    procedure setIREN; inline;
    procedure setLPBACK; inline;
    procedure setON; inline;
    procedure setPDSEL0; inline;
    procedure setPDSEL1; inline;
    procedure setRTSMD; inline;
    procedure setRXINV; inline;
    procedure setSIDL; inline;
    procedure setSTSEL; inline;
    procedure setUARTEN; inline;
    procedure setUEN0; inline;
    procedure setUEN1; inline;
    procedure setUSIDL; inline;
    procedure setWAKE; inline;
    property ABAUD : TBits_1 read getABAUD write setABAUD;
    property BRGH : TBits_1 read getBRGH write setBRGH;
    property IREN : TBits_1 read getIREN write setIREN;
    property LPBACK : TBits_1 read getLPBACK write setLPBACK;
    property ON : TBits_1 read getON write setON;
    property PDSEL : TBits_2 read getPDSEL write setPDSEL;
    property PDSEL0 : TBits_1 read getPDSEL0 write setPDSEL0;
    property PDSEL1 : TBits_1 read getPDSEL1 write setPDSEL1;
    property RTSMD : TBits_1 read getRTSMD write setRTSMD;
    property RXINV : TBits_1 read getRXINV write setRXINV;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property STSEL : TBits_1 read getSTSEL write setSTSEL;
    property UARTEN : TBits_1 read getUARTEN write setUARTEN;
    property UEN : TBits_2 read getUEN write setUEN;
    property UEN0 : TBits_1 read getUEN0 write setUEN0;
    property UEN1 : TBits_1 read getUEN1 write setUEN1;
    property USIDL : TBits_1 read getUSIDL write setUSIDL;
    property WAKE : TBits_1 read getWAKE write setWAKE;
    property w : TBits_32 read getw write setw;
  end;
  TUART1_U1STA = record
  private
    function  getADDEN : TBits_1; inline;
    function  getADDR : TBits_8; inline;
    function  getADM_EN : TBits_1; inline;
    function  getFERR : TBits_1; inline;
    function  getOERR : TBits_1; inline;
    function  getPERR : TBits_1; inline;
    function  getRIDLE : TBits_1; inline;
    function  getTRMT : TBits_1; inline;
    function  getURXDA : TBits_1; inline;
    function  getURXEN : TBits_1; inline;
    function  getURXISEL : TBits_2; inline;
    function  getURXISEL0 : TBits_1; inline;
    function  getURXISEL1 : TBits_1; inline;
    function  getUTXBF : TBits_1; inline;
    function  getUTXBRK : TBits_1; inline;
    function  getUTXEN : TBits_1; inline;
    function  getUTXINV : TBits_1; inline;
    function  getUTXISEL : TBits_2; inline;
    function  getUTXISEL0 : TBits_1; inline;
    function  getUTXISEL1 : TBits_1; inline;
    function  getUTXSEL : TBits_2; inline;
    function  getw : TBits_32; inline;
    procedure setADDEN(thebits : TBits_1); inline;
    procedure setADDR(thebits : TBits_8); inline;
    procedure setADM_EN(thebits : TBits_1); inline;
    procedure setFERR(thebits : TBits_1); inline;
    procedure setOERR(thebits : TBits_1); inline;
    procedure setPERR(thebits : TBits_1); inline;
    procedure setRIDLE(thebits : TBits_1); inline;
    procedure setTRMT(thebits : TBits_1); inline;
    procedure setURXDA(thebits : TBits_1); inline;
    procedure setURXEN(thebits : TBits_1); inline;
    procedure setURXISEL(thebits : TBits_2); inline;
    procedure setURXISEL0(thebits : TBits_1); inline;
    procedure setURXISEL1(thebits : TBits_1); inline;
    procedure setUTXBF(thebits : TBits_1); inline;
    procedure setUTXBRK(thebits : TBits_1); inline;
    procedure setUTXEN(thebits : TBits_1); inline;
    procedure setUTXINV(thebits : TBits_1); inline;
    procedure setUTXISEL(thebits : TBits_2); inline;
    procedure setUTXISEL0(thebits : TBits_1); inline;
    procedure setUTXISEL1(thebits : TBits_1); inline;
    procedure setUTXSEL(thebits : TBits_2); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearADDEN; inline;
    procedure clearADM_EN; inline;
    procedure clearFERR; inline;
    procedure clearOERR; inline;
    procedure clearPERR; inline;
    procedure clearRIDLE; inline;
    procedure clearTRMT; inline;
    procedure clearURXDA; inline;
    procedure clearURXEN; inline;
    procedure clearURXISEL0; inline;
    procedure clearURXISEL1; inline;
    procedure clearUTXBF; inline;
    procedure clearUTXBRK; inline;
    procedure clearUTXEN; inline;
    procedure clearUTXINV; inline;
    procedure clearUTXISEL0; inline;
    procedure clearUTXISEL1; inline;
    procedure setADDEN; inline;
    procedure setADM_EN; inline;
    procedure setFERR; inline;
    procedure setOERR; inline;
    procedure setPERR; inline;
    procedure setRIDLE; inline;
    procedure setTRMT; inline;
    procedure setURXDA; inline;
    procedure setURXEN; inline;
    procedure setURXISEL0; inline;
    procedure setURXISEL1; inline;
    procedure setUTXBF; inline;
    procedure setUTXBRK; inline;
    procedure setUTXEN; inline;
    procedure setUTXINV; inline;
    procedure setUTXISEL0; inline;
    procedure setUTXISEL1; inline;
    property ADDEN : TBits_1 read getADDEN write setADDEN;
    property ADDR : TBits_8 read getADDR write setADDR;
    property ADM_EN : TBits_1 read getADM_EN write setADM_EN;
    property FERR : TBits_1 read getFERR write setFERR;
    property OERR : TBits_1 read getOERR write setOERR;
    property PERR : TBits_1 read getPERR write setPERR;
    property RIDLE : TBits_1 read getRIDLE write setRIDLE;
    property TRMT : TBits_1 read getTRMT write setTRMT;
    property URXDA : TBits_1 read getURXDA write setURXDA;
    property URXEN : TBits_1 read getURXEN write setURXEN;
    property URXISEL : TBits_2 read getURXISEL write setURXISEL;
    property URXISEL0 : TBits_1 read getURXISEL0 write setURXISEL0;
    property URXISEL1 : TBits_1 read getURXISEL1 write setURXISEL1;
    property UTXBF : TBits_1 read getUTXBF write setUTXBF;
    property UTXBRK : TBits_1 read getUTXBRK write setUTXBRK;
    property UTXEN : TBits_1 read getUTXEN write setUTXEN;
    property UTXINV : TBits_1 read getUTXINV write setUTXINV;
    property UTXISEL : TBits_2 read getUTXISEL write setUTXISEL;
    property UTXISEL0 : TBits_1 read getUTXISEL0 write setUTXISEL0;
    property UTXISEL1 : TBits_1 read getUTXISEL1 write setUTXISEL1;
    property UTXSEL : TBits_2 read getUTXSEL write setUTXSEL;
    property w : TBits_32 read getw write setw;
  end;
type
  TUART1Registers = record
    U1MODEbits : TUART1_U1MODE;
    U1MODE : longWord;
    U1MODECLR : longWord;
    U1MODESET : longWord;
    U1MODEINV : longWord;
    U1STAbits : TUART1_U1STA;
    U1STA : longWord;
    U1STACLR : longWord;
    U1STASET : longWord;
    U1STAINV : longWord;
    U1TXREG : longWord;
    U1RXREG : longWord;
    U1BRG : longWord;
    U1BRGCLR : longWord;
    U1BRGSET : longWord;
    U1BRGINV : longWord;
  end;
  TUART2_U2MODE = record
  private
    function  getABAUD : TBits_1; inline;
    function  getBRGH : TBits_1; inline;
    function  getIREN : TBits_1; inline;
    function  getLPBACK : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getPDSEL : TBits_2; inline;
    function  getPDSEL0 : TBits_1; inline;
    function  getPDSEL1 : TBits_1; inline;
    function  getRTSMD : TBits_1; inline;
    function  getRXINV : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getSTSEL : TBits_1; inline;
    function  getUARTEN : TBits_1; inline;
    function  getUEN : TBits_2; inline;
    function  getUEN0 : TBits_1; inline;
    function  getUEN1 : TBits_1; inline;
    function  getUSIDL : TBits_1; inline;
    function  getWAKE : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setABAUD(thebits : TBits_1); inline;
    procedure setBRGH(thebits : TBits_1); inline;
    procedure setIREN(thebits : TBits_1); inline;
    procedure setLPBACK(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setPDSEL(thebits : TBits_2); inline;
    procedure setPDSEL0(thebits : TBits_1); inline;
    procedure setPDSEL1(thebits : TBits_1); inline;
    procedure setRTSMD(thebits : TBits_1); inline;
    procedure setRXINV(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setSTSEL(thebits : TBits_1); inline;
    procedure setUARTEN(thebits : TBits_1); inline;
    procedure setUEN(thebits : TBits_2); inline;
    procedure setUEN0(thebits : TBits_1); inline;
    procedure setUEN1(thebits : TBits_1); inline;
    procedure setUSIDL(thebits : TBits_1); inline;
    procedure setWAKE(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearABAUD; inline;
    procedure clearBRGH; inline;
    procedure clearIREN; inline;
    procedure clearLPBACK; inline;
    procedure clearON; inline;
    procedure clearPDSEL0; inline;
    procedure clearPDSEL1; inline;
    procedure clearRTSMD; inline;
    procedure clearRXINV; inline;
    procedure clearSIDL; inline;
    procedure clearSTSEL; inline;
    procedure clearUARTEN; inline;
    procedure clearUEN0; inline;
    procedure clearUEN1; inline;
    procedure clearUSIDL; inline;
    procedure clearWAKE; inline;
    procedure setABAUD; inline;
    procedure setBRGH; inline;
    procedure setIREN; inline;
    procedure setLPBACK; inline;
    procedure setON; inline;
    procedure setPDSEL0; inline;
    procedure setPDSEL1; inline;
    procedure setRTSMD; inline;
    procedure setRXINV; inline;
    procedure setSIDL; inline;
    procedure setSTSEL; inline;
    procedure setUARTEN; inline;
    procedure setUEN0; inline;
    procedure setUEN1; inline;
    procedure setUSIDL; inline;
    procedure setWAKE; inline;
    property ABAUD : TBits_1 read getABAUD write setABAUD;
    property BRGH : TBits_1 read getBRGH write setBRGH;
    property IREN : TBits_1 read getIREN write setIREN;
    property LPBACK : TBits_1 read getLPBACK write setLPBACK;
    property ON : TBits_1 read getON write setON;
    property PDSEL : TBits_2 read getPDSEL write setPDSEL;
    property PDSEL0 : TBits_1 read getPDSEL0 write setPDSEL0;
    property PDSEL1 : TBits_1 read getPDSEL1 write setPDSEL1;
    property RTSMD : TBits_1 read getRTSMD write setRTSMD;
    property RXINV : TBits_1 read getRXINV write setRXINV;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property STSEL : TBits_1 read getSTSEL write setSTSEL;
    property UARTEN : TBits_1 read getUARTEN write setUARTEN;
    property UEN : TBits_2 read getUEN write setUEN;
    property UEN0 : TBits_1 read getUEN0 write setUEN0;
    property UEN1 : TBits_1 read getUEN1 write setUEN1;
    property USIDL : TBits_1 read getUSIDL write setUSIDL;
    property WAKE : TBits_1 read getWAKE write setWAKE;
    property w : TBits_32 read getw write setw;
  end;
  TUART2_U2STA = record
  private
    function  getADDEN : TBits_1; inline;
    function  getADDR : TBits_8; inline;
    function  getADM_EN : TBits_1; inline;
    function  getFERR : TBits_1; inline;
    function  getOERR : TBits_1; inline;
    function  getPERR : TBits_1; inline;
    function  getRIDLE : TBits_1; inline;
    function  getTRMT : TBits_1; inline;
    function  getURXDA : TBits_1; inline;
    function  getURXEN : TBits_1; inline;
    function  getURXISEL : TBits_2; inline;
    function  getURXISEL0 : TBits_1; inline;
    function  getURXISEL1 : TBits_1; inline;
    function  getUTXBF : TBits_1; inline;
    function  getUTXBRK : TBits_1; inline;
    function  getUTXEN : TBits_1; inline;
    function  getUTXINV : TBits_1; inline;
    function  getUTXISEL : TBits_2; inline;
    function  getUTXISEL0 : TBits_1; inline;
    function  getUTXISEL1 : TBits_1; inline;
    function  getUTXSEL : TBits_2; inline;
    function  getw : TBits_32; inline;
    procedure setADDEN(thebits : TBits_1); inline;
    procedure setADDR(thebits : TBits_8); inline;
    procedure setADM_EN(thebits : TBits_1); inline;
    procedure setFERR(thebits : TBits_1); inline;
    procedure setOERR(thebits : TBits_1); inline;
    procedure setPERR(thebits : TBits_1); inline;
    procedure setRIDLE(thebits : TBits_1); inline;
    procedure setTRMT(thebits : TBits_1); inline;
    procedure setURXDA(thebits : TBits_1); inline;
    procedure setURXEN(thebits : TBits_1); inline;
    procedure setURXISEL(thebits : TBits_2); inline;
    procedure setURXISEL0(thebits : TBits_1); inline;
    procedure setURXISEL1(thebits : TBits_1); inline;
    procedure setUTXBF(thebits : TBits_1); inline;
    procedure setUTXBRK(thebits : TBits_1); inline;
    procedure setUTXEN(thebits : TBits_1); inline;
    procedure setUTXINV(thebits : TBits_1); inline;
    procedure setUTXISEL(thebits : TBits_2); inline;
    procedure setUTXISEL0(thebits : TBits_1); inline;
    procedure setUTXISEL1(thebits : TBits_1); inline;
    procedure setUTXSEL(thebits : TBits_2); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearADDEN; inline;
    procedure clearADM_EN; inline;
    procedure clearFERR; inline;
    procedure clearOERR; inline;
    procedure clearPERR; inline;
    procedure clearRIDLE; inline;
    procedure clearTRMT; inline;
    procedure clearURXDA; inline;
    procedure clearURXEN; inline;
    procedure clearURXISEL0; inline;
    procedure clearURXISEL1; inline;
    procedure clearUTXBF; inline;
    procedure clearUTXBRK; inline;
    procedure clearUTXEN; inline;
    procedure clearUTXINV; inline;
    procedure clearUTXISEL0; inline;
    procedure clearUTXISEL1; inline;
    procedure setADDEN; inline;
    procedure setADM_EN; inline;
    procedure setFERR; inline;
    procedure setOERR; inline;
    procedure setPERR; inline;
    procedure setRIDLE; inline;
    procedure setTRMT; inline;
    procedure setURXDA; inline;
    procedure setURXEN; inline;
    procedure setURXISEL0; inline;
    procedure setURXISEL1; inline;
    procedure setUTXBF; inline;
    procedure setUTXBRK; inline;
    procedure setUTXEN; inline;
    procedure setUTXINV; inline;
    procedure setUTXISEL0; inline;
    procedure setUTXISEL1; inline;
    property ADDEN : TBits_1 read getADDEN write setADDEN;
    property ADDR : TBits_8 read getADDR write setADDR;
    property ADM_EN : TBits_1 read getADM_EN write setADM_EN;
    property FERR : TBits_1 read getFERR write setFERR;
    property OERR : TBits_1 read getOERR write setOERR;
    property PERR : TBits_1 read getPERR write setPERR;
    property RIDLE : TBits_1 read getRIDLE write setRIDLE;
    property TRMT : TBits_1 read getTRMT write setTRMT;
    property URXDA : TBits_1 read getURXDA write setURXDA;
    property URXEN : TBits_1 read getURXEN write setURXEN;
    property URXISEL : TBits_2 read getURXISEL write setURXISEL;
    property URXISEL0 : TBits_1 read getURXISEL0 write setURXISEL0;
    property URXISEL1 : TBits_1 read getURXISEL1 write setURXISEL1;
    property UTXBF : TBits_1 read getUTXBF write setUTXBF;
    property UTXBRK : TBits_1 read getUTXBRK write setUTXBRK;
    property UTXEN : TBits_1 read getUTXEN write setUTXEN;
    property UTXINV : TBits_1 read getUTXINV write setUTXINV;
    property UTXISEL : TBits_2 read getUTXISEL write setUTXISEL;
    property UTXISEL0 : TBits_1 read getUTXISEL0 write setUTXISEL0;
    property UTXISEL1 : TBits_1 read getUTXISEL1 write setUTXISEL1;
    property UTXSEL : TBits_2 read getUTXSEL write setUTXSEL;
    property w : TBits_32 read getw write setw;
  end;
type
  TUART2Registers = record
    U2MODEbits : TUART2_U2MODE;
    U2MODE : longWord;
    U2MODECLR : longWord;
    U2MODESET : longWord;
    U2MODEINV : longWord;
    U2STAbits : TUART2_U2STA;
    U2STA : longWord;
    U2STACLR : longWord;
    U2STASET : longWord;
    U2STAINV : longWord;
    U2TXREG : longWord;
    U2RXREG : longWord;
    U2BRG : longWord;
    U2BRGCLR : longWord;
    U2BRGSET : longWord;
    U2BRGINV : longWord;
  end;
  TPMP_PMCON = record
  private
    function  getADRMUX : TBits_2; inline;
    function  getADRMUX0 : TBits_1; inline;
    function  getADRMUX1 : TBits_1; inline;
    function  getALP : TBits_1; inline;
    function  getCS1P : TBits_1; inline;
    function  getCS2P : TBits_1; inline;
    function  getCSF : TBits_2; inline;
    function  getCSF0 : TBits_1; inline;
    function  getCSF1 : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getPMPEN : TBits_1; inline;
    function  getPMPTTL : TBits_1; inline;
    function  getPSIDL : TBits_1; inline;
    function  getPTRDEN : TBits_1; inline;
    function  getPTWREN : TBits_1; inline;
    function  getRDSP : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getWRSP : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setADRMUX(thebits : TBits_2); inline;
    procedure setADRMUX0(thebits : TBits_1); inline;
    procedure setADRMUX1(thebits : TBits_1); inline;
    procedure setALP(thebits : TBits_1); inline;
    procedure setCS1P(thebits : TBits_1); inline;
    procedure setCS2P(thebits : TBits_1); inline;
    procedure setCSF(thebits : TBits_2); inline;
    procedure setCSF0(thebits : TBits_1); inline;
    procedure setCSF1(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setPMPEN(thebits : TBits_1); inline;
    procedure setPMPTTL(thebits : TBits_1); inline;
    procedure setPSIDL(thebits : TBits_1); inline;
    procedure setPTRDEN(thebits : TBits_1); inline;
    procedure setPTWREN(thebits : TBits_1); inline;
    procedure setRDSP(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setWRSP(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearADRMUX0; inline;
    procedure clearADRMUX1; inline;
    procedure clearALP; inline;
    procedure clearCS1P; inline;
    procedure clearCS2P; inline;
    procedure clearCSF0; inline;
    procedure clearCSF1; inline;
    procedure clearON; inline;
    procedure clearPMPEN; inline;
    procedure clearPMPTTL; inline;
    procedure clearPSIDL; inline;
    procedure clearPTRDEN; inline;
    procedure clearPTWREN; inline;
    procedure clearRDSP; inline;
    procedure clearSIDL; inline;
    procedure clearWRSP; inline;
    procedure setADRMUX0; inline;
    procedure setADRMUX1; inline;
    procedure setALP; inline;
    procedure setCS1P; inline;
    procedure setCS2P; inline;
    procedure setCSF0; inline;
    procedure setCSF1; inline;
    procedure setON; inline;
    procedure setPMPEN; inline;
    procedure setPMPTTL; inline;
    procedure setPSIDL; inline;
    procedure setPTRDEN; inline;
    procedure setPTWREN; inline;
    procedure setRDSP; inline;
    procedure setSIDL; inline;
    procedure setWRSP; inline;
    property ADRMUX : TBits_2 read getADRMUX write setADRMUX;
    property ADRMUX0 : TBits_1 read getADRMUX0 write setADRMUX0;
    property ADRMUX1 : TBits_1 read getADRMUX1 write setADRMUX1;
    property ALP : TBits_1 read getALP write setALP;
    property CS1P : TBits_1 read getCS1P write setCS1P;
    property CS2P : TBits_1 read getCS2P write setCS2P;
    property CSF : TBits_2 read getCSF write setCSF;
    property CSF0 : TBits_1 read getCSF0 write setCSF0;
    property CSF1 : TBits_1 read getCSF1 write setCSF1;
    property ON : TBits_1 read getON write setON;
    property PMPEN : TBits_1 read getPMPEN write setPMPEN;
    property PMPTTL : TBits_1 read getPMPTTL write setPMPTTL;
    property PSIDL : TBits_1 read getPSIDL write setPSIDL;
    property PTRDEN : TBits_1 read getPTRDEN write setPTRDEN;
    property PTWREN : TBits_1 read getPTWREN write setPTWREN;
    property RDSP : TBits_1 read getRDSP write setRDSP;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property WRSP : TBits_1 read getWRSP write setWRSP;
    property w : TBits_32 read getw write setw;
  end;
  TPMP_PMMODE = record
  private
    function  getBUSY : TBits_1; inline;
    function  getINCM : TBits_2; inline;
    function  getINCM0 : TBits_1; inline;
    function  getINCM1 : TBits_1; inline;
    function  getIRQM : TBits_2; inline;
    function  getIRQM0 : TBits_1; inline;
    function  getIRQM1 : TBits_1; inline;
    function  getMODE : TBits_2; inline;
    function  getMODE0 : TBits_1; inline;
    function  getMODE1 : TBits_1; inline;
    function  getMODE16 : TBits_1; inline;
    function  getWAITB : TBits_2; inline;
    function  getWAITB0 : TBits_1; inline;
    function  getWAITB1 : TBits_1; inline;
    function  getWAITE : TBits_2; inline;
    function  getWAITE0 : TBits_1; inline;
    function  getWAITE1 : TBits_1; inline;
    function  getWAITM : TBits_4; inline;
    function  getWAITM0 : TBits_1; inline;
    function  getWAITM1 : TBits_1; inline;
    function  getWAITM2 : TBits_1; inline;
    function  getWAITM3 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setBUSY(thebits : TBits_1); inline;
    procedure setINCM(thebits : TBits_2); inline;
    procedure setINCM0(thebits : TBits_1); inline;
    procedure setINCM1(thebits : TBits_1); inline;
    procedure setIRQM(thebits : TBits_2); inline;
    procedure setIRQM0(thebits : TBits_1); inline;
    procedure setIRQM1(thebits : TBits_1); inline;
    procedure setMODE(thebits : TBits_2); inline;
    procedure setMODE0(thebits : TBits_1); inline;
    procedure setMODE1(thebits : TBits_1); inline;
    procedure setMODE16(thebits : TBits_1); inline;
    procedure setWAITB(thebits : TBits_2); inline;
    procedure setWAITB0(thebits : TBits_1); inline;
    procedure setWAITB1(thebits : TBits_1); inline;
    procedure setWAITE(thebits : TBits_2); inline;
    procedure setWAITE0(thebits : TBits_1); inline;
    procedure setWAITE1(thebits : TBits_1); inline;
    procedure setWAITM(thebits : TBits_4); inline;
    procedure setWAITM0(thebits : TBits_1); inline;
    procedure setWAITM1(thebits : TBits_1); inline;
    procedure setWAITM2(thebits : TBits_1); inline;
    procedure setWAITM3(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearBUSY; inline;
    procedure clearINCM0; inline;
    procedure clearINCM1; inline;
    procedure clearIRQM0; inline;
    procedure clearIRQM1; inline;
    procedure clearMODE0; inline;
    procedure clearMODE16; inline;
    procedure clearMODE1; inline;
    procedure clearWAITB0; inline;
    procedure clearWAITB1; inline;
    procedure clearWAITE0; inline;
    procedure clearWAITE1; inline;
    procedure clearWAITM0; inline;
    procedure clearWAITM1; inline;
    procedure clearWAITM2; inline;
    procedure clearWAITM3; inline;
    procedure setBUSY; inline;
    procedure setINCM0; inline;
    procedure setINCM1; inline;
    procedure setIRQM0; inline;
    procedure setIRQM1; inline;
    procedure setMODE0; inline;
    procedure setMODE16; inline;
    procedure setMODE1; inline;
    procedure setWAITB0; inline;
    procedure setWAITB1; inline;
    procedure setWAITE0; inline;
    procedure setWAITE1; inline;
    procedure setWAITM0; inline;
    procedure setWAITM1; inline;
    procedure setWAITM2; inline;
    procedure setWAITM3; inline;
    property BUSY : TBits_1 read getBUSY write setBUSY;
    property INCM : TBits_2 read getINCM write setINCM;
    property INCM0 : TBits_1 read getINCM0 write setINCM0;
    property INCM1 : TBits_1 read getINCM1 write setINCM1;
    property IRQM : TBits_2 read getIRQM write setIRQM;
    property IRQM0 : TBits_1 read getIRQM0 write setIRQM0;
    property IRQM1 : TBits_1 read getIRQM1 write setIRQM1;
    property MODE : TBits_2 read getMODE write setMODE;
    property MODE0 : TBits_1 read getMODE0 write setMODE0;
    property MODE1 : TBits_1 read getMODE1 write setMODE1;
    property MODE16 : TBits_1 read getMODE16 write setMODE16;
    property WAITB : TBits_2 read getWAITB write setWAITB;
    property WAITB0 : TBits_1 read getWAITB0 write setWAITB0;
    property WAITB1 : TBits_1 read getWAITB1 write setWAITB1;
    property WAITE : TBits_2 read getWAITE write setWAITE;
    property WAITE0 : TBits_1 read getWAITE0 write setWAITE0;
    property WAITE1 : TBits_1 read getWAITE1 write setWAITE1;
    property WAITM : TBits_4 read getWAITM write setWAITM;
    property WAITM0 : TBits_1 read getWAITM0 write setWAITM0;
    property WAITM1 : TBits_1 read getWAITM1 write setWAITM1;
    property WAITM2 : TBits_1 read getWAITM2 write setWAITM2;
    property WAITM3 : TBits_1 read getWAITM3 write setWAITM3;
    property w : TBits_32 read getw write setw;
  end;
  TPMP_PMADDR = record
  private
    function  getADDR : TBits_14; inline;
    function  getCS : TBits_2; inline;
    function  getCS1 : TBits_1; inline;
    function  getCS2 : TBits_1; inline;
    function  getPADDR : TBits_14; inline;
    function  getw : TBits_32; inline;
    procedure setADDR(thebits : TBits_14); inline;
    procedure setCS(thebits : TBits_2); inline;
    procedure setCS1(thebits : TBits_1); inline;
    procedure setCS2(thebits : TBits_1); inline;
    procedure setPADDR(thebits : TBits_14); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCS1; inline;
    procedure clearCS2; inline;
    procedure setCS1; inline;
    procedure setCS2; inline;
    property ADDR : TBits_14 read getADDR write setADDR;
    property CS : TBits_2 read getCS write setCS;
    property CS1 : TBits_1 read getCS1 write setCS1;
    property CS2 : TBits_1 read getCS2 write setCS2;
    property PADDR : TBits_14 read getPADDR write setPADDR;
    property w : TBits_32 read getw write setw;
  end;
  TPMP_PMDOUT = record
  private
    function  getDATAOUT : TBits_32; inline;
    function  getw : TBits_32; inline;
    procedure setDATAOUT(thebits : TBits_32); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    property DATAOUT : TBits_32 read getDATAOUT write setDATAOUT;
    property w : TBits_32 read getw write setw;
  end;
  TPMP_PMDIN = record
  private
    function  getDATAIN : TBits_32; inline;
    function  getw : TBits_32; inline;
    procedure setDATAIN(thebits : TBits_32); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    property DATAIN : TBits_32 read getDATAIN write setDATAIN;
    property w : TBits_32 read getw write setw;
  end;
  TPMP_PMAEN = record
  private
    function  getPTEN : TBits_16; inline;
    function  getPTEN0 : TBits_1; inline;
    function  getPTEN1 : TBits_1; inline;
    function  getPTEN10 : TBits_1; inline;
    function  getPTEN11 : TBits_1; inline;
    function  getPTEN12 : TBits_1; inline;
    function  getPTEN13 : TBits_1; inline;
    function  getPTEN14 : TBits_1; inline;
    function  getPTEN15 : TBits_1; inline;
    function  getPTEN2 : TBits_1; inline;
    function  getPTEN3 : TBits_1; inline;
    function  getPTEN4 : TBits_1; inline;
    function  getPTEN5 : TBits_1; inline;
    function  getPTEN6 : TBits_1; inline;
    function  getPTEN7 : TBits_1; inline;
    function  getPTEN8 : TBits_1; inline;
    function  getPTEN9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setPTEN(thebits : TBits_16); inline;
    procedure setPTEN0(thebits : TBits_1); inline;
    procedure setPTEN1(thebits : TBits_1); inline;
    procedure setPTEN10(thebits : TBits_1); inline;
    procedure setPTEN11(thebits : TBits_1); inline;
    procedure setPTEN12(thebits : TBits_1); inline;
    procedure setPTEN13(thebits : TBits_1); inline;
    procedure setPTEN14(thebits : TBits_1); inline;
    procedure setPTEN15(thebits : TBits_1); inline;
    procedure setPTEN2(thebits : TBits_1); inline;
    procedure setPTEN3(thebits : TBits_1); inline;
    procedure setPTEN4(thebits : TBits_1); inline;
    procedure setPTEN5(thebits : TBits_1); inline;
    procedure setPTEN6(thebits : TBits_1); inline;
    procedure setPTEN7(thebits : TBits_1); inline;
    procedure setPTEN8(thebits : TBits_1); inline;
    procedure setPTEN9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearPTEN0; inline;
    procedure clearPTEN10; inline;
    procedure clearPTEN11; inline;
    procedure clearPTEN12; inline;
    procedure clearPTEN13; inline;
    procedure clearPTEN14; inline;
    procedure clearPTEN15; inline;
    procedure clearPTEN1; inline;
    procedure clearPTEN2; inline;
    procedure clearPTEN3; inline;
    procedure clearPTEN4; inline;
    procedure clearPTEN5; inline;
    procedure clearPTEN6; inline;
    procedure clearPTEN7; inline;
    procedure clearPTEN8; inline;
    procedure clearPTEN9; inline;
    procedure setPTEN0; inline;
    procedure setPTEN10; inline;
    procedure setPTEN11; inline;
    procedure setPTEN12; inline;
    procedure setPTEN13; inline;
    procedure setPTEN14; inline;
    procedure setPTEN15; inline;
    procedure setPTEN1; inline;
    procedure setPTEN2; inline;
    procedure setPTEN3; inline;
    procedure setPTEN4; inline;
    procedure setPTEN5; inline;
    procedure setPTEN6; inline;
    procedure setPTEN7; inline;
    procedure setPTEN8; inline;
    procedure setPTEN9; inline;
    property PTEN : TBits_16 read getPTEN write setPTEN;
    property PTEN0 : TBits_1 read getPTEN0 write setPTEN0;
    property PTEN1 : TBits_1 read getPTEN1 write setPTEN1;
    property PTEN10 : TBits_1 read getPTEN10 write setPTEN10;
    property PTEN11 : TBits_1 read getPTEN11 write setPTEN11;
    property PTEN12 : TBits_1 read getPTEN12 write setPTEN12;
    property PTEN13 : TBits_1 read getPTEN13 write setPTEN13;
    property PTEN14 : TBits_1 read getPTEN14 write setPTEN14;
    property PTEN15 : TBits_1 read getPTEN15 write setPTEN15;
    property PTEN2 : TBits_1 read getPTEN2 write setPTEN2;
    property PTEN3 : TBits_1 read getPTEN3 write setPTEN3;
    property PTEN4 : TBits_1 read getPTEN4 write setPTEN4;
    property PTEN5 : TBits_1 read getPTEN5 write setPTEN5;
    property PTEN6 : TBits_1 read getPTEN6 write setPTEN6;
    property PTEN7 : TBits_1 read getPTEN7 write setPTEN7;
    property PTEN8 : TBits_1 read getPTEN8 write setPTEN8;
    property PTEN9 : TBits_1 read getPTEN9 write setPTEN9;
    property w : TBits_32 read getw write setw;
  end;
  TPMP_PMSTAT = record
  private
    function  getIB0F : TBits_1; inline;
    function  getIB1F : TBits_1; inline;
    function  getIB2F : TBits_1; inline;
    function  getIB3F : TBits_1; inline;
    function  getIBF : TBits_1; inline;
    function  getIBOV : TBits_1; inline;
    function  getOB0E : TBits_1; inline;
    function  getOB1E : TBits_1; inline;
    function  getOB2E : TBits_1; inline;
    function  getOB3E : TBits_1; inline;
    function  getOBE : TBits_1; inline;
    function  getOBUF : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setIB0F(thebits : TBits_1); inline;
    procedure setIB1F(thebits : TBits_1); inline;
    procedure setIB2F(thebits : TBits_1); inline;
    procedure setIB3F(thebits : TBits_1); inline;
    procedure setIBF(thebits : TBits_1); inline;
    procedure setIBOV(thebits : TBits_1); inline;
    procedure setOB0E(thebits : TBits_1); inline;
    procedure setOB1E(thebits : TBits_1); inline;
    procedure setOB2E(thebits : TBits_1); inline;
    procedure setOB3E(thebits : TBits_1); inline;
    procedure setOBE(thebits : TBits_1); inline;
    procedure setOBUF(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearIB0F; inline;
    procedure clearIB1F; inline;
    procedure clearIB2F; inline;
    procedure clearIB3F; inline;
    procedure clearIBF; inline;
    procedure clearIBOV; inline;
    procedure clearOB0E; inline;
    procedure clearOB1E; inline;
    procedure clearOB2E; inline;
    procedure clearOB3E; inline;
    procedure clearOBE; inline;
    procedure clearOBUF; inline;
    procedure setIB0F; inline;
    procedure setIB1F; inline;
    procedure setIB2F; inline;
    procedure setIB3F; inline;
    procedure setIBF; inline;
    procedure setIBOV; inline;
    procedure setOB0E; inline;
    procedure setOB1E; inline;
    procedure setOB2E; inline;
    procedure setOB3E; inline;
    procedure setOBE; inline;
    procedure setOBUF; inline;
    property IB0F : TBits_1 read getIB0F write setIB0F;
    property IB1F : TBits_1 read getIB1F write setIB1F;
    property IB2F : TBits_1 read getIB2F write setIB2F;
    property IB3F : TBits_1 read getIB3F write setIB3F;
    property IBF : TBits_1 read getIBF write setIBF;
    property IBOV : TBits_1 read getIBOV write setIBOV;
    property OB0E : TBits_1 read getOB0E write setOB0E;
    property OB1E : TBits_1 read getOB1E write setOB1E;
    property OB2E : TBits_1 read getOB2E write setOB2E;
    property OB3E : TBits_1 read getOB3E write setOB3E;
    property OBE : TBits_1 read getOBE write setOBE;
    property OBUF : TBits_1 read getOBUF write setOBUF;
    property w : TBits_32 read getw write setw;
  end;
type
  TPMPRegisters = record
    PMCONbits : TPMP_PMCON;
    PMCON : longWord;
    PMCONCLR : longWord;
    PMCONSET : longWord;
    PMCONINV : longWord;
    PMMODEbits : TPMP_PMMODE;
    PMMODE : longWord;
    PMMODECLR : longWord;
    PMMODESET : longWord;
    PMMODEINV : longWord;
    PMADDRbits : TPMP_PMADDR;
    PMADDR : longWord;
    PMADDRCLR : longWord;
    PMADDRSET : longWord;
    PMADDRINV : longWord;
    PMDOUTbits : TPMP_PMDOUT;
    PMDOUT : longWord;
    PMDOUTCLR : longWord;
    PMDOUTSET : longWord;
    PMDOUTINV : longWord;
    PMDINbits : TPMP_PMDIN;
    PMDIN : longWord;
    PMDINCLR : longWord;
    PMDINSET : longWord;
    PMDININV : longWord;
    PMAENbits : TPMP_PMAEN;
    PMAEN : longWord;
    PMAENCLR : longWord;
    PMAENSET : longWord;
    PMAENINV : longWord;
    PMSTATbits : TPMP_PMSTAT;
    PMSTAT : longWord;
    PMSTATCLR : longWord;
    PMSTATSET : longWord;
    PMSTATINV : longWord;
  end;
  TADC10_AD1CON1 = record
  private
    function  getADON : TBits_1; inline;
    function  getADSIDL : TBits_1; inline;
    function  getASAM : TBits_1; inline;
    function  getCLRASAM : TBits_1; inline;
    function  getDONE : TBits_1; inline;
    function  getFORM : TBits_3; inline;
    function  getFORM0 : TBits_1; inline;
    function  getFORM1 : TBits_1; inline;
    function  getFORM2 : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getSAMP : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getSSRC : TBits_3; inline;
    function  getSSRC0 : TBits_1; inline;
    function  getSSRC1 : TBits_1; inline;
    function  getSSRC2 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setADON(thebits : TBits_1); inline;
    procedure setADSIDL(thebits : TBits_1); inline;
    procedure setASAM(thebits : TBits_1); inline;
    procedure setCLRASAM(thebits : TBits_1); inline;
    procedure setDONE(thebits : TBits_1); inline;
    procedure setFORM(thebits : TBits_3); inline;
    procedure setFORM0(thebits : TBits_1); inline;
    procedure setFORM1(thebits : TBits_1); inline;
    procedure setFORM2(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSAMP(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setSSRC(thebits : TBits_3); inline;
    procedure setSSRC0(thebits : TBits_1); inline;
    procedure setSSRC1(thebits : TBits_1); inline;
    procedure setSSRC2(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearADON; inline;
    procedure clearADSIDL; inline;
    procedure clearASAM; inline;
    procedure clearCLRASAM; inline;
    procedure clearDONE; inline;
    procedure clearFORM0; inline;
    procedure clearFORM1; inline;
    procedure clearFORM2; inline;
    procedure clearON; inline;
    procedure clearSAMP; inline;
    procedure clearSIDL; inline;
    procedure clearSSRC0; inline;
    procedure clearSSRC1; inline;
    procedure clearSSRC2; inline;
    procedure setADON; inline;
    procedure setADSIDL; inline;
    procedure setASAM; inline;
    procedure setCLRASAM; inline;
    procedure setDONE; inline;
    procedure setFORM0; inline;
    procedure setFORM1; inline;
    procedure setFORM2; inline;
    procedure setON; inline;
    procedure setSAMP; inline;
    procedure setSIDL; inline;
    procedure setSSRC0; inline;
    procedure setSSRC1; inline;
    procedure setSSRC2; inline;
    property ADON : TBits_1 read getADON write setADON;
    property ADSIDL : TBits_1 read getADSIDL write setADSIDL;
    property ASAM : TBits_1 read getASAM write setASAM;
    property CLRASAM : TBits_1 read getCLRASAM write setCLRASAM;
    property DONE : TBits_1 read getDONE write setDONE;
    property FORM : TBits_3 read getFORM write setFORM;
    property FORM0 : TBits_1 read getFORM0 write setFORM0;
    property FORM1 : TBits_1 read getFORM1 write setFORM1;
    property FORM2 : TBits_1 read getFORM2 write setFORM2;
    property ON : TBits_1 read getON write setON;
    property SAMP : TBits_1 read getSAMP write setSAMP;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property SSRC : TBits_3 read getSSRC write setSSRC;
    property SSRC0 : TBits_1 read getSSRC0 write setSSRC0;
    property SSRC1 : TBits_1 read getSSRC1 write setSSRC1;
    property SSRC2 : TBits_1 read getSSRC2 write setSSRC2;
    property w : TBits_32 read getw write setw;
  end;
  TADC10_AD1CON2 = record
  private
    function  getALTS : TBits_1; inline;
    function  getBUFM : TBits_1; inline;
    function  getBUFS : TBits_1; inline;
    function  getCSCNA : TBits_1; inline;
    function  getOFFCAL : TBits_1; inline;
    function  getSMPI : TBits_4; inline;
    function  getSMPI0 : TBits_1; inline;
    function  getSMPI1 : TBits_1; inline;
    function  getSMPI2 : TBits_1; inline;
    function  getSMPI3 : TBits_1; inline;
    function  getVCFG : TBits_3; inline;
    function  getVCFG0 : TBits_1; inline;
    function  getVCFG1 : TBits_1; inline;
    function  getVCFG2 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setALTS(thebits : TBits_1); inline;
    procedure setBUFM(thebits : TBits_1); inline;
    procedure setBUFS(thebits : TBits_1); inline;
    procedure setCSCNA(thebits : TBits_1); inline;
    procedure setOFFCAL(thebits : TBits_1); inline;
    procedure setSMPI(thebits : TBits_4); inline;
    procedure setSMPI0(thebits : TBits_1); inline;
    procedure setSMPI1(thebits : TBits_1); inline;
    procedure setSMPI2(thebits : TBits_1); inline;
    procedure setSMPI3(thebits : TBits_1); inline;
    procedure setVCFG(thebits : TBits_3); inline;
    procedure setVCFG0(thebits : TBits_1); inline;
    procedure setVCFG1(thebits : TBits_1); inline;
    procedure setVCFG2(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearALTS; inline;
    procedure clearBUFM; inline;
    procedure clearBUFS; inline;
    procedure clearCSCNA; inline;
    procedure clearOFFCAL; inline;
    procedure clearSMPI0; inline;
    procedure clearSMPI1; inline;
    procedure clearSMPI2; inline;
    procedure clearSMPI3; inline;
    procedure clearVCFG0; inline;
    procedure clearVCFG1; inline;
    procedure clearVCFG2; inline;
    procedure setALTS; inline;
    procedure setBUFM; inline;
    procedure setBUFS; inline;
    procedure setCSCNA; inline;
    procedure setOFFCAL; inline;
    procedure setSMPI0; inline;
    procedure setSMPI1; inline;
    procedure setSMPI2; inline;
    procedure setSMPI3; inline;
    procedure setVCFG0; inline;
    procedure setVCFG1; inline;
    procedure setVCFG2; inline;
    property ALTS : TBits_1 read getALTS write setALTS;
    property BUFM : TBits_1 read getBUFM write setBUFM;
    property BUFS : TBits_1 read getBUFS write setBUFS;
    property CSCNA : TBits_1 read getCSCNA write setCSCNA;
    property OFFCAL : TBits_1 read getOFFCAL write setOFFCAL;
    property SMPI : TBits_4 read getSMPI write setSMPI;
    property SMPI0 : TBits_1 read getSMPI0 write setSMPI0;
    property SMPI1 : TBits_1 read getSMPI1 write setSMPI1;
    property SMPI2 : TBits_1 read getSMPI2 write setSMPI2;
    property SMPI3 : TBits_1 read getSMPI3 write setSMPI3;
    property VCFG : TBits_3 read getVCFG write setVCFG;
    property VCFG0 : TBits_1 read getVCFG0 write setVCFG0;
    property VCFG1 : TBits_1 read getVCFG1 write setVCFG1;
    property VCFG2 : TBits_1 read getVCFG2 write setVCFG2;
    property w : TBits_32 read getw write setw;
  end;
  TADC10_AD1CON3 = record
  private
    function  getADCS : TBits_8; inline;
    function  getADCS0 : TBits_1; inline;
    function  getADCS1 : TBits_1; inline;
    function  getADCS2 : TBits_1; inline;
    function  getADCS3 : TBits_1; inline;
    function  getADCS4 : TBits_1; inline;
    function  getADCS5 : TBits_1; inline;
    function  getADCS6 : TBits_1; inline;
    function  getADCS7 : TBits_1; inline;
    function  getADRC : TBits_1; inline;
    function  getSAMC : TBits_5; inline;
    function  getSAMC0 : TBits_1; inline;
    function  getSAMC1 : TBits_1; inline;
    function  getSAMC2 : TBits_1; inline;
    function  getSAMC3 : TBits_1; inline;
    function  getSAMC4 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setADCS(thebits : TBits_8); inline;
    procedure setADCS0(thebits : TBits_1); inline;
    procedure setADCS1(thebits : TBits_1); inline;
    procedure setADCS2(thebits : TBits_1); inline;
    procedure setADCS3(thebits : TBits_1); inline;
    procedure setADCS4(thebits : TBits_1); inline;
    procedure setADCS5(thebits : TBits_1); inline;
    procedure setADCS6(thebits : TBits_1); inline;
    procedure setADCS7(thebits : TBits_1); inline;
    procedure setADRC(thebits : TBits_1); inline;
    procedure setSAMC(thebits : TBits_5); inline;
    procedure setSAMC0(thebits : TBits_1); inline;
    procedure setSAMC1(thebits : TBits_1); inline;
    procedure setSAMC2(thebits : TBits_1); inline;
    procedure setSAMC3(thebits : TBits_1); inline;
    procedure setSAMC4(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearADCS0; inline;
    procedure clearADCS1; inline;
    procedure clearADCS2; inline;
    procedure clearADCS3; inline;
    procedure clearADCS4; inline;
    procedure clearADCS5; inline;
    procedure clearADCS6; inline;
    procedure clearADCS7; inline;
    procedure clearADRC; inline;
    procedure clearSAMC0; inline;
    procedure clearSAMC1; inline;
    procedure clearSAMC2; inline;
    procedure clearSAMC3; inline;
    procedure clearSAMC4; inline;
    procedure setADCS0; inline;
    procedure setADCS1; inline;
    procedure setADCS2; inline;
    procedure setADCS3; inline;
    procedure setADCS4; inline;
    procedure setADCS5; inline;
    procedure setADCS6; inline;
    procedure setADCS7; inline;
    procedure setADRC; inline;
    procedure setSAMC0; inline;
    procedure setSAMC1; inline;
    procedure setSAMC2; inline;
    procedure setSAMC3; inline;
    procedure setSAMC4; inline;
    property ADCS : TBits_8 read getADCS write setADCS;
    property ADCS0 : TBits_1 read getADCS0 write setADCS0;
    property ADCS1 : TBits_1 read getADCS1 write setADCS1;
    property ADCS2 : TBits_1 read getADCS2 write setADCS2;
    property ADCS3 : TBits_1 read getADCS3 write setADCS3;
    property ADCS4 : TBits_1 read getADCS4 write setADCS4;
    property ADCS5 : TBits_1 read getADCS5 write setADCS5;
    property ADCS6 : TBits_1 read getADCS6 write setADCS6;
    property ADCS7 : TBits_1 read getADCS7 write setADCS7;
    property ADRC : TBits_1 read getADRC write setADRC;
    property SAMC : TBits_5 read getSAMC write setSAMC;
    property SAMC0 : TBits_1 read getSAMC0 write setSAMC0;
    property SAMC1 : TBits_1 read getSAMC1 write setSAMC1;
    property SAMC2 : TBits_1 read getSAMC2 write setSAMC2;
    property SAMC3 : TBits_1 read getSAMC3 write setSAMC3;
    property SAMC4 : TBits_1 read getSAMC4 write setSAMC4;
    property w : TBits_32 read getw write setw;
  end;
  TADC10_AD1CHS = record
  private
    function  getCH0NA : TBits_1; inline;
    function  getCH0NB : TBits_1; inline;
    function  getCH0SA : TBits_4; inline;
    function  getCH0SA0 : TBits_1; inline;
    function  getCH0SA1 : TBits_1; inline;
    function  getCH0SA2 : TBits_1; inline;
    function  getCH0SA3 : TBits_1; inline;
    function  getCH0SB : TBits_4; inline;
    function  getCH0SB0 : TBits_1; inline;
    function  getCH0SB1 : TBits_1; inline;
    function  getCH0SB2 : TBits_1; inline;
    function  getCH0SB3 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCH0NA(thebits : TBits_1); inline;
    procedure setCH0NB(thebits : TBits_1); inline;
    procedure setCH0SA(thebits : TBits_4); inline;
    procedure setCH0SA0(thebits : TBits_1); inline;
    procedure setCH0SA1(thebits : TBits_1); inline;
    procedure setCH0SA2(thebits : TBits_1); inline;
    procedure setCH0SA3(thebits : TBits_1); inline;
    procedure setCH0SB(thebits : TBits_4); inline;
    procedure setCH0SB0(thebits : TBits_1); inline;
    procedure setCH0SB1(thebits : TBits_1); inline;
    procedure setCH0SB2(thebits : TBits_1); inline;
    procedure setCH0SB3(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCH0NA; inline;
    procedure clearCH0NB; inline;
    procedure clearCH0SA0; inline;
    procedure clearCH0SA1; inline;
    procedure clearCH0SA2; inline;
    procedure clearCH0SA3; inline;
    procedure clearCH0SB0; inline;
    procedure clearCH0SB1; inline;
    procedure clearCH0SB2; inline;
    procedure clearCH0SB3; inline;
    procedure setCH0NA; inline;
    procedure setCH0NB; inline;
    procedure setCH0SA0; inline;
    procedure setCH0SA1; inline;
    procedure setCH0SA2; inline;
    procedure setCH0SA3; inline;
    procedure setCH0SB0; inline;
    procedure setCH0SB1; inline;
    procedure setCH0SB2; inline;
    procedure setCH0SB3; inline;
    property CH0NA : TBits_1 read getCH0NA write setCH0NA;
    property CH0NB : TBits_1 read getCH0NB write setCH0NB;
    property CH0SA : TBits_4 read getCH0SA write setCH0SA;
    property CH0SA0 : TBits_1 read getCH0SA0 write setCH0SA0;
    property CH0SA1 : TBits_1 read getCH0SA1 write setCH0SA1;
    property CH0SA2 : TBits_1 read getCH0SA2 write setCH0SA2;
    property CH0SA3 : TBits_1 read getCH0SA3 write setCH0SA3;
    property CH0SB : TBits_4 read getCH0SB write setCH0SB;
    property CH0SB0 : TBits_1 read getCH0SB0 write setCH0SB0;
    property CH0SB1 : TBits_1 read getCH0SB1 write setCH0SB1;
    property CH0SB2 : TBits_1 read getCH0SB2 write setCH0SB2;
    property CH0SB3 : TBits_1 read getCH0SB3 write setCH0SB3;
    property w : TBits_32 read getw write setw;
  end;
  TADC10_AD1CSSL = record
  private
    function  getCSSL : TBits_16; inline;
    function  getCSSL0 : TBits_1; inline;
    function  getCSSL1 : TBits_1; inline;
    function  getCSSL10 : TBits_1; inline;
    function  getCSSL11 : TBits_1; inline;
    function  getCSSL12 : TBits_1; inline;
    function  getCSSL13 : TBits_1; inline;
    function  getCSSL14 : TBits_1; inline;
    function  getCSSL15 : TBits_1; inline;
    function  getCSSL2 : TBits_1; inline;
    function  getCSSL3 : TBits_1; inline;
    function  getCSSL4 : TBits_1; inline;
    function  getCSSL5 : TBits_1; inline;
    function  getCSSL6 : TBits_1; inline;
    function  getCSSL7 : TBits_1; inline;
    function  getCSSL8 : TBits_1; inline;
    function  getCSSL9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCSSL(thebits : TBits_16); inline;
    procedure setCSSL0(thebits : TBits_1); inline;
    procedure setCSSL1(thebits : TBits_1); inline;
    procedure setCSSL10(thebits : TBits_1); inline;
    procedure setCSSL11(thebits : TBits_1); inline;
    procedure setCSSL12(thebits : TBits_1); inline;
    procedure setCSSL13(thebits : TBits_1); inline;
    procedure setCSSL14(thebits : TBits_1); inline;
    procedure setCSSL15(thebits : TBits_1); inline;
    procedure setCSSL2(thebits : TBits_1); inline;
    procedure setCSSL3(thebits : TBits_1); inline;
    procedure setCSSL4(thebits : TBits_1); inline;
    procedure setCSSL5(thebits : TBits_1); inline;
    procedure setCSSL6(thebits : TBits_1); inline;
    procedure setCSSL7(thebits : TBits_1); inline;
    procedure setCSSL8(thebits : TBits_1); inline;
    procedure setCSSL9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCSSL0; inline;
    procedure clearCSSL10; inline;
    procedure clearCSSL11; inline;
    procedure clearCSSL12; inline;
    procedure clearCSSL13; inline;
    procedure clearCSSL14; inline;
    procedure clearCSSL15; inline;
    procedure clearCSSL1; inline;
    procedure clearCSSL2; inline;
    procedure clearCSSL3; inline;
    procedure clearCSSL4; inline;
    procedure clearCSSL5; inline;
    procedure clearCSSL6; inline;
    procedure clearCSSL7; inline;
    procedure clearCSSL8; inline;
    procedure clearCSSL9; inline;
    procedure setCSSL0; inline;
    procedure setCSSL10; inline;
    procedure setCSSL11; inline;
    procedure setCSSL12; inline;
    procedure setCSSL13; inline;
    procedure setCSSL14; inline;
    procedure setCSSL15; inline;
    procedure setCSSL1; inline;
    procedure setCSSL2; inline;
    procedure setCSSL3; inline;
    procedure setCSSL4; inline;
    procedure setCSSL5; inline;
    procedure setCSSL6; inline;
    procedure setCSSL7; inline;
    procedure setCSSL8; inline;
    procedure setCSSL9; inline;
    property CSSL : TBits_16 read getCSSL write setCSSL;
    property CSSL0 : TBits_1 read getCSSL0 write setCSSL0;
    property CSSL1 : TBits_1 read getCSSL1 write setCSSL1;
    property CSSL10 : TBits_1 read getCSSL10 write setCSSL10;
    property CSSL11 : TBits_1 read getCSSL11 write setCSSL11;
    property CSSL12 : TBits_1 read getCSSL12 write setCSSL12;
    property CSSL13 : TBits_1 read getCSSL13 write setCSSL13;
    property CSSL14 : TBits_1 read getCSSL14 write setCSSL14;
    property CSSL15 : TBits_1 read getCSSL15 write setCSSL15;
    property CSSL2 : TBits_1 read getCSSL2 write setCSSL2;
    property CSSL3 : TBits_1 read getCSSL3 write setCSSL3;
    property CSSL4 : TBits_1 read getCSSL4 write setCSSL4;
    property CSSL5 : TBits_1 read getCSSL5 write setCSSL5;
    property CSSL6 : TBits_1 read getCSSL6 write setCSSL6;
    property CSSL7 : TBits_1 read getCSSL7 write setCSSL7;
    property CSSL8 : TBits_1 read getCSSL8 write setCSSL8;
    property CSSL9 : TBits_1 read getCSSL9 write setCSSL9;
    property w : TBits_32 read getw write setw;
  end;
  TADC10_AD1PCFG = record
  private
    function  getPCFG : TBits_16; inline;
    function  getPCFG0 : TBits_1; inline;
    function  getPCFG1 : TBits_1; inline;
    function  getPCFG10 : TBits_1; inline;
    function  getPCFG11 : TBits_1; inline;
    function  getPCFG12 : TBits_1; inline;
    function  getPCFG13 : TBits_1; inline;
    function  getPCFG14 : TBits_1; inline;
    function  getPCFG15 : TBits_1; inline;
    function  getPCFG2 : TBits_1; inline;
    function  getPCFG3 : TBits_1; inline;
    function  getPCFG4 : TBits_1; inline;
    function  getPCFG5 : TBits_1; inline;
    function  getPCFG6 : TBits_1; inline;
    function  getPCFG7 : TBits_1; inline;
    function  getPCFG8 : TBits_1; inline;
    function  getPCFG9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setPCFG(thebits : TBits_16); inline;
    procedure setPCFG0(thebits : TBits_1); inline;
    procedure setPCFG1(thebits : TBits_1); inline;
    procedure setPCFG10(thebits : TBits_1); inline;
    procedure setPCFG11(thebits : TBits_1); inline;
    procedure setPCFG12(thebits : TBits_1); inline;
    procedure setPCFG13(thebits : TBits_1); inline;
    procedure setPCFG14(thebits : TBits_1); inline;
    procedure setPCFG15(thebits : TBits_1); inline;
    procedure setPCFG2(thebits : TBits_1); inline;
    procedure setPCFG3(thebits : TBits_1); inline;
    procedure setPCFG4(thebits : TBits_1); inline;
    procedure setPCFG5(thebits : TBits_1); inline;
    procedure setPCFG6(thebits : TBits_1); inline;
    procedure setPCFG7(thebits : TBits_1); inline;
    procedure setPCFG8(thebits : TBits_1); inline;
    procedure setPCFG9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearPCFG0; inline;
    procedure clearPCFG10; inline;
    procedure clearPCFG11; inline;
    procedure clearPCFG12; inline;
    procedure clearPCFG13; inline;
    procedure clearPCFG14; inline;
    procedure clearPCFG15; inline;
    procedure clearPCFG1; inline;
    procedure clearPCFG2; inline;
    procedure clearPCFG3; inline;
    procedure clearPCFG4; inline;
    procedure clearPCFG5; inline;
    procedure clearPCFG6; inline;
    procedure clearPCFG7; inline;
    procedure clearPCFG8; inline;
    procedure clearPCFG9; inline;
    procedure setPCFG0; inline;
    procedure setPCFG10; inline;
    procedure setPCFG11; inline;
    procedure setPCFG12; inline;
    procedure setPCFG13; inline;
    procedure setPCFG14; inline;
    procedure setPCFG15; inline;
    procedure setPCFG1; inline;
    procedure setPCFG2; inline;
    procedure setPCFG3; inline;
    procedure setPCFG4; inline;
    procedure setPCFG5; inline;
    procedure setPCFG6; inline;
    procedure setPCFG7; inline;
    procedure setPCFG8; inline;
    procedure setPCFG9; inline;
    property PCFG : TBits_16 read getPCFG write setPCFG;
    property PCFG0 : TBits_1 read getPCFG0 write setPCFG0;
    property PCFG1 : TBits_1 read getPCFG1 write setPCFG1;
    property PCFG10 : TBits_1 read getPCFG10 write setPCFG10;
    property PCFG11 : TBits_1 read getPCFG11 write setPCFG11;
    property PCFG12 : TBits_1 read getPCFG12 write setPCFG12;
    property PCFG13 : TBits_1 read getPCFG13 write setPCFG13;
    property PCFG14 : TBits_1 read getPCFG14 write setPCFG14;
    property PCFG15 : TBits_1 read getPCFG15 write setPCFG15;
    property PCFG2 : TBits_1 read getPCFG2 write setPCFG2;
    property PCFG3 : TBits_1 read getPCFG3 write setPCFG3;
    property PCFG4 : TBits_1 read getPCFG4 write setPCFG4;
    property PCFG5 : TBits_1 read getPCFG5 write setPCFG5;
    property PCFG6 : TBits_1 read getPCFG6 write setPCFG6;
    property PCFG7 : TBits_1 read getPCFG7 write setPCFG7;
    property PCFG8 : TBits_1 read getPCFG8 write setPCFG8;
    property PCFG9 : TBits_1 read getPCFG9 write setPCFG9;
    property w : TBits_32 read getw write setw;
  end;
type
  TADC10Registers = record
    AD1CON1bits : TADC10_AD1CON1;
    AD1CON1 : longWord;
    AD1CON1CLR : longWord;
    AD1CON1SET : longWord;
    AD1CON1INV : longWord;
    AD1CON2bits : TADC10_AD1CON2;
    AD1CON2 : longWord;
    AD1CON2CLR : longWord;
    AD1CON2SET : longWord;
    AD1CON2INV : longWord;
    AD1CON3bits : TADC10_AD1CON3;
    AD1CON3 : longWord;
    AD1CON3CLR : longWord;
    AD1CON3SET : longWord;
    AD1CON3INV : longWord;
    AD1CHSbits : TADC10_AD1CHS;
    AD1CHS : longWord;
    AD1CHSCLR : longWord;
    AD1CHSSET : longWord;
    AD1CHSINV : longWord;
    AD1CSSLbits : TADC10_AD1CSSL;
    AD1CSSL : longWord;
    AD1CSSLCLR : longWord;
    AD1CSSLSET : longWord;
    AD1CSSLINV : longWord;
    AD1PCFGbits : TADC10_AD1PCFG;
    AD1PCFG : longWord;
    AD1PCFGCLR : longWord;
    AD1PCFGSET : longWord;
    AD1PCFGINV : longWord;
    ADC1BUF0 : longWord;
    ADC1BUF1 : longWord;
    ADC1BUF2 : longWord;
    ADC1BUF3 : longWord;
    ADC1BUF4 : longWord;
    ADC1BUF5 : longWord;
    ADC1BUF6 : longWord;
    ADC1BUF7 : longWord;
    ADC1BUF8 : longWord;
    ADC1BUF9 : longWord;
    ADC1BUFA : longWord;
    ADC1BUFB : longWord;
    ADC1BUFC : longWord;
    ADC1BUFD : longWord;
    ADC1BUFE : longWord;
    ADC1BUFF : longWord;
  end;
  TCVR_CVRCON = record
  private
    function  getCVR : TBits_4; inline;
    function  getCVR0 : TBits_1; inline;
    function  getCVR1 : TBits_1; inline;
    function  getCVR2 : TBits_1; inline;
    function  getCVR3 : TBits_1; inline;
    function  getCVROE : TBits_1; inline;
    function  getCVRR : TBits_1; inline;
    function  getCVRSS : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCVR(thebits : TBits_4); inline;
    procedure setCVR0(thebits : TBits_1); inline;
    procedure setCVR1(thebits : TBits_1); inline;
    procedure setCVR2(thebits : TBits_1); inline;
    procedure setCVR3(thebits : TBits_1); inline;
    procedure setCVROE(thebits : TBits_1); inline;
    procedure setCVRR(thebits : TBits_1); inline;
    procedure setCVRSS(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCVR0; inline;
    procedure clearCVR1; inline;
    procedure clearCVR2; inline;
    procedure clearCVR3; inline;
    procedure clearCVROE; inline;
    procedure clearCVRR; inline;
    procedure clearCVRSS; inline;
    procedure clearON; inline;
    procedure setCVR0; inline;
    procedure setCVR1; inline;
    procedure setCVR2; inline;
    procedure setCVR3; inline;
    procedure setCVROE; inline;
    procedure setCVRR; inline;
    procedure setCVRSS; inline;
    procedure setON; inline;
    property CVR : TBits_4 read getCVR write setCVR;
    property CVR0 : TBits_1 read getCVR0 write setCVR0;
    property CVR1 : TBits_1 read getCVR1 write setCVR1;
    property CVR2 : TBits_1 read getCVR2 write setCVR2;
    property CVR3 : TBits_1 read getCVR3 write setCVR3;
    property CVROE : TBits_1 read getCVROE write setCVROE;
    property CVRR : TBits_1 read getCVRR write setCVRR;
    property CVRSS : TBits_1 read getCVRSS write setCVRSS;
    property ON : TBits_1 read getON write setON;
    property w : TBits_32 read getw write setw;
  end;
type
  TCVRRegisters = record
    CVRCONbits : TCVR_CVRCON;
    CVRCON : longWord;
    CVRCONCLR : longWord;
    CVRCONSET : longWord;
    CVRCONINV : longWord;
  end;
  TCMP_CM1CON = record
  private
    function  getCCH : TBits_2; inline;
    function  getCCH0 : TBits_1; inline;
    function  getCCH1 : TBits_1; inline;
    function  getCOE : TBits_1; inline;
    function  getCOUT : TBits_1; inline;
    function  getCPOL : TBits_1; inline;
    function  getCREF : TBits_1; inline;
    function  getEVPOL : TBits_2; inline;
    function  getEVPOL0 : TBits_1; inline;
    function  getEVPOL1 : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCCH(thebits : TBits_2); inline;
    procedure setCCH0(thebits : TBits_1); inline;
    procedure setCCH1(thebits : TBits_1); inline;
    procedure setCOE(thebits : TBits_1); inline;
    procedure setCOUT(thebits : TBits_1); inline;
    procedure setCPOL(thebits : TBits_1); inline;
    procedure setCREF(thebits : TBits_1); inline;
    procedure setEVPOL(thebits : TBits_2); inline;
    procedure setEVPOL0(thebits : TBits_1); inline;
    procedure setEVPOL1(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCCH0; inline;
    procedure clearCCH1; inline;
    procedure clearCOE; inline;
    procedure clearCOUT; inline;
    procedure clearCPOL; inline;
    procedure clearCREF; inline;
    procedure clearEVPOL0; inline;
    procedure clearEVPOL1; inline;
    procedure clearON; inline;
    procedure setCCH0; inline;
    procedure setCCH1; inline;
    procedure setCOE; inline;
    procedure setCOUT; inline;
    procedure setCPOL; inline;
    procedure setCREF; inline;
    procedure setEVPOL0; inline;
    procedure setEVPOL1; inline;
    procedure setON; inline;
    property CCH : TBits_2 read getCCH write setCCH;
    property CCH0 : TBits_1 read getCCH0 write setCCH0;
    property CCH1 : TBits_1 read getCCH1 write setCCH1;
    property COE : TBits_1 read getCOE write setCOE;
    property COUT : TBits_1 read getCOUT write setCOUT;
    property CPOL : TBits_1 read getCPOL write setCPOL;
    property CREF : TBits_1 read getCREF write setCREF;
    property EVPOL : TBits_2 read getEVPOL write setEVPOL;
    property EVPOL0 : TBits_1 read getEVPOL0 write setEVPOL0;
    property EVPOL1 : TBits_1 read getEVPOL1 write setEVPOL1;
    property ON : TBits_1 read getON write setON;
    property w : TBits_32 read getw write setw;
  end;
  TCMP_CM2CON = record
  private
    function  getCCH : TBits_2; inline;
    function  getCCH0 : TBits_1; inline;
    function  getCCH1 : TBits_1; inline;
    function  getCOE : TBits_1; inline;
    function  getCOUT : TBits_1; inline;
    function  getCPOL : TBits_1; inline;
    function  getCREF : TBits_1; inline;
    function  getEVPOL : TBits_2; inline;
    function  getEVPOL0 : TBits_1; inline;
    function  getEVPOL1 : TBits_1; inline;
    function  getON : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCCH(thebits : TBits_2); inline;
    procedure setCCH0(thebits : TBits_1); inline;
    procedure setCCH1(thebits : TBits_1); inline;
    procedure setCOE(thebits : TBits_1); inline;
    procedure setCOUT(thebits : TBits_1); inline;
    procedure setCPOL(thebits : TBits_1); inline;
    procedure setCREF(thebits : TBits_1); inline;
    procedure setEVPOL(thebits : TBits_2); inline;
    procedure setEVPOL0(thebits : TBits_1); inline;
    procedure setEVPOL1(thebits : TBits_1); inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCCH0; inline;
    procedure clearCCH1; inline;
    procedure clearCOE; inline;
    procedure clearCOUT; inline;
    procedure clearCPOL; inline;
    procedure clearCREF; inline;
    procedure clearEVPOL0; inline;
    procedure clearEVPOL1; inline;
    procedure clearON; inline;
    procedure setCCH0; inline;
    procedure setCCH1; inline;
    procedure setCOE; inline;
    procedure setCOUT; inline;
    procedure setCPOL; inline;
    procedure setCREF; inline;
    procedure setEVPOL0; inline;
    procedure setEVPOL1; inline;
    procedure setON; inline;
    property CCH : TBits_2 read getCCH write setCCH;
    property CCH0 : TBits_1 read getCCH0 write setCCH0;
    property CCH1 : TBits_1 read getCCH1 write setCCH1;
    property COE : TBits_1 read getCOE write setCOE;
    property COUT : TBits_1 read getCOUT write setCOUT;
    property CPOL : TBits_1 read getCPOL write setCPOL;
    property CREF : TBits_1 read getCREF write setCREF;
    property EVPOL : TBits_2 read getEVPOL write setEVPOL;
    property EVPOL0 : TBits_1 read getEVPOL0 write setEVPOL0;
    property EVPOL1 : TBits_1 read getEVPOL1 write setEVPOL1;
    property ON : TBits_1 read getON write setON;
    property w : TBits_32 read getw write setw;
  end;
  TCMP_CMSTAT = record
  private
    function  getC1OUT : TBits_1; inline;
    function  getC2OUT : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setC1OUT(thebits : TBits_1); inline;
    procedure setC2OUT(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearC1OUT; inline;
    procedure clearC2OUT; inline;
    procedure clearSIDL; inline;
    procedure setC1OUT; inline;
    procedure setC2OUT; inline;
    procedure setSIDL; inline;
    property C1OUT : TBits_1 read getC1OUT write setC1OUT;
    property C2OUT : TBits_1 read getC2OUT write setC2OUT;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
type
  TCMPRegisters = record
    CM1CONbits : TCMP_CM1CON;
    CM1CON : longWord;
    CM1CONCLR : longWord;
    CM1CONSET : longWord;
    CM1CONINV : longWord;
    CM2CONbits : TCMP_CM2CON;
    CM2CON : longWord;
    CM2CONCLR : longWord;
    CM2CONSET : longWord;
    CM2CONINV : longWord;
    CMSTATbits : TCMP_CMSTAT;
    CMSTAT : longWord;
    CMSTATCLR : longWord;
    CMSTATSET : longWord;
    CMSTATINV : longWord;
  end;
  TOSC_OSCCON = record
  private
    function  getCF : TBits_1; inline;
    function  getCLKLOCK : TBits_1; inline;
    function  getCOSC : TBits_3; inline;
    function  getCOSC0 : TBits_1; inline;
    function  getCOSC1 : TBits_1; inline;
    function  getCOSC2 : TBits_1; inline;
    function  getFRCDIV : TBits_3; inline;
    function  getFRCDIV0 : TBits_1; inline;
    function  getFRCDIV1 : TBits_1; inline;
    function  getFRCDIV2 : TBits_1; inline;
    function  getLOCK : TBits_1; inline;
    function  getNOSC : TBits_3; inline;
    function  getNOSC0 : TBits_1; inline;
    function  getNOSC1 : TBits_1; inline;
    function  getNOSC2 : TBits_1; inline;
    function  getOSWEN : TBits_1; inline;
    function  getPBDIV : TBits_2; inline;
    function  getPBDIV0 : TBits_1; inline;
    function  getPBDIV1 : TBits_1; inline;
    function  getPLLMULT : TBits_3; inline;
    function  getPLLMULT0 : TBits_1; inline;
    function  getPLLMULT1 : TBits_1; inline;
    function  getPLLMULT2 : TBits_1; inline;
    function  getPLLODIV : TBits_3; inline;
    function  getPLLODIV0 : TBits_1; inline;
    function  getPLLODIV1 : TBits_1; inline;
    function  getPLLODIV2 : TBits_1; inline;
    function  getSLPEN : TBits_1; inline;
    function  getSOSCEN : TBits_1; inline;
    function  getSOSCRDY : TBits_1; inline;
    function  getUFRCEN : TBits_1; inline;
    function  getULOCK : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCF(thebits : TBits_1); inline;
    procedure setCLKLOCK(thebits : TBits_1); inline;
    procedure setCOSC(thebits : TBits_3); inline;
    procedure setCOSC0(thebits : TBits_1); inline;
    procedure setCOSC1(thebits : TBits_1); inline;
    procedure setCOSC2(thebits : TBits_1); inline;
    procedure setFRCDIV(thebits : TBits_3); inline;
    procedure setFRCDIV0(thebits : TBits_1); inline;
    procedure setFRCDIV1(thebits : TBits_1); inline;
    procedure setFRCDIV2(thebits : TBits_1); inline;
    procedure setLOCK(thebits : TBits_1); inline;
    procedure setNOSC(thebits : TBits_3); inline;
    procedure setNOSC0(thebits : TBits_1); inline;
    procedure setNOSC1(thebits : TBits_1); inline;
    procedure setNOSC2(thebits : TBits_1); inline;
    procedure setOSWEN(thebits : TBits_1); inline;
    procedure setPBDIV(thebits : TBits_2); inline;
    procedure setPBDIV0(thebits : TBits_1); inline;
    procedure setPBDIV1(thebits : TBits_1); inline;
    procedure setPLLMULT(thebits : TBits_3); inline;
    procedure setPLLMULT0(thebits : TBits_1); inline;
    procedure setPLLMULT1(thebits : TBits_1); inline;
    procedure setPLLMULT2(thebits : TBits_1); inline;
    procedure setPLLODIV(thebits : TBits_3); inline;
    procedure setPLLODIV0(thebits : TBits_1); inline;
    procedure setPLLODIV1(thebits : TBits_1); inline;
    procedure setPLLODIV2(thebits : TBits_1); inline;
    procedure setSLPEN(thebits : TBits_1); inline;
    procedure setSOSCEN(thebits : TBits_1); inline;
    procedure setSOSCRDY(thebits : TBits_1); inline;
    procedure setUFRCEN(thebits : TBits_1); inline;
    procedure setULOCK(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCF; inline;
    procedure clearCLKLOCK; inline;
    procedure clearCOSC0; inline;
    procedure clearCOSC1; inline;
    procedure clearCOSC2; inline;
    procedure clearFRCDIV0; inline;
    procedure clearFRCDIV1; inline;
    procedure clearFRCDIV2; inline;
    procedure clearLOCK; inline;
    procedure clearNOSC0; inline;
    procedure clearNOSC1; inline;
    procedure clearNOSC2; inline;
    procedure clearOSWEN; inline;
    procedure clearPBDIV0; inline;
    procedure clearPBDIV1; inline;
    procedure clearPLLMULT0; inline;
    procedure clearPLLMULT1; inline;
    procedure clearPLLMULT2; inline;
    procedure clearPLLODIV0; inline;
    procedure clearPLLODIV1; inline;
    procedure clearPLLODIV2; inline;
    procedure clearSLPEN; inline;
    procedure clearSOSCEN; inline;
    procedure clearSOSCRDY; inline;
    procedure clearUFRCEN; inline;
    procedure clearULOCK; inline;
    procedure setCF; inline;
    procedure setCLKLOCK; inline;
    procedure setCOSC0; inline;
    procedure setCOSC1; inline;
    procedure setCOSC2; inline;
    procedure setFRCDIV0; inline;
    procedure setFRCDIV1; inline;
    procedure setFRCDIV2; inline;
    procedure setLOCK; inline;
    procedure setNOSC0; inline;
    procedure setNOSC1; inline;
    procedure setNOSC2; inline;
    procedure setOSWEN; inline;
    procedure setPBDIV0; inline;
    procedure setPBDIV1; inline;
    procedure setPLLMULT0; inline;
    procedure setPLLMULT1; inline;
    procedure setPLLMULT2; inline;
    procedure setPLLODIV0; inline;
    procedure setPLLODIV1; inline;
    procedure setPLLODIV2; inline;
    procedure setSLPEN; inline;
    procedure setSOSCEN; inline;
    procedure setSOSCRDY; inline;
    procedure setUFRCEN; inline;
    procedure setULOCK; inline;
    property CF : TBits_1 read getCF write setCF;
    property CLKLOCK : TBits_1 read getCLKLOCK write setCLKLOCK;
    property COSC : TBits_3 read getCOSC write setCOSC;
    property COSC0 : TBits_1 read getCOSC0 write setCOSC0;
    property COSC1 : TBits_1 read getCOSC1 write setCOSC1;
    property COSC2 : TBits_1 read getCOSC2 write setCOSC2;
    property FRCDIV : TBits_3 read getFRCDIV write setFRCDIV;
    property FRCDIV0 : TBits_1 read getFRCDIV0 write setFRCDIV0;
    property FRCDIV1 : TBits_1 read getFRCDIV1 write setFRCDIV1;
    property FRCDIV2 : TBits_1 read getFRCDIV2 write setFRCDIV2;
    property LOCK : TBits_1 read getLOCK write setLOCK;
    property NOSC : TBits_3 read getNOSC write setNOSC;
    property NOSC0 : TBits_1 read getNOSC0 write setNOSC0;
    property NOSC1 : TBits_1 read getNOSC1 write setNOSC1;
    property NOSC2 : TBits_1 read getNOSC2 write setNOSC2;
    property OSWEN : TBits_1 read getOSWEN write setOSWEN;
    property PBDIV : TBits_2 read getPBDIV write setPBDIV;
    property PBDIV0 : TBits_1 read getPBDIV0 write setPBDIV0;
    property PBDIV1 : TBits_1 read getPBDIV1 write setPBDIV1;
    property PLLMULT : TBits_3 read getPLLMULT write setPLLMULT;
    property PLLMULT0 : TBits_1 read getPLLMULT0 write setPLLMULT0;
    property PLLMULT1 : TBits_1 read getPLLMULT1 write setPLLMULT1;
    property PLLMULT2 : TBits_1 read getPLLMULT2 write setPLLMULT2;
    property PLLODIV : TBits_3 read getPLLODIV write setPLLODIV;
    property PLLODIV0 : TBits_1 read getPLLODIV0 write setPLLODIV0;
    property PLLODIV1 : TBits_1 read getPLLODIV1 write setPLLODIV1;
    property PLLODIV2 : TBits_1 read getPLLODIV2 write setPLLODIV2;
    property SLPEN : TBits_1 read getSLPEN write setSLPEN;
    property SOSCEN : TBits_1 read getSOSCEN write setSOSCEN;
    property SOSCRDY : TBits_1 read getSOSCRDY write setSOSCRDY;
    property UFRCEN : TBits_1 read getUFRCEN write setUFRCEN;
    property ULOCK : TBits_1 read getULOCK write setULOCK;
    property w : TBits_32 read getw write setw;
  end;
  TOSC_OSCTUN = record
  private
    function  getTUN : TBits_6; inline;
    function  getTUN0 : TBits_1; inline;
    function  getTUN1 : TBits_1; inline;
    function  getTUN2 : TBits_1; inline;
    function  getTUN3 : TBits_1; inline;
    function  getTUN4 : TBits_1; inline;
    function  getTUN5 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setTUN(thebits : TBits_6); inline;
    procedure setTUN0(thebits : TBits_1); inline;
    procedure setTUN1(thebits : TBits_1); inline;
    procedure setTUN2(thebits : TBits_1); inline;
    procedure setTUN3(thebits : TBits_1); inline;
    procedure setTUN4(thebits : TBits_1); inline;
    procedure setTUN5(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearTUN0; inline;
    procedure clearTUN1; inline;
    procedure clearTUN2; inline;
    procedure clearTUN3; inline;
    procedure clearTUN4; inline;
    procedure clearTUN5; inline;
    procedure setTUN0; inline;
    procedure setTUN1; inline;
    procedure setTUN2; inline;
    procedure setTUN3; inline;
    procedure setTUN4; inline;
    procedure setTUN5; inline;
    property TUN : TBits_6 read getTUN write setTUN;
    property TUN0 : TBits_1 read getTUN0 write setTUN0;
    property TUN1 : TBits_1 read getTUN1 write setTUN1;
    property TUN2 : TBits_1 read getTUN2 write setTUN2;
    property TUN3 : TBits_1 read getTUN3 write setTUN3;
    property TUN4 : TBits_1 read getTUN4 write setTUN4;
    property TUN5 : TBits_1 read getTUN5 write setTUN5;
    property w : TBits_32 read getw write setw;
  end;
type
  TOSCRegisters = record
    OSCCONbits : TOSC_OSCCON;
    OSCCON : longWord;
    OSCCONCLR : longWord;
    OSCCONSET : longWord;
    OSCCONINV : longWord;
    OSCTUNbits : TOSC_OSCTUN;
    OSCTUN : longWord;
    OSCTUNCLR : longWord;
    OSCTUNSET : longWord;
    OSCTUNINV : longWord;
  end;
type
  TCFGRegisters = record
    DDPCON : longWord;
    DEVID : longWord;
    SYSKEY : longWord;
    SYSKEYCLR : longWord;
    SYSKEYSET : longWord;
    SYSKEYINV : longWord;
  end;
  TNVM_NVMCON = record
  private
    function  getLVDERR : TBits_1; inline;
    function  getLVDSTAT : TBits_1; inline;
    function  getNVMOP : TBits_4; inline;
    function  getNVMOP0 : TBits_1; inline;
    function  getNVMOP1 : TBits_1; inline;
    function  getNVMOP2 : TBits_1; inline;
    function  getNVMOP3 : TBits_1; inline;
    function  getPROGOP : TBits_4; inline;
    function  getPROGOP0 : TBits_1; inline;
    function  getPROGOP1 : TBits_1; inline;
    function  getPROGOP2 : TBits_1; inline;
    function  getPROGOP3 : TBits_1; inline;
    function  getWR : TBits_1; inline;
    function  getWREN : TBits_1; inline;
    function  getWRERR : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setLVDERR(thebits : TBits_1); inline;
    procedure setLVDSTAT(thebits : TBits_1); inline;
    procedure setNVMOP(thebits : TBits_4); inline;
    procedure setNVMOP0(thebits : TBits_1); inline;
    procedure setNVMOP1(thebits : TBits_1); inline;
    procedure setNVMOP2(thebits : TBits_1); inline;
    procedure setNVMOP3(thebits : TBits_1); inline;
    procedure setPROGOP(thebits : TBits_4); inline;
    procedure setPROGOP0(thebits : TBits_1); inline;
    procedure setPROGOP1(thebits : TBits_1); inline;
    procedure setPROGOP2(thebits : TBits_1); inline;
    procedure setPROGOP3(thebits : TBits_1); inline;
    procedure setWR(thebits : TBits_1); inline;
    procedure setWREN(thebits : TBits_1); inline;
    procedure setWRERR(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearLVDERR; inline;
    procedure clearLVDSTAT; inline;
    procedure clearNVMOP0; inline;
    procedure clearNVMOP1; inline;
    procedure clearNVMOP2; inline;
    procedure clearNVMOP3; inline;
    procedure clearPROGOP0; inline;
    procedure clearPROGOP1; inline;
    procedure clearPROGOP2; inline;
    procedure clearPROGOP3; inline;
    procedure clearWR; inline;
    procedure clearWREN; inline;
    procedure clearWRERR; inline;
    procedure setLVDERR; inline;
    procedure setLVDSTAT; inline;
    procedure setNVMOP0; inline;
    procedure setNVMOP1; inline;
    procedure setNVMOP2; inline;
    procedure setNVMOP3; inline;
    procedure setPROGOP0; inline;
    procedure setPROGOP1; inline;
    procedure setPROGOP2; inline;
    procedure setPROGOP3; inline;
    procedure setWR; inline;
    procedure setWREN; inline;
    procedure setWRERR; inline;
    property LVDERR : TBits_1 read getLVDERR write setLVDERR;
    property LVDSTAT : TBits_1 read getLVDSTAT write setLVDSTAT;
    property NVMOP : TBits_4 read getNVMOP write setNVMOP;
    property NVMOP0 : TBits_1 read getNVMOP0 write setNVMOP0;
    property NVMOP1 : TBits_1 read getNVMOP1 write setNVMOP1;
    property NVMOP2 : TBits_1 read getNVMOP2 write setNVMOP2;
    property NVMOP3 : TBits_1 read getNVMOP3 write setNVMOP3;
    property PROGOP : TBits_4 read getPROGOP write setPROGOP;
    property PROGOP0 : TBits_1 read getPROGOP0 write setPROGOP0;
    property PROGOP1 : TBits_1 read getPROGOP1 write setPROGOP1;
    property PROGOP2 : TBits_1 read getPROGOP2 write setPROGOP2;
    property PROGOP3 : TBits_1 read getPROGOP3 write setPROGOP3;
    property WR : TBits_1 read getWR write setWR;
    property WREN : TBits_1 read getWREN write setWREN;
    property WRERR : TBits_1 read getWRERR write setWRERR;
    property w : TBits_32 read getw write setw;
  end;
type
  TNVMRegisters = record
    NVMCONbits : TNVM_NVMCON;
    NVMCON : longWord;
    NVMCONCLR : longWord;
    NVMCONSET : longWord;
    NVMCONINV : longWord;
    NVMKEY : longWord;
    NVMADDR : longWord;
    NVMADDRCLR : longWord;
    NVMADDRSET : longWord;
    NVMADDRINV : longWord;
    NVMDATA : longWord;
    NVMSRCADDR : longWord;
  end;
  TRCON_RCON = record
  private
    function  getBOR : TBits_1; inline;
    function  getCMR : TBits_1; inline;
    function  getEXTR : TBits_1; inline;
    function  getIDLE : TBits_1; inline;
    function  getPOR : TBits_1; inline;
    function  getSLEEP : TBits_1; inline;
    function  getSWR : TBits_1; inline;
    function  getVREGS : TBits_1; inline;
    function  getWDTO : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setBOR(thebits : TBits_1); inline;
    procedure setCMR(thebits : TBits_1); inline;
    procedure setEXTR(thebits : TBits_1); inline;
    procedure setIDLE(thebits : TBits_1); inline;
    procedure setPOR(thebits : TBits_1); inline;
    procedure setSLEEP(thebits : TBits_1); inline;
    procedure setSWR(thebits : TBits_1); inline;
    procedure setVREGS(thebits : TBits_1); inline;
    procedure setWDTO(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearBOR; inline;
    procedure clearCMR; inline;
    procedure clearEXTR; inline;
    procedure clearIDLE; inline;
    procedure clearPOR; inline;
    procedure clearSLEEP; inline;
    procedure clearSWR; inline;
    procedure clearVREGS; inline;
    procedure clearWDTO; inline;
    procedure setBOR; inline;
    procedure setCMR; inline;
    procedure setEXTR; inline;
    procedure setIDLE; inline;
    procedure setPOR; inline;
    procedure setSLEEP; inline;
    procedure setSWR; inline;
    procedure setVREGS; inline;
    procedure setWDTO; inline;
    property BOR : TBits_1 read getBOR write setBOR;
    property CMR : TBits_1 read getCMR write setCMR;
    property EXTR : TBits_1 read getEXTR write setEXTR;
    property IDLE : TBits_1 read getIDLE write setIDLE;
    property POR : TBits_1 read getPOR write setPOR;
    property SLEEP : TBits_1 read getSLEEP write setSLEEP;
    property SWR : TBits_1 read getSWR write setSWR;
    property VREGS : TBits_1 read getVREGS write setVREGS;
    property WDTO : TBits_1 read getWDTO write setWDTO;
    property w : TBits_32 read getw write setw;
  end;
  TRCON_RSWRST = record
  private
    function  getSWRST : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setSWRST(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearSWRST; inline;
    procedure setSWRST; inline;
    property SWRST : TBits_1 read getSWRST write setSWRST;
    property w : TBits_32 read getw write setw;
  end;
type
  TRCONRegisters = record
    RCONbits : TRCON_RCON;
    RCON : longWord;
    RCONCLR : longWord;
    RCONSET : longWord;
    RCONINV : longWord;
    RSWRSTbits : TRCON_RSWRST;
    RSWRST : longWord;
    RSWRSTCLR : longWord;
    RSWRSTSET : longWord;
    RSWRSTINV : longWord;
  end;
type
  T_DDPSTATRegisters = record
    _DDPSTAT : longWord;
  end;
type
  T_STRORegisters = record
    _STRO : longWord;
    _STROCLR : longWord;
    _STROSET : longWord;
    _STROINV : longWord;
  end;
type
  T_APPORegisters = record
    _APPO : longWord;
    _APPOCLR : longWord;
    _APPOSET : longWord;
    _APPOINV : longWord;
  end;
type
  T_APPIRegisters = record
    _APPI : longWord;
  end;
  TINT_INTSTAT = record
  private
    function  getRIPL : TBits_3; inline;
    function  getSRIPL : TBits_3; inline;
    function  getVEC : TBits_6; inline;
    procedure setRIPL(thebits : TBits_3); inline;
    procedure setSRIPL(thebits : TBits_3); inline;
    procedure setVEC(thebits : TBits_6); inline;
  public
    property RIPL : TBits_3 read getRIPL write setRIPL;
    property SRIPL : TBits_3 read getSRIPL write setSRIPL;
    property VEC : TBits_6 read getVEC write setVEC;
  end;
type
  TINTRegisters = record
    INTCON : longWord;
    INTCONCLR : longWord;
    INTCONSET : longWord;
    INTCONINV : longWord;
    INTSTATbits : TINT_INTSTAT;
    INTSTAT : longWord;
    IPTMR : longWord;
    IPTMRCLR : longWord;
    IPTMRSET : longWord;
    IPTMRINV : longWord;
    IFS0 : longWord;
    IFS0CLR : longWord;
    IFS0SET : longWord;
    IFS0INV : longWord;
    IFS1 : longWord;
    IFS1CLR : longWord;
    IFS1SET : longWord;
    IFS1INV : longWord;
    IEC0 : longWord;
    IEC0CLR : longWord;
    IEC0SET : longWord;
    IEC0INV : longWord;
    IEC1 : longWord;
    IEC1CLR : longWord;
    IEC1SET : longWord;
    IEC1INV : longWord;
    IPC0 : longWord;
    IPC0CLR : longWord;
    IPC0SET : longWord;
    IPC0INV : longWord;
    IPC1 : longWord;
    IPC1CLR : longWord;
    IPC1SET : longWord;
    IPC1INV : longWord;
    IPC2 : longWord;
    IPC2CLR : longWord;
    IPC2SET : longWord;
    IPC2INV : longWord;
    IPC3 : longWord;
    IPC3CLR : longWord;
    IPC3SET : longWord;
    IPC3INV : longWord;
    IPC4 : longWord;
    IPC4CLR : longWord;
    IPC4SET : longWord;
    IPC4INV : longWord;
    IPC5 : longWord;
    IPC5CLR : longWord;
    IPC5SET : longWord;
    IPC5INV : longWord;
    IPC6 : longWord;
    IPC6CLR : longWord;
    IPC6SET : longWord;
    IPC6INV : longWord;
    IPC7 : longWord;
    IPC7CLR : longWord;
    IPC7SET : longWord;
    IPC7INV : longWord;
    IPC8 : longWord;
    IPC8CLR : longWord;
    IPC8SET : longWord;
    IPC8INV : longWord;
    IPC11 : longWord;
    IPC11CLR : longWord;
    IPC11SET : longWord;
    IPC11INV : longWord;
  end;
  TBMX_BMXCON = record
  private
    function  getBMXARB : TBits_3; inline;
    function  getBMXCHEDMA : TBits_1; inline;
    function  getBMXERRDMA : TBits_1; inline;
    function  getBMXERRDS : TBits_1; inline;
    function  getBMXERRICD : TBits_1; inline;
    function  getBMXERRIS : TBits_1; inline;
    function  getBMXERRIXI : TBits_1; inline;
    function  getBMXWSDRM : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setBMXARB(thebits : TBits_3); inline;
    procedure setBMXCHEDMA(thebits : TBits_1); inline;
    procedure setBMXERRDMA(thebits : TBits_1); inline;
    procedure setBMXERRDS(thebits : TBits_1); inline;
    procedure setBMXERRICD(thebits : TBits_1); inline;
    procedure setBMXERRIS(thebits : TBits_1); inline;
    procedure setBMXERRIXI(thebits : TBits_1); inline;
    procedure setBMXWSDRM(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearBMXCHEDMA; inline;
    procedure clearBMXERRDMA; inline;
    procedure clearBMXERRDS; inline;
    procedure clearBMXERRICD; inline;
    procedure clearBMXERRIS; inline;
    procedure clearBMXERRIXI; inline;
    procedure clearBMXWSDRM; inline;
    procedure setBMXCHEDMA; inline;
    procedure setBMXERRDMA; inline;
    procedure setBMXERRDS; inline;
    procedure setBMXERRICD; inline;
    procedure setBMXERRIS; inline;
    procedure setBMXERRIXI; inline;
    procedure setBMXWSDRM; inline;
    property BMXARB : TBits_3 read getBMXARB write setBMXARB;
    property BMXCHEDMA : TBits_1 read getBMXCHEDMA write setBMXCHEDMA;
    property BMXERRDMA : TBits_1 read getBMXERRDMA write setBMXERRDMA;
    property BMXERRDS : TBits_1 read getBMXERRDS write setBMXERRDS;
    property BMXERRICD : TBits_1 read getBMXERRICD write setBMXERRICD;
    property BMXERRIS : TBits_1 read getBMXERRIS write setBMXERRIS;
    property BMXERRIXI : TBits_1 read getBMXERRIXI write setBMXERRIXI;
    property BMXWSDRM : TBits_1 read getBMXWSDRM write setBMXWSDRM;
    property w : TBits_32 read getw write setw;
  end;
type
  TBMXRegisters = record
    BMXCONbits : TBMX_BMXCON;
    BMXCON : longWord;
    BMXCONCLR : longWord;
    BMXCONSET : longWord;
    BMXCONINV : longWord;
    BMXDKPBA : longWord;
    BMXDKPBACLR : longWord;
    BMXDKPBASET : longWord;
    BMXDKPBAINV : longWord;
    BMXDUDBA : longWord;
    BMXDUDBACLR : longWord;
    BMXDUDBASET : longWord;
    BMXDUDBAINV : longWord;
    BMXDUPBA : longWord;
    BMXDUPBACLR : longWord;
    BMXDUPBASET : longWord;
    BMXDUPBAINV : longWord;
    BMXDRMSZ : longWord;
    BMXPUPBA : longWord;
    BMXPUPBACLR : longWord;
    BMXPUPBASET : longWord;
    BMXPUPBAINV : longWord;
    BMXPFMSZ : longWord;
    BMXBOOTSZ : longWord;
  end;
  TPCACHE_CHECON = record
  private
    function  getCHECOH : TBits_1; inline;
    function  getDCSZ : TBits_2; inline;
    function  getPFMWS : TBits_3; inline;
    function  getPREFEN : TBits_2; inline;
    function  getw : TBits_32; inline;
    procedure setCHECOH(thebits : TBits_1); inline;
    procedure setDCSZ(thebits : TBits_2); inline;
    procedure setPFMWS(thebits : TBits_3); inline;
    procedure setPREFEN(thebits : TBits_2); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCHECOH; inline;
    procedure setCHECOH; inline;
    property CHECOH : TBits_1 read getCHECOH write setCHECOH;
    property DCSZ : TBits_2 read getDCSZ write setDCSZ;
    property PFMWS : TBits_3 read getPFMWS write setPFMWS;
    property PREFEN : TBits_2 read getPREFEN write setPREFEN;
    property w : TBits_32 read getw write setw;
  end;
  TPCACHE_CHETAG = record
  private
    function  getLLOCK : TBits_1; inline;
    function  getLTAG : TBits_20; inline;
    function  getLTAGBOOT : TBits_1; inline;
    function  getLTYPE : TBits_1; inline;
    function  getLVALID : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setLLOCK(thebits : TBits_1); inline;
    procedure setLTAG(thebits : TBits_20); inline;
    procedure setLTAGBOOT(thebits : TBits_1); inline;
    procedure setLTYPE(thebits : TBits_1); inline;
    procedure setLVALID(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearLLOCK; inline;
    procedure clearLTAGBOOT; inline;
    procedure clearLTYPE; inline;
    procedure clearLVALID; inline;
    procedure setLLOCK; inline;
    procedure setLTAGBOOT; inline;
    procedure setLTYPE; inline;
    procedure setLVALID; inline;
    property LLOCK : TBits_1 read getLLOCK write setLLOCK;
    property LTAG : TBits_20 read getLTAG write setLTAG;
    property LTAGBOOT : TBits_1 read getLTAGBOOT write setLTAGBOOT;
    property LTYPE : TBits_1 read getLTYPE write setLTYPE;
    property LVALID : TBits_1 read getLVALID write setLVALID;
    property w : TBits_32 read getw write setw;
  end;
type
  TPCACHERegisters = record
    CHECONbits : TPCACHE_CHECON;
    CHECON : longWord;
    CHECONCLR : longWord;
    CHECONSET : longWord;
    CHECONINV : longWord;
    CHEACC : longWord;
    CHEACCCLR : longWord;
    CHEACCSET : longWord;
    CHEACCINV : longWord;
    CHETAGbits : TPCACHE_CHETAG;
    CHETAG : longWord;
    CHETAGCLR : longWord;
    CHETAGSET : longWord;
    CHETAGINV : longWord;
    CHEMSK : longWord;
    CHEMSKCLR : longWord;
    CHEMSKSET : longWord;
    CHEMSKINV : longWord;
    CHEW0 : longWord;
    CHEW1 : longWord;
    CHEW2 : longWord;
    CHEW3 : longWord;
    CHELRU : longWord;
    CHEHIT : longWord;
    CHEMIS : longWord;
    CHEPFABT : longWord;
  end;
  TPORTB_TRISB = record
  private
    function  getTRISB0 : TBits_1; inline;
    function  getTRISB1 : TBits_1; inline;
    function  getTRISB10 : TBits_1; inline;
    function  getTRISB11 : TBits_1; inline;
    function  getTRISB12 : TBits_1; inline;
    function  getTRISB13 : TBits_1; inline;
    function  getTRISB14 : TBits_1; inline;
    function  getTRISB15 : TBits_1; inline;
    function  getTRISB2 : TBits_1; inline;
    function  getTRISB3 : TBits_1; inline;
    function  getTRISB4 : TBits_1; inline;
    function  getTRISB5 : TBits_1; inline;
    function  getTRISB6 : TBits_1; inline;
    function  getTRISB7 : TBits_1; inline;
    function  getTRISB8 : TBits_1; inline;
    function  getTRISB9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setTRISB0(thebits : TBits_1); inline;
    procedure setTRISB1(thebits : TBits_1); inline;
    procedure setTRISB10(thebits : TBits_1); inline;
    procedure setTRISB11(thebits : TBits_1); inline;
    procedure setTRISB12(thebits : TBits_1); inline;
    procedure setTRISB13(thebits : TBits_1); inline;
    procedure setTRISB14(thebits : TBits_1); inline;
    procedure setTRISB15(thebits : TBits_1); inline;
    procedure setTRISB2(thebits : TBits_1); inline;
    procedure setTRISB3(thebits : TBits_1); inline;
    procedure setTRISB4(thebits : TBits_1); inline;
    procedure setTRISB5(thebits : TBits_1); inline;
    procedure setTRISB6(thebits : TBits_1); inline;
    procedure setTRISB7(thebits : TBits_1); inline;
    procedure setTRISB8(thebits : TBits_1); inline;
    procedure setTRISB9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearTRISB0; inline;
    procedure clearTRISB10; inline;
    procedure clearTRISB11; inline;
    procedure clearTRISB12; inline;
    procedure clearTRISB13; inline;
    procedure clearTRISB14; inline;
    procedure clearTRISB15; inline;
    procedure clearTRISB1; inline;
    procedure clearTRISB2; inline;
    procedure clearTRISB3; inline;
    procedure clearTRISB4; inline;
    procedure clearTRISB5; inline;
    procedure clearTRISB6; inline;
    procedure clearTRISB7; inline;
    procedure clearTRISB8; inline;
    procedure clearTRISB9; inline;
    procedure setTRISB0; inline;
    procedure setTRISB10; inline;
    procedure setTRISB11; inline;
    procedure setTRISB12; inline;
    procedure setTRISB13; inline;
    procedure setTRISB14; inline;
    procedure setTRISB15; inline;
    procedure setTRISB1; inline;
    procedure setTRISB2; inline;
    procedure setTRISB3; inline;
    procedure setTRISB4; inline;
    procedure setTRISB5; inline;
    procedure setTRISB6; inline;
    procedure setTRISB7; inline;
    procedure setTRISB8; inline;
    procedure setTRISB9; inline;
    property TRISB0 : TBits_1 read getTRISB0 write setTRISB0;
    property TRISB1 : TBits_1 read getTRISB1 write setTRISB1;
    property TRISB10 : TBits_1 read getTRISB10 write setTRISB10;
    property TRISB11 : TBits_1 read getTRISB11 write setTRISB11;
    property TRISB12 : TBits_1 read getTRISB12 write setTRISB12;
    property TRISB13 : TBits_1 read getTRISB13 write setTRISB13;
    property TRISB14 : TBits_1 read getTRISB14 write setTRISB14;
    property TRISB15 : TBits_1 read getTRISB15 write setTRISB15;
    property TRISB2 : TBits_1 read getTRISB2 write setTRISB2;
    property TRISB3 : TBits_1 read getTRISB3 write setTRISB3;
    property TRISB4 : TBits_1 read getTRISB4 write setTRISB4;
    property TRISB5 : TBits_1 read getTRISB5 write setTRISB5;
    property TRISB6 : TBits_1 read getTRISB6 write setTRISB6;
    property TRISB7 : TBits_1 read getTRISB7 write setTRISB7;
    property TRISB8 : TBits_1 read getTRISB8 write setTRISB8;
    property TRISB9 : TBits_1 read getTRISB9 write setTRISB9;
    property w : TBits_32 read getw write setw;
  end;
  TPORTB_PORTB = record
  private
    function  getRB0 : TBits_1; inline;
    function  getRB1 : TBits_1; inline;
    function  getRB10 : TBits_1; inline;
    function  getRB11 : TBits_1; inline;
    function  getRB12 : TBits_1; inline;
    function  getRB13 : TBits_1; inline;
    function  getRB14 : TBits_1; inline;
    function  getRB15 : TBits_1; inline;
    function  getRB2 : TBits_1; inline;
    function  getRB3 : TBits_1; inline;
    function  getRB4 : TBits_1; inline;
    function  getRB5 : TBits_1; inline;
    function  getRB6 : TBits_1; inline;
    function  getRB7 : TBits_1; inline;
    function  getRB8 : TBits_1; inline;
    function  getRB9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setRB0(thebits : TBits_1); inline;
    procedure setRB1(thebits : TBits_1); inline;
    procedure setRB10(thebits : TBits_1); inline;
    procedure setRB11(thebits : TBits_1); inline;
    procedure setRB12(thebits : TBits_1); inline;
    procedure setRB13(thebits : TBits_1); inline;
    procedure setRB14(thebits : TBits_1); inline;
    procedure setRB15(thebits : TBits_1); inline;
    procedure setRB2(thebits : TBits_1); inline;
    procedure setRB3(thebits : TBits_1); inline;
    procedure setRB4(thebits : TBits_1); inline;
    procedure setRB5(thebits : TBits_1); inline;
    procedure setRB6(thebits : TBits_1); inline;
    procedure setRB7(thebits : TBits_1); inline;
    procedure setRB8(thebits : TBits_1); inline;
    procedure setRB9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearRB0; inline;
    procedure clearRB10; inline;
    procedure clearRB11; inline;
    procedure clearRB12; inline;
    procedure clearRB13; inline;
    procedure clearRB14; inline;
    procedure clearRB15; inline;
    procedure clearRB1; inline;
    procedure clearRB2; inline;
    procedure clearRB3; inline;
    procedure clearRB4; inline;
    procedure clearRB5; inline;
    procedure clearRB6; inline;
    procedure clearRB7; inline;
    procedure clearRB8; inline;
    procedure clearRB9; inline;
    procedure setRB0; inline;
    procedure setRB10; inline;
    procedure setRB11; inline;
    procedure setRB12; inline;
    procedure setRB13; inline;
    procedure setRB14; inline;
    procedure setRB15; inline;
    procedure setRB1; inline;
    procedure setRB2; inline;
    procedure setRB3; inline;
    procedure setRB4; inline;
    procedure setRB5; inline;
    procedure setRB6; inline;
    procedure setRB7; inline;
    procedure setRB8; inline;
    procedure setRB9; inline;
    property RB0 : TBits_1 read getRB0 write setRB0;
    property RB1 : TBits_1 read getRB1 write setRB1;
    property RB10 : TBits_1 read getRB10 write setRB10;
    property RB11 : TBits_1 read getRB11 write setRB11;
    property RB12 : TBits_1 read getRB12 write setRB12;
    property RB13 : TBits_1 read getRB13 write setRB13;
    property RB14 : TBits_1 read getRB14 write setRB14;
    property RB15 : TBits_1 read getRB15 write setRB15;
    property RB2 : TBits_1 read getRB2 write setRB2;
    property RB3 : TBits_1 read getRB3 write setRB3;
    property RB4 : TBits_1 read getRB4 write setRB4;
    property RB5 : TBits_1 read getRB5 write setRB5;
    property RB6 : TBits_1 read getRB6 write setRB6;
    property RB7 : TBits_1 read getRB7 write setRB7;
    property RB8 : TBits_1 read getRB8 write setRB8;
    property RB9 : TBits_1 read getRB9 write setRB9;
    property w : TBits_32 read getw write setw;
  end;
  TPortB_bits=(RB0=0,RB1=1,RB2=2,RB3=3,RB4=4,RB5=5,RB6=6,RB7=7,RB8=8,RB9=9,RB10=10,RB11=11,RB12=12,RB13=13,RB14=14,RB15=15);
  TPortB_bitset = set of TPortB_bits;
  TPORTB_LATB = record
  private
    function  getLATB0 : TBits_1; inline;
    function  getLATB1 : TBits_1; inline;
    function  getLATB10 : TBits_1; inline;
    function  getLATB11 : TBits_1; inline;
    function  getLATB12 : TBits_1; inline;
    function  getLATB13 : TBits_1; inline;
    function  getLATB14 : TBits_1; inline;
    function  getLATB15 : TBits_1; inline;
    function  getLATB2 : TBits_1; inline;
    function  getLATB3 : TBits_1; inline;
    function  getLATB4 : TBits_1; inline;
    function  getLATB5 : TBits_1; inline;
    function  getLATB6 : TBits_1; inline;
    function  getLATB7 : TBits_1; inline;
    function  getLATB8 : TBits_1; inline;
    function  getLATB9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setLATB0(thebits : TBits_1); inline;
    procedure setLATB1(thebits : TBits_1); inline;
    procedure setLATB10(thebits : TBits_1); inline;
    procedure setLATB11(thebits : TBits_1); inline;
    procedure setLATB12(thebits : TBits_1); inline;
    procedure setLATB13(thebits : TBits_1); inline;
    procedure setLATB14(thebits : TBits_1); inline;
    procedure setLATB15(thebits : TBits_1); inline;
    procedure setLATB2(thebits : TBits_1); inline;
    procedure setLATB3(thebits : TBits_1); inline;
    procedure setLATB4(thebits : TBits_1); inline;
    procedure setLATB5(thebits : TBits_1); inline;
    procedure setLATB6(thebits : TBits_1); inline;
    procedure setLATB7(thebits : TBits_1); inline;
    procedure setLATB8(thebits : TBits_1); inline;
    procedure setLATB9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearLATB0; inline;
    procedure clearLATB10; inline;
    procedure clearLATB11; inline;
    procedure clearLATB12; inline;
    procedure clearLATB13; inline;
    procedure clearLATB14; inline;
    procedure clearLATB15; inline;
    procedure clearLATB1; inline;
    procedure clearLATB2; inline;
    procedure clearLATB3; inline;
    procedure clearLATB4; inline;
    procedure clearLATB5; inline;
    procedure clearLATB6; inline;
    procedure clearLATB7; inline;
    procedure clearLATB8; inline;
    procedure clearLATB9; inline;
    procedure setLATB0; inline;
    procedure setLATB10; inline;
    procedure setLATB11; inline;
    procedure setLATB12; inline;
    procedure setLATB13; inline;
    procedure setLATB14; inline;
    procedure setLATB15; inline;
    procedure setLATB1; inline;
    procedure setLATB2; inline;
    procedure setLATB3; inline;
    procedure setLATB4; inline;
    procedure setLATB5; inline;
    procedure setLATB6; inline;
    procedure setLATB7; inline;
    procedure setLATB8; inline;
    procedure setLATB9; inline;
    property LATB0 : TBits_1 read getLATB0 write setLATB0;
    property LATB1 : TBits_1 read getLATB1 write setLATB1;
    property LATB10 : TBits_1 read getLATB10 write setLATB10;
    property LATB11 : TBits_1 read getLATB11 write setLATB11;
    property LATB12 : TBits_1 read getLATB12 write setLATB12;
    property LATB13 : TBits_1 read getLATB13 write setLATB13;
    property LATB14 : TBits_1 read getLATB14 write setLATB14;
    property LATB15 : TBits_1 read getLATB15 write setLATB15;
    property LATB2 : TBits_1 read getLATB2 write setLATB2;
    property LATB3 : TBits_1 read getLATB3 write setLATB3;
    property LATB4 : TBits_1 read getLATB4 write setLATB4;
    property LATB5 : TBits_1 read getLATB5 write setLATB5;
    property LATB6 : TBits_1 read getLATB6 write setLATB6;
    property LATB7 : TBits_1 read getLATB7 write setLATB7;
    property LATB8 : TBits_1 read getLATB8 write setLATB8;
    property LATB9 : TBits_1 read getLATB9 write setLATB9;
    property w : TBits_32 read getw write setw;
  end;
  TPORTB_ODCB = record
  private
    function  getODCB0 : TBits_1; inline;
    function  getODCB1 : TBits_1; inline;
    function  getODCB10 : TBits_1; inline;
    function  getODCB11 : TBits_1; inline;
    function  getODCB12 : TBits_1; inline;
    function  getODCB13 : TBits_1; inline;
    function  getODCB14 : TBits_1; inline;
    function  getODCB15 : TBits_1; inline;
    function  getODCB2 : TBits_1; inline;
    function  getODCB3 : TBits_1; inline;
    function  getODCB4 : TBits_1; inline;
    function  getODCB5 : TBits_1; inline;
    function  getODCB6 : TBits_1; inline;
    function  getODCB7 : TBits_1; inline;
    function  getODCB8 : TBits_1; inline;
    function  getODCB9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setODCB0(thebits : TBits_1); inline;
    procedure setODCB1(thebits : TBits_1); inline;
    procedure setODCB10(thebits : TBits_1); inline;
    procedure setODCB11(thebits : TBits_1); inline;
    procedure setODCB12(thebits : TBits_1); inline;
    procedure setODCB13(thebits : TBits_1); inline;
    procedure setODCB14(thebits : TBits_1); inline;
    procedure setODCB15(thebits : TBits_1); inline;
    procedure setODCB2(thebits : TBits_1); inline;
    procedure setODCB3(thebits : TBits_1); inline;
    procedure setODCB4(thebits : TBits_1); inline;
    procedure setODCB5(thebits : TBits_1); inline;
    procedure setODCB6(thebits : TBits_1); inline;
    procedure setODCB7(thebits : TBits_1); inline;
    procedure setODCB8(thebits : TBits_1); inline;
    procedure setODCB9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearODCB0; inline;
    procedure clearODCB10; inline;
    procedure clearODCB11; inline;
    procedure clearODCB12; inline;
    procedure clearODCB13; inline;
    procedure clearODCB14; inline;
    procedure clearODCB15; inline;
    procedure clearODCB1; inline;
    procedure clearODCB2; inline;
    procedure clearODCB3; inline;
    procedure clearODCB4; inline;
    procedure clearODCB5; inline;
    procedure clearODCB6; inline;
    procedure clearODCB7; inline;
    procedure clearODCB8; inline;
    procedure clearODCB9; inline;
    procedure setODCB0; inline;
    procedure setODCB10; inline;
    procedure setODCB11; inline;
    procedure setODCB12; inline;
    procedure setODCB13; inline;
    procedure setODCB14; inline;
    procedure setODCB15; inline;
    procedure setODCB1; inline;
    procedure setODCB2; inline;
    procedure setODCB3; inline;
    procedure setODCB4; inline;
    procedure setODCB5; inline;
    procedure setODCB6; inline;
    procedure setODCB7; inline;
    procedure setODCB8; inline;
    procedure setODCB9; inline;
    property ODCB0 : TBits_1 read getODCB0 write setODCB0;
    property ODCB1 : TBits_1 read getODCB1 write setODCB1;
    property ODCB10 : TBits_1 read getODCB10 write setODCB10;
    property ODCB11 : TBits_1 read getODCB11 write setODCB11;
    property ODCB12 : TBits_1 read getODCB12 write setODCB12;
    property ODCB13 : TBits_1 read getODCB13 write setODCB13;
    property ODCB14 : TBits_1 read getODCB14 write setODCB14;
    property ODCB15 : TBits_1 read getODCB15 write setODCB15;
    property ODCB2 : TBits_1 read getODCB2 write setODCB2;
    property ODCB3 : TBits_1 read getODCB3 write setODCB3;
    property ODCB4 : TBits_1 read getODCB4 write setODCB4;
    property ODCB5 : TBits_1 read getODCB5 write setODCB5;
    property ODCB6 : TBits_1 read getODCB6 write setODCB6;
    property ODCB7 : TBits_1 read getODCB7 write setODCB7;
    property ODCB8 : TBits_1 read getODCB8 write setODCB8;
    property ODCB9 : TBits_1 read getODCB9 write setODCB9;
    property w : TBits_32 read getw write setw;
  end;
type
  TPORTBRegisters = record
    TRISBbits : TPORTB_TRISB;
    TRISB : longWord;
    TRISBCLR : longWord;
    TRISBSET : longWord;
    TRISBINV : longWord;
    PORTBbits : TPORTB_PORTB;
    PORTB : longWord;
    PORTBCLR : longWord;
    PORTBSET : longWord;
    PORTBINV : longWord;
    LATBbits : TPORTB_LATB;
    LATB : longWord;
    LATBCLR : longWord;
    LATBSET : longWord;
    LATBINV : longWord;
    ODCBbits : TPORTB_ODCB;
    ODCB : longWord;
    ODCBCLR : longWord;
    ODCBSET : longWord;
    ODCBINV : longWord;
  end;
  TPORTC_TRISC = record
  private
    function  getTRISC12 : TBits_1; inline;
    function  getTRISC13 : TBits_1; inline;
    function  getTRISC14 : TBits_1; inline;
    function  getTRISC15 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setTRISC12(thebits : TBits_1); inline;
    procedure setTRISC13(thebits : TBits_1); inline;
    procedure setTRISC14(thebits : TBits_1); inline;
    procedure setTRISC15(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearTRISC12; inline;
    procedure clearTRISC13; inline;
    procedure clearTRISC14; inline;
    procedure clearTRISC15; inline;
    procedure setTRISC12; inline;
    procedure setTRISC13; inline;
    procedure setTRISC14; inline;
    procedure setTRISC15; inline;
    property TRISC12 : TBits_1 read getTRISC12 write setTRISC12;
    property TRISC13 : TBits_1 read getTRISC13 write setTRISC13;
    property TRISC14 : TBits_1 read getTRISC14 write setTRISC14;
    property TRISC15 : TBits_1 read getTRISC15 write setTRISC15;
    property w : TBits_32 read getw write setw;
  end;
  TPORTC_PORTC = record
  private
    function  getRC12 : TBits_1; inline;
    function  getRC13 : TBits_1; inline;
    function  getRC14 : TBits_1; inline;
    function  getRC15 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setRC12(thebits : TBits_1); inline;
    procedure setRC13(thebits : TBits_1); inline;
    procedure setRC14(thebits : TBits_1); inline;
    procedure setRC15(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearRC12; inline;
    procedure clearRC13; inline;
    procedure clearRC14; inline;
    procedure clearRC15; inline;
    procedure setRC12; inline;
    procedure setRC13; inline;
    procedure setRC14; inline;
    procedure setRC15; inline;
    property RC12 : TBits_1 read getRC12 write setRC12;
    property RC13 : TBits_1 read getRC13 write setRC13;
    property RC14 : TBits_1 read getRC14 write setRC14;
    property RC15 : TBits_1 read getRC15 write setRC15;
    property w : TBits_32 read getw write setw;
  end;
  TPortC_bits=(RC12=12,RC13=13,RC14=14,RC15=15);
  TPortC_bitset = set of TPortC_bits;
  TPORTC_LATC = record
  private
    function  getLATC12 : TBits_1; inline;
    function  getLATC13 : TBits_1; inline;
    function  getLATC14 : TBits_1; inline;
    function  getLATC15 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setLATC12(thebits : TBits_1); inline;
    procedure setLATC13(thebits : TBits_1); inline;
    procedure setLATC14(thebits : TBits_1); inline;
    procedure setLATC15(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearLATC12; inline;
    procedure clearLATC13; inline;
    procedure clearLATC14; inline;
    procedure clearLATC15; inline;
    procedure setLATC12; inline;
    procedure setLATC13; inline;
    procedure setLATC14; inline;
    procedure setLATC15; inline;
    property LATC12 : TBits_1 read getLATC12 write setLATC12;
    property LATC13 : TBits_1 read getLATC13 write setLATC13;
    property LATC14 : TBits_1 read getLATC14 write setLATC14;
    property LATC15 : TBits_1 read getLATC15 write setLATC15;
    property w : TBits_32 read getw write setw;
  end;
  TPORTC_ODCC = record
  private
    function  getODCC12 : TBits_1; inline;
    function  getODCC13 : TBits_1; inline;
    function  getODCC14 : TBits_1; inline;
    function  getODCC15 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setODCC12(thebits : TBits_1); inline;
    procedure setODCC13(thebits : TBits_1); inline;
    procedure setODCC14(thebits : TBits_1); inline;
    procedure setODCC15(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearODCC12; inline;
    procedure clearODCC13; inline;
    procedure clearODCC14; inline;
    procedure clearODCC15; inline;
    procedure setODCC12; inline;
    procedure setODCC13; inline;
    procedure setODCC14; inline;
    procedure setODCC15; inline;
    property ODCC12 : TBits_1 read getODCC12 write setODCC12;
    property ODCC13 : TBits_1 read getODCC13 write setODCC13;
    property ODCC14 : TBits_1 read getODCC14 write setODCC14;
    property ODCC15 : TBits_1 read getODCC15 write setODCC15;
    property w : TBits_32 read getw write setw;
  end;
type
  TPORTCRegisters = record
    TRISCbits : TPORTC_TRISC;
    TRISC : longWord;
    TRISCCLR : longWord;
    TRISCSET : longWord;
    TRISCINV : longWord;
    PORTCbits : TPORTC_PORTC;
    PORTC : longWord;
    PORTCCLR : longWord;
    PORTCSET : longWord;
    PORTCINV : longWord;
    LATCbits : TPORTC_LATC;
    LATC : longWord;
    LATCCLR : longWord;
    LATCSET : longWord;
    LATCINV : longWord;
    ODCCbits : TPORTC_ODCC;
    ODCC : longWord;
    ODCCCLR : longWord;
    ODCCSET : longWord;
    ODCCINV : longWord;
  end;
  TPORTD_TRISD = record
  private
    function  getTRISD0 : TBits_1; inline;
    function  getTRISD1 : TBits_1; inline;
    function  getTRISD10 : TBits_1; inline;
    function  getTRISD11 : TBits_1; inline;
    function  getTRISD2 : TBits_1; inline;
    function  getTRISD3 : TBits_1; inline;
    function  getTRISD4 : TBits_1; inline;
    function  getTRISD5 : TBits_1; inline;
    function  getTRISD6 : TBits_1; inline;
    function  getTRISD7 : TBits_1; inline;
    function  getTRISD8 : TBits_1; inline;
    function  getTRISD9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setTRISD0(thebits : TBits_1); inline;
    procedure setTRISD1(thebits : TBits_1); inline;
    procedure setTRISD10(thebits : TBits_1); inline;
    procedure setTRISD11(thebits : TBits_1); inline;
    procedure setTRISD2(thebits : TBits_1); inline;
    procedure setTRISD3(thebits : TBits_1); inline;
    procedure setTRISD4(thebits : TBits_1); inline;
    procedure setTRISD5(thebits : TBits_1); inline;
    procedure setTRISD6(thebits : TBits_1); inline;
    procedure setTRISD7(thebits : TBits_1); inline;
    procedure setTRISD8(thebits : TBits_1); inline;
    procedure setTRISD9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearTRISD0; inline;
    procedure clearTRISD10; inline;
    procedure clearTRISD11; inline;
    procedure clearTRISD1; inline;
    procedure clearTRISD2; inline;
    procedure clearTRISD3; inline;
    procedure clearTRISD4; inline;
    procedure clearTRISD5; inline;
    procedure clearTRISD6; inline;
    procedure clearTRISD7; inline;
    procedure clearTRISD8; inline;
    procedure clearTRISD9; inline;
    procedure setTRISD0; inline;
    procedure setTRISD10; inline;
    procedure setTRISD11; inline;
    procedure setTRISD1; inline;
    procedure setTRISD2; inline;
    procedure setTRISD3; inline;
    procedure setTRISD4; inline;
    procedure setTRISD5; inline;
    procedure setTRISD6; inline;
    procedure setTRISD7; inline;
    procedure setTRISD8; inline;
    procedure setTRISD9; inline;
    property TRISD0 : TBits_1 read getTRISD0 write setTRISD0;
    property TRISD1 : TBits_1 read getTRISD1 write setTRISD1;
    property TRISD10 : TBits_1 read getTRISD10 write setTRISD10;
    property TRISD11 : TBits_1 read getTRISD11 write setTRISD11;
    property TRISD2 : TBits_1 read getTRISD2 write setTRISD2;
    property TRISD3 : TBits_1 read getTRISD3 write setTRISD3;
    property TRISD4 : TBits_1 read getTRISD4 write setTRISD4;
    property TRISD5 : TBits_1 read getTRISD5 write setTRISD5;
    property TRISD6 : TBits_1 read getTRISD6 write setTRISD6;
    property TRISD7 : TBits_1 read getTRISD7 write setTRISD7;
    property TRISD8 : TBits_1 read getTRISD8 write setTRISD8;
    property TRISD9 : TBits_1 read getTRISD9 write setTRISD9;
    property w : TBits_32 read getw write setw;
  end;
  TPORTD_PORTD = record
  private
    function  getRD0 : TBits_1; inline;
    function  getRD1 : TBits_1; inline;
    function  getRD10 : TBits_1; inline;
    function  getRD11 : TBits_1; inline;
    function  getRD2 : TBits_1; inline;
    function  getRD3 : TBits_1; inline;
    function  getRD4 : TBits_1; inline;
    function  getRD5 : TBits_1; inline;
    function  getRD6 : TBits_1; inline;
    function  getRD7 : TBits_1; inline;
    function  getRD8 : TBits_1; inline;
    function  getRD9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setRD0(thebits : TBits_1); inline;
    procedure setRD1(thebits : TBits_1); inline;
    procedure setRD10(thebits : TBits_1); inline;
    procedure setRD11(thebits : TBits_1); inline;
    procedure setRD2(thebits : TBits_1); inline;
    procedure setRD3(thebits : TBits_1); inline;
    procedure setRD4(thebits : TBits_1); inline;
    procedure setRD5(thebits : TBits_1); inline;
    procedure setRD6(thebits : TBits_1); inline;
    procedure setRD7(thebits : TBits_1); inline;
    procedure setRD8(thebits : TBits_1); inline;
    procedure setRD9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearRD0; inline;
    procedure clearRD10; inline;
    procedure clearRD11; inline;
    procedure clearRD1; inline;
    procedure clearRD2; inline;
    procedure clearRD3; inline;
    procedure clearRD4; inline;
    procedure clearRD5; inline;
    procedure clearRD6; inline;
    procedure clearRD7; inline;
    procedure clearRD8; inline;
    procedure clearRD9; inline;
    procedure setRD0; inline;
    procedure setRD10; inline;
    procedure setRD11; inline;
    procedure setRD1; inline;
    procedure setRD2; inline;
    procedure setRD3; inline;
    procedure setRD4; inline;
    procedure setRD5; inline;
    procedure setRD6; inline;
    procedure setRD7; inline;
    procedure setRD8; inline;
    procedure setRD9; inline;
    property RD0 : TBits_1 read getRD0 write setRD0;
    property RD1 : TBits_1 read getRD1 write setRD1;
    property RD10 : TBits_1 read getRD10 write setRD10;
    property RD11 : TBits_1 read getRD11 write setRD11;
    property RD2 : TBits_1 read getRD2 write setRD2;
    property RD3 : TBits_1 read getRD3 write setRD3;
    property RD4 : TBits_1 read getRD4 write setRD4;
    property RD5 : TBits_1 read getRD5 write setRD5;
    property RD6 : TBits_1 read getRD6 write setRD6;
    property RD7 : TBits_1 read getRD7 write setRD7;
    property RD8 : TBits_1 read getRD8 write setRD8;
    property RD9 : TBits_1 read getRD9 write setRD9;
    property w : TBits_32 read getw write setw;
  end;
  TPortD_bits=(RD0=0,RD1=1,RD2=2,RD3=3,RD4=4,RD5=5,RD6=6,RD7=7,RD8=8,RD9=9,RD10=10,RD11=11);
  TPortD_bitset = set of TPortD_bits;
  TPORTD_LATD = record
  private
    function  getLATD0 : TBits_1; inline;
    function  getLATD1 : TBits_1; inline;
    function  getLATD10 : TBits_1; inline;
    function  getLATD11 : TBits_1; inline;
    function  getLATD2 : TBits_1; inline;
    function  getLATD3 : TBits_1; inline;
    function  getLATD4 : TBits_1; inline;
    function  getLATD5 : TBits_1; inline;
    function  getLATD6 : TBits_1; inline;
    function  getLATD7 : TBits_1; inline;
    function  getLATD8 : TBits_1; inline;
    function  getLATD9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setLATD0(thebits : TBits_1); inline;
    procedure setLATD1(thebits : TBits_1); inline;
    procedure setLATD10(thebits : TBits_1); inline;
    procedure setLATD11(thebits : TBits_1); inline;
    procedure setLATD2(thebits : TBits_1); inline;
    procedure setLATD3(thebits : TBits_1); inline;
    procedure setLATD4(thebits : TBits_1); inline;
    procedure setLATD5(thebits : TBits_1); inline;
    procedure setLATD6(thebits : TBits_1); inline;
    procedure setLATD7(thebits : TBits_1); inline;
    procedure setLATD8(thebits : TBits_1); inline;
    procedure setLATD9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearLATD0; inline;
    procedure clearLATD10; inline;
    procedure clearLATD11; inline;
    procedure clearLATD1; inline;
    procedure clearLATD2; inline;
    procedure clearLATD3; inline;
    procedure clearLATD4; inline;
    procedure clearLATD5; inline;
    procedure clearLATD6; inline;
    procedure clearLATD7; inline;
    procedure clearLATD8; inline;
    procedure clearLATD9; inline;
    procedure setLATD0; inline;
    procedure setLATD10; inline;
    procedure setLATD11; inline;
    procedure setLATD1; inline;
    procedure setLATD2; inline;
    procedure setLATD3; inline;
    procedure setLATD4; inline;
    procedure setLATD5; inline;
    procedure setLATD6; inline;
    procedure setLATD7; inline;
    procedure setLATD8; inline;
    procedure setLATD9; inline;
    property LATD0 : TBits_1 read getLATD0 write setLATD0;
    property LATD1 : TBits_1 read getLATD1 write setLATD1;
    property LATD10 : TBits_1 read getLATD10 write setLATD10;
    property LATD11 : TBits_1 read getLATD11 write setLATD11;
    property LATD2 : TBits_1 read getLATD2 write setLATD2;
    property LATD3 : TBits_1 read getLATD3 write setLATD3;
    property LATD4 : TBits_1 read getLATD4 write setLATD4;
    property LATD5 : TBits_1 read getLATD5 write setLATD5;
    property LATD6 : TBits_1 read getLATD6 write setLATD6;
    property LATD7 : TBits_1 read getLATD7 write setLATD7;
    property LATD8 : TBits_1 read getLATD8 write setLATD8;
    property LATD9 : TBits_1 read getLATD9 write setLATD9;
    property w : TBits_32 read getw write setw;
  end;
  TPORTD_ODCD = record
  private
    function  getODCD0 : TBits_1; inline;
    function  getODCD1 : TBits_1; inline;
    function  getODCD10 : TBits_1; inline;
    function  getODCD11 : TBits_1; inline;
    function  getODCD2 : TBits_1; inline;
    function  getODCD3 : TBits_1; inline;
    function  getODCD4 : TBits_1; inline;
    function  getODCD5 : TBits_1; inline;
    function  getODCD6 : TBits_1; inline;
    function  getODCD7 : TBits_1; inline;
    function  getODCD8 : TBits_1; inline;
    function  getODCD9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setODCD0(thebits : TBits_1); inline;
    procedure setODCD1(thebits : TBits_1); inline;
    procedure setODCD10(thebits : TBits_1); inline;
    procedure setODCD11(thebits : TBits_1); inline;
    procedure setODCD2(thebits : TBits_1); inline;
    procedure setODCD3(thebits : TBits_1); inline;
    procedure setODCD4(thebits : TBits_1); inline;
    procedure setODCD5(thebits : TBits_1); inline;
    procedure setODCD6(thebits : TBits_1); inline;
    procedure setODCD7(thebits : TBits_1); inline;
    procedure setODCD8(thebits : TBits_1); inline;
    procedure setODCD9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearODCD0; inline;
    procedure clearODCD10; inline;
    procedure clearODCD11; inline;
    procedure clearODCD1; inline;
    procedure clearODCD2; inline;
    procedure clearODCD3; inline;
    procedure clearODCD4; inline;
    procedure clearODCD5; inline;
    procedure clearODCD6; inline;
    procedure clearODCD7; inline;
    procedure clearODCD8; inline;
    procedure clearODCD9; inline;
    procedure setODCD0; inline;
    procedure setODCD10; inline;
    procedure setODCD11; inline;
    procedure setODCD1; inline;
    procedure setODCD2; inline;
    procedure setODCD3; inline;
    procedure setODCD4; inline;
    procedure setODCD5; inline;
    procedure setODCD6; inline;
    procedure setODCD7; inline;
    procedure setODCD8; inline;
    procedure setODCD9; inline;
    property ODCD0 : TBits_1 read getODCD0 write setODCD0;
    property ODCD1 : TBits_1 read getODCD1 write setODCD1;
    property ODCD10 : TBits_1 read getODCD10 write setODCD10;
    property ODCD11 : TBits_1 read getODCD11 write setODCD11;
    property ODCD2 : TBits_1 read getODCD2 write setODCD2;
    property ODCD3 : TBits_1 read getODCD3 write setODCD3;
    property ODCD4 : TBits_1 read getODCD4 write setODCD4;
    property ODCD5 : TBits_1 read getODCD5 write setODCD5;
    property ODCD6 : TBits_1 read getODCD6 write setODCD6;
    property ODCD7 : TBits_1 read getODCD7 write setODCD7;
    property ODCD8 : TBits_1 read getODCD8 write setODCD8;
    property ODCD9 : TBits_1 read getODCD9 write setODCD9;
    property w : TBits_32 read getw write setw;
  end;
type
  TPORTDRegisters = record
    TRISDbits : TPORTD_TRISD;
    TRISD : longWord;
    TRISDCLR : longWord;
    TRISDSET : longWord;
    TRISDINV : longWord;
    PORTDbits : TPORTD_PORTD;
    PORTD : longWord;
    PORTDCLR : longWord;
    PORTDSET : longWord;
    PORTDINV : longWord;
    LATDbits : TPORTD_LATD;
    LATD : longWord;
    LATDCLR : longWord;
    LATDSET : longWord;
    LATDINV : longWord;
    ODCDbits : TPORTD_ODCD;
    ODCD : longWord;
    ODCDCLR : longWord;
    ODCDSET : longWord;
    ODCDINV : longWord;
  end;
  TPORTE_TRISE = record
  private
    function  getTRISE0 : TBits_1; inline;
    function  getTRISE1 : TBits_1; inline;
    function  getTRISE2 : TBits_1; inline;
    function  getTRISE3 : TBits_1; inline;
    function  getTRISE4 : TBits_1; inline;
    function  getTRISE5 : TBits_1; inline;
    function  getTRISE6 : TBits_1; inline;
    function  getTRISE7 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setTRISE0(thebits : TBits_1); inline;
    procedure setTRISE1(thebits : TBits_1); inline;
    procedure setTRISE2(thebits : TBits_1); inline;
    procedure setTRISE3(thebits : TBits_1); inline;
    procedure setTRISE4(thebits : TBits_1); inline;
    procedure setTRISE5(thebits : TBits_1); inline;
    procedure setTRISE6(thebits : TBits_1); inline;
    procedure setTRISE7(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearTRISE0; inline;
    procedure clearTRISE1; inline;
    procedure clearTRISE2; inline;
    procedure clearTRISE3; inline;
    procedure clearTRISE4; inline;
    procedure clearTRISE5; inline;
    procedure clearTRISE6; inline;
    procedure clearTRISE7; inline;
    procedure setTRISE0; inline;
    procedure setTRISE1; inline;
    procedure setTRISE2; inline;
    procedure setTRISE3; inline;
    procedure setTRISE4; inline;
    procedure setTRISE5; inline;
    procedure setTRISE6; inline;
    procedure setTRISE7; inline;
    property TRISE0 : TBits_1 read getTRISE0 write setTRISE0;
    property TRISE1 : TBits_1 read getTRISE1 write setTRISE1;
    property TRISE2 : TBits_1 read getTRISE2 write setTRISE2;
    property TRISE3 : TBits_1 read getTRISE3 write setTRISE3;
    property TRISE4 : TBits_1 read getTRISE4 write setTRISE4;
    property TRISE5 : TBits_1 read getTRISE5 write setTRISE5;
    property TRISE6 : TBits_1 read getTRISE6 write setTRISE6;
    property TRISE7 : TBits_1 read getTRISE7 write setTRISE7;
    property w : TBits_32 read getw write setw;
  end;
  TPORTE_PORTE = record
  private
    function  getRE0 : TBits_1; inline;
    function  getRE1 : TBits_1; inline;
    function  getRE2 : TBits_1; inline;
    function  getRE3 : TBits_1; inline;
    function  getRE4 : TBits_1; inline;
    function  getRE5 : TBits_1; inline;
    function  getRE6 : TBits_1; inline;
    function  getRE7 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setRE0(thebits : TBits_1); inline;
    procedure setRE1(thebits : TBits_1); inline;
    procedure setRE2(thebits : TBits_1); inline;
    procedure setRE3(thebits : TBits_1); inline;
    procedure setRE4(thebits : TBits_1); inline;
    procedure setRE5(thebits : TBits_1); inline;
    procedure setRE6(thebits : TBits_1); inline;
    procedure setRE7(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearRE0; inline;
    procedure clearRE1; inline;
    procedure clearRE2; inline;
    procedure clearRE3; inline;
    procedure clearRE4; inline;
    procedure clearRE5; inline;
    procedure clearRE6; inline;
    procedure clearRE7; inline;
    procedure setRE0; inline;
    procedure setRE1; inline;
    procedure setRE2; inline;
    procedure setRE3; inline;
    procedure setRE4; inline;
    procedure setRE5; inline;
    procedure setRE6; inline;
    procedure setRE7; inline;
    property RE0 : TBits_1 read getRE0 write setRE0;
    property RE1 : TBits_1 read getRE1 write setRE1;
    property RE2 : TBits_1 read getRE2 write setRE2;
    property RE3 : TBits_1 read getRE3 write setRE3;
    property RE4 : TBits_1 read getRE4 write setRE4;
    property RE5 : TBits_1 read getRE5 write setRE5;
    property RE6 : TBits_1 read getRE6 write setRE6;
    property RE7 : TBits_1 read getRE7 write setRE7;
    property w : TBits_32 read getw write setw;
  end;
  TPortE_bits=(RE0=0,RE1=1,RE2=2,RE3=3,RE4=4,RE5=5,RE6=6,RE7=7);
  TPortE_bitset = set of TPortE_bits;
  TPORTE_LATE = record
  private
    function  getLATE0 : TBits_1; inline;
    function  getLATE1 : TBits_1; inline;
    function  getLATE2 : TBits_1; inline;
    function  getLATE3 : TBits_1; inline;
    function  getLATE4 : TBits_1; inline;
    function  getLATE5 : TBits_1; inline;
    function  getLATE6 : TBits_1; inline;
    function  getLATE7 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setLATE0(thebits : TBits_1); inline;
    procedure setLATE1(thebits : TBits_1); inline;
    procedure setLATE2(thebits : TBits_1); inline;
    procedure setLATE3(thebits : TBits_1); inline;
    procedure setLATE4(thebits : TBits_1); inline;
    procedure setLATE5(thebits : TBits_1); inline;
    procedure setLATE6(thebits : TBits_1); inline;
    procedure setLATE7(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearLATE0; inline;
    procedure clearLATE1; inline;
    procedure clearLATE2; inline;
    procedure clearLATE3; inline;
    procedure clearLATE4; inline;
    procedure clearLATE5; inline;
    procedure clearLATE6; inline;
    procedure clearLATE7; inline;
    procedure setLATE0; inline;
    procedure setLATE1; inline;
    procedure setLATE2; inline;
    procedure setLATE3; inline;
    procedure setLATE4; inline;
    procedure setLATE5; inline;
    procedure setLATE6; inline;
    procedure setLATE7; inline;
    property LATE0 : TBits_1 read getLATE0 write setLATE0;
    property LATE1 : TBits_1 read getLATE1 write setLATE1;
    property LATE2 : TBits_1 read getLATE2 write setLATE2;
    property LATE3 : TBits_1 read getLATE3 write setLATE3;
    property LATE4 : TBits_1 read getLATE4 write setLATE4;
    property LATE5 : TBits_1 read getLATE5 write setLATE5;
    property LATE6 : TBits_1 read getLATE6 write setLATE6;
    property LATE7 : TBits_1 read getLATE7 write setLATE7;
    property w : TBits_32 read getw write setw;
  end;
  TPORTE_ODCE = record
  private
    function  getODCE0 : TBits_1; inline;
    function  getODCE1 : TBits_1; inline;
    function  getODCE2 : TBits_1; inline;
    function  getODCE3 : TBits_1; inline;
    function  getODCE4 : TBits_1; inline;
    function  getODCE5 : TBits_1; inline;
    function  getODCE6 : TBits_1; inline;
    function  getODCE7 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setODCE0(thebits : TBits_1); inline;
    procedure setODCE1(thebits : TBits_1); inline;
    procedure setODCE2(thebits : TBits_1); inline;
    procedure setODCE3(thebits : TBits_1); inline;
    procedure setODCE4(thebits : TBits_1); inline;
    procedure setODCE5(thebits : TBits_1); inline;
    procedure setODCE6(thebits : TBits_1); inline;
    procedure setODCE7(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearODCE0; inline;
    procedure clearODCE1; inline;
    procedure clearODCE2; inline;
    procedure clearODCE3; inline;
    procedure clearODCE4; inline;
    procedure clearODCE5; inline;
    procedure clearODCE6; inline;
    procedure clearODCE7; inline;
    procedure setODCE0; inline;
    procedure setODCE1; inline;
    procedure setODCE2; inline;
    procedure setODCE3; inline;
    procedure setODCE4; inline;
    procedure setODCE5; inline;
    procedure setODCE6; inline;
    procedure setODCE7; inline;
    property ODCE0 : TBits_1 read getODCE0 write setODCE0;
    property ODCE1 : TBits_1 read getODCE1 write setODCE1;
    property ODCE2 : TBits_1 read getODCE2 write setODCE2;
    property ODCE3 : TBits_1 read getODCE3 write setODCE3;
    property ODCE4 : TBits_1 read getODCE4 write setODCE4;
    property ODCE5 : TBits_1 read getODCE5 write setODCE5;
    property ODCE6 : TBits_1 read getODCE6 write setODCE6;
    property ODCE7 : TBits_1 read getODCE7 write setODCE7;
    property w : TBits_32 read getw write setw;
  end;
type
  TPORTERegisters = record
    TRISEbits : TPORTE_TRISE;
    TRISE : longWord;
    TRISECLR : longWord;
    TRISESET : longWord;
    TRISEINV : longWord;
    PORTEbits : TPORTE_PORTE;
    PORTE : longWord;
    PORTECLR : longWord;
    PORTESET : longWord;
    PORTEINV : longWord;
    LATEbits : TPORTE_LATE;
    LATE : longWord;
    LATECLR : longWord;
    LATESET : longWord;
    LATEINV : longWord;
    ODCEbits : TPORTE_ODCE;
    ODCE : longWord;
    ODCECLR : longWord;
    ODCESET : longWord;
    ODCEINV : longWord;
  end;
  TPORTF_TRISF = record
  private
    function  getTRISF0 : TBits_1; inline;
    function  getTRISF1 : TBits_1; inline;
    function  getTRISF2 : TBits_1; inline;
    function  getTRISF3 : TBits_1; inline;
    function  getTRISF4 : TBits_1; inline;
    function  getTRISF5 : TBits_1; inline;
    function  getTRISF6 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setTRISF0(thebits : TBits_1); inline;
    procedure setTRISF1(thebits : TBits_1); inline;
    procedure setTRISF2(thebits : TBits_1); inline;
    procedure setTRISF3(thebits : TBits_1); inline;
    procedure setTRISF4(thebits : TBits_1); inline;
    procedure setTRISF5(thebits : TBits_1); inline;
    procedure setTRISF6(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearTRISF0; inline;
    procedure clearTRISF1; inline;
    procedure clearTRISF2; inline;
    procedure clearTRISF3; inline;
    procedure clearTRISF4; inline;
    procedure clearTRISF5; inline;
    procedure clearTRISF6; inline;
    procedure setTRISF0; inline;
    procedure setTRISF1; inline;
    procedure setTRISF2; inline;
    procedure setTRISF3; inline;
    procedure setTRISF4; inline;
    procedure setTRISF5; inline;
    procedure setTRISF6; inline;
    property TRISF0 : TBits_1 read getTRISF0 write setTRISF0;
    property TRISF1 : TBits_1 read getTRISF1 write setTRISF1;
    property TRISF2 : TBits_1 read getTRISF2 write setTRISF2;
    property TRISF3 : TBits_1 read getTRISF3 write setTRISF3;
    property TRISF4 : TBits_1 read getTRISF4 write setTRISF4;
    property TRISF5 : TBits_1 read getTRISF5 write setTRISF5;
    property TRISF6 : TBits_1 read getTRISF6 write setTRISF6;
    property w : TBits_32 read getw write setw;
  end;
  TPORTF_PORTF = record
  private
    function  getRF0 : TBits_1; inline;
    function  getRF1 : TBits_1; inline;
    function  getRF2 : TBits_1; inline;
    function  getRF3 : TBits_1; inline;
    function  getRF4 : TBits_1; inline;
    function  getRF5 : TBits_1; inline;
    function  getRF6 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setRF0(thebits : TBits_1); inline;
    procedure setRF1(thebits : TBits_1); inline;
    procedure setRF2(thebits : TBits_1); inline;
    procedure setRF3(thebits : TBits_1); inline;
    procedure setRF4(thebits : TBits_1); inline;
    procedure setRF5(thebits : TBits_1); inline;
    procedure setRF6(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearRF0; inline;
    procedure clearRF1; inline;
    procedure clearRF2; inline;
    procedure clearRF3; inline;
    procedure clearRF4; inline;
    procedure clearRF5; inline;
    procedure clearRF6; inline;
    procedure setRF0; inline;
    procedure setRF1; inline;
    procedure setRF2; inline;
    procedure setRF3; inline;
    procedure setRF4; inline;
    procedure setRF5; inline;
    procedure setRF6; inline;
    property RF0 : TBits_1 read getRF0 write setRF0;
    property RF1 : TBits_1 read getRF1 write setRF1;
    property RF2 : TBits_1 read getRF2 write setRF2;
    property RF3 : TBits_1 read getRF3 write setRF3;
    property RF4 : TBits_1 read getRF4 write setRF4;
    property RF5 : TBits_1 read getRF5 write setRF5;
    property RF6 : TBits_1 read getRF6 write setRF6;
    property w : TBits_32 read getw write setw;
  end;
  TPortF_bits=(RF0=0,RF1=1,RF2=2,RF3=3,RF4=4,RF5=5,RF6=6);
  TPortF_bitset = set of TPortF_bits;
  TPORTF_LATF = record
  private
    function  getLATF0 : TBits_1; inline;
    function  getLATF1 : TBits_1; inline;
    function  getLATF2 : TBits_1; inline;
    function  getLATF3 : TBits_1; inline;
    function  getLATF4 : TBits_1; inline;
    function  getLATF5 : TBits_1; inline;
    function  getLATF6 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setLATF0(thebits : TBits_1); inline;
    procedure setLATF1(thebits : TBits_1); inline;
    procedure setLATF2(thebits : TBits_1); inline;
    procedure setLATF3(thebits : TBits_1); inline;
    procedure setLATF4(thebits : TBits_1); inline;
    procedure setLATF5(thebits : TBits_1); inline;
    procedure setLATF6(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearLATF0; inline;
    procedure clearLATF1; inline;
    procedure clearLATF2; inline;
    procedure clearLATF3; inline;
    procedure clearLATF4; inline;
    procedure clearLATF5; inline;
    procedure clearLATF6; inline;
    procedure setLATF0; inline;
    procedure setLATF1; inline;
    procedure setLATF2; inline;
    procedure setLATF3; inline;
    procedure setLATF4; inline;
    procedure setLATF5; inline;
    procedure setLATF6; inline;
    property LATF0 : TBits_1 read getLATF0 write setLATF0;
    property LATF1 : TBits_1 read getLATF1 write setLATF1;
    property LATF2 : TBits_1 read getLATF2 write setLATF2;
    property LATF3 : TBits_1 read getLATF3 write setLATF3;
    property LATF4 : TBits_1 read getLATF4 write setLATF4;
    property LATF5 : TBits_1 read getLATF5 write setLATF5;
    property LATF6 : TBits_1 read getLATF6 write setLATF6;
    property w : TBits_32 read getw write setw;
  end;
  TPORTF_ODCF = record
  private
    function  getODCF0 : TBits_1; inline;
    function  getODCF1 : TBits_1; inline;
    function  getODCF2 : TBits_1; inline;
    function  getODCF3 : TBits_1; inline;
    function  getODCF4 : TBits_1; inline;
    function  getODCF5 : TBits_1; inline;
    function  getODCF6 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setODCF0(thebits : TBits_1); inline;
    procedure setODCF1(thebits : TBits_1); inline;
    procedure setODCF2(thebits : TBits_1); inline;
    procedure setODCF3(thebits : TBits_1); inline;
    procedure setODCF4(thebits : TBits_1); inline;
    procedure setODCF5(thebits : TBits_1); inline;
    procedure setODCF6(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearODCF0; inline;
    procedure clearODCF1; inline;
    procedure clearODCF2; inline;
    procedure clearODCF3; inline;
    procedure clearODCF4; inline;
    procedure clearODCF5; inline;
    procedure clearODCF6; inline;
    procedure setODCF0; inline;
    procedure setODCF1; inline;
    procedure setODCF2; inline;
    procedure setODCF3; inline;
    procedure setODCF4; inline;
    procedure setODCF5; inline;
    procedure setODCF6; inline;
    property ODCF0 : TBits_1 read getODCF0 write setODCF0;
    property ODCF1 : TBits_1 read getODCF1 write setODCF1;
    property ODCF2 : TBits_1 read getODCF2 write setODCF2;
    property ODCF3 : TBits_1 read getODCF3 write setODCF3;
    property ODCF4 : TBits_1 read getODCF4 write setODCF4;
    property ODCF5 : TBits_1 read getODCF5 write setODCF5;
    property ODCF6 : TBits_1 read getODCF6 write setODCF6;
    property w : TBits_32 read getw write setw;
  end;
type
  TPORTFRegisters = record
    TRISFbits : TPORTF_TRISF;
    TRISF : longWord;
    TRISFCLR : longWord;
    TRISFSET : longWord;
    TRISFINV : longWord;
    PORTFbits : TPORTF_PORTF;
    PORTF : longWord;
    PORTFCLR : longWord;
    PORTFSET : longWord;
    PORTFINV : longWord;
    LATFbits : TPORTF_LATF;
    LATF : longWord;
    LATFCLR : longWord;
    LATFSET : longWord;
    LATFINV : longWord;
    ODCFbits : TPORTF_ODCF;
    ODCF : longWord;
    ODCFCLR : longWord;
    ODCFSET : longWord;
    ODCFINV : longWord;
  end;
  TPORTG_TRISG = record
  private
    function  getTRISG2 : TBits_1; inline;
    function  getTRISG3 : TBits_1; inline;
    function  getTRISG6 : TBits_1; inline;
    function  getTRISG7 : TBits_1; inline;
    function  getTRISG8 : TBits_1; inline;
    function  getTRISG9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setTRISG2(thebits : TBits_1); inline;
    procedure setTRISG3(thebits : TBits_1); inline;
    procedure setTRISG6(thebits : TBits_1); inline;
    procedure setTRISG7(thebits : TBits_1); inline;
    procedure setTRISG8(thebits : TBits_1); inline;
    procedure setTRISG9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearTRISG2; inline;
    procedure clearTRISG3; inline;
    procedure clearTRISG6; inline;
    procedure clearTRISG7; inline;
    procedure clearTRISG8; inline;
    procedure clearTRISG9; inline;
    procedure setTRISG2; inline;
    procedure setTRISG3; inline;
    procedure setTRISG6; inline;
    procedure setTRISG7; inline;
    procedure setTRISG8; inline;
    procedure setTRISG9; inline;
    property TRISG2 : TBits_1 read getTRISG2 write setTRISG2;
    property TRISG3 : TBits_1 read getTRISG3 write setTRISG3;
    property TRISG6 : TBits_1 read getTRISG6 write setTRISG6;
    property TRISG7 : TBits_1 read getTRISG7 write setTRISG7;
    property TRISG8 : TBits_1 read getTRISG8 write setTRISG8;
    property TRISG9 : TBits_1 read getTRISG9 write setTRISG9;
    property w : TBits_32 read getw write setw;
  end;
  TPORTG_PORTG = record
  private
    function  getRG2 : TBits_1; inline;
    function  getRG3 : TBits_1; inline;
    function  getRG6 : TBits_1; inline;
    function  getRG7 : TBits_1; inline;
    function  getRG8 : TBits_1; inline;
    function  getRG9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setRG2(thebits : TBits_1); inline;
    procedure setRG3(thebits : TBits_1); inline;
    procedure setRG6(thebits : TBits_1); inline;
    procedure setRG7(thebits : TBits_1); inline;
    procedure setRG8(thebits : TBits_1); inline;
    procedure setRG9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearRG2; inline;
    procedure clearRG3; inline;
    procedure clearRG6; inline;
    procedure clearRG7; inline;
    procedure clearRG8; inline;
    procedure clearRG9; inline;
    procedure setRG2; inline;
    procedure setRG3; inline;
    procedure setRG6; inline;
    procedure setRG7; inline;
    procedure setRG8; inline;
    procedure setRG9; inline;
    property RG2 : TBits_1 read getRG2 write setRG2;
    property RG3 : TBits_1 read getRG3 write setRG3;
    property RG6 : TBits_1 read getRG6 write setRG6;
    property RG7 : TBits_1 read getRG7 write setRG7;
    property RG8 : TBits_1 read getRG8 write setRG8;
    property RG9 : TBits_1 read getRG9 write setRG9;
    property w : TBits_32 read getw write setw;
  end;
  TPortG_bits=(RG2=2,RG3=3,RG6=6,RG7=7,RG8=8,RG9=9);
  TPortG_bitset = set of TPortG_bits;
  TPORTG_LATG = record
  private
    function  getLATG2 : TBits_1; inline;
    function  getLATG3 : TBits_1; inline;
    function  getLATG6 : TBits_1; inline;
    function  getLATG7 : TBits_1; inline;
    function  getLATG8 : TBits_1; inline;
    function  getLATG9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setLATG2(thebits : TBits_1); inline;
    procedure setLATG3(thebits : TBits_1); inline;
    procedure setLATG6(thebits : TBits_1); inline;
    procedure setLATG7(thebits : TBits_1); inline;
    procedure setLATG8(thebits : TBits_1); inline;
    procedure setLATG9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearLATG2; inline;
    procedure clearLATG3; inline;
    procedure clearLATG6; inline;
    procedure clearLATG7; inline;
    procedure clearLATG8; inline;
    procedure clearLATG9; inline;
    procedure setLATG2; inline;
    procedure setLATG3; inline;
    procedure setLATG6; inline;
    procedure setLATG7; inline;
    procedure setLATG8; inline;
    procedure setLATG9; inline;
    property LATG2 : TBits_1 read getLATG2 write setLATG2;
    property LATG3 : TBits_1 read getLATG3 write setLATG3;
    property LATG6 : TBits_1 read getLATG6 write setLATG6;
    property LATG7 : TBits_1 read getLATG7 write setLATG7;
    property LATG8 : TBits_1 read getLATG8 write setLATG8;
    property LATG9 : TBits_1 read getLATG9 write setLATG9;
    property w : TBits_32 read getw write setw;
  end;
  TPORTG_ODCG = record
  private
    function  getODCG2 : TBits_1; inline;
    function  getODCG3 : TBits_1; inline;
    function  getODCG6 : TBits_1; inline;
    function  getODCG7 : TBits_1; inline;
    function  getODCG8 : TBits_1; inline;
    function  getODCG9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setODCG2(thebits : TBits_1); inline;
    procedure setODCG3(thebits : TBits_1); inline;
    procedure setODCG6(thebits : TBits_1); inline;
    procedure setODCG7(thebits : TBits_1); inline;
    procedure setODCG8(thebits : TBits_1); inline;
    procedure setODCG9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearODCG2; inline;
    procedure clearODCG3; inline;
    procedure clearODCG6; inline;
    procedure clearODCG7; inline;
    procedure clearODCG8; inline;
    procedure clearODCG9; inline;
    procedure setODCG2; inline;
    procedure setODCG3; inline;
    procedure setODCG6; inline;
    procedure setODCG7; inline;
    procedure setODCG8; inline;
    procedure setODCG9; inline;
    property ODCG2 : TBits_1 read getODCG2 write setODCG2;
    property ODCG3 : TBits_1 read getODCG3 write setODCG3;
    property ODCG6 : TBits_1 read getODCG6 write setODCG6;
    property ODCG7 : TBits_1 read getODCG7 write setODCG7;
    property ODCG8 : TBits_1 read getODCG8 write setODCG8;
    property ODCG9 : TBits_1 read getODCG9 write setODCG9;
    property w : TBits_32 read getw write setw;
  end;
  TPORTG_CNCON = record
  private
    function  getON : TBits_1; inline;
    function  getSIDL : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setON(thebits : TBits_1); inline;
    procedure setSIDL(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearON; inline;
    procedure clearSIDL; inline;
    procedure setON; inline;
    procedure setSIDL; inline;
    property ON : TBits_1 read getON write setON;
    property SIDL : TBits_1 read getSIDL write setSIDL;
    property w : TBits_32 read getw write setw;
  end;
  TPORTG_CNEN = record
  private
    function  getCNEN0 : TBits_1; inline;
    function  getCNEN1 : TBits_1; inline;
    function  getCNEN10 : TBits_1; inline;
    function  getCNEN11 : TBits_1; inline;
    function  getCNEN12 : TBits_1; inline;
    function  getCNEN13 : TBits_1; inline;
    function  getCNEN14 : TBits_1; inline;
    function  getCNEN15 : TBits_1; inline;
    function  getCNEN16 : TBits_1; inline;
    function  getCNEN17 : TBits_1; inline;
    function  getCNEN18 : TBits_1; inline;
    function  getCNEN2 : TBits_1; inline;
    function  getCNEN3 : TBits_1; inline;
    function  getCNEN4 : TBits_1; inline;
    function  getCNEN5 : TBits_1; inline;
    function  getCNEN6 : TBits_1; inline;
    function  getCNEN7 : TBits_1; inline;
    function  getCNEN8 : TBits_1; inline;
    function  getCNEN9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCNEN0(thebits : TBits_1); inline;
    procedure setCNEN1(thebits : TBits_1); inline;
    procedure setCNEN10(thebits : TBits_1); inline;
    procedure setCNEN11(thebits : TBits_1); inline;
    procedure setCNEN12(thebits : TBits_1); inline;
    procedure setCNEN13(thebits : TBits_1); inline;
    procedure setCNEN14(thebits : TBits_1); inline;
    procedure setCNEN15(thebits : TBits_1); inline;
    procedure setCNEN16(thebits : TBits_1); inline;
    procedure setCNEN17(thebits : TBits_1); inline;
    procedure setCNEN18(thebits : TBits_1); inline;
    procedure setCNEN2(thebits : TBits_1); inline;
    procedure setCNEN3(thebits : TBits_1); inline;
    procedure setCNEN4(thebits : TBits_1); inline;
    procedure setCNEN5(thebits : TBits_1); inline;
    procedure setCNEN6(thebits : TBits_1); inline;
    procedure setCNEN7(thebits : TBits_1); inline;
    procedure setCNEN8(thebits : TBits_1); inline;
    procedure setCNEN9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCNEN0; inline;
    procedure clearCNEN10; inline;
    procedure clearCNEN11; inline;
    procedure clearCNEN12; inline;
    procedure clearCNEN13; inline;
    procedure clearCNEN14; inline;
    procedure clearCNEN15; inline;
    procedure clearCNEN16; inline;
    procedure clearCNEN17; inline;
    procedure clearCNEN18; inline;
    procedure clearCNEN1; inline;
    procedure clearCNEN2; inline;
    procedure clearCNEN3; inline;
    procedure clearCNEN4; inline;
    procedure clearCNEN5; inline;
    procedure clearCNEN6; inline;
    procedure clearCNEN7; inline;
    procedure clearCNEN8; inline;
    procedure clearCNEN9; inline;
    procedure setCNEN0; inline;
    procedure setCNEN10; inline;
    procedure setCNEN11; inline;
    procedure setCNEN12; inline;
    procedure setCNEN13; inline;
    procedure setCNEN14; inline;
    procedure setCNEN15; inline;
    procedure setCNEN16; inline;
    procedure setCNEN17; inline;
    procedure setCNEN18; inline;
    procedure setCNEN1; inline;
    procedure setCNEN2; inline;
    procedure setCNEN3; inline;
    procedure setCNEN4; inline;
    procedure setCNEN5; inline;
    procedure setCNEN6; inline;
    procedure setCNEN7; inline;
    procedure setCNEN8; inline;
    procedure setCNEN9; inline;
    property CNEN0 : TBits_1 read getCNEN0 write setCNEN0;
    property CNEN1 : TBits_1 read getCNEN1 write setCNEN1;
    property CNEN10 : TBits_1 read getCNEN10 write setCNEN10;
    property CNEN11 : TBits_1 read getCNEN11 write setCNEN11;
    property CNEN12 : TBits_1 read getCNEN12 write setCNEN12;
    property CNEN13 : TBits_1 read getCNEN13 write setCNEN13;
    property CNEN14 : TBits_1 read getCNEN14 write setCNEN14;
    property CNEN15 : TBits_1 read getCNEN15 write setCNEN15;
    property CNEN16 : TBits_1 read getCNEN16 write setCNEN16;
    property CNEN17 : TBits_1 read getCNEN17 write setCNEN17;
    property CNEN18 : TBits_1 read getCNEN18 write setCNEN18;
    property CNEN2 : TBits_1 read getCNEN2 write setCNEN2;
    property CNEN3 : TBits_1 read getCNEN3 write setCNEN3;
    property CNEN4 : TBits_1 read getCNEN4 write setCNEN4;
    property CNEN5 : TBits_1 read getCNEN5 write setCNEN5;
    property CNEN6 : TBits_1 read getCNEN6 write setCNEN6;
    property CNEN7 : TBits_1 read getCNEN7 write setCNEN7;
    property CNEN8 : TBits_1 read getCNEN8 write setCNEN8;
    property CNEN9 : TBits_1 read getCNEN9 write setCNEN9;
    property w : TBits_32 read getw write setw;
  end;
  TPORTG_CNPUE = record
  private
    function  getCNPUE0 : TBits_1; inline;
    function  getCNPUE1 : TBits_1; inline;
    function  getCNPUE10 : TBits_1; inline;
    function  getCNPUE11 : TBits_1; inline;
    function  getCNPUE12 : TBits_1; inline;
    function  getCNPUE13 : TBits_1; inline;
    function  getCNPUE14 : TBits_1; inline;
    function  getCNPUE15 : TBits_1; inline;
    function  getCNPUE16 : TBits_1; inline;
    function  getCNPUE17 : TBits_1; inline;
    function  getCNPUE18 : TBits_1; inline;
    function  getCNPUE2 : TBits_1; inline;
    function  getCNPUE3 : TBits_1; inline;
    function  getCNPUE4 : TBits_1; inline;
    function  getCNPUE5 : TBits_1; inline;
    function  getCNPUE6 : TBits_1; inline;
    function  getCNPUE7 : TBits_1; inline;
    function  getCNPUE8 : TBits_1; inline;
    function  getCNPUE9 : TBits_1; inline;
    function  getw : TBits_32; inline;
    procedure setCNPUE0(thebits : TBits_1); inline;
    procedure setCNPUE1(thebits : TBits_1); inline;
    procedure setCNPUE10(thebits : TBits_1); inline;
    procedure setCNPUE11(thebits : TBits_1); inline;
    procedure setCNPUE12(thebits : TBits_1); inline;
    procedure setCNPUE13(thebits : TBits_1); inline;
    procedure setCNPUE14(thebits : TBits_1); inline;
    procedure setCNPUE15(thebits : TBits_1); inline;
    procedure setCNPUE16(thebits : TBits_1); inline;
    procedure setCNPUE17(thebits : TBits_1); inline;
    procedure setCNPUE18(thebits : TBits_1); inline;
    procedure setCNPUE2(thebits : TBits_1); inline;
    procedure setCNPUE3(thebits : TBits_1); inline;
    procedure setCNPUE4(thebits : TBits_1); inline;
    procedure setCNPUE5(thebits : TBits_1); inline;
    procedure setCNPUE6(thebits : TBits_1); inline;
    procedure setCNPUE7(thebits : TBits_1); inline;
    procedure setCNPUE8(thebits : TBits_1); inline;
    procedure setCNPUE9(thebits : TBits_1); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearCNPUE0; inline;
    procedure clearCNPUE10; inline;
    procedure clearCNPUE11; inline;
    procedure clearCNPUE12; inline;
    procedure clearCNPUE13; inline;
    procedure clearCNPUE14; inline;
    procedure clearCNPUE15; inline;
    procedure clearCNPUE16; inline;
    procedure clearCNPUE17; inline;
    procedure clearCNPUE18; inline;
    procedure clearCNPUE1; inline;
    procedure clearCNPUE2; inline;
    procedure clearCNPUE3; inline;
    procedure clearCNPUE4; inline;
    procedure clearCNPUE5; inline;
    procedure clearCNPUE6; inline;
    procedure clearCNPUE7; inline;
    procedure clearCNPUE8; inline;
    procedure clearCNPUE9; inline;
    procedure setCNPUE0; inline;
    procedure setCNPUE10; inline;
    procedure setCNPUE11; inline;
    procedure setCNPUE12; inline;
    procedure setCNPUE13; inline;
    procedure setCNPUE14; inline;
    procedure setCNPUE15; inline;
    procedure setCNPUE16; inline;
    procedure setCNPUE17; inline;
    procedure setCNPUE18; inline;
    procedure setCNPUE1; inline;
    procedure setCNPUE2; inline;
    procedure setCNPUE3; inline;
    procedure setCNPUE4; inline;
    procedure setCNPUE5; inline;
    procedure setCNPUE6; inline;
    procedure setCNPUE7; inline;
    procedure setCNPUE8; inline;
    procedure setCNPUE9; inline;
    property CNPUE0 : TBits_1 read getCNPUE0 write setCNPUE0;
    property CNPUE1 : TBits_1 read getCNPUE1 write setCNPUE1;
    property CNPUE10 : TBits_1 read getCNPUE10 write setCNPUE10;
    property CNPUE11 : TBits_1 read getCNPUE11 write setCNPUE11;
    property CNPUE12 : TBits_1 read getCNPUE12 write setCNPUE12;
    property CNPUE13 : TBits_1 read getCNPUE13 write setCNPUE13;
    property CNPUE14 : TBits_1 read getCNPUE14 write setCNPUE14;
    property CNPUE15 : TBits_1 read getCNPUE15 write setCNPUE15;
    property CNPUE16 : TBits_1 read getCNPUE16 write setCNPUE16;
    property CNPUE17 : TBits_1 read getCNPUE17 write setCNPUE17;
    property CNPUE18 : TBits_1 read getCNPUE18 write setCNPUE18;
    property CNPUE2 : TBits_1 read getCNPUE2 write setCNPUE2;
    property CNPUE3 : TBits_1 read getCNPUE3 write setCNPUE3;
    property CNPUE4 : TBits_1 read getCNPUE4 write setCNPUE4;
    property CNPUE5 : TBits_1 read getCNPUE5 write setCNPUE5;
    property CNPUE6 : TBits_1 read getCNPUE6 write setCNPUE6;
    property CNPUE7 : TBits_1 read getCNPUE7 write setCNPUE7;
    property CNPUE8 : TBits_1 read getCNPUE8 write setCNPUE8;
    property CNPUE9 : TBits_1 read getCNPUE9 write setCNPUE9;
    property w : TBits_32 read getw write setw;
  end;
type
  TPORTGRegisters = record
    TRISGbits : TPORTG_TRISG;
    TRISG : longWord;
    TRISGCLR : longWord;
    TRISGSET : longWord;
    TRISGINV : longWord;
    PORTGbits : TPORTG_PORTG;
    PORTG : longWord;
    PORTGCLR : longWord;
    PORTGSET : longWord;
    PORTGINV : longWord;
    LATGbits : TPORTG_LATG;
    LATG : longWord;
    LATGCLR : longWord;
    LATGSET : longWord;
    LATGINV : longWord;
    ODCGbits : TPORTG_ODCG;
    ODCG : longWord;
    ODCGCLR : longWord;
    ODCGSET : longWord;
    ODCGINV : longWord;
    CNCONbits : TPORTG_CNCON;
    CNCON : longWord;
    CNCONCLR : longWord;
    CNCONSET : longWord;
    CNCONINV : longWord;
    CNENbits : TPORTG_CNEN;
    CNEN : longWord;
    CNENCLR : longWord;
    CNENSET : longWord;
    CNENINV : longWord;
    CNPUEbits : TPORTG_CNPUE;
    CNPUE : longWord;
    CNPUECLR : longWord;
    CNPUESET : longWord;
    CNPUEINV : longWord;
  end;
  TDEVCFG_DEVCFG3 = record
  private
    function  getUSERID : TBits_16; inline;
    function  getw : TBits_32; inline;
    procedure setUSERID(thebits : TBits_16); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    property USERID : TBits_16 read getUSERID write setUSERID;
    property w : TBits_32 read getw write setw;
  end;
  TDEVCFG_DEVCFG2 = record
  private
    function  getFPLLIDIV : TBits_3; inline;
    function  getFPLLMUL : TBits_3; inline;
    function  getFPLLODIV : TBits_3; inline;
    function  getw : TBits_32; inline;
    procedure setFPLLIDIV(thebits : TBits_3); inline;
    procedure setFPLLMUL(thebits : TBits_3); inline;
    procedure setFPLLODIV(thebits : TBits_3); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    property FPLLIDIV : TBits_3 read getFPLLIDIV write setFPLLIDIV;
    property FPLLMUL : TBits_3 read getFPLLMUL write setFPLLMUL;
    property FPLLODIV : TBits_3 read getFPLLODIV write setFPLLODIV;
    property w : TBits_32 read getw write setw;
  end;
  TDEVCFG_DEVCFG1 = record
  private
    function  getFCKSM : TBits_2; inline;
    function  getFNOSC : TBits_3; inline;
    function  getFPBDIV : TBits_2; inline;
    function  getFSOSCEN : TBits_1; inline;
    function  getFWDTEN : TBits_1; inline;
    function  getIESO : TBits_1; inline;
    function  getOSCIOFNC : TBits_1; inline;
    function  getPOSCMOD : TBits_2; inline;
    function  getWDTPS : TBits_5; inline;
    function  getw : TBits_32; inline;
    procedure setFCKSM(thebits : TBits_2); inline;
    procedure setFNOSC(thebits : TBits_3); inline;
    procedure setFPBDIV(thebits : TBits_2); inline;
    procedure setFSOSCEN(thebits : TBits_1); inline;
    procedure setFWDTEN(thebits : TBits_1); inline;
    procedure setIESO(thebits : TBits_1); inline;
    procedure setOSCIOFNC(thebits : TBits_1); inline;
    procedure setPOSCMOD(thebits : TBits_2); inline;
    procedure setWDTPS(thebits : TBits_5); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearFSOSCEN; inline;
    procedure clearFWDTEN; inline;
    procedure clearIESO; inline;
    procedure clearOSCIOFNC; inline;
    procedure setFSOSCEN; inline;
    procedure setFWDTEN; inline;
    procedure setIESO; inline;
    procedure setOSCIOFNC; inline;
    property FCKSM : TBits_2 read getFCKSM write setFCKSM;
    property FNOSC : TBits_3 read getFNOSC write setFNOSC;
    property FPBDIV : TBits_2 read getFPBDIV write setFPBDIV;
    property FSOSCEN : TBits_1 read getFSOSCEN write setFSOSCEN;
    property FWDTEN : TBits_1 read getFWDTEN write setFWDTEN;
    property IESO : TBits_1 read getIESO write setIESO;
    property OSCIOFNC : TBits_1 read getOSCIOFNC write setOSCIOFNC;
    property POSCMOD : TBits_2 read getPOSCMOD write setPOSCMOD;
    property WDTPS : TBits_5 read getWDTPS write setWDTPS;
    property w : TBits_32 read getw write setw;
  end;
  TDEVCFG_DEVCFG0 = record
  private
    function  getBWP : TBits_1; inline;
    function  getCP : TBits_1; inline;
    function  getDEBUG : TBits_2; inline;
    function  getFDEBUG : TBits_2; inline;
    function  getICESEL : TBits_1; inline;
    function  getPWP : TBits_8; inline;
    function  getw : TBits_32; inline;
    procedure setBWP(thebits : TBits_1); inline;
    procedure setCP(thebits : TBits_1); inline;
    procedure setDEBUG(thebits : TBits_2); inline;
    procedure setFDEBUG(thebits : TBits_2); inline;
    procedure setICESEL(thebits : TBits_1); inline;
    procedure setPWP(thebits : TBits_8); inline;
    procedure setw(thebits : TBits_32); inline;
  public
    procedure clearBWP; inline;
    procedure clearCP; inline;
    procedure clearICESEL; inline;
    procedure setBWP; inline;
    procedure setCP; inline;
    procedure setICESEL; inline;
    property BWP : TBits_1 read getBWP write setBWP;
    property CP : TBits_1 read getCP write setCP;
    property DEBUG : TBits_2 read getDEBUG write setDEBUG;
    property FDEBUG : TBits_2 read getFDEBUG write setFDEBUG;
    property ICESEL : TBits_1 read getICESEL write setICESEL;
    property PWP : TBits_8 read getPWP write setPWP;
    property w : TBits_32 read getw write setw;
  end;
const
  _CORE_TIMER_IRQ = 0;
  _CORE_SOFTWARE_0_IRQ = 1;
  _CORE_SOFTWARE_1_IRQ = 2;
  _EXTERNAL_0_IRQ = 3;
  _TIMER_1_IRQ = 4;
  _INPUT_CAPTURE_1_IRQ = 5;
  _OUTPUT_COMPARE_1_IRQ = 6;
  _EXTERNAL_1_IRQ = 7;
  _TIMER_2_IRQ = 8;
  _INPUT_CAPTURE_2_IRQ = 9;
  _OUTPUT_COMPARE_2_IRQ = 10;
  _EXTERNAL_2_IRQ = 11;
  _TIMER_3_IRQ = 12;
  _INPUT_CAPTURE_3_IRQ = 13;
  _OUTPUT_COMPARE_3_IRQ = 14;
  _EXTERNAL_3_IRQ = 15;
  _TIMER_4_IRQ = 16;
  _INPUT_CAPTURE_4_IRQ = 17;
  _OUTPUT_COMPARE_4_IRQ = 18;
  _EXTERNAL_4_IRQ = 19;
  _TIMER_5_IRQ = 20;
  _INPUT_CAPTURE_5_IRQ = 21;
  _OUTPUT_COMPARE_5_IRQ = 22;
  _SPI1_ERR_IRQ = 23;
  _SPI1_TX_IRQ = 24;
  _SPI1_RX_IRQ = 25;
  _UART1_ERR_IRQ = 26;
  _UART1_RX_IRQ = 27;
  _UART1_TX_IRQ = 28;
  _I2C1_BUS_IRQ = 29;
  _I2C1_SLAVE_IRQ = 30;
  _I2C1_MASTER_IRQ = 31;
  _CHANGE_NOTICE_IRQ = 32;
  _ADC_IRQ = 33;
  _PMP_IRQ = 34;
  _COMPARATOR_1_IRQ = 35;
  _COMPARATOR_2_IRQ = 36;
  _SPI2_ERR_IRQ = 37;
  _SPI2_TX_IRQ = 38;
  _SPI2_RX_IRQ = 39;
  _UART2_ERR_IRQ = 40;
  _UART2_RX_IRQ = 41;
  _UART2_TX_IRQ = 42;
  _I2C2_BUS_IRQ = 43;
  _I2C2_SLAVE_IRQ = 44;
  _I2C2_MASTER_IRQ = 45;
  _FAIL_SAFE_MONITOR_IRQ = 46;
  _RTCC_IRQ = 47;
  _FLASH_CONTROL_IRQ = 56;
const
  ADC10_BASE_ADDRESS = $BF809000;
var
  ADC10 : TADC10Registers absolute ADC10_BASE_ADDRESS;
const
  BMX_BASE_ADDRESS = $BF882000;
var
  BMX : TBMXRegisters absolute BMX_BASE_ADDRESS;
const
  CFG_BASE_ADDRESS = $BF80F200;
var
  CFG : TCFGRegisters absolute CFG_BASE_ADDRESS;
const
  CMP_BASE_ADDRESS = $BF80A000;
var
  CMP : TCMPRegisters absolute CMP_BASE_ADDRESS;
const
  CVR_BASE_ADDRESS = $BF809800;
var
  CVR : TCVRRegisters absolute CVR_BASE_ADDRESS;
const
  I2C1_BASE_ADDRESS = $BF805000;
var
  I2C1 : TI2C1Registers absolute I2C1_BASE_ADDRESS;
const
  I2C2_BASE_ADDRESS = $BF805200;
var
  I2C2 : TI2C2Registers absolute I2C2_BASE_ADDRESS;
const
  ICAP1_BASE_ADDRESS = $BF802000;
var
  ICAP1 : TICAP1Registers absolute ICAP1_BASE_ADDRESS;
const
  ICAP2_BASE_ADDRESS = $BF802200;
var
  ICAP2 : TICAP2Registers absolute ICAP2_BASE_ADDRESS;
const
  ICAP3_BASE_ADDRESS = $BF802400;
var
  ICAP3 : TICAP3Registers absolute ICAP3_BASE_ADDRESS;
const
  ICAP4_BASE_ADDRESS = $BF802600;
var
  ICAP4 : TICAP4Registers absolute ICAP4_BASE_ADDRESS;
const
  ICAP5_BASE_ADDRESS = $BF802800;
var
  ICAP5 : TICAP5Registers absolute ICAP5_BASE_ADDRESS;
const
  INT_BASE_ADDRESS = $BF881000;
var
  INT : TINTRegisters absolute INT_BASE_ADDRESS;
const
  NVM_BASE_ADDRESS = $BF80F400;
var
  NVM : TNVMRegisters absolute NVM_BASE_ADDRESS;
const
  OCMP1_BASE_ADDRESS = $BF803000;
var
  OCMP1 : TOCMP1Registers absolute OCMP1_BASE_ADDRESS;
const
  OCMP2_BASE_ADDRESS = $BF803200;
var
  OCMP2 : TOCMP2Registers absolute OCMP2_BASE_ADDRESS;
const
  OCMP3_BASE_ADDRESS = $BF803400;
var
  OCMP3 : TOCMP3Registers absolute OCMP3_BASE_ADDRESS;
const
  OCMP4_BASE_ADDRESS = $BF803600;
var
  OCMP4 : TOCMP4Registers absolute OCMP4_BASE_ADDRESS;
const
  OCMP5_BASE_ADDRESS = $BF803800;
var
  OCMP5 : TOCMP5Registers absolute OCMP5_BASE_ADDRESS;
const
  OSC_BASE_ADDRESS = $BF80F000;
var
  OSC : TOSCRegisters absolute OSC_BASE_ADDRESS;
const
  PCACHE_BASE_ADDRESS = $BF884000;
var
  PCACHE : TPCACHERegisters absolute PCACHE_BASE_ADDRESS;
const
  PMP_BASE_ADDRESS = $BF807000;
var
  PMP : TPMPRegisters absolute PMP_BASE_ADDRESS;
const
  PORTB_BASE_ADDRESS = $BF886040;
var
  PORTB : TPORTBRegisters absolute PORTB_BASE_ADDRESS;
const
  PORTC_BASE_ADDRESS = $BF886080;
var
  PORTC : TPORTCRegisters absolute PORTC_BASE_ADDRESS;
const
  PORTD_BASE_ADDRESS = $BF8860C0;
var
  PORTD : TPORTDRegisters absolute PORTD_BASE_ADDRESS;
const
  PORTE_BASE_ADDRESS = $BF886100;
var
  PORTE : TPORTERegisters absolute PORTE_BASE_ADDRESS;
const
  PORTF_BASE_ADDRESS = $BF886140;
var
  PORTF : TPORTFRegisters absolute PORTF_BASE_ADDRESS;
const
  PORTG_BASE_ADDRESS = $BF886180;
var
  PORTG : TPORTGRegisters absolute PORTG_BASE_ADDRESS;
const
  RCON_BASE_ADDRESS = $BF80F600;
var
  RCON : TRCONRegisters absolute RCON_BASE_ADDRESS;
const
  RTCC_BASE_ADDRESS = $BF800200;
var
  RTCC : TRTCCRegisters absolute RTCC_BASE_ADDRESS;
const
  SPI1_BASE_ADDRESS = $BF805800;
var
  SPI1 : TSPI1Registers absolute SPI1_BASE_ADDRESS;
const
  SPI2_BASE_ADDRESS = $BF805A00;
var
  SPI2 : TSPI2Registers absolute SPI2_BASE_ADDRESS;
const
  TMR1_BASE_ADDRESS = $BF800600;
var
  TMR1 : TTMR1Registers absolute TMR1_BASE_ADDRESS;
const
  TMR23_BASE_ADDRESS = $BF800800;
var
  TMR23 : TTMR23Registers absolute TMR23_BASE_ADDRESS;
const
  TMR3_BASE_ADDRESS = $BF800A00;
var
  TMR3 : TTMR3Registers absolute TMR3_BASE_ADDRESS;
const
  TMR4_BASE_ADDRESS = $BF800C00;
var
  TMR4 : TTMR4Registers absolute TMR4_BASE_ADDRESS;
const
  TMR5_BASE_ADDRESS = $BF800E00;
var
  TMR5 : TTMR5Registers absolute TMR5_BASE_ADDRESS;
const
  UART1_BASE_ADDRESS = $BF806000;
var
  UART1 : TUART1Registers absolute UART1_BASE_ADDRESS;
const
  UART2_BASE_ADDRESS = $BF806200;
var
  UART2 : TUART2Registers absolute UART2_BASE_ADDRESS;
const
  WDT_BASE_ADDRESS = $BF800000;
var
  WDT : TWDTRegisters absolute WDT_BASE_ADDRESS;
const
  _APPI_BASE_ADDRESS = $BF880190;
var
  _APPI : T_APPIRegisters absolute _APPI_BASE_ADDRESS;
const
  _APPO_BASE_ADDRESS = $BF880180;
var
  _APPO : T_APPORegisters absolute _APPO_BASE_ADDRESS;
const
  _DDPSTAT_BASE_ADDRESS = $BF880140;
var
  _DDPSTAT : T_DDPSTATRegisters absolute _DDPSTAT_BASE_ADDRESS;
const
  _STRO_BASE_ADDRESS = $BF880170;
var
  _STRO : T_STRORegisters absolute _STRO_BASE_ADDRESS;
implementation
type
  TDefRegMap = record
    val : longWord;
    clr : longWord;
    &set : longWord;
    inv : longWord;
  end;

  pTDefRegMap = ^TDefRegMap;

procedure TWDT_WDTCON.setWDTCLR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TWDT_WDTCON.clearWDTCLR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TWDT_WDTCON.setWDTCLR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TWDT_WDTCON.getWDTCLR : TBits_1; inline;
begin
  getWDTCLR := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TWDT_WDTCON.setSWDTPS(thebits : TBits_5); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF83 or ( thebits shl 2 );
end;
function  TWDT_WDTCON.getSWDTPS : TBits_5; inline;
begin
  getSWDTPS := (pTDefRegMap(@Self)^.val and $0000007C) shr 2;
end;
procedure TWDT_WDTCON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TWDT_WDTCON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TWDT_WDTCON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TWDT_WDTCON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TWDT_WDTCON.setSWDTPS0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TWDT_WDTCON.clearSWDTPS0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TWDT_WDTCON.setSWDTPS0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TWDT_WDTCON.getSWDTPS0 : TBits_1; inline;
begin
  getSWDTPS0 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TWDT_WDTCON.setSWDTPS1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TWDT_WDTCON.clearSWDTPS1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TWDT_WDTCON.setSWDTPS1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TWDT_WDTCON.getSWDTPS1 : TBits_1; inline;
begin
  getSWDTPS1 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TWDT_WDTCON.setSWDTPS2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TWDT_WDTCON.clearSWDTPS2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TWDT_WDTCON.setSWDTPS2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TWDT_WDTCON.getSWDTPS2 : TBits_1; inline;
begin
  getSWDTPS2 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TWDT_WDTCON.setSWDTPS3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TWDT_WDTCON.clearSWDTPS3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TWDT_WDTCON.setSWDTPS3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TWDT_WDTCON.getSWDTPS3 : TBits_1; inline;
begin
  getSWDTPS3 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TWDT_WDTCON.setSWDTPS4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TWDT_WDTCON.clearSWDTPS4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TWDT_WDTCON.setSWDTPS4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TWDT_WDTCON.getSWDTPS4 : TBits_1; inline;
begin
  getSWDTPS4 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TWDT_WDTCON.setWDTPSTA(thebits : TBits_5); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF83 or ( thebits shl 2 );
end;
function  TWDT_WDTCON.getWDTPSTA : TBits_5; inline;
begin
  getWDTPSTA := (pTDefRegMap(@Self)^.val and $0000007C) shr 2;
end;
procedure TWDT_WDTCON.setWDTPS(thebits : TBits_5); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF83 or ( thebits shl 2 );
end;
function  TWDT_WDTCON.getWDTPS : TBits_5; inline;
begin
  getWDTPS := (pTDefRegMap(@Self)^.val and $0000007C) shr 2;
end;
procedure TWDT_WDTCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TWDT_WDTCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TRTCC_RTCCON.setRTCOE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TRTCC_RTCCON.clearRTCOE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TRTCC_RTCCON.setRTCOE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TRTCC_RTCCON.getRTCOE : TBits_1; inline;
begin
  getRTCOE := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TRTCC_RTCCON.setHALFSEC; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TRTCC_RTCCON.clearHALFSEC; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TRTCC_RTCCON.setHALFSEC(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TRTCC_RTCCON.getHALFSEC : TBits_1; inline;
begin
  getHALFSEC := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TRTCC_RTCCON.setRTCSYNC; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TRTCC_RTCCON.clearRTCSYNC; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TRTCC_RTCCON.setRTCSYNC(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TRTCC_RTCCON.getRTCSYNC : TBits_1; inline;
begin
  getRTCSYNC := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TRTCC_RTCCON.setRTCWREN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TRTCC_RTCCON.clearRTCWREN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TRTCC_RTCCON.setRTCWREN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TRTCC_RTCCON.getRTCWREN : TBits_1; inline;
begin
  getRTCWREN := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TRTCC_RTCCON.setRTCCLKON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TRTCC_RTCCON.clearRTCCLKON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TRTCC_RTCCON.setRTCCLKON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TRTCC_RTCCON.getRTCCLKON : TBits_1; inline;
begin
  getRTCCLKON := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TRTCC_RTCCON.setRTSECSEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TRTCC_RTCCON.clearRTSECSEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TRTCC_RTCCON.setRTSECSEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TRTCC_RTCCON.getRTSECSEL : TBits_1; inline;
begin
  getRTSECSEL := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TRTCC_RTCCON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TRTCC_RTCCON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TRTCC_RTCCON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TRTCC_RTCCON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TRTCC_RTCCON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TRTCC_RTCCON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TRTCC_RTCCON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TRTCC_RTCCON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TRTCC_RTCCON.setCAL(thebits : TBits_10); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FC00FFFF or ( thebits shl 16 );
end;
function  TRTCC_RTCCON.getCAL : TBits_10; inline;
begin
  getCAL := (pTDefRegMap(@Self)^.val and $03FF0000) shr 16;
end;
procedure TRTCC_RTCCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TRTCC_RTCCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TRTCC_RTCALRM.setARPT(thebits : TBits_8); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF00 or ( thebits shl 0 );
end;
function  TRTCC_RTCALRM.getARPT : TBits_8; inline;
begin
  getARPT := (pTDefRegMap(@Self)^.val and $000000FF) shr 0;
end;
procedure TRTCC_RTCALRM.setAMASK(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF0FF or ( thebits shl 8 );
end;
function  TRTCC_RTCALRM.getAMASK : TBits_4; inline;
begin
  getAMASK := (pTDefRegMap(@Self)^.val and $00000F00) shr 8;
end;
procedure TRTCC_RTCALRM.setALRMSYNC; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TRTCC_RTCALRM.clearALRMSYNC; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TRTCC_RTCALRM.setALRMSYNC(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TRTCC_RTCALRM.getALRMSYNC : TBits_1; inline;
begin
  getALRMSYNC := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TRTCC_RTCALRM.setPIV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TRTCC_RTCALRM.clearPIV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TRTCC_RTCALRM.setPIV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TRTCC_RTCALRM.getPIV : TBits_1; inline;
begin
  getPIV := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TRTCC_RTCALRM.setCHIME; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TRTCC_RTCALRM.clearCHIME; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TRTCC_RTCALRM.setCHIME(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TRTCC_RTCALRM.getCHIME : TBits_1; inline;
begin
  getCHIME := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TRTCC_RTCALRM.setALRMEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TRTCC_RTCALRM.clearALRMEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TRTCC_RTCALRM.setALRMEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TRTCC_RTCALRM.getALRMEN : TBits_1; inline;
begin
  getALRMEN := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TRTCC_RTCALRM.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TRTCC_RTCALRM.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TRTCC_RTCTIME.setSEC01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF0FF or ( thebits shl 8 );
end;
function  TRTCC_RTCTIME.getSEC01 : TBits_4; inline;
begin
  getSEC01 := (pTDefRegMap(@Self)^.val and $00000F00) shr 8;
end;
procedure TRTCC_RTCTIME.setSEC10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF0FFF or ( thebits shl 12 );
end;
function  TRTCC_RTCTIME.getSEC10 : TBits_4; inline;
begin
  getSEC10 := (pTDefRegMap(@Self)^.val and $0000F000) shr 12;
end;
procedure TRTCC_RTCTIME.setMIN01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFF0FFFF or ( thebits shl 16 );
end;
function  TRTCC_RTCTIME.getMIN01 : TBits_4; inline;
begin
  getMIN01 := (pTDefRegMap(@Self)^.val and $000F0000) shr 16;
end;
procedure TRTCC_RTCTIME.setMIN10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FF0FFFFF or ( thebits shl 20 );
end;
function  TRTCC_RTCTIME.getMIN10 : TBits_4; inline;
begin
  getMIN10 := (pTDefRegMap(@Self)^.val and $00F00000) shr 20;
end;
procedure TRTCC_RTCTIME.setHR01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $F0FFFFFF or ( thebits shl 24 );
end;
function  TRTCC_RTCTIME.getHR01 : TBits_4; inline;
begin
  getHR01 := (pTDefRegMap(@Self)^.val and $0F000000) shr 24;
end;
procedure TRTCC_RTCTIME.setHR10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $0FFFFFFF or ( thebits shl 28 );
end;
function  TRTCC_RTCTIME.getHR10 : TBits_4; inline;
begin
  getHR10 := (pTDefRegMap(@Self)^.val and $F0000000) shr 28;
end;
procedure TRTCC_RTCTIME.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TRTCC_RTCTIME.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TRTCC_RTCDATE.setWDAY01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF0 or ( thebits shl 0 );
end;
function  TRTCC_RTCDATE.getWDAY01 : TBits_4; inline;
begin
  getWDAY01 := (pTDefRegMap(@Self)^.val and $0000000F) shr 0;
end;
procedure TRTCC_RTCDATE.setDAY01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF0FF or ( thebits shl 8 );
end;
function  TRTCC_RTCDATE.getDAY01 : TBits_4; inline;
begin
  getDAY01 := (pTDefRegMap(@Self)^.val and $00000F00) shr 8;
end;
procedure TRTCC_RTCDATE.setDAY10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF0FFF or ( thebits shl 12 );
end;
function  TRTCC_RTCDATE.getDAY10 : TBits_4; inline;
begin
  getDAY10 := (pTDefRegMap(@Self)^.val and $0000F000) shr 12;
end;
procedure TRTCC_RTCDATE.setMONTH01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFF0FFFF or ( thebits shl 16 );
end;
function  TRTCC_RTCDATE.getMONTH01 : TBits_4; inline;
begin
  getMONTH01 := (pTDefRegMap(@Self)^.val and $000F0000) shr 16;
end;
procedure TRTCC_RTCDATE.setMONTH10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FF0FFFFF or ( thebits shl 20 );
end;
function  TRTCC_RTCDATE.getMONTH10 : TBits_4; inline;
begin
  getMONTH10 := (pTDefRegMap(@Self)^.val and $00F00000) shr 20;
end;
procedure TRTCC_RTCDATE.setYEAR01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $F0FFFFFF or ( thebits shl 24 );
end;
function  TRTCC_RTCDATE.getYEAR01 : TBits_4; inline;
begin
  getYEAR01 := (pTDefRegMap(@Self)^.val and $0F000000) shr 24;
end;
procedure TRTCC_RTCDATE.setYEAR10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $0FFFFFFF or ( thebits shl 28 );
end;
function  TRTCC_RTCDATE.getYEAR10 : TBits_4; inline;
begin
  getYEAR10 := (pTDefRegMap(@Self)^.val and $F0000000) shr 28;
end;
procedure TRTCC_RTCDATE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TRTCC_RTCDATE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TRTCC_ALRMTIME.setSEC01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF0FF or ( thebits shl 8 );
end;
function  TRTCC_ALRMTIME.getSEC01 : TBits_4; inline;
begin
  getSEC01 := (pTDefRegMap(@Self)^.val and $00000F00) shr 8;
end;
procedure TRTCC_ALRMTIME.setSEC10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF0FFF or ( thebits shl 12 );
end;
function  TRTCC_ALRMTIME.getSEC10 : TBits_4; inline;
begin
  getSEC10 := (pTDefRegMap(@Self)^.val and $0000F000) shr 12;
end;
procedure TRTCC_ALRMTIME.setMIN01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFF0FFFF or ( thebits shl 16 );
end;
function  TRTCC_ALRMTIME.getMIN01 : TBits_4; inline;
begin
  getMIN01 := (pTDefRegMap(@Self)^.val and $000F0000) shr 16;
end;
procedure TRTCC_ALRMTIME.setMIN10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FF0FFFFF or ( thebits shl 20 );
end;
function  TRTCC_ALRMTIME.getMIN10 : TBits_4; inline;
begin
  getMIN10 := (pTDefRegMap(@Self)^.val and $00F00000) shr 20;
end;
procedure TRTCC_ALRMTIME.setHR01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $F0FFFFFF or ( thebits shl 24 );
end;
function  TRTCC_ALRMTIME.getHR01 : TBits_4; inline;
begin
  getHR01 := (pTDefRegMap(@Self)^.val and $0F000000) shr 24;
end;
procedure TRTCC_ALRMTIME.setHR10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $0FFFFFFF or ( thebits shl 28 );
end;
function  TRTCC_ALRMTIME.getHR10 : TBits_4; inline;
begin
  getHR10 := (pTDefRegMap(@Self)^.val and $F0000000) shr 28;
end;
procedure TRTCC_ALRMTIME.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TRTCC_ALRMTIME.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TRTCC_ALRMDATE.setWDAY01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF0 or ( thebits shl 0 );
end;
function  TRTCC_ALRMDATE.getWDAY01 : TBits_4; inline;
begin
  getWDAY01 := (pTDefRegMap(@Self)^.val and $0000000F) shr 0;
end;
procedure TRTCC_ALRMDATE.setDAY01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF0FF or ( thebits shl 8 );
end;
function  TRTCC_ALRMDATE.getDAY01 : TBits_4; inline;
begin
  getDAY01 := (pTDefRegMap(@Self)^.val and $00000F00) shr 8;
end;
procedure TRTCC_ALRMDATE.setDAY10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF0FFF or ( thebits shl 12 );
end;
function  TRTCC_ALRMDATE.getDAY10 : TBits_4; inline;
begin
  getDAY10 := (pTDefRegMap(@Self)^.val and $0000F000) shr 12;
end;
procedure TRTCC_ALRMDATE.setMONTH01(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFF0FFFF or ( thebits shl 16 );
end;
function  TRTCC_ALRMDATE.getMONTH01 : TBits_4; inline;
begin
  getMONTH01 := (pTDefRegMap(@Self)^.val and $000F0000) shr 16;
end;
procedure TRTCC_ALRMDATE.setMONTH10(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FF0FFFFF or ( thebits shl 20 );
end;
function  TRTCC_ALRMDATE.getMONTH10 : TBits_4; inline;
begin
  getMONTH10 := (pTDefRegMap(@Self)^.val and $00F00000) shr 20;
end;
procedure TRTCC_ALRMDATE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TRTCC_ALRMDATE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TTMR1_T1CON.setTCS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TTMR1_T1CON.clearTCS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TTMR1_T1CON.setTCS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TTMR1_T1CON.getTCS : TBits_1; inline;
begin
  getTCS := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TTMR1_T1CON.setTSYNC; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TTMR1_T1CON.clearTSYNC; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TTMR1_T1CON.setTSYNC(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TTMR1_T1CON.getTSYNC : TBits_1; inline;
begin
  getTSYNC := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TTMR1_T1CON.setTCKPS(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFCF or ( thebits shl 4 );
end;
function  TTMR1_T1CON.getTCKPS : TBits_2; inline;
begin
  getTCKPS := (pTDefRegMap(@Self)^.val and $00000030) shr 4;
end;
procedure TTMR1_T1CON.setTGATE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TTMR1_T1CON.clearTGATE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TTMR1_T1CON.setTGATE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TTMR1_T1CON.getTGATE : TBits_1; inline;
begin
  getTGATE := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TTMR1_T1CON.setTWIP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TTMR1_T1CON.clearTWIP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TTMR1_T1CON.setTWIP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TTMR1_T1CON.getTWIP : TBits_1; inline;
begin
  getTWIP := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TTMR1_T1CON.setTWDIS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TTMR1_T1CON.clearTWDIS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TTMR1_T1CON.setTWDIS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TTMR1_T1CON.getTWDIS : TBits_1; inline;
begin
  getTWDIS := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TTMR1_T1CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR1_T1CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR1_T1CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR1_T1CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR1_T1CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR1_T1CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR1_T1CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR1_T1CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR1_T1CON.setTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TTMR1_T1CON.clearTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TTMR1_T1CON.setTCKPS0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TTMR1_T1CON.getTCKPS0 : TBits_1; inline;
begin
  getTCKPS0 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TTMR1_T1CON.setTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TTMR1_T1CON.clearTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TTMR1_T1CON.setTCKPS1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TTMR1_T1CON.getTCKPS1 : TBits_1; inline;
begin
  getTCKPS1 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TTMR1_T1CON.setTSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR1_T1CON.clearTSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR1_T1CON.setTSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR1_T1CON.getTSIDL : TBits_1; inline;
begin
  getTSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR1_T1CON.setTON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR1_T1CON.clearTON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR1_T1CON.setTON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR1_T1CON.getTON : TBits_1; inline;
begin
  getTON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR1_T1CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TTMR1_T1CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TTMR23_T2CON.setTCS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TTMR23_T2CON.clearTCS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TTMR23_T2CON.setTCS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TTMR23_T2CON.getTCS : TBits_1; inline;
begin
  getTCS := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TTMR23_T2CON.setT32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TTMR23_T2CON.clearT32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TTMR23_T2CON.setT32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TTMR23_T2CON.getT32 : TBits_1; inline;
begin
  getT32 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TTMR23_T2CON.setTCKPS(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF8F or ( thebits shl 4 );
end;
function  TTMR23_T2CON.getTCKPS : TBits_3; inline;
begin
  getTCKPS := (pTDefRegMap(@Self)^.val and $00000070) shr 4;
end;
procedure TTMR23_T2CON.setTGATE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TTMR23_T2CON.clearTGATE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TTMR23_T2CON.setTGATE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TTMR23_T2CON.getTGATE : TBits_1; inline;
begin
  getTGATE := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TTMR23_T2CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR23_T2CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR23_T2CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR23_T2CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR23_T2CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR23_T2CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR23_T2CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR23_T2CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR23_T2CON.setTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TTMR23_T2CON.clearTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TTMR23_T2CON.setTCKPS0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TTMR23_T2CON.getTCKPS0 : TBits_1; inline;
begin
  getTCKPS0 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TTMR23_T2CON.setTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TTMR23_T2CON.clearTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TTMR23_T2CON.setTCKPS1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TTMR23_T2CON.getTCKPS1 : TBits_1; inline;
begin
  getTCKPS1 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TTMR23_T2CON.setTCKPS2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TTMR23_T2CON.clearTCKPS2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TTMR23_T2CON.setTCKPS2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TTMR23_T2CON.getTCKPS2 : TBits_1; inline;
begin
  getTCKPS2 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TTMR23_T2CON.setTSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR23_T2CON.clearTSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR23_T2CON.setTSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR23_T2CON.getTSIDL : TBits_1; inline;
begin
  getTSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR23_T2CON.setTON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR23_T2CON.clearTON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR23_T2CON.setTON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR23_T2CON.getTON : TBits_1; inline;
begin
  getTON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR23_T2CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TTMR23_T2CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TTMR3_T3CON.setTCS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TTMR3_T3CON.clearTCS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TTMR3_T3CON.setTCS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TTMR3_T3CON.getTCS : TBits_1; inline;
begin
  getTCS := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TTMR3_T3CON.setTCKPS(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF8F or ( thebits shl 4 );
end;
function  TTMR3_T3CON.getTCKPS : TBits_3; inline;
begin
  getTCKPS := (pTDefRegMap(@Self)^.val and $00000070) shr 4;
end;
procedure TTMR3_T3CON.setTGATE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TTMR3_T3CON.clearTGATE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TTMR3_T3CON.setTGATE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TTMR3_T3CON.getTGATE : TBits_1; inline;
begin
  getTGATE := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TTMR3_T3CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR3_T3CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR3_T3CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR3_T3CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR3_T3CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR3_T3CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR3_T3CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR3_T3CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR3_T3CON.setTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TTMR3_T3CON.clearTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TTMR3_T3CON.setTCKPS0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TTMR3_T3CON.getTCKPS0 : TBits_1; inline;
begin
  getTCKPS0 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TTMR3_T3CON.setTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TTMR3_T3CON.clearTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TTMR3_T3CON.setTCKPS1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TTMR3_T3CON.getTCKPS1 : TBits_1; inline;
begin
  getTCKPS1 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TTMR3_T3CON.setTCKPS2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TTMR3_T3CON.clearTCKPS2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TTMR3_T3CON.setTCKPS2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TTMR3_T3CON.getTCKPS2 : TBits_1; inline;
begin
  getTCKPS2 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TTMR3_T3CON.setTSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR3_T3CON.clearTSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR3_T3CON.setTSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR3_T3CON.getTSIDL : TBits_1; inline;
begin
  getTSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR3_T3CON.setTON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR3_T3CON.clearTON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR3_T3CON.setTON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR3_T3CON.getTON : TBits_1; inline;
begin
  getTON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR3_T3CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TTMR3_T3CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TTMR4_T4CON.setTCS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TTMR4_T4CON.clearTCS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TTMR4_T4CON.setTCS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TTMR4_T4CON.getTCS : TBits_1; inline;
begin
  getTCS := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TTMR4_T4CON.setT32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TTMR4_T4CON.clearT32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TTMR4_T4CON.setT32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TTMR4_T4CON.getT32 : TBits_1; inline;
begin
  getT32 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TTMR4_T4CON.setTCKPS(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF8F or ( thebits shl 4 );
end;
function  TTMR4_T4CON.getTCKPS : TBits_3; inline;
begin
  getTCKPS := (pTDefRegMap(@Self)^.val and $00000070) shr 4;
end;
procedure TTMR4_T4CON.setTGATE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TTMR4_T4CON.clearTGATE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TTMR4_T4CON.setTGATE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TTMR4_T4CON.getTGATE : TBits_1; inline;
begin
  getTGATE := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TTMR4_T4CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR4_T4CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR4_T4CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR4_T4CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR4_T4CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR4_T4CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR4_T4CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR4_T4CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR4_T4CON.setTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TTMR4_T4CON.clearTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TTMR4_T4CON.setTCKPS0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TTMR4_T4CON.getTCKPS0 : TBits_1; inline;
begin
  getTCKPS0 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TTMR4_T4CON.setTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TTMR4_T4CON.clearTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TTMR4_T4CON.setTCKPS1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TTMR4_T4CON.getTCKPS1 : TBits_1; inline;
begin
  getTCKPS1 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TTMR4_T4CON.setTCKPS2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TTMR4_T4CON.clearTCKPS2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TTMR4_T4CON.setTCKPS2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TTMR4_T4CON.getTCKPS2 : TBits_1; inline;
begin
  getTCKPS2 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TTMR4_T4CON.setTSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR4_T4CON.clearTSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR4_T4CON.setTSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR4_T4CON.getTSIDL : TBits_1; inline;
begin
  getTSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR4_T4CON.setTON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR4_T4CON.clearTON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR4_T4CON.setTON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR4_T4CON.getTON : TBits_1; inline;
begin
  getTON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR4_T4CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TTMR4_T4CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TTMR5_T5CON.setTCS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TTMR5_T5CON.clearTCS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TTMR5_T5CON.setTCS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TTMR5_T5CON.getTCS : TBits_1; inline;
begin
  getTCS := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TTMR5_T5CON.setTCKPS(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF8F or ( thebits shl 4 );
end;
function  TTMR5_T5CON.getTCKPS : TBits_3; inline;
begin
  getTCKPS := (pTDefRegMap(@Self)^.val and $00000070) shr 4;
end;
procedure TTMR5_T5CON.setTGATE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TTMR5_T5CON.clearTGATE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TTMR5_T5CON.setTGATE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TTMR5_T5CON.getTGATE : TBits_1; inline;
begin
  getTGATE := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TTMR5_T5CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR5_T5CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR5_T5CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR5_T5CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR5_T5CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR5_T5CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR5_T5CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR5_T5CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR5_T5CON.setTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TTMR5_T5CON.clearTCKPS0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TTMR5_T5CON.setTCKPS0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TTMR5_T5CON.getTCKPS0 : TBits_1; inline;
begin
  getTCKPS0 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TTMR5_T5CON.setTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TTMR5_T5CON.clearTCKPS1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TTMR5_T5CON.setTCKPS1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TTMR5_T5CON.getTCKPS1 : TBits_1; inline;
begin
  getTCKPS1 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TTMR5_T5CON.setTCKPS2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TTMR5_T5CON.clearTCKPS2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TTMR5_T5CON.setTCKPS2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TTMR5_T5CON.getTCKPS2 : TBits_1; inline;
begin
  getTCKPS2 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TTMR5_T5CON.setTSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TTMR5_T5CON.clearTSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TTMR5_T5CON.setTSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TTMR5_T5CON.getTSIDL : TBits_1; inline;
begin
  getTSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TTMR5_T5CON.setTON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TTMR5_T5CON.clearTON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TTMR5_T5CON.setTON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TTMR5_T5CON.getTON : TBits_1; inline;
begin
  getTON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TTMR5_T5CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TTMR5_T5CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TICAP1_IC1CON.setICM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TICAP1_IC1CON.getICM : TBits_3; inline;
begin
  getICM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TICAP1_IC1CON.setICBNE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TICAP1_IC1CON.clearICBNE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TICAP1_IC1CON.setICBNE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TICAP1_IC1CON.getICBNE : TBits_1; inline;
begin
  getICBNE := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TICAP1_IC1CON.setICOV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TICAP1_IC1CON.clearICOV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TICAP1_IC1CON.setICOV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TICAP1_IC1CON.getICOV : TBits_1; inline;
begin
  getICOV := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TICAP1_IC1CON.setICI(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF9F or ( thebits shl 5 );
end;
function  TICAP1_IC1CON.getICI : TBits_2; inline;
begin
  getICI := (pTDefRegMap(@Self)^.val and $00000060) shr 5;
end;
procedure TICAP1_IC1CON.setICTMR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TICAP1_IC1CON.clearICTMR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TICAP1_IC1CON.setICTMR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TICAP1_IC1CON.getICTMR : TBits_1; inline;
begin
  getICTMR := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TICAP1_IC1CON.setC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TICAP1_IC1CON.clearC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TICAP1_IC1CON.setC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TICAP1_IC1CON.getC32 : TBits_1; inline;
begin
  getC32 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TICAP1_IC1CON.setFEDGE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TICAP1_IC1CON.clearFEDGE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TICAP1_IC1CON.setFEDGE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TICAP1_IC1CON.getFEDGE : TBits_1; inline;
begin
  getFEDGE := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TICAP1_IC1CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP1_IC1CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP1_IC1CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP1_IC1CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP1_IC1CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TICAP1_IC1CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TICAP1_IC1CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TICAP1_IC1CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TICAP1_IC1CON.setICM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TICAP1_IC1CON.clearICM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TICAP1_IC1CON.setICM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TICAP1_IC1CON.getICM0 : TBits_1; inline;
begin
  getICM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TICAP1_IC1CON.setICM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TICAP1_IC1CON.clearICM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TICAP1_IC1CON.setICM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TICAP1_IC1CON.getICM1 : TBits_1; inline;
begin
  getICM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TICAP1_IC1CON.setICM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TICAP1_IC1CON.clearICM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TICAP1_IC1CON.setICM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TICAP1_IC1CON.getICM2 : TBits_1; inline;
begin
  getICM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TICAP1_IC1CON.setICI0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TICAP1_IC1CON.clearICI0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TICAP1_IC1CON.setICI0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TICAP1_IC1CON.getICI0 : TBits_1; inline;
begin
  getICI0 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TICAP1_IC1CON.setICI1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TICAP1_IC1CON.clearICI1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TICAP1_IC1CON.setICI1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TICAP1_IC1CON.getICI1 : TBits_1; inline;
begin
  getICI1 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TICAP1_IC1CON.setICSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP1_IC1CON.clearICSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP1_IC1CON.setICSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP1_IC1CON.getICSIDL : TBits_1; inline;
begin
  getICSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP1_IC1CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TICAP1_IC1CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TICAP2_IC2CON.setICM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TICAP2_IC2CON.getICM : TBits_3; inline;
begin
  getICM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TICAP2_IC2CON.setICBNE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TICAP2_IC2CON.clearICBNE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TICAP2_IC2CON.setICBNE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TICAP2_IC2CON.getICBNE : TBits_1; inline;
begin
  getICBNE := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TICAP2_IC2CON.setICOV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TICAP2_IC2CON.clearICOV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TICAP2_IC2CON.setICOV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TICAP2_IC2CON.getICOV : TBits_1; inline;
begin
  getICOV := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TICAP2_IC2CON.setICI(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF9F or ( thebits shl 5 );
end;
function  TICAP2_IC2CON.getICI : TBits_2; inline;
begin
  getICI := (pTDefRegMap(@Self)^.val and $00000060) shr 5;
end;
procedure TICAP2_IC2CON.setICTMR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TICAP2_IC2CON.clearICTMR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TICAP2_IC2CON.setICTMR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TICAP2_IC2CON.getICTMR : TBits_1; inline;
begin
  getICTMR := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TICAP2_IC2CON.setC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TICAP2_IC2CON.clearC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TICAP2_IC2CON.setC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TICAP2_IC2CON.getC32 : TBits_1; inline;
begin
  getC32 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TICAP2_IC2CON.setFEDGE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TICAP2_IC2CON.clearFEDGE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TICAP2_IC2CON.setFEDGE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TICAP2_IC2CON.getFEDGE : TBits_1; inline;
begin
  getFEDGE := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TICAP2_IC2CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP2_IC2CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP2_IC2CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP2_IC2CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP2_IC2CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TICAP2_IC2CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TICAP2_IC2CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TICAP2_IC2CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TICAP2_IC2CON.setICM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TICAP2_IC2CON.clearICM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TICAP2_IC2CON.setICM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TICAP2_IC2CON.getICM0 : TBits_1; inline;
begin
  getICM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TICAP2_IC2CON.setICM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TICAP2_IC2CON.clearICM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TICAP2_IC2CON.setICM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TICAP2_IC2CON.getICM1 : TBits_1; inline;
begin
  getICM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TICAP2_IC2CON.setICM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TICAP2_IC2CON.clearICM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TICAP2_IC2CON.setICM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TICAP2_IC2CON.getICM2 : TBits_1; inline;
begin
  getICM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TICAP2_IC2CON.setICI0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TICAP2_IC2CON.clearICI0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TICAP2_IC2CON.setICI0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TICAP2_IC2CON.getICI0 : TBits_1; inline;
begin
  getICI0 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TICAP2_IC2CON.setICI1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TICAP2_IC2CON.clearICI1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TICAP2_IC2CON.setICI1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TICAP2_IC2CON.getICI1 : TBits_1; inline;
begin
  getICI1 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TICAP2_IC2CON.setICSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP2_IC2CON.clearICSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP2_IC2CON.setICSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP2_IC2CON.getICSIDL : TBits_1; inline;
begin
  getICSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP2_IC2CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TICAP2_IC2CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TICAP3_IC3CON.setICM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TICAP3_IC3CON.getICM : TBits_3; inline;
begin
  getICM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TICAP3_IC3CON.setICBNE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TICAP3_IC3CON.clearICBNE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TICAP3_IC3CON.setICBNE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TICAP3_IC3CON.getICBNE : TBits_1; inline;
begin
  getICBNE := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TICAP3_IC3CON.setICOV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TICAP3_IC3CON.clearICOV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TICAP3_IC3CON.setICOV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TICAP3_IC3CON.getICOV : TBits_1; inline;
begin
  getICOV := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TICAP3_IC3CON.setICI(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF9F or ( thebits shl 5 );
end;
function  TICAP3_IC3CON.getICI : TBits_2; inline;
begin
  getICI := (pTDefRegMap(@Self)^.val and $00000060) shr 5;
end;
procedure TICAP3_IC3CON.setICTMR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TICAP3_IC3CON.clearICTMR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TICAP3_IC3CON.setICTMR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TICAP3_IC3CON.getICTMR : TBits_1; inline;
begin
  getICTMR := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TICAP3_IC3CON.setC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TICAP3_IC3CON.clearC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TICAP3_IC3CON.setC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TICAP3_IC3CON.getC32 : TBits_1; inline;
begin
  getC32 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TICAP3_IC3CON.setFEDGE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TICAP3_IC3CON.clearFEDGE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TICAP3_IC3CON.setFEDGE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TICAP3_IC3CON.getFEDGE : TBits_1; inline;
begin
  getFEDGE := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TICAP3_IC3CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP3_IC3CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP3_IC3CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP3_IC3CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP3_IC3CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TICAP3_IC3CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TICAP3_IC3CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TICAP3_IC3CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TICAP3_IC3CON.setICM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TICAP3_IC3CON.clearICM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TICAP3_IC3CON.setICM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TICAP3_IC3CON.getICM0 : TBits_1; inline;
begin
  getICM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TICAP3_IC3CON.setICM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TICAP3_IC3CON.clearICM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TICAP3_IC3CON.setICM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TICAP3_IC3CON.getICM1 : TBits_1; inline;
begin
  getICM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TICAP3_IC3CON.setICM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TICAP3_IC3CON.clearICM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TICAP3_IC3CON.setICM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TICAP3_IC3CON.getICM2 : TBits_1; inline;
begin
  getICM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TICAP3_IC3CON.setICI0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TICAP3_IC3CON.clearICI0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TICAP3_IC3CON.setICI0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TICAP3_IC3CON.getICI0 : TBits_1; inline;
begin
  getICI0 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TICAP3_IC3CON.setICI1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TICAP3_IC3CON.clearICI1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TICAP3_IC3CON.setICI1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TICAP3_IC3CON.getICI1 : TBits_1; inline;
begin
  getICI1 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TICAP3_IC3CON.setICSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP3_IC3CON.clearICSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP3_IC3CON.setICSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP3_IC3CON.getICSIDL : TBits_1; inline;
begin
  getICSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP3_IC3CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TICAP3_IC3CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TICAP4_IC4CON.setICM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TICAP4_IC4CON.getICM : TBits_3; inline;
begin
  getICM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TICAP4_IC4CON.setICBNE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TICAP4_IC4CON.clearICBNE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TICAP4_IC4CON.setICBNE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TICAP4_IC4CON.getICBNE : TBits_1; inline;
begin
  getICBNE := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TICAP4_IC4CON.setICOV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TICAP4_IC4CON.clearICOV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TICAP4_IC4CON.setICOV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TICAP4_IC4CON.getICOV : TBits_1; inline;
begin
  getICOV := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TICAP4_IC4CON.setICI(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF9F or ( thebits shl 5 );
end;
function  TICAP4_IC4CON.getICI : TBits_2; inline;
begin
  getICI := (pTDefRegMap(@Self)^.val and $00000060) shr 5;
end;
procedure TICAP4_IC4CON.setICTMR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TICAP4_IC4CON.clearICTMR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TICAP4_IC4CON.setICTMR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TICAP4_IC4CON.getICTMR : TBits_1; inline;
begin
  getICTMR := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TICAP4_IC4CON.setC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TICAP4_IC4CON.clearC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TICAP4_IC4CON.setC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TICAP4_IC4CON.getC32 : TBits_1; inline;
begin
  getC32 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TICAP4_IC4CON.setFEDGE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TICAP4_IC4CON.clearFEDGE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TICAP4_IC4CON.setFEDGE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TICAP4_IC4CON.getFEDGE : TBits_1; inline;
begin
  getFEDGE := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TICAP4_IC4CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP4_IC4CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP4_IC4CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP4_IC4CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP4_IC4CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TICAP4_IC4CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TICAP4_IC4CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TICAP4_IC4CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TICAP4_IC4CON.setICM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TICAP4_IC4CON.clearICM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TICAP4_IC4CON.setICM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TICAP4_IC4CON.getICM0 : TBits_1; inline;
begin
  getICM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TICAP4_IC4CON.setICM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TICAP4_IC4CON.clearICM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TICAP4_IC4CON.setICM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TICAP4_IC4CON.getICM1 : TBits_1; inline;
begin
  getICM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TICAP4_IC4CON.setICM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TICAP4_IC4CON.clearICM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TICAP4_IC4CON.setICM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TICAP4_IC4CON.getICM2 : TBits_1; inline;
begin
  getICM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TICAP4_IC4CON.setICI0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TICAP4_IC4CON.clearICI0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TICAP4_IC4CON.setICI0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TICAP4_IC4CON.getICI0 : TBits_1; inline;
begin
  getICI0 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TICAP4_IC4CON.setICI1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TICAP4_IC4CON.clearICI1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TICAP4_IC4CON.setICI1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TICAP4_IC4CON.getICI1 : TBits_1; inline;
begin
  getICI1 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TICAP4_IC4CON.setICSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP4_IC4CON.clearICSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP4_IC4CON.setICSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP4_IC4CON.getICSIDL : TBits_1; inline;
begin
  getICSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP4_IC4CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TICAP4_IC4CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TICAP5_IC5CON.setICM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TICAP5_IC5CON.getICM : TBits_3; inline;
begin
  getICM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TICAP5_IC5CON.setICBNE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TICAP5_IC5CON.clearICBNE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TICAP5_IC5CON.setICBNE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TICAP5_IC5CON.getICBNE : TBits_1; inline;
begin
  getICBNE := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TICAP5_IC5CON.setICOV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TICAP5_IC5CON.clearICOV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TICAP5_IC5CON.setICOV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TICAP5_IC5CON.getICOV : TBits_1; inline;
begin
  getICOV := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TICAP5_IC5CON.setICI(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF9F or ( thebits shl 5 );
end;
function  TICAP5_IC5CON.getICI : TBits_2; inline;
begin
  getICI := (pTDefRegMap(@Self)^.val and $00000060) shr 5;
end;
procedure TICAP5_IC5CON.setICTMR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TICAP5_IC5CON.clearICTMR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TICAP5_IC5CON.setICTMR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TICAP5_IC5CON.getICTMR : TBits_1; inline;
begin
  getICTMR := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TICAP5_IC5CON.setC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TICAP5_IC5CON.clearC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TICAP5_IC5CON.setC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TICAP5_IC5CON.getC32 : TBits_1; inline;
begin
  getC32 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TICAP5_IC5CON.setFEDGE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TICAP5_IC5CON.clearFEDGE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TICAP5_IC5CON.setFEDGE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TICAP5_IC5CON.getFEDGE : TBits_1; inline;
begin
  getFEDGE := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TICAP5_IC5CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP5_IC5CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP5_IC5CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP5_IC5CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP5_IC5CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TICAP5_IC5CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TICAP5_IC5CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TICAP5_IC5CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TICAP5_IC5CON.setICM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TICAP5_IC5CON.clearICM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TICAP5_IC5CON.setICM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TICAP5_IC5CON.getICM0 : TBits_1; inline;
begin
  getICM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TICAP5_IC5CON.setICM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TICAP5_IC5CON.clearICM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TICAP5_IC5CON.setICM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TICAP5_IC5CON.getICM1 : TBits_1; inline;
begin
  getICM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TICAP5_IC5CON.setICM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TICAP5_IC5CON.clearICM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TICAP5_IC5CON.setICM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TICAP5_IC5CON.getICM2 : TBits_1; inline;
begin
  getICM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TICAP5_IC5CON.setICI0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TICAP5_IC5CON.clearICI0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TICAP5_IC5CON.setICI0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TICAP5_IC5CON.getICI0 : TBits_1; inline;
begin
  getICI0 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TICAP5_IC5CON.setICI1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TICAP5_IC5CON.clearICI1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TICAP5_IC5CON.setICI1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TICAP5_IC5CON.getICI1 : TBits_1; inline;
begin
  getICI1 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TICAP5_IC5CON.setICSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TICAP5_IC5CON.clearICSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TICAP5_IC5CON.setICSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TICAP5_IC5CON.getICSIDL : TBits_1; inline;
begin
  getICSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TICAP5_IC5CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TICAP5_IC5CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TOCMP1_OC1CON.setOCM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TOCMP1_OC1CON.getOCM : TBits_3; inline;
begin
  getOCM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TOCMP1_OC1CON.setOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TOCMP1_OC1CON.clearOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TOCMP1_OC1CON.setOCTSEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TOCMP1_OC1CON.getOCTSEL : TBits_1; inline;
begin
  getOCTSEL := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TOCMP1_OC1CON.setOCFLT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TOCMP1_OC1CON.clearOCFLT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TOCMP1_OC1CON.setOCFLT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TOCMP1_OC1CON.getOCFLT : TBits_1; inline;
begin
  getOCFLT := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TOCMP1_OC1CON.setOC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TOCMP1_OC1CON.clearOC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TOCMP1_OC1CON.setOC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TOCMP1_OC1CON.getOC32 : TBits_1; inline;
begin
  getOC32 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TOCMP1_OC1CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP1_OC1CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP1_OC1CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP1_OC1CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP1_OC1CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TOCMP1_OC1CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TOCMP1_OC1CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TOCMP1_OC1CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TOCMP1_OC1CON.setOCM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TOCMP1_OC1CON.clearOCM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TOCMP1_OC1CON.setOCM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TOCMP1_OC1CON.getOCM0 : TBits_1; inline;
begin
  getOCM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TOCMP1_OC1CON.setOCM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TOCMP1_OC1CON.clearOCM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TOCMP1_OC1CON.setOCM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TOCMP1_OC1CON.getOCM1 : TBits_1; inline;
begin
  getOCM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TOCMP1_OC1CON.setOCM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TOCMP1_OC1CON.clearOCM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TOCMP1_OC1CON.setOCM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TOCMP1_OC1CON.getOCM2 : TBits_1; inline;
begin
  getOCM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TOCMP1_OC1CON.setOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP1_OC1CON.clearOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP1_OC1CON.setOCSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP1_OC1CON.getOCSIDL : TBits_1; inline;
begin
  getOCSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP1_OC1CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TOCMP1_OC1CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TOCMP2_OC2CON.setOCM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TOCMP2_OC2CON.getOCM : TBits_3; inline;
begin
  getOCM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TOCMP2_OC2CON.setOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TOCMP2_OC2CON.clearOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TOCMP2_OC2CON.setOCTSEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TOCMP2_OC2CON.getOCTSEL : TBits_1; inline;
begin
  getOCTSEL := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TOCMP2_OC2CON.setOCFLT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TOCMP2_OC2CON.clearOCFLT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TOCMP2_OC2CON.setOCFLT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TOCMP2_OC2CON.getOCFLT : TBits_1; inline;
begin
  getOCFLT := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TOCMP2_OC2CON.setOC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TOCMP2_OC2CON.clearOC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TOCMP2_OC2CON.setOC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TOCMP2_OC2CON.getOC32 : TBits_1; inline;
begin
  getOC32 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TOCMP2_OC2CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP2_OC2CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP2_OC2CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP2_OC2CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP2_OC2CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TOCMP2_OC2CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TOCMP2_OC2CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TOCMP2_OC2CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TOCMP2_OC2CON.setOCM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TOCMP2_OC2CON.clearOCM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TOCMP2_OC2CON.setOCM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TOCMP2_OC2CON.getOCM0 : TBits_1; inline;
begin
  getOCM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TOCMP2_OC2CON.setOCM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TOCMP2_OC2CON.clearOCM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TOCMP2_OC2CON.setOCM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TOCMP2_OC2CON.getOCM1 : TBits_1; inline;
begin
  getOCM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TOCMP2_OC2CON.setOCM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TOCMP2_OC2CON.clearOCM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TOCMP2_OC2CON.setOCM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TOCMP2_OC2CON.getOCM2 : TBits_1; inline;
begin
  getOCM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TOCMP2_OC2CON.setOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP2_OC2CON.clearOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP2_OC2CON.setOCSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP2_OC2CON.getOCSIDL : TBits_1; inline;
begin
  getOCSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP2_OC2CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TOCMP2_OC2CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TOCMP3_OC3CON.setOCM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TOCMP3_OC3CON.getOCM : TBits_3; inline;
begin
  getOCM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TOCMP3_OC3CON.setOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TOCMP3_OC3CON.clearOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TOCMP3_OC3CON.setOCTSEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TOCMP3_OC3CON.getOCTSEL : TBits_1; inline;
begin
  getOCTSEL := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TOCMP3_OC3CON.setOCFLT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TOCMP3_OC3CON.clearOCFLT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TOCMP3_OC3CON.setOCFLT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TOCMP3_OC3CON.getOCFLT : TBits_1; inline;
begin
  getOCFLT := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TOCMP3_OC3CON.setOC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TOCMP3_OC3CON.clearOC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TOCMP3_OC3CON.setOC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TOCMP3_OC3CON.getOC32 : TBits_1; inline;
begin
  getOC32 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TOCMP3_OC3CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP3_OC3CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP3_OC3CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP3_OC3CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP3_OC3CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TOCMP3_OC3CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TOCMP3_OC3CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TOCMP3_OC3CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TOCMP3_OC3CON.setOCM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TOCMP3_OC3CON.clearOCM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TOCMP3_OC3CON.setOCM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TOCMP3_OC3CON.getOCM0 : TBits_1; inline;
begin
  getOCM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TOCMP3_OC3CON.setOCM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TOCMP3_OC3CON.clearOCM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TOCMP3_OC3CON.setOCM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TOCMP3_OC3CON.getOCM1 : TBits_1; inline;
begin
  getOCM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TOCMP3_OC3CON.setOCM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TOCMP3_OC3CON.clearOCM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TOCMP3_OC3CON.setOCM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TOCMP3_OC3CON.getOCM2 : TBits_1; inline;
begin
  getOCM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TOCMP3_OC3CON.setOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP3_OC3CON.clearOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP3_OC3CON.setOCSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP3_OC3CON.getOCSIDL : TBits_1; inline;
begin
  getOCSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP3_OC3CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TOCMP3_OC3CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TOCMP4_OC4CON.setOCM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TOCMP4_OC4CON.getOCM : TBits_3; inline;
begin
  getOCM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TOCMP4_OC4CON.setOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TOCMP4_OC4CON.clearOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TOCMP4_OC4CON.setOCTSEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TOCMP4_OC4CON.getOCTSEL : TBits_1; inline;
begin
  getOCTSEL := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TOCMP4_OC4CON.setOCFLT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TOCMP4_OC4CON.clearOCFLT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TOCMP4_OC4CON.setOCFLT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TOCMP4_OC4CON.getOCFLT : TBits_1; inline;
begin
  getOCFLT := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TOCMP4_OC4CON.setOC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TOCMP4_OC4CON.clearOC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TOCMP4_OC4CON.setOC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TOCMP4_OC4CON.getOC32 : TBits_1; inline;
begin
  getOC32 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TOCMP4_OC4CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP4_OC4CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP4_OC4CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP4_OC4CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP4_OC4CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TOCMP4_OC4CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TOCMP4_OC4CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TOCMP4_OC4CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TOCMP4_OC4CON.setOCM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TOCMP4_OC4CON.clearOCM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TOCMP4_OC4CON.setOCM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TOCMP4_OC4CON.getOCM0 : TBits_1; inline;
begin
  getOCM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TOCMP4_OC4CON.setOCM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TOCMP4_OC4CON.clearOCM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TOCMP4_OC4CON.setOCM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TOCMP4_OC4CON.getOCM1 : TBits_1; inline;
begin
  getOCM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TOCMP4_OC4CON.setOCM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TOCMP4_OC4CON.clearOCM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TOCMP4_OC4CON.setOCM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TOCMP4_OC4CON.getOCM2 : TBits_1; inline;
begin
  getOCM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TOCMP4_OC4CON.setOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP4_OC4CON.clearOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP4_OC4CON.setOCSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP4_OC4CON.getOCSIDL : TBits_1; inline;
begin
  getOCSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP4_OC4CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TOCMP4_OC4CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TOCMP5_OC5CON.setOCM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TOCMP5_OC5CON.getOCM : TBits_3; inline;
begin
  getOCM := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TOCMP5_OC5CON.setOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TOCMP5_OC5CON.clearOCTSEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TOCMP5_OC5CON.setOCTSEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TOCMP5_OC5CON.getOCTSEL : TBits_1; inline;
begin
  getOCTSEL := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TOCMP5_OC5CON.setOCFLT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TOCMP5_OC5CON.clearOCFLT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TOCMP5_OC5CON.setOCFLT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TOCMP5_OC5CON.getOCFLT : TBits_1; inline;
begin
  getOCFLT := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TOCMP5_OC5CON.setOC32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TOCMP5_OC5CON.clearOC32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TOCMP5_OC5CON.setOC32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TOCMP5_OC5CON.getOC32 : TBits_1; inline;
begin
  getOC32 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TOCMP5_OC5CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP5_OC5CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP5_OC5CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP5_OC5CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP5_OC5CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TOCMP5_OC5CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TOCMP5_OC5CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TOCMP5_OC5CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TOCMP5_OC5CON.setOCM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TOCMP5_OC5CON.clearOCM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TOCMP5_OC5CON.setOCM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TOCMP5_OC5CON.getOCM0 : TBits_1; inline;
begin
  getOCM0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TOCMP5_OC5CON.setOCM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TOCMP5_OC5CON.clearOCM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TOCMP5_OC5CON.setOCM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TOCMP5_OC5CON.getOCM1 : TBits_1; inline;
begin
  getOCM1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TOCMP5_OC5CON.setOCM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TOCMP5_OC5CON.clearOCM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TOCMP5_OC5CON.setOCM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TOCMP5_OC5CON.getOCM2 : TBits_1; inline;
begin
  getOCM2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TOCMP5_OC5CON.setOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOCMP5_OC5CON.clearOCSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOCMP5_OC5CON.setOCSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOCMP5_OC5CON.getOCSIDL : TBits_1; inline;
begin
  getOCSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOCMP5_OC5CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TOCMP5_OC5CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TI2C1_I2C1CON.setSEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TI2C1_I2C1CON.clearSEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TI2C1_I2C1CON.setSEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TI2C1_I2C1CON.getSEN : TBits_1; inline;
begin
  getSEN := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TI2C1_I2C1CON.setRSEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TI2C1_I2C1CON.clearRSEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TI2C1_I2C1CON.setRSEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TI2C1_I2C1CON.getRSEN : TBits_1; inline;
begin
  getRSEN := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TI2C1_I2C1CON.setPEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TI2C1_I2C1CON.clearPEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TI2C1_I2C1CON.setPEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TI2C1_I2C1CON.getPEN : TBits_1; inline;
begin
  getPEN := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TI2C1_I2C1CON.setRCEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TI2C1_I2C1CON.clearRCEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TI2C1_I2C1CON.setRCEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TI2C1_I2C1CON.getRCEN : TBits_1; inline;
begin
  getRCEN := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TI2C1_I2C1CON.setACKEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TI2C1_I2C1CON.clearACKEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TI2C1_I2C1CON.setACKEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TI2C1_I2C1CON.getACKEN : TBits_1; inline;
begin
  getACKEN := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TI2C1_I2C1CON.setACKDT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TI2C1_I2C1CON.clearACKDT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TI2C1_I2C1CON.setACKDT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TI2C1_I2C1CON.getACKDT : TBits_1; inline;
begin
  getACKDT := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TI2C1_I2C1CON.setSTREN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TI2C1_I2C1CON.clearSTREN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TI2C1_I2C1CON.setSTREN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TI2C1_I2C1CON.getSTREN : TBits_1; inline;
begin
  getSTREN := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TI2C1_I2C1CON.setGCEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TI2C1_I2C1CON.clearGCEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TI2C1_I2C1CON.setGCEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TI2C1_I2C1CON.getGCEN : TBits_1; inline;
begin
  getGCEN := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TI2C1_I2C1CON.setSMEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TI2C1_I2C1CON.clearSMEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TI2C1_I2C1CON.setSMEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TI2C1_I2C1CON.getSMEN : TBits_1; inline;
begin
  getSMEN := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TI2C1_I2C1CON.setDISSLW; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TI2C1_I2C1CON.clearDISSLW; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TI2C1_I2C1CON.setDISSLW(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TI2C1_I2C1CON.getDISSLW : TBits_1; inline;
begin
  getDISSLW := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TI2C1_I2C1CON.setA10M; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TI2C1_I2C1CON.clearA10M; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TI2C1_I2C1CON.setA10M(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TI2C1_I2C1CON.getA10M : TBits_1; inline;
begin
  getA10M := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TI2C1_I2C1CON.setSTRICT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TI2C1_I2C1CON.clearSTRICT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TI2C1_I2C1CON.setSTRICT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TI2C1_I2C1CON.getSTRICT : TBits_1; inline;
begin
  getSTRICT := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TI2C1_I2C1CON.setSCLREL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TI2C1_I2C1CON.clearSCLREL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TI2C1_I2C1CON.setSCLREL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TI2C1_I2C1CON.getSCLREL : TBits_1; inline;
begin
  getSCLREL := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TI2C1_I2C1CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TI2C1_I2C1CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TI2C1_I2C1CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TI2C1_I2C1CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TI2C1_I2C1CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TI2C1_I2C1CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TI2C1_I2C1CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TI2C1_I2C1CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TI2C1_I2C1CON.setIPMIEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TI2C1_I2C1CON.clearIPMIEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TI2C1_I2C1CON.setIPMIEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TI2C1_I2C1CON.getIPMIEN : TBits_1; inline;
begin
  getIPMIEN := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TI2C1_I2C1CON.setI2CSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TI2C1_I2C1CON.clearI2CSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TI2C1_I2C1CON.setI2CSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TI2C1_I2C1CON.getI2CSIDL : TBits_1; inline;
begin
  getI2CSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TI2C1_I2C1CON.setI2CEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TI2C1_I2C1CON.clearI2CEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TI2C1_I2C1CON.setI2CEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TI2C1_I2C1CON.getI2CEN : TBits_1; inline;
begin
  getI2CEN := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TI2C1_I2C1CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TI2C1_I2C1CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TI2C1_I2C1STAT.setTBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TI2C1_I2C1STAT.clearTBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TI2C1_I2C1STAT.setTBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TI2C1_I2C1STAT.getTBF : TBits_1; inline;
begin
  getTBF := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TI2C1_I2C1STAT.setRBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TI2C1_I2C1STAT.clearRBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TI2C1_I2C1STAT.setRBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TI2C1_I2C1STAT.getRBF : TBits_1; inline;
begin
  getRBF := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TI2C1_I2C1STAT.setR_W; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TI2C1_I2C1STAT.clearR_W; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TI2C1_I2C1STAT.setR_W(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TI2C1_I2C1STAT.getR_W : TBits_1; inline;
begin
  getR_W := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TI2C1_I2C1STAT.setS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TI2C1_I2C1STAT.clearS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TI2C1_I2C1STAT.setS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TI2C1_I2C1STAT.getS : TBits_1; inline;
begin
  getS := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TI2C1_I2C1STAT.setP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TI2C1_I2C1STAT.clearP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TI2C1_I2C1STAT.setP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TI2C1_I2C1STAT.getP : TBits_1; inline;
begin
  getP := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TI2C1_I2C1STAT.setD_A; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TI2C1_I2C1STAT.clearD_A; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TI2C1_I2C1STAT.setD_A(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TI2C1_I2C1STAT.getD_A : TBits_1; inline;
begin
  getD_A := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TI2C1_I2C1STAT.setI2COV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TI2C1_I2C1STAT.clearI2COV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TI2C1_I2C1STAT.setI2COV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TI2C1_I2C1STAT.getI2COV : TBits_1; inline;
begin
  getI2COV := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TI2C1_I2C1STAT.setIWCOL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TI2C1_I2C1STAT.clearIWCOL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TI2C1_I2C1STAT.setIWCOL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TI2C1_I2C1STAT.getIWCOL : TBits_1; inline;
begin
  getIWCOL := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TI2C1_I2C1STAT.setADD10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TI2C1_I2C1STAT.clearADD10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TI2C1_I2C1STAT.setADD10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TI2C1_I2C1STAT.getADD10 : TBits_1; inline;
begin
  getADD10 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TI2C1_I2C1STAT.setGCSTAT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TI2C1_I2C1STAT.clearGCSTAT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TI2C1_I2C1STAT.setGCSTAT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TI2C1_I2C1STAT.getGCSTAT : TBits_1; inline;
begin
  getGCSTAT := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TI2C1_I2C1STAT.setBCL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TI2C1_I2C1STAT.clearBCL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TI2C1_I2C1STAT.setBCL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TI2C1_I2C1STAT.getBCL : TBits_1; inline;
begin
  getBCL := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TI2C1_I2C1STAT.setTRSTAT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TI2C1_I2C1STAT.clearTRSTAT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TI2C1_I2C1STAT.setTRSTAT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TI2C1_I2C1STAT.getTRSTAT : TBits_1; inline;
begin
  getTRSTAT := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TI2C1_I2C1STAT.setACKSTAT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TI2C1_I2C1STAT.clearACKSTAT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TI2C1_I2C1STAT.setACKSTAT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TI2C1_I2C1STAT.getACKSTAT : TBits_1; inline;
begin
  getACKSTAT := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TI2C1_I2C1STAT.setI2CPOV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TI2C1_I2C1STAT.clearI2CPOV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TI2C1_I2C1STAT.setI2CPOV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TI2C1_I2C1STAT.getI2CPOV : TBits_1; inline;
begin
  getI2CPOV := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TI2C1_I2C1STAT.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TI2C1_I2C1STAT.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TI2C2_I2C2CON.setSEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TI2C2_I2C2CON.clearSEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TI2C2_I2C2CON.setSEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TI2C2_I2C2CON.getSEN : TBits_1; inline;
begin
  getSEN := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TI2C2_I2C2CON.setRSEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TI2C2_I2C2CON.clearRSEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TI2C2_I2C2CON.setRSEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TI2C2_I2C2CON.getRSEN : TBits_1; inline;
begin
  getRSEN := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TI2C2_I2C2CON.setPEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TI2C2_I2C2CON.clearPEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TI2C2_I2C2CON.setPEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TI2C2_I2C2CON.getPEN : TBits_1; inline;
begin
  getPEN := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TI2C2_I2C2CON.setRCEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TI2C2_I2C2CON.clearRCEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TI2C2_I2C2CON.setRCEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TI2C2_I2C2CON.getRCEN : TBits_1; inline;
begin
  getRCEN := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TI2C2_I2C2CON.setACKEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TI2C2_I2C2CON.clearACKEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TI2C2_I2C2CON.setACKEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TI2C2_I2C2CON.getACKEN : TBits_1; inline;
begin
  getACKEN := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TI2C2_I2C2CON.setACKDT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TI2C2_I2C2CON.clearACKDT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TI2C2_I2C2CON.setACKDT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TI2C2_I2C2CON.getACKDT : TBits_1; inline;
begin
  getACKDT := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TI2C2_I2C2CON.setSTREN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TI2C2_I2C2CON.clearSTREN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TI2C2_I2C2CON.setSTREN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TI2C2_I2C2CON.getSTREN : TBits_1; inline;
begin
  getSTREN := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TI2C2_I2C2CON.setGCEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TI2C2_I2C2CON.clearGCEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TI2C2_I2C2CON.setGCEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TI2C2_I2C2CON.getGCEN : TBits_1; inline;
begin
  getGCEN := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TI2C2_I2C2CON.setSMEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TI2C2_I2C2CON.clearSMEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TI2C2_I2C2CON.setSMEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TI2C2_I2C2CON.getSMEN : TBits_1; inline;
begin
  getSMEN := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TI2C2_I2C2CON.setDISSLW; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TI2C2_I2C2CON.clearDISSLW; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TI2C2_I2C2CON.setDISSLW(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TI2C2_I2C2CON.getDISSLW : TBits_1; inline;
begin
  getDISSLW := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TI2C2_I2C2CON.setA10M; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TI2C2_I2C2CON.clearA10M; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TI2C2_I2C2CON.setA10M(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TI2C2_I2C2CON.getA10M : TBits_1; inline;
begin
  getA10M := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TI2C2_I2C2CON.setSTRICT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TI2C2_I2C2CON.clearSTRICT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TI2C2_I2C2CON.setSTRICT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TI2C2_I2C2CON.getSTRICT : TBits_1; inline;
begin
  getSTRICT := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TI2C2_I2C2CON.setSCLREL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TI2C2_I2C2CON.clearSCLREL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TI2C2_I2C2CON.setSCLREL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TI2C2_I2C2CON.getSCLREL : TBits_1; inline;
begin
  getSCLREL := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TI2C2_I2C2CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TI2C2_I2C2CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TI2C2_I2C2CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TI2C2_I2C2CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TI2C2_I2C2CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TI2C2_I2C2CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TI2C2_I2C2CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TI2C2_I2C2CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TI2C2_I2C2CON.setIPMIEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TI2C2_I2C2CON.clearIPMIEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TI2C2_I2C2CON.setIPMIEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TI2C2_I2C2CON.getIPMIEN : TBits_1; inline;
begin
  getIPMIEN := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TI2C2_I2C2CON.setI2CSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TI2C2_I2C2CON.clearI2CSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TI2C2_I2C2CON.setI2CSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TI2C2_I2C2CON.getI2CSIDL : TBits_1; inline;
begin
  getI2CSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TI2C2_I2C2CON.setI2CEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TI2C2_I2C2CON.clearI2CEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TI2C2_I2C2CON.setI2CEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TI2C2_I2C2CON.getI2CEN : TBits_1; inline;
begin
  getI2CEN := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TI2C2_I2C2CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TI2C2_I2C2CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TI2C2_I2C2STAT.setTBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TI2C2_I2C2STAT.clearTBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TI2C2_I2C2STAT.setTBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TI2C2_I2C2STAT.getTBF : TBits_1; inline;
begin
  getTBF := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TI2C2_I2C2STAT.setRBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TI2C2_I2C2STAT.clearRBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TI2C2_I2C2STAT.setRBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TI2C2_I2C2STAT.getRBF : TBits_1; inline;
begin
  getRBF := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TI2C2_I2C2STAT.setR_W; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TI2C2_I2C2STAT.clearR_W; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TI2C2_I2C2STAT.setR_W(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TI2C2_I2C2STAT.getR_W : TBits_1; inline;
begin
  getR_W := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TI2C2_I2C2STAT.setS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TI2C2_I2C2STAT.clearS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TI2C2_I2C2STAT.setS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TI2C2_I2C2STAT.getS : TBits_1; inline;
begin
  getS := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TI2C2_I2C2STAT.setP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TI2C2_I2C2STAT.clearP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TI2C2_I2C2STAT.setP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TI2C2_I2C2STAT.getP : TBits_1; inline;
begin
  getP := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TI2C2_I2C2STAT.setD_A; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TI2C2_I2C2STAT.clearD_A; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TI2C2_I2C2STAT.setD_A(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TI2C2_I2C2STAT.getD_A : TBits_1; inline;
begin
  getD_A := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TI2C2_I2C2STAT.setI2COV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TI2C2_I2C2STAT.clearI2COV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TI2C2_I2C2STAT.setI2COV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TI2C2_I2C2STAT.getI2COV : TBits_1; inline;
begin
  getI2COV := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TI2C2_I2C2STAT.setIWCOL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TI2C2_I2C2STAT.clearIWCOL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TI2C2_I2C2STAT.setIWCOL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TI2C2_I2C2STAT.getIWCOL : TBits_1; inline;
begin
  getIWCOL := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TI2C2_I2C2STAT.setADD10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TI2C2_I2C2STAT.clearADD10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TI2C2_I2C2STAT.setADD10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TI2C2_I2C2STAT.getADD10 : TBits_1; inline;
begin
  getADD10 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TI2C2_I2C2STAT.setGCSTAT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TI2C2_I2C2STAT.clearGCSTAT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TI2C2_I2C2STAT.setGCSTAT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TI2C2_I2C2STAT.getGCSTAT : TBits_1; inline;
begin
  getGCSTAT := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TI2C2_I2C2STAT.setBCL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TI2C2_I2C2STAT.clearBCL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TI2C2_I2C2STAT.setBCL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TI2C2_I2C2STAT.getBCL : TBits_1; inline;
begin
  getBCL := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TI2C2_I2C2STAT.setTRSTAT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TI2C2_I2C2STAT.clearTRSTAT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TI2C2_I2C2STAT.setTRSTAT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TI2C2_I2C2STAT.getTRSTAT : TBits_1; inline;
begin
  getTRSTAT := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TI2C2_I2C2STAT.setACKSTAT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TI2C2_I2C2STAT.clearACKSTAT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TI2C2_I2C2STAT.setACKSTAT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TI2C2_I2C2STAT.getACKSTAT : TBits_1; inline;
begin
  getACKSTAT := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TI2C2_I2C2STAT.setI2CPOV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TI2C2_I2C2STAT.clearI2CPOV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TI2C2_I2C2STAT.setI2CPOV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TI2C2_I2C2STAT.getI2CPOV : TBits_1; inline;
begin
  getI2CPOV := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TI2C2_I2C2STAT.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TI2C2_I2C2STAT.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TSPI1_SPI1CON.setMSTEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TSPI1_SPI1CON.clearMSTEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TSPI1_SPI1CON.setMSTEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TSPI1_SPI1CON.getMSTEN : TBits_1; inline;
begin
  getMSTEN := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TSPI1_SPI1CON.setCKP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TSPI1_SPI1CON.clearCKP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TSPI1_SPI1CON.setCKP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TSPI1_SPI1CON.getCKP : TBits_1; inline;
begin
  getCKP := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TSPI1_SPI1CON.setSSEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TSPI1_SPI1CON.clearSSEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TSPI1_SPI1CON.setSSEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TSPI1_SPI1CON.getSSEN : TBits_1; inline;
begin
  getSSEN := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TSPI1_SPI1CON.setCKE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TSPI1_SPI1CON.clearCKE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TSPI1_SPI1CON.setCKE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TSPI1_SPI1CON.getCKE : TBits_1; inline;
begin
  getCKE := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TSPI1_SPI1CON.setSMP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TSPI1_SPI1CON.clearSMP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TSPI1_SPI1CON.setSMP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TSPI1_SPI1CON.getSMP : TBits_1; inline;
begin
  getSMP := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TSPI1_SPI1CON.setMODE16; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TSPI1_SPI1CON.clearMODE16; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TSPI1_SPI1CON.setMODE16(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TSPI1_SPI1CON.getMODE16 : TBits_1; inline;
begin
  getMODE16 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TSPI1_SPI1CON.setMODE32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TSPI1_SPI1CON.clearMODE32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TSPI1_SPI1CON.setMODE32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TSPI1_SPI1CON.getMODE32 : TBits_1; inline;
begin
  getMODE32 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TSPI1_SPI1CON.setDISSDO; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TSPI1_SPI1CON.clearDISSDO; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TSPI1_SPI1CON.setDISSDO(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TSPI1_SPI1CON.getDISSDO : TBits_1; inline;
begin
  getDISSDO := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TSPI1_SPI1CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TSPI1_SPI1CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TSPI1_SPI1CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TSPI1_SPI1CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TSPI1_SPI1CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TSPI1_SPI1CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TSPI1_SPI1CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TSPI1_SPI1CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TSPI1_SPI1CON.setSPIFE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00020000;
end;
procedure TSPI1_SPI1CON.clearSPIFE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00020000;
end;
procedure TSPI1_SPI1CON.setSPIFE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00020000
  else
    pTDefRegMap(@Self)^.&set := $00020000;
end;
function  TSPI1_SPI1CON.getSPIFE : TBits_1; inline;
begin
  getSPIFE := (pTDefRegMap(@Self)^.val and $00020000) shr 17;
end;
procedure TSPI1_SPI1CON.setFRMPOL; inline;
begin
  pTDefRegMap(@Self)^.&set := $20000000;
end;
procedure TSPI1_SPI1CON.clearFRMPOL; inline;
begin
  pTDefRegMap(@Self)^.clr := $20000000;
end;
procedure TSPI1_SPI1CON.setFRMPOL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $20000000
  else
    pTDefRegMap(@Self)^.&set := $20000000;
end;
function  TSPI1_SPI1CON.getFRMPOL : TBits_1; inline;
begin
  getFRMPOL := (pTDefRegMap(@Self)^.val and $20000000) shr 29;
end;
procedure TSPI1_SPI1CON.setFRMSYNC; inline;
begin
  pTDefRegMap(@Self)^.&set := $40000000;
end;
procedure TSPI1_SPI1CON.clearFRMSYNC; inline;
begin
  pTDefRegMap(@Self)^.clr := $40000000;
end;
procedure TSPI1_SPI1CON.setFRMSYNC(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $40000000
  else
    pTDefRegMap(@Self)^.&set := $40000000;
end;
function  TSPI1_SPI1CON.getFRMSYNC : TBits_1; inline;
begin
  getFRMSYNC := (pTDefRegMap(@Self)^.val and $40000000) shr 30;
end;
procedure TSPI1_SPI1CON.setFRMEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $80000000;
end;
procedure TSPI1_SPI1CON.clearFRMEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $80000000;
end;
procedure TSPI1_SPI1CON.setFRMEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $80000000
  else
    pTDefRegMap(@Self)^.&set := $80000000;
end;
function  TSPI1_SPI1CON.getFRMEN : TBits_1; inline;
begin
  getFRMEN := (pTDefRegMap(@Self)^.val and $80000000) shr 31;
end;
procedure TSPI1_SPI1CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TSPI1_SPI1CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TSPI1_SPI1STAT.setSPIRBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TSPI1_SPI1STAT.clearSPIRBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TSPI1_SPI1STAT.setSPIRBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TSPI1_SPI1STAT.getSPIRBF : TBits_1; inline;
begin
  getSPIRBF := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TSPI1_SPI1STAT.setSPITBE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TSPI1_SPI1STAT.clearSPITBE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TSPI1_SPI1STAT.setSPITBE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TSPI1_SPI1STAT.getSPITBE : TBits_1; inline;
begin
  getSPITBE := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TSPI1_SPI1STAT.setSPIROV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TSPI1_SPI1STAT.clearSPIROV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TSPI1_SPI1STAT.setSPIROV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TSPI1_SPI1STAT.getSPIROV : TBits_1; inline;
begin
  getSPIROV := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TSPI1_SPI1STAT.setSPIBUSY; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TSPI1_SPI1STAT.clearSPIBUSY; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TSPI1_SPI1STAT.setSPIBUSY(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TSPI1_SPI1STAT.getSPIBUSY : TBits_1; inline;
begin
  getSPIBUSY := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TSPI1_SPI1STAT.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TSPI1_SPI1STAT.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TSPI2_SPI2CON.setMSTEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TSPI2_SPI2CON.clearMSTEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TSPI2_SPI2CON.setMSTEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TSPI2_SPI2CON.getMSTEN : TBits_1; inline;
begin
  getMSTEN := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TSPI2_SPI2CON.setCKP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TSPI2_SPI2CON.clearCKP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TSPI2_SPI2CON.setCKP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TSPI2_SPI2CON.getCKP : TBits_1; inline;
begin
  getCKP := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TSPI2_SPI2CON.setSSEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TSPI2_SPI2CON.clearSSEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TSPI2_SPI2CON.setSSEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TSPI2_SPI2CON.getSSEN : TBits_1; inline;
begin
  getSSEN := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TSPI2_SPI2CON.setCKE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TSPI2_SPI2CON.clearCKE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TSPI2_SPI2CON.setCKE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TSPI2_SPI2CON.getCKE : TBits_1; inline;
begin
  getCKE := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TSPI2_SPI2CON.setSMP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TSPI2_SPI2CON.clearSMP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TSPI2_SPI2CON.setSMP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TSPI2_SPI2CON.getSMP : TBits_1; inline;
begin
  getSMP := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TSPI2_SPI2CON.setMODE16; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TSPI2_SPI2CON.clearMODE16; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TSPI2_SPI2CON.setMODE16(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TSPI2_SPI2CON.getMODE16 : TBits_1; inline;
begin
  getMODE16 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TSPI2_SPI2CON.setMODE32; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TSPI2_SPI2CON.clearMODE32; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TSPI2_SPI2CON.setMODE32(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TSPI2_SPI2CON.getMODE32 : TBits_1; inline;
begin
  getMODE32 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TSPI2_SPI2CON.setDISSDO; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TSPI2_SPI2CON.clearDISSDO; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TSPI2_SPI2CON.setDISSDO(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TSPI2_SPI2CON.getDISSDO : TBits_1; inline;
begin
  getDISSDO := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TSPI2_SPI2CON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TSPI2_SPI2CON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TSPI2_SPI2CON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TSPI2_SPI2CON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TSPI2_SPI2CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TSPI2_SPI2CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TSPI2_SPI2CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TSPI2_SPI2CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TSPI2_SPI2CON.setSPIFE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00020000;
end;
procedure TSPI2_SPI2CON.clearSPIFE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00020000;
end;
procedure TSPI2_SPI2CON.setSPIFE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00020000
  else
    pTDefRegMap(@Self)^.&set := $00020000;
end;
function  TSPI2_SPI2CON.getSPIFE : TBits_1; inline;
begin
  getSPIFE := (pTDefRegMap(@Self)^.val and $00020000) shr 17;
end;
procedure TSPI2_SPI2CON.setFRMPOL; inline;
begin
  pTDefRegMap(@Self)^.&set := $20000000;
end;
procedure TSPI2_SPI2CON.clearFRMPOL; inline;
begin
  pTDefRegMap(@Self)^.clr := $20000000;
end;
procedure TSPI2_SPI2CON.setFRMPOL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $20000000
  else
    pTDefRegMap(@Self)^.&set := $20000000;
end;
function  TSPI2_SPI2CON.getFRMPOL : TBits_1; inline;
begin
  getFRMPOL := (pTDefRegMap(@Self)^.val and $20000000) shr 29;
end;
procedure TSPI2_SPI2CON.setFRMSYNC; inline;
begin
  pTDefRegMap(@Self)^.&set := $40000000;
end;
procedure TSPI2_SPI2CON.clearFRMSYNC; inline;
begin
  pTDefRegMap(@Self)^.clr := $40000000;
end;
procedure TSPI2_SPI2CON.setFRMSYNC(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $40000000
  else
    pTDefRegMap(@Self)^.&set := $40000000;
end;
function  TSPI2_SPI2CON.getFRMSYNC : TBits_1; inline;
begin
  getFRMSYNC := (pTDefRegMap(@Self)^.val and $40000000) shr 30;
end;
procedure TSPI2_SPI2CON.setFRMEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $80000000;
end;
procedure TSPI2_SPI2CON.clearFRMEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $80000000;
end;
procedure TSPI2_SPI2CON.setFRMEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $80000000
  else
    pTDefRegMap(@Self)^.&set := $80000000;
end;
function  TSPI2_SPI2CON.getFRMEN : TBits_1; inline;
begin
  getFRMEN := (pTDefRegMap(@Self)^.val and $80000000) shr 31;
end;
procedure TSPI2_SPI2CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TSPI2_SPI2CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TSPI2_SPI2STAT.setSPIRBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TSPI2_SPI2STAT.clearSPIRBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TSPI2_SPI2STAT.setSPIRBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TSPI2_SPI2STAT.getSPIRBF : TBits_1; inline;
begin
  getSPIRBF := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TSPI2_SPI2STAT.setSPITBE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TSPI2_SPI2STAT.clearSPITBE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TSPI2_SPI2STAT.setSPITBE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TSPI2_SPI2STAT.getSPITBE : TBits_1; inline;
begin
  getSPITBE := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TSPI2_SPI2STAT.setSPIROV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TSPI2_SPI2STAT.clearSPIROV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TSPI2_SPI2STAT.setSPIROV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TSPI2_SPI2STAT.getSPIROV : TBits_1; inline;
begin
  getSPIROV := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TSPI2_SPI2STAT.setSPIBUSY; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TSPI2_SPI2STAT.clearSPIBUSY; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TSPI2_SPI2STAT.setSPIBUSY(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TSPI2_SPI2STAT.getSPIBUSY : TBits_1; inline;
begin
  getSPIBUSY := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TSPI2_SPI2STAT.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TSPI2_SPI2STAT.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TUART1_U1MODE.setSTSEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TUART1_U1MODE.clearSTSEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TUART1_U1MODE.setSTSEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TUART1_U1MODE.getSTSEL : TBits_1; inline;
begin
  getSTSEL := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TUART1_U1MODE.setPDSEL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF9 or ( thebits shl 1 );
end;
function  TUART1_U1MODE.getPDSEL : TBits_2; inline;
begin
  getPDSEL := (pTDefRegMap(@Self)^.val and $00000006) shr 1;
end;
procedure TUART1_U1MODE.setBRGH; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TUART1_U1MODE.clearBRGH; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TUART1_U1MODE.setBRGH(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TUART1_U1MODE.getBRGH : TBits_1; inline;
begin
  getBRGH := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TUART1_U1MODE.setRXINV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TUART1_U1MODE.clearRXINV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TUART1_U1MODE.setRXINV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TUART1_U1MODE.getRXINV : TBits_1; inline;
begin
  getRXINV := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TUART1_U1MODE.setABAUD; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TUART1_U1MODE.clearABAUD; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TUART1_U1MODE.setABAUD(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TUART1_U1MODE.getABAUD : TBits_1; inline;
begin
  getABAUD := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TUART1_U1MODE.setLPBACK; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TUART1_U1MODE.clearLPBACK; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TUART1_U1MODE.setLPBACK(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TUART1_U1MODE.getLPBACK : TBits_1; inline;
begin
  getLPBACK := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TUART1_U1MODE.setWAKE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TUART1_U1MODE.clearWAKE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TUART1_U1MODE.setWAKE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TUART1_U1MODE.getWAKE : TBits_1; inline;
begin
  getWAKE := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TUART1_U1MODE.setUEN(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFCFF or ( thebits shl 8 );
end;
function  TUART1_U1MODE.getUEN : TBits_2; inline;
begin
  getUEN := (pTDefRegMap(@Self)^.val and $00000300) shr 8;
end;
procedure TUART1_U1MODE.setRTSMD; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TUART1_U1MODE.clearRTSMD; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TUART1_U1MODE.setRTSMD(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TUART1_U1MODE.getRTSMD : TBits_1; inline;
begin
  getRTSMD := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TUART1_U1MODE.setIREN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TUART1_U1MODE.clearIREN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TUART1_U1MODE.setIREN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TUART1_U1MODE.getIREN : TBits_1; inline;
begin
  getIREN := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TUART1_U1MODE.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TUART1_U1MODE.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TUART1_U1MODE.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TUART1_U1MODE.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TUART1_U1MODE.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TUART1_U1MODE.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TUART1_U1MODE.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TUART1_U1MODE.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TUART1_U1MODE.setPDSEL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TUART1_U1MODE.clearPDSEL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TUART1_U1MODE.setPDSEL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TUART1_U1MODE.getPDSEL0 : TBits_1; inline;
begin
  getPDSEL0 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TUART1_U1MODE.setPDSEL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TUART1_U1MODE.clearPDSEL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TUART1_U1MODE.setPDSEL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TUART1_U1MODE.getPDSEL1 : TBits_1; inline;
begin
  getPDSEL1 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TUART1_U1MODE.setUEN0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TUART1_U1MODE.clearUEN0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TUART1_U1MODE.setUEN0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TUART1_U1MODE.getUEN0 : TBits_1; inline;
begin
  getUEN0 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TUART1_U1MODE.setUEN1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TUART1_U1MODE.clearUEN1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TUART1_U1MODE.setUEN1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TUART1_U1MODE.getUEN1 : TBits_1; inline;
begin
  getUEN1 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TUART1_U1MODE.setUSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TUART1_U1MODE.clearUSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TUART1_U1MODE.setUSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TUART1_U1MODE.getUSIDL : TBits_1; inline;
begin
  getUSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TUART1_U1MODE.setUARTEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TUART1_U1MODE.clearUARTEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TUART1_U1MODE.setUARTEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TUART1_U1MODE.getUARTEN : TBits_1; inline;
begin
  getUARTEN := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TUART1_U1MODE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TUART1_U1MODE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TUART1_U1STA.setURXDA; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TUART1_U1STA.clearURXDA; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TUART1_U1STA.setURXDA(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TUART1_U1STA.getURXDA : TBits_1; inline;
begin
  getURXDA := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TUART1_U1STA.setOERR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TUART1_U1STA.clearOERR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TUART1_U1STA.setOERR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TUART1_U1STA.getOERR : TBits_1; inline;
begin
  getOERR := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TUART1_U1STA.setFERR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TUART1_U1STA.clearFERR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TUART1_U1STA.setFERR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TUART1_U1STA.getFERR : TBits_1; inline;
begin
  getFERR := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TUART1_U1STA.setPERR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TUART1_U1STA.clearPERR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TUART1_U1STA.setPERR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TUART1_U1STA.getPERR : TBits_1; inline;
begin
  getPERR := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TUART1_U1STA.setRIDLE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TUART1_U1STA.clearRIDLE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TUART1_U1STA.setRIDLE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TUART1_U1STA.getRIDLE : TBits_1; inline;
begin
  getRIDLE := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TUART1_U1STA.setADDEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TUART1_U1STA.clearADDEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TUART1_U1STA.setADDEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TUART1_U1STA.getADDEN : TBits_1; inline;
begin
  getADDEN := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TUART1_U1STA.setURXISEL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF3F or ( thebits shl 6 );
end;
function  TUART1_U1STA.getURXISEL : TBits_2; inline;
begin
  getURXISEL := (pTDefRegMap(@Self)^.val and $000000C0) shr 6;
end;
procedure TUART1_U1STA.setTRMT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TUART1_U1STA.clearTRMT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TUART1_U1STA.setTRMT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TUART1_U1STA.getTRMT : TBits_1; inline;
begin
  getTRMT := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TUART1_U1STA.setUTXBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TUART1_U1STA.clearUTXBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TUART1_U1STA.setUTXBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TUART1_U1STA.getUTXBF : TBits_1; inline;
begin
  getUTXBF := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TUART1_U1STA.setUTXEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TUART1_U1STA.clearUTXEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TUART1_U1STA.setUTXEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TUART1_U1STA.getUTXEN : TBits_1; inline;
begin
  getUTXEN := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TUART1_U1STA.setUTXBRK; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TUART1_U1STA.clearUTXBRK; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TUART1_U1STA.setUTXBRK(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TUART1_U1STA.getUTXBRK : TBits_1; inline;
begin
  getUTXBRK := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TUART1_U1STA.setURXEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TUART1_U1STA.clearURXEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TUART1_U1STA.setURXEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TUART1_U1STA.getURXEN : TBits_1; inline;
begin
  getURXEN := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TUART1_U1STA.setUTXINV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TUART1_U1STA.clearUTXINV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TUART1_U1STA.setUTXINV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TUART1_U1STA.getUTXINV : TBits_1; inline;
begin
  getUTXINV := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TUART1_U1STA.setUTXISEL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF3FFF or ( thebits shl 14 );
end;
function  TUART1_U1STA.getUTXISEL : TBits_2; inline;
begin
  getUTXISEL := (pTDefRegMap(@Self)^.val and $0000C000) shr 14;
end;
procedure TUART1_U1STA.setADDR(thebits : TBits_8); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FF00FFFF or ( thebits shl 16 );
end;
function  TUART1_U1STA.getADDR : TBits_8; inline;
begin
  getADDR := (pTDefRegMap(@Self)^.val and $00FF0000) shr 16;
end;
procedure TUART1_U1STA.setADM_EN; inline;
begin
  pTDefRegMap(@Self)^.&set := $01000000;
end;
procedure TUART1_U1STA.clearADM_EN; inline;
begin
  pTDefRegMap(@Self)^.clr := $01000000;
end;
procedure TUART1_U1STA.setADM_EN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $01000000
  else
    pTDefRegMap(@Self)^.&set := $01000000;
end;
function  TUART1_U1STA.getADM_EN : TBits_1; inline;
begin
  getADM_EN := (pTDefRegMap(@Self)^.val and $01000000) shr 24;
end;
procedure TUART1_U1STA.setURXISEL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TUART1_U1STA.clearURXISEL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TUART1_U1STA.setURXISEL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TUART1_U1STA.getURXISEL0 : TBits_1; inline;
begin
  getURXISEL0 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TUART1_U1STA.setURXISEL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TUART1_U1STA.clearURXISEL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TUART1_U1STA.setURXISEL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TUART1_U1STA.getURXISEL1 : TBits_1; inline;
begin
  getURXISEL1 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TUART1_U1STA.setUTXISEL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TUART1_U1STA.clearUTXISEL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TUART1_U1STA.setUTXISEL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TUART1_U1STA.getUTXISEL0 : TBits_1; inline;
begin
  getUTXISEL0 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TUART1_U1STA.setUTXISEL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TUART1_U1STA.clearUTXISEL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TUART1_U1STA.setUTXISEL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TUART1_U1STA.getUTXISEL1 : TBits_1; inline;
begin
  getUTXISEL1 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TUART1_U1STA.setUTXSEL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF3FFF or ( thebits shl 14 );
end;
function  TUART1_U1STA.getUTXSEL : TBits_2; inline;
begin
  getUTXSEL := (pTDefRegMap(@Self)^.val and $0000C000) shr 14;
end;
procedure TUART1_U1STA.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TUART1_U1STA.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TUART2_U2MODE.setSTSEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TUART2_U2MODE.clearSTSEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TUART2_U2MODE.setSTSEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TUART2_U2MODE.getSTSEL : TBits_1; inline;
begin
  getSTSEL := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TUART2_U2MODE.setPDSEL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF9 or ( thebits shl 1 );
end;
function  TUART2_U2MODE.getPDSEL : TBits_2; inline;
begin
  getPDSEL := (pTDefRegMap(@Self)^.val and $00000006) shr 1;
end;
procedure TUART2_U2MODE.setBRGH; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TUART2_U2MODE.clearBRGH; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TUART2_U2MODE.setBRGH(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TUART2_U2MODE.getBRGH : TBits_1; inline;
begin
  getBRGH := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TUART2_U2MODE.setRXINV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TUART2_U2MODE.clearRXINV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TUART2_U2MODE.setRXINV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TUART2_U2MODE.getRXINV : TBits_1; inline;
begin
  getRXINV := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TUART2_U2MODE.setABAUD; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TUART2_U2MODE.clearABAUD; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TUART2_U2MODE.setABAUD(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TUART2_U2MODE.getABAUD : TBits_1; inline;
begin
  getABAUD := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TUART2_U2MODE.setLPBACK; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TUART2_U2MODE.clearLPBACK; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TUART2_U2MODE.setLPBACK(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TUART2_U2MODE.getLPBACK : TBits_1; inline;
begin
  getLPBACK := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TUART2_U2MODE.setWAKE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TUART2_U2MODE.clearWAKE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TUART2_U2MODE.setWAKE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TUART2_U2MODE.getWAKE : TBits_1; inline;
begin
  getWAKE := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TUART2_U2MODE.setUEN(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFCFF or ( thebits shl 8 );
end;
function  TUART2_U2MODE.getUEN : TBits_2; inline;
begin
  getUEN := (pTDefRegMap(@Self)^.val and $00000300) shr 8;
end;
procedure TUART2_U2MODE.setRTSMD; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TUART2_U2MODE.clearRTSMD; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TUART2_U2MODE.setRTSMD(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TUART2_U2MODE.getRTSMD : TBits_1; inline;
begin
  getRTSMD := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TUART2_U2MODE.setIREN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TUART2_U2MODE.clearIREN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TUART2_U2MODE.setIREN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TUART2_U2MODE.getIREN : TBits_1; inline;
begin
  getIREN := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TUART2_U2MODE.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TUART2_U2MODE.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TUART2_U2MODE.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TUART2_U2MODE.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TUART2_U2MODE.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TUART2_U2MODE.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TUART2_U2MODE.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TUART2_U2MODE.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TUART2_U2MODE.setPDSEL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TUART2_U2MODE.clearPDSEL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TUART2_U2MODE.setPDSEL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TUART2_U2MODE.getPDSEL0 : TBits_1; inline;
begin
  getPDSEL0 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TUART2_U2MODE.setPDSEL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TUART2_U2MODE.clearPDSEL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TUART2_U2MODE.setPDSEL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TUART2_U2MODE.getPDSEL1 : TBits_1; inline;
begin
  getPDSEL1 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TUART2_U2MODE.setUEN0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TUART2_U2MODE.clearUEN0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TUART2_U2MODE.setUEN0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TUART2_U2MODE.getUEN0 : TBits_1; inline;
begin
  getUEN0 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TUART2_U2MODE.setUEN1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TUART2_U2MODE.clearUEN1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TUART2_U2MODE.setUEN1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TUART2_U2MODE.getUEN1 : TBits_1; inline;
begin
  getUEN1 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TUART2_U2MODE.setUSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TUART2_U2MODE.clearUSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TUART2_U2MODE.setUSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TUART2_U2MODE.getUSIDL : TBits_1; inline;
begin
  getUSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TUART2_U2MODE.setUARTEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TUART2_U2MODE.clearUARTEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TUART2_U2MODE.setUARTEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TUART2_U2MODE.getUARTEN : TBits_1; inline;
begin
  getUARTEN := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TUART2_U2MODE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TUART2_U2MODE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TUART2_U2STA.setURXDA; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TUART2_U2STA.clearURXDA; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TUART2_U2STA.setURXDA(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TUART2_U2STA.getURXDA : TBits_1; inline;
begin
  getURXDA := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TUART2_U2STA.setOERR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TUART2_U2STA.clearOERR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TUART2_U2STA.setOERR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TUART2_U2STA.getOERR : TBits_1; inline;
begin
  getOERR := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TUART2_U2STA.setFERR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TUART2_U2STA.clearFERR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TUART2_U2STA.setFERR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TUART2_U2STA.getFERR : TBits_1; inline;
begin
  getFERR := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TUART2_U2STA.setPERR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TUART2_U2STA.clearPERR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TUART2_U2STA.setPERR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TUART2_U2STA.getPERR : TBits_1; inline;
begin
  getPERR := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TUART2_U2STA.setRIDLE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TUART2_U2STA.clearRIDLE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TUART2_U2STA.setRIDLE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TUART2_U2STA.getRIDLE : TBits_1; inline;
begin
  getRIDLE := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TUART2_U2STA.setADDEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TUART2_U2STA.clearADDEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TUART2_U2STA.setADDEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TUART2_U2STA.getADDEN : TBits_1; inline;
begin
  getADDEN := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TUART2_U2STA.setURXISEL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF3F or ( thebits shl 6 );
end;
function  TUART2_U2STA.getURXISEL : TBits_2; inline;
begin
  getURXISEL := (pTDefRegMap(@Self)^.val and $000000C0) shr 6;
end;
procedure TUART2_U2STA.setTRMT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TUART2_U2STA.clearTRMT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TUART2_U2STA.setTRMT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TUART2_U2STA.getTRMT : TBits_1; inline;
begin
  getTRMT := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TUART2_U2STA.setUTXBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TUART2_U2STA.clearUTXBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TUART2_U2STA.setUTXBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TUART2_U2STA.getUTXBF : TBits_1; inline;
begin
  getUTXBF := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TUART2_U2STA.setUTXEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TUART2_U2STA.clearUTXEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TUART2_U2STA.setUTXEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TUART2_U2STA.getUTXEN : TBits_1; inline;
begin
  getUTXEN := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TUART2_U2STA.setUTXBRK; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TUART2_U2STA.clearUTXBRK; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TUART2_U2STA.setUTXBRK(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TUART2_U2STA.getUTXBRK : TBits_1; inline;
begin
  getUTXBRK := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TUART2_U2STA.setURXEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TUART2_U2STA.clearURXEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TUART2_U2STA.setURXEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TUART2_U2STA.getURXEN : TBits_1; inline;
begin
  getURXEN := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TUART2_U2STA.setUTXINV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TUART2_U2STA.clearUTXINV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TUART2_U2STA.setUTXINV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TUART2_U2STA.getUTXINV : TBits_1; inline;
begin
  getUTXINV := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TUART2_U2STA.setUTXISEL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF3FFF or ( thebits shl 14 );
end;
function  TUART2_U2STA.getUTXISEL : TBits_2; inline;
begin
  getUTXISEL := (pTDefRegMap(@Self)^.val and $0000C000) shr 14;
end;
procedure TUART2_U2STA.setADDR(thebits : TBits_8); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FF00FFFF or ( thebits shl 16 );
end;
function  TUART2_U2STA.getADDR : TBits_8; inline;
begin
  getADDR := (pTDefRegMap(@Self)^.val and $00FF0000) shr 16;
end;
procedure TUART2_U2STA.setADM_EN; inline;
begin
  pTDefRegMap(@Self)^.&set := $01000000;
end;
procedure TUART2_U2STA.clearADM_EN; inline;
begin
  pTDefRegMap(@Self)^.clr := $01000000;
end;
procedure TUART2_U2STA.setADM_EN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $01000000
  else
    pTDefRegMap(@Self)^.&set := $01000000;
end;
function  TUART2_U2STA.getADM_EN : TBits_1; inline;
begin
  getADM_EN := (pTDefRegMap(@Self)^.val and $01000000) shr 24;
end;
procedure TUART2_U2STA.setURXISEL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TUART2_U2STA.clearURXISEL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TUART2_U2STA.setURXISEL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TUART2_U2STA.getURXISEL0 : TBits_1; inline;
begin
  getURXISEL0 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TUART2_U2STA.setURXISEL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TUART2_U2STA.clearURXISEL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TUART2_U2STA.setURXISEL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TUART2_U2STA.getURXISEL1 : TBits_1; inline;
begin
  getURXISEL1 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TUART2_U2STA.setUTXISEL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TUART2_U2STA.clearUTXISEL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TUART2_U2STA.setUTXISEL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TUART2_U2STA.getUTXISEL0 : TBits_1; inline;
begin
  getUTXISEL0 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TUART2_U2STA.setUTXISEL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TUART2_U2STA.clearUTXISEL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TUART2_U2STA.setUTXISEL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TUART2_U2STA.getUTXISEL1 : TBits_1; inline;
begin
  getUTXISEL1 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TUART2_U2STA.setUTXSEL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF3FFF or ( thebits shl 14 );
end;
function  TUART2_U2STA.getUTXSEL : TBits_2; inline;
begin
  getUTXSEL := (pTDefRegMap(@Self)^.val and $0000C000) shr 14;
end;
procedure TUART2_U2STA.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TUART2_U2STA.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMCON.setRDSP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPMP_PMCON.clearRDSP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPMP_PMCON.setRDSP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPMP_PMCON.getRDSP : TBits_1; inline;
begin
  getRDSP := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPMP_PMCON.setWRSP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPMP_PMCON.clearWRSP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPMP_PMCON.setWRSP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPMP_PMCON.getWRSP : TBits_1; inline;
begin
  getWRSP := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPMP_PMCON.setCS1P; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPMP_PMCON.clearCS1P; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPMP_PMCON.setCS1P(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPMP_PMCON.getCS1P : TBits_1; inline;
begin
  getCS1P := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPMP_PMCON.setCS2P; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPMP_PMCON.clearCS2P; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPMP_PMCON.setCS2P(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPMP_PMCON.getCS2P : TBits_1; inline;
begin
  getCS2P := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPMP_PMCON.setALP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPMP_PMCON.clearALP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPMP_PMCON.setALP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPMP_PMCON.getALP : TBits_1; inline;
begin
  getALP := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPMP_PMCON.setCSF(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF3F or ( thebits shl 6 );
end;
function  TPMP_PMCON.getCSF : TBits_2; inline;
begin
  getCSF := (pTDefRegMap(@Self)^.val and $000000C0) shr 6;
end;
procedure TPMP_PMCON.setPTRDEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPMP_PMCON.clearPTRDEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPMP_PMCON.setPTRDEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPMP_PMCON.getPTRDEN : TBits_1; inline;
begin
  getPTRDEN := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPMP_PMCON.setPTWREN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPMP_PMCON.clearPTWREN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPMP_PMCON.setPTWREN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPMP_PMCON.getPTWREN : TBits_1; inline;
begin
  getPTWREN := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPMP_PMCON.setPMPTTL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPMP_PMCON.clearPMPTTL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPMP_PMCON.setPMPTTL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPMP_PMCON.getPMPTTL : TBits_1; inline;
begin
  getPMPTTL := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPMP_PMCON.setADRMUX(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFE7FF or ( thebits shl 11 );
end;
function  TPMP_PMCON.getADRMUX : TBits_2; inline;
begin
  getADRMUX := (pTDefRegMap(@Self)^.val and $00001800) shr 11;
end;
procedure TPMP_PMCON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPMP_PMCON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPMP_PMCON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPMP_PMCON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPMP_PMCON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPMP_PMCON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPMP_PMCON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPMP_PMCON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPMP_PMCON.setCSF0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPMP_PMCON.clearCSF0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPMP_PMCON.setCSF0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPMP_PMCON.getCSF0 : TBits_1; inline;
begin
  getCSF0 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPMP_PMCON.setCSF1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPMP_PMCON.clearCSF1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPMP_PMCON.setCSF1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPMP_PMCON.getCSF1 : TBits_1; inline;
begin
  getCSF1 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPMP_PMCON.setADRMUX0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPMP_PMCON.clearADRMUX0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPMP_PMCON.setADRMUX0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPMP_PMCON.getADRMUX0 : TBits_1; inline;
begin
  getADRMUX0 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPMP_PMCON.setADRMUX1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPMP_PMCON.clearADRMUX1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPMP_PMCON.setADRMUX1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPMP_PMCON.getADRMUX1 : TBits_1; inline;
begin
  getADRMUX1 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPMP_PMCON.setPSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPMP_PMCON.clearPSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPMP_PMCON.setPSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPMP_PMCON.getPSIDL : TBits_1; inline;
begin
  getPSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPMP_PMCON.setPMPEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPMP_PMCON.clearPMPEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPMP_PMCON.setPMPEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPMP_PMCON.getPMPEN : TBits_1; inline;
begin
  getPMPEN := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPMP_PMCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMMODE.setWAITE(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFFC or ( thebits shl 0 );
end;
function  TPMP_PMMODE.getWAITE : TBits_2; inline;
begin
  getWAITE := (pTDefRegMap(@Self)^.val and $00000003) shr 0;
end;
procedure TPMP_PMMODE.setWAITM(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFC3 or ( thebits shl 2 );
end;
function  TPMP_PMMODE.getWAITM : TBits_4; inline;
begin
  getWAITM := (pTDefRegMap(@Self)^.val and $0000003C) shr 2;
end;
procedure TPMP_PMMODE.setWAITB(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF3F or ( thebits shl 6 );
end;
function  TPMP_PMMODE.getWAITB : TBits_2; inline;
begin
  getWAITB := (pTDefRegMap(@Self)^.val and $000000C0) shr 6;
end;
procedure TPMP_PMMODE.setMODE(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFCFF or ( thebits shl 8 );
end;
function  TPMP_PMMODE.getMODE : TBits_2; inline;
begin
  getMODE := (pTDefRegMap(@Self)^.val and $00000300) shr 8;
end;
procedure TPMP_PMMODE.setMODE16; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPMP_PMMODE.clearMODE16; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPMP_PMMODE.setMODE16(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPMP_PMMODE.getMODE16 : TBits_1; inline;
begin
  getMODE16 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPMP_PMMODE.setINCM(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFE7FF or ( thebits shl 11 );
end;
function  TPMP_PMMODE.getINCM : TBits_2; inline;
begin
  getINCM := (pTDefRegMap(@Self)^.val and $00001800) shr 11;
end;
procedure TPMP_PMMODE.setIRQM(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF9FFF or ( thebits shl 13 );
end;
function  TPMP_PMMODE.getIRQM : TBits_2; inline;
begin
  getIRQM := (pTDefRegMap(@Self)^.val and $00006000) shr 13;
end;
procedure TPMP_PMMODE.setBUSY; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPMP_PMMODE.clearBUSY; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPMP_PMMODE.setBUSY(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPMP_PMMODE.getBUSY : TBits_1; inline;
begin
  getBUSY := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPMP_PMMODE.setWAITE0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPMP_PMMODE.clearWAITE0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPMP_PMMODE.setWAITE0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPMP_PMMODE.getWAITE0 : TBits_1; inline;
begin
  getWAITE0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPMP_PMMODE.setWAITE1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPMP_PMMODE.clearWAITE1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPMP_PMMODE.setWAITE1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPMP_PMMODE.getWAITE1 : TBits_1; inline;
begin
  getWAITE1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPMP_PMMODE.setWAITM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPMP_PMMODE.clearWAITM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPMP_PMMODE.setWAITM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPMP_PMMODE.getWAITM0 : TBits_1; inline;
begin
  getWAITM0 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPMP_PMMODE.setWAITM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPMP_PMMODE.clearWAITM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPMP_PMMODE.setWAITM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPMP_PMMODE.getWAITM1 : TBits_1; inline;
begin
  getWAITM1 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPMP_PMMODE.setWAITM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPMP_PMMODE.clearWAITM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPMP_PMMODE.setWAITM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPMP_PMMODE.getWAITM2 : TBits_1; inline;
begin
  getWAITM2 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPMP_PMMODE.setWAITM3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPMP_PMMODE.clearWAITM3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPMP_PMMODE.setWAITM3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPMP_PMMODE.getWAITM3 : TBits_1; inline;
begin
  getWAITM3 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPMP_PMMODE.setWAITB0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPMP_PMMODE.clearWAITB0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPMP_PMMODE.setWAITB0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPMP_PMMODE.getWAITB0 : TBits_1; inline;
begin
  getWAITB0 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPMP_PMMODE.setWAITB1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPMP_PMMODE.clearWAITB1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPMP_PMMODE.setWAITB1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPMP_PMMODE.getWAITB1 : TBits_1; inline;
begin
  getWAITB1 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPMP_PMMODE.setMODE0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPMP_PMMODE.clearMODE0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPMP_PMMODE.setMODE0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPMP_PMMODE.getMODE0 : TBits_1; inline;
begin
  getMODE0 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPMP_PMMODE.setMODE1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPMP_PMMODE.clearMODE1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPMP_PMMODE.setMODE1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPMP_PMMODE.getMODE1 : TBits_1; inline;
begin
  getMODE1 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPMP_PMMODE.setINCM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPMP_PMMODE.clearINCM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPMP_PMMODE.setINCM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPMP_PMMODE.getINCM0 : TBits_1; inline;
begin
  getINCM0 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPMP_PMMODE.setINCM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPMP_PMMODE.clearINCM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPMP_PMMODE.setINCM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPMP_PMMODE.getINCM1 : TBits_1; inline;
begin
  getINCM1 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPMP_PMMODE.setIRQM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPMP_PMMODE.clearIRQM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPMP_PMMODE.setIRQM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPMP_PMMODE.getIRQM0 : TBits_1; inline;
begin
  getIRQM0 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPMP_PMMODE.setIRQM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPMP_PMMODE.clearIRQM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPMP_PMMODE.setIRQM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPMP_PMMODE.getIRQM1 : TBits_1; inline;
begin
  getIRQM1 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPMP_PMMODE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMMODE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMADDR.setADDR(thebits : TBits_14); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFC000 or ( thebits shl 0 );
end;
function  TPMP_PMADDR.getADDR : TBits_14; inline;
begin
  getADDR := (pTDefRegMap(@Self)^.val and $00003FFF) shr 0;
end;
procedure TPMP_PMADDR.setCS(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF3FFF or ( thebits shl 14 );
end;
function  TPMP_PMADDR.getCS : TBits_2; inline;
begin
  getCS := (pTDefRegMap(@Self)^.val and $0000C000) shr 14;
end;
procedure TPMP_PMADDR.setPADDR(thebits : TBits_14); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFC000 or ( thebits shl 0 );
end;
function  TPMP_PMADDR.getPADDR : TBits_14; inline;
begin
  getPADDR := (pTDefRegMap(@Self)^.val and $00003FFF) shr 0;
end;
procedure TPMP_PMADDR.setCS1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPMP_PMADDR.clearCS1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPMP_PMADDR.setCS1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPMP_PMADDR.getCS1 : TBits_1; inline;
begin
  getCS1 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPMP_PMADDR.setCS2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPMP_PMADDR.clearCS2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPMP_PMADDR.setCS2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPMP_PMADDR.getCS2 : TBits_1; inline;
begin
  getCS2 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPMP_PMADDR.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMADDR.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMDOUT.setDATAOUT(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMDOUT.getDATAOUT : TBits_32; inline;
begin
  getDATAOUT := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMDOUT.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMDOUT.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMDIN.setDATAIN(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMDIN.getDATAIN : TBits_32; inline;
begin
  getDATAIN := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMDIN.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMDIN.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMAEN.setPTEN(thebits : TBits_16); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF0000 or ( thebits shl 0 );
end;
function  TPMP_PMAEN.getPTEN : TBits_16; inline;
begin
  getPTEN := (pTDefRegMap(@Self)^.val and $0000FFFF) shr 0;
end;
procedure TPMP_PMAEN.setPTEN0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPMP_PMAEN.clearPTEN0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPMP_PMAEN.setPTEN0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPMP_PMAEN.getPTEN0 : TBits_1; inline;
begin
  getPTEN0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPMP_PMAEN.setPTEN1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPMP_PMAEN.clearPTEN1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPMP_PMAEN.setPTEN1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPMP_PMAEN.getPTEN1 : TBits_1; inline;
begin
  getPTEN1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPMP_PMAEN.setPTEN2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPMP_PMAEN.clearPTEN2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPMP_PMAEN.setPTEN2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPMP_PMAEN.getPTEN2 : TBits_1; inline;
begin
  getPTEN2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPMP_PMAEN.setPTEN3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPMP_PMAEN.clearPTEN3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPMP_PMAEN.setPTEN3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPMP_PMAEN.getPTEN3 : TBits_1; inline;
begin
  getPTEN3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPMP_PMAEN.setPTEN4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPMP_PMAEN.clearPTEN4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPMP_PMAEN.setPTEN4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPMP_PMAEN.getPTEN4 : TBits_1; inline;
begin
  getPTEN4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPMP_PMAEN.setPTEN5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPMP_PMAEN.clearPTEN5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPMP_PMAEN.setPTEN5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPMP_PMAEN.getPTEN5 : TBits_1; inline;
begin
  getPTEN5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPMP_PMAEN.setPTEN6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPMP_PMAEN.clearPTEN6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPMP_PMAEN.setPTEN6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPMP_PMAEN.getPTEN6 : TBits_1; inline;
begin
  getPTEN6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPMP_PMAEN.setPTEN7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPMP_PMAEN.clearPTEN7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPMP_PMAEN.setPTEN7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPMP_PMAEN.getPTEN7 : TBits_1; inline;
begin
  getPTEN7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPMP_PMAEN.setPTEN8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPMP_PMAEN.clearPTEN8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPMP_PMAEN.setPTEN8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPMP_PMAEN.getPTEN8 : TBits_1; inline;
begin
  getPTEN8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPMP_PMAEN.setPTEN9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPMP_PMAEN.clearPTEN9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPMP_PMAEN.setPTEN9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPMP_PMAEN.getPTEN9 : TBits_1; inline;
begin
  getPTEN9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPMP_PMAEN.setPTEN10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPMP_PMAEN.clearPTEN10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPMP_PMAEN.setPTEN10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPMP_PMAEN.getPTEN10 : TBits_1; inline;
begin
  getPTEN10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPMP_PMAEN.setPTEN11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPMP_PMAEN.clearPTEN11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPMP_PMAEN.setPTEN11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPMP_PMAEN.getPTEN11 : TBits_1; inline;
begin
  getPTEN11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPMP_PMAEN.setPTEN12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPMP_PMAEN.clearPTEN12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPMP_PMAEN.setPTEN12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPMP_PMAEN.getPTEN12 : TBits_1; inline;
begin
  getPTEN12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPMP_PMAEN.setPTEN13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPMP_PMAEN.clearPTEN13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPMP_PMAEN.setPTEN13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPMP_PMAEN.getPTEN13 : TBits_1; inline;
begin
  getPTEN13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPMP_PMAEN.setPTEN14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPMP_PMAEN.clearPTEN14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPMP_PMAEN.setPTEN14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPMP_PMAEN.getPTEN14 : TBits_1; inline;
begin
  getPTEN14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPMP_PMAEN.setPTEN15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPMP_PMAEN.clearPTEN15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPMP_PMAEN.setPTEN15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPMP_PMAEN.getPTEN15 : TBits_1; inline;
begin
  getPTEN15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPMP_PMAEN.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMAEN.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPMP_PMSTAT.setOB0E; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPMP_PMSTAT.clearOB0E; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPMP_PMSTAT.setOB0E(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPMP_PMSTAT.getOB0E : TBits_1; inline;
begin
  getOB0E := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPMP_PMSTAT.setOB1E; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPMP_PMSTAT.clearOB1E; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPMP_PMSTAT.setOB1E(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPMP_PMSTAT.getOB1E : TBits_1; inline;
begin
  getOB1E := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPMP_PMSTAT.setOB2E; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPMP_PMSTAT.clearOB2E; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPMP_PMSTAT.setOB2E(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPMP_PMSTAT.getOB2E : TBits_1; inline;
begin
  getOB2E := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPMP_PMSTAT.setOB3E; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPMP_PMSTAT.clearOB3E; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPMP_PMSTAT.setOB3E(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPMP_PMSTAT.getOB3E : TBits_1; inline;
begin
  getOB3E := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPMP_PMSTAT.setOBUF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPMP_PMSTAT.clearOBUF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPMP_PMSTAT.setOBUF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPMP_PMSTAT.getOBUF : TBits_1; inline;
begin
  getOBUF := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPMP_PMSTAT.setOBE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPMP_PMSTAT.clearOBE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPMP_PMSTAT.setOBE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPMP_PMSTAT.getOBE : TBits_1; inline;
begin
  getOBE := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPMP_PMSTAT.setIB0F; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPMP_PMSTAT.clearIB0F; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPMP_PMSTAT.setIB0F(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPMP_PMSTAT.getIB0F : TBits_1; inline;
begin
  getIB0F := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPMP_PMSTAT.setIB1F; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPMP_PMSTAT.clearIB1F; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPMP_PMSTAT.setIB1F(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPMP_PMSTAT.getIB1F : TBits_1; inline;
begin
  getIB1F := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPMP_PMSTAT.setIB2F; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPMP_PMSTAT.clearIB2F; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPMP_PMSTAT.setIB2F(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPMP_PMSTAT.getIB2F : TBits_1; inline;
begin
  getIB2F := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPMP_PMSTAT.setIB3F; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPMP_PMSTAT.clearIB3F; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPMP_PMSTAT.setIB3F(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPMP_PMSTAT.getIB3F : TBits_1; inline;
begin
  getIB3F := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPMP_PMSTAT.setIBOV; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPMP_PMSTAT.clearIBOV; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPMP_PMSTAT.setIBOV(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPMP_PMSTAT.getIBOV : TBits_1; inline;
begin
  getIBOV := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPMP_PMSTAT.setIBF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPMP_PMSTAT.clearIBF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPMP_PMSTAT.setIBF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPMP_PMSTAT.getIBF : TBits_1; inline;
begin
  getIBF := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPMP_PMSTAT.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPMP_PMSTAT.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TADC10_AD1CON1.setDONE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TADC10_AD1CON1.clearDONE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TADC10_AD1CON1.setDONE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TADC10_AD1CON1.getDONE : TBits_1; inline;
begin
  getDONE := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TADC10_AD1CON1.setSAMP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TADC10_AD1CON1.clearSAMP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TADC10_AD1CON1.setSAMP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TADC10_AD1CON1.getSAMP : TBits_1; inline;
begin
  getSAMP := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TADC10_AD1CON1.setASAM; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TADC10_AD1CON1.clearASAM; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TADC10_AD1CON1.setASAM(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TADC10_AD1CON1.getASAM : TBits_1; inline;
begin
  getASAM := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TADC10_AD1CON1.setCLRASAM; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TADC10_AD1CON1.clearCLRASAM; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TADC10_AD1CON1.setCLRASAM(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TADC10_AD1CON1.getCLRASAM : TBits_1; inline;
begin
  getCLRASAM := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TADC10_AD1CON1.setSSRC(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF1F or ( thebits shl 5 );
end;
function  TADC10_AD1CON1.getSSRC : TBits_3; inline;
begin
  getSSRC := (pTDefRegMap(@Self)^.val and $000000E0) shr 5;
end;
procedure TADC10_AD1CON1.setFORM(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF8FF or ( thebits shl 8 );
end;
function  TADC10_AD1CON1.getFORM : TBits_3; inline;
begin
  getFORM := (pTDefRegMap(@Self)^.val and $00000700) shr 8;
end;
procedure TADC10_AD1CON1.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TADC10_AD1CON1.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TADC10_AD1CON1.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TADC10_AD1CON1.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TADC10_AD1CON1.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TADC10_AD1CON1.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TADC10_AD1CON1.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TADC10_AD1CON1.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TADC10_AD1CON1.setSSRC0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TADC10_AD1CON1.clearSSRC0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TADC10_AD1CON1.setSSRC0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TADC10_AD1CON1.getSSRC0 : TBits_1; inline;
begin
  getSSRC0 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TADC10_AD1CON1.setSSRC1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TADC10_AD1CON1.clearSSRC1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TADC10_AD1CON1.setSSRC1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TADC10_AD1CON1.getSSRC1 : TBits_1; inline;
begin
  getSSRC1 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TADC10_AD1CON1.setSSRC2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TADC10_AD1CON1.clearSSRC2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TADC10_AD1CON1.setSSRC2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TADC10_AD1CON1.getSSRC2 : TBits_1; inline;
begin
  getSSRC2 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TADC10_AD1CON1.setFORM0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TADC10_AD1CON1.clearFORM0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TADC10_AD1CON1.setFORM0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TADC10_AD1CON1.getFORM0 : TBits_1; inline;
begin
  getFORM0 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TADC10_AD1CON1.setFORM1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TADC10_AD1CON1.clearFORM1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TADC10_AD1CON1.setFORM1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TADC10_AD1CON1.getFORM1 : TBits_1; inline;
begin
  getFORM1 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TADC10_AD1CON1.setFORM2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TADC10_AD1CON1.clearFORM2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TADC10_AD1CON1.setFORM2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TADC10_AD1CON1.getFORM2 : TBits_1; inline;
begin
  getFORM2 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TADC10_AD1CON1.setADSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TADC10_AD1CON1.clearADSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TADC10_AD1CON1.setADSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TADC10_AD1CON1.getADSIDL : TBits_1; inline;
begin
  getADSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TADC10_AD1CON1.setADON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TADC10_AD1CON1.clearADON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TADC10_AD1CON1.setADON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TADC10_AD1CON1.getADON : TBits_1; inline;
begin
  getADON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TADC10_AD1CON1.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TADC10_AD1CON1.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TADC10_AD1CON2.setALTS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TADC10_AD1CON2.clearALTS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TADC10_AD1CON2.setALTS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TADC10_AD1CON2.getALTS : TBits_1; inline;
begin
  getALTS := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TADC10_AD1CON2.setBUFM; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TADC10_AD1CON2.clearBUFM; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TADC10_AD1CON2.setBUFM(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TADC10_AD1CON2.getBUFM : TBits_1; inline;
begin
  getBUFM := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TADC10_AD1CON2.setSMPI(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFC3 or ( thebits shl 2 );
end;
function  TADC10_AD1CON2.getSMPI : TBits_4; inline;
begin
  getSMPI := (pTDefRegMap(@Self)^.val and $0000003C) shr 2;
end;
procedure TADC10_AD1CON2.setBUFS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TADC10_AD1CON2.clearBUFS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TADC10_AD1CON2.setBUFS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TADC10_AD1CON2.getBUFS : TBits_1; inline;
begin
  getBUFS := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TADC10_AD1CON2.setCSCNA; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TADC10_AD1CON2.clearCSCNA; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TADC10_AD1CON2.setCSCNA(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TADC10_AD1CON2.getCSCNA : TBits_1; inline;
begin
  getCSCNA := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TADC10_AD1CON2.setOFFCAL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TADC10_AD1CON2.clearOFFCAL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TADC10_AD1CON2.setOFFCAL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TADC10_AD1CON2.getOFFCAL : TBits_1; inline;
begin
  getOFFCAL := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TADC10_AD1CON2.setVCFG(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF1FFF or ( thebits shl 13 );
end;
function  TADC10_AD1CON2.getVCFG : TBits_3; inline;
begin
  getVCFG := (pTDefRegMap(@Self)^.val and $0000E000) shr 13;
end;
procedure TADC10_AD1CON2.setSMPI0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TADC10_AD1CON2.clearSMPI0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TADC10_AD1CON2.setSMPI0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TADC10_AD1CON2.getSMPI0 : TBits_1; inline;
begin
  getSMPI0 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TADC10_AD1CON2.setSMPI1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TADC10_AD1CON2.clearSMPI1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TADC10_AD1CON2.setSMPI1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TADC10_AD1CON2.getSMPI1 : TBits_1; inline;
begin
  getSMPI1 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TADC10_AD1CON2.setSMPI2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TADC10_AD1CON2.clearSMPI2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TADC10_AD1CON2.setSMPI2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TADC10_AD1CON2.getSMPI2 : TBits_1; inline;
begin
  getSMPI2 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TADC10_AD1CON2.setSMPI3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TADC10_AD1CON2.clearSMPI3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TADC10_AD1CON2.setSMPI3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TADC10_AD1CON2.getSMPI3 : TBits_1; inline;
begin
  getSMPI3 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TADC10_AD1CON2.setVCFG0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TADC10_AD1CON2.clearVCFG0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TADC10_AD1CON2.setVCFG0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TADC10_AD1CON2.getVCFG0 : TBits_1; inline;
begin
  getVCFG0 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TADC10_AD1CON2.setVCFG1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TADC10_AD1CON2.clearVCFG1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TADC10_AD1CON2.setVCFG1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TADC10_AD1CON2.getVCFG1 : TBits_1; inline;
begin
  getVCFG1 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TADC10_AD1CON2.setVCFG2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TADC10_AD1CON2.clearVCFG2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TADC10_AD1CON2.setVCFG2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TADC10_AD1CON2.getVCFG2 : TBits_1; inline;
begin
  getVCFG2 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TADC10_AD1CON2.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TADC10_AD1CON2.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TADC10_AD1CON3.setADCS(thebits : TBits_8); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF00 or ( thebits shl 0 );
end;
function  TADC10_AD1CON3.getADCS : TBits_8; inline;
begin
  getADCS := (pTDefRegMap(@Self)^.val and $000000FF) shr 0;
end;
procedure TADC10_AD1CON3.setSAMC(thebits : TBits_5); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFE0FF or ( thebits shl 8 );
end;
function  TADC10_AD1CON3.getSAMC : TBits_5; inline;
begin
  getSAMC := (pTDefRegMap(@Self)^.val and $00001F00) shr 8;
end;
procedure TADC10_AD1CON3.setADRC; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TADC10_AD1CON3.clearADRC; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TADC10_AD1CON3.setADRC(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TADC10_AD1CON3.getADRC : TBits_1; inline;
begin
  getADRC := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TADC10_AD1CON3.setADCS0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TADC10_AD1CON3.clearADCS0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TADC10_AD1CON3.setADCS0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TADC10_AD1CON3.getADCS0 : TBits_1; inline;
begin
  getADCS0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TADC10_AD1CON3.setADCS1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TADC10_AD1CON3.clearADCS1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TADC10_AD1CON3.setADCS1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TADC10_AD1CON3.getADCS1 : TBits_1; inline;
begin
  getADCS1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TADC10_AD1CON3.setADCS2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TADC10_AD1CON3.clearADCS2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TADC10_AD1CON3.setADCS2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TADC10_AD1CON3.getADCS2 : TBits_1; inline;
begin
  getADCS2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TADC10_AD1CON3.setADCS3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TADC10_AD1CON3.clearADCS3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TADC10_AD1CON3.setADCS3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TADC10_AD1CON3.getADCS3 : TBits_1; inline;
begin
  getADCS3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TADC10_AD1CON3.setADCS4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TADC10_AD1CON3.clearADCS4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TADC10_AD1CON3.setADCS4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TADC10_AD1CON3.getADCS4 : TBits_1; inline;
begin
  getADCS4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TADC10_AD1CON3.setADCS5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TADC10_AD1CON3.clearADCS5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TADC10_AD1CON3.setADCS5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TADC10_AD1CON3.getADCS5 : TBits_1; inline;
begin
  getADCS5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TADC10_AD1CON3.setADCS6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TADC10_AD1CON3.clearADCS6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TADC10_AD1CON3.setADCS6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TADC10_AD1CON3.getADCS6 : TBits_1; inline;
begin
  getADCS6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TADC10_AD1CON3.setADCS7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TADC10_AD1CON3.clearADCS7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TADC10_AD1CON3.setADCS7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TADC10_AD1CON3.getADCS7 : TBits_1; inline;
begin
  getADCS7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TADC10_AD1CON3.setSAMC0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TADC10_AD1CON3.clearSAMC0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TADC10_AD1CON3.setSAMC0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TADC10_AD1CON3.getSAMC0 : TBits_1; inline;
begin
  getSAMC0 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TADC10_AD1CON3.setSAMC1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TADC10_AD1CON3.clearSAMC1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TADC10_AD1CON3.setSAMC1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TADC10_AD1CON3.getSAMC1 : TBits_1; inline;
begin
  getSAMC1 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TADC10_AD1CON3.setSAMC2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TADC10_AD1CON3.clearSAMC2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TADC10_AD1CON3.setSAMC2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TADC10_AD1CON3.getSAMC2 : TBits_1; inline;
begin
  getSAMC2 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TADC10_AD1CON3.setSAMC3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TADC10_AD1CON3.clearSAMC3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TADC10_AD1CON3.setSAMC3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TADC10_AD1CON3.getSAMC3 : TBits_1; inline;
begin
  getSAMC3 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TADC10_AD1CON3.setSAMC4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TADC10_AD1CON3.clearSAMC4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TADC10_AD1CON3.setSAMC4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TADC10_AD1CON3.getSAMC4 : TBits_1; inline;
begin
  getSAMC4 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TADC10_AD1CON3.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TADC10_AD1CON3.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TADC10_AD1CHS.setCH0SA(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFF0FFFF or ( thebits shl 16 );
end;
function  TADC10_AD1CHS.getCH0SA : TBits_4; inline;
begin
  getCH0SA := (pTDefRegMap(@Self)^.val and $000F0000) shr 16;
end;
procedure TADC10_AD1CHS.setCH0NA; inline;
begin
  pTDefRegMap(@Self)^.&set := $00800000;
end;
procedure TADC10_AD1CHS.clearCH0NA; inline;
begin
  pTDefRegMap(@Self)^.clr := $00800000;
end;
procedure TADC10_AD1CHS.setCH0NA(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00800000
  else
    pTDefRegMap(@Self)^.&set := $00800000;
end;
function  TADC10_AD1CHS.getCH0NA : TBits_1; inline;
begin
  getCH0NA := (pTDefRegMap(@Self)^.val and $00800000) shr 23;
end;
procedure TADC10_AD1CHS.setCH0SB(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $F0FFFFFF or ( thebits shl 24 );
end;
function  TADC10_AD1CHS.getCH0SB : TBits_4; inline;
begin
  getCH0SB := (pTDefRegMap(@Self)^.val and $0F000000) shr 24;
end;
procedure TADC10_AD1CHS.setCH0NB; inline;
begin
  pTDefRegMap(@Self)^.&set := $80000000;
end;
procedure TADC10_AD1CHS.clearCH0NB; inline;
begin
  pTDefRegMap(@Self)^.clr := $80000000;
end;
procedure TADC10_AD1CHS.setCH0NB(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $80000000
  else
    pTDefRegMap(@Self)^.&set := $80000000;
end;
function  TADC10_AD1CHS.getCH0NB : TBits_1; inline;
begin
  getCH0NB := (pTDefRegMap(@Self)^.val and $80000000) shr 31;
end;
procedure TADC10_AD1CHS.setCH0SA0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00010000;
end;
procedure TADC10_AD1CHS.clearCH0SA0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00010000;
end;
procedure TADC10_AD1CHS.setCH0SA0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00010000
  else
    pTDefRegMap(@Self)^.&set := $00010000;
end;
function  TADC10_AD1CHS.getCH0SA0 : TBits_1; inline;
begin
  getCH0SA0 := (pTDefRegMap(@Self)^.val and $00010000) shr 16;
end;
procedure TADC10_AD1CHS.setCH0SA1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00020000;
end;
procedure TADC10_AD1CHS.clearCH0SA1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00020000;
end;
procedure TADC10_AD1CHS.setCH0SA1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00020000
  else
    pTDefRegMap(@Self)^.&set := $00020000;
end;
function  TADC10_AD1CHS.getCH0SA1 : TBits_1; inline;
begin
  getCH0SA1 := (pTDefRegMap(@Self)^.val and $00020000) shr 17;
end;
procedure TADC10_AD1CHS.setCH0SA2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00040000;
end;
procedure TADC10_AD1CHS.clearCH0SA2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00040000;
end;
procedure TADC10_AD1CHS.setCH0SA2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00040000
  else
    pTDefRegMap(@Self)^.&set := $00040000;
end;
function  TADC10_AD1CHS.getCH0SA2 : TBits_1; inline;
begin
  getCH0SA2 := (pTDefRegMap(@Self)^.val and $00040000) shr 18;
end;
procedure TADC10_AD1CHS.setCH0SA3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00080000;
end;
procedure TADC10_AD1CHS.clearCH0SA3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00080000;
end;
procedure TADC10_AD1CHS.setCH0SA3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00080000
  else
    pTDefRegMap(@Self)^.&set := $00080000;
end;
function  TADC10_AD1CHS.getCH0SA3 : TBits_1; inline;
begin
  getCH0SA3 := (pTDefRegMap(@Self)^.val and $00080000) shr 19;
end;
procedure TADC10_AD1CHS.setCH0SB0; inline;
begin
  pTDefRegMap(@Self)^.&set := $01000000;
end;
procedure TADC10_AD1CHS.clearCH0SB0; inline;
begin
  pTDefRegMap(@Self)^.clr := $01000000;
end;
procedure TADC10_AD1CHS.setCH0SB0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $01000000
  else
    pTDefRegMap(@Self)^.&set := $01000000;
end;
function  TADC10_AD1CHS.getCH0SB0 : TBits_1; inline;
begin
  getCH0SB0 := (pTDefRegMap(@Self)^.val and $01000000) shr 24;
end;
procedure TADC10_AD1CHS.setCH0SB1; inline;
begin
  pTDefRegMap(@Self)^.&set := $02000000;
end;
procedure TADC10_AD1CHS.clearCH0SB1; inline;
begin
  pTDefRegMap(@Self)^.clr := $02000000;
end;
procedure TADC10_AD1CHS.setCH0SB1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $02000000
  else
    pTDefRegMap(@Self)^.&set := $02000000;
end;
function  TADC10_AD1CHS.getCH0SB1 : TBits_1; inline;
begin
  getCH0SB1 := (pTDefRegMap(@Self)^.val and $02000000) shr 25;
end;
procedure TADC10_AD1CHS.setCH0SB2; inline;
begin
  pTDefRegMap(@Self)^.&set := $04000000;
end;
procedure TADC10_AD1CHS.clearCH0SB2; inline;
begin
  pTDefRegMap(@Self)^.clr := $04000000;
end;
procedure TADC10_AD1CHS.setCH0SB2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $04000000
  else
    pTDefRegMap(@Self)^.&set := $04000000;
end;
function  TADC10_AD1CHS.getCH0SB2 : TBits_1; inline;
begin
  getCH0SB2 := (pTDefRegMap(@Self)^.val and $04000000) shr 26;
end;
procedure TADC10_AD1CHS.setCH0SB3; inline;
begin
  pTDefRegMap(@Self)^.&set := $08000000;
end;
procedure TADC10_AD1CHS.clearCH0SB3; inline;
begin
  pTDefRegMap(@Self)^.clr := $08000000;
end;
procedure TADC10_AD1CHS.setCH0SB3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $08000000
  else
    pTDefRegMap(@Self)^.&set := $08000000;
end;
function  TADC10_AD1CHS.getCH0SB3 : TBits_1; inline;
begin
  getCH0SB3 := (pTDefRegMap(@Self)^.val and $08000000) shr 27;
end;
procedure TADC10_AD1CHS.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TADC10_AD1CHS.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TADC10_AD1CSSL.setCSSL(thebits : TBits_16); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF0000 or ( thebits shl 0 );
end;
function  TADC10_AD1CSSL.getCSSL : TBits_16; inline;
begin
  getCSSL := (pTDefRegMap(@Self)^.val and $0000FFFF) shr 0;
end;
procedure TADC10_AD1CSSL.setCSSL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TADC10_AD1CSSL.clearCSSL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TADC10_AD1CSSL.setCSSL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TADC10_AD1CSSL.getCSSL0 : TBits_1; inline;
begin
  getCSSL0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TADC10_AD1CSSL.setCSSL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TADC10_AD1CSSL.clearCSSL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TADC10_AD1CSSL.setCSSL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TADC10_AD1CSSL.getCSSL1 : TBits_1; inline;
begin
  getCSSL1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TADC10_AD1CSSL.setCSSL2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TADC10_AD1CSSL.clearCSSL2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TADC10_AD1CSSL.setCSSL2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TADC10_AD1CSSL.getCSSL2 : TBits_1; inline;
begin
  getCSSL2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TADC10_AD1CSSL.setCSSL3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TADC10_AD1CSSL.clearCSSL3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TADC10_AD1CSSL.setCSSL3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TADC10_AD1CSSL.getCSSL3 : TBits_1; inline;
begin
  getCSSL3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TADC10_AD1CSSL.setCSSL4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TADC10_AD1CSSL.clearCSSL4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TADC10_AD1CSSL.setCSSL4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TADC10_AD1CSSL.getCSSL4 : TBits_1; inline;
begin
  getCSSL4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TADC10_AD1CSSL.setCSSL5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TADC10_AD1CSSL.clearCSSL5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TADC10_AD1CSSL.setCSSL5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TADC10_AD1CSSL.getCSSL5 : TBits_1; inline;
begin
  getCSSL5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TADC10_AD1CSSL.setCSSL6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TADC10_AD1CSSL.clearCSSL6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TADC10_AD1CSSL.setCSSL6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TADC10_AD1CSSL.getCSSL6 : TBits_1; inline;
begin
  getCSSL6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TADC10_AD1CSSL.setCSSL7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TADC10_AD1CSSL.clearCSSL7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TADC10_AD1CSSL.setCSSL7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TADC10_AD1CSSL.getCSSL7 : TBits_1; inline;
begin
  getCSSL7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TADC10_AD1CSSL.setCSSL8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TADC10_AD1CSSL.clearCSSL8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TADC10_AD1CSSL.setCSSL8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TADC10_AD1CSSL.getCSSL8 : TBits_1; inline;
begin
  getCSSL8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TADC10_AD1CSSL.setCSSL9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TADC10_AD1CSSL.clearCSSL9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TADC10_AD1CSSL.setCSSL9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TADC10_AD1CSSL.getCSSL9 : TBits_1; inline;
begin
  getCSSL9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TADC10_AD1CSSL.setCSSL10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TADC10_AD1CSSL.clearCSSL10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TADC10_AD1CSSL.setCSSL10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TADC10_AD1CSSL.getCSSL10 : TBits_1; inline;
begin
  getCSSL10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TADC10_AD1CSSL.setCSSL11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TADC10_AD1CSSL.clearCSSL11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TADC10_AD1CSSL.setCSSL11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TADC10_AD1CSSL.getCSSL11 : TBits_1; inline;
begin
  getCSSL11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TADC10_AD1CSSL.setCSSL12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TADC10_AD1CSSL.clearCSSL12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TADC10_AD1CSSL.setCSSL12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TADC10_AD1CSSL.getCSSL12 : TBits_1; inline;
begin
  getCSSL12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TADC10_AD1CSSL.setCSSL13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TADC10_AD1CSSL.clearCSSL13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TADC10_AD1CSSL.setCSSL13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TADC10_AD1CSSL.getCSSL13 : TBits_1; inline;
begin
  getCSSL13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TADC10_AD1CSSL.setCSSL14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TADC10_AD1CSSL.clearCSSL14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TADC10_AD1CSSL.setCSSL14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TADC10_AD1CSSL.getCSSL14 : TBits_1; inline;
begin
  getCSSL14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TADC10_AD1CSSL.setCSSL15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TADC10_AD1CSSL.clearCSSL15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TADC10_AD1CSSL.setCSSL15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TADC10_AD1CSSL.getCSSL15 : TBits_1; inline;
begin
  getCSSL15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TADC10_AD1CSSL.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TADC10_AD1CSSL.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TADC10_AD1PCFG.setPCFG(thebits : TBits_16); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF0000 or ( thebits shl 0 );
end;
function  TADC10_AD1PCFG.getPCFG : TBits_16; inline;
begin
  getPCFG := (pTDefRegMap(@Self)^.val and $0000FFFF) shr 0;
end;
procedure TADC10_AD1PCFG.setPCFG0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TADC10_AD1PCFG.clearPCFG0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TADC10_AD1PCFG.setPCFG0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TADC10_AD1PCFG.getPCFG0 : TBits_1; inline;
begin
  getPCFG0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TADC10_AD1PCFG.setPCFG1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TADC10_AD1PCFG.clearPCFG1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TADC10_AD1PCFG.setPCFG1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TADC10_AD1PCFG.getPCFG1 : TBits_1; inline;
begin
  getPCFG1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TADC10_AD1PCFG.setPCFG2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TADC10_AD1PCFG.clearPCFG2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TADC10_AD1PCFG.setPCFG2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TADC10_AD1PCFG.getPCFG2 : TBits_1; inline;
begin
  getPCFG2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TADC10_AD1PCFG.setPCFG3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TADC10_AD1PCFG.clearPCFG3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TADC10_AD1PCFG.setPCFG3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TADC10_AD1PCFG.getPCFG3 : TBits_1; inline;
begin
  getPCFG3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TADC10_AD1PCFG.setPCFG4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TADC10_AD1PCFG.clearPCFG4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TADC10_AD1PCFG.setPCFG4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TADC10_AD1PCFG.getPCFG4 : TBits_1; inline;
begin
  getPCFG4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TADC10_AD1PCFG.setPCFG5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TADC10_AD1PCFG.clearPCFG5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TADC10_AD1PCFG.setPCFG5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TADC10_AD1PCFG.getPCFG5 : TBits_1; inline;
begin
  getPCFG5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TADC10_AD1PCFG.setPCFG6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TADC10_AD1PCFG.clearPCFG6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TADC10_AD1PCFG.setPCFG6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TADC10_AD1PCFG.getPCFG6 : TBits_1; inline;
begin
  getPCFG6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TADC10_AD1PCFG.setPCFG7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TADC10_AD1PCFG.clearPCFG7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TADC10_AD1PCFG.setPCFG7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TADC10_AD1PCFG.getPCFG7 : TBits_1; inline;
begin
  getPCFG7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TADC10_AD1PCFG.setPCFG8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TADC10_AD1PCFG.clearPCFG8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TADC10_AD1PCFG.setPCFG8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TADC10_AD1PCFG.getPCFG8 : TBits_1; inline;
begin
  getPCFG8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TADC10_AD1PCFG.setPCFG9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TADC10_AD1PCFG.clearPCFG9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TADC10_AD1PCFG.setPCFG9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TADC10_AD1PCFG.getPCFG9 : TBits_1; inline;
begin
  getPCFG9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TADC10_AD1PCFG.setPCFG10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TADC10_AD1PCFG.clearPCFG10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TADC10_AD1PCFG.setPCFG10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TADC10_AD1PCFG.getPCFG10 : TBits_1; inline;
begin
  getPCFG10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TADC10_AD1PCFG.setPCFG11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TADC10_AD1PCFG.clearPCFG11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TADC10_AD1PCFG.setPCFG11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TADC10_AD1PCFG.getPCFG11 : TBits_1; inline;
begin
  getPCFG11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TADC10_AD1PCFG.setPCFG12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TADC10_AD1PCFG.clearPCFG12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TADC10_AD1PCFG.setPCFG12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TADC10_AD1PCFG.getPCFG12 : TBits_1; inline;
begin
  getPCFG12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TADC10_AD1PCFG.setPCFG13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TADC10_AD1PCFG.clearPCFG13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TADC10_AD1PCFG.setPCFG13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TADC10_AD1PCFG.getPCFG13 : TBits_1; inline;
begin
  getPCFG13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TADC10_AD1PCFG.setPCFG14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TADC10_AD1PCFG.clearPCFG14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TADC10_AD1PCFG.setPCFG14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TADC10_AD1PCFG.getPCFG14 : TBits_1; inline;
begin
  getPCFG14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TADC10_AD1PCFG.setPCFG15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TADC10_AD1PCFG.clearPCFG15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TADC10_AD1PCFG.setPCFG15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TADC10_AD1PCFG.getPCFG15 : TBits_1; inline;
begin
  getPCFG15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TADC10_AD1PCFG.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TADC10_AD1PCFG.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TCVR_CVRCON.setCVR(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF0 or ( thebits shl 0 );
end;
function  TCVR_CVRCON.getCVR : TBits_4; inline;
begin
  getCVR := (pTDefRegMap(@Self)^.val and $0000000F) shr 0;
end;
procedure TCVR_CVRCON.setCVRSS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TCVR_CVRCON.clearCVRSS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TCVR_CVRCON.setCVRSS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TCVR_CVRCON.getCVRSS : TBits_1; inline;
begin
  getCVRSS := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TCVR_CVRCON.setCVRR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TCVR_CVRCON.clearCVRR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TCVR_CVRCON.setCVRR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TCVR_CVRCON.getCVRR : TBits_1; inline;
begin
  getCVRR := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TCVR_CVRCON.setCVROE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TCVR_CVRCON.clearCVROE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TCVR_CVRCON.setCVROE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TCVR_CVRCON.getCVROE : TBits_1; inline;
begin
  getCVROE := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TCVR_CVRCON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TCVR_CVRCON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TCVR_CVRCON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TCVR_CVRCON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TCVR_CVRCON.setCVR0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TCVR_CVRCON.clearCVR0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TCVR_CVRCON.setCVR0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TCVR_CVRCON.getCVR0 : TBits_1; inline;
begin
  getCVR0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TCVR_CVRCON.setCVR1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TCVR_CVRCON.clearCVR1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TCVR_CVRCON.setCVR1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TCVR_CVRCON.getCVR1 : TBits_1; inline;
begin
  getCVR1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TCVR_CVRCON.setCVR2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TCVR_CVRCON.clearCVR2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TCVR_CVRCON.setCVR2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TCVR_CVRCON.getCVR2 : TBits_1; inline;
begin
  getCVR2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TCVR_CVRCON.setCVR3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TCVR_CVRCON.clearCVR3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TCVR_CVRCON.setCVR3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TCVR_CVRCON.getCVR3 : TBits_1; inline;
begin
  getCVR3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TCVR_CVRCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TCVR_CVRCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TCMP_CM1CON.setCCH(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFFC or ( thebits shl 0 );
end;
function  TCMP_CM1CON.getCCH : TBits_2; inline;
begin
  getCCH := (pTDefRegMap(@Self)^.val and $00000003) shr 0;
end;
procedure TCMP_CM1CON.setCREF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TCMP_CM1CON.clearCREF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TCMP_CM1CON.setCREF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TCMP_CM1CON.getCREF : TBits_1; inline;
begin
  getCREF := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TCMP_CM1CON.setEVPOL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF3F or ( thebits shl 6 );
end;
function  TCMP_CM1CON.getEVPOL : TBits_2; inline;
begin
  getEVPOL := (pTDefRegMap(@Self)^.val and $000000C0) shr 6;
end;
procedure TCMP_CM1CON.setCOUT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TCMP_CM1CON.clearCOUT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TCMP_CM1CON.setCOUT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TCMP_CM1CON.getCOUT : TBits_1; inline;
begin
  getCOUT := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TCMP_CM1CON.setCPOL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TCMP_CM1CON.clearCPOL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TCMP_CM1CON.setCPOL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TCMP_CM1CON.getCPOL : TBits_1; inline;
begin
  getCPOL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TCMP_CM1CON.setCOE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TCMP_CM1CON.clearCOE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TCMP_CM1CON.setCOE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TCMP_CM1CON.getCOE : TBits_1; inline;
begin
  getCOE := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TCMP_CM1CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TCMP_CM1CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TCMP_CM1CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TCMP_CM1CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TCMP_CM1CON.setCCH0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TCMP_CM1CON.clearCCH0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TCMP_CM1CON.setCCH0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TCMP_CM1CON.getCCH0 : TBits_1; inline;
begin
  getCCH0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TCMP_CM1CON.setCCH1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TCMP_CM1CON.clearCCH1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TCMP_CM1CON.setCCH1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TCMP_CM1CON.getCCH1 : TBits_1; inline;
begin
  getCCH1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TCMP_CM1CON.setEVPOL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TCMP_CM1CON.clearEVPOL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TCMP_CM1CON.setEVPOL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TCMP_CM1CON.getEVPOL0 : TBits_1; inline;
begin
  getEVPOL0 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TCMP_CM1CON.setEVPOL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TCMP_CM1CON.clearEVPOL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TCMP_CM1CON.setEVPOL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TCMP_CM1CON.getEVPOL1 : TBits_1; inline;
begin
  getEVPOL1 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TCMP_CM1CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TCMP_CM1CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TCMP_CM2CON.setCCH(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFFC or ( thebits shl 0 );
end;
function  TCMP_CM2CON.getCCH : TBits_2; inline;
begin
  getCCH := (pTDefRegMap(@Self)^.val and $00000003) shr 0;
end;
procedure TCMP_CM2CON.setCREF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TCMP_CM2CON.clearCREF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TCMP_CM2CON.setCREF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TCMP_CM2CON.getCREF : TBits_1; inline;
begin
  getCREF := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TCMP_CM2CON.setEVPOL(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF3F or ( thebits shl 6 );
end;
function  TCMP_CM2CON.getEVPOL : TBits_2; inline;
begin
  getEVPOL := (pTDefRegMap(@Self)^.val and $000000C0) shr 6;
end;
procedure TCMP_CM2CON.setCOUT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TCMP_CM2CON.clearCOUT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TCMP_CM2CON.setCOUT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TCMP_CM2CON.getCOUT : TBits_1; inline;
begin
  getCOUT := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TCMP_CM2CON.setCPOL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TCMP_CM2CON.clearCPOL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TCMP_CM2CON.setCPOL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TCMP_CM2CON.getCPOL : TBits_1; inline;
begin
  getCPOL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TCMP_CM2CON.setCOE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TCMP_CM2CON.clearCOE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TCMP_CM2CON.setCOE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TCMP_CM2CON.getCOE : TBits_1; inline;
begin
  getCOE := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TCMP_CM2CON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TCMP_CM2CON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TCMP_CM2CON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TCMP_CM2CON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TCMP_CM2CON.setCCH0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TCMP_CM2CON.clearCCH0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TCMP_CM2CON.setCCH0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TCMP_CM2CON.getCCH0 : TBits_1; inline;
begin
  getCCH0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TCMP_CM2CON.setCCH1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TCMP_CM2CON.clearCCH1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TCMP_CM2CON.setCCH1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TCMP_CM2CON.getCCH1 : TBits_1; inline;
begin
  getCCH1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TCMP_CM2CON.setEVPOL0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TCMP_CM2CON.clearEVPOL0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TCMP_CM2CON.setEVPOL0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TCMP_CM2CON.getEVPOL0 : TBits_1; inline;
begin
  getEVPOL0 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TCMP_CM2CON.setEVPOL1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TCMP_CM2CON.clearEVPOL1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TCMP_CM2CON.setEVPOL1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TCMP_CM2CON.getEVPOL1 : TBits_1; inline;
begin
  getEVPOL1 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TCMP_CM2CON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TCMP_CM2CON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TCMP_CMSTAT.setC1OUT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TCMP_CMSTAT.clearC1OUT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TCMP_CMSTAT.setC1OUT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TCMP_CMSTAT.getC1OUT : TBits_1; inline;
begin
  getC1OUT := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TCMP_CMSTAT.setC2OUT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TCMP_CMSTAT.clearC2OUT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TCMP_CMSTAT.setC2OUT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TCMP_CMSTAT.getC2OUT : TBits_1; inline;
begin
  getC2OUT := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TCMP_CMSTAT.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TCMP_CMSTAT.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TCMP_CMSTAT.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TCMP_CMSTAT.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TCMP_CMSTAT.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TCMP_CMSTAT.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TOSC_OSCCON.setOSWEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TOSC_OSCCON.clearOSWEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TOSC_OSCCON.setOSWEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TOSC_OSCCON.getOSWEN : TBits_1; inline;
begin
  getOSWEN := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TOSC_OSCCON.setSOSCEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TOSC_OSCCON.clearSOSCEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TOSC_OSCCON.setSOSCEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TOSC_OSCCON.getSOSCEN : TBits_1; inline;
begin
  getSOSCEN := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TOSC_OSCCON.setUFRCEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TOSC_OSCCON.clearUFRCEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TOSC_OSCCON.setUFRCEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TOSC_OSCCON.getUFRCEN : TBits_1; inline;
begin
  getUFRCEN := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TOSC_OSCCON.setCF; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TOSC_OSCCON.clearCF; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TOSC_OSCCON.setCF(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TOSC_OSCCON.getCF : TBits_1; inline;
begin
  getCF := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TOSC_OSCCON.setSLPEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TOSC_OSCCON.clearSLPEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TOSC_OSCCON.setSLPEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TOSC_OSCCON.getSLPEN : TBits_1; inline;
begin
  getSLPEN := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TOSC_OSCCON.setLOCK; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TOSC_OSCCON.clearLOCK; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TOSC_OSCCON.setLOCK(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TOSC_OSCCON.getLOCK : TBits_1; inline;
begin
  getLOCK := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TOSC_OSCCON.setULOCK; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TOSC_OSCCON.clearULOCK; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TOSC_OSCCON.setULOCK(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TOSC_OSCCON.getULOCK : TBits_1; inline;
begin
  getULOCK := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TOSC_OSCCON.setCLKLOCK; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TOSC_OSCCON.clearCLKLOCK; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TOSC_OSCCON.setCLKLOCK(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TOSC_OSCCON.getCLKLOCK : TBits_1; inline;
begin
  getCLKLOCK := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TOSC_OSCCON.setNOSC(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF8FF or ( thebits shl 8 );
end;
function  TOSC_OSCCON.getNOSC : TBits_3; inline;
begin
  getNOSC := (pTDefRegMap(@Self)^.val and $00000700) shr 8;
end;
procedure TOSC_OSCCON.setCOSC(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF8FFF or ( thebits shl 12 );
end;
function  TOSC_OSCCON.getCOSC : TBits_3; inline;
begin
  getCOSC := (pTDefRegMap(@Self)^.val and $00007000) shr 12;
end;
procedure TOSC_OSCCON.setPLLMULT(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFF8FFFF or ( thebits shl 16 );
end;
function  TOSC_OSCCON.getPLLMULT : TBits_3; inline;
begin
  getPLLMULT := (pTDefRegMap(@Self)^.val and $00070000) shr 16;
end;
procedure TOSC_OSCCON.setPBDIV(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFE7FFFF or ( thebits shl 19 );
end;
function  TOSC_OSCCON.getPBDIV : TBits_2; inline;
begin
  getPBDIV := (pTDefRegMap(@Self)^.val and $00180000) shr 19;
end;
procedure TOSC_OSCCON.setSOSCRDY; inline;
begin
  pTDefRegMap(@Self)^.&set := $00400000;
end;
procedure TOSC_OSCCON.clearSOSCRDY; inline;
begin
  pTDefRegMap(@Self)^.clr := $00400000;
end;
procedure TOSC_OSCCON.setSOSCRDY(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00400000
  else
    pTDefRegMap(@Self)^.&set := $00400000;
end;
function  TOSC_OSCCON.getSOSCRDY : TBits_1; inline;
begin
  getSOSCRDY := (pTDefRegMap(@Self)^.val and $00400000) shr 22;
end;
procedure TOSC_OSCCON.setFRCDIV(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $F8FFFFFF or ( thebits shl 24 );
end;
function  TOSC_OSCCON.getFRCDIV : TBits_3; inline;
begin
  getFRCDIV := (pTDefRegMap(@Self)^.val and $07000000) shr 24;
end;
procedure TOSC_OSCCON.setPLLODIV(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $C7FFFFFF or ( thebits shl 27 );
end;
function  TOSC_OSCCON.getPLLODIV : TBits_3; inline;
begin
  getPLLODIV := (pTDefRegMap(@Self)^.val and $38000000) shr 27;
end;
procedure TOSC_OSCCON.setNOSC0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TOSC_OSCCON.clearNOSC0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TOSC_OSCCON.setNOSC0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TOSC_OSCCON.getNOSC0 : TBits_1; inline;
begin
  getNOSC0 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TOSC_OSCCON.setNOSC1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TOSC_OSCCON.clearNOSC1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TOSC_OSCCON.setNOSC1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TOSC_OSCCON.getNOSC1 : TBits_1; inline;
begin
  getNOSC1 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TOSC_OSCCON.setNOSC2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TOSC_OSCCON.clearNOSC2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TOSC_OSCCON.setNOSC2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TOSC_OSCCON.getNOSC2 : TBits_1; inline;
begin
  getNOSC2 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TOSC_OSCCON.setCOSC0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TOSC_OSCCON.clearCOSC0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TOSC_OSCCON.setCOSC0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TOSC_OSCCON.getCOSC0 : TBits_1; inline;
begin
  getCOSC0 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TOSC_OSCCON.setCOSC1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TOSC_OSCCON.clearCOSC1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TOSC_OSCCON.setCOSC1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TOSC_OSCCON.getCOSC1 : TBits_1; inline;
begin
  getCOSC1 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TOSC_OSCCON.setCOSC2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TOSC_OSCCON.clearCOSC2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TOSC_OSCCON.setCOSC2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TOSC_OSCCON.getCOSC2 : TBits_1; inline;
begin
  getCOSC2 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TOSC_OSCCON.setPLLMULT0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00010000;
end;
procedure TOSC_OSCCON.clearPLLMULT0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00010000;
end;
procedure TOSC_OSCCON.setPLLMULT0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00010000
  else
    pTDefRegMap(@Self)^.&set := $00010000;
end;
function  TOSC_OSCCON.getPLLMULT0 : TBits_1; inline;
begin
  getPLLMULT0 := (pTDefRegMap(@Self)^.val and $00010000) shr 16;
end;
procedure TOSC_OSCCON.setPLLMULT1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00020000;
end;
procedure TOSC_OSCCON.clearPLLMULT1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00020000;
end;
procedure TOSC_OSCCON.setPLLMULT1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00020000
  else
    pTDefRegMap(@Self)^.&set := $00020000;
end;
function  TOSC_OSCCON.getPLLMULT1 : TBits_1; inline;
begin
  getPLLMULT1 := (pTDefRegMap(@Self)^.val and $00020000) shr 17;
end;
procedure TOSC_OSCCON.setPLLMULT2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00040000;
end;
procedure TOSC_OSCCON.clearPLLMULT2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00040000;
end;
procedure TOSC_OSCCON.setPLLMULT2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00040000
  else
    pTDefRegMap(@Self)^.&set := $00040000;
end;
function  TOSC_OSCCON.getPLLMULT2 : TBits_1; inline;
begin
  getPLLMULT2 := (pTDefRegMap(@Self)^.val and $00040000) shr 18;
end;
procedure TOSC_OSCCON.setPBDIV0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00080000;
end;
procedure TOSC_OSCCON.clearPBDIV0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00080000;
end;
procedure TOSC_OSCCON.setPBDIV0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00080000
  else
    pTDefRegMap(@Self)^.&set := $00080000;
end;
function  TOSC_OSCCON.getPBDIV0 : TBits_1; inline;
begin
  getPBDIV0 := (pTDefRegMap(@Self)^.val and $00080000) shr 19;
end;
procedure TOSC_OSCCON.setPBDIV1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00100000;
end;
procedure TOSC_OSCCON.clearPBDIV1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00100000;
end;
procedure TOSC_OSCCON.setPBDIV1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00100000
  else
    pTDefRegMap(@Self)^.&set := $00100000;
end;
function  TOSC_OSCCON.getPBDIV1 : TBits_1; inline;
begin
  getPBDIV1 := (pTDefRegMap(@Self)^.val and $00100000) shr 20;
end;
procedure TOSC_OSCCON.setFRCDIV0; inline;
begin
  pTDefRegMap(@Self)^.&set := $01000000;
end;
procedure TOSC_OSCCON.clearFRCDIV0; inline;
begin
  pTDefRegMap(@Self)^.clr := $01000000;
end;
procedure TOSC_OSCCON.setFRCDIV0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $01000000
  else
    pTDefRegMap(@Self)^.&set := $01000000;
end;
function  TOSC_OSCCON.getFRCDIV0 : TBits_1; inline;
begin
  getFRCDIV0 := (pTDefRegMap(@Self)^.val and $01000000) shr 24;
end;
procedure TOSC_OSCCON.setFRCDIV1; inline;
begin
  pTDefRegMap(@Self)^.&set := $02000000;
end;
procedure TOSC_OSCCON.clearFRCDIV1; inline;
begin
  pTDefRegMap(@Self)^.clr := $02000000;
end;
procedure TOSC_OSCCON.setFRCDIV1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $02000000
  else
    pTDefRegMap(@Self)^.&set := $02000000;
end;
function  TOSC_OSCCON.getFRCDIV1 : TBits_1; inline;
begin
  getFRCDIV1 := (pTDefRegMap(@Self)^.val and $02000000) shr 25;
end;
procedure TOSC_OSCCON.setFRCDIV2; inline;
begin
  pTDefRegMap(@Self)^.&set := $04000000;
end;
procedure TOSC_OSCCON.clearFRCDIV2; inline;
begin
  pTDefRegMap(@Self)^.clr := $04000000;
end;
procedure TOSC_OSCCON.setFRCDIV2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $04000000
  else
    pTDefRegMap(@Self)^.&set := $04000000;
end;
function  TOSC_OSCCON.getFRCDIV2 : TBits_1; inline;
begin
  getFRCDIV2 := (pTDefRegMap(@Self)^.val and $04000000) shr 26;
end;
procedure TOSC_OSCCON.setPLLODIV0; inline;
begin
  pTDefRegMap(@Self)^.&set := $08000000;
end;
procedure TOSC_OSCCON.clearPLLODIV0; inline;
begin
  pTDefRegMap(@Self)^.clr := $08000000;
end;
procedure TOSC_OSCCON.setPLLODIV0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $08000000
  else
    pTDefRegMap(@Self)^.&set := $08000000;
end;
function  TOSC_OSCCON.getPLLODIV0 : TBits_1; inline;
begin
  getPLLODIV0 := (pTDefRegMap(@Self)^.val and $08000000) shr 27;
end;
procedure TOSC_OSCCON.setPLLODIV1; inline;
begin
  pTDefRegMap(@Self)^.&set := $10000000;
end;
procedure TOSC_OSCCON.clearPLLODIV1; inline;
begin
  pTDefRegMap(@Self)^.clr := $10000000;
end;
procedure TOSC_OSCCON.setPLLODIV1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $10000000
  else
    pTDefRegMap(@Self)^.&set := $10000000;
end;
function  TOSC_OSCCON.getPLLODIV1 : TBits_1; inline;
begin
  getPLLODIV1 := (pTDefRegMap(@Self)^.val and $10000000) shr 28;
end;
procedure TOSC_OSCCON.setPLLODIV2; inline;
begin
  pTDefRegMap(@Self)^.&set := $20000000;
end;
procedure TOSC_OSCCON.clearPLLODIV2; inline;
begin
  pTDefRegMap(@Self)^.clr := $20000000;
end;
procedure TOSC_OSCCON.setPLLODIV2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $20000000
  else
    pTDefRegMap(@Self)^.&set := $20000000;
end;
function  TOSC_OSCCON.getPLLODIV2 : TBits_1; inline;
begin
  getPLLODIV2 := (pTDefRegMap(@Self)^.val and $20000000) shr 29;
end;
procedure TOSC_OSCCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TOSC_OSCCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TOSC_OSCTUN.setTUN(thebits : TBits_6); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFC0 or ( thebits shl 0 );
end;
function  TOSC_OSCTUN.getTUN : TBits_6; inline;
begin
  getTUN := (pTDefRegMap(@Self)^.val and $0000003F) shr 0;
end;
procedure TOSC_OSCTUN.setTUN0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TOSC_OSCTUN.clearTUN0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TOSC_OSCTUN.setTUN0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TOSC_OSCTUN.getTUN0 : TBits_1; inline;
begin
  getTUN0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TOSC_OSCTUN.setTUN1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TOSC_OSCTUN.clearTUN1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TOSC_OSCTUN.setTUN1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TOSC_OSCTUN.getTUN1 : TBits_1; inline;
begin
  getTUN1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TOSC_OSCTUN.setTUN2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TOSC_OSCTUN.clearTUN2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TOSC_OSCTUN.setTUN2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TOSC_OSCTUN.getTUN2 : TBits_1; inline;
begin
  getTUN2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TOSC_OSCTUN.setTUN3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TOSC_OSCTUN.clearTUN3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TOSC_OSCTUN.setTUN3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TOSC_OSCTUN.getTUN3 : TBits_1; inline;
begin
  getTUN3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TOSC_OSCTUN.setTUN4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TOSC_OSCTUN.clearTUN4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TOSC_OSCTUN.setTUN4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TOSC_OSCTUN.getTUN4 : TBits_1; inline;
begin
  getTUN4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TOSC_OSCTUN.setTUN5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TOSC_OSCTUN.clearTUN5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TOSC_OSCTUN.setTUN5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TOSC_OSCTUN.getTUN5 : TBits_1; inline;
begin
  getTUN5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TOSC_OSCTUN.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TOSC_OSCTUN.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TNVM_NVMCON.setNVMOP(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF0 or ( thebits shl 0 );
end;
function  TNVM_NVMCON.getNVMOP : TBits_4; inline;
begin
  getNVMOP := (pTDefRegMap(@Self)^.val and $0000000F) shr 0;
end;
procedure TNVM_NVMCON.setLVDSTAT; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TNVM_NVMCON.clearLVDSTAT; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TNVM_NVMCON.setLVDSTAT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TNVM_NVMCON.getLVDSTAT : TBits_1; inline;
begin
  getLVDSTAT := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TNVM_NVMCON.setLVDERR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TNVM_NVMCON.clearLVDERR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TNVM_NVMCON.setLVDERR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TNVM_NVMCON.getLVDERR : TBits_1; inline;
begin
  getLVDERR := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TNVM_NVMCON.setWRERR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TNVM_NVMCON.clearWRERR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TNVM_NVMCON.setWRERR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TNVM_NVMCON.getWRERR : TBits_1; inline;
begin
  getWRERR := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TNVM_NVMCON.setWREN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TNVM_NVMCON.clearWREN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TNVM_NVMCON.setWREN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TNVM_NVMCON.getWREN : TBits_1; inline;
begin
  getWREN := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TNVM_NVMCON.setWR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TNVM_NVMCON.clearWR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TNVM_NVMCON.setWR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TNVM_NVMCON.getWR : TBits_1; inline;
begin
  getWR := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TNVM_NVMCON.setNVMOP0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TNVM_NVMCON.clearNVMOP0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TNVM_NVMCON.setNVMOP0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TNVM_NVMCON.getNVMOP0 : TBits_1; inline;
begin
  getNVMOP0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TNVM_NVMCON.setNVMOP1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TNVM_NVMCON.clearNVMOP1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TNVM_NVMCON.setNVMOP1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TNVM_NVMCON.getNVMOP1 : TBits_1; inline;
begin
  getNVMOP1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TNVM_NVMCON.setNVMOP2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TNVM_NVMCON.clearNVMOP2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TNVM_NVMCON.setNVMOP2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TNVM_NVMCON.getNVMOP2 : TBits_1; inline;
begin
  getNVMOP2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TNVM_NVMCON.setNVMOP3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TNVM_NVMCON.clearNVMOP3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TNVM_NVMCON.setNVMOP3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TNVM_NVMCON.getNVMOP3 : TBits_1; inline;
begin
  getNVMOP3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TNVM_NVMCON.setPROGOP(thebits : TBits_4); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF0 or ( thebits shl 0 );
end;
function  TNVM_NVMCON.getPROGOP : TBits_4; inline;
begin
  getPROGOP := (pTDefRegMap(@Self)^.val and $0000000F) shr 0;
end;
procedure TNVM_NVMCON.setPROGOP0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TNVM_NVMCON.clearPROGOP0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TNVM_NVMCON.setPROGOP0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TNVM_NVMCON.getPROGOP0 : TBits_1; inline;
begin
  getPROGOP0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TNVM_NVMCON.setPROGOP1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TNVM_NVMCON.clearPROGOP1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TNVM_NVMCON.setPROGOP1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TNVM_NVMCON.getPROGOP1 : TBits_1; inline;
begin
  getPROGOP1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TNVM_NVMCON.setPROGOP2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TNVM_NVMCON.clearPROGOP2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TNVM_NVMCON.setPROGOP2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TNVM_NVMCON.getPROGOP2 : TBits_1; inline;
begin
  getPROGOP2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TNVM_NVMCON.setPROGOP3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TNVM_NVMCON.clearPROGOP3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TNVM_NVMCON.setPROGOP3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TNVM_NVMCON.getPROGOP3 : TBits_1; inline;
begin
  getPROGOP3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TNVM_NVMCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TNVM_NVMCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TRCON_RCON.setPOR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TRCON_RCON.clearPOR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TRCON_RCON.setPOR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TRCON_RCON.getPOR : TBits_1; inline;
begin
  getPOR := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TRCON_RCON.setBOR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TRCON_RCON.clearBOR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TRCON_RCON.setBOR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TRCON_RCON.getBOR : TBits_1; inline;
begin
  getBOR := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TRCON_RCON.setIDLE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TRCON_RCON.clearIDLE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TRCON_RCON.setIDLE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TRCON_RCON.getIDLE : TBits_1; inline;
begin
  getIDLE := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TRCON_RCON.setSLEEP; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TRCON_RCON.clearSLEEP; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TRCON_RCON.setSLEEP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TRCON_RCON.getSLEEP : TBits_1; inline;
begin
  getSLEEP := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TRCON_RCON.setWDTO; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TRCON_RCON.clearWDTO; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TRCON_RCON.setWDTO(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TRCON_RCON.getWDTO : TBits_1; inline;
begin
  getWDTO := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TRCON_RCON.setSWR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TRCON_RCON.clearSWR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TRCON_RCON.setSWR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TRCON_RCON.getSWR : TBits_1; inline;
begin
  getSWR := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TRCON_RCON.setEXTR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TRCON_RCON.clearEXTR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TRCON_RCON.setEXTR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TRCON_RCON.getEXTR : TBits_1; inline;
begin
  getEXTR := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TRCON_RCON.setVREGS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TRCON_RCON.clearVREGS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TRCON_RCON.setVREGS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TRCON_RCON.getVREGS : TBits_1; inline;
begin
  getVREGS := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TRCON_RCON.setCMR; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TRCON_RCON.clearCMR; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TRCON_RCON.setCMR(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TRCON_RCON.getCMR : TBits_1; inline;
begin
  getCMR := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TRCON_RCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TRCON_RCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TRCON_RSWRST.setSWRST; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TRCON_RSWRST.clearSWRST; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TRCON_RSWRST.setSWRST(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TRCON_RSWRST.getSWRST : TBits_1; inline;
begin
  getSWRST := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TRCON_RSWRST.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TRCON_RSWRST.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TINT_INTSTAT.setVEC(thebits : TBits_6); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFC0 or ( thebits shl 0 );
end;
function  TINT_INTSTAT.getVEC : TBits_6; inline;
begin
  getVEC := (pTDefRegMap(@Self)^.val and $0000003F) shr 0;
end;
procedure TINT_INTSTAT.setRIPL(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF8FF or ( thebits shl 8 );
end;
function  TINT_INTSTAT.getRIPL : TBits_3; inline;
begin
  getRIPL := (pTDefRegMap(@Self)^.val and $00000700) shr 8;
end;
procedure TINT_INTSTAT.setSRIPL(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFF8FF or ( thebits shl 8 );
end;
function  TINT_INTSTAT.getSRIPL : TBits_3; inline;
begin
  getSRIPL := (pTDefRegMap(@Self)^.val and $00000700) shr 8;
end;
procedure TBMX_BMXCON.setBMXARB(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TBMX_BMXCON.getBMXARB : TBits_3; inline;
begin
  getBMXARB := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TBMX_BMXCON.setBMXWSDRM; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TBMX_BMXCON.clearBMXWSDRM; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TBMX_BMXCON.setBMXWSDRM(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TBMX_BMXCON.getBMXWSDRM : TBits_1; inline;
begin
  getBMXWSDRM := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TBMX_BMXCON.setBMXERRIS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00010000;
end;
procedure TBMX_BMXCON.clearBMXERRIS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00010000;
end;
procedure TBMX_BMXCON.setBMXERRIS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00010000
  else
    pTDefRegMap(@Self)^.&set := $00010000;
end;
function  TBMX_BMXCON.getBMXERRIS : TBits_1; inline;
begin
  getBMXERRIS := (pTDefRegMap(@Self)^.val and $00010000) shr 16;
end;
procedure TBMX_BMXCON.setBMXERRDS; inline;
begin
  pTDefRegMap(@Self)^.&set := $00020000;
end;
procedure TBMX_BMXCON.clearBMXERRDS; inline;
begin
  pTDefRegMap(@Self)^.clr := $00020000;
end;
procedure TBMX_BMXCON.setBMXERRDS(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00020000
  else
    pTDefRegMap(@Self)^.&set := $00020000;
end;
function  TBMX_BMXCON.getBMXERRDS : TBits_1; inline;
begin
  getBMXERRDS := (pTDefRegMap(@Self)^.val and $00020000) shr 17;
end;
procedure TBMX_BMXCON.setBMXERRDMA; inline;
begin
  pTDefRegMap(@Self)^.&set := $00040000;
end;
procedure TBMX_BMXCON.clearBMXERRDMA; inline;
begin
  pTDefRegMap(@Self)^.clr := $00040000;
end;
procedure TBMX_BMXCON.setBMXERRDMA(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00040000
  else
    pTDefRegMap(@Self)^.&set := $00040000;
end;
function  TBMX_BMXCON.getBMXERRDMA : TBits_1; inline;
begin
  getBMXERRDMA := (pTDefRegMap(@Self)^.val and $00040000) shr 18;
end;
procedure TBMX_BMXCON.setBMXERRICD; inline;
begin
  pTDefRegMap(@Self)^.&set := $00080000;
end;
procedure TBMX_BMXCON.clearBMXERRICD; inline;
begin
  pTDefRegMap(@Self)^.clr := $00080000;
end;
procedure TBMX_BMXCON.setBMXERRICD(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00080000
  else
    pTDefRegMap(@Self)^.&set := $00080000;
end;
function  TBMX_BMXCON.getBMXERRICD : TBits_1; inline;
begin
  getBMXERRICD := (pTDefRegMap(@Self)^.val and $00080000) shr 19;
end;
procedure TBMX_BMXCON.setBMXERRIXI; inline;
begin
  pTDefRegMap(@Self)^.&set := $00100000;
end;
procedure TBMX_BMXCON.clearBMXERRIXI; inline;
begin
  pTDefRegMap(@Self)^.clr := $00100000;
end;
procedure TBMX_BMXCON.setBMXERRIXI(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00100000
  else
    pTDefRegMap(@Self)^.&set := $00100000;
end;
function  TBMX_BMXCON.getBMXERRIXI : TBits_1; inline;
begin
  getBMXERRIXI := (pTDefRegMap(@Self)^.val and $00100000) shr 20;
end;
procedure TBMX_BMXCON.setBMXCHEDMA; inline;
begin
  pTDefRegMap(@Self)^.&set := $04000000;
end;
procedure TBMX_BMXCON.clearBMXCHEDMA; inline;
begin
  pTDefRegMap(@Self)^.clr := $04000000;
end;
procedure TBMX_BMXCON.setBMXCHEDMA(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $04000000
  else
    pTDefRegMap(@Self)^.&set := $04000000;
end;
function  TBMX_BMXCON.getBMXCHEDMA : TBits_1; inline;
begin
  getBMXCHEDMA := (pTDefRegMap(@Self)^.val and $04000000) shr 26;
end;
procedure TBMX_BMXCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TBMX_BMXCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPCACHE_CHECON.setPFMWS(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TPCACHE_CHECON.getPFMWS : TBits_3; inline;
begin
  getPFMWS := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TPCACHE_CHECON.setPREFEN(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFCF or ( thebits shl 4 );
end;
function  TPCACHE_CHECON.getPREFEN : TBits_2; inline;
begin
  getPREFEN := (pTDefRegMap(@Self)^.val and $00000030) shr 4;
end;
procedure TPCACHE_CHECON.setDCSZ(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFCFF or ( thebits shl 8 );
end;
function  TPCACHE_CHECON.getDCSZ : TBits_2; inline;
begin
  getDCSZ := (pTDefRegMap(@Self)^.val and $00000300) shr 8;
end;
procedure TPCACHE_CHECON.setCHECOH; inline;
begin
  pTDefRegMap(@Self)^.&set := $00010000;
end;
procedure TPCACHE_CHECON.clearCHECOH; inline;
begin
  pTDefRegMap(@Self)^.clr := $00010000;
end;
procedure TPCACHE_CHECON.setCHECOH(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00010000
  else
    pTDefRegMap(@Self)^.&set := $00010000;
end;
function  TPCACHE_CHECON.getCHECOH : TBits_1; inline;
begin
  getCHECOH := (pTDefRegMap(@Self)^.val and $00010000) shr 16;
end;
procedure TPCACHE_CHECON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPCACHE_CHECON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPCACHE_CHETAG.setLTYPE; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPCACHE_CHETAG.clearLTYPE; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPCACHE_CHETAG.setLTYPE(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPCACHE_CHETAG.getLTYPE : TBits_1; inline;
begin
  getLTYPE := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPCACHE_CHETAG.setLLOCK; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPCACHE_CHETAG.clearLLOCK; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPCACHE_CHETAG.setLLOCK(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPCACHE_CHETAG.getLLOCK : TBits_1; inline;
begin
  getLLOCK := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPCACHE_CHETAG.setLVALID; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPCACHE_CHETAG.clearLVALID; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPCACHE_CHETAG.setLVALID(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPCACHE_CHETAG.getLVALID : TBits_1; inline;
begin
  getLVALID := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPCACHE_CHETAG.setLTAG(thebits : TBits_20); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FF00000F or ( thebits shl 4 );
end;
function  TPCACHE_CHETAG.getLTAG : TBits_20; inline;
begin
  getLTAG := (pTDefRegMap(@Self)^.val and $00FFFFF0) shr 4;
end;
procedure TPCACHE_CHETAG.setLTAGBOOT; inline;
begin
  pTDefRegMap(@Self)^.&set := $80000000;
end;
procedure TPCACHE_CHETAG.clearLTAGBOOT; inline;
begin
  pTDefRegMap(@Self)^.clr := $80000000;
end;
procedure TPCACHE_CHETAG.setLTAGBOOT(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $80000000
  else
    pTDefRegMap(@Self)^.&set := $80000000;
end;
function  TPCACHE_CHETAG.getLTAGBOOT : TBits_1; inline;
begin
  getLTAGBOOT := (pTDefRegMap(@Self)^.val and $80000000) shr 31;
end;
procedure TPCACHE_CHETAG.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPCACHE_CHETAG.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTB_TRISB.setTRISB0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTB_TRISB.clearTRISB0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTB_TRISB.setTRISB0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTB_TRISB.getTRISB0 : TBits_1; inline;
begin
  getTRISB0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTB_TRISB.setTRISB1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTB_TRISB.clearTRISB1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTB_TRISB.setTRISB1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTB_TRISB.getTRISB1 : TBits_1; inline;
begin
  getTRISB1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTB_TRISB.setTRISB2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTB_TRISB.clearTRISB2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTB_TRISB.setTRISB2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTB_TRISB.getTRISB2 : TBits_1; inline;
begin
  getTRISB2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTB_TRISB.setTRISB3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTB_TRISB.clearTRISB3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTB_TRISB.setTRISB3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTB_TRISB.getTRISB3 : TBits_1; inline;
begin
  getTRISB3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTB_TRISB.setTRISB4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTB_TRISB.clearTRISB4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTB_TRISB.setTRISB4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTB_TRISB.getTRISB4 : TBits_1; inline;
begin
  getTRISB4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTB_TRISB.setTRISB5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTB_TRISB.clearTRISB5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTB_TRISB.setTRISB5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTB_TRISB.getTRISB5 : TBits_1; inline;
begin
  getTRISB5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTB_TRISB.setTRISB6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTB_TRISB.clearTRISB6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTB_TRISB.setTRISB6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTB_TRISB.getTRISB6 : TBits_1; inline;
begin
  getTRISB6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTB_TRISB.setTRISB7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTB_TRISB.clearTRISB7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTB_TRISB.setTRISB7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTB_TRISB.getTRISB7 : TBits_1; inline;
begin
  getTRISB7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTB_TRISB.setTRISB8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTB_TRISB.clearTRISB8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTB_TRISB.setTRISB8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTB_TRISB.getTRISB8 : TBits_1; inline;
begin
  getTRISB8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTB_TRISB.setTRISB9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTB_TRISB.clearTRISB9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTB_TRISB.setTRISB9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTB_TRISB.getTRISB9 : TBits_1; inline;
begin
  getTRISB9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTB_TRISB.setTRISB10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTB_TRISB.clearTRISB10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTB_TRISB.setTRISB10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTB_TRISB.getTRISB10 : TBits_1; inline;
begin
  getTRISB10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTB_TRISB.setTRISB11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTB_TRISB.clearTRISB11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTB_TRISB.setTRISB11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTB_TRISB.getTRISB11 : TBits_1; inline;
begin
  getTRISB11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTB_TRISB.setTRISB12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTB_TRISB.clearTRISB12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTB_TRISB.setTRISB12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTB_TRISB.getTRISB12 : TBits_1; inline;
begin
  getTRISB12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTB_TRISB.setTRISB13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTB_TRISB.clearTRISB13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTB_TRISB.setTRISB13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTB_TRISB.getTRISB13 : TBits_1; inline;
begin
  getTRISB13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTB_TRISB.setTRISB14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTB_TRISB.clearTRISB14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTB_TRISB.setTRISB14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTB_TRISB.getTRISB14 : TBits_1; inline;
begin
  getTRISB14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTB_TRISB.setTRISB15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTB_TRISB.clearTRISB15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTB_TRISB.setTRISB15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTB_TRISB.getTRISB15 : TBits_1; inline;
begin
  getTRISB15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTB_TRISB.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTB_TRISB.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTB_PORTB.setRB0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTB_PORTB.clearRB0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTB_PORTB.setRB0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTB_PORTB.getRB0 : TBits_1; inline;
begin
  getRB0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTB_PORTB.setRB1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTB_PORTB.clearRB1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTB_PORTB.setRB1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTB_PORTB.getRB1 : TBits_1; inline;
begin
  getRB1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTB_PORTB.setRB2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTB_PORTB.clearRB2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTB_PORTB.setRB2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTB_PORTB.getRB2 : TBits_1; inline;
begin
  getRB2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTB_PORTB.setRB3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTB_PORTB.clearRB3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTB_PORTB.setRB3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTB_PORTB.getRB3 : TBits_1; inline;
begin
  getRB3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTB_PORTB.setRB4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTB_PORTB.clearRB4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTB_PORTB.setRB4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTB_PORTB.getRB4 : TBits_1; inline;
begin
  getRB4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTB_PORTB.setRB5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTB_PORTB.clearRB5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTB_PORTB.setRB5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTB_PORTB.getRB5 : TBits_1; inline;
begin
  getRB5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTB_PORTB.setRB6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTB_PORTB.clearRB6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTB_PORTB.setRB6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTB_PORTB.getRB6 : TBits_1; inline;
begin
  getRB6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTB_PORTB.setRB7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTB_PORTB.clearRB7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTB_PORTB.setRB7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTB_PORTB.getRB7 : TBits_1; inline;
begin
  getRB7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTB_PORTB.setRB8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTB_PORTB.clearRB8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTB_PORTB.setRB8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTB_PORTB.getRB8 : TBits_1; inline;
begin
  getRB8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTB_PORTB.setRB9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTB_PORTB.clearRB9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTB_PORTB.setRB9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTB_PORTB.getRB9 : TBits_1; inline;
begin
  getRB9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTB_PORTB.setRB10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTB_PORTB.clearRB10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTB_PORTB.setRB10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTB_PORTB.getRB10 : TBits_1; inline;
begin
  getRB10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTB_PORTB.setRB11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTB_PORTB.clearRB11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTB_PORTB.setRB11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTB_PORTB.getRB11 : TBits_1; inline;
begin
  getRB11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTB_PORTB.setRB12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTB_PORTB.clearRB12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTB_PORTB.setRB12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTB_PORTB.getRB12 : TBits_1; inline;
begin
  getRB12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTB_PORTB.setRB13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTB_PORTB.clearRB13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTB_PORTB.setRB13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTB_PORTB.getRB13 : TBits_1; inline;
begin
  getRB13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTB_PORTB.setRB14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTB_PORTB.clearRB14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTB_PORTB.setRB14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTB_PORTB.getRB14 : TBits_1; inline;
begin
  getRB14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTB_PORTB.setRB15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTB_PORTB.clearRB15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTB_PORTB.setRB15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTB_PORTB.getRB15 : TBits_1; inline;
begin
  getRB15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTB_PORTB.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTB_PORTB.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTB_LATB.setLATB0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTB_LATB.clearLATB0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTB_LATB.setLATB0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTB_LATB.getLATB0 : TBits_1; inline;
begin
  getLATB0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTB_LATB.setLATB1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTB_LATB.clearLATB1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTB_LATB.setLATB1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTB_LATB.getLATB1 : TBits_1; inline;
begin
  getLATB1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTB_LATB.setLATB2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTB_LATB.clearLATB2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTB_LATB.setLATB2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTB_LATB.getLATB2 : TBits_1; inline;
begin
  getLATB2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTB_LATB.setLATB3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTB_LATB.clearLATB3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTB_LATB.setLATB3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTB_LATB.getLATB3 : TBits_1; inline;
begin
  getLATB3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTB_LATB.setLATB4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTB_LATB.clearLATB4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTB_LATB.setLATB4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTB_LATB.getLATB4 : TBits_1; inline;
begin
  getLATB4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTB_LATB.setLATB5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTB_LATB.clearLATB5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTB_LATB.setLATB5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTB_LATB.getLATB5 : TBits_1; inline;
begin
  getLATB5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTB_LATB.setLATB6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTB_LATB.clearLATB6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTB_LATB.setLATB6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTB_LATB.getLATB6 : TBits_1; inline;
begin
  getLATB6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTB_LATB.setLATB7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTB_LATB.clearLATB7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTB_LATB.setLATB7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTB_LATB.getLATB7 : TBits_1; inline;
begin
  getLATB7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTB_LATB.setLATB8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTB_LATB.clearLATB8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTB_LATB.setLATB8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTB_LATB.getLATB8 : TBits_1; inline;
begin
  getLATB8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTB_LATB.setLATB9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTB_LATB.clearLATB9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTB_LATB.setLATB9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTB_LATB.getLATB9 : TBits_1; inline;
begin
  getLATB9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTB_LATB.setLATB10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTB_LATB.clearLATB10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTB_LATB.setLATB10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTB_LATB.getLATB10 : TBits_1; inline;
begin
  getLATB10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTB_LATB.setLATB11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTB_LATB.clearLATB11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTB_LATB.setLATB11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTB_LATB.getLATB11 : TBits_1; inline;
begin
  getLATB11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTB_LATB.setLATB12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTB_LATB.clearLATB12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTB_LATB.setLATB12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTB_LATB.getLATB12 : TBits_1; inline;
begin
  getLATB12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTB_LATB.setLATB13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTB_LATB.clearLATB13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTB_LATB.setLATB13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTB_LATB.getLATB13 : TBits_1; inline;
begin
  getLATB13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTB_LATB.setLATB14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTB_LATB.clearLATB14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTB_LATB.setLATB14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTB_LATB.getLATB14 : TBits_1; inline;
begin
  getLATB14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTB_LATB.setLATB15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTB_LATB.clearLATB15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTB_LATB.setLATB15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTB_LATB.getLATB15 : TBits_1; inline;
begin
  getLATB15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTB_LATB.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTB_LATB.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTB_ODCB.setODCB0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTB_ODCB.clearODCB0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTB_ODCB.setODCB0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTB_ODCB.getODCB0 : TBits_1; inline;
begin
  getODCB0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTB_ODCB.setODCB1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTB_ODCB.clearODCB1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTB_ODCB.setODCB1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTB_ODCB.getODCB1 : TBits_1; inline;
begin
  getODCB1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTB_ODCB.setODCB2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTB_ODCB.clearODCB2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTB_ODCB.setODCB2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTB_ODCB.getODCB2 : TBits_1; inline;
begin
  getODCB2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTB_ODCB.setODCB3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTB_ODCB.clearODCB3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTB_ODCB.setODCB3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTB_ODCB.getODCB3 : TBits_1; inline;
begin
  getODCB3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTB_ODCB.setODCB4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTB_ODCB.clearODCB4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTB_ODCB.setODCB4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTB_ODCB.getODCB4 : TBits_1; inline;
begin
  getODCB4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTB_ODCB.setODCB5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTB_ODCB.clearODCB5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTB_ODCB.setODCB5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTB_ODCB.getODCB5 : TBits_1; inline;
begin
  getODCB5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTB_ODCB.setODCB6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTB_ODCB.clearODCB6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTB_ODCB.setODCB6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTB_ODCB.getODCB6 : TBits_1; inline;
begin
  getODCB6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTB_ODCB.setODCB7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTB_ODCB.clearODCB7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTB_ODCB.setODCB7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTB_ODCB.getODCB7 : TBits_1; inline;
begin
  getODCB7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTB_ODCB.setODCB8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTB_ODCB.clearODCB8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTB_ODCB.setODCB8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTB_ODCB.getODCB8 : TBits_1; inline;
begin
  getODCB8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTB_ODCB.setODCB9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTB_ODCB.clearODCB9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTB_ODCB.setODCB9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTB_ODCB.getODCB9 : TBits_1; inline;
begin
  getODCB9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTB_ODCB.setODCB10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTB_ODCB.clearODCB10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTB_ODCB.setODCB10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTB_ODCB.getODCB10 : TBits_1; inline;
begin
  getODCB10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTB_ODCB.setODCB11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTB_ODCB.clearODCB11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTB_ODCB.setODCB11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTB_ODCB.getODCB11 : TBits_1; inline;
begin
  getODCB11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTB_ODCB.setODCB12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTB_ODCB.clearODCB12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTB_ODCB.setODCB12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTB_ODCB.getODCB12 : TBits_1; inline;
begin
  getODCB12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTB_ODCB.setODCB13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTB_ODCB.clearODCB13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTB_ODCB.setODCB13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTB_ODCB.getODCB13 : TBits_1; inline;
begin
  getODCB13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTB_ODCB.setODCB14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTB_ODCB.clearODCB14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTB_ODCB.setODCB14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTB_ODCB.getODCB14 : TBits_1; inline;
begin
  getODCB14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTB_ODCB.setODCB15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTB_ODCB.clearODCB15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTB_ODCB.setODCB15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTB_ODCB.getODCB15 : TBits_1; inline;
begin
  getODCB15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTB_ODCB.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTB_ODCB.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTC_TRISC.setTRISC12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTC_TRISC.clearTRISC12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTC_TRISC.setTRISC12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTC_TRISC.getTRISC12 : TBits_1; inline;
begin
  getTRISC12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTC_TRISC.setTRISC13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTC_TRISC.clearTRISC13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTC_TRISC.setTRISC13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTC_TRISC.getTRISC13 : TBits_1; inline;
begin
  getTRISC13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTC_TRISC.setTRISC14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTC_TRISC.clearTRISC14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTC_TRISC.setTRISC14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTC_TRISC.getTRISC14 : TBits_1; inline;
begin
  getTRISC14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTC_TRISC.setTRISC15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTC_TRISC.clearTRISC15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTC_TRISC.setTRISC15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTC_TRISC.getTRISC15 : TBits_1; inline;
begin
  getTRISC15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTC_TRISC.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTC_TRISC.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTC_PORTC.setRC12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTC_PORTC.clearRC12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTC_PORTC.setRC12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTC_PORTC.getRC12 : TBits_1; inline;
begin
  getRC12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTC_PORTC.setRC13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTC_PORTC.clearRC13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTC_PORTC.setRC13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTC_PORTC.getRC13 : TBits_1; inline;
begin
  getRC13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTC_PORTC.setRC14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTC_PORTC.clearRC14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTC_PORTC.setRC14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTC_PORTC.getRC14 : TBits_1; inline;
begin
  getRC14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTC_PORTC.setRC15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTC_PORTC.clearRC15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTC_PORTC.setRC15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTC_PORTC.getRC15 : TBits_1; inline;
begin
  getRC15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTC_PORTC.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTC_PORTC.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTC_LATC.setLATC12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTC_LATC.clearLATC12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTC_LATC.setLATC12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTC_LATC.getLATC12 : TBits_1; inline;
begin
  getLATC12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTC_LATC.setLATC13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTC_LATC.clearLATC13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTC_LATC.setLATC13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTC_LATC.getLATC13 : TBits_1; inline;
begin
  getLATC13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTC_LATC.setLATC14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTC_LATC.clearLATC14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTC_LATC.setLATC14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTC_LATC.getLATC14 : TBits_1; inline;
begin
  getLATC14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTC_LATC.setLATC15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTC_LATC.clearLATC15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTC_LATC.setLATC15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTC_LATC.getLATC15 : TBits_1; inline;
begin
  getLATC15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTC_LATC.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTC_LATC.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTC_ODCC.setODCC12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTC_ODCC.clearODCC12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTC_ODCC.setODCC12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTC_ODCC.getODCC12 : TBits_1; inline;
begin
  getODCC12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTC_ODCC.setODCC13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTC_ODCC.clearODCC13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTC_ODCC.setODCC13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTC_ODCC.getODCC13 : TBits_1; inline;
begin
  getODCC13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTC_ODCC.setODCC14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTC_ODCC.clearODCC14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTC_ODCC.setODCC14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTC_ODCC.getODCC14 : TBits_1; inline;
begin
  getODCC14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTC_ODCC.setODCC15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTC_ODCC.clearODCC15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTC_ODCC.setODCC15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTC_ODCC.getODCC15 : TBits_1; inline;
begin
  getODCC15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTC_ODCC.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTC_ODCC.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTD_TRISD.setTRISD0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTD_TRISD.clearTRISD0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTD_TRISD.setTRISD0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTD_TRISD.getTRISD0 : TBits_1; inline;
begin
  getTRISD0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTD_TRISD.setTRISD1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTD_TRISD.clearTRISD1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTD_TRISD.setTRISD1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTD_TRISD.getTRISD1 : TBits_1; inline;
begin
  getTRISD1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTD_TRISD.setTRISD2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTD_TRISD.clearTRISD2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTD_TRISD.setTRISD2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTD_TRISD.getTRISD2 : TBits_1; inline;
begin
  getTRISD2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTD_TRISD.setTRISD3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTD_TRISD.clearTRISD3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTD_TRISD.setTRISD3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTD_TRISD.getTRISD3 : TBits_1; inline;
begin
  getTRISD3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTD_TRISD.setTRISD4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTD_TRISD.clearTRISD4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTD_TRISD.setTRISD4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTD_TRISD.getTRISD4 : TBits_1; inline;
begin
  getTRISD4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTD_TRISD.setTRISD5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTD_TRISD.clearTRISD5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTD_TRISD.setTRISD5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTD_TRISD.getTRISD5 : TBits_1; inline;
begin
  getTRISD5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTD_TRISD.setTRISD6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTD_TRISD.clearTRISD6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTD_TRISD.setTRISD6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTD_TRISD.getTRISD6 : TBits_1; inline;
begin
  getTRISD6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTD_TRISD.setTRISD7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTD_TRISD.clearTRISD7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTD_TRISD.setTRISD7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTD_TRISD.getTRISD7 : TBits_1; inline;
begin
  getTRISD7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTD_TRISD.setTRISD8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTD_TRISD.clearTRISD8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTD_TRISD.setTRISD8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTD_TRISD.getTRISD8 : TBits_1; inline;
begin
  getTRISD8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTD_TRISD.setTRISD9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTD_TRISD.clearTRISD9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTD_TRISD.setTRISD9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTD_TRISD.getTRISD9 : TBits_1; inline;
begin
  getTRISD9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTD_TRISD.setTRISD10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTD_TRISD.clearTRISD10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTD_TRISD.setTRISD10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTD_TRISD.getTRISD10 : TBits_1; inline;
begin
  getTRISD10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTD_TRISD.setTRISD11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTD_TRISD.clearTRISD11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTD_TRISD.setTRISD11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTD_TRISD.getTRISD11 : TBits_1; inline;
begin
  getTRISD11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTD_TRISD.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTD_TRISD.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTD_PORTD.setRD0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTD_PORTD.clearRD0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTD_PORTD.setRD0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTD_PORTD.getRD0 : TBits_1; inline;
begin
  getRD0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTD_PORTD.setRD1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTD_PORTD.clearRD1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTD_PORTD.setRD1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTD_PORTD.getRD1 : TBits_1; inline;
begin
  getRD1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTD_PORTD.setRD2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTD_PORTD.clearRD2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTD_PORTD.setRD2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTD_PORTD.getRD2 : TBits_1; inline;
begin
  getRD2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTD_PORTD.setRD3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTD_PORTD.clearRD3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTD_PORTD.setRD3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTD_PORTD.getRD3 : TBits_1; inline;
begin
  getRD3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTD_PORTD.setRD4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTD_PORTD.clearRD4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTD_PORTD.setRD4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTD_PORTD.getRD4 : TBits_1; inline;
begin
  getRD4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTD_PORTD.setRD5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTD_PORTD.clearRD5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTD_PORTD.setRD5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTD_PORTD.getRD5 : TBits_1; inline;
begin
  getRD5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTD_PORTD.setRD6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTD_PORTD.clearRD6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTD_PORTD.setRD6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTD_PORTD.getRD6 : TBits_1; inline;
begin
  getRD6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTD_PORTD.setRD7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTD_PORTD.clearRD7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTD_PORTD.setRD7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTD_PORTD.getRD7 : TBits_1; inline;
begin
  getRD7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTD_PORTD.setRD8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTD_PORTD.clearRD8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTD_PORTD.setRD8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTD_PORTD.getRD8 : TBits_1; inline;
begin
  getRD8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTD_PORTD.setRD9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTD_PORTD.clearRD9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTD_PORTD.setRD9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTD_PORTD.getRD9 : TBits_1; inline;
begin
  getRD9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTD_PORTD.setRD10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTD_PORTD.clearRD10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTD_PORTD.setRD10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTD_PORTD.getRD10 : TBits_1; inline;
begin
  getRD10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTD_PORTD.setRD11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTD_PORTD.clearRD11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTD_PORTD.setRD11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTD_PORTD.getRD11 : TBits_1; inline;
begin
  getRD11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTD_PORTD.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTD_PORTD.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTD_LATD.setLATD0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTD_LATD.clearLATD0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTD_LATD.setLATD0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTD_LATD.getLATD0 : TBits_1; inline;
begin
  getLATD0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTD_LATD.setLATD1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTD_LATD.clearLATD1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTD_LATD.setLATD1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTD_LATD.getLATD1 : TBits_1; inline;
begin
  getLATD1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTD_LATD.setLATD2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTD_LATD.clearLATD2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTD_LATD.setLATD2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTD_LATD.getLATD2 : TBits_1; inline;
begin
  getLATD2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTD_LATD.setLATD3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTD_LATD.clearLATD3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTD_LATD.setLATD3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTD_LATD.getLATD3 : TBits_1; inline;
begin
  getLATD3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTD_LATD.setLATD4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTD_LATD.clearLATD4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTD_LATD.setLATD4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTD_LATD.getLATD4 : TBits_1; inline;
begin
  getLATD4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTD_LATD.setLATD5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTD_LATD.clearLATD5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTD_LATD.setLATD5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTD_LATD.getLATD5 : TBits_1; inline;
begin
  getLATD5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTD_LATD.setLATD6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTD_LATD.clearLATD6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTD_LATD.setLATD6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTD_LATD.getLATD6 : TBits_1; inline;
begin
  getLATD6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTD_LATD.setLATD7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTD_LATD.clearLATD7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTD_LATD.setLATD7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTD_LATD.getLATD7 : TBits_1; inline;
begin
  getLATD7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTD_LATD.setLATD8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTD_LATD.clearLATD8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTD_LATD.setLATD8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTD_LATD.getLATD8 : TBits_1; inline;
begin
  getLATD8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTD_LATD.setLATD9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTD_LATD.clearLATD9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTD_LATD.setLATD9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTD_LATD.getLATD9 : TBits_1; inline;
begin
  getLATD9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTD_LATD.setLATD10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTD_LATD.clearLATD10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTD_LATD.setLATD10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTD_LATD.getLATD10 : TBits_1; inline;
begin
  getLATD10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTD_LATD.setLATD11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTD_LATD.clearLATD11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTD_LATD.setLATD11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTD_LATD.getLATD11 : TBits_1; inline;
begin
  getLATD11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTD_LATD.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTD_LATD.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTD_ODCD.setODCD0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTD_ODCD.clearODCD0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTD_ODCD.setODCD0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTD_ODCD.getODCD0 : TBits_1; inline;
begin
  getODCD0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTD_ODCD.setODCD1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTD_ODCD.clearODCD1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTD_ODCD.setODCD1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTD_ODCD.getODCD1 : TBits_1; inline;
begin
  getODCD1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTD_ODCD.setODCD2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTD_ODCD.clearODCD2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTD_ODCD.setODCD2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTD_ODCD.getODCD2 : TBits_1; inline;
begin
  getODCD2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTD_ODCD.setODCD3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTD_ODCD.clearODCD3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTD_ODCD.setODCD3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTD_ODCD.getODCD3 : TBits_1; inline;
begin
  getODCD3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTD_ODCD.setODCD4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTD_ODCD.clearODCD4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTD_ODCD.setODCD4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTD_ODCD.getODCD4 : TBits_1; inline;
begin
  getODCD4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTD_ODCD.setODCD5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTD_ODCD.clearODCD5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTD_ODCD.setODCD5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTD_ODCD.getODCD5 : TBits_1; inline;
begin
  getODCD5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTD_ODCD.setODCD6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTD_ODCD.clearODCD6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTD_ODCD.setODCD6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTD_ODCD.getODCD6 : TBits_1; inline;
begin
  getODCD6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTD_ODCD.setODCD7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTD_ODCD.clearODCD7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTD_ODCD.setODCD7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTD_ODCD.getODCD7 : TBits_1; inline;
begin
  getODCD7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTD_ODCD.setODCD8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTD_ODCD.clearODCD8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTD_ODCD.setODCD8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTD_ODCD.getODCD8 : TBits_1; inline;
begin
  getODCD8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTD_ODCD.setODCD9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTD_ODCD.clearODCD9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTD_ODCD.setODCD9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTD_ODCD.getODCD9 : TBits_1; inline;
begin
  getODCD9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTD_ODCD.setODCD10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTD_ODCD.clearODCD10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTD_ODCD.setODCD10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTD_ODCD.getODCD10 : TBits_1; inline;
begin
  getODCD10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTD_ODCD.setODCD11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTD_ODCD.clearODCD11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTD_ODCD.setODCD11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTD_ODCD.getODCD11 : TBits_1; inline;
begin
  getODCD11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTD_ODCD.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTD_ODCD.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTE_TRISE.setTRISE0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTE_TRISE.clearTRISE0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTE_TRISE.setTRISE0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTE_TRISE.getTRISE0 : TBits_1; inline;
begin
  getTRISE0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTE_TRISE.setTRISE1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTE_TRISE.clearTRISE1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTE_TRISE.setTRISE1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTE_TRISE.getTRISE1 : TBits_1; inline;
begin
  getTRISE1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTE_TRISE.setTRISE2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTE_TRISE.clearTRISE2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTE_TRISE.setTRISE2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTE_TRISE.getTRISE2 : TBits_1; inline;
begin
  getTRISE2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTE_TRISE.setTRISE3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTE_TRISE.clearTRISE3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTE_TRISE.setTRISE3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTE_TRISE.getTRISE3 : TBits_1; inline;
begin
  getTRISE3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTE_TRISE.setTRISE4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTE_TRISE.clearTRISE4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTE_TRISE.setTRISE4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTE_TRISE.getTRISE4 : TBits_1; inline;
begin
  getTRISE4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTE_TRISE.setTRISE5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTE_TRISE.clearTRISE5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTE_TRISE.setTRISE5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTE_TRISE.getTRISE5 : TBits_1; inline;
begin
  getTRISE5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTE_TRISE.setTRISE6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTE_TRISE.clearTRISE6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTE_TRISE.setTRISE6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTE_TRISE.getTRISE6 : TBits_1; inline;
begin
  getTRISE6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTE_TRISE.setTRISE7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTE_TRISE.clearTRISE7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTE_TRISE.setTRISE7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTE_TRISE.getTRISE7 : TBits_1; inline;
begin
  getTRISE7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTE_TRISE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTE_TRISE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTE_PORTE.setRE0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTE_PORTE.clearRE0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTE_PORTE.setRE0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTE_PORTE.getRE0 : TBits_1; inline;
begin
  getRE0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTE_PORTE.setRE1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTE_PORTE.clearRE1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTE_PORTE.setRE1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTE_PORTE.getRE1 : TBits_1; inline;
begin
  getRE1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTE_PORTE.setRE2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTE_PORTE.clearRE2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTE_PORTE.setRE2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTE_PORTE.getRE2 : TBits_1; inline;
begin
  getRE2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTE_PORTE.setRE3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTE_PORTE.clearRE3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTE_PORTE.setRE3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTE_PORTE.getRE3 : TBits_1; inline;
begin
  getRE3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTE_PORTE.setRE4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTE_PORTE.clearRE4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTE_PORTE.setRE4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTE_PORTE.getRE4 : TBits_1; inline;
begin
  getRE4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTE_PORTE.setRE5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTE_PORTE.clearRE5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTE_PORTE.setRE5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTE_PORTE.getRE5 : TBits_1; inline;
begin
  getRE5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTE_PORTE.setRE6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTE_PORTE.clearRE6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTE_PORTE.setRE6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTE_PORTE.getRE6 : TBits_1; inline;
begin
  getRE6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTE_PORTE.setRE7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTE_PORTE.clearRE7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTE_PORTE.setRE7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTE_PORTE.getRE7 : TBits_1; inline;
begin
  getRE7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTE_PORTE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTE_PORTE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTE_LATE.setLATE0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTE_LATE.clearLATE0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTE_LATE.setLATE0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTE_LATE.getLATE0 : TBits_1; inline;
begin
  getLATE0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTE_LATE.setLATE1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTE_LATE.clearLATE1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTE_LATE.setLATE1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTE_LATE.getLATE1 : TBits_1; inline;
begin
  getLATE1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTE_LATE.setLATE2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTE_LATE.clearLATE2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTE_LATE.setLATE2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTE_LATE.getLATE2 : TBits_1; inline;
begin
  getLATE2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTE_LATE.setLATE3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTE_LATE.clearLATE3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTE_LATE.setLATE3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTE_LATE.getLATE3 : TBits_1; inline;
begin
  getLATE3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTE_LATE.setLATE4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTE_LATE.clearLATE4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTE_LATE.setLATE4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTE_LATE.getLATE4 : TBits_1; inline;
begin
  getLATE4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTE_LATE.setLATE5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTE_LATE.clearLATE5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTE_LATE.setLATE5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTE_LATE.getLATE5 : TBits_1; inline;
begin
  getLATE5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTE_LATE.setLATE6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTE_LATE.clearLATE6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTE_LATE.setLATE6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTE_LATE.getLATE6 : TBits_1; inline;
begin
  getLATE6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTE_LATE.setLATE7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTE_LATE.clearLATE7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTE_LATE.setLATE7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTE_LATE.getLATE7 : TBits_1; inline;
begin
  getLATE7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTE_LATE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTE_LATE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTE_ODCE.setODCE0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTE_ODCE.clearODCE0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTE_ODCE.setODCE0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTE_ODCE.getODCE0 : TBits_1; inline;
begin
  getODCE0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTE_ODCE.setODCE1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTE_ODCE.clearODCE1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTE_ODCE.setODCE1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTE_ODCE.getODCE1 : TBits_1; inline;
begin
  getODCE1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTE_ODCE.setODCE2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTE_ODCE.clearODCE2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTE_ODCE.setODCE2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTE_ODCE.getODCE2 : TBits_1; inline;
begin
  getODCE2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTE_ODCE.setODCE3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTE_ODCE.clearODCE3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTE_ODCE.setODCE3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTE_ODCE.getODCE3 : TBits_1; inline;
begin
  getODCE3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTE_ODCE.setODCE4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTE_ODCE.clearODCE4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTE_ODCE.setODCE4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTE_ODCE.getODCE4 : TBits_1; inline;
begin
  getODCE4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTE_ODCE.setODCE5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTE_ODCE.clearODCE5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTE_ODCE.setODCE5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTE_ODCE.getODCE5 : TBits_1; inline;
begin
  getODCE5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTE_ODCE.setODCE6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTE_ODCE.clearODCE6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTE_ODCE.setODCE6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTE_ODCE.getODCE6 : TBits_1; inline;
begin
  getODCE6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTE_ODCE.setODCE7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTE_ODCE.clearODCE7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTE_ODCE.setODCE7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTE_ODCE.getODCE7 : TBits_1; inline;
begin
  getODCE7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTE_ODCE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTE_ODCE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTF_TRISF.setTRISF0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTF_TRISF.clearTRISF0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTF_TRISF.setTRISF0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTF_TRISF.getTRISF0 : TBits_1; inline;
begin
  getTRISF0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTF_TRISF.setTRISF1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTF_TRISF.clearTRISF1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTF_TRISF.setTRISF1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTF_TRISF.getTRISF1 : TBits_1; inline;
begin
  getTRISF1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTF_TRISF.setTRISF2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTF_TRISF.clearTRISF2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTF_TRISF.setTRISF2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTF_TRISF.getTRISF2 : TBits_1; inline;
begin
  getTRISF2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTF_TRISF.setTRISF3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTF_TRISF.clearTRISF3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTF_TRISF.setTRISF3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTF_TRISF.getTRISF3 : TBits_1; inline;
begin
  getTRISF3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTF_TRISF.setTRISF4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTF_TRISF.clearTRISF4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTF_TRISF.setTRISF4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTF_TRISF.getTRISF4 : TBits_1; inline;
begin
  getTRISF4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTF_TRISF.setTRISF5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTF_TRISF.clearTRISF5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTF_TRISF.setTRISF5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTF_TRISF.getTRISF5 : TBits_1; inline;
begin
  getTRISF5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTF_TRISF.setTRISF6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTF_TRISF.clearTRISF6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTF_TRISF.setTRISF6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTF_TRISF.getTRISF6 : TBits_1; inline;
begin
  getTRISF6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTF_TRISF.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTF_TRISF.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTF_PORTF.setRF0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTF_PORTF.clearRF0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTF_PORTF.setRF0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTF_PORTF.getRF0 : TBits_1; inline;
begin
  getRF0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTF_PORTF.setRF1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTF_PORTF.clearRF1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTF_PORTF.setRF1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTF_PORTF.getRF1 : TBits_1; inline;
begin
  getRF1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTF_PORTF.setRF2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTF_PORTF.clearRF2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTF_PORTF.setRF2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTF_PORTF.getRF2 : TBits_1; inline;
begin
  getRF2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTF_PORTF.setRF3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTF_PORTF.clearRF3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTF_PORTF.setRF3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTF_PORTF.getRF3 : TBits_1; inline;
begin
  getRF3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTF_PORTF.setRF4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTF_PORTF.clearRF4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTF_PORTF.setRF4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTF_PORTF.getRF4 : TBits_1; inline;
begin
  getRF4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTF_PORTF.setRF5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTF_PORTF.clearRF5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTF_PORTF.setRF5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTF_PORTF.getRF5 : TBits_1; inline;
begin
  getRF5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTF_PORTF.setRF6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTF_PORTF.clearRF6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTF_PORTF.setRF6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTF_PORTF.getRF6 : TBits_1; inline;
begin
  getRF6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTF_PORTF.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTF_PORTF.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTF_LATF.setLATF0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTF_LATF.clearLATF0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTF_LATF.setLATF0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTF_LATF.getLATF0 : TBits_1; inline;
begin
  getLATF0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTF_LATF.setLATF1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTF_LATF.clearLATF1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTF_LATF.setLATF1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTF_LATF.getLATF1 : TBits_1; inline;
begin
  getLATF1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTF_LATF.setLATF2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTF_LATF.clearLATF2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTF_LATF.setLATF2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTF_LATF.getLATF2 : TBits_1; inline;
begin
  getLATF2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTF_LATF.setLATF3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTF_LATF.clearLATF3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTF_LATF.setLATF3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTF_LATF.getLATF3 : TBits_1; inline;
begin
  getLATF3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTF_LATF.setLATF4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTF_LATF.clearLATF4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTF_LATF.setLATF4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTF_LATF.getLATF4 : TBits_1; inline;
begin
  getLATF4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTF_LATF.setLATF5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTF_LATF.clearLATF5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTF_LATF.setLATF5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTF_LATF.getLATF5 : TBits_1; inline;
begin
  getLATF5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTF_LATF.setLATF6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTF_LATF.clearLATF6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTF_LATF.setLATF6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTF_LATF.getLATF6 : TBits_1; inline;
begin
  getLATF6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTF_LATF.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTF_LATF.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTF_ODCF.setODCF0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTF_ODCF.clearODCF0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTF_ODCF.setODCF0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTF_ODCF.getODCF0 : TBits_1; inline;
begin
  getODCF0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTF_ODCF.setODCF1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTF_ODCF.clearODCF1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTF_ODCF.setODCF1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTF_ODCF.getODCF1 : TBits_1; inline;
begin
  getODCF1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTF_ODCF.setODCF2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTF_ODCF.clearODCF2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTF_ODCF.setODCF2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTF_ODCF.getODCF2 : TBits_1; inline;
begin
  getODCF2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTF_ODCF.setODCF3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTF_ODCF.clearODCF3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTF_ODCF.setODCF3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTF_ODCF.getODCF3 : TBits_1; inline;
begin
  getODCF3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTF_ODCF.setODCF4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTF_ODCF.clearODCF4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTF_ODCF.setODCF4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTF_ODCF.getODCF4 : TBits_1; inline;
begin
  getODCF4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTF_ODCF.setODCF5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTF_ODCF.clearODCF5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTF_ODCF.setODCF5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTF_ODCF.getODCF5 : TBits_1; inline;
begin
  getODCF5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTF_ODCF.setODCF6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTF_ODCF.clearODCF6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTF_ODCF.setODCF6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTF_ODCF.getODCF6 : TBits_1; inline;
begin
  getODCF6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTF_ODCF.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTF_ODCF.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTG_TRISG.setTRISG2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTG_TRISG.clearTRISG2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTG_TRISG.setTRISG2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTG_TRISG.getTRISG2 : TBits_1; inline;
begin
  getTRISG2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTG_TRISG.setTRISG3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTG_TRISG.clearTRISG3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTG_TRISG.setTRISG3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTG_TRISG.getTRISG3 : TBits_1; inline;
begin
  getTRISG3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTG_TRISG.setTRISG6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTG_TRISG.clearTRISG6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTG_TRISG.setTRISG6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTG_TRISG.getTRISG6 : TBits_1; inline;
begin
  getTRISG6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTG_TRISG.setTRISG7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTG_TRISG.clearTRISG7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTG_TRISG.setTRISG7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTG_TRISG.getTRISG7 : TBits_1; inline;
begin
  getTRISG7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTG_TRISG.setTRISG8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTG_TRISG.clearTRISG8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTG_TRISG.setTRISG8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTG_TRISG.getTRISG8 : TBits_1; inline;
begin
  getTRISG8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTG_TRISG.setTRISG9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTG_TRISG.clearTRISG9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTG_TRISG.setTRISG9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTG_TRISG.getTRISG9 : TBits_1; inline;
begin
  getTRISG9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTG_TRISG.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTG_TRISG.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTG_PORTG.setRG2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTG_PORTG.clearRG2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTG_PORTG.setRG2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTG_PORTG.getRG2 : TBits_1; inline;
begin
  getRG2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTG_PORTG.setRG3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTG_PORTG.clearRG3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTG_PORTG.setRG3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTG_PORTG.getRG3 : TBits_1; inline;
begin
  getRG3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTG_PORTG.setRG6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTG_PORTG.clearRG6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTG_PORTG.setRG6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTG_PORTG.getRG6 : TBits_1; inline;
begin
  getRG6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTG_PORTG.setRG7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTG_PORTG.clearRG7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTG_PORTG.setRG7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTG_PORTG.getRG7 : TBits_1; inline;
begin
  getRG7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTG_PORTG.setRG8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTG_PORTG.clearRG8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTG_PORTG.setRG8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTG_PORTG.getRG8 : TBits_1; inline;
begin
  getRG8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTG_PORTG.setRG9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTG_PORTG.clearRG9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTG_PORTG.setRG9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTG_PORTG.getRG9 : TBits_1; inline;
begin
  getRG9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTG_PORTG.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTG_PORTG.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTG_LATG.setLATG2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTG_LATG.clearLATG2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTG_LATG.setLATG2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTG_LATG.getLATG2 : TBits_1; inline;
begin
  getLATG2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTG_LATG.setLATG3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTG_LATG.clearLATG3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTG_LATG.setLATG3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTG_LATG.getLATG3 : TBits_1; inline;
begin
  getLATG3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTG_LATG.setLATG6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTG_LATG.clearLATG6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTG_LATG.setLATG6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTG_LATG.getLATG6 : TBits_1; inline;
begin
  getLATG6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTG_LATG.setLATG7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTG_LATG.clearLATG7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTG_LATG.setLATG7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTG_LATG.getLATG7 : TBits_1; inline;
begin
  getLATG7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTG_LATG.setLATG8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTG_LATG.clearLATG8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTG_LATG.setLATG8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTG_LATG.getLATG8 : TBits_1; inline;
begin
  getLATG8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTG_LATG.setLATG9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTG_LATG.clearLATG9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTG_LATG.setLATG9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTG_LATG.getLATG9 : TBits_1; inline;
begin
  getLATG9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTG_LATG.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTG_LATG.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTG_ODCG.setODCG2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTG_ODCG.clearODCG2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTG_ODCG.setODCG2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTG_ODCG.getODCG2 : TBits_1; inline;
begin
  getODCG2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTG_ODCG.setODCG3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTG_ODCG.clearODCG3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTG_ODCG.setODCG3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTG_ODCG.getODCG3 : TBits_1; inline;
begin
  getODCG3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTG_ODCG.setODCG6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTG_ODCG.clearODCG6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTG_ODCG.setODCG6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTG_ODCG.getODCG6 : TBits_1; inline;
begin
  getODCG6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTG_ODCG.setODCG7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTG_ODCG.clearODCG7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTG_ODCG.setODCG7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTG_ODCG.getODCG7 : TBits_1; inline;
begin
  getODCG7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTG_ODCG.setODCG8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTG_ODCG.clearODCG8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTG_ODCG.setODCG8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTG_ODCG.getODCG8 : TBits_1; inline;
begin
  getODCG8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTG_ODCG.setODCG9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTG_ODCG.clearODCG9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTG_ODCG.setODCG9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTG_ODCG.getODCG9 : TBits_1; inline;
begin
  getODCG9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTG_ODCG.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTG_ODCG.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTG_CNCON.setSIDL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTG_CNCON.clearSIDL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTG_CNCON.setSIDL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTG_CNCON.getSIDL : TBits_1; inline;
begin
  getSIDL := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTG_CNCON.setON; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTG_CNCON.clearON; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTG_CNCON.setON(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTG_CNCON.getON : TBits_1; inline;
begin
  getON := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTG_CNCON.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTG_CNCON.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTG_CNEN.setCNEN0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTG_CNEN.clearCNEN0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTG_CNEN.setCNEN0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTG_CNEN.getCNEN0 : TBits_1; inline;
begin
  getCNEN0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTG_CNEN.setCNEN1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTG_CNEN.clearCNEN1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTG_CNEN.setCNEN1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTG_CNEN.getCNEN1 : TBits_1; inline;
begin
  getCNEN1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTG_CNEN.setCNEN2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTG_CNEN.clearCNEN2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTG_CNEN.setCNEN2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTG_CNEN.getCNEN2 : TBits_1; inline;
begin
  getCNEN2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTG_CNEN.setCNEN3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTG_CNEN.clearCNEN3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTG_CNEN.setCNEN3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTG_CNEN.getCNEN3 : TBits_1; inline;
begin
  getCNEN3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTG_CNEN.setCNEN4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTG_CNEN.clearCNEN4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTG_CNEN.setCNEN4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTG_CNEN.getCNEN4 : TBits_1; inline;
begin
  getCNEN4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTG_CNEN.setCNEN5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTG_CNEN.clearCNEN5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTG_CNEN.setCNEN5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTG_CNEN.getCNEN5 : TBits_1; inline;
begin
  getCNEN5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTG_CNEN.setCNEN6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTG_CNEN.clearCNEN6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTG_CNEN.setCNEN6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTG_CNEN.getCNEN6 : TBits_1; inline;
begin
  getCNEN6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTG_CNEN.setCNEN7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTG_CNEN.clearCNEN7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTG_CNEN.setCNEN7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTG_CNEN.getCNEN7 : TBits_1; inline;
begin
  getCNEN7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTG_CNEN.setCNEN8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTG_CNEN.clearCNEN8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTG_CNEN.setCNEN8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTG_CNEN.getCNEN8 : TBits_1; inline;
begin
  getCNEN8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTG_CNEN.setCNEN9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTG_CNEN.clearCNEN9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTG_CNEN.setCNEN9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTG_CNEN.getCNEN9 : TBits_1; inline;
begin
  getCNEN9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTG_CNEN.setCNEN10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTG_CNEN.clearCNEN10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTG_CNEN.setCNEN10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTG_CNEN.getCNEN10 : TBits_1; inline;
begin
  getCNEN10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTG_CNEN.setCNEN11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTG_CNEN.clearCNEN11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTG_CNEN.setCNEN11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTG_CNEN.getCNEN11 : TBits_1; inline;
begin
  getCNEN11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTG_CNEN.setCNEN12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTG_CNEN.clearCNEN12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTG_CNEN.setCNEN12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTG_CNEN.getCNEN12 : TBits_1; inline;
begin
  getCNEN12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTG_CNEN.setCNEN13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTG_CNEN.clearCNEN13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTG_CNEN.setCNEN13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTG_CNEN.getCNEN13 : TBits_1; inline;
begin
  getCNEN13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTG_CNEN.setCNEN14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTG_CNEN.clearCNEN14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTG_CNEN.setCNEN14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTG_CNEN.getCNEN14 : TBits_1; inline;
begin
  getCNEN14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTG_CNEN.setCNEN15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTG_CNEN.clearCNEN15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTG_CNEN.setCNEN15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTG_CNEN.getCNEN15 : TBits_1; inline;
begin
  getCNEN15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTG_CNEN.setCNEN16; inline;
begin
  pTDefRegMap(@Self)^.&set := $00010000;
end;
procedure TPORTG_CNEN.clearCNEN16; inline;
begin
  pTDefRegMap(@Self)^.clr := $00010000;
end;
procedure TPORTG_CNEN.setCNEN16(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00010000
  else
    pTDefRegMap(@Self)^.&set := $00010000;
end;
function  TPORTG_CNEN.getCNEN16 : TBits_1; inline;
begin
  getCNEN16 := (pTDefRegMap(@Self)^.val and $00010000) shr 16;
end;
procedure TPORTG_CNEN.setCNEN17; inline;
begin
  pTDefRegMap(@Self)^.&set := $00020000;
end;
procedure TPORTG_CNEN.clearCNEN17; inline;
begin
  pTDefRegMap(@Self)^.clr := $00020000;
end;
procedure TPORTG_CNEN.setCNEN17(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00020000
  else
    pTDefRegMap(@Self)^.&set := $00020000;
end;
function  TPORTG_CNEN.getCNEN17 : TBits_1; inline;
begin
  getCNEN17 := (pTDefRegMap(@Self)^.val and $00020000) shr 17;
end;
procedure TPORTG_CNEN.setCNEN18; inline;
begin
  pTDefRegMap(@Self)^.&set := $00040000;
end;
procedure TPORTG_CNEN.clearCNEN18; inline;
begin
  pTDefRegMap(@Self)^.clr := $00040000;
end;
procedure TPORTG_CNEN.setCNEN18(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00040000
  else
    pTDefRegMap(@Self)^.&set := $00040000;
end;
function  TPORTG_CNEN.getCNEN18 : TBits_1; inline;
begin
  getCNEN18 := (pTDefRegMap(@Self)^.val and $00040000) shr 18;
end;
procedure TPORTG_CNEN.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTG_CNEN.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TPORTG_CNPUE.setCNPUE0; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000001;
end;
procedure TPORTG_CNPUE.clearCNPUE0; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000001;
end;
procedure TPORTG_CNPUE.setCNPUE0(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000001
  else
    pTDefRegMap(@Self)^.&set := $00000001;
end;
function  TPORTG_CNPUE.getCNPUE0 : TBits_1; inline;
begin
  getCNPUE0 := (pTDefRegMap(@Self)^.val and $00000001) shr 0;
end;
procedure TPORTG_CNPUE.setCNPUE1; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000002;
end;
procedure TPORTG_CNPUE.clearCNPUE1; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000002;
end;
procedure TPORTG_CNPUE.setCNPUE1(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000002
  else
    pTDefRegMap(@Self)^.&set := $00000002;
end;
function  TPORTG_CNPUE.getCNPUE1 : TBits_1; inline;
begin
  getCNPUE1 := (pTDefRegMap(@Self)^.val and $00000002) shr 1;
end;
procedure TPORTG_CNPUE.setCNPUE2; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000004;
end;
procedure TPORTG_CNPUE.clearCNPUE2; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000004;
end;
procedure TPORTG_CNPUE.setCNPUE2(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000004
  else
    pTDefRegMap(@Self)^.&set := $00000004;
end;
function  TPORTG_CNPUE.getCNPUE2 : TBits_1; inline;
begin
  getCNPUE2 := (pTDefRegMap(@Self)^.val and $00000004) shr 2;
end;
procedure TPORTG_CNPUE.setCNPUE3; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TPORTG_CNPUE.clearCNPUE3; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TPORTG_CNPUE.setCNPUE3(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TPORTG_CNPUE.getCNPUE3 : TBits_1; inline;
begin
  getCNPUE3 := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TPORTG_CNPUE.setCNPUE4; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000010;
end;
procedure TPORTG_CNPUE.clearCNPUE4; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000010;
end;
procedure TPORTG_CNPUE.setCNPUE4(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000010
  else
    pTDefRegMap(@Self)^.&set := $00000010;
end;
function  TPORTG_CNPUE.getCNPUE4 : TBits_1; inline;
begin
  getCNPUE4 := (pTDefRegMap(@Self)^.val and $00000010) shr 4;
end;
procedure TPORTG_CNPUE.setCNPUE5; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TPORTG_CNPUE.clearCNPUE5; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TPORTG_CNPUE.setCNPUE5(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TPORTG_CNPUE.getCNPUE5 : TBits_1; inline;
begin
  getCNPUE5 := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TPORTG_CNPUE.setCNPUE6; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000040;
end;
procedure TPORTG_CNPUE.clearCNPUE6; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000040;
end;
procedure TPORTG_CNPUE.setCNPUE6(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000040
  else
    pTDefRegMap(@Self)^.&set := $00000040;
end;
function  TPORTG_CNPUE.getCNPUE6 : TBits_1; inline;
begin
  getCNPUE6 := (pTDefRegMap(@Self)^.val and $00000040) shr 6;
end;
procedure TPORTG_CNPUE.setCNPUE7; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TPORTG_CNPUE.clearCNPUE7; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TPORTG_CNPUE.setCNPUE7(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TPORTG_CNPUE.getCNPUE7 : TBits_1; inline;
begin
  getCNPUE7 := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TPORTG_CNPUE.setCNPUE8; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000100;
end;
procedure TPORTG_CNPUE.clearCNPUE8; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000100;
end;
procedure TPORTG_CNPUE.setCNPUE8(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000100
  else
    pTDefRegMap(@Self)^.&set := $00000100;
end;
function  TPORTG_CNPUE.getCNPUE8 : TBits_1; inline;
begin
  getCNPUE8 := (pTDefRegMap(@Self)^.val and $00000100) shr 8;
end;
procedure TPORTG_CNPUE.setCNPUE9; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000200;
end;
procedure TPORTG_CNPUE.clearCNPUE9; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000200;
end;
procedure TPORTG_CNPUE.setCNPUE9(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000200
  else
    pTDefRegMap(@Self)^.&set := $00000200;
end;
function  TPORTG_CNPUE.getCNPUE9 : TBits_1; inline;
begin
  getCNPUE9 := (pTDefRegMap(@Self)^.val and $00000200) shr 9;
end;
procedure TPORTG_CNPUE.setCNPUE10; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TPORTG_CNPUE.clearCNPUE10; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TPORTG_CNPUE.setCNPUE10(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TPORTG_CNPUE.getCNPUE10 : TBits_1; inline;
begin
  getCNPUE10 := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TPORTG_CNPUE.setCNPUE11; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000800;
end;
procedure TPORTG_CNPUE.clearCNPUE11; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000800;
end;
procedure TPORTG_CNPUE.setCNPUE11(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000800
  else
    pTDefRegMap(@Self)^.&set := $00000800;
end;
function  TPORTG_CNPUE.getCNPUE11 : TBits_1; inline;
begin
  getCNPUE11 := (pTDefRegMap(@Self)^.val and $00000800) shr 11;
end;
procedure TPORTG_CNPUE.setCNPUE12; inline;
begin
  pTDefRegMap(@Self)^.&set := $00001000;
end;
procedure TPORTG_CNPUE.clearCNPUE12; inline;
begin
  pTDefRegMap(@Self)^.clr := $00001000;
end;
procedure TPORTG_CNPUE.setCNPUE12(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00001000
  else
    pTDefRegMap(@Self)^.&set := $00001000;
end;
function  TPORTG_CNPUE.getCNPUE12 : TBits_1; inline;
begin
  getCNPUE12 := (pTDefRegMap(@Self)^.val and $00001000) shr 12;
end;
procedure TPORTG_CNPUE.setCNPUE13; inline;
begin
  pTDefRegMap(@Self)^.&set := $00002000;
end;
procedure TPORTG_CNPUE.clearCNPUE13; inline;
begin
  pTDefRegMap(@Self)^.clr := $00002000;
end;
procedure TPORTG_CNPUE.setCNPUE13(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00002000
  else
    pTDefRegMap(@Self)^.&set := $00002000;
end;
function  TPORTG_CNPUE.getCNPUE13 : TBits_1; inline;
begin
  getCNPUE13 := (pTDefRegMap(@Self)^.val and $00002000) shr 13;
end;
procedure TPORTG_CNPUE.setCNPUE14; inline;
begin
  pTDefRegMap(@Self)^.&set := $00004000;
end;
procedure TPORTG_CNPUE.clearCNPUE14; inline;
begin
  pTDefRegMap(@Self)^.clr := $00004000;
end;
procedure TPORTG_CNPUE.setCNPUE14(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00004000
  else
    pTDefRegMap(@Self)^.&set := $00004000;
end;
function  TPORTG_CNPUE.getCNPUE14 : TBits_1; inline;
begin
  getCNPUE14 := (pTDefRegMap(@Self)^.val and $00004000) shr 14;
end;
procedure TPORTG_CNPUE.setCNPUE15; inline;
begin
  pTDefRegMap(@Self)^.&set := $00008000;
end;
procedure TPORTG_CNPUE.clearCNPUE15; inline;
begin
  pTDefRegMap(@Self)^.clr := $00008000;
end;
procedure TPORTG_CNPUE.setCNPUE15(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00008000
  else
    pTDefRegMap(@Self)^.&set := $00008000;
end;
function  TPORTG_CNPUE.getCNPUE15 : TBits_1; inline;
begin
  getCNPUE15 := (pTDefRegMap(@Self)^.val and $00008000) shr 15;
end;
procedure TPORTG_CNPUE.setCNPUE16; inline;
begin
  pTDefRegMap(@Self)^.&set := $00010000;
end;
procedure TPORTG_CNPUE.clearCNPUE16; inline;
begin
  pTDefRegMap(@Self)^.clr := $00010000;
end;
procedure TPORTG_CNPUE.setCNPUE16(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00010000
  else
    pTDefRegMap(@Self)^.&set := $00010000;
end;
function  TPORTG_CNPUE.getCNPUE16 : TBits_1; inline;
begin
  getCNPUE16 := (pTDefRegMap(@Self)^.val and $00010000) shr 16;
end;
procedure TPORTG_CNPUE.setCNPUE17; inline;
begin
  pTDefRegMap(@Self)^.&set := $00020000;
end;
procedure TPORTG_CNPUE.clearCNPUE17; inline;
begin
  pTDefRegMap(@Self)^.clr := $00020000;
end;
procedure TPORTG_CNPUE.setCNPUE17(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00020000
  else
    pTDefRegMap(@Self)^.&set := $00020000;
end;
function  TPORTG_CNPUE.getCNPUE17 : TBits_1; inline;
begin
  getCNPUE17 := (pTDefRegMap(@Self)^.val and $00020000) shr 17;
end;
procedure TPORTG_CNPUE.setCNPUE18; inline;
begin
  pTDefRegMap(@Self)^.&set := $00040000;
end;
procedure TPORTG_CNPUE.clearCNPUE18; inline;
begin
  pTDefRegMap(@Self)^.clr := $00040000;
end;
procedure TPORTG_CNPUE.setCNPUE18(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00040000
  else
    pTDefRegMap(@Self)^.&set := $00040000;
end;
function  TPORTG_CNPUE.getCNPUE18 : TBits_1; inline;
begin
  getCNPUE18 := (pTDefRegMap(@Self)^.val and $00040000) shr 18;
end;
procedure TPORTG_CNPUE.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TPORTG_CNPUE.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TDEVCFG_DEVCFG3.setUSERID(thebits : TBits_16); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF0000 or ( thebits shl 0 );
end;
function  TDEVCFG_DEVCFG3.getUSERID : TBits_16; inline;
begin
  getUSERID := (pTDefRegMap(@Self)^.val and $0000FFFF) shr 0;
end;
procedure TDEVCFG_DEVCFG3.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TDEVCFG_DEVCFG3.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TDEVCFG_DEVCFG2.setFPLLIDIV(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TDEVCFG_DEVCFG2.getFPLLIDIV : TBits_3; inline;
begin
  getFPLLIDIV := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TDEVCFG_DEVCFG2.setFPLLMUL(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFF8F or ( thebits shl 4 );
end;
function  TDEVCFG_DEVCFG2.getFPLLMUL : TBits_3; inline;
begin
  getFPLLMUL := (pTDefRegMap(@Self)^.val and $00000070) shr 4;
end;
procedure TDEVCFG_DEVCFG2.setFPLLODIV(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFF8FFFF or ( thebits shl 16 );
end;
function  TDEVCFG_DEVCFG2.getFPLLODIV : TBits_3; inline;
begin
  getFPLLODIV := (pTDefRegMap(@Self)^.val and $00070000) shr 16;
end;
procedure TDEVCFG_DEVCFG2.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TDEVCFG_DEVCFG2.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TDEVCFG_DEVCFG1.setFNOSC(thebits : TBits_3); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFF8 or ( thebits shl 0 );
end;
function  TDEVCFG_DEVCFG1.getFNOSC : TBits_3; inline;
begin
  getFNOSC := (pTDefRegMap(@Self)^.val and $00000007) shr 0;
end;
procedure TDEVCFG_DEVCFG1.setFSOSCEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000020;
end;
procedure TDEVCFG_DEVCFG1.clearFSOSCEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000020;
end;
procedure TDEVCFG_DEVCFG1.setFSOSCEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000020
  else
    pTDefRegMap(@Self)^.&set := $00000020;
end;
function  TDEVCFG_DEVCFG1.getFSOSCEN : TBits_1; inline;
begin
  getFSOSCEN := (pTDefRegMap(@Self)^.val and $00000020) shr 5;
end;
procedure TDEVCFG_DEVCFG1.setIESO; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000080;
end;
procedure TDEVCFG_DEVCFG1.clearIESO; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000080;
end;
procedure TDEVCFG_DEVCFG1.setIESO(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000080
  else
    pTDefRegMap(@Self)^.&set := $00000080;
end;
function  TDEVCFG_DEVCFG1.getIESO : TBits_1; inline;
begin
  getIESO := (pTDefRegMap(@Self)^.val and $00000080) shr 7;
end;
procedure TDEVCFG_DEVCFG1.setPOSCMOD(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFCFF or ( thebits shl 8 );
end;
function  TDEVCFG_DEVCFG1.getPOSCMOD : TBits_2; inline;
begin
  getPOSCMOD := (pTDefRegMap(@Self)^.val and $00000300) shr 8;
end;
procedure TDEVCFG_DEVCFG1.setOSCIOFNC; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000400;
end;
procedure TDEVCFG_DEVCFG1.clearOSCIOFNC; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000400;
end;
procedure TDEVCFG_DEVCFG1.setOSCIOFNC(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000400
  else
    pTDefRegMap(@Self)^.&set := $00000400;
end;
function  TDEVCFG_DEVCFG1.getOSCIOFNC : TBits_1; inline;
begin
  getOSCIOFNC := (pTDefRegMap(@Self)^.val and $00000400) shr 10;
end;
procedure TDEVCFG_DEVCFG1.setFPBDIV(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFCFFF or ( thebits shl 12 );
end;
function  TDEVCFG_DEVCFG1.getFPBDIV : TBits_2; inline;
begin
  getFPBDIV := (pTDefRegMap(@Self)^.val and $00003000) shr 12;
end;
procedure TDEVCFG_DEVCFG1.setFCKSM(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFF3FFF or ( thebits shl 14 );
end;
function  TDEVCFG_DEVCFG1.getFCKSM : TBits_2; inline;
begin
  getFCKSM := (pTDefRegMap(@Self)^.val and $0000C000) shr 14;
end;
procedure TDEVCFG_DEVCFG1.setWDTPS(thebits : TBits_5); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFE0FFFF or ( thebits shl 16 );
end;
function  TDEVCFG_DEVCFG1.getWDTPS : TBits_5; inline;
begin
  getWDTPS := (pTDefRegMap(@Self)^.val and $001F0000) shr 16;
end;
procedure TDEVCFG_DEVCFG1.setFWDTEN; inline;
begin
  pTDefRegMap(@Self)^.&set := $00800000;
end;
procedure TDEVCFG_DEVCFG1.clearFWDTEN; inline;
begin
  pTDefRegMap(@Self)^.clr := $00800000;
end;
procedure TDEVCFG_DEVCFG1.setFWDTEN(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00800000
  else
    pTDefRegMap(@Self)^.&set := $00800000;
end;
function  TDEVCFG_DEVCFG1.getFWDTEN : TBits_1; inline;
begin
  getFWDTEN := (pTDefRegMap(@Self)^.val and $00800000) shr 23;
end;
procedure TDEVCFG_DEVCFG1.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TDEVCFG_DEVCFG1.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
procedure TDEVCFG_DEVCFG0.setDEBUG(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFFC or ( thebits shl 0 );
end;
function  TDEVCFG_DEVCFG0.getDEBUG : TBits_2; inline;
begin
  getDEBUG := (pTDefRegMap(@Self)^.val and $00000003) shr 0;
end;
procedure TDEVCFG_DEVCFG0.setICESEL; inline;
begin
  pTDefRegMap(@Self)^.&set := $00000008;
end;
procedure TDEVCFG_DEVCFG0.clearICESEL; inline;
begin
  pTDefRegMap(@Self)^.clr := $00000008;
end;
procedure TDEVCFG_DEVCFG0.setICESEL(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $00000008
  else
    pTDefRegMap(@Self)^.&set := $00000008;
end;
function  TDEVCFG_DEVCFG0.getICESEL : TBits_1; inline;
begin
  getICESEL := (pTDefRegMap(@Self)^.val and $00000008) shr 3;
end;
procedure TDEVCFG_DEVCFG0.setPWP(thebits : TBits_8); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFF00FFF or ( thebits shl 12 );
end;
function  TDEVCFG_DEVCFG0.getPWP : TBits_8; inline;
begin
  getPWP := (pTDefRegMap(@Self)^.val and $000FF000) shr 12;
end;
procedure TDEVCFG_DEVCFG0.setBWP; inline;
begin
  pTDefRegMap(@Self)^.&set := $01000000;
end;
procedure TDEVCFG_DEVCFG0.clearBWP; inline;
begin
  pTDefRegMap(@Self)^.clr := $01000000;
end;
procedure TDEVCFG_DEVCFG0.setBWP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $01000000
  else
    pTDefRegMap(@Self)^.&set := $01000000;
end;
function  TDEVCFG_DEVCFG0.getBWP : TBits_1; inline;
begin
  getBWP := (pTDefRegMap(@Self)^.val and $01000000) shr 24;
end;
procedure TDEVCFG_DEVCFG0.setCP; inline;
begin
  pTDefRegMap(@Self)^.&set := $10000000;
end;
procedure TDEVCFG_DEVCFG0.clearCP; inline;
begin
  pTDefRegMap(@Self)^.clr := $10000000;
end;
procedure TDEVCFG_DEVCFG0.setCP(thebits : TBits_1); inline;
begin
  if thebits = 0 then
    pTDefRegMap(@Self)^.clr := $10000000
  else
    pTDefRegMap(@Self)^.&set := $10000000;
end;
function  TDEVCFG_DEVCFG0.getCP : TBits_1; inline;
begin
  getCP := (pTDefRegMap(@Self)^.val and $10000000) shr 28;
end;
procedure TDEVCFG_DEVCFG0.setFDEBUG(thebits : TBits_2); inline;
begin
  pTDefRegMap(@Self)^.val := pTDefRegMap(@Self)^.val and $FFFFFFFC or ( thebits shl 0 );
end;
function  TDEVCFG_DEVCFG0.getFDEBUG : TBits_2; inline;
begin
  getFDEBUG := (pTDefRegMap(@Self)^.val and $00000003) shr 0;
end;
procedure TDEVCFG_DEVCFG0.setw(thebits : TBits_32); inline;
begin
    pTDefRegMap(@Self)^.val := thebits;
end;
function  TDEVCFG_DEVCFG0.getw : TBits_32; inline;
begin
  getw := (pTDefRegMap(@Self)^.val and $FFFFFFFF) shr 0;
end;
  procedure _CORE_TIMER_VECTOR_interrupt; external name '_CORE_TIMER_VECTOR_interrupt';
  procedure _CORE_SOFTWARE_0_VECTOR_interrupt; external name '_CORE_SOFTWARE_0_VECTOR_interrupt';
  procedure _CORE_SOFTWARE_1_VECTOR_interrupt; external name '_CORE_SOFTWARE_1_VECTOR_interrupt';
  procedure _EXTERNAL_0_VECTOR_interrupt; external name '_EXTERNAL_0_VECTOR_interrupt';
  procedure _TIMER_1_VECTOR_interrupt; external name '_TIMER_1_VECTOR_interrupt';
  procedure _INPUT_CAPTURE_1_VECTOR_interrupt; external name '_INPUT_CAPTURE_1_VECTOR_interrupt';
  procedure _OUTPUT_COMPARE_1_VECTOR_interrupt; external name '_OUTPUT_COMPARE_1_VECTOR_interrupt';
  procedure _EXTERNAL_1_VECTOR_interrupt; external name '_EXTERNAL_1_VECTOR_interrupt';
  procedure _TIMER_2_VECTOR_interrupt; external name '_TIMER_2_VECTOR_interrupt';
  procedure _INPUT_CAPTURE_2_VECTOR_interrupt; external name '_INPUT_CAPTURE_2_VECTOR_interrupt';
  procedure _OUTPUT_COMPARE_2_VECTOR_interrupt; external name '_OUTPUT_COMPARE_2_VECTOR_interrupt';
  procedure _EXTERNAL_2_VECTOR_interrupt; external name '_EXTERNAL_2_VECTOR_interrupt';
  procedure _TIMER_3_VECTOR_interrupt; external name '_TIMER_3_VECTOR_interrupt';
  procedure _INPUT_CAPTURE_3_VECTOR_interrupt; external name '_INPUT_CAPTURE_3_VECTOR_interrupt';
  procedure _OUTPUT_COMPARE_3_VECTOR_interrupt; external name '_OUTPUT_COMPARE_3_VECTOR_interrupt';
  procedure _EXTERNAL_3_VECTOR_interrupt; external name '_EXTERNAL_3_VECTOR_interrupt';
  procedure _TIMER_4_VECTOR_interrupt; external name '_TIMER_4_VECTOR_interrupt';
  procedure _INPUT_CAPTURE_4_VECTOR_interrupt; external name '_INPUT_CAPTURE_4_VECTOR_interrupt';
  procedure _OUTPUT_COMPARE_4_VECTOR_interrupt; external name '_OUTPUT_COMPARE_4_VECTOR_interrupt';
  procedure _EXTERNAL_4_VECTOR_interrupt; external name '_EXTERNAL_4_VECTOR_interrupt';
  procedure _TIMER_5_VECTOR_interrupt; external name '_TIMER_5_VECTOR_interrupt';
  procedure _INPUT_CAPTURE_5_VECTOR_interrupt; external name '_INPUT_CAPTURE_5_VECTOR_interrupt';
  procedure _OUTPUT_COMPARE_5_VECTOR_interrupt; external name '_OUTPUT_COMPARE_5_VECTOR_interrupt';
  procedure _SPI_1_VECTOR_interrupt; external name '_SPI_1_VECTOR_interrupt';
  procedure _UART_1_VECTOR_interrupt; external name '_UART_1_VECTOR_interrupt';
  procedure _I2C_1_VECTOR_interrupt; external name '_I2C_1_VECTOR_interrupt';
  procedure _CHANGE_NOTICE_VECTOR_interrupt; external name '_CHANGE_NOTICE_VECTOR_interrupt';
  procedure _ADC_VECTOR_interrupt; external name '_ADC_VECTOR_interrupt';
  procedure _PMP_VECTOR_interrupt; external name '_PMP_VECTOR_interrupt';
  procedure _COMPARATOR_1_VECTOR_interrupt; external name '_COMPARATOR_1_VECTOR_interrupt';
  procedure _COMPARATOR_2_VECTOR_interrupt; external name '_COMPARATOR_2_VECTOR_interrupt';
  procedure _SPI_2_VECTOR_interrupt; external name '_SPI_2_VECTOR_interrupt';
  procedure _UART_2_VECTOR_interrupt; external name '_UART_2_VECTOR_interrupt';
  procedure _I2C_2_VECTOR_interrupt; external name '_I2C_2_VECTOR_interrupt';
  procedure _FAIL_SAFE_MONITOR_VECTOR_interrupt; external name '_FAIL_SAFE_MONITOR_VECTOR_interrupt';
  procedure _RTCC_VECTOR_interrupt; external name '_RTCC_VECTOR_interrupt';
  procedure _FCE_VECTOR_interrupt; external name '_FCE_VECTOR_interrupt';

  procedure Vectors; assembler; nostackframe;
  label interrupt_vectors;
  asm
    .section ".init.interrupt_vectors,\"ax\",@progbits"
  interrupt_vectors:

    j _CORE_TIMER_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _CORE_SOFTWARE_0_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _CORE_SOFTWARE_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _EXTERNAL_0_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _TIMER_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _INPUT_CAPTURE_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _OUTPUT_COMPARE_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _EXTERNAL_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _TIMER_2_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _INPUT_CAPTURE_2_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _OUTPUT_COMPARE_2_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _EXTERNAL_2_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _TIMER_3_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _INPUT_CAPTURE_3_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _OUTPUT_COMPARE_3_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _EXTERNAL_3_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _TIMER_4_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _INPUT_CAPTURE_4_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _OUTPUT_COMPARE_4_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _EXTERNAL_4_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _TIMER_5_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _INPUT_CAPTURE_5_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _OUTPUT_COMPARE_5_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _SPI_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _UART_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _I2C_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _CHANGE_NOTICE_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _ADC_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _PMP_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _COMPARATOR_1_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _COMPARATOR_2_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _SPI_2_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _UART_2_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _I2C_2_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _FAIL_SAFE_MONITOR_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _RTCC_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j _FCE_VECTOR_interrupt
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    .weak _CORE_TIMER_VECTOR_interrupt
    .weak _CORE_SOFTWARE_0_VECTOR_interrupt
    .weak _CORE_SOFTWARE_1_VECTOR_interrupt
    .weak _EXTERNAL_0_VECTOR_interrupt
    .weak _TIMER_1_VECTOR_interrupt
    .weak _INPUT_CAPTURE_1_VECTOR_interrupt
    .weak _OUTPUT_COMPARE_1_VECTOR_interrupt
    .weak _EXTERNAL_1_VECTOR_interrupt
    .weak _TIMER_2_VECTOR_interrupt
    .weak _INPUT_CAPTURE_2_VECTOR_interrupt
    .weak _OUTPUT_COMPARE_2_VECTOR_interrupt
    .weak _EXTERNAL_2_VECTOR_interrupt
    .weak _TIMER_3_VECTOR_interrupt
    .weak _INPUT_CAPTURE_3_VECTOR_interrupt
    .weak _OUTPUT_COMPARE_3_VECTOR_interrupt
    .weak _EXTERNAL_3_VECTOR_interrupt
    .weak _TIMER_4_VECTOR_interrupt
    .weak _INPUT_CAPTURE_4_VECTOR_interrupt
    .weak _OUTPUT_COMPARE_4_VECTOR_interrupt
    .weak _EXTERNAL_4_VECTOR_interrupt
    .weak _TIMER_5_VECTOR_interrupt
    .weak _INPUT_CAPTURE_5_VECTOR_interrupt
    .weak _OUTPUT_COMPARE_5_VECTOR_interrupt
    .weak _SPI_1_VECTOR_interrupt
    .weak _UART_1_VECTOR_interrupt
    .weak _I2C_1_VECTOR_interrupt
    .weak _CHANGE_NOTICE_VECTOR_interrupt
    .weak _ADC_VECTOR_interrupt
    .weak _PMP_VECTOR_interrupt
    .weak _COMPARATOR_1_VECTOR_interrupt
    .weak _COMPARATOR_2_VECTOR_interrupt
    .weak _SPI_2_VECTOR_interrupt
    .weak _UART_2_VECTOR_interrupt
    .weak _I2C_2_VECTOR_interrupt
    .weak _FAIL_SAFE_MONITOR_VECTOR_interrupt
    .weak _RTCC_VECTOR_interrupt
    .weak _FCE_VECTOR_interrupt

    .text
  end;
end.
