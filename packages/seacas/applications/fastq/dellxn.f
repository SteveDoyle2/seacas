C    Copyright(C) 1999-2020 National Technology & Engineering Solutions
C    of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C    NTESS, the U.S. Government retains certain rights in this software.
C    
C    See packages/seacas/LICENSE for details

C

C
      SUBROUTINE DELLXN (MXND, LXN, NUID, NAVAIL, IAVAIL, NODE, LINE,
     &   NNN, ERR, NOROOM)
C***********************************************************************
C
C  SUBROUTINE DELLXN = DELETE LINE FROM THE LIST OF LINES FOR THIS NODE
C
C***********************************************************************
C
      DIMENSION LINES (20), LXN (4, MXND), NUID (MXND)
C
      LOGICAL ERR, NOROOM
C
      CALL GETLXN (MXND, LXN, NODE, LINES, NL, ERR)
      IF (NL.LT.1) THEN
         WRITE (*, 10000)NODE
         GOTO 110
      ENDIF
      IF (ERR) GOTO 110
C
      K = 0
      DO 100 I = 1, NL
         IF (LINES (I) .NE. LINE) THEN
            K = K + 1
            LINES (K) = LINES (I)
         ENDIF
  100 CONTINUE
C
      IF (K .NE. NL - 1) THEN
         WRITE (*, 10010) NODE, (LINES (I), I = 1, NL)
         ERR = .TRUE.
         GOTO 110
      ENDIF
      NL = NL-1
      CALL PUTLXN (MXND, NL, LXN, NUID, NODE, LINES, NAVAIL, IAVAIL,
     &   NNN, ERR, NOROOM)
C
  110 CONTINUE
      RETURN
C
10000 FORMAT (' ERROR IN DELLXN - NODE', I5, ' HAS NO LINES')
10010 FORMAT (' ERROR IN DELLXN - NODE:', I5, /, ' LINES:', 20I5)
C
      END
