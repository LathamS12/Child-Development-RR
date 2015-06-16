****************************************************************************
* Name: Erica Greenberg
* Purpose: To assess our new state regulations database via ECLS-B
* Date: June 23, 2014
* Using: ECLS Regulations Database, ECLS-B
****************************************************************************

clear all
set maxvar 30000

* 1. load ECLS-B
* -----------------

use "F:\NCES Data\ECLS-B\Extracted Data\eclsb.dta", clear



* 3. identify primary care arrangements when children are 2 years old (2003, wave 2) and 4 years old (2005, wave 3)
* -------------------------------------------------------------------------------------------------------------------

forv wave = 2/3 {				
	
	foreach type in dc oth fh hs pk pa {
		gen `type'`wave' = .
	}	
	
* define homes using ECEP response (UP026) and fee information from providers and parents
	replace fh`wave' = 1 if J`wave'INHOME==2 & (P`wave'RFEE==1 | P`wave'NFEE==1 | (J`wave'EARNED>0 & J`wave'EARNED~=.))
	replace fh`wave' = 1 if J`wave'INHOME==2 & P`wave'RFEE==-1		// i.e., 9 missing cases (see email 9.20.12)
	replace oth`wave' = 1 if J`wave'INHOME==1 | (J`wave'INHOME==2 & fh`wave'~=1)
* define parental care using parent response/ECLS primary care arrangement variable (X-PRMARR)
	replace pa`wave' = 1 if X`wave'PRMARR==0
}
* define centers using director response on ECEP interview (CI002)
	replace dc2 = 1 if J2LOCCRE==2
	replace dc3 = 1 if J3TYPPRO==3 | J3TYPPRO==5 | J3TYPPRO==6	// child care center, preschool/nursery school, some other center-based program
	replace hs3 = 1 if J3TYPPRO==4
	replace pk3 = 1 if J3TYPPRO==1 | J3TYPPRO==2

