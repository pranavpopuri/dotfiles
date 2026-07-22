; inherits: c
;
; C++ has no upstream locals.scm, so it gets zero local-variable tracking.
; Inheriting C gives us the important part: parameters are tagged as
; @local.definition.variable.parameter and every identifier as @local.reference,
; so Helix propagates the parameter's highlight (orange) to its uses in the body.
;
; Below: C++-only parameter forms that C's rules don't cover.

;; Default arguments, e.g.  void f(int x = 5)
(optional_parameter_declaration
  (identifier) @local.definition.variable.parameter)
(optional_parameter_declaration
  (_
    (identifier) @local.definition.variable.parameter))
(optional_parameter_declaration
  (_
    (_
      (identifier) @local.definition.variable.parameter)))

;; Lambdas get their own scope so their params resolve correctly
(lambda_expression) @local.scope
