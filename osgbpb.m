bcpl fstest.osgbpb/b fstest.osgbpb/o
save fstest.osgbpb/o
joincin fstest.main/o fstest.osgbpb/o fstest.sequen/o fstest.random/o fstest.caesar/o fstest.acolib/o flarith flio as=temp
needcin temp lib fstest.osgbpb
save fstest.osgbpb