* define cases that were not part of the ECEP interview by parent response/ECLS primary care arrangement variable (X-PRMARR)
	forv wave = 2/3 {
		replace fh`wave' = 1 if fh`wave'==. & oth`wave'==. & dc`wave'==. & hs`wave'==. & pk`wave'==. & ((X`wave'PRMARR==2 & (P`wave'RFEE==1 | P`wave'NFEE==1 | (J`wave'EARNED>0 & J`wave'EARNED~=.))) | (X`wave'PRMARR==5 & (P`wave'RFEE==1 | P`wave'NFEE==1 | (J`wave'EARNED>0 & J`wave'EARNED~=.))))
		replace oth`wave' = 1 if fh`wave'==. & oth`wave'==. & dc`wave'==. & hs`wave'==. & pk`wave'==. & (X`wave'PRMARR==1 | (X`wave'PRMARR==2 & fh`wave'~=1) | X`wave'PRMARR==3 | X`wave'PRMARR==4 | (X`wave'PRMARR==5 & fh`wave'~=1) | X`wave'PRMARR==6)
	}
		replace dc2 = 1 if fh2==. & oth2==. & dc2==. & hs2==. & pk2==. & X2PRMARR==7
		replace dc3 = 1 if fh3==. & oth3==. & dc3==. & hs3==. & pk3==. & X3PRMARR==7 & (P3PRTYPE==1 | P3PRTYPE==2 | P3PRTYPE==3 | P3PRTYPE==5)
		replace hs3 = 1 if fh3==. & oth3==. & dc3==. & hs3==. & pk3==. & X3PRMARR==8
		replace pk3 = 1 if fh3==. & oth3==. & dc3==. & hs3==. & pk3==. & X3PRMARR==7 & P3PRTYPE==4

* recode as parental care cases where lack of ECEP interview can be attributed to no nonparental care arrangement
	forv wave = 2/3 {
		replace pa`wave' = 1 if X`wave'STCCP==4
		replace dc`wave' = 0 if X`wave'STCCP==4
		replace fh`wave' = 0 if X`wave'STCCP==4
		replace oth`wave' = 0 if X`wave'STCCP==4
	}	
		replace hs3 = 0 if X3STCCP==4
		replace pk3 = 0 if X3STCCP==4
	
* categories cover all children except those whose care type was "not ascertained" (3 per wave); they do not overlap
	replace dc2 = 0 if fh2==1 | oth2==1 | pa2==1
	replace fh2 = 0 if dc2==1 | oth2==1 | pa2==1
	replace oth2 = 0 if dc2==1 | fh2==1 | pa2==1
	replace pa2 = 0 if dc2==1 | fh2==1 | oth2==1

	replace dc3 = 0 if fh3==1 | hs3==1 | pk3==1 | oth3==1 | pa3==1
	replace fh3 = 0 if dc3==1 | hs3==1 | pk3==1 | oth3==1 | pa3==1
	replace oth3 = 0 if dc3==1 | fh3==1 | hs3==1 | pk3==1 | pa3==1
	replace hs3 = 0 if dc3==1 | fh3==1 | pk3==1 | oth3==1 | pa3==1
	replace pk3 = 0 if dc3==1 | fh3==1 | hs3==1 | oth3==1 | pa3==1
	replace pa3 = 0 if dc3==1 | fh3==1 | hs3==1 | pk3==1 | oth3==1
		
	gen type2 = ""
	replace type2 = "fh" if fh2==1
	replace type2 = "dc" if dc2==1
	replace type2 = "pa" if pa2==1
	replace type2 = "oth" if oth2==1

	gen type3 = ""
	replace type3 = "fh" if fh3==1
	replace type3 = "dc" if dc3==1
	replace type3 = "pk" if pk3==1
	replace type3 = "hs" if hs3==1
	replace type3 = "pa" if pa3==1
	replace type3 = "oth" if oth3==1

	gen formal2 = 1 if dc2==1
	replace formal2 = 0 if fh2==1 | oth2==1 | pa2==1
	gen informal2 = 1 if fh2==1 | oth2==1 
	replace informal2 = 0 if dc2==1 | pa2==1

	gen formal3 = 1 if dc3==1 | hs3==1 | pk3==1
	replace formal3 = 0 if fh3==1 | oth3==1 | pa3==1
	gen informal3 = 1 if fh3==1 | oth3==1 
	replace informal3 = 0 if dc3==1 | hs3==1 | pk3==1 | pa3==1

	gen fccformal2 = 1 if dc2==1 | fh2==1
	replace fccformal2 = 0 if oth2==1 | pa2==1

	gen fccformal3 = 1 if dc3==1 | hs3==1 | pk3==1 | fh3==1
	replace fccformal3 = 0 if oth3==1 | pa3==1


* 4. clean and save variables of interest
* ---------------------------------------

rename I_ID childid

*program quality and caregiver characteristics

forv wave = 2/3 {
	foreach measure in edt ongot ongoht ratio turnover mqecet aget ///
		cwhite cblack chisp casian cother ecedeg ececourse cda exp HQT LQT ///
		treads readevery mathevery tvhrs playout zoo library comp gampuzz writcurr wholeclass chisel carehrs ///
		smokedet firstaid outlet ers arnett {
			g `measure'`wave' = .	
	}
}

forv wave = 2/3 {
*age
	recode J`wave'CGBDYY -9=. -8=. -7=. -1=. 
	replace aget2 = 2003 - J2CGBDYY
	replace aget3 = 2005 - J3CGBDYY
				 
*education
	recode J`wave'CGEDUC -9=. -8=. -7=. -1=. 13=12 14=12.5 15=13 16=12.5 17=14 18=16 19=17 20=18 21=20 22=20
	replace edt`wave' = J`wave'CGEDUC if dc`wave'==1 | fh`wave'==1 | oth`wave'==1
	replace edt3 = J3CGEDUC if hs3==1 | pk3==1

*cda
	recode J`wave'CGCDAC -9=0 -8=. -7=. -1=0 2=0 3=0
	replace cda`wave' = J`wave'CGCDAC if dc`wave'==1 | fh`wave'==1 | oth`wave'==1
	replace cda3 = J3CGCDAC if hs3==1 | pk3==1

*other degree in ece or related field
	recode J`wave'CGECHD -9=0 -8=. -1=0 2=0
	replace ecedeg`wave' = J`wave'CGECHD if dc`wave'==1 | fh`wave'==1 | oth`wave'==1 
	replace ecedeg3 = J3CGECHD if hs3==1 | pk3==1

*ongoing training (binary)
	recode J`wave'ERLYED -9=0 -1=0 2=0 
	replace ongot`wave' = J`wave'ERLYED if dc`wave'==1 | fh`wave'==1 | oth`wave'==1 
	replace ongot3 = J3ERLYED if hs3==1 | pk3==1
	
	**note: hours of training listed in categories (item BK090 in the preschool wave)

*years of experience
	recode J`wave'CCPYRS -9=. -8=. -7=. -1=.
	recode J`wave'CCPMOS -9=. -8=. -7=. -1=.
	replace exp`wave' = J`wave'CCPYRS + J`wave'CCPMOS/12 if dc`wave'==1 | fh`wave'==1 | oth`wave'==1 
	replace exp3 = J3CCPYRS + J3CCPMOS/12 if hs3==1 | pk3==1

*child: teacher ratios
	recode J`wave'NUMCH -9=0 -8=. -7=. -1=0
	recode J`wave'NUMPD -9=. -8=. -7=. -1=. 0=.
	
	replace ratio2 = ((J2NUMCH + 1)/J2NUMPD) if P2SAMETW~=1 & (dc2==1 | fh2==1 | oth2==1)
	replace ratio2 = ((J2NUMCH + 2)/J2NUMPD) if P2SAMETW==1 & (dc2==1 | fh2==1 | oth2==1)
	replace ratio2 = ((J2NUMCH + 1)/1) if P2SAMETW~=1 & J2NUMPD==. & (fh2==1 | oth2==1)
	replace ratio2 = ((J2NUMCH + 2)/1) if P2SAMETW==1 & J2NUMPD==. & (fh2==1 | oth2==1)
	
	replace ratio3 = ((J3NUMCH + 1)/J3NUMPD) if P3SAMETW~=1 & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)
	replace ratio3 = ((J3NUMCH + 2)/J3NUMPD) if P3SAMETW==1 & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)
	replace ratio3 = ((J3NUMCH + 1)/1) if P3SAMETW~=1 & J3NUMPD==. & (fh3==1 | oth3==1)
	replace ratio3 = ((J3NUMCH + 2)/1) if P3SAMETW==1 & J3NUMPD==. & (fh3==1 | oth3==1)
	
*turnover (only for center-based care): how many staff (full- or part-time) have left the program in the past 12 months?
	recode J`wave'CGVRLF -9=. -8=. -7=. -1=.
	recode J`wave'CGVRFT -9=. -8=. -7=. -1=.
	recode J`wave'CGVRPT -9=. -8=. -7=. -1=.
	replace turnover`wave' = J`wave'CGVRLF/(J`wave'CGVRFT + J`wave'CGVRPT) if dc`wave'==1
	replace turnover3 = J3CGVRLF/(J3CGVRFT + J3CGVRPT) if pk3==1 | hs3==1

*pre-service ece courses: binary for wave 2, number of courses for preschool wave
	recode J2CRSWRK -9=0 -1=0 2=0 
	replace mqecet2 = J2CRSWRK if dc2==1 | fh2==1 | oth2==1
	recode J3EARLED -9=0 -8=. -7=. -1=0 
	recode J3CHDEV -9=0 -8=. -7=. -1=0
	replace mqecet3 = J3EARLED + J3CHDEV if dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1

*caregiver reads books 
	recode J2READBO -9=. -1=.
	*1 = not at all, 2 = once or twice/week, 3 = 3 to 6 times/week, 4 = every day
	recode J3TMREAD -9=. -8=. -7=. -1=.
	*number of times/week
	replace treads2 = 0 if (J2READBO==1 | J2READBO==2 | J2READBO==3) & (dc2==1 | fh2==1 | oth2==1)
	replace treads2 = 1 if J2READBO==4 & (dc2==1 | fh2==1 | oth2==1)
	replace treads3 = J3TMREAD if dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1

*reading activities everyday
	recode J3LETTRS -9=. -8=. -7=. 
	recode J3WRITNG -9=. -8=. -7=.  
	recode J3NEWWRD -9=. -8=. -7=. 
	recode J3STORY  -9=. -8=. -7=. 
	recode J3PHONIC -9=. -8=. -7=. 
	recode J3BIGBKS -9=. -8=. -7=. 
	recode J3NOPRNT -9=. -8=. -7=. 
	recode J3RETELL -9=. -8=. -7=. 
	recode J3CONPRN -9=. -8=. -7=. 
	recode J3OWNNAM -9=. -8=. -7=. 
	recode J3RHYME  -9=. -8=. -7=. 
	replace readevery3 = 1 if (J3LETTRS==5 | J3WRITNG==5 | J3NEWWRD==5 | J3STORY==5 | J3PHONIC==5 | J3BIGBKS==5 | J3NOPRNT==5 | J3RETELL==5 | J3CONPRN==5 | J3OWNNAM==5 | J3RHYME==5) & (dc3==1 | fh3==1 | oth3==1 | hs3==1 | pk3==1)
	replace readevery3 = 0 if (J3LETTRS<5 & J3WRITNG<5 & J3NEWWRD<5 & J3STORY<5 & J3PHONIC<5 & J3BIGBKS<5 & J3NOPRNT<5 & J3RETELL<5 & J3CONPRN<5 & J3OWNNAM<5 & J3RHYME<5) & (dc3==1 | fh3==1 | oth3==1 | hs3==1 | pk3==1)
	
*math activities everyday 
	recode J3CNTOUT -9=. -8=. -7=. 
	recode J3GEOMTR -9=. -8=. -7=.  
	recode J3CNTMNP -9=. -8=. -7=. 
	recode J3MTHGAM -9=. -8=. -7=.
	recode J3MUSIC -9=. -8=. -7=.
	recode J3CREATV -9=. -8=. -7=. 
	recode J3RULERS -9=. -8=. -7=. 
	recode J3CALNDR -9=. -8=. -7=. 
	recode J3TELTME -9=. -8=. -7=. 
	recode J3SHAPS -9=. -8=. -7=. 
	replace mathevery3 = 1 if (J3CNTOUT==5 | J3GEOMTR==5 | J3CNTMNP==5 | J3MTHGAM==5 | J3MUSIC==5 | J3CREATV==5 | J3RULERS==5 | J3CALNDR==5 | J3TELTME==5 | J3SHAPS==5) & (dc3==1 | fh3==1 | oth3==1 | hs3==1 | pk3==1)
	replace mathevery3 = 0 if (J3CNTOUT<5 & J3GEOMTR<5 & J3CNTMNP<5 & J3MTHGAM<5 & J3MUSIC<5 & J3CREATV<5 & J3RULERS<5 & J3CALNDR<5 & J3TELTME<5 & J3SHAPS<5) & (dc3==1 | fh3==1 | oth3==1 | hs3==1 | pk3==1)
	
*television hours
	recode J`wave'TVHRS -9=. -8=. -7=. -1=. 995=0
	replace tvhrs`wave' = J`wave'TVHRS if dc`wave'==1 | fh`wave'==1 | oth`wave'==1
	replace tvhrs3 = J3TVHRS if hs3==1 | pk3==1

*outside for a walk or to play in the yard, a park, or playground at least once a day
	replace J`wave'OUTSDE = . if J`wave'OUTSDE<0
	replace playout2 = 1 if (J2OUTSDE==1 | J2OUTSDE==2) & (dc2==1 | fh2==1 | oth2==1)
	replace playout2 = 0 if (J2OUTSDE==3 | J2OUTSDE==4 | J2OUTSDE==5 | J2OUTSDE==6) & (dc2==1 | fh2==1 | oth2==1)

	replace playout3 = 1 if J3OUTSDE==1 & (fh3==1 | oth3==1)
	replace playout3 = 0 if (J3OUTSDE==2 | J3OUTSDE==3 | J3OUTSDE==4) & (fh3==1 | oth3==1)
	
*trip to the zoo
	*for the 2-year-old wave: in the past month, have you visited a zoo, aquarium, or petting farm?
	replace zoo2 = 1 if J2VSTZOO==1 & (dc2==1 | fh2==1 | oth2==1)
	replace zoo2 = 0 if J2VSTZOO==2 & (dc2==1 | fh2==1 | oth2==1)
	
	*for the preschool wave: in the past month, how often have you gone to a public place like a zoo or museum? (1=once a day or more, few times a week, or few times a month; 0=rarely/not at all)
	replace zoo3 = 1 if (J3PUBLIC==1 | J3PUBLIC==2 | J3PUBLIC==3) & (fh3==1 | oth3==1)
	replace zoo3 = 0 if J3PUBLIC==4 & (fh3==1 | oth3==1)

*trip to the library
	*for the 2-year-old wave: in the past month, have you visited a library?
	replace library2 = 1 if J2VSTLIB==1 & (dc2==1 | fh2==1 | oth2==1)
	replace library2 = 0 if J2VSTLIB==2 & (dc2==1 | fh2==1 | oth2==1)
	
	*for the preschool wave: in the past month, how many times have you visited a library?
	replace J3VSTLIB = . if J3VSTLIB<0 
	replace library3 = J3VSTLIB if (fh3==1 | oth3==1)

*available computer?
	replace comp3 = 1 if J3COMPUT==1 & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)
	replace comp3 = 0 if J3COMPUT==2 & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)

*playing games or puzzles (times/week)
	replace J3TMGAME = . if J3TMGAME<0
	replace gampuzz3 = J3TMGAME if (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)

*follow a written curriculum?
	replace writcurr3 = 1 if J3WRTCUR==1 & (dc3==1 | pk3==1 | hs3==1)
	replace writcurr3 = 0 if J3WRTCUR==2 & (dc3==1 | pk3==1 | hs3==1)

*time per day spent on whole class activities (cat., and only for children who attend care with others [note: disproportionately missing those in "other" care, only for formal settings])
	replace wholeclass3 = 1 if (J3WHLCLS==4 | J3WHLCLS==5) & (dc3==1 | pk3==1 | hs3==1)	// more than one hour/day
	replace wholeclass3 = 0 if (J3WHLCLS==1 | J3WHLCLS==2 | J3WHLCLS==3) & (dc3==1 | pk3==1 | hs3==1) 	//an hour/day or less

*time per day spent on child selected activities (cat.)
	replace chisel3 = 1 if (J3CHDSEL==4 | J3CHDSEL==5) & (dc3==1 | pk3==1 | hs3==1)		// more than one hour/day
	replace chisel3 = 0 if (J3CHDSEL==1 | J3CHDSEL==2 |J3CHDSEL==3) & (dc3==1 | pk3==1 | hs3==1)		//an hour/day or less

*health/safety items: always have available one working smoke detector, one first aid kit, or covers on all the open electrical outlets?
	replace smokedet2 = 1 if J2SMKDET==4 & (dc2==1 | fh2==1 | oth2==1)
	replace smokedet2 = 0 if (J2SMKDET==1 | J2SMKDET==2 | J2SMKDET==3) & (dc2==1 | fh2==1 | oth2==1)
	replace smokedet3 = 1 if J3SMKDET==1 & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)
	replace smokedet3 = 0 if (J3SMKDET==2 | J3SMKDET==3 | J3SMKDET==4) & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)
	
	replace firstaid2 = 1 if J21STAID==4 & (dc2==1 | fh2==1 | oth2==1)
	replace firstaid2 = 0 if (J21STAID==1 | J21STAID==2 | J21STAID==3) & (dc2==1 | fh2==1 | oth2==1)
	replace firstaid3 = 1 if J31STAID==1 & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)
	replace firstaid3 = 0 if (J31STAID==2 | J31STAID==3 | J31STAID==4) & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)
	
	replace outlet2 = 1 if J2OUTCVR==4 & (dc2==1 | fh2==1 | oth2==1)
	replace outlet2 = 0 if (J2OUTCVR==1 | J2OUTCVR==2 | J2OUTCVR==3) & (dc2==1 | fh2==1 | oth2==1)
	replace outlet3 = 1 if J3OUTCVR==1 & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)
	replace outlet3 = 0 if (J3OUTCVR==2 | J3OUTCVR==3 | J3OUTCVR==4) & (dc3==1 | fh3==1 | oth3==1 | pk3==1 | hs3==1)

