bcpl fstest.byteio/b fstest.byteio/o
save fstest.byteio/o
joincin fstest.main/o fstest.byteio/o fstest.sequen/o fstest.random/o fstest.caesar/o fstest.acolib/o flarith flio as=temp
needcin temp lib fstest.byteio
save fstest.byteio
