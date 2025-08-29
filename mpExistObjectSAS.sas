/*========================================================================================================*/
/* AUTHOR : jbchav                                                                                        */
/*========================================================================================================*/
/* Type of supported objects : TABLE,COLUMN,VIEW,CATALOG,FILEREF,LIBREF,MACROV,MACROF,FILE,FOLDER         */
/*========================================================================================================*/
/* OPTIONS :                                                                                              */
/* - verbose                                                                                              */ 
/*   = NOINFO (default): Just return result without printing any information if no errors                 */
/*   = NOWARN          : Return result and print only informations (no warnings) if no errors             */
/*   = INFO            : Return all informations and warnings                                             */
/*   Note that if something is wrong, informations about the issue will be mandatorily printed            */
/*========================================================================================================*/
/* CALL EXAMPLES :                                                                                        */
/*                                                                                                        */
/* [TABLE]   %put %mpExistObjectSAS(objectType=TABLE, objectName=sashelp.class);                          */
/* [COLUMN]  %put %mpExistObjectSAS(objectType=COLUMN, objectName=sashelp.class.age);                     */
/* [VIEW]    %put %mpExistObjectSAS(objectType=VIEW, objectName=sashelp.class);                           */
/* [CATALOG] %put %mpExistObjectSAS(objectType=CATALOG, objectName=myLib.myCatalog);                      */
/* [FUNC]    %put %mpExistObjectSAS(objectType=FUNC, objectName=compress);                                */
/* [FILEREF] %put %mpExistObjectSAS(objectType=FILEREF, objectName=fileref1);                             */
/* [LIBREF]  %put %mpExistObjectSAS(objectType=LIBREF, objectName=sashelp);                               */
/* [MACROV]  %put %mpExistObjectSAS(objectType=MACROV, objectName=sysdate9);                              */
/* [FILE]    %put %mpExistObjectSAS(objectType=FILE, objectName=/appl/sas/calmar2_v9/source/calmar1.sas); */
/* [FOLDER]  %put %mpExistObjectSAS(objectType=FOLDER, objectName=/appl/sas/calmar2_v9/source);           */
/*========================================================================================================*/

