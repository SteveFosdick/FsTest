SECTION "BYTEIO"

NEEDS "ACOLIB"
NEEDS "CAESAR"
NEEDS "SEQUEN"
NEEDS "RANDOM"
NEEDS "MAIN"

GET "LIBHDR"
GET "SYSHDR"
GET "FSTEST.ACOHDR/b"
GET "FSTEST.RATHDR/b"

LET banner() BE
$(
   WRITES("Using OSBPUT/OSBGET*N")
$)

AND setPTR(fd, fileptr) BE
$(
   LET zp = 56
   zp!0 := fileptr
   zp!1 := 0
   MCRESULT := 0
   CALLBYTE(OSARGS, 1, (fd<<8)|(zp<<1))
   IF (MCRESULT >> 8) = #XFF THEN $(
      LET ecode = MCRESULT & #XFF
      ERRORMSG(ecode)
      WRITEF("fail: Error #%N attempting to set file pointer with OSARGS", ecode)
      STOP(504)
   $)
$)

AND PutBytes(fd, fdata, offset, len) BE
$(
   LET last = offset + len - 1
   MCRESULT := 0
   FOR i = offset TO last DO $(
      CALLBYTE(OSBPUT, fdata%i, fd<<8)
      IF (MCRESULT >> 8) = #XFF THEN $(
         LET ecode = MCRESULT & #XFF
         ERRORMSG(ecode)
         WRITEF("fail: Error #%N in OSBPUT", ecode)
         STOP(504)
      $)
   $)
$)

AND SeekPut(fd, fdata, offset, len, fileptr) BE
$(
   setPTR(fd,fileptr)
   PutBytes(fd, fdata, offset, len)
$)

AND GetBytes(fd, fdata, offset, len) BE
$(
   LET last = offset + len - 1
   MCRESULT := 0
   FOR i = offset TO last DO $(
      CALLBYTE(OSBGET, 0, fd<<8)
      IF (MCRESULT >> 8) = #XFF THEN $(
         LET ecode = MCRESULT & #XFF
         ERRORMSG(ecode+1000)
         WRITEF("fail: Error #%N in OSBGET", ecode)
         STOP(504)
      $)
      fdata%i := MCRESULT & #XFF
   $)
$)

AND SeekGet(fd, fdata, offset, len, fileptr) BE
$(
   setPTR(fd,fileptr)
   GetBytes(fd, fdata, offset, len)
$)

AND UnCheckedGet(fd) BE
$(
   CALLBYTE(OSBGET, 0, fd<<8)
$)

AND UnCheckedPut(fd) BE
$(
   CALLBYTE(OSBPUT, 0, fd<<8)
$)
