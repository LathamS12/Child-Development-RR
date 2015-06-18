//////////////
// Analysis
//////////////

use "${datasave}\Imputed.dta", clear

	#delimit ;
		gl ecepsurvey2		"ratio turnover smokedet firstaid outlet
								HQT LQT aget edt ecedeg mqecet ongot cda exp
								treads tvhrs playout zoo library ";

		gl ecepsurvey3 		"ratio turnover smokedet firstaid outlet  
								HQT LQT aget edt ecedeg mqecet ongot cda exp 
								treads tvhrs readevery mathevery comp gampuzz writcurr wholeclass chisel ";

		gl ccobs			"ers arnett" ;
		gl parsurvey		"carehrs" ;	

		gl basics 			"testage testmonth kinder ";

		gl qualityall		"smokedet firstaid outlet ratio aget edt ecedeg mqecet ongot cda exp treads tvhrs readevery mathevery comp gampuzz ";

		gl qualityformal	"smokedet firstaid outlet ratio turnover aget edt ecedeg mqecet ongot cda 
									exp treads tvhrs readevery mathevery comp gampuzz writcurr wholeclass chisel ";

		gl dems 			"black hisp poor hinc urban rural";

		gl alldems 			"black hisp asian other poor hinc urban rural female bweight weight height numchild cregion
								mpart mlook mout paredhilesshs paredhihs paredhilesscoll enghome books wic
								preads ptvhrswk dinfam discorp ";

		gl flooded 			"black hisp poor hinc urban rural age female bweight weight height numchild cregion
								mpart mlook mout paredhilesshs paredhihs paredhilesscoll enghome books wic
								preads ptvhrswk dinfam discorp " ;

		gl multi			"num_settings only_setting multi_a multi_b multi_c multi_d multi_e multi_f" ;
	#delimit cr

	////////////////////////////////////////
	// Multiple care setting descriptives
	////////////////////////////////////////

		tempname name
		tempfile file
		postfile `name' str80(var) all form inf cent hs pk fcc other using `file', replace

		foreach x in $multi	{

			loc lab: variable label `x'
			sum `x'	[aw = wte]
			loc m`x': di %4.2f r(mean)
			
			foreach y in formal informal dc hs pk fh oth	{ 
				sum `x' [aw =wte] if `y' ==1
				loc m`x'`y': di %4.2f r(mean)
			} //closes y loop

			post `name' ("`lab'") (`m`x'') (`m`x'formal') (`m`x'informal') (`m`x'dc') (`m`x'hs') (`m`x'pk') (`m`x'fh') (`m`x'oth')

		} //closes x loop
		
		postclose `name'

		preserve
			use `file', clear
			export excel using "${outputsave}\Multi setting descriptives", replace
		restore


	/////////////////////////////////////////////////////////////////////////////////
	/// 	Table 1 & Table 2 - Needs revising to make output comparable to tables
	/////////////////////////////////////////////////////////////////////////////////

		tempname memhold
		postfile `memhold' str20(variable) wave dc dctest fh fhtest oth othtest hs hstest pk pktest formal formaltest informal informaltest tot using "$outputsave\observables by setting.dta", replace

		forv wave = 2/3 {
			
			foreach var in ${ecepsurvey`wave'} { 
				loc wave = `wave'
					
				foreach type in dc fh hs pk pa oth {
					preserve
						keep if wave==`wave' & (`type'==1 | dc==1)
						cap: reg `var' dc [pw=wte]
						cap: test dc			
						loc `type'test = r(p)
						if _rc~=0 {
							loc `type'test = .
						}
					restore
				
					su `var' if wave==`wave' [aw=wte]
					loc totmean = r(mean)
				
					cap: su `var' if wave==`wave' & `type'==1 [aw=wte]
					loc `type'mean = r(mean)
					if _rc~=0 {
						loc `type'mean = .
					}
				}
				
				foreach type in formal informal {
					preserve
						keep if wave==`wave' & (`type'==1 | formal==1)
						cap: reg `var' formal [pw=wte]
						cap: test formal			
						loc `type'test = r(p)
						if _rc~=0 {
							loc `type'test = .
						}
					restore
				
					su `var' if wave==`wave' [aw=wte]
					loc totmean = r(mean)
				
					cap: su `var' if wave==`wave' & `type'==1 [aw=wte]
					loc `type'mean = r(mean)
					if _rc~=0 {
						loc `type'mean = .
					}
				}
				post `memhold' ("`var'") (`wave') (`dcmean') (`dctest') (`fhmean') (`fhtest') (`othmean') (`othtest') (`hsmean') (`hstest') (`pkmean') (`pktest') (`formalmean') (`formaltest') (`informalmean') (`informaltest') (`totmean')	
			}

			foreach var in ${parsurvey} { 
				loc wave = `wave'
					
				foreach type in dc fh hs pk pa oth {
					preserve
						keep if wave==`wave' & (`type'==1 | dc==1)
						cap: reg `var' dc [pw=wtp]
						cap: test dc			
						loc `type'test = r(p)
						if _rc~=0 {
							loc `type'test = .
						}
					restore
				
					su `var' if wave==`wave' [aw=wtp]
					loc totmean = r(mean)
				
					cap: su `var' if wave==`wave' & `type'==1 [aw=wtp]
					loc `type'mean = r(mean)
					if _rc~=0 {
						loc `type'mean = .
					}
				}
				
				foreach type in formal informal {
					preserve
						keep if wave==`wave' & (`type'==1 | formal==1)
						cap: reg `var' formal [pw=wtp]
						cap: test formal			
						loc `type'test = r(p)
						if _rc~=0 {
							loc `type'test = .
						}
					restore
				
					su `var' if wave==`wave' [aw=wtp]
					loc totmean = r(mean)
				
					cap: su `var' if wave==`wave' & `type'==1 [aw=wtp]
					loc `type'mean = r(mean)
					if _rc~=0 {
						loc `type'mean = .
					}
				}
				post `memhold' ("`var'") (`wave') (`dcmean') (`dctest') (`fhmean') (`fhtest') (`othmean') (`othtest') (`hsmean') (`hstest') (`pkmean') (`pktest') (`formalmean') (`formaltest') (`informalmean') (`informaltest') (`totmean')	
			}
			
			foreach var in ${parsurvey} { 
				loc wave = `wave'
				
				foreach type in dc fh hs pk oth formal informal { 
					
					cap: su `var' if wave==`wave' & `type'==1 [aw=wtp]
					loc `type'mean = r(sd)
					if _rc~=0 {
						loc `type'mean = .
					}
					loc `type'test = .
				}
				post `memhold' ("`var'") (`wave') (`dcmean') (`dctest') (`fhmean') (`fhtest') (`othmean') (`othtest') (`hsmean') (`hstest') (`pkmean') (`pktest') (`formalmean') (`formaltest') (`informalmean') (`informaltest') (`totmean')	
			}	
			
			foreach var in ${ccobs} { 
				loc wave = `wave'
					
				foreach type in dc fh hs pk pa oth {
					preserve
						keep if wave==`wave' & (`type'==1 | dc==1)
						reg `var' dc [pw=wto]
						test dc			
						loc `type'test = r(p)
					restore
				
					su `var' if wave==`wave' [aw=wto]
					loc totmean = r(mean)
				
					cap: su `var' if wave==`wave' & `type'==1 [aw=wto]
					loc `type'mean = r(mean)
					if _rc~=0 {
						loc `type'mean = .
					}
				}
				
				foreach type in formal informal {
					preserve
						keep if wave==`wave' & (`type'==1 | formal==1)
						reg `var' formal [pw=wto]
						test formal			
						loc `type'test = r(p)
					restore
				
					su `var' if wave==`wave' [aw=wto]
					loc totmean = r(mean)
				
					cap: su `var' if wave==`wave' & `type'==1 [aw=wto]
					loc `type'mean = r(mean)
					if _rc~=0 {
						loc `type'mean = .
					}
				}
				post `memhold' ("`var'") (`wave') (`dcmean') (`dctest') (`fhmean') (`fhtest') (`othmean') (`othtest') (`hsmean') (`hstest') (`pkmean') (`pktest') (`formalmean') (`formaltest') (`informalmean') (`informaltest') (`totmean')	
			}
			
			foreach var in ${ccobs} { 
				loc wave = `wave'
				
				foreach type in dc fh hs pk oth formal informal { 
					
					cap: su `var' if wave==`wave' & `type'==1 [aw=wto]
					loc `type'mean = r(sd)
					if _rc~=0 {
						loc `type'mean = .
					}
					loc `type'test = .
				}
				post `memhold' ("`var'") (`wave') (`dcmean') (`dctest') (`fhmean') (`fhtest') (`othmean') (`othtest') (`hsmean') (`hstest') (`pkmean') (`pktest') (`formalmean') (`formaltest') (`informalmean') (`informaltest') (`totmean')	
			}	

			foreach var in rat2y rat4y turnover aget edt mqecet exp treads tvhrs gampuzz { 
				loc wave = `wave'
					
				foreach type in dc fh hs pk oth formal informal { 
					
					cap: su `var' if wave==`wave' & `type'==1 [aw=wte]
					loc `type'mean = r(sd)
					if _rc~=0 {
						loc `type'mean = .
					}
					loc `type'test = .
				}
				post `memhold' ("`var'") (`wave') (`dcmean') (`dctest') (`fhmean') (`fhtest') (`othmean') (`othtest') (`hsmean') (`hstest') (`pkmean') (`pktest') (`formalmean') (`formaltest') (`informalmean') (`informaltest') (`totmean')	
			}	
			
			foreach var in ${ccobs} { 
				loc wave = `wave'
					
				foreach type in dc fh hs pk oth formal informal {
					cap: su `var' if wave==`wave' & `type'==1 [aw=wto]
					loc `type'mean = r(N)
					loc `type'test = .
				}
					cap: su `var' if wave==`wave' [aw=wto]
					loc totmean = r(N)
					loc tottest = .
				post `memhold' ("`var'") (`wave') (`dcmean') (`dctest') (`fhmean') (`fhtest') (`othmean') (`othtest') (`hsmean') (`hstest') (`pkmean') (`pktest') (`formalmean') (`formaltest') (`informalmean') (`informaltest') (`totmean')	
			}
		}

		postclose `memhold'

		preserve
			use "$outputsave\observables by setting.dta", clear
			export excel "$outputsave\observables by setting column.xls", replace firstrow(variables)
		restore



	******************************************************************************************
	* Table 3 - Have to be careful here because "treads" is OLS at age 4 and Logit at age 2 
	*				(This means I've gotta run twice to get right estimates)
	******************************************************************************************
		forv wave = 2/3 {
			preserve
				keep if wave==`wave' & (formal==1 | fh==1 | oth==1)


				foreach var in tvhrs ratio treads {

					reg `var' fh oth $flooded [pw=wte] 
					estimates store `var'wave`wave'_m4
				
					reg `var' fh oth if e(sample) ==1 [pw=wte]
					estimates store `var'wave`wave'_m1
				}

				foreach var in HQT {

					logit `var' fh oth $flooded [pw=wte], or
					estimates store `var'wave`wave'_m4
					
					logit `var' fh oth if e(sample) ==1 [pw=wte], or
					estimates store `var'wave`wave'_m1

				}
				
				foreach var in ers {

					reg `var' fh oth $flooded [pw=wto]
					estimates store `var'wave`wave'_m4		
				
					reg `var' fh oth if e(sample) ==1 [pw=wto]
					estimates store `var'wave`wave'_m1

				}
			restore
		}

		estout 	treadswave3_m1 treadswave3_m4 ratiowave3_m1 ratiowave3_m4 ///
				HQTwave3_m1 HQTwave3_m4 tvhrswave3_m1 tvhrswave3_m4 ///
				erswave3_m1 erswave3_m4 /// 
				using "$outputsave\Table 3.xls", replace ///
				eform(0 0 0 0 1 1 0 0 0 0) keep(fh oth) ///
				cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach

		estout 	treadswave2_m1 treadswave2_m4 ratiowave2_m1 ratiowave2_m4 ///
				HQTwave2_m1 HQTwave2_m4 tvhrswave2_m1 tvhrswave2_m4 ///
				erswave2_m1 erswave2_m4 ///
				using "$outputsave\Table 3.xls", append ///
				eform(1 1 0 0 1 1 0 0 0 0) keep(fh oth) ///
				cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach	
			
			
			
	*******************************
	* Table 4 - Exactly replicated
	*******************************
		foreach wave in 3 {
			preserve
				keep if wave==`wave' & (dc==1 | hs==1 | pk==1)

				foreach var in ratio tvhrs treads {
					
					reg `var' hs pk $flooded  [pw=wte]
					estimates store `var'wave`wave'_m4

					reg `var' hs pk if e(sample) ==1 [pw=wte]
					estimates store `var'wave`wave'_m1
										
				}
				
				foreach var in  HQT {

					logit `var' hs pk $flooded [pw=wte], or
					estimates store `var'wave`wave'_m4	

					logit `var' hs pk if e(sample)==1 [pw=wte], or 
					estimates store `var'wave`wave'_m1

				}
							
				foreach var in ers {

					reg `var' hs pk $flooded [pw=wto]
					estimates store `var'wave`wave'_m4	

					reg `var' hs pk if e(sample) ==1 [pw=wto]
					estimates store `var'wave`wave'_m1

			
				}	

			restore	
		}

		estout 	treadswave3_m1 treadswave3_m4 ratiowave3_m1 ratiowave3_m4 ///
				HQTwave3_m1 HQTwave3_m4 tvhrswave3_m1 tvhrswave3_m4 ///
				erswave3_m1 erswave3_m4 ///				
				using "$outputsave\Table 4.xls", replace ///
				eform(0 0 0 0 1 1 0 0 0 0) keep(hs pk) /// 				
				cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach	

			
	
	**********************************
	* Table 5
	**********************************
		//Construct samples variable for table 5
			capture drop t5samp1 t5samp2
			gen t5samp1 = 1 if read5score !=. & math5score !=.
			gen t5samp2 = 1 if read5score !=. & math5score !=.

			foreach x in $qualityall	{
				replace t5samp1 = . if `x' ==.
			}

			foreach x in $qualityformal	{
				replace t5samp2 = . if `x' ==.
			}

		preserve
			keep if wave==3 & (formal==1 | informal==1)

				reg read5score informal cogscore2yr $basics $alldems $qualityall if math5score !=. & cogscore2yr!=. [pw=wtscore]
				estimates store m2_read

				reg read5score informal cogscore2yr $basics $alldems if e(sample) ==1 [pw=wtscore]
				estimates store m1_read
		
				
				reg math5score informal cogscore2yr $basics $alldems if e(sample) ==1 [pw=wtscore]
				estimates store m3_math
				
				reg math5score informal cogscore2yr $basics $alldems $qualityall if e(sample) ==1 [pw=wtscore]
				estimates store m4_math

		* second, for children in FORMAL sector care
			drop if informal==1

				reg read5score hs pk cogscore2yr $basics $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m5_read

				reg read5score hs pk cogscore2yr $basics $alldems $qualityformal if t5samp2 ==1 [pw=wtscore]
				estimates store m6_read
				
				reg math5score hs pk cogscore2yr $basics $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m7_math
				
				reg math5score hs pk cogscore2yr $basics $alldems $qualityformal if t5samp2 ==1 [pw=wtscore]
				estimates store m8_math
				
		restore 

		estout 	m1* m2* m3* m4* m5* m6* m7* m8* using "$outputsave\Table 5.xls", replace ///
				cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N r2) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach ///
				keep(informal hs pk)
		estimates clear

				
		

