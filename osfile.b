SECTION "OSFTST"
GET "LIBHDR"
GET "SYSHDR"

MANIFEST
$(
   OSFIND   = #XFFCE
   OSFILE   = #XFFDD
   DATASIZE = 2000
$)

LET Pattern(DATA) BE
$(
   FOR I = 0 TO (DATASIZE-1) BY 2 DO
      DATA!I := I
   FOR I = 1 TO (DATASIZE-1) BY 2 DO
      DATA!I := DATASIZE-I
$)

AND Compare(DATA) BE
$(
   FOR I = 0 TO (DATASIZE-1) BY 2 DO
      UNLESS DATA!I = I WRITEF("Fail at %I4*N", I)
   FOR I = 1 TO (DATASIZE-1) BY 2 DO
      UNLESS DATA!I = DATASIZE-I WRITEF("Fail at %I4*N", I)
$)

AND LoadSave(FUNC, CBLK, FN, DATA, EXECLOW, EXECHIGH) BE
$(
   LET DATABYTE = DATA << 1
   CBLK!0 := FN << 1
   CBLK!1 := DATABYTE
   CBLK!2 := 0
   CBLK!3 := EXECLOW
   CBLK!4 := EXECHIGH
   CBLK!5 := DATABYTE
   CBLK!6 := 0
   CBLK!7 := (DATA+DATASIZE)<<1
   CBLK!8 := 0
   MCRESULT := 0
   CALLBYTE(OSFILE, FUNC, CBLK<<1)
$)

AND CheckedLoadSave(FUNC, CBLK, FN, DATA, EXECLOW, EXECHIGH) BE
$(
   LoadSave(FUNC, CBLK, FN, DATA, EXECLOW, EXECHIGH)
   IF (MCRESULT >> 8) = #XFF DO $(
      WRITEF("fail: error in OSFILE #%I2*N", FUNC)
      STOP(501)
   $)
$)

AND CheckAttr(FUNC, CBLK, LoadLow, LoadHigh, ExecLow, ExecHigh) BE
$(
   CALLBYTE(OSFILE, FUNC, CBLK<<1)
   CBLK!1 := 0
   CBLK!2 := 0
   CBLK!3 := 0
   CBLK!4 := 0
   CBLK!5 := 0
   CBLK!6 := 0
   CBLK!7 := 0
   CALLBYTE(OSFILE, 5, CBLK<<1)
   UNLESS CBLK!1 = LoadLow & CBLK!2 = LoadHigh DO $(
      WRITEF("OSFILE %I2: incorrect load address*N", FUNC)
      WRITEF("Written %X4%X4, ", LoadHigh, LoadLow)
      WRITEF("%X4%X4 returned*N", CBLK!2, CBLK!1)
   $)
   UNLESS CBLK!3 = ExecLow & CBLK!4 = ExecHigh DO $(
      WRITEF("OSFILE %I2: incorrect exec address*N", FUNC)
      WRITEF("Written %X4%X4, ", ExecHigh, ExecLow)
      WRITEF("%X4%X4 returned*N", CBLK!4, CBLK!3)
   $)
$)

AND TestAttr(CBLK, FN) BE
$(
   LET LoadLow  = CBLK!1 + 3
   LET LoadHigh = CBLK!2 + 5
   LET ExecLow  = CBLK!3 + 7
   LET ExecHigh = CBLK!4 + 11
   CBLK!0 := FN << 1
   CBLK!1 := LoadLow
   CBLK!2 := LoadHigh
   CBLK!3 := ExecLow
   CBLK!4 := ExecHigh
   CheckAttr(1, CBLK, LoadLow, LoadHigh, ExecLow, ExecHigh)
   LoadLow  := LoadLow + 3
   LoadHigh := LoadHigh + 5
   CBLK!1 := LoadLow
   CBLK!2 := LoadHigh
   CBLK!3 := ExecLow + 7
   CBLK!4 := ExecHigh + 11
   CheckAttr(2, CBLK, LoadLow, LoadHigh, ExecLow, ExecHigh)
   ExecLow  := ExecLow + 3
   ExecHigh := ExecHigh + 5
   CBLK!1 := LoadLow + 7
   CBLK!2 := LoadHigh + 11
   CBLK!3 := ExecLow
   CBLK!4 := ExecHigh
   CheckAttr(3, CBLK, LoadLow, LoadHigh, ExecLow, ExecHigh)
$)

