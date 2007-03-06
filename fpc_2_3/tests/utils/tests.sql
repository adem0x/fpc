CREATE TABLE TESTS (
  T_ID   INTEGER NOT NULL AUTO_INCREMENT,
  T_NAME VARCHAR(80) NOT NULL,
  T_FULLNAME VARCHAR(255) NOT NULL,
  T_CPU VARCHAR(20),
  T_OS VARCHAR(30),
  T_VERSION VARCHAR(10),
  T_ADDDATE DATE NOT NULL,
  T_GRAPH CHAR(1) NOT NULL DEFAULT '-',
  T_INTERACTIVE CHAR(1) NOT NULL DEFAULT '-',
  T_RESULT INTEGER NOT NULL DEFAULT 0,
  T_FAIL CHAR(1) NOT NULL DEFAULT '-',
  T_RECOMPILE CHAR(1) NOT NULL DEFAULT '-',
  T_NORUN CHAR(1) NOT NULL DEFAULT '-',
  T_NEEDLIBRARY CHAR(1) NOT NULL DEFAULT '-',
  T_KNOWNRUNERROR INTEGER NOT NULL DEFAULT 0,
  T_KNOWN CHAR(1) NOT NULL DEFAULT '-',
  T_NOTE VARCHAR(255),
  T_DESCRIPTION TEXT,
  T_SOURCE TEXT,
  T_OPTS VARCHAR(255),
  UNIQUE TESTNAME (T_NAME),
  PRIMARY KEY PK_TEST (T_ID)
);

CREATE TABLE TESTRESULTS (
  TR_ID INTEGER NOT NULL AUTO_INCREMENT,
  TR_TEST_FK INTEGER NOT NULL,
  TR_DATE TIMESTAMP NOT NULL,
  TR_CPU_FK INTEGER,
  TR_OS_FK INTEGER,
  TR_VERSION_FK INTEGER,
  TR_OK CHAR(1) NOT NULL DEFAULT '-',
  TR_SKIP CHAR(1) NOT NULL DEFAULT '-',
  TR_RESULT INT NOT NULL DEFAULT 0,
  TR_LOG TEXT,
  PRIMARY KEY (TR_ID),
  INDEX TR_IDATE (TR_DATE)
);

CREATE TABLE TESTOS (
  TO_ID INTEGER NOT NULL AUTO_INCREMENT,
  TO_NAME VARCHAR(10),
  PRIMARY KEY (TO_ID),
  UNIQUE TR_INAME (TO_NAME)
);

CREATE TABLE TESTVERSION (
  TV_ID INTEGER NOT NULL AUTO_INCREMENT,
  TV_VERSION VARCHAR(10),
  TV_RELEASEDATE TIMESTAMP,
  PRIMARY KEY (TV_ID),
  UNIQUE TR_INAME (TV_VERSION)
);

CREATE TABLE TESTCPU (
  TC_ID INTEGER NOT NULL AUTO_INCREMENT,
  TC_NAME VARCHAR(10),
  PRIMARY KEY (TC_ID),
  UNIQUE TC_INAME (TC_NAME)
);

INSERT INTO TESTOS (TO_NAME) VALUES ('linux');
INSERT INTO TESTOS (TO_NAME) VALUES ('win32');
INSERT INTO TESTOS (TO_NAME) VALUES ('go32v2');
INSERT INTO TESTOS (TO_NAME) VALUES ('os2');
INSERT INTO TESTOS (TO_NAME) VALUES ('freebsd');
INSERT INTO TESTOS (TO_NAME) VALUES ('netbsd');
INSERT INTO TESTOS (TO_NAME) VALUES ('openbsd');
INSERT INTO TESTOS (TO_NAME) VALUES ('amiga');
INSERT INTO TESTOS (TO_NAME) VALUES ('atari');
INSERT INTO TESTOS (TO_NAME) VALUES ('qnx');
INSERT INTO TESTOS (TO_NAME) VALUES ('beos');
INSERT INTO TESTOS (TO_NAME) VALUES ('sunos');

INSERT INTO TESTCPU (TC_NAME) VALUES ('i386');
INSERT INTO TESTCPU (TC_NAME) VALUES ('ppc');
INSERT INTO TESTCPU (TC_NAME) VALUES ('m68k');
INSERT INTO TESTCPU (TC_NAME) VALUES ('sparc');

INSERT INTO TESTVERSION (TV_VERSION) VALUES ('1.0.6');
INSERT INTO TESTVERSION (TV_VERSION) VALUES ('1.0.7');
INSERT INTO TESTVERSION (TV_VERSION) VALUES ('1.0.8');
INSERT INTO TESTVERSION (TV_VERSION) VALUES ('1.1.0');
INSERT INTO TESTVERSION (TV_VERSION) VALUES ('1.1');


 
