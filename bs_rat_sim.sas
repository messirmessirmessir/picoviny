proc sql; 
create table VS_all as select 
		&date. format datetime. as datum,
		institutszuordnung,
		kundennummer, 
		kundennummer_KK, 
		kontonummer,
		kundenname,
		kundenname_KK,
		basel2_segment,
		dat_letzt_antr_scor,
		dat_kontoeroeffnung,
		produktgruppe,
		produktgruppe_KK,
		produktcode,
		produktcode_KK, 
		kartennummer,
		kontostatus,
		risikoklasse_antr_kto,
		eroeffnungsdatum,
		dat_antragsscoring,
		risikoklasse_antrag,
		score_antrag,
		risikoklasse_Kunde,
		Risikoklasse_verh_VM,
		dat_verhaltensscoring,
		kundenname1 as BR_TOOL, 
		ukv_bankleitzahl,
		risikoklasse1/*entsch_risikoklasse*/ as BR_Rating,
		r7040_score as Score_VS,
		r7040_score_index,
		produktcode,
		produktgruppe,
		anz_tage_haben,
		anz_tage_uebzieh_l6m,
		lim_proz_ds_saldo_l3M,
		ums_haben_bereinigt,
		rueckstand,
		/*KONTO KMU*/
		MON_EROEFF,			
		LIM_PROZ_DS_SALDO_L6M,
		ANZ_TAGE_UEBZIEH_L6M,
		ANZ_TAGE_HABEN,	
		ANZ_TAGE_SOLL_L6M,
		/*KONTO SONSTIGE*/
		LIM_PROZ_DS_SALDO_L3M, 
		ANZ_TAGE_UEBZIEH_MON  ,
		ANZ_TAGE_SOLL_L6M     ,
		MAX_MAHNSTUFE_L6M     ,
		DS_BUCHWERT ,
		/*VKredit Generisch*/
		MAX_MAHNSTUFE_L6M,    
		ANZ_MAHNUNG_1_L12M  , 
		ANZ_RATEN_GESTUND ,   
		MAHNSTUFE	,		 
		PRODUKTCODE		,	 
		LIM_PROZ_DS_SALDO_L6M,
		RUECKSTAND,
		/*KK*/
		ANZ_UMS_WAREN_L6M,
		DS_LS_SALDO_L3M,
		MON_EROEFF,
		LIMITAUSLASTUNG_L6M,
		RISIKOKLASSE_MAHN_VM,
		ANZ_BARBEHEB_MON,
		ANZ_RISKUMS,
		ukv_bankleitzahl,	
		ANZ_BARBEHEB_L6M,
		ANZ_TAGE_UEBZIEH_KK_L6M,
		ANZ_SPERR_BONITAET_L24M,
		LIMITAUSLASTUNG_L6M,
		ANZ_MAHNUNG_1_L3M,
		ANZ_MAHNUNG_2_L12M,
		ANZ_MAHNUNG_EROEFF,
		ANZ_TAGE_SOLL,
		ANZ_TAGE_UEBZIEH_L12M,
		ANZ_TAGE_UEBZIEH_L9M,
		DS_BUCHWERT_L3M,
		MAX_MAHNSTUFE_L9M,
		MAX_RUECKSTAND_EROEFF,
		MAX_RUECKSTAND_L12M,
		MAX_RUECKSTAND_L6M,
		MINSALDO_RAHMEN,
		SALDO
	from dwhp.ldr_sco_verh
	where datum=&date_bs. 
	and kundenname1 not in ('VDummy','VMahn')
/*	and ( (not missing(produktcode)) or (produktcode_kk not in ('BW','PW')) )*/
/*	and ( (not missing(produktcode_kk)) or (produktcode not in ('B597')) )*/
	and institutszuordnung in (&institut_list.)
	and risikoklasse1>0
	and mon_eroeff>=6
;
quit;

proc sql; 
	create table KreditKarte as select 
		&date. format datetime. as datum,
		a.institutszuordnung ,
		a.kundennummer_KK,
		b.basel2_segment as basel2_segment_KK,
		b.kontonummer as Kontonummer_KK

	from dwhp.ldr_sco_verh  a left join 
    	 dwhp.ldr_kde_kto_basis b
			on   (
				a.datum=b.datum and
				a.institutszuordnung=b.institutszuordnung and
				a.kundennummer_KK=b.kundennummer and
				a.kartennummer=b.konto_subnummer
					)
	where a.datum=&date_bs
	and a.kundennummer_kk>0
	and a.institutszuordnung in (&institut_list.)
;

quit;

data VS;
	set VS_all; 

if Br_TOOL in ('VKonto KMU_generisch_032015','VKonto KMU_generisch','VKonto KMU_generisch_neu','VKonto KMU_generisch_neu1','VKonto KMU_generisch_20140206','VKonto KMU_generisch_072017')  then BR_TOOL_Group="KMU";
				else if Br_TOOL in ('VKonto_PSK_GE_032015', 'VKonto_PSK_GE_neu_20140206','VKonto_PSK_GE_neu','VKonto_PSK_GE','VKonto_PSK_GE_072017')then BR_TOOL_Group="Konto";
				else if Br_TOOL in ('VKonto_PSK_Sonst_Neu_032015', 'VKonto_PSK_Sonst_Neu','VKonto_PSK_Sonst','VKonto_PSK_Sonst_Neu1','VKonto_PSK_Sonst_Neu1_20140206','VKonto_PSK_Sonst_Neu_072017') then BR_TOOL_Group="Konto";
				else if Br_TOOL in ('VKredit_generisch_Neu_032015', 'VKredit_generisch_Neu_20140206','VKredit_generisch_Neu','VKredit_generisch','VKredit_generisch_Neu_072017')  then BR_TOOL_Group="Kredit";/*missing score*/
				else if Br_TOOL in ('VKreditkarte_neu_20140206','Vkreditkarte_neu_20151005','VKreditkarte','VKreditkarte_neu') then BR_TOOL_Group="KK";/*missing score*/

		if Br_TOOL in  ('VKreditkarte_neu_20140206','Vkreditkarte_neu_20151005','VKreditkarte','VKreditkarte_neu') then do; /*('VKreditkarte_neu_20140206','Vkreditkarte_neu_20151005','VKreditkarte','VKreditkarte_neu')*/
			Kundennummer=Kundennummer_KK;
			dat_kontoeroeffnung=eroeffnungsdatum;
		
		end;
	key=trim(Institutszuordnung)||trim(kundennummer);
