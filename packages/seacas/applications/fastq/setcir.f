C    Copyright(C) 1999-2020 National Technology & Engineering Solutions
C    of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C    NTESS, the U.S. Government retains certain rights in this software.
C    
C    See packages/seacas/LICENSE for details

C
C
C
      SUBROUTINE SETCIR (MXND, MLN, NLOOP, LNODES, NODE, ERR)
C***********************************************************************
C
C  SUBROUTINE SETCIR = MARKS ALL THE NODES IN THE CIRCULAR LOOP
C  AS SIDES EXCEPT FOR ROW CORNERS
C
C***********************************************************************
C
      DIMENSION LNODES (MLN, MXND)
C
      LOGICAL ERR
C
      ERR = .FALSE.
C
      KOUNT = 0
      INOW = NODE
      NEWNOD = NODE
C
  100 CONTINUE
      INOW = LNODES (3, INOW)
      IF (LNODES (1, INOW) .LE. 4) THEN
         LNODES (1, INOW) = 3
      ELSEIF (LNODES (1, INOW) .EQ. 6) THEN
         LNODES (1, INOW) = 5
      ENDIF
      IF ( (LNODES (1, NEWNOD) .EQ. 3) .AND.
     &   ( (LNODES (1, INOW) .EQ. 5) .OR. (LNODES (1, INOW) .EQ. 7)) )
     &   THEN
         NEWNOD = INOW
      ENDIF
C
      IF (INOW .EQ. NODE) THEN
         NODE = NEWNOD
         RETURN
      ENDIF
C
      KOUNT = KOUNT + 1
      IF (KOUNT .GT. NLOOP) THEN
         CALL MESAGE('PROBLEMS IN SETCIR WITH LOOP NOT CLOSING')
         ERR = .TRUE.
         GOTO 110
      ENDIF
      GOTO 100
C
  110 CONTINUE
C
      RETURN
C
      END
