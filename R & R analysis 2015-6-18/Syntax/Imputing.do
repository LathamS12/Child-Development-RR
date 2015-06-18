/***********************************************************************
* Author: Scott Latham
* Purpose: This file imputes missing data for the Child Development R & R
*
*
* Created: 1/30/2015
* Last modified: 6/18/2015
************************************************************************/

	pause on
	use "$datasave\master dataset.dta", clear

	capture log close
	log using "F:\Scott\Child Development R & R\Logs\Imputation", replace



	#delimit ;

		gl ivs 	"black hisp asian other hinc urban rural bweight weight height mpart mlook 
						mout paredhilesshs paredhihs paredhilesscoll enghome books wic
						preads ptvhrswk dinfam discorp testage testmonth kinder cogscore2yr cogscore9mo " ;

		gl dvs	"ratio turnover smokedet firstaid outlet HQT LQT aget edt ecedeg mqecet ongot
						cda exp treads tvhrs playout zoo library ers arnett readevery mathevery 
						comp gampuzz writcurr wholeclass chisel carehrs  ";


		gl reg 		"poor age female numchild cregion" ;

	#delimit cr

	sum $ivs $dvs
	sum $reg


	//Set and register the data
		mi set wide
		mi register imputed $ivs $dvs
		mi register regular $reg

		//set seed 10001
		set seed 18571

		//Including all controls
			mi impute chained (regress) ${ivs} ${dvs} = ${reg}, add(20)
			log close


		//Delete imputed values for dependent variables, and unregister those variables
			foreach x in $dvs	{
				drop _?_`x'
			}

			mi unregister $dvs	


		save "$datasave\Imputed", replace

	