run;

PROC SQL;
drop table VS_all;
QUIT;


proc sql;
		create table VS2 as
		select a.*, b.basel2_segment_KK,b.Kontonummer_KK 
		from    VS 	 a
			    left join KreditKarte b
			on  
				(a.datum=b.datum and
				a.institutszuordnung=b.institutszuordnung and
				a.kundennummer=b.kundennummer_KK 
				)
;

quit; 

PROC SQL;
drop table VS;
drop table KreditKarte;
QUIT;


data VS2;
	set VS2;
	if Kontonummer="" then Kontonummer=Kontonummer_KK;
run;


proc sort data=VS2;
by institutszuordnung kundennummer descending basel2_segment;
run; 

data VS2;
	set VS2;
	y=lag(basel2_segment);
	if basel2_segment=''  and kundennummer_KK ne . then basel2_Segment2=basel2_Segment_KK;
	else if key = lag(key) and basel2_segment='' then basel2_Segment2=y;
	
	else basel2_Segment2=basel2_segment;
run; 

data VS2;
	set VS2;
	drop basel2_segment;
run; 

data VS2;
	set VS2;
basel2_segment=basel2_segment2;
drop basel2_segment2;
drop basel2_Segment_KK;
run; 

data VS2;
set VS2;
where basel2_segment in (&basel2_list.);
run;

%macro BR_Score_calculation(data_in, data_out);
data &data_out;
	set &data_in; 
	Basel2_Segment=Basel2_Segment;
	Produktcode=Produktcode;
		
	
/*KONTO GEHALT*/

	T_RUECKSTAND=log(-RUECKSTAND+1);
	format T_RUECKSTAND 19.2;
	T_ANZ_TAGE_UEBZIEH_L9M=log(ANZ_TAGE_UEBZIEH_L9M+1);
	format T_ANZ_TAGE_UEBZIEH_L9M 19.2;
	T_SALDO=exp((9000-max(SALDO,-100))/2000);
	format T_SALDO 19.2;
	T_PRODUKTCODE_K5=0;
	IF PRODUKTCODE in ('B557') then T_PRODUKTCODE_K5=1;
	T_PRODUKTCODE_K4=0;
	IF PRODUKTCODE in ('B112','B115','B510','B553') then T_PRODUKTCODE_K4=1;
	Q_DT_T_RUECKSTAND=min(max(T_RUECKSTAND,0),11.6729002659157);
	Q_DT_T_ANZ_TAGE_UEBZIEH_L9M=min(max(T_ANZ_TAGE_UEBZIEH_L9M,0),5.62401750618734);
	Q_DT_T_SALDO=min(max(T_SALDO,0),94.632408314924);
	Q_DT_ANZ_MAHNUNG_2_L12M=min(max(ANZ_MAHNUNG_2_L12M,0),1);
	Q_DT_ANZ_MAHNUNG_1_L12M=min(max(ANZ_MAHNUNG_1_L12M,0),1);
	Q_DT_MON_EROEFF=min(max(MON_EROEFF,0),444);
	Q_DT_T_PRODUKTCODE_K5=min(max(T_PRODUKTCODE_K5,0),1);
	Q_DT_T_PRODUKTCODE_K4=min(max(T_PRODUKTCODE_K4,0),1);
	
	Teilscore_KONSTANTE=582.5300;
	Teilscore_RUECKSTAND=Q_DT_T_RUECKSTAND*(-25.5687);
	Teilscore_ANZ_TAGE_UEBZIEH_L9M=Q_DT_T_ANZ_TAGE_UEBZIEH_L9M*(-26.8724);
	Teilscore_SALDO=Q_DT_T_SALDO*(-2.6173);
	Teilscore_ANZ_MAHNUNG_2_L12M=Q_DT_ANZ_MAHNUNG_2_L12M*(-83.3143);
	Teilscore_ANZ_MAHNUNG_1_L12M=Q_DT_ANZ_MAHNUNG_1_L12M*(-58.9321);
	Teilscore_MON_EROEFF=Q_DT_MON_EROEFF*(0.1791);
	Teilscore_PRODUKTCODE=Q_DT_T_PRODUKTCODE_K5*(-94.3414)+Q_DT_T_PRODUKTCODE_K4*(-23.5053);
	Score_ex=Teilscore_KONSTANTE
		+Teilscore_RUECKSTAND
		+Teilscore_ANZ_TAGE_UEBZIEH_L9M
		+Teilscore_SALDO
		+Teilscore_ANZ_MAHNUNG_2_L12M
		+Teilscore_ANZ_MAHNUNG_1_L12M
		+Teilscore_MON_EROEFF
		+Teilscore_PRODUKTCODE
		;

Score_kon_GE=round(Score_ex,1);
		
/*KONTO KMU*/

	T_ANZ_TAGE_UEBZIEH_L6M=log(ANZ_TAGE_UEBZIEH_L6M+1);
	T_SALDO=exp((7000-max(SALDO,0))/1000);
	T_MAX_RUECKSTAND_L6M=abs(MAX_RUECKSTAND_L6M);
	Q_DT_T_ANZ_TAGE_UEBZIEH=T_ANZ_TAGE_UEBZIEH_L6M;
	Q_DT_T_SALDO=min(max(T_SALDO,-1591.703892),2653.951841);
	Q_DT_T_MAX_RUECKSTAND_L6M=min(max(T_MAX_RUECKSTAND_L6M,0),1);
	Q_DT_MON_EROEFF=MON_EROEFF;
	Q_DT_ANZ_MAHNUNG_1_L3M=ANZ_MAHNUNG_1_L3M;
	
	Teilscore_KONSTANTE=399.0500;
	Teilscore_ANZ_TAGE_UEBZIEH=Q_DT_T_ANZ_TAGE_UEBZIEH*(-48.84);
	Teilscore_SALDO=Q_DT_T_SALDO*(-0.117);
	Teilscore_MAX_RUECKSTAND_L6M=Q_DT_T_MAX_RUECKSTAND_L6M*(-70);
	Teilscore_MON_EROEFF=Q_DT_MON_EROEFF*(0.452);
	Teilscore_ANZ_MAHNUNG_1_L3M=Q_DT_ANZ_MAHNUNG_1_L3M*(-44);
	Score_ex=Teilscore_KONSTANTE
		+Teilscore_ANZ_TAGE_UEBZIEH
		+Teilscore_SALDO
		+Teilscore_MAX_RUECKSTAND_L6M
		+Teilscore_MON_EROEFF
		+Teilscore_ANZ_MAHNUNG_1_L3M
		;

