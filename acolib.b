SECTION "ACOLIB"

// Acorn MOS library.

GET "LIBHDR"
GET "SYSHDR"
GET "FSTEST.ACOHDR/b"

MANIFEST $(
   MAXFNLEN = 14
$)

LET OPENFILE(filename, mode) = VALOF
$(
   LET bytelen  = filename%0
   LET reslow  = ?
   LET fnword  = VEC((MAXFNLEN/2)+1)
   LET fnbyte  = fnword << 1

   IF bytelen > MAXFNLEN THEN $(
      WRITEF("OPENFILE: filename %S too long (max %N characters)*N", filename, MAXFNLEN)
      STOP(501)
   $)
   MOVEBYTE((filename<<1)+1, fnbyte, bytelen)
   fnword%bytelen := '*C'
   MCRESULT := 0
   CALLBYTE(OSFIND, mode, fnbyte)
   reslow := MCRESULT & #XFF
   IF (MCRESULT >> 8) = #XFF THEN $(
      ERRORMSG(1000+reslow)
      STOP(502)
   $)
   RESULTIS reslow
$)

AND CLOSE(fd) BE
$(
   CALLBYTE(OSFIND, 0, fd << 8)
$)

AND OPENIN(filename) = OPENFILE(filename, #X40)

AND OPENOUT(filename) = OPENFILE(filename, #X80)

AND OPENUP(filename) = OPENFILE(filename, #XC0)
