SECTION "RANDOM"
NEEDS "ACOLIB"
GET "LIBHDR"
GET "SYSHDR"
GET "FSTEST.ACOHDR/b"
GET "FSTEST.RATHDR/b"

LET writeRandom(filename, fdata, ivec, lines) BE
$(
   LET fd = OPENOUT(filename)
   TEST fd = 0 THEN $(
      WRITEF("Unable to open file %S for output*N", filename)
      STOP(503)
   $)
   ELSE $(
      LET this = 0
      LET next = ivec!0
      LET ipos = 0
      LET dpos = lines << 1
      WRITEF("Write random %S*N", filename)
      FOR i = 1 TO lines DO $(
         LET len = next - this
         SeekPut(fd, ivec, (i-1)<<1, 2, ipos)
         ipos := ipos + 2
         IF len > 0 THEN $(
            SeekPut(fd, fdata, this, len, dpos)
            dpos := dpos + len
         $)
         this := next
         next := ivec!i
      $)
      CLOSE(fd)
   $)
$)

AND compareRandom(filename, fdata, ivec, lines, cvec) BE
$(
   LET fd = OPENIN(filename)
   TEST fd = 0 THEN $(
      WRITEF("Unable to open file %S for input*N", filename)
      STOP(503)
   $)
   ELSE $(
      LET dbase = lines * 2
      LET j = RANDOM(0)
      LET ptrw = VEC(2)
      WRITEF("Compare random %S*N", filename)
      FOR i = 0 TO lines DO $(
         LET ref = ?
         LET len = ?
         LET dpos = ?
         LET k = ABS(MULDIV(j, lines, 65535))
         IF K < lines THEN $(
            TEST k = 0 THEN $(
               ref := 0
               SeekGet(fd, ptrw, 0, 2, 0)
               len := ptrw!0
               dpos := dbase
            $)
            ELSE $(
               LET n = k-1
               ref := ivec!n
               SeekGet(fd, ptrw, 0, 4, n << 1)
               len := ptrw!1 - ptrw!0
               dpos := dbase + ptrw!0
            $)
            IF len > 0 $(
               SeekGet(fd, cvec, 0, len, dpos)
               IF compareStr(fdata, ref, cvec, len) THEN $(
                  WRITEF("%S%I4*N", "fail: mismatch in random data, line no=", k)
                  showDiffs(fdata, ref, cvec, len)
                  CLOSE(fd)
                  RETURN
               $)
            $)
         $)
         j := RANDOM(j)
      $)
      CLOSE(fd)
   $)
$)

