/// Registers
// Control/Status Register (CSR)
typedef struct packed {
   bit en; // enable
   bit ie; // interrupt enable
   bit bb; // bus busy
   bit bc; // bus captured
   bit [3:0] bid; // bus id
} csr_reg;

// Data/Parameter Register (DPR)
typedef struct {
   bit [7:0] data;
} dpr_reg;

typedef enum bit [2:0] {
   START          = 3'b100,
   STOP           = 3'b101,
   READ_WITH_ACK  = 3'b010,
   READ_WITH_NAK  = 3'b011,
   WRITE          = 3'b001,
   SET_BUS        = 3'b110,
   WAIT           = 3'b000
} i2cmb_cmd;

// Command Register (CMDR)
typedef struct packed {
   bit don;  // Done. Indicates command completion
   bit nak;  // Data write was not acknowledged
   bit al;   // Arbitration Lost
   bit err;  // Error Indication
   bit r;    // Reserved bit
   i2cmb_cmd cmd; // Byte-level command code
} cmdr_reg;

typedef enum bit [2:0] {
   DONE             = 3'b000,
   ARBITRATION_LOST = 3'b010,
   NO_ACKNOWLEDGE   = 3'b001,
   BYTE             = 3'b100,
   ERROR            = 3'b011
} i2cmb_res;

// FSM States Register (FSMR)
typedef struct packed {
   bit [3:0] byte_fsm;  // Current state of byte-level FSM
   bit [3:0] bit_fsm;   // Current state of bit-level FSM
} fsmr_reg;


typedef enum {
   IDLE,
   BUS_TAKEN
} i2cmb_state;
