/***********************************************************************
* Author: Scott Latham
* Purpose: This file imputes missing data for the Child Development R & R
*
*
* Created: 1/30/2015
* Last modified: 3/10/2015
************************************************************************/
	
	use "$datasave\master dataset.dta", clear
	pause on


	capture log close
	log using "F:\Scott\ECLS-B Rerun\Logs\Imputation", replace


	#delimit ;

		gl impute 	"black hisp asian other hinc urban rural bweight weight height mpart mlook 
						mout paredhilesshs paredhihs paredhilesscoll enghome books wic
						preads ptvhrswk dinfam discorp " ;

		gl reg 		"poor age female numchild cregion" ;

	#delimit cr

	sum $impute
	sum $reg

	//Set and register the data
		mi set wide
		mi register imputed $impute
		mi register regular $reg

		set seed 10001

		//Including all controls
			mi impute chained (regress) $impute = $reg, add(5)
			log close

			save "$datasave\Imputed", replace

		
