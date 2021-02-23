# FsTest
A filing system tester for Acorn MOS API (BBC Micro etc)

This is a suite of test programs to test a filing system that implements
the Acorn MOS API as on the BBC Micro and related machines.

* OSFILE tests saving and re-loading a whole and some other OSFILE
  functions.

* BYTEIO tests writing and reading back a test file in both sequential
  and randon order by using byte IO, i.e. the functions OSBPUT and
  OSBGET.  For the random access OSARGS is used to move the file
  pointer.

* OSGBPB does the same test as BYTEIO but uses the OSGBPB to read/write
  multiple bytes at a time.  Also, for the random access, there is no
  separate call to OSARGS but the feature of OSGBPB to write a
  specified file pointer value is used.

To compile, each of these commands has an equivalent file with a .m
as the suffix.  Separate modules are used as the amount of memory on
the BBC micro is very limited.  Any module without a .m file is
compiled with the bcpl command with the source as a .b file and the
output as a .o file.
