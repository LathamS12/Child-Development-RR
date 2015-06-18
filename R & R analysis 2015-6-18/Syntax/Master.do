/***********************************************************************
* Author: Scott Latham
* Purpose: This is the master file for the  Child Development R & R
*
*
* Created: 6/16/2015
* Last modified: 6/18/2015
************************************************************************/


gl path "F:\Scott\Child Development R & R"

gl datasave 	"${path}\Data"
gl outputsave 	"${path}\Tables"
gl graphsave 	"${path}\Figures"


	do "${path}\Syntax\Data Cleaning and Variable Selection"
	do "${path}\Syntax\Imputing"

	//do "${path}\Syntax\Analysis"
	//do "${path}\Syntax\Imputed estimates"
	//do "${path}\Syntax\Analysis - Specification Checks
