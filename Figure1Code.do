clear all
macro drop _all
set more off
set maxvar 7000

global folder "/Users/.../folder"
global data "${folder}/Data"
use "${data}/GSS7218_R1.DTA", clear

svyset [weight=wtssall], strata (vstrat) psu(vpsu) singleunit(scaled)

keep if year>=1977

********************************************************************************
// #1
// Recode variables
********************************************************************************

// Make binary gender attitudes items (agree/disagree)
// Recode so 1=more liberal, 0=more conservative

	gen fepol_b=.
	replace fepol_b=0 if fepol==1
	replace fepol_b=1 if fepol==2
	label var fepol_b "Women not suited for politics - binary"
	label define disagreeb 0 "0 agree" 1 "1 disagree"
	label val fepol_b disagreeb
	tab fepol fepol_b
	
	gen fepresch_b=.
	replace fepresch_b=0 if fepresch==1 | fepresch==2
	replace fepresch_b=1 if fepresch==3 | fepresch==4
	label var fepresch_b "Preschool kids suffer if mother works - binary"
	label val fepresch_b disagreeb
	tab fepresch fepresch_b
	
	gen fefam_b=.
	replace fefam_b=0 if fefam==1 | fefam==2
	replace fefam_b=1 if fefam==3 | fefam==4
	label var fefam_b "Better for man to work, woman tend home - binary"
	label val fefam_b disagreeb
	tab fefam fefam_b
	
	gen fechld_b=.
	replace fechld_b=0 if fechld==3 | fechld==4
	replace fechld_b=1 if fechld==1 | fechld==2
	label var fechld_b "Mother working doesn't hurt children - binary"
	label define agreeb 0 "0 disagree" 1 "1 agree"
	label val fechld_b agreeb
	tab fechld fechld_b

// Education

	// Any college
	gen anycollege=0 if educ<=12 & !missing(educ)
	replace anycollege=1 if educ>12 & !missing(educ)
	label var anycollege "Education beyond HS"
	label define anycollege 0 "HS Degree or Below" 1 "Any College"
	label val anycollege anycollege
	tab educ anycollege
	
	// BA degree+
	gen BA=1 if degree==3 | degree==4
	replace BA=0 if degree<3 
	label var BA "Bachelor's degree or above"
	label define yesno 1 "1 yes" 0 "0 no"
	label val BA yesno
	tab degree BA
	
	
********************************************************************************
// #2
// Make Figure 1
********************************************************************************
	
global gendervars "fepol_b fepresch_b fefam_b fechld_b"

foreach var in $gendervars {
	svy: logit `var' year##sex age educ
	
	margins year#sex, vce(unconditional)
	marginsplot, recastci(rarea) ciopt(color(%50)) ///
		name(`var'_gender, replace) ///
		xlabel(1975(5)2020) ylabel(.2(.2)1) ///
		xtitle("Year") ytitle("Predicted Probability") title("") scheme(538w) ///
		plot1opts(mcolor(blue) lcolor(blue)) ///
		ci1opts(lcolor(blue) fcolor(blue) fintensity(50) lwidth(none)) ///
		plot2opts (mcolor(red) lcolor(red)) ///
		ci2opts(lcolor(red) fcolor(red) fintensity(50) lwidth(none)) ///
		legend(order(4 "Women" 3 "Men") ring(0) position(4))
}

foreach var in $gendervars {
	svy: logit `var' year##anycollege age i.sex
	
	margins year#anycollege, vce(unconditional)
	marginsplot, recastci(rarea) ciopt(color(%50)) ///
		name(`var'_educ, replace) ///
		xlabel(1975(5)2020) ylabel(.2(.2)1) ///
		xtitle("Year") ytitle("Predicted Probability") title("") scheme(538w) ///
		plot1opts(mcolor(orange) lcolor(orange)) ///
		ci1opts(lcolor(orange) fcolor(orange) fintensity(50) lwidth(none)) ///
		plot2opts (mcolor(green) lcolor(green)) ///
		ci2opts(lcolor(green) fcolor(green) fintensity(50) lwidth(none)) ///
		legend(order(4 "College" 3 "HS or below") ring(0) position(4))
}

graph combine fepol_b_gender fepol_b_educ, rows(1) scheme(538w) ///
	name(fepol, replace) title("Women in Politics") iscale(*.9)
	
