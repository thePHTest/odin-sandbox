package sandbox

TEST_CONSTANT := 1;

PrintlnProc :: #type  proc(args: ..any, sep := " ") -> int;
DllTest0Proc :: #type proc(print : PrintlnProc);
