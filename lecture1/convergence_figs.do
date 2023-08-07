/*
This code creates updated versions of Figures 25 and 26 in Jones 2016 
*/

set scheme plotplainblind

*colors
global myred "216 27 96"
global myblue "30 136 229"
global myyellow "255 193 7"
global mygreen "16 185 156"


*Data from: https://ourworldindata.org/population-growth#explore-data-poverty
import delimited "C:\Users\tanner_regan\Downloads\population-and-demography.csv", clear
keep countryname year population
keep if year>=1960 & year<=2019
gen pop2019=population if year==2019
gen pop1960=population if year==1960
collapse (mean) population pop2019 pop1960, by(countryname)
rename countryname entity
save "temp/population_counts.dta", replace

*Data from: https://ourworldindata.org/grapher/gdp-per-capita-penn-world-table
import delimited "C:\Users\tanner_regan\Downloads\gdp-per-capita-penn-world-table.csv", clear
rename gdppercapitaoutputmultiplepriceb GPDpc
reshape wide GPDpc, i(code entity) j(year)

*merge with population
merge 1:1 entity using "temp/population_counts.dta"
drop _merge

*USE 1960 onwards because data availablility is better
keep if missing(GPDpc1960)==0 & missing(GPDpc2019)==0

*Make OECD dummies
gen oecd=0
local cl AUT BEL CAN CHE DEU DNK ESP FIN FRA GBR GRC IRE ISL ITA JPN LUX NLD NOR PRT SWE TUR USA //OECD countries prior to 1970
foreach c in `cl'{
replace oecd=1 if code=="`c'"
}
tab entity if oecd==1

*calculate average annual growth rates
gen growth2011_1960=((GPDpc2011/GPDpc1960)^(1/(2011-1960))-1)*100 //this is the period that Jones 2016 looks at
gen growth2019_1960=((GPDpc2019/GPDpc1960)^(1/(2019-1960))-1)*100

*calculate GDP in 1960 relative to USA, take logs
sum GPDpc1960 if entity=="United States"
gen GDPpc1960relusa=ln(GPDpc1960/`r(mean)')


*ALL countries
reg growth2019_1960 GDPpc1960relusa
predict growth_hat
local b0=_b[_cons]
local b0: di %2.0f `b0'
local b1=_b[GDPpc1960relusa]
local b1: di %3.2f `b1'
local se1=_se[GDPpc1960relusa]
local se1: di %3.2f `se1'
	
twoway ///
	(line growth_hat GDPpc1960relusa, lcolor(black) sort lpattern(solid) lwidth(thin)) ///
	(scatter growth2019_1960 GDPpc1960relusa if oecd==1, mcolor("$myred") msymbol(oh) msize(medium)) ///
	(scatter growth2019_1960 GDPpc1960relusa if oecd==0, mcolor("$myblue") msymbol(oh) msize(medium)) ///
	if entity!="Venezuela" /// //drop venezuala just because it is a huge negative growth outlier and skews the axis
	, yline(0, lcolor(gray)) ytitle("Avg. growth per annum (1960-2019)") xtitle("GDP per capita 1960 (relative to USA)") ///
	xscale(range(-3.615506 .197651)) yscale(range(-0.025 0.07)) ///
	xlab(-3.4657359 "1/32" -2.7725887 "1/16" -2.0794415 "1/8" -1.3862944 "1/4" -.69314718 "1/2" 0 "1") ///
	ylab(-2.5 "-2.5%" 0 "0%" 2.5 "2.5%" 5 "5%" 7.5 "7.5%") ///
	legend(order(2 "OECD" 3 "non-OECD" 1 "y = `b1'(`se1') lnx + `b0'") pos(2) ring(0) col(1) region(lcolor(black)))
graph export "graphs/convergence1960_2019.png", replace
drop growth_hat


*OECD only
reg growth2019_1960 GDPpc1960relusa if oecd==1
predict growth_hat if oecd==1
local b0=_b[_cons]
local b0: di %2.0f `b0'
local b1=_b[GDPpc1960relusa]
local b1: di %3.2f `b1'
local se1=_se[GDPpc1960relusa]
local se1: di %3.2f `se1'
	
twoway ///
	(line growth_hat GDPpc1960relusa, lcolor(black) sort lpattern(solid) lwidth(thin)) ///
	(scatter growth2019_1960 GDPpc1960relusa if oecd==1, mcolor("$myred") msymbol(oh) msize(medium)) ///
	, yline(0, lcolor(gray)) ytitle("Avg. growth per annum (1960-2019)") xtitle("GDP per capita 1960 (relative to USA)") ///
	xscale(range(-3.615506 .197651)) yscale(range(-0.025 0.07)) ///
	xlab(-3.4657359 "1/32" -2.7725887 "1/16" -2.0794415 "1/8" -1.3862944 "1/4" -.69314718 "1/2" 0 "1") ///
	ylab(-2.5 "-2.5%" 0 "0%" 2.5 "2.5%" 5 "5%" 7.5 "7.5%") ///
	legend(order(2 "OECD" 1 "y = `b1'(`se1') lnx + `b0'") pos(2) ring(0) col(1) region(lcolor(black)))
graph export "graphs/convergence1960_2019oecd.png", replace
drop growth_hat


*ALL countries (1960-2011)
reg growth2011_1960 GDPpc1960relusa
predict growth_hat
local b0=_b[_cons]
local b0: di %2.0f `b0'
local b1=_b[GDPpc1960relusa]
local b1: di %3.2f `b1'
local se1=_se[GDPpc1960relusa]
local se1: di %3.2f `se1'
	
