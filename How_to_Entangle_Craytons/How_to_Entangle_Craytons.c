/*20:*/
#line 526 "How_to_Entangle_Craytons.w"

#include <stdio.h> 
#include <stdlib.h> 
#include <math.h> 
#include <float.h> 

/*2:*/
#line 88 "How_to_Entangle_Craytons.w"

int a_global_variable= 12345;

double
number_between_zero_and_one()
{
int i= a_global_variable*75;
while(i> 65537)i= i-65537;
a_global_variable= i;
return((1.0*i)/65537.0);
}

/*:2*/
#line 532 "How_to_Entangle_Craytons.w"

/*3:*/
#line 105 "How_to_Entangle_Craytons.w"

typedef enum{updown,sideways}crayton;

/*:3*/
#line 533 "How_to_Entangle_Craytons.w"

/*4:*/
#line 118 "How_to_Entangle_Craytons.w"

typedef struct{crayton k1;crayton k2;}crayton_pair;

crayton_pair
crayton_source()
{
crayton_pair pair;
if(number_between_zero_and_one()<0.5)
{
pair.k1= updown;
pair.k2= sideways;
}
else
{
pair.k1= sideways;
pair.k2= updown;
}
return pair;
}

/*:4*/
#line 534 "How_to_Entangle_Craytons.w"

/*5:*/
#line 148 "How_to_Entangle_Craytons.w"

typedef double cray_ban;

/*:5*/
#line 535 "How_to_Entangle_Craytons.w"

/*7:*/
#line 211 "How_to_Entangle_Craytons.w"

int
law_of_logodaedalus(cray_ban angle,crayton crayton_that_will_be_sent)
{
double x;
int i;
if(crayton_that_will_be_sent==updown)
x= sin(angle);
else
x= cos(angle);
if(number_between_zero_and_one()<x*x)
i= +1;
else
i= -1;
return i;
}

/*:7*/
#line 536 "How_to_Entangle_Craytons.w"

/*8:*/
#line 234 "How_to_Entangle_Craytons.w"

typedef struct
{
crayton_pair pair;
int way_k1_was_sent;
int way_k2_was_sent;
}event_data;

event_data
experimental_event(cray_ban angle1,cray_ban angle2)
{
event_data data;
data.pair= crayton_source();
data.way_k1_was_sent= law_of_logodaedalus(angle1,data.pair.k1);
data.way_k2_was_sent= law_of_logodaedalus(angle2,data.pair.k2);
return data;
}

/*:8*/
#line 537 "How_to_Entangle_Craytons.w"

/*9:*/
#line 263 "How_to_Entangle_Craytons.w"

typedef struct
{
cray_ban angle1;
cray_ban angle2;
int number_of_events;
int number_of_updown_sideways_plus_plus;
int number_of_updown_sideways_plus_minus;
int number_of_updown_sideways_minus_plus;
int number_of_updown_sideways_minus_minus;
int number_of_sideways_updown_plus_plus;
int number_of_sideways_updown_plus_minus;
int number_of_sideways_updown_minus_plus;
int number_of_sideways_updown_minus_minus;
}series_data;

/*:9*/
#line 538 "How_to_Entangle_Craytons.w"

/*10:*/
#line 282 "How_to_Entangle_Craytons.w"

series_data
experimental_series(cray_ban angle1,cray_ban angle2,int n)
{
series_data sdata;
sdata.angle1= angle1;
sdata.angle2= angle2;
sdata.number_of_events= n;
sdata.number_of_updown_sideways_plus_plus= 0;
sdata.number_of_updown_sideways_plus_minus= 0;
sdata.number_of_updown_sideways_minus_plus= 0;
sdata.number_of_updown_sideways_minus_minus= 0;
sdata.number_of_sideways_updown_plus_plus= 0;
sdata.number_of_sideways_updown_plus_minus= 0;
sdata.number_of_sideways_updown_minus_plus= 0;
sdata.number_of_sideways_updown_minus_minus= 0;
for(int i= 0;i!=n;i= i+1)
{
event_data edata= experimental_event(angle1,angle2);
if(edata.pair.k1==updown)
{
if(edata.way_k1_was_sent==+1)
{
if(edata.way_k2_was_sent==+1)
{
sdata.number_of_updown_sideways_plus_plus= 
sdata.number_of_updown_sideways_plus_plus+1;
}
else
{
sdata.number_of_updown_sideways_plus_minus= 
sdata.number_of_updown_sideways_plus_minus+1;
}
}
else
{
if(edata.way_k2_was_sent==+1)
{
sdata.number_of_updown_sideways_minus_plus= 
sdata.number_of_updown_sideways_minus_plus+1;
}
else
{
sdata.number_of_updown_sideways_minus_minus= 
sdata.number_of_updown_sideways_minus_minus+1;
}
}
}
else
{
if(edata.way_k1_was_sent==+1)
{
if(edata.way_k2_was_sent==+1)
{
sdata.number_of_sideways_updown_plus_plus= 
sdata.number_of_sideways_updown_plus_plus+1;
}
else
{
sdata.number_of_sideways_updown_plus_minus= 
sdata.number_of_sideways_updown_plus_minus+1;
}
}
else
{
if(edata.way_k2_was_sent==+1)
{
sdata.number_of_sideways_updown_minus_plus= 
sdata.number_of_sideways_updown_minus_plus+1;
}
else
{
sdata.number_of_sideways_updown_minus_minus= 
sdata.number_of_sideways_updown_minus_minus+1;
}
}
}
}
return sdata;
}

