;; A single assembly instruction is the closest analogue to a "statement"
(instruction) @function.around
(call_statement) @function.around

;; Labels introduce a named scope / symbol
(label) @class.around
(macro_label) @class.around
(numeric_label) @class.around

;; Conditional branches
((instruction
   mnemonic: (instruction_mnemonic) @_mnemonic) @conditional.around
 (#match? @_mnemonic "^(b|bc|beq|bne|beqz|bnez|blez|bgez|bltz|bgtz|bnel|beql|blt|bgt|ble|bge)$"))

;; Unconditional jumps and calls
((instruction
   mnemonic: (instruction_mnemonic) @_mnemonic) @loop.around
 (#match? @_mnemonic "^(j|jr|jal|jalr)$"))

;; Operand lists behave like parameter lists
(operands) @parameter.around
(operands
  (_) @parameter.inside)

;; Comments
(comment) @comment.inside
(comment)+ @comment.around