*environmental rating scales
	replace X2ITRTOT = . if X2ITRTOT<0				//iters overall mean score
	replace X3ECRTOT = . if X3ECRTOT<0				//ecers overall mean score
	replace X`wave'FDCTOT = . if X`wave'FDCTOT<0	// fdcrs overall mean score
	replace ers2 = X2ITRTOT if dc2==1
	replace ers2 = X2FDCTOT if fh2==1 | oth2==1
	replace ers3 = X3ECRTOT if dc3==1 | hs3==1 | pk3==1
	replace ers3 = X3FDCTOT if fh3==1 | oth3==1

*arnett measure of lead caregiver sensitivity
	replace X`wave'ARNTOT = . if X`wave'ARNTOT<0	//arnett lead caregiver total score
	replace arnett`wave' = X`wave'ARNTOT if dc`wave'==1 | fh`wave'==1 | oth`wave'==1
	replace arnett3 = X3ARNTOT if hs3==1 | pk3==1
}	

*high qualified and low qualifed teacher profiles
	replace HQT2 = 1 if (cda2==1 | ecedeg2==1 | mqecet2==1) & ongot2==1
	replace HQT2 = 0 if type2~="" & type2~="pa" & HQT2~=1
	
	replace LQT2 = 1 if (cda2==0 & ecedeg2==0 & mqecet2==0 & edt2<=12) & ongot2==0
	replace LQT2 = 0 if type2~="" & type2~="pa" & LQT2~=1

	
	replace HQT3 = 1 if (edt3>=16 & edt3~=.) & ecedeg3==1 & ongot3==1
	replace HQT3 = 0 if type3~="" & type3~="pa" & HQT3~=1
	
	replace LQT3 = 1 if (cda3==0 & ecedeg3==0 & mqecet3<=1 & edt3<=12) & ongot3==0
	replace LQT3 = 0 if type3~="" & type3~="pa" & LQT3~=1