graph combine fepresch_b_gender fepresch_b_educ, rows(1) scheme(538w) ///
	name(fepresch, replace) title("Working Mothers of Preschool Kids") iscale(*.9)	
	
graph combine fefam_b_gender fefam_b_educ, rows(1) scheme(538w) ///
	name(fefam, replace) title("Traditional Family and Work Social Roles") iscale(*.9)

graph combine fechld_b_gender fechld_b_educ, rows(1) scheme(538w) ///
	name(fechld, replace) title("Working Mothers of Children") iscale(*.9)
	
graph combine fepol fefam fechld fepresch, cols(1) scheme(538w) ///
	name(combine, replace)

graph display combine, xsize(4) ysize(6)
graph export "${folder}/fig1.png", replace


********************************************************************************
// #3
// Robustness check
********************************************************************************

// Re-do education graphs with variable for BA degree+

	svy: logit fepol_b year##BA age i.sex
	margins year#BA, vce(unconditional)
	marginsplot, recastci(rarea) ciopt(color(%50)) ///
		name(fepol_b_ba, replace) title("Women in Politics") ///
		xlabel(1975(5)2020) ylabel(.2(.2)1) ///
		xtitle("Year") ytitle("Predicted Probability") scheme(538w) ///
		plot1opts(mcolor(orange) lcolor(orange)) ///
		ci1opts(lcolor(orange) fcolor(orange) fintensity(50) lwidth(none)) ///
		plot2opts (mcolor(green) lcolor(green)) ///
		ci2opts(lcolor(green) fcolor(green) fintensity(50) lwidth(none)) ///
		legend(order(4 "College degree" 3 "Less than college degree") ring(0) position(4))
		
	svy: logit fepresch_b year##BA age i.sex
	margins year#BA, vce(unconditional)
	marginsplot, recastci(rarea) ciopt(color(%50)) ///
		name(fepresch_b_ba, replace) title("Working Mothers of Preschool Kids") ///
		xlabel(1975(5)2020) ylabel(.2(.2)1) ///
		xtitle("Year") ytitle("Predicted Probability") scheme(538w) ///
		plot1opts(mcolor(orange) lcolor(orange)) ///
		ci1opts(lcolor(orange) fcolor(orange) fintensity(50) lwidth(none)) ///
		plot2opts (mcolor(green) lcolor(green)) ///
		ci2opts(lcolor(green) fcolor(green) fintensity(50) lwidth(none)) ///
		legend(order(4 "College degree" 3 "Less than college degree") ring(0) position(4))
		
	svy: logit fefam_b year##BA age i.sex
	margins year#BA, vce(unconditional)
	marginsplot, recastci(rarea) ciopt(color(%50)) ///
		name(fefam_b_ba, replace) title("Traditional Family and Work Social Roles") ///
		xlabel(1975(5)2020) ylabel(.2(.2)1) ///
		xtitle("Year") ytitle("Predicted Probability") scheme(538w) ///
		plot1opts(mcolor(orange) lcolor(orange)) ///
		ci1opts(lcolor(orange) fcolor(orange) fintensity(50) lwidth(none)) ///
		plot2opts (mcolor(green) lcolor(green)) ///
		ci2opts(lcolor(green) fcolor(green) fintensity(50) lwidth(none)) ///
		legend(order(4 "College degree" 3 "Less than college degree") ring(0) position(4))		

	svy: logit fechld_b year##BA age i.sex
	margins year#BA, vce(unconditional)
	marginsplot, recastci(rarea) ciopt(color(%50)) ///
		name(fechld_b_ba, replace) title("Working Mothers of Children") ///
		xlabel(1975(5)2020) ylabel(.2(.2)1) ///
		xtitle("Year") ytitle("Predicted Probability") scheme(538w) ///
		plot1opts(mcolor(orange) lcolor(orange)) ///
		ci1opts(lcolor(orange) fcolor(orange) fintensity(50) lwidth(none)) ///
		plot2opts (mcolor(green) lcolor(green)) ///
		ci2opts(lcolor(green) fcolor(green) fintensity(50) lwidth(none)) ///
		legend(order(4 "College degree" 3 "Less than college degree") ring(0) position(4))
		
graph combine fepol_b_ba fefam_b_ba fechld_b_ba fepresch_b_ba, cols(1) scheme(538w) ///
	name(ba, replace)		
		
graph display ba, xsize(2) ysize(6)
graph export "${folder}/figA1.png", replace
