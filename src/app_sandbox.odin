package app
import sb "sandbox"
import "core:fmt"
import "core:log"

@export
DllTest0::proc() {
    fmt.print("Does fmt.print go to stdout?");
    test_log := log.create_console_logger();
    context.logger = test_log;
    log.info("Does log.info go to stdout?");
}
