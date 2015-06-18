
//Propensity score matching
	use "F:\Scott\Child Development R & R\Data\Imputed.dta", clear

	# delimit ;

		gl pscore_covs 	"cogscore2yr black hisp asian other poor hinc urban rural female bweight weight 
								height numchild cregion mpart mlook mout paredhilesshs paredhihs paredhilesscoll
								enghome books wic preads ptvhrswk dinfam discorp ";

		gl qualityall		"smokedet firstaid outlet ratio aget edt ecedeg mqecet ongot cda exp treads tvhrs 
								readevery mathevery comp gampuzz ";


		gl basics 			"testage testmonth kinder ";


		gl alldems 			"black hisp asian other poor hinc urban rural female bweight weight height numchild cregion
								mpart mlook mout paredhilesshs paredhihs paredhilesscoll enghome books wic
								preads ptvhrswk dinfam discorp ";


	# delimit cr

		//Sample selection
			capture drop t5samp1
			gen t5samp1 =.
			replace t5samp1 = 1 if read5score !=. & math5score !=. & wave==3 & (formal==1|informal==1)
		
			foreach x in $qualityall $pscore_covs	{
				replace t5samp1 = . if `x' ==.
			}

	****************************
	*	Informal as treatment
	****************************
			
		//Estimate propensity score
			psmatch2 informal $pscore_covs if t5samp1 ==1

			twoway (histogram _pscore if informal ==0, color(ltblue))  ///
				   (histogram _pscore if informal ==1, fcolor(none) lcolor(black)), ///
					legend(order(1 "formal (control)" 2 "informal (treatment)")) xtitle("")	 title("Region of common support")

			graph export "${graphsave}\Region of common support (Informal).pdf", replace
 
			
		//Imposing minimum and maximum restrictions
			sum _pscore if informal ==0
			drop if informal ==1 & _pscore > r(max) & _pscore <. //dropping control obs. with a lower propensity than min treatment
				//We lose 0 observations this way

			sum _pscore if informal ==1
			drop if informal ==0 & _pscore < r(min) //dropping treatment obs. with a higher propensity than max control
				//We lose 100 observations (4%) this way


		//Re-estimate using propensity score

			*gl score " & _pscore < .5"
			gl score "" 

			reg read5score informal cogscore2yr testage testmonth if t5samp1 ==1 $score [fw=_weight]
			estimates store m1_read			

			reg read5score informal cogscore2yr $basics $alldems if t5samp1 ==1 $score [fw=_weight]
			estimates store m2_read

			reg read5score informal cogscore2yr $basics $qualityall if t5samp1 ==1 $score [fw=_weight]
			estimates store m3_read

			reg read5score informal cogscore2yr $basics $alldems $qualityall if t5samp1 ==1 $score [fw=_weight]
			estimates store m4_read


			reg math5score informal cogscore2yr testage testmonth if t5samp1 ==1  $score [fw=_weight]
			estimates store m1_math

			reg math5score informal cogscore2yr $basics $alldems if t5samp1 ==1 $score [fw=_weight]
			estimates store m2_math
			
			reg math5score informal cogscore2yr $basics $qualityall if t5samp1 ==1 $score [fw=_weight]
			estimates store m3_math

			reg math5score informal cogscore2yr $basics $alldems $qualityall if t5samp1 ==1 $score [fw=_weight]
			estimates store m4_math


			estout 	* using "$outputsave\Table 5 - Propensity score (Informal).xls", replace ///
					cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N r2) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach ///
					keep(informal)



	****************************
	*	Formal as treatment
	****************************

		//Estimate propensity score
			capture drop _pscore
			psmatch2 formal $pscore_covs if t5samp1 ==1


			twoway (histogram _pscore if formal ==0, color(ltblue))  ///
				   (histogram _pscore if formal ==1, fcolor(none) lcolor(black)), ///
					legend(order(1 "informal (control)" 2 "formal (treatment)")) xtitle("")	 title("Region of common support")

			graph export "${graphsave}\Region of common support (Formal).pdf", replace
 
			
		//Imposing minimum and maximum restrictions
			sum _pscore if formal ==1
			drop if formal ==0 & _pscore < r(min) //dropping control obs. with a lower propensity than min treatment
				//We lose 0 observations this way

			sum _pscore if formal ==0
			drop if formal ==1 & _pscore > r(max) & _pscore <. //dropping treatment obs. with a higher propensity than max control
				//We lose 100 observations (4%) this way


		//Re-estimate using propensity score

			gl score "& _pscore > .5"
			*gl score ""

			mi estimate, post: reg read5score informal cogscore2yr testage testmonth if t5samp1 ==1 $score [fw=_weight]
			estimates store m1_read			

			mi estimate, post: reg read5score informal cogscore2yr $basics $alldems if t5samp1 ==1 $score [fw=_weight]
			estimates store m2_read

			mi estimate, post: reg read5score informal cogscore2yr $basics $qualityall if t5samp1 ==1 $score [fw=_weight]
			estimates store m3_read

			mi estimate, post: reg read5score informal cogscore2yr $basics $alldems $qualityall if t5samp1 ==1 $score [fw=_weight]
			estimates store m4_read


			mi estimate, post: reg math5score informal cogscore2yr testage testmonth if t5samp1 ==1  $score [fw=_weight]
			estimates store m1_math

			mi estimate, post: reg math5score informal cogscore2yr $basics $alldems if t5samp1 ==1 $score [fw=_weight]
			estimates store m2_math
			
			mi estimate, post: reg math5score informal cogscore2yr $basics $qualityall if t5samp1 ==1 $score [fw=_weight]
			estimates store m3_math

			mi estimate, post: reg math5score informal cogscore2yr $basics $alldems $qualityall if t5samp1 ==1 $score [fw=_weight]
			estimates store m4_math


			estout 	* using "$outputsave\Table 5 - Propensity score (Formal).xls", replace ///
					cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N r2) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach ///
					keep(informal)
