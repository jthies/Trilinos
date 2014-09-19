C    Copyright (c) 2014, Sandia Corporation.
C    Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
C    the U.S. Governement retains certain rights in this software.
C    
C    Redistribution and use in source and binary forms, with or without
C    modification, are permitted provided that the following conditions are
C    met:
C    
C        * Redistributions of source code must retain the above copyright
C          notice, this list of conditions and the following disclaimer.
C    
C        * Redistributions in binary form must reproduce the above
C          copyright notice, this list of conditions and the following
C          disclaimer in the documentation and/or other materials provided
C          with the distribution.
C    
C        * Neither the name of Sandia Corporation nor the names of its
C          contributors may be used to endorse or promote products derived
C          from this software without specific prior written permission.
C    
C    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
C    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
C    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
C    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
C    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
C    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
C    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
C    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
C    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
C    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
C    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
C    

C $Id: bmschm.f,v 1.1 1990/11/30 11:04:04 gdsjaar Exp $
C $Log: bmschm.f,v $
C Revision 1.1  1990/11/30 11:04:04  gdsjaar
C Initial revision
C
C
CC* FILE: [.QMESH]BMSCHM.FOR
CC* MODIFIED BY: TED BLACKER
CC* MODIFICATION DATE: 7/6/90
CC* MODIFICATION: COMPLETED HEADER INFORMATION
C
      SUBROUTINE BMSCHM (NPER, KKK, LLL, NNN, ML, MS, NSPR, ISLIST,
     &   NINT, IFLINE, NLPS, ILLIST, LINKL, LINKS, MXNPER, MAXPRM, MAX3,
     &   MXND, X, Y, NID, NNPS, ANGLE, XN, YN, NUID, LXK, KXL, NXL, LXN,
     &   XSUB, YSUB, NIDSUB, INDX, IAVAIL, NAVAIL, CCW, HALFC, ERR)
C***********************************************************************
C
C  BMSCHM - "B" MESH SCHEME; CALCULATE A "TRANSITION" MAPPED MESH
C      (2 TRIANGULAR SUBREGIONS WITH 3 RECTANGULAR SUBREGIONS/TRIANGLE)
C
C***********************************************************************
C
      DIMENSION ISLIST(NSPR), NINT(ML), IFLINE(MS), NLPS(MS)
      DIMENSION ILLIST(MS*3), LINKL(2, ML), LINKS(2, MS)
      DIMENSION X(MXNPER), Y(MXNPER), NID(MXNPER*MAXPRM), NNPS(MAX3)
      DIMENSION ANGLE(MXNPER), XN(MXND), YN(MXND), NUID(MXND)
      DIMENSION LXK(4, MXND), KXL(2, 3*MXND), NXL(2, 3*MXND)
      DIMENSION LXN(4, MXND)
      DIMENSION XSUB(MXNPER), YSUB(MXNPER), NIDSUB(MXNPER), INDX(MXND)
C
      LOGICAL CCW, ERR, FINAL, HALFC
C
C  SET UP THE TRIANGLE DIVISIONS, AND FIND THE CENTER POINT
C
      CALL GETTRN (ML, MS, MAX3, NSPR, ISLIST, NINT, IFLINE, NLPS,
     &   ILLIST, LINKL, LINKS, X, Y, NID, NNPS, ANGLE, NPER, I1, I2,
     &   I3, I4, I5, I6, I7, I8, XCEN1, YCEN1, XCEN2, YCEN2, XMID1,
     &   YMID1, XMID2, YMID2, CCW, HALFC, ERR)
      FINAL = .FALSE.
C
C  SET UP THE FIRST SUBREGION, AND SEND IT OFF TO BE GENERATED
C
      IF (.NOT.ERR) THEN
         CALL SUBTRN (NPER, NEWPER, 1, X, Y, NID, XSUB, YSUB, NIDSUB,
     &      I1, I2, I3, I4, I5, I6, I7, I8, XCEN1, YCEN1, XCEN2, YCEN2,
     &      XMID1, YMID1, XMID2, YMID2, CCW, ERR)
         NNNOLD = NNN
         KKKOLD = KKK
         LLLOLD = LLL
         M1 = I2 - I1
         M2 = NPER - I8 + 1
         CALL RMESH (NEWPER, MXND, XSUB, YSUB, NIDSUB, XN, YN, NUID,
     &      LXK, KXL, NXL, LXN, M1, M2, KKK, KKKOLD, NNN, NNNOLD, LLL,
     &      LLLOLD, IAVAIL, NAVAIL, ERR)
      END IF
C
C  SET UP THE SECOND SUBREGION, AND SEND IT OFF TO BE GENERATED
C
      IF (.NOT.ERR) THEN
         CALL SUBTRN (NPER, NEWPER, 2, X, Y, NID, XSUB, YSUB, NIDSUB,
     &      I1, I2, I3, I4, I5, I6, I7, I8, XCEN1, YCEN1, XCEN2, YCEN2,
     &      XMID1, YMID1, XMID2, YMID2, CCW, ERR)
         NNNOLD = NNN
         KKKOLD = KKK
         LLLOLD = LLL
         M1 = I8 - I7
         M2 = I2 - I1
         CALL RMESH (NEWPER, MXND, XSUB, YSUB, NIDSUB, XN, YN, NUID,
     &      LXK, KXL, NXL, LXN, M1, M2, KKK, KKKOLD, NNN, NNNOLD, LLL,
     &      LLLOLD, IAVAIL, NAVAIL, ERR)
         CALL FIXSUB (MXND, NNNOLD, NNN, LLLOLD, LLL, KKKOLD, KKK, XN,
     &      YN, NUID, LXK, KXL, NXL, LXN, INDX, IAVAIL, NAVAIL, FINAL)
      END IF