AND TestDelete(CBLK, FN) BE
$(
   LET ARET = ?
   CBLK!0 := FN << 1
   MCRESULT := 0
   CALLBYTE(OSFILE, 6, CBLK<<1)
   TEST (MCRESULT >> 8) = #XFF THEN
      WRITEF("fail: error #%X2 in OSFILE 6*N", MCRESULT & #XFF)
   ELSE $(
      ARET := MCRESULT & #XFF
      TEST ARET = 6 THEN
         WRITES("OSFILE 6 not implemented*N")
      ELSE $(
         TEST ARET = 1 THEN $(
            MCRESULT := 0
            CALLBYTE(OSFILE, 6, CBLK<<1)
            TEST (MCRESULT >> 8) = #XFF THEN
               WRITEF("fail: error #%X2 in OSFILE 6*N", MCRESULT & #XFF)
            ELSE $(
               ARET := MCRESULT & #XFF
               UNLESS ARET = 0 DO
                  WRITEF("fail: OSFILE 6: incorrect return (%I2) in A when file does not exist*N", ARET)
            $)
         $)
         ELSE
            WRITEF("fail: OSFILE 6: incorrect return (%I2) in A when file exists*N", ARET)
      $)
   $)
$)

AND CreateObj(FUNC, CBLK, FN, len) BE
$(
   CBLK!0 := FN << 1
   CBLK!1 := 0
   CBLK!2 := 0
   CBLK!3 := 0
   CBLK!4 := 0
   CBLK!5 := 0
   CBLK!6 := 0
   CBLK!7 := len
   CBLK!8 := 0
   MCRESULT := 0
   CALLBYTE(OSFILE, FUNC, CBLK<<1)
$)

AND TestCreation(CBLK, FN) BE
$(
   LET ARET = ?
   // Create a file (it has just been deleted so should not exist)
   CreateObj(7, CBLK, FN, 1234)
   TEST (MCRESULT >> 8) = #XFF THEN
      WRITEF("fail: Error #%X2 occured creating non-existent file*N", MCRESULT & #XFF)
   ELSE $(
      ARET := MCRESULT & #XFF
      TEST ARET = 7 THEN
        WRITES("OSFILE 7 not implemented*N")
      ELSE $(
         // Now attempt to create it again (should work without error)
         CreateObj(7, CBLK, FN, 1234)
         TEST (MCRESULT >> 8) = #XFF DO
            WRITEF("fail: Error #%X2 occured re-creating existing file*N", MCRESULT & #XFF)
         ELSE $(
            // Attempt to create a directory on top of the file.
            CreateObj(8, CBLK, FN, 0)
            UNLESS (MCRESULT >> 8) = #XFF DO
               WRITES("fail: Allowed a directory to be created on top of a file*N")
         $)
         // Delete the file and try again.
         CALLBYTE(OSFILE, 6, CBLK<<1)
      $)
   $)
   CreateObj(8, CBLK, FN, 0)
   TEST (MCRESULT >> 8) = #XFF THEN
      WRITEF("fail: Error #%X2 occured creating directory*N", MCRESULT & #XFF)
   ELSE $(
      ARET := MCRESULT & #XFF
      TEST ARET = 8 THEN
         WRITES("OSFILE 8 not implemented*N")
      ELSE $(
         // Now attempt to create a file on top of the directory.
         CreateObj(7, CBLK, FN, 1234)
         UNLESS (MCRESULT >> 8) = #XFF DO
            WRITES("fail: Allowed a file to be created on top of a directory*N")
      $)
      // Delete the directory
      CALLBYTE(OSFILE, 6, CBLK<<1)
   $)
$)

AND TestOpenSave(CBLK, FN, DATA) BE
$(
   LET chan = ?
   MCRESULT := 0
   CALLBYTE(OSFIND, #X80, FN<<1)
   TEST (MCRESULT >> 8) = #XFF THEN
      WRITEF("fail: Error #%X2 occured opening file*N", MCRESULT & #XFF)
   ELSE $(
      chan := MCRESULT & #XFF
      LoadSave(0, CBLK, FN, DATA, #X1234, #X5678)
      UNLESS (MCRESULT >> 8) = #XFF DO
         WRITES("fail: Allowed a file to be saved over a file open for writing*N")
      CALLBYTE(OSFIND, 0, chan << 8)
   $)
$)

AND START() BE
$(
   LET DATA = ?
   LET CBLK = VEC(9)
   LET FN   = VEC(4)

   WRITES("Filing System Whole File Test*N")

   /* The following line is to set up the filename in BBC OS format rather
      than BCPL format so it is taking a copy, skipping over the length byte
      at the start and copying the carriage return at the end.
   */
   MOVEBYTE(("TSTFIL*C*N"<<1)+1, FN<<1, 8)

   DATA := GETVEC(DATASIZE+1)
   WRITES("Generating pattern*N")
   Pattern(DATA)

   WRITES("Saving*N")
   CheckedLoadSave(0, CBLK, FN, DATA, #X1234, #X5678)

   WRITES("Re-loading*N")
   CheckedLoadSave(#XFF, CBLK, FN, DATA+1, 0, 0)

   WRITES("Comparing*N")
   Compare(DATA+1)

   WRITES("Testing attribute setting*N")
   TestAttr(CBLK, FN)

   WRITES("Testing file deletion*N")
   TestDelete(CBLK, FN)

   WRITES("Testing file and directory creation*N")
   TestCreation(CBLK, FN)

   WRITES("Testing saving over an open file*N")
   TestOpenSave(CBLK, FN, DATA)
$)
