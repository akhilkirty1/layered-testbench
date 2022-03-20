package wb_pkg;
   import ncsu_pkg::*;
   `include "ncsu_macros.svh"

   `include "src/wb_typedefs.svh"
   `include "src/wb_configuration.svh"
   `include "src/wb_transaction.svh"
   `include "src/wb_driver.svh"
   `include "src/wb_monitor.svh"
   `include "src/wb_coverage.svh"
   `include "src/wb_agent.svh"

   typedef enum {READ, WRITE} wb_op_t;
   
endpackage