/*:10*/
#line 539 "How_to_Entangle_Craytons.w"

/*18:*/
#line 494 "How_to_Entangle_Craytons.w"

double
correlation_coefficient_estimate(series_data sdata)
{
/*14:*/
#line 430 "How_to_Entangle_Craytons.w"

double freq_of_updown_sideways_plus_plus= 
(1.0*sdata.number_of_updown_sideways_plus_plus)/sdata.number_of_events;
double freq_of_updown_sideways_plus_minus= 
(1.0*sdata.number_of_updown_sideways_plus_minus)/sdata.number_of_events;
double freq_of_updown_sideways_minus_plus= 
(1.0*sdata.number_of_updown_sideways_minus_plus)/sdata.number_of_events;
double freq_of_updown_sideways_minus_minus= 
(1.0*sdata.number_of_updown_sideways_minus_minus)/sdata.number_of_events;
double freq_of_sideways_updown_plus_plus= 
(1.0*sdata.number_of_sideways_updown_plus_plus)/sdata.number_of_events;
double freq_of_sideways_updown_plus_minus= 
(1.0*sdata.number_of_sideways_updown_plus_minus)/sdata.number_of_events;
double freq_of_sideways_updown_minus_plus= 
(1.0*sdata.number_of_sideways_updown_minus_plus)/sdata.number_of_events;
double freq_of_sideways_updown_minus_minus= 
(1.0*sdata.number_of_sideways_updown_minus_minus)/sdata.number_of_events;

/*:14*/
#line 498 "How_to_Entangle_Craytons.w"

/*15:*/
#line 455 "How_to_Entangle_Craytons.w"

double estimate_of_cos2_phi1_cos2_phi2= 
freq_of_updown_sideways_minus_plus+freq_of_sideways_updown_plus_minus;
double estimate_of_cos2_phi1_sin2_phi2= 
freq_of_updown_sideways_minus_minus+freq_of_sideways_updown_plus_plus;
double estimate_of_sin2_phi1_cos2_phi2= 
freq_of_updown_sideways_plus_plus+freq_of_sideways_updown_minus_minus;
double estimate_of_sin2_phi1_sin2_phi2= 
freq_of_updown_sideways_plus_minus+freq_of_sideways_updown_minus_plus;

/*:15*/
#line 499 "How_to_Entangle_Craytons.w"

/*16:*/
#line 476 "How_to_Entangle_Craytons.w"

double estimate_of_cos_phi1_minus_phi2= 
sqrt(estimate_of_cos2_phi1_cos2_phi2)+sqrt(estimate_of_sin2_phi1_sin2_phi2);
double estimate_of_sin_phi1_minus_phi2= 
sqrt(estimate_of_sin2_phi1_cos2_phi2)-sqrt(estimate_of_cos2_phi1_sin2_phi2);

/*:16*/
#line 500 "How_to_Entangle_Craytons.w"

/*17:*/
#line 484 "How_to_Entangle_Craytons.w"

double estimate_of_correlation_coefficient= 
-((estimate_of_cos_phi1_minus_phi2*estimate_of_cos_phi1_minus_phi2)-
(estimate_of_sin_phi1_minus_phi2*estimate_of_sin_phi1_minus_phi2));

/*:17*/
#line 501 "How_to_Entangle_Craytons.w"

return estimate_of_correlation_coefficient;
}

/*:18*/
#line 540 "How_to_Entangle_Craytons.w"

/*19:*/
#line 509 "How_to_Entangle_Craytons.w"

void
print_correlation_coefficient_estimate(series_data sdata)
{
printf("cray_ban angle1      %4.1f deg\n",
sdata.angle1*180.0/M_PI);
printf("cray_ban angle2      %4.1f deg\n",
sdata.angle2*180.0/M_PI);
printf("nominal corr coef    %+8.5f\n",
-cos(2.0*(sdata.angle1-sdata.angle2)));
printf("measured corr coef   %+8.5f\n",
correlation_coefficient_estimate(sdata));
}

/*:19*/
#line 541 "How_to_Entangle_Craytons.w"


int
main()
{
int n= 10000;
series_data sdata1= experimental_series(0.0,M_PI/8.0,n);
series_data sdata2= experimental_series(0.0,3.0*M_PI/8.0,n);
series_data sdata3= experimental_series(M_PI/4.0,M_PI/8.0,n);
series_data sdata4= experimental_series(M_PI/4.0,3.0*M_PI/8.0,n);
printf("\n");
print_correlation_coefficient_estimate(sdata1);
printf("\n");
print_correlation_coefficient_estimate(sdata2);
printf("\n");
print_correlation_coefficient_estimate(sdata3);
printf("\n");
print_correlation_coefficient_estimate(sdata4);
printf("\n");
return 0;
}

/*:20*/
