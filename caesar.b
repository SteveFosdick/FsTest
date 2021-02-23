SECTION "CAESAR"
GET "LIBHDR"
GET "FSTEST.RATHDR/b"

LET countLines(fdata, size) = VALOF
$(
   LET lines = 0
   FOR i = 0 TO size DO IF fdata%i = '*C' THEN lines := lines + 1
   UNLESS fdata%(size-1) = '*C' DO lines := lines + 1
   WRITEF("Lines: %I4*N", lines)
   RESULTIS lines
$)

AND indexLines(fdata, size, lines) = VALOF
$(
   LET ivec = GETVEC(lines)
   LET line = 0
   FOR i = 0 TO size DO IF fdata%i = '*C' THEN $(
      ivec!line := i + 1
      line := line + 1
   $)
   ivec!line := size
   RESULTIS ivec
$)

AND longestLine(ivec, lines) = VALOF
$(
   LET maxlen = 0
   LET this = 0
   LET next = ivec!0
   FOR i = 1 TO lines DO $(
      LET len = next - this
      IF len > maxlen THEN maxlen := len
      this := next
      next := ivec!i
   $)
   WRITEF("Longest: %I4*N", maxlen)
   RESULTIS maxlen
$)

