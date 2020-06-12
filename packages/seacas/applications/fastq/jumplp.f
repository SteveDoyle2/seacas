C    Copyright(C) 1999-2020 National Technology & Engineering Solutions
C    of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C    NTESS, the U.S. Government retains certain rights in this software.
C    
C    See packages/seacas/LICENSE for details

C
C
C
      FUNCTION JUMPLP (MXND, MLN, LNODES, INOW, IJUMP)
C***********************************************************************
C
C  FUNCTION JUMPLP = JUMPS IJUMP STEPS FORWARD AROUND THE CLOSED LOOP
C
C***********************************************************************
C
      DIMENSION LNODES (MLN, MXND)
C
      JUMPLP = INOW
      DO 100 I = 1, IJUMP
         JUMPLP = LNODES (3, JUMPLP)
  100 CONTINUE
      RETURN
C
      END