Score_KMU=round(Score_ex,1);
		
/*KONTO SONSTIGE NEU*/

	T_ANZ_TAGE_UEBZIEH_L12M=log(ANZ_TAGE_UEBZIEH_L12M+1);
	T_DS_BUCHWERT_L3M=exp((10000-max(DS_BUCHWERT_L3M,-100))/1000);
	T_MAX_RUECKSTAND_L12M=abs(MAX_RUECKSTAND_L12M);
	if Produktcode in ('B600','B610','B620') then PC_GM4='ANGESTELLTE';
		else if Produktcode in ('B800') then PC_GM4='FW_KREDIT';
		else if Produktcode in ('B211','B216','B220','B221','B200','B201','B209','B210','B212',
								 'B213','B214','B215'/*,'B217'*/,'B601','B230', 'B231','B232','B233','B234'
								 'B240', 'B241','B242') then PC_GM4='PENSION';
		else if Produktcode in ('B300','B310','B350','B360','B400','B410','B420','B450','B460','B470', /*new*/'B320', 'B370') then PC_GM4='STUD_LEHR';
		else if Produktcode in ('B583','B584','B594','B694','B580','B586','B590','B592','B593','B596',
								 'B680','B683','B684','B686','B690','B696', /*new*/'B665','B780','B783','B786','B787', 'B791', 'B792','B794', 'B798','B799') then PC_GM4='TEILZAHLUNG';
		else if Produktcode in (/*new*/'C100','C101','C105','C150') then PC_GM4='Wertpapier';
		else PC_GM4='REST';
	T_PC_C1=0;
	T_PC_C2=0;
	T_PC_C3=0;
	T_PC_C5=0;
	T_PC_C6=0;
	T_PC_C7=0;
	IF PC_GM4='STUD_LEHR' then T_PC_C1=1;
	IF PC_GM4='ANGESTELLTE' then T_PC_C2=1;
	IF PC_GM4='TEILZAHLUNG' then T_PC_C3=1;
	IF PC_GM4='FW_KREDIT' then T_PC_C5=1;
	IF PC_GM4='REST' then T_PC_C6=1;
	IF PC_GM4='PENSION' then T_PC_C7=1;
	Q_DT_ANZ_TAGE_SOLL=min(max(ANZ_TAGE_SOLL,0),31);
	Q_DT_T_ANZ_TAGE_UEBZIEH_L12M=min(max(T_ANZ_TAGE_UEBZIEH_L12M,0),5.905361848);
	Q_DT_T_DS_BUCHWERT_L3M=min(max(T_DS_BUCHWERT_L3M,-25195.250535),22037.48178);
	Q_DT_ANZ_MAHNUNG_EROEFF=min(max(ANZ_MAHNUNG_EROEFF,0),52);
	Q_DT_MAHNSTUFE=min(max(MAHNSTUFE,0),1);
	Q_DT_T_MAX_RUECKSTAND_L12M=min(max(T_MAX_RUECKSTAND_L12M,0),1);
	Q_DT_T_PC_C1=T_PC_C1;
	Q_DT_T_PC_C2=T_PC_C2;
	Q_DT_T_PC_C3=T_PC_C3;
	Q_DT_T_PC_C5=T_PC_C5;
	Q_DT_T_PC_C6=T_PC_C6;
	Q_DT_T_PC_C7=T_PC_C7;
	
	Teilscore_KONSTANTE=610.3000;
	Teilscore_ANZ_TAGE_SOLL=Q_DT_ANZ_TAGE_SOLL*(-0.816);
	Teilscore_ANZ_TAGE_UEBZIEH_L12M=Q_DT_T_ANZ_TAGE_UEBZIEH_L12M*(-19.74);
	Teilscore_DS_BUCHWERT_L3M=Q_DT_T_DS_BUCHWERT_L3M*(-0.008);
	Teilscore_ANZ_MAHNUNG_EROEFF=Q_DT_ANZ_MAHNUNG_EROEFF*(-7.75);
	Teilscore_MAHNSTUFE=Q_DT_MAHNSTUFE*(-94);
	Teilscore_MAX_RUECKSTAND_L12M=Q_DT_T_MAX_RUECKSTAND_L12M*(-52.77);
	Teilscore_PRODUKTCODE=Q_DT_T_PC_C1*(138.33)+Q_DT_T_PC_C2*(108.97)+Q_DT_T_PC_C3*(32.12)+Q_DT_T_PC_C5*(-72.94)+Q_DT_T_PC_C6*(-77.92)+Q_DT_T_PC_C7*(-124.36);
	Score_ex=Teilscore_KONSTANTE
		+Teilscore_ANZ_TAGE_SOLL
		+Teilscore_ANZ_TAGE_UEBZIEH_L12M
		+Teilscore_DS_BUCHWERT_L3M
		+Teilscore_ANZ_MAHNUNG_EROEFF
		+Teilscore_MAHNSTUFE
		+Teilscore_MAX_RUECKSTAND_L12M
		+Teilscore_PRODUKTCODE
		;

Score_KON_SON=round(Score_ex,1);