C
C  SET UP THE THIRD SUBREGION, AND SEND IT OFF TO BE GENERATED
C
      IF (.NOT.ERR) THEN
         CALL SUBTRN (NPER, NEWPER, 3, X, Y, NID, XSUB, YSUB, NIDSUB,
     &      I1, I2, I3, I4, I5, I6, I7, I8, XCEN1, YCEN1, XCEN2, YCEN2,
     &      XMID1, YMID1, XMID2, YMID2, CCW, ERR)
         NNNOLD = NNN
         KKKOLD = KKK
         LLLOLD = LLL
         M1 = NPER - I8 + 1
         M2 = I3 - I2
         CALL RMESH (NEWPER, MXND, XSUB, YSUB, NIDSUB, XN, YN, NUID,
     &      LXK, KXL, NXL, LXN, M1, M2, KKK, KKKOLD, NNN, NNNOLD, LLL,
     &      LLLOLD, IAVAIL, NAVAIL, ERR)
         CALL FIXSUB (MXND, NNNOLD, NNN, LLLOLD, LLL, KKKOLD, KKK, XN,
     &      YN, NUID, LXK, KXL, NXL, LXN, INDX, IAVAIL, NAVAIL, FINAL)
      END IF
C
C  SET UP THE FOURTH SUBREGION, AND SEND IT OFF TO BE GENERATED
C
      IF (.NOT.ERR) THEN
         CALL SUBTRN (NPER, NEWPER, 4, X, Y, NID, XSUB, YSUB, NIDSUB,
     &      I1, I2, I3, I4, I5, I6, I7, I8, XCEN1, YCEN1, XCEN2, YCEN2,
     &      XMID1, YMID1, XMID2, YMID2, CCW, ERR)
         NNNOLD = NNN
         KKKOLD = KKK
         LLLOLD = LLL
         M1 = I5 - I4
         M2 = I6 - I5
         CALL RMESH (NEWPER, MXND, XSUB, YSUB, NIDSUB, XN, YN, NUID,
     &      LXK, KXL, NXL, LXN, M1, M2, KKK, KKKOLD, NNN, NNNOLD, LLL,
     &      LLLOLD, IAVAIL, NAVAIL, ERR)
         CALL FIXSUB (MXND, NNNOLD, NNN, LLLOLD, LLL, KKKOLD, KKK, XN,
     &      YN, NUID, LXK, KXL, NXL, LXN, INDX, IAVAIL, NAVAIL, FINAL)
      END IF
C
C  SET UP THE FIFTH SUBREGION, AND SEND IT OFF TO BE GENERATED
C
      IF (.NOT.ERR) THEN
         CALL SUBTRN (NPER, NEWPER, 5, X, Y, NID, XSUB, YSUB, NIDSUB,
     &      I1, I2, I3, I4, I5, I6, I7, I8, XCEN1, YCEN1, XCEN2, YCEN2,
     &      XMID1, YMID1, XMID2, YMID2, CCW, ERR)
         NNNOLD = NNN
         KKKOLD = KKK
         LLLOLD = LLL
         M1 = I7 - I6
         M2 = I5 - I4
         CALL RMESH (NEWPER, MXND, XSUB, YSUB, NIDSUB, XN, YN, NUID,
     &      LXK, KXL, NXL, LXN, M1, M2, KKK, KKKOLD, NNN, NNNOLD, LLL,
     &      LLLOLD, IAVAIL, NAVAIL, ERR)
         CALL FIXSUB (MXND, NNNOLD, NNN, LLLOLD, LLL, KKKOLD, KKK, XN,
     &      YN, NUID, LXK, KXL, NXL, LXN, INDX, IAVAIL, NAVAIL, FINAL)
      END IF
C
C  SET UP THE SIXTH SUBREGION, AND SEND IT OFF TO BE GENERATED
C
      IF (.NOT.ERR) THEN
         CALL SUBTRN (NPER, NEWPER, 6, X, Y, NID, XSUB, YSUB, NIDSUB,
     &      I1, I2, I3, I4, I5, I6, I7, I8, XCEN1, YCEN1, XCEN2, YCEN2,
     &      XMID1, YMID1, XMID2, YMID2, CCW, ERR)
         NNNOLD = NNN
         KKKOLD = KKK
         LLLOLD = LLL
         M1 = I6 - I5
         M2 = I4 - I3
         CALL RMESH (NEWPER, MXND, XSUB, YSUB, NIDSUB, XN, YN, NUID,
     &      LXK, KXL, NXL, LXN, M1, M2, KKK, KKKOLD, NNN, NNNOLD, LLL,
     &      LLLOLD, IAVAIL, NAVAIL, ERR)
         FINAL = .TRUE.
         CALL FIXSUB (MXND, NNNOLD, NNN, LLLOLD, LLL, KKKOLD, KKK, XN,
     &      YN, NUID, LXK, KXL, NXL, LXN, INDX, IAVAIL, NAVAIL, FINAL)
      END IF
C
      RETURN
      END
