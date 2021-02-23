SECTION "MAIN"
NEEDS "TIME"
GET "LIBHDR"
GET "SYSHDR"
GET "FPHDR"
GET "FSTEST.ACOHDR/b"
GET "FSTEST.RATHDR/b"

LET compareStr(aBase, aOffset, b, len) = VALOF
$(
   LET d = 0
   FOR i = 0 TO len-1 DO $(
      d := aBase%aOffset - b%i
      UNLESS d = 0 THEN BREAK
      aOffset := aOffset + 1
   $)
   RESULTIS d
$)

AND showDiffs(aBase, aOffset, b, len) BE
$(
   WRITES("a: ")
   FOR i = 0 TO len-1 DO $(
      WRCH(aBase%aOffset)
      aOffset := aOffset + 1
   $)
   WRITES("*Nb: ")
   FOR i = 0 TO len-1 DO WRCH(b%i)
   NEWLINE()
$)

AND checkChannel() BE
$(
   LET filename = "tstfil1"
   LET tvec = VEC(10)
   LET tbyte = tvec << 1
   LET osfsc = !#X10F
   LET xy = ?
   LET handle = ?

   // Start with a handle that is out of range.
   MCRESULT := 0
   GetBytes(0, tbyte, 10)
   UNLESS (MCRESULT >> 8) = #XFF DO
      WRITES("fail: no error generated using another filing system's handle*N")

   // Open a file for input and then try to write to it
   handle := OPENIN(filename)
   TEST handle = 0 THEN
      WRITEF("fail: unable to open file %S for reading*N", filename)
   ELSE $(
      MCRESULT := 0
      PutBytes(handle, tbyte, 10)
      UNLESS (MCRESULT >> 8) = #XFF DO
         WRITES("fail: no error generated writing to a file open for reading*N")
      CLOSE(handle)
   $)

   // Now try a handle that is in-range but closed.
   MCRESULT := 0
   GetBytes(handle+1, tbyte, 10)
   UNLESS (MCRESULT >> 8) = #XFF DO
      WRITES("fail: no error generated using a closed handle*N")
$)

AND DOIT() BE
$(
   LET source = "caesar"
   LET fvec = FILETOVEC(source)
   TEST fvec = 0 THEN $(
      WRITEF("Unable to read file %S*N", source)
      STOP(501)
   $)
   ELSE $(
      LET size = fvec!1
      LET fdata = fvec + 2
      LET lines = countLines(fdata, size)
      LET ivec = indexLines(fdata, size, lines)
      LET longest = longestLine(ivec, lines)
      LET cvec = GETVEC((longest + 1) >> 1)
      LET test1 = "tstfil1"
      LET test2 = "tstfil2"
      WriteSequential(test1, fdata, ivec, lines)
      CompareSequential(test1, fdata, ivec, lines, cvec)
      CompareRandom(test1, fdata, ivec, lines, cvec)
      WriteRandom(test2, fdata, ivec, lines)
      CompareSequential(test2, fdata, ivec, lines, cvec)
      CompareRandom(test2, fdata, ivec, lines, cvec)
      CheckChannel()
   $)
$)

AND getSysTime(fpvec) BE
$(
    LET sysclock = VEC(3)
    LET scale = VEC(FP.LEN)
    LET byte = VEC(FP.LEN)
    LET temp = VEC(FP.LEN)
    CALLBYTE(#XFFF1, 1, sysclock << 1)
    FFLOAT(256, scale)
    FFLOAT(0, fpvec)
    FOR i = 4 TO 0 BY -1 DO $(
        FFLOAT(sysclock%i, byte)
        FMULT(fpvec, scale, temp)
        FPLUS(temp, byte, fpvec)
    $)
$)

AND ReportTime(sTime) BE
$(
   LET eTime = VEC(FP.LEN)
   LET dTime = VEC(FP.LEN)
   LET secs = VEC(FP.LEN)
   LET hund = VEC(FP.LEN)
   getSysTime(eTime)
   FMINUS(eTime, sTime, dTime)
   FFLOAT(100, hund)
   FDIV(dTime, hund, secs)
   WRITES("Took ")
   WRITEFP(secs, 17, 2)
   WRITES(" seconds*N")
$)

AND START() BE
$(
   LET sTime = VEC(FP.LEN)
   WRITES("Filing System Random Access Test*N")
   banner()
   getSysTime(sTime)
   DOIT()
   ReportTime(sTime)
$)