/*VKredit Generisch*/

	T_PRODUKTCODE4='KMU';
	if PRODUKTCODE in ('S100','S101','S110','S112','S115','S116','S119','S120',
        'S121','S122','S123','S130','S131','S132','S150','S220','S350','S400',
        'S420') then T_PRODUKTCODE4='STANDARD';
    if PRODUKTCODE in ('U100','U101','U110','U120','U150','U200','U240','U250',
        'U700') then T_PRODUKTCODE4='WmH';
    if PRODUKTCODE in ('S200','S210','S250','S500','S700','U350','U400','U410',
        'U411') then T_PRODUKTCODE4='WoH';
	T_PC4_WmH=0;
	T_PC4_WoH=0;
	IF T_PRODUKTCODE4='WmH' then T_PC4_WmH=1;
	IF T_PRODUKTCODE4='WoH' then T_PC4_WoH=1;
	Q_DT_MAX_MAHNSTUFE_L9M=min(max(MAX_MAHNSTUFE_L9M,0),4);
	Q_DT_MAX_RUECKSTAND_EROEFF=min(max(MAX_RUECKSTAND_EROEFF,-618.6),0);
	Q_DT_ANZ_RATEN_GESTUND=min(max(ANZ_RATEN_GESTUND,0),5);
	Q_DT_MINSALDO_RAHMEN=min(max(MINSALDO_RAHMEN,100),102.5);
	Q_DT_RUECKSTAND=min(max(RUECKSTAND,-816.27),0);
	Q_DT_T_PC4_WmH=min(max(T_PC4_WmH,0),1);
	Q_DT_T_PC4_WoH=min(max(T_PC4_WoH,0),1);
	
	Teilscore_KONSTANTE=1398.0153;
	Teilscore_MAX_MAHNSTUFE_L9M=Q_DT_MAX_MAHNSTUFE_L9M*(-101.6191);
	Teilscore_MAX_RUECKSTAND_EROEFF=Q_DT_MAX_RUECKSTAND_EROEFF*(0.2156);
	Teilscore_ANZ_RATEN_GESTUND=Q_DT_ANZ_RATEN_GESTUND*(-29.8048);
	Teilscore_MINSALDO_RAHMEN=Q_DT_MINSALDO_RAHMEN*(-10.1842);
	Teilscore_RUECKSTAND=Q_DT_RUECKSTAND*(0.2455);
	Teilscore_PRODUKTCODE=Q_DT_T_PC4_WmH*(114.7936)+Q_DT_T_PC4_WoH*(102.4692);
	Score_ex=Teilscore_KONSTANTE
		+Teilscore_MAX_MAHNSTUFE_L9M
		+Teilscore_MAX_RUECKSTAND_EROEFF
		+Teilscore_ANZ_RATEN_GESTUND
		+Teilscore_MINSALDO_RAHMEN
		+Teilscore_RUECKSTAND
		+Teilscore_PRODUKTCODE
		;

Score_KRE_GEN=round(Score_ex,1);

/*KK*/
if ANZ_BARBEHEB_L6M=0   then ANZ_BARBEHEB_L6M_GR=196;
else if ANZ_BARBEHEB_L6M > 0  				then ANZ_BARBEHEB_L6M_GR=-1012; /*ok*/


if ANZ_TAGE_UEBZIEH_KK_L6M = 0 then ANZ_TAGE_UEBZIEH_KK_L6M_GR = 22;
else if ANZ_TAGE_UEBZIEH_KK_L6M > 0 then ANZ_TAGE_UEBZIEH_KK_L6M_GR =-456; /*ok*/

if LIMITAUSLASTUNG_L6M >= 0 AND LIMITAUSLASTUNG_L6M <= 6 then LIMITAUSLASTUNG_L6M_GR=187;
else if LIMITAUSLASTUNG_L6M >= 7 and LIMITAUSLASTUNG_L6M<=20 then LIMITAUSLASTUNG_L6M_GR=16;
else if LIMITAUSLASTUNG_L6M >= 21 then LIMITAUSLASTUNG_L6M_GR=-444; /*ok*/

if ANZ_SPERR_BONITAET_L24M = 0 then ANZ_SPERR_BONITAET_L24M_GR = 493; /*ok*/
else if ANZ_SPERR_BONITAET_L24M > 0 then ANZ_SPERR_BONITAET_L24M_GR = -1989;

	 if  MON_EROEFF<=10 							then MON_EROEFF2_GR=-394; 
else if MON_EROEFF>=11 and MON_EROEFF<= 58    		then MON_EROEFF2_GR=-20;
else if MON_EROEFF>=59 and MON_EROEFF<= 113    		then MON_EROEFF2_GR=86;
else if MON_EROEFF>=114 					   		then MON_EROEFF2_GR=264;


Intercept_KK=4916;
SCORE_KK= Intercept_KK+MON_EROEFF2_GR+ANZ_SPERR_BONITAET_L24M_GR+LIMITAUSLASTUNG_L6M_GR+ANZ_TAGE_UEBZIEH_KK_L6M_GR+ANZ_BARBEHEB_L6M_GR;

%mend;


%BR_Score_calculation(VS2,VS_SIM);

PROC SQL;
drop table VS2;
QUIT;

/********/
data VS_SIM;
	set VS_SIM;
			 if Br_TOOL in ('VKonto KMU_generisch_032015','VKonto KMU_generisch','VKonto KMU_generisch_neu','VKonto KMU_generisch_neu1','VKonto KMU_generisch_20140206','VKonto KMU_generisch_072017')  then Score_SIM=Score_KMU;
		else if Br_TOOL in ('VKonto_PSK_GE_032015', 'VKonto_PSK_GE_neu_20140206','VKonto_PSK_GE_neu','VKonto_PSK_GE','VKonto_PSK_GE_072017') then Score_SIM=Score_kon_GE;
		else if Br_TOOL in ('VKonto_PSK_Sonst_Neu_032015', 'VKonto_PSK_Sonst_Neu','VKonto_PSK_Sonst','VKonto_PSK_Sonst_Neu1','VKonto_PSK_Sonst_Neu1_20140206','VKonto_PSK_Sonst_Neu_072017')  then Score_SIM=Score_KON_SON;
		else if Br_TOOL in ('VKredit_generisch_Neu_032015', 'VKredit_generisch_Neu_20140206','VKredit_generisch_Neu','VKredit_generisch','VKredit_generisch_Neu_072017')  then Score_SIM=Score_KRE_GEN;
		else if Br_TOOL in ('VKreditkarte_neu_20140206','Vkreditkarte_neu_20151005','VKreditkarte','VKreditkarte_neu')    then Score_SIM=Score_KK;   

run; 



data VS_SIM;
	set  VS_SIM;

array   rk[15] (3.1,3.2,3.3,4.1,4.2,4.3,5.1,5.2,5.3,5.4,6.1,6.2,6.3,6.4,7.0);
 
