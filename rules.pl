%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file contains some of the San Jose inclusive housing rules implemented in
% SWI-Prolog using s(CASP). The easiest way to run it would be to copy it into
% SWISH.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(library(scasp)).
:- set_prolog_flag(scasp_unknown, fail).
:- style_check(-singleton).
:- style_check(-discontiguous).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Residential development basics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#pred rd_type(RD, Type) :: '@(RD) is of type @(Type)'.
#pred rd_iu_type(RD, IUType) :: '@(RD)\'s inclusionary units are of type @(IUType)'.
#pred rd_iu_location(RD, IULocation) :: '@(RD)\'s inclusionary units are located at @(IULocation)'.
#pred rd_iu_share(RD, Income, Proportion) :: 'A @(Proportion) proportion of @(RD)\'s units are affordable to @(Income)'.
#pred rd_plan_count(RD, Plan, Count) :: '@(RD) contains @(Count) units of plan @(Plan)'.
#pred unit_plan_area(Plan, Sqft) :: '@(Plan) units have @(Sqft) square feet of living area'.

total_area_for_unit_plan(RD, Plan, TotalArea) :-
    rd_plan_count(RD, Plan, PlanCount),
    unit_plan_area(Plan, UnitArea),
    TotalArea is PlanCount * UnitArea.

sum_areas(RD, [Plan|Tail], TotalArea) :-
    sum_areas(RD, Tail, TailArea),
    total_area_for_unit_plan(RD, Plan, UnitArea),
    TotalArea is TailArea + UnitArea.
sum_areas(RD, [], 0).

rd_total_area(RD, TotalArea) :-
    rd_unit_plans(RD, Plans),
    sum_areas(RD, Plans, TotalArea).

count_plans_units(RD, [Plan|Tail], TotalUnits) :-
    rd_plan_count(RD, Plan, Units),
    count_plans_units(RD, Tail, TailUnits),
    TotalUnits is Units + TailUnits.
count_plans_units(RD, [], 0).

rd_unit_count(RD, Units) :-
    rd_unit_plans(RD, Plans),
    count_plans_units(RD, Plans, Units).

ami_fraction(ami110,   1.10).
ami_fraction(ami100,   1.00).
ami_fraction(ami80,    0.80).
ami_fraction(low,      0.80).
ami_fraction(ami60,    0.60).
ami_fraction(lower,    0.60).
ami_fraction(ami50,    0.50).
ami_fraction(very_low, 0.50).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For-sale developments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% I don't know how to do the multiplication in the format string here to get a percentage.
#pred compliance_requires(Rule, RDType, IUType, IULocation, Income, Proportion) :: '@(Rule) requires a @(Proportion) proportion of units to be affordable to @(Income)'.

% On-site for-sale inclusionary units
compliance_requires("5.08.400.A.1", for_sale, for_sale, on_site, ami110, 0.15).

% Off-site for-sale inclusionary units
compliance_requires("5.08.400.A.1", for_sale, for_sale, off_site, ami110, 0.20).

% On-site for-rent inclusionary units
compliance_requires("5.08.500.A.i", for_sale, for_rent, on_site, ami100,   0.05).
compliance_requires("5.08.500.A.i", for_sale, for_rent, on_site, lower,    0.05).
compliance_requires("5.08.500.A.i", for_sale, for_rent, on_site, very_low, 0.05).

% Same but for extremely low income
compliance_requires("5.08.500.A.ii", for_sale, for_rent, on_site, extreme_low, 0.10).

% Clustered for-rent inclusionary units
compliance_requires("5.08.590.F.i", for_sale, for_rent, cluster, ami100,   0.05).
compliance_requires("5.08.590.F.i", for_sale, for_rent, cluster, lower,    0.05).
compliance_requires("5.08.590.F.i", for_sale, for_rent, cluster, very_low, 0.05).

% Same but for extremely low income
compliance_requires("5.08.590.F.ii", for_sale, for_rent, cluster, extreme_low, 0.10).

% Off-site for-rent inclusionary units
compliance_requires("5.08.510.A.2", for_sale, for_rent, off_site, ami80,    0.05).
compliance_requires("5.08.510.A.2", for_sale, for_rent, off_site, lower,    0.05).
compliance_requires("5.08.510.A.2", for_sale, for_rent, off_site, very_low, 0.10).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rental developments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% On-site for-rent inclusionary units
compliance_requires("5.08.400.A.2.i", for_rent, for_rent, on_site, ami100,   0.05).
compliance_requires("5.08.400.A.2.i", for_rent, for_rent, on_site, lower,    0.05).
compliance_requires("5.08.400.A.2.i", for_rent, for_rent, on_site, very_low, 0.05).

% Same but for extremely low income
compliance_requires("5.08.400.A.2.ii", for_rent, for_rent, on_site, extreme_low, 0.10).

% Clustered for-rent inclusionary units
compliance_requires("5.08.590.F.i", for_rent, for_rent, cluster, ami100,   0.05).
compliance_requires("5.08.590.F.i", for_rent, for_rent, cluster, lower,    0.05).
compliance_requires("5.08.590.F.i", for_rent, for_rent, cluster, very_low, 0.05).

% Same but for extremely low income
compliance_requires("5.08.590.F.ii", for_rent, for_rent, cluster, extreme_low, 0.10).