*time spent per day in care
foreach var in P2CHRS P2RHRS P2NHRS P3CHRS P3RHRS P3NHRS P3HSHRS P2CDAYS P2RDAYS P2NDAYS P3CDAYS P3RDAYS P3NDAYS P3HSDAYS {
	replace `var' = . if `var'<0
}
forv wave = 2/3 {
	gen Rhrs`wave' = P`wave'RHRS/P`wave'RDAYS 
	gen Nhrs`wave' = P`wave'NHRS/P`wave'NDAYS
	gen HOMEhrs`wave' = .
	replace HOMEhrs`wave' = Nhrs`wave' if Rhrs`wave'==.
	replace HOMEhrs`wave' = Rhrs`wave' if Nhrs`wave'==.
	replace HOMEhrs`wave' = Nhrs`wave' if Rhrs`wave'~=. & Nhrs`wave'~=. & Nhrs`wave'>=Rhrs`wave'
	replace HOMEhrs`wave' = Rhrs`wave' if Rhrs`wave'~=. & Nhrs`wave'~=. & Rhrs`wave'>=Nhrs`wave'
}

	replace carehrs2 = P2CHRS/P2CDAYS if dc2==1
	replace carehrs2 = HOMEhrs2 if (fh2==1 | oth2==1)

	replace carehrs3 = P3CHRS/P3CDAYS if (dc3==1 | pk3==1)
	replace carehrs3 = P3HSHRS/P3HSDAYS if hs3==1
	replace carehrs3 = HOMEhrs3 if (fh3==1 | oth3==1)
/*
forv wave = 2/3 {
	table type`wave' [pw=W`wave'R0], contents (mean carehrs`wave')
}
*/

*child characteristics

*in waves 2 and 3
forv wave = 2/3 {

	g state`wave' = ""
	g age`wave' = .
	g weight`wave' = .
	g height`wave' = .
	g numchild`wave' = .
	g urban`wave' = .
	g suburban`wave' = .
	g rural`wave' = .
	g cregion`wave' = .
	g mothemp`wave' = .
	g paredhi`wave' = .

	g hinc25less`wave' = .
	g hinc25to50`wave' = .
	g hinc50to75g`wave' = .
	g hinc75more`wave' = .

	g poor`wave' = .
	g nonpoor`wave' = .
	g hinc`wave' = .
	g minc`wave' = .
	g enghome`wave' = .
	g numbooks`wave' = .
	g visit`wave' = .
	g learndiff`wave' = .
	g actdiff`wave' = .
	g comdiff`wave' = .
	g indread`wave' = .
	g indepen`wave' = .
	g payatten`wave' = .
	g ell`wave' = .
	g wic`wave' = .
	
	g preads`wave' = .
	g ptvhrswk`wave' = .
	g dinfam`wave' = .
	g discorp`wave' = .

	replace state`wave' = P`wave'CSTATE

	replace age`wave' = X`wave'ASAGE/12 if X`wave'ASAGE>0 & X`wave'ASAGE~=.

	recode X`wave'CHWGHT -9=. -1=.
	replace weight`wave' = X`wave'CHWGHT*2.204	// convert kg to pounds

	recode X`wave'CHHGHT -9=. -1=.
	replace height`wave' = X`wave'CHHGHT/2.54 		// convert cm to inches
	
	replace numchild`wave' = Y`wave'LESS18
	
	replace rural`wave' = 0 if X`wave'HHURBN==1
	replace rural`wave' = 1 if (X`wave'HHURBN==2 | X`wave'HHURBN==3)
	
	replace cregion`wave' = X`wave'HHREGN 
	
	foreach emp in mwork mpart mlook mout {
		gen `emp'`wave' = .
		replace `emp'`wave' = 0 if Y`wave'HMEMP>0 & Y`wave'HMEMP~=.
	}
	
	replace mwork`wave' = 1 if Y`wave'HMEMP==1
	replace mpart`wave' = 1 if Y`wave'HMEMP==2
	replace mlook`wave' = 1 if Y`wave'HMEMP==3
	replace mout`wave' = 1 if Y`wave'HMEMP==4
	
	foreach pared in paredhilesshs paredhihs paredhilesscoll paredhicollplus {
		gen `pared'`wave' = .
		replace `pared'`wave' = 0 if Y`wave'PARED>0 & Y`wave'PARED~=.
	}
	
	replace paredhilesshs`wave' = 1 if Y`wave'PARED==1 | Y`wave'PARED==2
	replace paredhihs`wave' = 1 if Y`wave'PARED==3
	replace paredhilesscoll`wave' = 1 if Y`wave'PARED==4 | Y`wave'PARED==5
	replace paredhicollplus`wave' = 1 if Y`wave'PARED==6 | Y`wave'PARED==7 | Y`wave'PARED==8 | Y`wave'PARED==9

	replace hinc25less`wave' = 1 if P`wave'HHINCS==1 | P`wave'HHINCS==2 | P`wave'HHINCS==3 |P`wave'HHINCS==4 |P`wave'HHINCS==5
	replace hinc25less`wave' = 0 if P`wave'HHINCS==6 | P`wave'HHINCS==7 | P`wave'HHINCS==8 | P`wave'HHINCS==9 | P`wave'HHINCS==10 | P`wave'HHINCS==11 | P`wave'HHINCS==12 | P`wave'HHINCS==13
	replace hinc25to50`wave' = 1 if P`wave'HHINCS==6 | P`wave'HHINCS==7 | P`wave'HHINCS==8 | P`wave'HHINCS==9
	replace hinc25to50`wave' = 0 if P`wave'HHINCS==1 | P`wave'HHINCS==2 | P`wave'HHINCS==3 |P`wave'HHINCS==4 |P`wave'HHINCS==5 | P`wave'HHINCS==10 | P`wave'HHINCS==11 | P`wave'HHINCS==12 | P`wave'HHINCS==13
	replace hinc50to75g`wave' = 1 if P`wave'HHINCS==10
	replace hinc50to75g`wave' = 0 if P`wave'HHINCS==1 | P`wave'HHINCS==2 | P`wave'HHINCS==3 |P`wave'HHINCS==4 |P`wave'HHINCS==5 | P`wave'HHINCS==6 | P`wave'HHINCS==7 | P`wave'HHINCS==8 | P`wave'HHINCS==9 | P`wave'HHINCS==11 | P`wave'HHINCS==12 | P`wave'HHINCS==13
	replace hinc75more`wave' = 1 if P`wave'HHINCS==11 | P`wave'HHINCS==12 | P`wave'HHINCS==13
	replace hinc75more`wave' = 0 if P`wave'HHINCS==1 | P`wave'HHINCS==2 | P`wave'HHINCS==3 |P`wave'HHINCS==4 |P`wave'HHINCS==5 | P`wave'HHINCS==6 | P`wave'HHINCS==7 | P`wave'HHINCS==8 | P`wave'HHINCS==9 | P`wave'HHINCS==10
	
	replace enghome`wave' = 1 if X`wave'PRMLNG==1	//primary household language is non english
	replace enghome`wave'= 0 if X`wave'PRMLNG==2 
	
	recode P`wave'NMKDBK -9=. -8=. -7=. -1=.
	replace numbooks`wave' = P`wave'NMKDBK 
	egen books`wave' = std(numbooks`wave'), mean(50) std(10)
	
	replace visit`wave' = 1 if P`wave'SRVHM==1
	replace visit`wave' = 0 if P`wave'SRVHM==2 
	
	replace wic`wave' = 1 if P`wave'WICBFT==1 
	replace wic`wave' = 0 if P`wave'WICBFT==2
	
	replace poor`wave' = 1 if Y`wave'POVRTY==1 
	replace poor`wave' = 0 if Y`wave'POVRTY==2
	
	replace nonpoor`wave' = 0 if Y`wave'POVRTY==1 
	replace nonpoor`wave' = 1 if Y`wave'POVRTY==2
	
	replace hinc`wave' = 1 if nonpoor`wave'==1 & (P`wave'HHINCS==11 | P`wave'HHINCS==12 | P`wave'HHINCS==13)
	replace hinc`wave' = 0 if poor`wave'==1 | (nonpoor`wave'==1 & P`wave'HHINCS>0 & P`wave'HHINCS<11)
	
	replace minc`wave' = 1 if nonpoor`wave'==1 & hinc`wave'==0
	replace minc`wave' = 0 if poor`wave'==1 | hinc`wave'==1
	
	replace urban`wave' = 1 if X3HHLOCL==11 | X3HHLOCL==12 | X3HHLOCL==13
	replace suburban`wave' = 1 if X3HHLOCL==21 | X3HHLOCL==22 | X3HHLOCL==23
	replace rural`wave' = 1 if X3HHLOCL==31 | X3HHLOCL==32 | X3HHLOCL==33 | X3HHLOCL==41 | X3HHLOCL==42 | X3HHLOCL==43 // town, rural

	replace urban`wave' = 0 if suburban`wave'==1 | rural`wave'==1
	replace suburban`wave' = 0 if urban`wave'==1 | rural`wave'==1
	replace rural`wave' = 0 if urban`wave'==1 | suburban`wave'==1
	
	replace preads`wave' = 0 if (P`wave'READBO==1 | P`wave'READBO==2 | P`wave'READBO==3)	// parent reads books every day
	replace preads`wave' = 1 if P`wave'READBO==4
	
	replace P`wave'TVWKDY = . if P`wave'TVWKDY<0
	recode P`wave'TVWKDY 95=0
	replace ptvhrswk`wave' = P`wave'TVWKDY 
	
	replace P`wave'DINFML = . if P`wave'DINFML<0	// number of nights/week eat evening meal as a family
	replace dinfam`wave' = P`wave'DINFML
	
	replace discorp`wave' = 1 if (P`wave'SPANK==1 | P`wave'HITBCK==1)
	replace discorp`wave' = 0 if (P`wave'SPANK==2 & P`wave'HITBCK==2)
	
}