if Br_TOOL in ('VKonto_PSK_GE_032015', 'VKonto_PSK_GE_neu_20140206','VKonto_PSK_GE_neu','VKonto_PSK_GE','VKonto_PSK_GE_072017') then do;
	array lowKonGE[15] (600,579,547,482,424,382,334,279,228,186,148,104,62,26,-99999);
	array highKONGE[15](99999,599,578,546,481,423,381,333,278,227,185,147,103,61,25);
  	do i=1 to 15;
	  	if Score_SIM>=lowKonGE[i] and Score_SIM<=highKONGE[i] then RK_HF_SIM2=rk[i];
	end;	
end;
else if Br_TOOL in ('VKonto KMU_generisch_032015','VKonto KMU_generisch','VKonto KMU_generisch_neu','VKonto KMU_generisch_neu1','VKonto KMU_generisch_20140206','VKonto KMU_generisch_072017') then do;
	array lowKMU[15] (596,577,547,487,433,395,350,300,252,213,178,138,99,66,-99999);
	array highKMU[15](99999,595,576,546,486,432,394,349,299,251,212,177,137,98,65);
	do i=1 to 15;
	  	if Score_SIM>=lowKMU[i] and Score_SIM<=highKMU[i] then RK_HF_SIM2=rk[i];
	end;
end; 
else if Br_TOOL in ('VKonto_PSK_Sonst_Neu_032015', 'VKonto_PSK_Sonst_Neu','VKonto_PSK_Sonst','VKonto_PSK_Sonst_Neu1','VKonto_PSK_Sonst_Neu1_20140206','VKonto_PSK_Sonst_Neu_072017') then do;
	array lowKonSon[15] (639,617,583,514,453,408,357,300,245,201,161,115,70,32,-99999);
	array highKonSon[15](99999,638,616,582,513,452,407,356,299,244,200,160,114,69,31);
	do i=1 to 15;
	  	if Score_SIM>=lowKonSon[i] and Score_SIM<=highKonSon[i] then RK_HF_SIM2=rk[i];
	end;
end; 
else if Br_TOOL in ('VKredit_generisch_Neu_032015', 'VKredit_generisch_Neu_20140206','VKredit_generisch_Neu','VKredit_generisch','VKredit_generisch_Neu_072017')  then do;
	array lowKREgen[15] (636,617,588,530,478,441,398,349,303,265,232,193,155,123,-99999);
	array highKREgen[15](99999,635,616,587,529,477,440,397,348,302,264,231,192,154,122);
	do i=1 to 15;
	  	if Score_SIM>=lowKREgen[i] and Score_SIM<=highKREgen[i] then RK_HF_SIM2=rk[i];
	end;
end; 
else if Br_TOOL in ('VKreditkarte_neu_20140206','Vkreditkarte_neu_20151005','VKreditkarte','VKreditkarte_neu') then do;
	array lowKK[15] (5702,5538,5285,4775,4316,3989,3608,3182,2773,2445,2149,1806,1476,1191,-99999);
	array highKK[15](99999,5701,5537,5284,4774,4315,3988,3607,3181,2772,2444,2148,1805,1475,1190);
	do i=1 to 15;
	  	if Score_SIM>=lowKK[i] and Score_SIM<=highKK[i] then RK_HF_SIM2=rk[i];
	end;
end; 

if BR_RATING=0.00 or BR_RATING>=8.00 then RK_HF_SIM=BR_RATING;
else if Br_TOOL in ('VMahn') then RK_HF_SIM=BR_RATING;
else if Br_TOOL in ('VKreditkarte_neu_20140206','Vkreditkarte_neu_20151005','VKreditkarte','VKreditkarte_neu') and round(BR_RATING,0.1) ^= round(r7040_score_index/10,0.1) 
									   then RK_HF_SIM=BR_RATING;  
else if Br_TOOL not in ('VKreditkarte_neu_20140206','Vkreditkarte_neu_20151005','VKreditkarte','VKreditkarte_neu') and  ukv_bankleitzahl^=.
									   then RK_HF_SIM=BR_RATING;

else RK_HF_SIM=RK_HF_SIM2;
RK_HF_SIM=round(RK_HF_SIM,0.01);
if BASEL2_SEGMENT="040170" and RK_HF_SIM=3.10 then RK_HF_SIM=3.20;
		if BASEL2_SEGMENT="040170" then do;
				 if RK_HF_SIM=3.20 then mid_RK_HF_SIM=0.0009;
			else if RK_HF_SIM=3.30 then mid_RK_HF_SIM=0.001343;
			else if RK_HF_SIM=4.10 then mid_RK_HF_SIM=0.00229; 
			else if RK_HF_SIM=4.20 then mid_RK_HF_SIM=0.004076;
			else if RK_HF_SIM=4.30 then mid_RK_HF_SIM=0.006358;
			else if RK_HF_SIM=5.10 then mid_RK_HF_SIM=0.009912;
			else if RK_HF_SIM=5.20 then mid_RK_HF_SIM=0.016339;
			else if RK_HF_SIM=5.30 then mid_RK_HF_SIM=0.026812;
			else if RK_HF_SIM=5.40 then mid_RK_HF_SIM=0.040652;
			else if RK_HF_SIM=6.10 then mid_RK_HF_SIM=0.058043;
			else if RK_HF_SIM=6.20 then mid_RK_HF_SIM=0.084333;
			else if RK_HF_SIM=6.30 then mid_RK_HF_SIM=0.122015;
			else if RK_HF_SIM=6.40 then mid_RK_HF_SIM=0.166749;
			else if RK_HF_SIM=7.00 or RK_HF_SIM= 0.00    then mid_RK_HF_SIM=0.35;
			else if RK_HF_SIM>=8.00 then mid_RK_HF_SIM=1;
		end;

		else if BASEL2_SEGMENT="040270" then do;
			     if RK_HF_SIM=3.10 then mid_RK_HF_SIM=0.00085;
			else if RK_HF_SIM=3.20 then mid_RK_HF_SIM=0.00105;
			else if RK_HF_SIM=3.30 then mid_RK_HF_SIM=0.0014;
			else if RK_HF_SIM=4.10 then mid_RK_HF_SIM=0.002475; 
			else if RK_HF_SIM=4.20 then mid_RK_HF_SIM=0.004375;
			else if RK_HF_SIM=4.30 then mid_RK_HF_SIM=0.007;
			else if RK_HF_SIM=5.10 then mid_RK_HF_SIM=0.0115;
			else if RK_HF_SIM=5.20 then mid_RK_HF_SIM=0.0175;
			else if RK_HF_SIM=5.30 then mid_RK_HF_SIM=0.0275;
			else if RK_HF_SIM=5.40 then mid_RK_HF_SIM=0.045;
			else if RK_HF_SIM=6.10 then mid_RK_HF_SIM=0.0625;
			else if RK_HF_SIM=6.20 then mid_RK_HF_SIM=0.0925;
			else if RK_HF_SIM=6.30 then mid_RK_HF_SIM=0.13;
			else if RK_HF_SIM=6.40 then mid_RK_HF_SIM=0.18;
			else if RK_HF_SIM=7.00  or RK_HF_SIM= 0.00  then mid_RK_HF_SIM=0.3;

		end;


  drop  lowKonGE1   -lowKonGE15    highKONGE1   -highKONGE15
		lowKMU1     -lowKMU15      highKMU1     -highKMU15
		lowKONSON1  -lowKONSON15   highKONSON1  -highKONSON15
		lowKREgen1  -lowKREgen15   highKREgen1  -highKREgen15
		lowKK1      -lowKK15       highKK1      -highKK15
		rk1-rk15;
