//////////////
// Analysis
//////////////

	use "F:\Scott\ECLS-B Rerun\Data\Imputed.dta", clear

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

			gl qual_2yr 		"smokedet firstaid outlet ratio aget edt ecedeg mqecet ongot cda exp treads tvhrs";


			//Five measures of quality;
				gl ratio 		"ratio";
				gl cgchars_all	"aget edt ecedeg mqecet ongot cda exp";
				gl cgchars_form "turnover aget edt ecedeg mqecet ongot cda exp";
				gl safety		"smokedet firstaid outlet";
				gl activs_all	"treads tvhrs readevery mathevery comp gampuzz";
				gl activs_form	"treads tvhrs readevery mathevery comp gampuzz writcurr wholeclass chisel";

			gl dems 			"black hisp poor hinc urban rural";

			gl alldems 			"black hisp asian other poor hinc urban rural female bweight weight height numchild cregion
									mpart mlook mout paredhilesshs paredhihs paredhilesscoll enghome books wic
									preads ptvhrswk dinfam discorp ";

			gl flooded 			"black hisp poor hinc urban rural age female bweight weight height numchild cregion
									mpart mlook mout paredhilesshs paredhihs paredhilesscoll enghome books wic
									preads ptvhrswk dinfam discorp " ;

			gl multi			"num_settings only_setting multi_a multi_b multi_c multi_d multi_e multi_f" ;
		#delimit cr

	
	
	**********************************
	* Table 5 Specification checks
	**********************************

		capture program drop table_5
		program define table_5
			args sample title controls
			
			//Construct samples variable for table 5
				capture drop t5samp1 t5samp2
				gen t5samp1 = 1 if read5score !=. & math5score !=. `sample'
				gen t5samp2 = 1 if read5score !=. & math5score !=. `sample'

				foreach x in $qualityall 	{
					replace t5samp1 = . if `x' ==.
				}

				foreach x in $qualityformal	{
					replace t5samp2 = . if `x' ==.
				}

			preserve
				keep if wave==3 & (formal==1 | informal==1)

					mi estimate, post: reg read5score informal cogscore2yr testage testmonth if t5samp1 ==1 [pw=wtscore]
					estimates store m1_read

					mi estimate, post: reg read5score informal cogscore2yr $basics $alldems if t5samp1 ==1 [pw=wtscore]
					estimates store m2_read

					mi estimate, post: reg read5score informal cogscore2yr $basics $qualityall `controls' if t5samp1 ==1 [pw=wtscore]
					estimates store m3_read

					mi estimate, post: reg read5score informal cogscore2yr $basics $alldems $qualityall `controls' if t5samp1 ==1 [pw=wtscore]
					estimates store m4_read


					mi estimate, post: reg math5score informal cogscore2yr testage testmonth if t5samp1 ==1 [pw=wtscore]
					estimates store m1_math
			
					mi estimate, post: reg math5score informal cogscore2yr $basics $alldems if t5samp1 ==1 [pw=wtscore]
					estimates store m2_math
					
					mi estimate, post: reg math5score informal cogscore2yr $basics $qualityall `controls' if t5samp1 ==1 [pw=wtscore]
					estimates store m3_math

					mi estimate, post: reg math5score informal cogscore2yr $basics $alldems $qualityall `controls' if t5samp1 ==1 [pw=wtscore]
					estimates store m4_math

			* second, for children in FORMAL sector care
				drop if informal==1

					mi estimate, post: reg read5score hs pk cogscore2yr testage testmonth if t5samp2 ==1 [pw=wtscore]
					estimates store m5_read

					mi estimate, post: reg read5score hs pk cogscore2yr $basics $alldems if t5samp2 ==1 [pw=wtscore]
					estimates store m6_read

					mi estimate, post: reg read5score hs pk cogscore2yr $basics $qualityformal `controls' if t5samp2 ==1 [pw=wtscore]
					estimates store m7_read

					mi estimate, post: reg read5score hs pk cogscore2yr $basics $alldems $qualityformal `controls' if t5samp2 ==1 [pw=wtscore]
					estimates store m8_read

				
					mi estimate, post: reg math5score hs pk cogscore2yr testage testmonth if t5samp2 ==1 [pw=wtscore]
					estimates store m5_math

					mi estimate, post: reg math5score hs pk cogscore2yr $basics $alldems if t5samp2 ==1 [pw=wtscore]
					estimates store m6_math
					
					mi estimate, post: reg math5score hs pk cogscore2yr $basics $qualityformal `controls' if t5samp2 ==1 [pw=wtscore]
					estimates store m7_math

					mi estimate, post: reg math5score hs pk cogscore2yr $basics $alldems $qualityformal `controls' if t5samp2 ==1 [pw=wtscore]
					estimates store m8_math
					
			restore 

			estout 	* using "$outputsave\Table 5 - `title'.xls", replace ///
					cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N r2) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach ///
					keep(informal hs pk `controls')
			estimates clear

		end //Ends program "table_5"

		table_5 "" 							"Added model"
		table_5 "& num_settings==1" 		"Single care setting"	
		table_5 "" 							"Control for only setting"	"only_setting" 
		table_5 "& ers !=. & arnett!=." 	"No ERS"
		table_5 "& ers !=. & arnett!=."		"Adding ERS"				"ers arnett"	


	**********************************
	* Table 5 interactions
	**********************************
			
		loc ints1 "only_setting  only_informal"
		loc ints2 "only_setting  only_pk only_hs"

		//Construct samples variable for table 5
			capture drop t5samp1 t5samp2
			gen t5samp1 = 1 if read5score !=. & math5score !=. `sample'
			gen t5samp2 = 1 if read5score !=. & math5score !=. `sample'

			foreach x in $qualityall 	{
				replace t5samp1 = . if `x' ==.
			}

			foreach x in $qualityformal	{
				replace t5samp2 = . if `x' ==.
			}

		preserve
			keep if wave==3 & (formal==1 | informal==1)

				mi estimate, post: reg read5score informal cogscore2yr testage testmonth if t5samp1 ==1 [pw=wtscore]
				estimates store m1_read

				mi estimate, post: reg read5score informal cogscore2yr $basics $alldems `ints1' if t5samp1 ==1 [pw=wtscore]
				estimates store m2_read

				mi estimate, post: reg read5score informal cogscore2yr $basics $qualityall `ints1' if t5samp1 ==1 [pw=wtscore]
				estimates store m3_read

				mi estimate, post: reg read5score informal cogscore2yr $basics $alldems $qualityall `ints1' if t5samp1 ==1 [pw=wtscore]
				estimates store m4_read


				mi estimate, post: reg math5score informal cogscore2yr testage testmonth if t5samp1 ==1 [pw=wtscore]
				estimates store m1_math
		
				mi estimate, post: reg math5score informal cogscore2yr $basics $alldems `ints1' if t5samp1 ==1 [pw=wtscore]
				estimates store m2_math
				
				mi estimate, post: reg math5score informal cogscore2yr $basics $qualityall `ints1' if t5samp1 ==1 [pw=wtscore]
				estimates store m3_math

				mi estimate, post: reg math5score informal cogscore2yr $basics $alldems $qualityall `ints1' if t5samp1 ==1 [pw=wtscore]
				estimates store m4_math

		* second, for children in FORMAL sector care
			drop if informal==1

				mi estimate, post: reg read5score hs pk cogscore2yr testage testmonth if t5samp2 ==1 [pw=wtscore]
				estimates store m5_read

				mi estimate, post: reg read5score hs pk cogscore2yr $basics $alldems `ints2' if t5samp2 ==1 [pw=wtscore]
				estimates store m6_read

				mi estimate, post: reg read5score hs pk cogscore2yr $basics $qualityformal `ints2' if t5samp2 ==1 [pw=wtscore]
				estimates store m7_read

				mi estimate, post: reg read5score hs pk cogscore2yr $basics $alldems $qualityformal `ints2' if t5samp2 ==1 [pw=wtscore]
				estimates store m8_read

			
				mi estimate, post: reg math5score hs pk cogscore2yr testage testmonth if t5samp2 ==1 [pw=wtscore]
				estimates store m5_math

				mi estimate, post: reg math5score hs pk cogscore2yr $basics $alldems `ints2' if t5samp2 ==1 [pw=wtscore]
				estimates store m6_math
				
				mi estimate, post: reg math5score hs pk cogscore2yr $basics $qualityformal `ints2' if t5samp2 ==1 [pw=wtscore]
				estimates store m7_math

				mi estimate, post: reg math5score hs pk cogscore2yr $basics $alldems $qualityformal `ints2' if t5samp2 ==1 [pw=wtscore]
				estimates store m8_math
				
		restore 

		estout 	* using "$outputsave\Table 5 - Adding interactions.xls", replace ///
				cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N r2) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach ///
				keep(informal hs pk only_setting only_informal only_hs only_pk)
		estimates clear




	*********************************
	* Table 5 - 2 year olds
	**********************************
			
		capture drop t5samp1
		gen t5samp1 = 1 if cogscore2yr !=.

		foreach x in $qual_2yr 	{
			replace t5samp1 = . if `x' ==.

		}

		preserve
			keep if wave==2 & (formal==1 | informal==1)

				mi estimate, post: reg cogscore2yr informal cogscore9mo testage2yr if t5samp1 ==1 [pw=wtc]
				estimates store m1

				mi estimate, post: reg cogscore2yr informal cogscore9mo testage2yr $alldems if t5samp1 ==1 [pw=wtc]
				estimates store m2

				mi estimate, post: reg cogscore2yr informal cogscore9mo testage2yr $qual_2yr if t5samp1 ==1 [pw=wtc]
				estimates store m3

				mi estimate, post: reg cogscore2yr informal cogscore9mo testage2yr $alldems $qual_2yr if t5samp1 ==1 [pw=wtc]
				estimates store m4

		pause
		restore 

		estout 	* using "$outputsave\Table 5 - 2 year olds.xls", replace ///
				cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N r2) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach ///
				keep(informal)
		estimates clear


	***************************************************
	* Table 5 - Adding quality measures one at a time
	***************************************************

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

			foreach x in math read	{

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $ratio if t5samp1 ==1 [pw=wtscore]
				estimates store m1_`x'a

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $cgchars_all if t5samp1 ==1 [pw=wtscore]
				estimates store m2_`x'a				

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $safety if t5samp1 ==1 [pw=wtscore]
				estimates store m3_`x'a

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $activs_all if t5samp1 ==1 [pw=wtscore]
				estimates store m4_`x'a	


				//Including child/family covariates
				mi estimate, post: reg `x'5score informal cogscore2yr $basics $ratio $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m1_`x'b

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $cgchars_all $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m2_`x'b				

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $safety $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m3_`x'b

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $activs_all $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m4_`x'b			

			}	//closes x loop	
			

		* second, for children in FORMAL sector care
			drop if informal==1

			foreach x in math read	{

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $ratio if t5samp2 ==1 [pw=wtscore]
				estimates store m1_`x'c

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $cgchars_form if t5samp2 ==1 [pw=wtscore]
				estimates store m2_`x'c				

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $safety if t5samp2 ==1 [pw=wtscore]
				estimates store m3_`x'c

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $activs_all if t5samp2 ==1 [pw=wtscore]
				estimates store m4_`x'c	


				//Including child/family covariates
				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $ratio $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m1_`x'd

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $cgchars_form $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m2_`x'd				

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $safety $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m3_`x'd

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $activs_all $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m4_`x'd			

			}	//closes x loop	
				
		restore 

		estout 	*a *b *c *d using "$outputsave\Table 5 - Adding quality measures one at a time.xls", replace ///
				cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N r2) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach ///
				keep(informal hs pk)
		estimates clear




	*************************************************************************
	* Table 5 - Iterative quality measures including observational measures
	*************************************************************************

		//Construct samples variable for table 5
			capture drop t5samp1 t5samp2
			gen t5samp1 = 1 if read5score !=. & math5score !=.
			gen t5samp2 = 1 if read5score !=. & math5score !=.

			foreach x in $qualityall $ccobs	{
				replace t5samp1 = . if `x' ==.
			}

			foreach x in $qualityformal $ccobs	{
				replace t5samp2 = . if `x' ==.
			}

		preserve
			keep if wave==3 & (formal==1 | informal==1)

			foreach x in math read	{

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $ratio if t5samp1 ==1 [pw=wtscore]
				estimates store m1_`x'a

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $cgchars_all if t5samp1 ==1 [pw=wtscore]
				estimates store m2_`x'a				

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $safety if t5samp1 ==1 [pw=wtscore]
				estimates store m3_`x'a

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $activs_all if t5samp1 ==1 [pw=wtscore]
				estimates store m4_`x'a	
	
				mi estimate, post: reg `x'5score informal cogscore2yr $basics $ccobs if t5samp1 ==1 [pw=wtscore]
				estimates store m5_`x'a	

				//Including child/family covariates
				mi estimate, post: reg `x'5score informal cogscore2yr $basics $ratio $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m1_`x'b

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $cgchars_all $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m2_`x'b				

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $safety $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m3_`x'b

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $activs_all $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m4_`x'b		

				mi estimate, post: reg `x'5score informal cogscore2yr $basics $ccobs $alldems if t5samp1 ==1 [pw=wtscore]
				estimates store m5_`x'b			

			}	//closes x loop	
			

		* second, for children in FORMAL sector care
			drop if informal==1

			foreach x in math read	{

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $ratio if t5samp2 ==1 [pw=wtscore]
				estimates store m1_`x'c

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $cgchars_form if t5samp2 ==1 [pw=wtscore]
				estimates store m2_`x'c				

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $safety if t5samp2 ==1 [pw=wtscore]
				estimates store m3_`x'c

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $activs_all if t5samp2 ==1 [pw=wtscore]
				estimates store m4_`x'c	

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $ccobs if t5samp2 ==1 [pw=wtscore]
				estimates store m5_`x'c	


				//Including child/family covariates
				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $ratio $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m1_`x'd

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $cgchars_form $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m2_`x'd				

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $safety $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m3_`x'd

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $activs_all $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m4_`x'd	

				mi estimate, post: reg `x'5score hs pk cogscore2yr $basics $ccobs $alldems if t5samp2 ==1 [pw=wtscore]
				estimates store m5_`x'd			

			}	//closes x loop	
				
		restore 

		estout 	*a *b *c *d using "$outputsave\Table 5 - Adding quality measures one at a time (including ERS).xls", replace ///
				cells(b(star fmt(2)) se(par(`"="("'`")""')fmt(2))) stats(N r2) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) stardetach ///
				keep(informal hs pk)
		estimates clear


	************************************
	* Correlations of quality measures
	************************************
		reg $qualityall $ccobs
		corr $qualityall $ccobs if e(sample)==1
		
		reg $qualityformal $ccobs	
		corr $qualityformal $ccobs if e(sample) ==1
