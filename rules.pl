:- use_module(library(scasp)).
:- set_prolog_flag(scasp_unknown, fail).
:- style_check(-singleton).
:- style_check(-discontiguous).

% I don't know how to do the multiplication in the format string here to get a percentage.
#pred compliance_requires(Rule, RDType, IUType, IULocation, Income, Proportion) :: '@(Rule) requires a @(Proportion) proportion of units to be affordable to @(Income)'.
#pred rd_type(RD, Type) :: '@(RD) is of type @(Type)'.
#pred rd_iu_type(RD, IUType) :: '@(RD)\'s inclusionary units are of type @(IUType)'.
#pred rd_iu_location(RD, IULocation) :: '@(RD)\'s inclusionary units are located at @(IULocation)'.
#pred rd_iu_share(RD, Income, Proportion) :: 'A @(Proportion) proportion of @(RD)\'s units are affordable to @(Income)'.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For-sale developments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% On-site for-sale inclusionary units
compliance_requires("5.08.400.A.1", for_sale, for_sale, on_site, ami110, 0.15).

% Off-site for-sale inclusionary units
compliance_requires("5.08.400.A.1", for_sale, for_sale, off_site, ami110,  0.20).

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
% Compliance checking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#pred applies(RD, ComplianceOption) :: '@(ComplianceOption) applies to @(RD)'.
applies(RD, ComplianceOption) :-
    rd_type(RD, RDType),
    rd_iu_type(RD, IUType),
    rd_iu_location(RD, IULocation),
    % ComplianceOption has some requirement pertaining to this development/IU scheme
    compliance_requires(ComplianceOption, RDType, IUType, IULocation, _IncomeLevel, _Proportion).

requirement_missed(RD, IncomeLevel, ReqProportion) :-
    rd_iu_share(RD, IncomeLevel, RDProportion),
    RDProportion < ReqProportion.

#pred compliance_missed(RD, ComplianceOption) :: '@(RD) does not comply with @(ComplianceOption)'.
compliance_missed(RD, ComplianceOption) :-
    rd_type(RD, RDType),
    rd_iu_type(RD, IUType),
    rd_iu_location(RD, IULocation),
    compliance_requires(ComplianceOption, RDType, IUType, IULocation, Income, Proportion),
    requirement_missed(RD, Income, Proportion).

#pred complies(RD, ComplianceOption) :: '@(RD) complies with @(ComplianceOption)'.
complies(RD, ComplianceOption) :-
    applies(RD, ComplianceOption),
    not compliance_missed(RD, ComplianceOption).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rd_type(rd400, for_sale).
rd_iu_type(rd400, for_sale).
rd_iu_location(rd400, on_site).
rd_iu_share(rd400, ami110, 0.15).