run; 

	/*Ende Simulation*/

proc sort data=VS_SIM out=VS_SIM;
	by Institutszuordnung kundennummer  BR_TOOL/*_Group*/ descending rk_hf_SIM   score_sim ;
run;

proc sort data=VS_SIM nodupkey out=VS_SIM;
	by Institutszuordnung kundennummer  BR_TOOL/*_Group*/   ;
run; 


proc sort data=VS_SIM out=VS_SIM;
	by Institutszuordnung kundennummer  BR_TOOL_Group descending rk_hf_SIM   score_sim ;
run;

proc sort data=VS_SIM nodupkey out=VS_SIM;
	by Institutszuordnung kundennummer  BR_TOOL_Group   ;
run; 


proc sort data=VS_SIM;
	by institutszuordnung kundennummer ;
run;

proc transpose data=  VS_SIM out=VS2_nodup_trans_sco;
	by institutszuordnung kundennummer ;
	id BR_TOOL_Group;
	var score_sim  ;
run; 
proc transpose data=  VS_SIM out=VS2_nodup_trans_RAT;
	by institutszuordnung kundennummer;
	id BR_TOOL_Group;
	var  rk_hf_SIM  ;
run; 

data VS2_nodup_trans_RAT;
	set VS2_nodup_trans_RAT;
	KRE_RAT=KRE;
	KMU_RAT=KMU;
	KON_RAT=KON;
	KK_RAT=KK;
	keep institutszuordnung  kundennummer /*kontonummer BR_TOOL_Group*/ 
	     KRE_RAT KMU_RAT KON_RAT KK_RAT;

run;

proc sort data=VS2_nodup_trans_RAT;
	by institutszuordnung kundennummer ;
run;
proc sort data=VS2_nodup_trans_SCO;
	by institutszuordnung kundennummer ;
run;

data VS2_nodup_trans_merge;
	merge VS_SIM 	    	(in=a)
		  VS2_nodup_trans_RAT  (in=b)
		  VS2_nodup_trans_sco   (in=c)
;
	if a;
by institutszuordnung kundennummer  ;
drop _name_ _label_;
run; 

PROC SQL;
drop table VS_SIM;
drop table VS2_nodup_trans_RAT;
drop table VS2_nodup_trans_sco;
QUIT;


%macro rk_to_pd(var,mid_var);

if BASEL2_SEGMENT="040170" then do;
			if &var=0 then &mid_var=-1;
			else if &var=3.20 then &mid_var=0.0009;
			else if &var=3.30 then &mid_var=0.001343;
			else if &var=4.10 then &mid_var=0.00229; 
			else if &var=4.20 then &mid_var=0.004076;
			else if &var=4.30 then &mid_var=0.006358;
			else if &var=5.10 then &mid_var=0.009912;
			else if &var=5.20 then &mid_var=0.016339;
			else if &var=5.30 then &mid_var=0.026812;
			else if &var=5.40 then &mid_var=0.040652;
			else if &var=6.10 then &mid_var=0.058043;
			else if &var=6.20 then &mid_var=0.084333;
			else if &var=6.30 then &mid_var=0.122015;
			else if &var=6.40 then &mid_var=0.166749;
			else if &var=7.00 /*or &var= 0.00 */   then &mid_var=0.35;
			else if &var>=8.00 then &mid_var=1;
		end;

		else if BASEL2_SEGMENT in ("040270" "040271") then do;
			     if &var=0 then &mid_var=-1;	
			else if &var=3.10 then &mid_var=0.00085;
			else if &var=3.20 then &mid_var=0.00105;
			else if &var=3.30 then &mid_var=0.0014;
			else if &var=4.10 then &mid_var=0.002475; 
			else if &var=4.20 then &mid_var=0.004375;
			else if &var=4.30 then &mid_var=0.007;
			else if &var=5.10 then &mid_var=0.0115;
			else if &var=5.20 then &mid_var=0.0175;
			else if &var=5.30 then &mid_var=0.0275;
			else if &var=5.40 then &mid_var=0.045;
			else if &var=6.10 then &mid_var=0.0625;
			else if &var=6.20 then &mid_var=0.0925;
			else if &var=6.30 then &mid_var=0.13;
			else if &var=6.40 then &mid_var=0.18;
			else if &var=7.00  /*or &var= 0.00*/  then &mid_var=0.3;
			else if &var>=8.00 then &mid_var=1;
		
end;
%mend;

data VS2_nodup_trans_merge;
	set VS2_nodup_trans_merge;
/*where kundennummer=6;*/
	KRE_RK=round(KRE_RAT,0.01);
	KON_RK=round(KON_RAT,0.01);
	KK_RK =round(KK_RAT,0.01);
	KMU_RK=round(KMU_RAT,0.01);


	%rk_to_pd(KRE_RK,KRE_pd);
	%rk_to_pd(KON_RK,KON_pd);
	%rk_to_pd(KK_RK,KK_pd);
	%rk_to_pd(KMU_RK,KMU_pd);

