SECTION "SEQUEN"
NEEDS "ACOLIB"
GET "LIBHDR"
GET "FSTEST.ACOHDR/B"
GET "FSTEST.RATHDR/B"

LET writeSequential(filename, fdata, ivec, lines) BE
$(
   LET fd = OPENOUT(filename)
   TEST fd = 0 THEN $(
      WRITEF("Unable to open file %S for output*N", filename)
      STOP(503)
   $)
   ELSE $(
      LET this = 0
      LET next = ivec!0
      LET ibyte = ivec << 1
      LET ptrw = VEC(1)
      LET ptrb = ptrw << 1
      WRITEF("Write sequential %S*N", filename)
      PutBytes(fd, ivec, 0, LINES << 1)
      FOR i = 1 TO lines DO $(
         LET len = next - this
         IF len > 0 THEN PutBytes(fd, fdata, this, len)
            this := next
         next := ivec!i
      $)
      CLOSE(fd)
   $)
$)

AND compareSequential(filename, fdata, ivec, lines, cvec) BE
$(
   LET fd = OPENIN(filename)
   TEST fd = 0 THEN $(
      WRITEF("Unable to open file %S for input*N", filename)
      STOP(503)
   $)
   ELSE $(
      LET ibyte = ivec << 1
      LET this = 0
      LET next = ivec!0
      WRITEF("Compare sequential %S*N", filename)
      FOR i = 0 TO lines-1 DO $(
         GetBytes(fd, cvec, 0, 2)
         UNLESS cvec!0 = ivec!i THEN $(
            WRITEF("%S%I4*N", "fail: mismatch in sequential index, line no=", i)
            CLOSE(fd)
            RETURN
         $)
      $)
      FOR i = 1 TO lines DO $(
         LET len = next - this
         IF len > 0 THEN $(
            GetBytes(fd, cvec, 0, len)
            IF compareStr(fdata, this, cvec, len) THEN $(
               WRITEF("%S%I4*N", "fail: mismatch in sequential data, line no=", i)
               CLOSE(fd)
               RETURN
            $)
         $)
         this := next
         next := ivec!i
      $)
      CLOSE(fd)
   $)
$)

