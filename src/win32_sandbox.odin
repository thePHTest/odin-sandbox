package main
import sb "sandbox"

import "core:dynlib"
import "core:fmt"

Println : sb.PrintlnProc : proc(args: ..any, sep := " ") -> int  {
    return fmt.println(args, sep);
}

main :: proc () {
    fmt.println("Running sandbox");
    lib, load_success := dynlib.load_library("../debug_build/app_sandbox.dll");
    if !load_success {
        fmt.println("Error loading dll");
    }

    dll_test0_addr, found_symbol := dynlib.symbol_address(lib, "DllTest0");
    if !found_symbol {
        fmt.println("Could not find dll_test0 symbol");
    }
    dll_test0 := cast(sb.DllTest0Proc)dll_test0_addr;
    dll_test0(Println);
}