/* 	above, replace the limited urbanicity variable in wave 2 with the designation in wave 3
	replace urban2 = 1 if X2HHURBN==1
	replace urban2 = 0 if (X2HHURBN==2 | X2HHURBN==3)
*/

*in wave 2, only
	recode X2MTLTSC -99=.		// bsf-r (bayley) mental t-score
	g cogtwo2 = X2MTLTSC	

	recode C2STNATT -1=. 95=.	// two bags task: child sustained attention
	egen atttwo2 = std(C2STNATT), mean(50) std(10)

*in wave 3, only
forv wave = 3/3 {

	recode X`wave'RTHR2 -9=.
	egen read`wave' = std(X`wave'RTHR2), mean(50) std(10)
	recode X`wave'MTHR2 -9=.
	egen math`wave' = std(X`wave'MTHR2), mean(50) std(10)

	replace learndiff`wave' = 1 if P`wave'DIAGAT==1 
	replace learndiff`wave' = 0 if P`wave'DIAGAT==-1 
	replace learndiff`wave' = 0 if P`wave'DIAGAT==2 
	
	replace actdiff`wave' = 1 if P`wave'DIAGAC==1 
	replace actdiff`wave' = 0 if P`wave'DIAGAC==-1 
	replace actdiff`wave' = 0 if P`wave'DIAGAC==2 
	
	replace comdiff`wave' = 1 if P`wave'DIAGCO==1 
	replace comdiff`wave' = 0 if P`wave'DIAGCO==-1 
	replace comdiff`wave' = 0 if P`wave'DIAGCO==2 
	
	replace indread`wave' = 2 if P`wave'RDALON==1 
	replace indread`wave' = 1 if P`wave'RDALON==2 
	egen iread`wave' = std(indread`wave'), mean(50) std(10)
	
	recode P`wave'NDEPND  -9=. -8=. -7=.
	replace indepen`wave' = P`wave'NDEPND
	egen indep`wave' = std(indepen`wave'), mean(50) std(10)
	
	recode P`wave'PAYATT -9=. -7=.
	replace payatten`wave' = P`wave'PAYATT
	egen atten`wave' = std(payatten`wave'), mean(50) std(10)
	
}

