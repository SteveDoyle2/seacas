C    Copyright(C) 1999-2020 National Technology & Engineering Solutions
C    of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C    NTESS, the U.S. Government retains certain rights in this software.
C    
C    See packages/seacas/LICENSE for details

C
C
C
      SUBROUTINE MIXVAR (NPNODE, BMESUR, DMESUR, SECOND, TERROR,
     &   EMIN, EMAX, EMINS, EMAXS, E1S)
C** MODIFIED BY: TED BLACKER
C** MODIFICATION DATE: 7/31/90
C** MODIFICATION: PASSED THE EMAX AND EMIN VARIABLES BACK OUT FOR USE
C
C** MODIFIED BY: TED BLACKER
C** MODIFICATION DATE: 8/2/90
C** MODIFICATION: PASSED THE EMAX AND EMIN VARIABLES IN NOW AS WELL
C
C***********************************************************************
C
C  SUBROUTINE MIXVAR = MIXES THE NODAL VARIABLES TO BE USED IN THE
C                      REMESHING USING PAVING.
C
C***********************************************************************
C
      DIMENSION BMESUR(NPNODE), DMESUR(NPNODE)
C
      LOGICAL SECOND, TRILIN, TERROR
C
      TRILIN = .TRUE.
C
      IF (SECOND) THEN
C
C  NORMALIZE THE NODE VARIABLES
C
         IF (TRILIN) THEN
C
C  WEIGHT THE ERROR MEASURE (BMESUR) BY A
C  TRILINEAR STRESS MEASURE (DMESUR) FUNCTION
C
            RMAX = 1.0
            CALL NORMND (NPNODE, BMESUR, RMAX)
            CALL NORMND (NPNODE, DMESUR, RMAX)
            X1 = .3
            X2 = .7
            Y1 = .3
            Y2 = 1.0
            DO 100 I = 1, NPNODE
               IF (DMESUR(I) .LE. X1) THEN
                  BMESUR(I) = BMESUR(I) * Y1
               ELSEIF (DMESUR(I) .LE. X2) THEN
                  BMESUR(I) = BMESUR(I) * ( (
     &               ((Y2 - Y1) * (DMESUR(I)- X1)) / (X2 - X1) ) + Y1)
               ENDIF
  100       CONTINUE
C
C
C  NOW (RE)NORMALIZE THE ERROR (BMESUR) VARIABLE
C
            RMAX = .6
            CALL NORMND (NPNODE, BMESUR, RMAX)
C
         ELSE
            RMAX = .6
            CALL NORMND (NPNODE, BMESUR, RMAX)
            CALL NORMND (NPNODE, DMESUR, RMAX)
C
            DO 110 I = 1, NPNODE
               BMESUR(I) = AMAX1 (BMESUR(I), DMESUR(I))
  110       CONTINUE
         ENDIF
C
C**               THE SIZE FACTOR TO BE 1.0 AT AN ERROR EQUAL TO
C**               THE TARGET ERROR.
C**               INSTEAD OF 1/7.
C
C  NOW NORMALIZE THE ERROR (BMESUR) VARIABLE
C
      ELSEIF (TERROR) THEN
C
C** MODIFIED BY: TED BLACKER
C** MODIFICATION DATE: 7/31/90
C** MODIFICATION: SET E1S TO BE .2 * TERR (WAS JUST TERR) AND SET
C**               EMAXS TO BE 1.5 * TERR (WAS 3.0 * TERR).  THIS IS
C**               CONSISTENT WITH THE TEST RUNS DONE ON HOW AGGRESSIVE THE
C**               ERROR MEASURE NEEDED TO BE IN ORDER TO GET TO A TARGET
C**               ERROR.
C
         EF1  = (EMAX - 1.0) / (EMAX - EMIN)
C
         DO 120 I = 1, NPNODE
            IF (BMESUR(I) .LE. EMINS) THEN
               BMESUR(I) = 0.0
            ELSEIF (BMESUR(I) .LE. E1S) THEN
               BMESUR(I) = (EF1 * (BMESUR(I) - EMINS)) / (E1S - EMINS)
            ELSEIF (BMESUR(I) .LT. EMAXS) THEN
               BMESUR(I) = EF1 + ( (1. - EF1) * (BMESUR(I) - E1S) /
     &            (EMAXS - E1S) )
            ELSE
               BMESUR(I) = 1.0
            ENDIF
  120    CONTINUE
C
C
C  NORMALIZE THE ERROR (BMESUR) VARIABLE
C
      ELSE
         RMAX = .6
         CALL NORMND (NPNODE, BMESUR, RMAX)
C
      ENDIF
C
      RETURN
C
      END
