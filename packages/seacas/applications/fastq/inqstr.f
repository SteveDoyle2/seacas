C    Copyright(C) 1999-2020 National Technology & Engineering Solutions
C    of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C    NTESS, the U.S. Government retains certain rights in this software.
C    
C    See packages/seacas/LICENSE for details

c
C
C
      SUBROUTINE INQSTR (PROMPT, IANS)
C***********************************************************************
C
C  SUBROUTINE INQSTR = INPUTS CHARACTER STRINGS
C
C***********************************************************************
C
      CHARACTER* (*) PROMPT, IANS, HOLD*80
C
      IZ = 0
  100 CONTINUE
      CALL GETINP (IZ, IZ, PROMPT, HOLD, IOSTAT)
      IF (IOSTAT .EQ. 0) THEN
         CALL STRCUT (HOLD)
         IANS = HOLD (1:)
         RETURN
      ELSEIF (IOSTAT .LT. 0) THEN
         IANS = ' '
         RETURN
      ELSEIF (IOSTAT .GT. 0) THEN
         WRITE (*, 10010)
         GOTO 100
      ENDIF
C
10010 FORMAT (' BAD CHARACTER STRING  -  TRY AGAIN')
      END
