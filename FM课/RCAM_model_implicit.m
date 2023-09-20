function FVAL = RCAM_model_implicit(XDOT,X,U)

FVAL = RCAM_model(X,U) - XDOT;