twoway ///
	(line growth_hat GDPpc1960relusa, lcolor(black) sort lpattern(solid) lwidth(thin)) ///
	(scatter growth2011_1960 GDPpc1960relusa if oecd==1, mcolor("$myred") msymbol(oh) msize(medium)) ///
	(scatter growth2011_1960 GDPpc1960relusa if oecd==0, mcolor("$myblue") msymbol(oh) msize(medium)) ///
	if entity!="Venezuela" /// //drop venezuala just because it is a huge negative growth outlier and skews the axis
	, yline(0, lcolor(gray)) ytitle("Avg. growth per annum (1960-2011)") xtitle("GDP per capita 1960 (relative to USA)") ///
	xscale(range(-3.615506 .197651)) yscale(range(-0.025 0.07)) ///
	xlab(-3.4657359 "1/32" -2.7725887 "1/16" -2.0794415 "1/8" -1.3862944 "1/4" -.69314718 "1/2" 0 "1") ///
	ylab(-2.5 "-2.5%" 0 "0%" 2.5 "2.5%" 5 "5%" 7.5 "7.5%") ///
	legend(order(2 "OECD" 3 "non-OECD" 1 "y = `b1'(`se1') lnx + `b0'") pos(2) ring(0) col(1) region(lcolor(black)))
graph export "graphs/convergence1960_2011.png", replace
drop growth_hat


*OECD only (1960-2011)
reg growth2011_1960 GDPpc1960relusa if oecd==1
predict growth_hat if oecd==1
local b0=_b[_cons]
local b0: di %2.0f `b0'
local b1=_b[GDPpc1960relusa]
local b1: di %3.2f `b1'
local se1=_se[GDPpc1960relusa]
local se1: di %3.2f `se1'
	
twoway ///
	(line growth_hat GDPpc1960relusa, lcolor(black) sort lpattern(solid) lwidth(thin)) ///
	(scatter growth2011_1960 GDPpc1960relusa if oecd==1, mcolor("$myred") msymbol(oh) msize(medium)) ///
	, yline(0, lcolor(gray)) ytitle("Avg. growth per annum (1960-2011)") xtitle("GDP per capita 1960 (relative to USA)") ///
	xscale(range(-3.615506 .197651)) yscale(range(-0.025 0.07)) ///
	xlab(-3.4657359 "1/32" -2.7725887 "1/16" -2.0794415 "1/8" -1.3862944 "1/4" -.69314718 "1/2" 0 "1") ///
	ylab(-2.5 "-2.5%" 0 "0%" 2.5 "2.5%" 5 "5%" 7.5 "7.5%") ///
	legend(order(2 "OECD" 1 "y = `b1'(`se1') lnx + `b0'") pos(2) ring(0) col(1) region(lcolor(black)))
graph export "graphs/convergence1960_2011oecd.png", replace
drop growth_hat


*ALL countries (weight by average population)
reg growth2019_1960 GDPpc1960relusa [w=population]
predict growth_hat
local b0=_b[_cons]
local b0: di %2.0f `b0'
local b1=_b[GDPpc1960relusa]
local b1: di %3.2f `b1'
local se1=_se[GDPpc1960relusa]
local se1: di %3.2f `se1'
	