*in wave 4, only
recode X4RTHR2 -9=.
egen read5score = std(X4RTHR2), mean(50) std(10)
recode X4MTHR2 -9=.
egen math5score = std(X4MTHR2), mean(50) std(10)

gen testage=(X4ASAGE/12) if X4ASAGE>0 & X4ASAGE~=.

rename X4ASMTMM testmonth
recode testmonth 9=0 10=1 11=2 12=3 1=4 2=5 3=6

recode X4GRDLVL -9=.
gen kinder=(X4GRDLVL==1) if X4GRDLVL~=.


recode BCBRTHWT -8=.
g bweight = BCBRTHWT*.002204	// convert grams to pounds

foreach race in white black hisp asian other othrace {
	g `race' = .
}
replace white = (Y1CHRACE==1) if Y1CHRACE~=-9
replace black = (Y1CHRACE==2) if Y1CHRACE~=-9
replace hisp = (Y1CHRACE==3 | Y1CHRACE==4) if Y1CHRACE~=-9
replace asian = (Y1CHRACE==5) if Y1CHRACE~=-9
replace other = (Y1CHRACE==6 | Y1CHRACE==7 | Y1CHRACE==8) if Y1CHRACE~=-9
replace othrace = (asian==1 | other==1) if Y1CHRACE~=-9

g female = .
replace female = 1 if X4CHSEX==2
replace female = 0 if X4CHSEX==1

*weights
g wtp2 = W2R0
g wtc2 = W2C0
g wte2 = W22J0
g wto2 = W22P0

g wtp3 = W3R0
g wtc3 = W31C0
g wte3 = W33J0
g wto3 = W33P0

g wtscore = W4C0

/////////////////////////////////////////////////////////////////
//
// Scott's additions
//
////////////////////////////////////////////////////////////////
	save "${datasave}\temp", replace
	use "${datasave}\temp", clear

	//2 year old variables
		rename X2ASAGE testage2yr2
		gen testage2yr3 = testage2yr2
		

		recode X1RMTLT X2MTLTSC (-99=.)

		rename X1RMTLT cogscore9mo2
		rename X2MTLTSC cogscore2yr2

		gen cogscore9mo3 = cogscore9mo2
		gen cogscore2yr3 = cogscore2yr2

	//Reading, telling stories, singing songs every day
		recode J2READBO J2TELLST J2SINGSO (-9=.) (-8=.) (-7=.) (-1=.)

		gen read_ed2 = J2READBO ==4
		gen tell_ed2 = J2TELLST ==4
		gen sing_ed2 = J2SINGSO ==4

		replace read_ed2 = . if J2READBO ==.
		replace tell_ed2 = . if J2TELLST ==.
		replace sing_ed2 = . if J2SINGSO ==.

	//dc - centers for 2 year olds
	//fh - family homes
	//formal - center + HS + prek
	//informal - family homes + other


	//Number of care settings
		recode P?RELNUM P?NRNUM P?CTRNUM P3HSNOW X?PRMARR (-9=.) (-8=.) (-7=.) (-1=0)
		recode P3HSNOW (2=0)

		egen num_settings3 = rowtotal (P3HSNOW P3RELNUM P3NRNUM P3CTRNUM), missing
		//label var num_settings3 "Total number of care settings in the year before K"

		gen num_inf3 = P3RELNUM + P3NRNUM
		//label var num_inf3 "Number of informal settings"

		gen num_for3 = P3HSNOW + P3CTRNUM
		//label var num_for3 "Number of formal settings"
		

		gen only_setting3 = num_settings ==1
		replace only_setting3 = . if num_settings ==.
		//label var only_setting3 "Child's primary care setting is the only arrangement noted"

		gen multi_a3 = informal3==1 & (num_for >=1)
		replace multi_a3 = . if informal3 ==.
		//label var multi_a3 "Child's primary setting is informal, but also enrolled in a formal setting"

		gen multi_b3 = informal3 ==1 & (num_inf >=2)
		replace multi_b3 = . if informal3 ==. 
		//label var multi_b3 "Child's primary setting is informal, but also enrolled in another informal setting"
	 
		gen multi_c3 = formal3 ==1 & (num_inf >=1)
		replace multi_c3 = . if formal3 ==.
		//label var multi_c3 "Child's primary setting is formal, but also enrolled in an informal setting"

		gen multi_d3 = formal3 ==1 & (num_for >=2)
		replace multi_d3 = . if formal3 ==.
		//label var multi_d3 "Child's primary setting is formal, but also enrolled in another formal setting"

		gen multi_e3 = multi_b3 ==1 //Primary setting is informal and also other informal
		replace multi_e3 = 1 if multi_d3 ==1 //Primary setting is formal and also other formal
		replace multi_e3 = . if formal3 ==.
		//label var multi_e3 "Child has at least one care arrangement of the same type as the primary"

		gen multi_f3 = multi_a3 ==1 //Primary setting is informal and also other formal
		replace multi_f3 = 1 if multi_c3 ==1 //Primary setting is formal and also other informal
		replace multi_f3 = . if formal3 ==.
		//label var multi_f3 "Child has at least one care arrangement of a different type than the primary"


* reshape dataset long
	keep ///	
	childid /// // individual-level identifier
	state* ///
	age* female bweight weight* height* white black hisp asian other othrace numchild* urban* suburban* rural* cregion* mwork* mpart* mlook* mout* paredhi* poor* nonpoor* hinc* minc* enghome* books* visit* /// //child-level covars.
	hinc25less* hinc25to50* hinc50to75g* hinc75more* ell* wic* preads* ptvhrswk* dinfam* discorp* /// //child-level covars.
	dc* fh* hs* pk* pa* oth* type* formal* informal* fccformal* /// // primary care arrangement
	cogtwo* atttwo* learndiff* actdiff* comdiff* read* math* iread* indep* atten* /// // child outcomes
	edt* ongot* ongoht* ratio* turnover* mqecet* cda* ecedeg* aget* exp* /// // structural and caregiver characteristics
	smokedet* firstaid* outlet* ers* arnett* HQT* LQT* /// // structural characteristics, cont'd
	carehrs* treads* readevery* mathevery* tvhrs* playout* zoo* library* comp* gampuzz* writcurr* wholeclass* chisel* /// // time use
	read5score math5score testage* testmonth* kinder /// variables at age 5
	read_ed tell_ed sing_ed /// variables at age 2
	wt* 	multi* only_setting* num_settings* num_inf3 num_for3 cogscore*

	reshape long state age weight height numchild urban suburban rural cregion mwork mpart mlook mout paredhilesshs paredhihs paredhilesscoll paredhicollplus poor nonpoor hinc minc enghome books visit ///
		hinc25less hinc25to50 hinc50to75g hinc75more ell wic preads ptvhrswk dinfam discorp ///
		dc fh hs pk pa oth type formal informal fccformal ///
		cogtwo atttwo learndiff actdiff comdiff read math iread indep atten ///
		edt ongot ongoht ratio turnover mqecet cda ecedeg aget ///
		exp carehrs treads readevery mathevery tvhrs playout zoo library comp gampuzz writcurr wholeclass chisel ///
		smokedet firstaid outlet ers arnett HQT LQT ///
		wtp wtc wte wto 	///
		cogscore9mo cogscore2yr testmonth2yr testage2yr read_ed tell_ed sing_ed ///
		num_settings only_setting num_inf num_for multi_a multi_b multi_c multi_d multi_e multi_f, ///
		i(childid) j(wave)

* final data cleaning
	drop if state=="" // note: cases lost to sample attrition, home-schooling, ungraded categorization, or jumping to 1st/2nd grade

	g year = 2003 if wave==2
	replace year = 2005 if wave==3

	gen HQP = 0 if HQT~=.
	replace HQP = 1 if HQT==1
	replace HQP = 2 if HQT==1 & smokedet==1 & firstaid==1 & outlet==1
	replace HQP = 3 if HQT==1 & smokedet==1 & firstaid==1 & outlet==1 & tvhrs==0
	replace HQP = 4 if HQT==1 & smokedet==1 & firstaid==1 & outlet==1 & tvhrs==0 ///
						& readevery==1 & mathevery==1
							
	gen LQP = 0 if LQT~=.
	replace LQP = 1 if LQT==1
	replace LQP = 2 if LQT==1 & (smokedet==0 | firstaid==0 | outlet==0)
	replace LQP = 3 if LQT==1 & (smokedet==0 | firstaid==0 | outlet==0) & tvhrs>0 & tvhrs~=.
	replace LQP = 4 if LQT==1 & (smokedet==0 | firstaid==0 | outlet==0) & tvhrs>0 & tvhrs~=. ///
						& (readevery==0 | mathevery==0)

	foreach var in HQP LQP {
		gen `var'b = 0 if `var'==0 | `var'==1 | `var'==2 | `var'==3
		replace `var'b = 1 if `var'==4
	}

