package main
import sb "sandbox"

import "core:dynlib"
import "core:fmt"

main :: proc () {
    fmt.print("Running sandbox");
    lib, load_success := dynlib.load_library("../debug_build/app_sandbox.dll");
    if !load_success {
        fmt.print("Error loading dll");
    }

    dll_test0_addr, found_symbol := dynlib.symbol_address(lib, "DllTest0");
    if !found_symbol {
        fmt.print("Could not find dll_test0 symbol");
    }
    dll_test0 := cast(sb.DllTest0)dll_test0_addr;
    dll_test0();
}