%macro mpExistObjectSAS(objectType=, objectName=, verbose=NOINFO) / MINOPERATOR; 

	/* Initialization*/
	%if "&objectType." ne "" %then %let objectType=%upcase(%sysfunc(COMPRESS(&objectType)));
	%if "&objectName." ne "" %then %let objectName=%sysfunc(COMPRESS(&objectName));
	%let verbose=%upcase(%sysfunc(COMPRESS(&verbose)));

	/* Check */
	%if "&objectName." eq "" %then %do;
		%put INFO:[mpExistObjectSAS] No object <objectName> was requested for detection;
		0
	%end;
	%else %do;
		%if "&objectType." eq "" %then %do;
			%put INFO:[mpExistObjectSAS] No object type <objectType> was requested for detection;
			0
		%end;
		%else %do;
			/* not(&objectType. in TABLE COLUMN VIEW CATALOG FUNC FILEREF LIBREF MACROV FILE FOLDER) */
			%if "&objectType." ne "TABLE" and "&objectType." ne "COLUMN" and "&objectType." ne "VIEW"
				and "&objectType." ne "CATALOG" and "&objectType." ne "FUNC" and "&objectType." ne "FILEREF"
				and "&objectType." ne "LIBREF" and "&objectType." ne "MACROV" and "&objectType." ne "FILE"
				and "&objectType." ne "FOLDER"
				%then %do;
				%put INFO:[mpExistObjectSAS] The object type <&objectType> is not valid !;
				%put INFO:[mpExistObjectSAS] Expected values : TABLE COLUMN VIEW CATALOG FUNC FILEREF LIBREF MACROV FILE FOLDER !;
				0
			%end;
		%end;
	%end;

	/* Test for SAS table exist */
	%if "&objectType." = "TABLE" and "&objectName." ne "" %then %do;
		%if %sysfunc(EXIST(&objectName)) %then %do; 
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then 
				%put %str(WARN)ING:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

	/* Test for SAS column exist */
	%if "&objectType." = "COLUMN" and "&objectName." ne "" %then %do;

		%local dsid rc level1 level2 level3;
		%let level3 = %upcase(%scan(&objectName,-1,.));
		%let level2 = %upcase(%scan(&objectName,-2,.));
		%let level1 = %upcase(%scan(&objectName,-3,.));
		%if %nrbquote(&level1) = %then %do; 
			%let level1 = work; %let objectName=work.&objectName;
		%end;

		%if %sysfunc(EXIST(&level1..&level2)) %then %do;
			%let dsid=%sysfunc(OPEN(&level1..&level2));
			%let result=%sysfunc(VARNUM(&dsid,&level3));
			%if &result > 0 %then %do; 
				1
				%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
					%put INFO:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> exists. (Column No &result);
			%end;
			%else %do; 
				0
				%if "&verbose." ne "NOWARN" %then
					%put %str(WARN)ING:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> does not exist !!!;
			%end;
			%let rc = %sysfunc(DCLOSE(&dsid));
		%end;
		%else %do;
			0
			%put %str(WARN)ING:[mpExistObjectSAS] The SAS table <&level1..&level2> does not exist !!!;
		%end;
	%end;

	/* Test for SAS view exist */
	%if "&objectType." = "VIEW" and "&objectName." ne "" %then %do;
		%if %sysfunc(EXIST(&objectName,"VIEW")) %then %do; 
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then
				%put %str(WARN)ING:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

	/* Test for SAS catalog exist */
	%if "&objectType." = "CATALOG" and "&objectName." ne "" %then %do;
		%if %sysfunc(CEXIST(&objectName)) %then %do; 
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then
				%put %str(WARN)ING:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

	/* Test for SAS function exist */
	%if "&objectType." = "FUNC" and "&objectName." ne "" %then %do;
		%local dsid rc exist;
		%let dsid=%sysfunc(open(sashelp.vfunc(where=(fncname="%upcase(&objectName)"))));
		%let exist=1;
		%let exist=%sysfunc(fetch(&dsid, NOSET));
		%let rc=%sysfunc(close(&dsid));
		%if %sysevalf(0 = &exist) %then %do;
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then
				%put %str(WARN)ING:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

	/* Test for fileref exist */
	%if "&objectType." = "FILEREF" and "&objectName." ne "" %then %do;
		%if %sysfunc(FEXIST(&objectName)) %then %do; 
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then
				%put %str(WARN)ING:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

	/* Test for libref exist */
	%if "&objectType." = "LIBREF" and "&objectName." ne "" %then %do;
		%if %sysfunc(LIBREF(&objectName)) = 0 %then %do; 
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then
				%put %str(WARN)ING:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

	/* Test for macro-variable exist */
	%if "&objectType." = "MACROV" and "&objectName." ne "" %then %do;
		%if %sysfunc(SYMEXIST(&objectName)) %then %do;
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then
				%put %str(WARN)ING:[mpExistObjectSAS] The SAS object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

	/* Test for file exist */
	%if "&objectType." = "FILE" and "&objectName." ne "" %then %do;
		%if %sysfunc(FILEEXIST(&objectName)) %then %do; 
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then
				%put %str(WARN)ING:[mpExistObjectSAS] The object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

	/* Test for folder exist */
	%if "&objectType." = "FOLDER" and "&objectName." ne "" %then %do;
		%if %sysfunc(FILEEXIST(&objectName)) %then %do; 
			1
			%if "&verbose." ne "NOINFO" and "&verbose." ne "NOWARN" %then
				%put INFO:[mpExistObjectSAS] The object <&objectName> type <&objectType> exists.;
		%end;
		%else %do; 
			0
			%if "&verbose." ne "NOWARN" %then
				%put %str(WARN)ING:[mpExistObjectSAS] The object <&objectName> type <&objectType> does not exist !!!;
		%end;
	%end;

%mend mpExistObjectSAS;
