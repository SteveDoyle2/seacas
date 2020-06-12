C Copyright(C) 1999-2020 National Technology & Engineering Solutions
C of Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C NTESS, the U.S. Government retains certain rights in this software.
C 
C See packages/seacas/LICENSE for details

C=======================================================================
      SUBROUTINE FFRRNG (IFLD, INTYP, CFIELD, RFIELD, EXPECT, RMAX,
     &   RANGE, *)
C=======================================================================
c
c

C   --*** FFVRNG *** (FFLIB) Parse free-field real range
C   --   Written by Amy Gilkey - revised 02/24/86
C   --   Modified by Greg Sjaardema - 02/08/89
C   --
C   --FFVRNG parses a range of reals.  A range has one of the following
C   --forms:
C   --            r1                  assume r2 = r1, r3 = 0.
C   --            r1 TO r2            assume r3 = 0.
C   --            r1 TO r2 STEP r3
C   --
C   --Parameters:
C   --   IFLD - IN/OUT - the index of the current field number, incremented
C   --   INTYP - IN - the input type array from the free-field reader
C   --   CFIELD - IN - the input string array from the free-field reader
C   --   RFIELD - IN - the input integer array from the free-field reader
C   --   EXPECT - IN - the type of range being parsed, for error
C   --   RMAX - IN - the maximum range value
C   --   RANGE - OUT - the input range value array:
C   --          (1) = r1, (2) = r2, (3) = r3;
C   --      partially set on error
C   --   * - return statement if the range is invalid; message is printed

C   --Routines Called:
C   --   LENSTR - (STRLIB) Find string length

      INTEGER IFLD
      INTEGER INTYP(*)
      CHARACTER*(*) CFIELD(*)
      REAL RFIELD(*)
      CHARACTER*(*) EXPECT
      REAL RMAX
      REAL RANGE(3)

      CHARACTER*80 STRA
      CHARACTER*80 ERRMSG

      RANGE(1) = 0.
      RANGE(2) = 0.
      RANGE(3) = 0.

      IF (INTYP(IFLD) .GE. -1) THEN

C      --Get starting number

         IF (INTYP(IFLD) .LT. 1) THEN
            WRITE (ERRMSG, 10000)
     &         EXPECT, CFIELD(IFLD)(:LENSTR(CFIELD(IFLD)))
            CALL PRTERR ('CMDERR', ERRMSG(:LENSTR(ERRMSG)))
            GOTO 100
         END IF
         RANGE(1) = RFIELD(IFLD)
         RANGE(2) = RANGE(1)
         RANGE(3) = 0.
         IFLD = IFLD + 1

         IF (INTYP(IFLD) .EQ. 0) THEN

C         --Get TO and ending value

            IF (CFIELD(IFLD) .NE. 'TO') THEN
               WRITE (ERRMSG, 10000)
     &            '"TO"', CFIELD(IFLD)(:LENSTR(CFIELD(IFLD)))
               CALL PRTERR ('CMDERR', ERRMSG(:LENSTR(ERRMSG)))
               GOTO 100
            END IF
            IFLD = IFLD + 1

            IF (INTYP(IFLD) .LT. 1) THEN
               STRA = 'TO ' // EXPECT
               WRITE (ERRMSG, 10000) STRA(:LENSTR(STRA)),
     &            CFIELD(IFLD)(:LENSTR(CFIELD(IFLD)))
               CALL PRTERR ('CMDERR', ERRMSG(:LENSTR(ERRMSG)))
               GOTO 100
            END IF
            RANGE(2) = RFIELD(IFLD)
            IFLD = IFLD + 1

            IF (INTYP(IFLD) .EQ. 0) THEN

C            --Get BY and step value

               IF (CFIELD(IFLD) .NE. 'BY') THEN
                  WRITE (ERRMSG, 10000)
     &               '"BY"', CFIELD(IFLD)(:LENSTR(CFIELD(IFLD)))
                  CALL PRTERR ('CMDERR', ERRMSG(:LENSTR(ERRMSG)))
                  GOTO 100
               END IF
               IFLD = IFLD + 1

               IF (INTYP(IFLD) .LT. 1) THEN
                  WRITE (ERRMSG, 10000)
     &               'BY value', CFIELD(IFLD)(:LENSTR(CFIELD(IFLD)))
                  CALL PRTERR ('CMDERR', ERRMSG(:LENSTR(ERRMSG)))
                  GOTO 100
               END IF
               RANGE(3) = RFIELD(IFLD)
               IFLD = IFLD + 1
            END IF
         END IF

C         IF (RANGE(3) .EQ. 0) THEN
C            WRITE (ERRMSG, 10010, IOSTAT=IDUM)
C     &         'Invalid BY value', RANGE(3)
C            CALL SQZSTR (ERRMSG, L)
C            CALL PRTERR ('CMDERR', ERRMSG(:L))
C            GOTO 110
C         END IF
         IF ((RANGE(3) .GT. 0.) .AND. (RANGE(1) .GT. RANGE(2))) THEN
            STRA = 'Starting ' // EXPECT
            WRITE (ERRMSG, 10010, IOSTAT=IDUM) STRA(:LENSTR(STRA)),
     &         RANGE(1), ' > ending ', RANGE(2)
            CALL SQZSTR (ERRMSG, L)
            CALL PRTERR ('CMDERR', ERRMSG(:L))
            GOTO 110
         END IF
         IF ((RANGE(3) .LT. 0.) .AND. (RANGE(1) .LT. RANGE(2))) THEN
            STRA = 'Starting ' // EXPECT
            WRITE (ERRMSG, 10010, IOSTAT=IDUM) STRA(:LENSTR(STRA)),
     &         RANGE(1), ' < ending ', RANGE(2), ' with negative step'
            CALL SQZSTR (ERRMSG, L)
            CALL PRTERR ('CMDERR', ERRMSG(:L))
         END IF
         IF (MIN (RANGE(1), RANGE(2)) .GT. RMAX) THEN
            STRA = 'Minimum ' // EXPECT
            WRITE (ERRMSG, 10010, IOSTAT=IDUM) STRA(:LENSTR(STRA)),
     &         MIN (RANGE(1), RANGE(2)), ' > maximum ', RMAX
            CALL SQZSTR (ERRMSG, L)
            CALL PRTERR ('CMDERR', ERRMSG(:L))
            GOTO 110
         END IF

         IF (RANGE(1) .GT. RMAX) RANGE(1) = RMAX
         IF (RANGE(2) .GT. RMAX) RANGE(2) = RMAX
      END IF

      RETURN

  100 CONTINUE
      IF (INTYP(IFLD) .GE. -1) IFLD = IFLD + 1
  110 CONTINUE
      RETURN 1
10000  FORMAT ('Expected ', A, ', not "', A, '"')
10010  FORMAT (A, 1PE10.3, A, 1PE10.3, A)
      END