twoway ///
	(line growth_hat GDPpc1960relusa, lcolor(black) sort lpattern(solid) lwidth(thin)) ///
	(scatter growth2019_1960 GDPpc1960relusa if oecd==1 [w=population], mcolor("$myred") msymbol(oh) msize(medium)) ///
	(scatter growth2019_1960 GDPpc1960relusa if oecd==0 [w=population], mcolor("$myblue") msymbol(oh) msize(medium)) ///
	if entity!="Venezuela" /// //drop venezuala just because it is a huge negative growth outlier and skews the axis
	, yline(0, lcolor(gray)) ytitle("Avg. growth per annum (1960-2019)") xtitle("GDP per capita 1960 (relative to USA)") ///
	xscale(range(-3.615506 .197651)) yscale(range(-0.025 0.07)) ///
	xlab(-3.4657359 "1/32" -2.7725887 "1/16" -2.0794415 "1/8" -1.3862944 "1/4" -.69314718 "1/2" 0 "1") ///
	ylab(-2.5 "-2.5%" 0 "0%" 2.5 "2.5%" 5 "5%" 7.5 "7.5%") ///
	legend(order(2 "OECD" 3 "non-OECD" 1 "y = `b1'(`se1') lnx + `b0'") pos(2) ring(0) col(1) region(lcolor(black)))
graph export "graphs/convergence1960_2019popwt.png", replace
drop growth_hat


*ALL countries (weight by today population)
reg growth2019_1960 GDPpc1960relusa [w=pop2019]
predict growth_hat
local b0=_b[_cons]
local b0: di %2.0f `b0'
local b1=_b[GDPpc1960relusa]
local b1: di %3.2f `b1'
local se1=_se[GDPpc1960relusa]
local se1: di %3.2f `se1'
	
twoway ///
	(line growth_hat GDPpc1960relusa, lcolor(black) sort lpattern(solid) lwidth(thin)) ///
	(scatter growth2019_1960 GDPpc1960relusa if oecd==1 [w=pop2019], mcolor("$myred") msymbol(oh) msize(medium)) ///
	(scatter growth2019_1960 GDPpc1960relusa if oecd==0 [w=pop2019], mcolor("$myblue") msymbol(oh) msize(medium)) ///
	if entity!="Venezuela" /// //drop venezuala just because it is a huge negative growth outlier and skews the axis
	, yline(0, lcolor(gray)) ytitle("Avg. growth per annum (1960-2019)") xtitle("GDP per capita 1960 (relative to USA)") ///
	xscale(range(-3.615506 .197651)) yscale(range(-0.025 0.07)) ///
	xlab(-3.4657359 "1/32" -2.7725887 "1/16" -2.0794415 "1/8" -1.3862944 "1/4" -.69314718 "1/2" 0 "1") ///
	ylab(-2.5 "-2.5%" 0 "0%" 2.5 "2.5%" 5 "5%" 7.5 "7.5%") ///
	legend(order(2 "OECD" 3 "non-OECD" 1 "y = `b1'(`se1') lnx + `b0'") pos(2) ring(0) col(1) region(lcolor(black)))
graph export "graphs/convergence1960_2019popwt2019.png", replace
drop growth_hat
