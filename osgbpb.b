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

AND SeekPut(fd, fdata, offset, len, fileptr) BE
$(
   LET fcb  = VEC(6)
   setupFCB(fcb, fd, fdata, offset, len)
   setupPTR(fcb, fileptr)
   CALLBYTE(OSGBPB, 1, fcb << 1)
$)

AND PutBytes(fd, fdata, offset, len) BE
$(
   LET fcb  = VEC(6)
   setupFCB(fcb, fd, fdata, offset, len)
   CALLBYTE(OSGBPB, 2, fcb << 1)
$)

AND SeekGet(fd, fdata, offset, len, fileptr) BE
$(
   LET fcb  = VEC(6)
   setupFCB(fcb, fd, fdata, offset, len)
   setupPTR(fcb, fileptr)
   CALLBYTE(OSGBPB, 3, fcb << 1)
$)

AND GetBytes(fd, fdata, offset, len) BE
$(
   LET fcb  = VEC(6)
   setupFCB(fcb, fd, fdata, offset, len)
   CALLBYTE(OSGBPB, 4, fcb << 1)
$)