run;

/*leasing, how many 040271?*/
data VS2_nodup_trans_merge;
	set VS2_nodup_trans_merge;
	 if Basel2_Segment="040170" then do;
		 if KMU_pd not in (. -1) and 	KON_pd  in     (. -1) and KK_pd     in (. -1) and  KRE_pd not in (. -1) then do;  Model=1;Score_Gr=KMU_pd ;RK_Gr=KMU_pd ;  end;
	else if KMU_pd     in (. -1) and    KON_pd  not in (. -1) and KK_pd     in (. -1) and  KRE_pd not in (. -1) then do;  Model=2;Score_Gr=KON_pd ;RK_Gr=KON_pd ;  end;
	else if KMU_pd not in (. -1) and 	KON_pd  not in (. -1) and KK_pd     in (. -1) and  KRE_pd     in (. -1) then do;  Model=3;Score_Gr=KON_pd ;RK_Gr=KON_pd ;  end;
	else if KMU_pd not in (. -1) and 	KON_pd  not in (. -1) and KK_pd     in (. -1) and  KRE_pd not in (. -1) then do;  Model=4;Score_Gr=KON_pd ;RK_Gr=KON_pd ;  end;
	else if KMU_pd     in (. -1) and 	KON_pd  in     (. -1) and KK_pd not in (. -1) and  KRE_pd not in (. -1) then do;  Model=5;Score_Gr=KRE_pd ;RK_Gr=KRE_pd ;  end;

	else if KMU_pd not in (. -1) and 	KON_pd      in (. -1) and KK_pd not in (. -1) and  KRE_pd in (. -1) then do;  Model=6;Score_Gr=KMU_pd ;RK_Gr=KMU_pd ;  end;
	else if KMU_pd not in (. -1) and 	KON_pd      in (. -1) and KK_pd not in (. -1) and  KRE_pd not in (. -1) then do;  Model=7;Score_Gr=KMU_pd ;RK_Gr=KMU_pd ;  end;
	else if KMU_pd     in (. -1) and 	KON_pd  not in (. -1) and KK_pd not in (. -1) and  KRE_pd in (. -1) then do;  Model=8;Score_Gr=KON_pd ;RK_Gr=KON_pd ;  end;
	else if KMU_pd     in (. -1) and 	KON_pd  not in (. -1) and KK_pd not in (. -1) and  KRE_pd not in (. -1) then do;  Model=9;Score_Gr=KON_pd ;RK_Gr=KON_pd ;  end;
	else if KMU_pd not in (. -1) and 	KON_pd  not in (. -1) and KK_pd not in (. -1) and  KRE_pd in (. -1) then do;  Model=10;Score_Gr=KON_pd ;RK_Gr=KON_pd ;  end;

	else if KMU_pd not in (. -1) and 	KON_pd  not in (. -1) and KK_pd not in (. -1) and  KRE_pd not in (. -1) then do; Model=11;Score_Gr=KON_pd ;RK_Gr=KON_pd ;  end;
	else if KMU_pd not in (. -1) and 	KON_pd  	in (. -1) and KK_pd 	in (. -1) and  KRE_pd in (. -1) then do; Model=12;Score_Gr=KMU_pd ;RK_Gr=KMU_pd ;  end;
	else if KMU_pd 	   in (. -1) and 	KON_pd  not in (. -1) and KK_pd 	in (. -1) and  KRE_pd in (. -1) then do; Model=13;Score_Gr=KON_pd ;RK_Gr=KON_pd ;  end;
	else if KMU_pd 	   in (. -1) and 	KON_pd  	in (. -1) and KK_pd not in (. -1) and  KRE_pd in (. -1) then do; Model=14;Score_Gr=KK_pd  ;RK_Gr=KK_pd  ;  end;
	else if KMU_pd     in (. -1) and 	KON_pd  	in (. -1) and KK_pd 	in (. -1) and  KRE_pd not in (. -1) then do; Model=15;Score_Gr=KRE_pd ;RK_Gr=KRE_pd ;  end;
		end;

	else if Basel2_Segment in ("040270" "040271") then do;/*Score probably not necessary*/
		 if KMU_pd not in (. -1) and 	KON_pd  	in (. -1) 	and KK_pd 	  in (. -1) and  KRE_pd not in (. -1) then do;Model=1;Score_Gr= 0.3 * KMU_pd + 0.7 * KRE_pd;                 RK_Gr= 0.3 * KMU_pd + 0.7 * KRE_pd;           end;
	else if KMU_pd 	   in (. -1) and 	KON_pd  not in (. -1)   and KK_pd     in (. -1) and  KRE_pd not in (. -1) then do;Model=2;Score_Gr= 0.6 * KON_pd  + 0.4 * KRE_pd;				RK_Gr= 0.6 * KON_pd  + 0.4 * KRE_pd;		  end;
	else if KMU_pd not in (. -1) and 	KON_pd  not in (. -1)   and KK_pd 	  in (. -1) and  KRE_pd  in (. -1) then do;Model=3;Score_Gr= 0.7 * KON_pd  + 0.3 * KMU_pd;				RK_Gr= 0.7 * KON_pd  + 0.3 * KMU_pd;		  end;
	else if KMU_pd not in (. -1) and 	KON_pd  not in (. -1)   and KK_pd 	  in (. -1) and  KRE_pd not in (. -1) then do;Model=4;Score_Gr= 0.3 * KON_pd  + 0.3 * KMU_pd + 0.4 * KRE_pd;    RK_Gr= 0.3 * KON_pd  + 0.3 * KMU_pd + 0.4 * KRE_pd;  end;
	else if KMU_pd 	   in (. -1) and 	KON_pd  	in (. -1) 	and KK_pd not in (. -1) and  KRE_pd not in (. -1) then do;Model=5;Score_Gr= KRE_pd;									RK_Gr= KRE_pd;								  end;

	else if KMU_pd not in (. -1) and 	KON_pd      in (. -1)	and KK_pd not in (. -1) and  KRE_pd in (. -1) then do;Model=6;Score_Gr= KMU_pd;									RK_Gr= KMU_pd;								  end;
	else if KMU_pd not in (. -1) and 	KON_pd      in (. -1) 	and KK_pd not in (. -1) and  KRE_pd not in (. -1) then do;Model=7;Score_Gr= 0.3 * KMU_pd + 0.7 * KRE_pd;					RK_Gr= 0.3 * KMU_pd + 0.7 * KRE_pd;			  end;
	else if KMU_pd 	   in (. -1) and 	KON_pd  not in (. -1)   and KK_pd not in (. -1) and  KRE_pd in (. -1) then do;Model=8;Score_Gr= KON_pd ; 									RK_Gr= KON_pd ; 							  end;
	else if KMU_pd     in (. -1) and 	KON_pd  not in (. -1)   and KK_pd not in (. -1) and  KRE_pd not in (. -1) then do;Model=9;Score_Gr= 0.6 * KON_pd  + 0.4 * KRE_pd;				RK_Gr= 0.6 * KON_pd  + 0.4 * KRE_pd;		  end;	
	else if KMU_pd not in (. -1) and 	KON_pd  not in (. -1)   and KK_pd not in (. -1) and  KRE_pd in (. -1) then do;Model=10;Score_Gr= 0.7 * KON_pd  + 0.3 * KMU_pd;				RK_Gr= 0.7 * KON_pd  + 0.3 * KMU_pd;		  end;

	else if KMU_pd not in (. -1) and 	KON_pd  not in (. -1)   and KK_pd not in (. -1) and  KRE_pd not in (. -1) then do;Model=11;Score_Gr= 0.3 * KON_pd  + 0.3 * KMU_pd + 0.4 * KRE_pd;	RK_Gr= 0.3 * KON_pd  + 0.3 * KMU_pd + 0.4 * KRE_pd;  end;
	else if KMU_pd not in (. -1) and 	KON_pd  	in (. -1)   and KK_pd 	  in (. -1) and  KRE_pd in (. -1) then do;Model=12;Score_Gr= KMU_pd;									RK_Gr= KMU_pd;								  end;
	else if KMU_pd 	   in (. -1) and 	KON_pd  not in (. -1)   and KK_pd 	  in (. -1) and  KRE_pd in (. -1) then do;Model=13;Score_Gr= KON_pd;									RK_Gr= KON_pd;								  end;
	else if KMU_pd     in (. -1) and 	KON_pd  	in (. -1)   and KK_pd not in (. -1) and  KRE_pd in (. -1) then do;Model=14;Score_Gr= KK_pd ;									RK_Gr= KK_pd ;								  end;
	else if KMU_pd     in (. -1) and 	KON_pd  	in (. -1)   and KK_pd 	  in (. -1) and  KRE_pd not in (. -1) then do;Model=15;Score_Gr= KRE_pd;									RK_Gr= KRE_pd;								  end;
		end;
			 if RK_Gr=.             then RK_After='7.0';
			 else if RK_Gr < 0.0009 then RK_After= '3.1';
			 else if RK_Gr < 0.0011 then RK_After= '3.2';
			 else if RK_Gr < 0.0015 then RK_After= '3.3';
			 else if RK_Gr < 0.0028 then RK_After= '4.1';
			 else if RK_Gr < 0.0049 then RK_After= '4.2';
			 else if RK_Gr < 0.0073 then RK_After= '4.3';
			 else if RK_Gr < 0.0116 then RK_After= '5.1';
			 else if RK_Gr < 0.0194 then RK_After= '5.2';
			 else if RK_Gr < 0.0316 then RK_After= '5.3';
			 else if RK_Gr < 0.0465 then RK_After= '5.4';
			 else if RK_Gr < 0.0655 then RK_After= '6.1';
			 else if RK_Gr < 0.0965 then RK_After= '6.2';
			 else if RK_Gr < 0.1385 then RK_After= '6.3';
			 else if RK_Gr < 0.185  then RK_After= '6.4';
			 else if RK_Gr >= 0.185 and RK_Gr<1 then RK_After= '7.0';
			 else if RK_GR=1 then RK_After='8.0';
