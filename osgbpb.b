SECTION "OSGBPB"

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
   WRITES("Using OSGBPB*N")
$)

AND setupFCB(fcb, fd, fdata, offset, len) BE
$(
   LET byteptr = (fdata<<1)+offset
   fcb%0 := fd
   fcb%1 := byteptr & #XFF
   fcb%2 := byteptr >> 8
   fcb%3 := 0
   fcb%4 := 0
   fcb%5 := len & #XFF
   fcb%6 := len >> 8
   fcb%7 := 0
   fcb%8 := 0
$)

AND setupPTR(fcb, fileptr) BE
$(
   fcb%9  := fileptr & #XFF
   fcb%10 := fileptr >> 8
   fcb%11 := 0
   fcb%12 := 0
$)

AND CheckedOSGBPB(fcb, func) BE
$(
   CALLBYTE(OSGBPB, func, fcb << 1)
   IF (MCRESULT >> 8) = #XFF DO $(
      LET ecode = MCRESULT & #XFF
      ERRORMSG(ecode+1000)
      WRITEF("error#%N in OSGBPB#%N*N", ecode, func)
      STOP(501)
   $)
$)

AND SeekPut(fd, fdata, offset, len, fileptr) BE
$(
   LET fcb  = VEC(6)
   setupFCB(fcb, fd, fdata, offset, len)
   setupPTR(fcb, fileptr)
   CheckedOSGBPB(fcb, 1)
$)

AND PutBytes(fd, fdata, offset, len) BE
$(
   LET fcb  = VEC(6)
   setupFCB(fcb, fd, fdata, offset, len)
   CheckedOSGBPB(fcb, 2)
$)

AND SeekGet(fd, fdata, offset, len, fileptr) BE
$(
   LET fcb  = VEC(6)
   setupFCB(fcb, fd, fdata, offset, len)
   setupPTR(fcb, fileptr)
   CheckedOSGBPB(fcb, 3)
$)

AND GetBytes(fd, fdata, offset, len) BE
$(
   LET fcb  = VEC(6)
   setupFCB(fcb, fd, fdata, offset, len)
   CheckedOSGBPB(fcb, 4)
$)

AND UnCheckedGet(fd) BE
$(
   LET tvec = VEC(10)
   LET tbyte = tvec << 1
   LET fcb  = VEC(6)
   setupFCB(fcb, 0, tbyte, 0, 10)
   CALLBYTE(OSGBPB, 4, fcb << 1)
$)

AND UnCheckedPut(fd) BE
$(
   LET tvec = VEC(10)
   LET tbyte = tvec << 1
   LET fcb  = VEC(6)
   setupFCB(fcb, 0, tbyte, 0, 10)
   CALLBYTE(OSGBPB, 2, fcb << 1)
$)
