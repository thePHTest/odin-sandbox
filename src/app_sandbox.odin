package app
import sb "sandbox"

import "core:fmt"
import "core:log"

test_global := GlobalAssign();

@export
DllTest0 : sb.DllTest0Proc : proc(println : sb.PrintlnProc) {
    fmt.println("Does fmt.print go to stdout?");
    test_log := log.create_console_logger();
    context.logger = test_log;
    log.info("Does log.info go to stdout?");
    println("Does this print?");
    println(test_global);
}

GlobalAssign::proc() -> int {
    return 12345;
}
