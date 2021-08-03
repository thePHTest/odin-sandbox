package app
import sb "sandbox"

import "core:fmt"
import "core:log"
import "core:os"

test_global := GlobalAssign();

@export
DllTest0 : sb.DllTest0Proc : proc(println : sb.PrintlnProc) {
    fmt.println("Does fmt.print go to stdout?");
    test_log := log.create_console_logger();
    context.logger = test_log;
    log.info("Does log.info go to stdout?");
    println("Does this print?");
    test_str := "How do I make a fully functional fmt.println pass through??";
    println(test_global);
}

GlobalAssign::proc() -> int {
    return 12345;
}