* tabulate quality variables by sector
	forv wave = 2/3 {
		foreach var in HQT LQT HQPb LQPb {
			foreach sector in formal informal dc hs pk fh oth {
				di "`var'`wave'`sector'"
				su `var' if wave==`wave' & `sector'==1 [aw=wte]
			}
		}
	}

	//Scott's labels
		label var num_settings "Total number of care settings in the year before K"
		label var num_inf "Number of informal settings"
		label var num_for "Number of formal settings"
		label var only_setting "Child's primary care setting is the only arrangement noted"
		label var multi_a "Child's primary setting is informal, but also enrolled in a formal setting"
		label var multi_b "Child's primary setting is informal, but also enrolled in another informal setting"
		label var multi_c "Child's primary setting is formal, but also enrolled in an informal setting"
		label var multi_d "Child's primary setting is formal, but also enrolled in another formal setting"
		label var multi_e "Child has at least one care arrangement of the same type as the primary"
		label var multi_f "Child has at least one care arrangement of a different type than the primary"

	foreach x in informal pk hs	{
		gen only_`x' = `x' * only_setting
	}

* merge with state FIPS codes
*merge m:1 state using "$datasave\State FIPS.dta"
*drop _merge

*order state year
*sort state year
save "${datasave}\master dataset.dta", replace
