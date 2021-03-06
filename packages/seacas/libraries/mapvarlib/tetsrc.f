C Copyright (c) 2007-2017 National Technology & Engineering Solutions of
C Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C NTESS, the U.S. Government retains certain rights in this software.
C
C Redistribution and use in source and binary forms, with or without
C modification, are permitted provided that the following conditions are
C met:
C
C     * Redistributions of source code must retain the above copyright
C       notice, this list of conditions and the following disclaimer.
C
C     * Redistributions in binary form must reproduce the above
C       copyright notice, this list of conditions and the following
C       disclaimer in the documentation and/or other materials provided
C       with the distribution.
C
C     * Neither the name of NTESS nor the names of its
C       contributors may be used to endorse or promote products derived
C       from this software without specific prior written permission.
C
C THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
C "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
C LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
C A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
C OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
C SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
C LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
C DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
C THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
C (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
C OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
C

      SUBROUTINE TETSRC(
     *  NDIM,     NPTS,     NPSRF,    NFSRF,    NISR,
     *  NRSR,     NRSS,     XYZE,     XYZP,     LS,
     *  ISRCHR,   RSRCHR,   IPT,      IELT,     IERR    )
C
C-----------------------------------------------------------------------
C
C DESCRIPTION:
C
C THIS SUBROUTINE CALCULATES THE CLOSEST POINT PROBLEM
C BETWEEN 'KOUNTS' PAIRS OF POINTS AND SURFACES.
C
C-----------------------------------------------------------------------
C
C FORMAL PARAMETERS
C
C MEMORY      : P=PERMANENT, S=SCRATCH
C NAME        : IMPLICIT A-H,O-Z REAL, I-N INTEGER
C TYPE        : INPUT_STATUS/OUTPUT_STATUS (I=INPUT,O=OUTPUT,P=PASSED,
C               U=UNMODIFIED,-=UNDEFINED)
C DESCRIPTION : DESCRIPTION OF VARIABLE
C
C-----------------------------------------------------------------------
C
C CALLING ARGUMENTS
C
C MEMORY NAME     TYPE   DESCRIPTION
C ---    ----     ---    -----------
C  P     NDIM     I/U    DIMENSION OF PROBLEM=3
C  P     NPTS     I/U    NUMBER OF POINTS TO BE SEARCHED
C  P     NPSRF    I/U    NUMBER OF POINTS THAT DEFINE THE SURFACE
C  P     NFSRF    I/U    NUMBER OF SURFACES
C  P     NISR     I/U    NUMBER OF INTEGER SEARCH RESULTS (>=1)
C  P     NRSR     I/U    NUMBER OF REAL SEARCH RESULTS (>=4)
C  P     NRSS     I/U    NUMBER OF REAL SEARCH SCRATCH MEMORY (=10)
C  P     XYZE     I/U    XYZ COORDS OF POINTS DEFINING ELEMENT
C  P     XYZP     I/U    XYZ COORDS OF POINTS TO BE SEARCHED
C  P     LS       I/U    CONNECTIVITY OF ELEMENTS (8*NFSRF),
C                        NUMBERS REFER TO LOCATIONS IN XYZE ARRAY
C  P     ISRCHR   I/O    INTEGER SEARCH RESULTS
C  P     RSRCHR   I/O    REAL SEARCH RESULTS
C  P     IPT      I/U    POINT PAIRED WITH SURFACE IELT
C  P     IELT     I/U    SURFACE PAIRED WITH POINT IPT
C
C-----------------------------------------------------------------------
C
      include 'toldat.blk'
      include 'tapes.blk'
C
C INPUT/OUTPUT ARRAYS
      DIMENSION
     *  XYZP(NPTS,NDIM)     ,XYZE(NPSRF,NDIM)  ,LS(4,NFSRF)    ,
     *  ISRCHR(NISR,NPTS)   ,RSRCHR(NRSR,NPTS)
      DIMENSION XX(27), YY(27), ZZ(27)
C
      IF( NISR .LT. 1 .OR. NRSR .LT. 3 .OR. NRSS .LT. 10 )THEN
        IERR = 1
        RETURN
      ENDIF
C
C check for Mesh-B point coincident with node of element in Mesh-A
C
      SIDE1 = (XYZE(LS(1,IELT),1)-XYZE(LS(2,IELT),1))**2
     &  + (XYZE(LS(1,IELT),2)-XYZE(LS(2,IELT),2))**2
     &  + (XYZE(LS(1,IELT),3)-XYZE(LS(2,IELT),3))**2
      SIDE2 = (XYZE(LS(1,IELT),1)-XYZE(LS(3,IELT),1))**2
     &  + (XYZE(LS(1,IELT),2)-XYZE(LS(3,IELT),2))**2
     &  + (XYZE(LS(1,IELT),3)-XYZE(LS(3,IELT),3))**2
      SIDE3 = (XYZE(LS(1,IELT),1)-XYZE(LS(4,IELT),1))**2
     &  + (XYZE(LS(1,IELT),2)-XYZE(LS(4,IELT),2))**2
     &  + (XYZE(LS(1,IELT),3)-XYZE(LS(4,IELT),3))**2
      SIDE4 = (XYZE(LS(2,IELT),1)-XYZE(LS(3,IELT),1))**2
     &  + (XYZE(LS(2,IELT),2)-XYZE(LS(3,IELT),2))**2
     &  + (XYZE(LS(2,IELT),3)-XYZE(LS(3,IELT),3))**2
      SIDE5 = (XYZE(LS(2,IELT),1)-XYZE(LS(4,IELT),1))**2
     &  + (XYZE(LS(2,IELT),2)-XYZE(LS(4,IELT),2))**2
     &  + (XYZE(LS(2,IELT),3)-XYZE(LS(4,IELT),3))**2
      SIDE6 = (XYZE(LS(3,IELT),1)-XYZE(LS(4,IELT),1))**2
     &  + (XYZE(LS(3,IELT),2)-XYZE(LS(4,IELT),2))**2
     &  + (XYZE(LS(3,IELT),3)-XYZE(LS(4,IELT),3))**2
      SIDMIN = MIN(SIDE1,SIDE2,SIDE3,SIDE4,SIDE5,SIDE6)
      COTEST = EPS*EPS*SIDMIN
      DO 110 I = 1, 4
        A = XYZE(LS(I,IELT),1) - XYZP(IPT,1)
        B = XYZE(LS(I,IELT),2) - XYZP(IPT,2)
        C = XYZE(LS(I,IELT),3) - XYZP(IPT,3)
        DIST = A**2 + B**2 + C**2
        IF (DIST .LT. COTEST)THEN
C
C coincident node, so fill search results arrays
C no need to check for better search result
C
          INODE = I
          ISRCHR(1,IPT) = IELT
          CALL NODE (6,INODE,RSRCHR(1,IPT),RSRCHR(2,IPT),
     &      RSRCHR(3,IPT))
          GO TO 100
        END IF
 110  CONTINUE
C
C Mesh-B point not coincident with Mesh-A node so compute isoparametric
C coordinates. Use Newton's method
C
      SG = 0.
      TG = 0.
      RG = 0.
      ITER = 0
C
C Build Jacobian and invert
C
      DO 120 I = 1, 4
        XX(I) = XYZE(LS(I,IELT),1)
        YY(I) = XYZE(LS(I,IELT),2)
        ZZ(I) = XYZE(LS(I,IELT),3)
 120  CONTINUE
 130  CONTINUE
      CALL JACOBN (6,XX,YY,ZZ,SG,TG,RG,A11,A12,A13,A21,A22,A23,
     &  A31,A32,A33,F1,F2,F3)
      DETA = A11*(A22*A33 - A23*A32) - A12*(A21*A33 - A31*A23)
     &  + A13*(A21*A32 - A31*A22)
      IF (ABS(DETA) .LT. 1.E-25)THEN
        CALL ERROR ('SRCHT',
     &    'ZERO JACOBIAN FOUND DURING NEWTON ITERATION',
     &    'MESH-A ELEMENT',IELT,
     &    ' ',0,' ',' ',0)
        GO TO 100
      END IF
C
      AI11 =  (A22*A33 - A23*A32)/DETA
      AI12 = -(A12*A33 - A32*A13)/DETA
      AI13 =  (A23*A12 - A13*A22)/DETA
      AI21 = -(A21*A33 - A31*A23)/DETA
      AI22 =  (A11*A33 - A13*A31)/DETA
      AI23 = -(A11*A23 - A21*A13)/DETA
      AI31 =  (A21*A32 - A31*A22)/DETA
      AI32 = -(A11*A32 - A31*A12)/DETA
      AI33 =  (A11*A22 - A12*A21)/DETA
C
      FS = F1 - XYZP(IPT,1)
      FT = F2 - XYZP(IPT,2)
      FR = F3 - XYZP(IPT,3)
      SNEW = SG - (AI11*FS + AI12*FT + AI13*FR)
      TNEW = TG - (AI21*FS + AI22*FT + AI23*FR)
      RNEW = RG - (AI31*FS + AI32*FT + AI33*FR)
C
      ITER = ITER + 1
      DS = ABS(SNEW-SG)
      DT = ABS(TNEW-TG)
      DR = ABS(RNEW-RG)
      IF (DS .LT. TOL .AND. DT .LT. TOL .AND. DR .LT. TOL) GO TO 300
      SG = SNEW
      TG = TNEW
      RG = RNEW
      IF (ITER .EQ. ITERMX)GO TO 100
      GO TO 130
C
 300  CONTINUE
C
C Newton converged, load up search results arrays if appropriate
C
      IF (ABS(SNEW) .LT. STRLMT .AND. ABS(TNEW) .LT. STRLMT .AND.
     &  ABS(RNEW) .LT. STRLMT)THEN
C
C Search was adequate
C
        FTEST = MAX(ABS(RSRCHR(1,IPT)),ABS(RSRCHR(2,IPT)),
     &    ABS(RSRCHR(3,IPT)))
        FCOMP = MAX(ABS(SNEW),ABS(TNEW),ABS(RNEW))
        IF (FTEST .GT. FCOMP .OR. ISRCHR(1,IPT) .EQ. 0)THEN
C
C New search is better or first find, replace search results
C
          ISRCHR(1,IPT) = IELT
          RSRCHR(1,IPT) = SNEW
          RSRCHR(2,IPT) = TNEW
          RSRCHR(3,IPT) = RNEW
        END IF
      END IF
 100  CONTINUE
      RETURN
      END