run; 


/*VMahn*/
proc sql; 
create table VS_mahn as select 
		&date. format datetime. as datum,
		institutszuordnung,
		kundennummer, 
		kundennummer_KK, 
		kontonummer, 
		risikoklasse1 as rk_mahn
	from dwhp.ldr_sco_verh
	where datum= &date_bs and kundenname1 in ('VMahn')
	and institutszuordnung in (&institut_list.)
;
quit; 

proc sql;
create table VS2_nodup_trans_merge_3 as
select a.*, b.rk_mahn from VS2_nodup_trans_merge a left join VS_mahn b
on (a.institutszuordnung = b.institutszuordnung
and a.kundennummer= b.kundennummer);
run;

PROC SQL;
drop table VS2_nodup_trans_merge;
drop table VS_mahn;
QUIT;

data VS2_nodup_trans_merge_3;
set VS2_nodup_trans_merge_3;
if rk_mahn ne . then RK_after = rk_mahn;
drop rk_mahn;
run; 

data Rating_Table_VS;
set Rating_Table_Behaviour;
run;

proc sort data= Rating_Table_VS;
by institutszuordnung kundennummer;
run; 
proc sort data=VS2_nodup_trans_merge_3 nodupkey out =  VS2_nodup_trans_merge_3;
by institutszuordnung kundennummer;
run; 

PROC SQL;
create table simulation_RK_VS as
select a.*,
b.RK_after
from Rating_Table_VS a
left join VS2_nodup_trans_merge_3 b
on a.institutszuordnung=b.institutszuordnung
and a.kundennummer=b.kundennummer
;
QUIT;

data simulation_RK_VS;
set simulation_RK_VS;
format bs_rating_datum datetime20.;
RK_end=input(RK_After,8.);
is_simulated=0;
if not missing(RK_end) then is_simulated=1;
if missing(RK_end) then RK_end=input(RK_final,8.);
bs_rating_ldr=RK_final;
bs_rating_datum=RATINGDATUM;
keep institutszuordnung kundennummer basel2_segment RK_end bs_rating_datum bs_rating_ldr is_simulated;
run;
 
data SIMRWA.BSOLD;
set simulation_RK_VS;
where bs_rating_datum>=&date_as.;
run;

PROC SQL;
drop table Comparison;
drop table VS2_nodup_trans_merge_3;
drop table Rating_Table_VS;
drop table simulation_RK_VS;
QUIT;