% Off-site for-rent inclusionary units
compliance_requires("5.08.510.B", for_rent, for_rent, off_site, ami80,    0.05).
compliance_requires("5.08.510.B", for_rent, for_rent, off_site, lower,    0.05).
compliance_requires("5.08.510.B", for_rent, for_rent, off_site, very_low, 0.10).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fees in lieu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Developments adding 10-19 units at 90% or higher of General Plan density get
% some breaks on in-lieu fees.
meets_density_threshold(RD) :-
    rd_unit_count(RD, Units),
    Units >= 10,
    Units =< 20,
    rd_general_plan_density(RD, Density),
    Density > 0.90.

in_lieu_fee_rate(RD, 0) :-
    complies(RD, _ComplianceOption).

in_lieu_fee_rate(RD, 25) :-
    rd_type(RD, for_sale).

in_lieu_fee_rate(RD, 5.04) :-
    rd_type(RD, for_rent),
    rd_iu_location(RD, on_site),
    rd_iu_share(RD, Income, Share),
    ami_fraction(Income, AmiFraction),
    AmiFraction =< 0.5,
    Share >= 0.05,
    meets_density_threshold(RD).

in_lieu_fee_rate(RD, 6.24) :-
    rd_type(RD, for_rent),
    rd_iu_location(RD, on_site),
    rd_iu_share(RD, Income, Share),
    ami_fraction(Income, AmiFraction),
    AmiFraction =< 0.6,
    Share >= 0.05,
    meets_density_threshold(RD).

in_lieu_fee_rate(RD, 9.35) :-
    rd_type(RD, for_rent),
    rd_iu_location(RD, on_site),
    rd_iu_share(RD, Income, Share),
    ami_fraction(Income, AmiFraction),
    AmiFraction =< 1,
    Share >= 0.05,
    meets_density_threshold(RD).

in_lieu_fee_rate(RD, 9.35) :-
    rd_type(RD, for_rent),
    rd_market_strength(RD, moderate_market),
    meets_density_threshold(RD).

in_lieu_fee_rate(RD, 10.07) :-
    rd_type(RD, for_rent),
    rd_iu_location(RD, on_site),
    rd_iu_share(RD, Income, Share),
    ami_fraction(Income, AmiFraction),
    AmiFraction =< 0.5,
    Share >= 0.05.

in_lieu_fee_rate(RD, 12.47) :-
    rd_type(RD, for_rent),
    rd_iu_location(RD, on_site),
    rd_iu_share(RD, Income, Share),
    ami_fraction(Income, AmiFraction),
    AmiFraction =< 0.6,
    Share >= 0.05.

in_lieu_fee_rate(RD, 18.70) :-
    rd_type(RD, for_rent),
    rd_iu_location(RD, on_site),
    rd_iu_share(RD, Income, Share),
    ami_fraction(Income, AmiFraction),
    AmiFraction =< 1,
    Share >= 0.05.

in_lieu_fee_rate(RD, 18.70) :-
    rd_type(RD, for_rent),
    rd_market_strength(RD, moderate_market).

in_lieu_fee_rate(RD, 21.50) :-
    rd_type(RD, for_rent),
    meets_density_threshold(RD).

in_lieu_fee_rate(RD, 43) :-
    rd_type(RD, for_rent).

in_lieu_fee(RD, Fee) :-
    in_lieu_fee_rate(RD, Rate),
    rd_total_area(RD, Sqft),
    Fee is Sqft * Rate.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compliance checking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#pred applies(RD, ComplianceOption) :: '@(ComplianceOption) applies to @(RD)'.
applies(RD, ComplianceOption) :-
    rd_type(RD, RDType),
    rd_iu_type(RD, IUType),
    rd_iu_location(RD, IULocation),
    % ComplianceOption has some requirement pertaining to this development/IU scheme
    compliance_requires(ComplianceOption, RDType, IUType, IULocation, _IncomeLevel, _Proportion).

#pred requirement_missed(RD, ComplianceOption) :: '@(RD) does not comply with @(ComplianceOption)'.
requirement_missed(RD, ComplianceOption) :-
    rd_type(RD, RDType),
    rd_iu_type(RD, IUType),
    rd_iu_location(RD, IULocation),
    compliance_requires(ComplianceOption, RDType, IUType, IULocation, Income, ReqProportion),
    rd_iu_share(RD, Income, RDProportion),
    RDProportion < ReqProportion.

#pred requirements_met(RD, ComplianceOption) :: '@(RD) meets all the requirements of @(ComplianceOption)'.
requirements_met(RD, ComplianceOption) :-
    not requirement_missed(RD, ComplianceOption).

#pred complies(RD, ComplianceOption) :: '@(RD) complies with @(ComplianceOption)'.
complies(RD, ComplianceOption) :-
    applies(RD, ComplianceOption),
    requirements_met(RD, ComplianceOption).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rd_type(rd400, for_rent).
rd_iu_type(rd400, for_rent).
rd_iu_location(rd400, on_site).
rd_iu_share(rd400, ami110, 0).
rd_iu_share(rd400, ami100, 0).
rd_iu_share(rd400, ami80, 0).
rd_iu_share(rd400, ami60, 0).
rd_iu_share(rd400, ami50, 0).
rd_iu_share(rd400, lower, 0).
rd_iu_share(rd400, very_low, 0).
rd_iu_share(rd400, extreme_low, 0).
rd_unit_plans(rd400, [one_bdrm, two_bdrm]).
rd_plan_count(rd400, one_bdrm, 6).
rd_plan_count(rd400, two_bdrm, 10).
unit_plan_area(one_bdrm, 800).
unit_plan_area(two_bdrm, 1200).
