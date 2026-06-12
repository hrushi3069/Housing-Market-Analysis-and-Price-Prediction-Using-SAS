/* ============================================================
   PROGRAM: Housing Price Analysis
   PURPOSE: Import, clean, explore, and model house price data
            using regression techniques in SAS
   ============================================================ */


/* ------------------------------------------------------------
   SECTION 1: ENVIRONMENT SETUP
   ------------------------------------------------------------ */

/* Define a library (shortcut) called MM711 pointing to your
   working folder. SAS uses this alias to read/write datasets. */
libname MM711 "/home/u64455556/MM711/hpd18 MYDATA";

/* Suppress date/time and page numbers from output */
options nodate nonumber;

/* ODS LISTING: directs any traditional (listing) graphics output
   (e.g. PNG files) to this folder on disk */
ods listing gpath="/home/u64455556/MM711/hpd18 MYDATA";

/* ODS HTML: opens an HTML output file called fixed_report_outputs.html
   using the HTMLBlue style (a clean, blue-themed template).
   All subsequent PROC output will render into this file. */
ods html path="/home/u64455556/MM711/hpd18 MYDATA"
         file="fixed_report_outputs.html"
         style=HTMLBlue;


/* ------------------------------------------------------------
   SECTION 2: DATA IMPORT
   ------------------------------------------------------------ */

/* Import the house price Excel file into a temporary SAS dataset
   called HOUSE_PRICE.
   - DBMS=XLSX tells SAS to use the Excel engine
   - REPLACE overwrites the dataset if it already exists
   - GETNAMES=YES uses the first row as variable names         */
proc import datafile="/home/u64455556/MM711/hpd18 MYDATA/Houseprice.xlsx"
            out=house_price
            dbms=xlsx
            replace;
    getnames=yes;
run;

/* Import the property characteristics Excel file into a temporary
   SAS dataset called CHARACTERISTICS using the same method.    */
proc import datafile="/home/u64455556/MM711/hpd18 MYDATA/Characteristics.xlsx"
            out=characteristics
            dbms=xlsx
            replace;
    getnames=yes;
run;


/* ------------------------------------------------------------
   SECTION 3: APPLY VARIABLE LABELS
   ------------------------------------------------------------ */

/* Add descriptive labels to the CHARACTERISTICS dataset.
   Labels appear in output tables and plots instead of raw
   variable names, making results easier to read.              */
data characteristics;
    set characteristics;
    label
        Reference       = "House Reference Number"
        LivingArea_sm   = "Living Area (Square Metres)"
        Garage_sm       = "Garage Area (Square Metres)"
        Garage_Type     = "Garage Type"
        Bedroom         = "Number of Bedrooms"
        Bathroom        = "Number of Bathrooms";
run;

/* Add labels and a numeric format to the HOUSE_PRICE dataset.
   FORMAT SoldPrice 12.2 displays sale price with 2 decimal places
   in a field of up to 12 characters wide.                     */
data house_price;
    set house_price;
    format SoldPrice 12.2;
    label
        Reference        = "House Reference Number"
        ConstructionYear = "Construction Year"
        YearSold         = "Year Sold"
        SoldPrice        = "Sale Price";
run;


/* ------------------------------------------------------------
   SECTION 4: SORT BOTH DATASETS BEFORE MERGING
   ------------------------------------------------------------ */

/* Both datasets must be sorted by the common key variable
   (Reference) before a DATA step merge can be performed.      */
proc sort data=house_price;     by Reference; run;
proc sort data=characteristics; by Reference; run;


/* ------------------------------------------------------------
   SECTION 5: MERGE DATASETS
   ------------------------------------------------------------ */

/* Perform an inner join (match-merge) on Reference.
   - IN=A and IN=B create flag variables showing which dataset
     each observation came from.
   - The IF A AND B condition keeps only records present in BOTH
     datasets (i.e. matched observations only).
   Result: HOUSING_RAW contains all variables from both files
   for properties that appear in both.                         */
data housing_raw;
    merge house_price(in=a) characteristics(in=b);
    by Reference;
    if a and b;  /* Keep only matched records */
run;


/* ------------------------------------------------------------
   SECTION 6: DATA CLEANING AND FEATURE ENGINEERING
   ------------------------------------------------------------ */

data housing_clean;
    set housing_raw;

    /* Declare variable lengths upfront to avoid truncation     */
    length GarageType_Clean $20
           Garage_Status    $15;

    /* --- Derived Variable: House Age ---
       Calculate how old the property was at the time of sale.  */
    HouseAge = YearSold - ConstructionYear;

    /* --- Clean Garage Type Variable ---
       Handle missing, "NA", and valid entries consistently.
       UPCASE/STRIP normalises values before comparison.        */
    if missing(Garage_Type) then
        GarageType_Clean = "Unknown";
    else if upcase(strip(Garage_Type)) = "NA" and Garage_sm = 0 then
        GarageType_Clean = "No garage / NA";
    else
        GarageType_Clean = strip(Garage_Type);

    /* --- Binary Garage Indicator ---
       Simple label showing whether a garage is present or not. */
    if Garage_sm > 0 then Garage_Status = "Garage";
    else                  Garage_Status = "No garage";

    /* --- Remove Invalid / Incomplete Records ---
       Delete rows where critical analysis variables are missing
       or logically impossible (e.g. negative age or area).    */
    if missing(SoldPrice) or
       missing(YearSold)  or
       missing(ConstructionYear) then delete;  /* Must have price & year */
    if LivingArea_sm <= 0         then delete;  /* Must have positive area */
    if Garage_sm < 0              then delete;  /* Garage area cannot be negative */
    if HouseAge < 0               then delete;  /* Cannot be sold before built */
run;


/* ------------------------------------------------------------
   SECTION 7: EXPLORATORY FREQUENCY TABLES
   ------------------------------------------------------------ */

/* Produce frequency counts for categorical variables.
   MISSING option includes any observations with missing values
   in the counts so they are not silently excluded.            */
proc freq data=housing_clean;
    tables Bedroom Bathroom GarageType_Clean / missing;
run;


/* ------------------------------------------------------------
   SECTION 8: DESCRIPTIVE STATISTICS
   ------------------------------------------------------------ */

/* Compute summary statistics for all key numeric variables.
   MAXDEC=2 limits decimal places in output to 2.             */
proc means data=housing_clean mean median std min max maxdec=2;
    var SoldPrice LivingArea_sm Garage_sm Bedroom Bathroom
        ConstructionYear YearSold HouseAge;
run;


/* ------------------------------------------------------------
   SECTION 9: BUILD HISTOGRAM BIN DATA
   ------------------------------------------------------------ */

/* Create a binned version of SoldPrice for a custom histogram.
   BinWidth=10,000 means each bar spans a £10,000 price range.
   FLOOR() rounds down to the nearest bin boundary.
   CATS() and PUT() format the bin label (e.g. "200,000-210,000"). */
data hist;
    set housing_clean;
    BinWidth = 10000;
    BinLow   = floor(SoldPrice / BinWidth) * BinWidth;
    BinHigh  = BinLow + BinWidth;
    BinMid   = BinLow + (BinWidth / 2);  /* Midpoint for plotting position */
    PriceRange = cats(put(BinLow, comma12.), "-", put(BinHigh, comma12.));
run;

/* Count how many properties fall into each bin.
   NWAY ensures one output row per unique combination of
   BinMid and PriceRange. _FREQ_ holds the count per bin.     */
proc summary data=hist nway;
    class BinMid PriceRange;
    output out=hist_counts(drop=_type_);
run;


/* ------------------------------------------------------------
   SECTION 10: SCATTER PLOTS WITH REGRESSION LINES
   ------------------------------------------------------------ */

/* Plot SoldPrice vs LivingArea with a linear regression overlay.
   REG statement adds a fitted line + confidence band.         */
proc sgplot data=housing_clean;
    scatter x=LivingArea_sm y=SoldPrice;
    reg     x=LivingArea_sm y=SoldPrice;
run;

/* Plot SoldPrice vs Garage Area */
proc sgplot data=housing_clean;
    scatter x=Garage_sm y=SoldPrice;
    reg     x=Garage_sm y=SoldPrice;
run;

/* Plot SoldPrice vs House Age */
proc sgplot data=housing_clean;
    scatter x=HouseAge y=SoldPrice;
    reg     x=HouseAge y=SoldPrice;
run;


/* ------------------------------------------------------------
   SECTION 11: BOX PLOTS BY CATEGORICAL VARIABLES
   ------------------------------------------------------------ */

/* Box plots show the distribution of SoldPrice within each
   category. Useful for spotting group-level price differences. */

/* SoldPrice by number of Bathrooms */
proc sgplot data=housing_clean;
    vbox SoldPrice / category=Bathroom;
run;

/* SoldPrice by number of Bedrooms */
proc sgplot data=housing_clean;
    vbox SoldPrice / category=Bedroom;
run;

/* SoldPrice by Garage Type */
proc sgplot data=housing_clean;
    vbox SoldPrice / category=GarageType_Clean;
run;


/* ------------------------------------------------------------
   SECTION 12: CORRELATION ANALYSIS
   ------------------------------------------------------------ */

/* PROC CORR computes Pearson correlation coefficients between
   all listed variables. PLOTS=MATRIX(HISTOGRAM) produces a
   scatter plot matrix with histograms on the diagonal, giving
   a visual overview of all pairwise relationships.            */
proc corr data=housing_clean plots=matrix(histogram);
    var SoldPrice LivingArea_sm Garage_sm Bedroom
        Bathroom HouseAge YearSold;
run;


/* ------------------------------------------------------------
   SECTION 13: FULL MODEL - GLM WITH CATEGORICAL PREDICTOR
   ------------------------------------------------------------ */

/* PROC GLM fits a General Linear Model (ANOVA/regression).
   CLASS statement tells SAS that GarageType_Clean is categorical
   — it will be dummy-coded automatically.
   PLOTS=DIAGNOSTICS produces residual diagnostic plots.       */
proc glm data=housing_clean plots=diagnostics;
    class GarageType_Clean;
    model SoldPrice =
        LivingArea_sm
        Garage_sm
        GarageType_Clean   /* Categorical: creates indicator variables */
        Bedroom
        Bathroom
        HouseAge
        YearSold;
run;
quit;  /* QUIT closes the interactive GLM procedure */


/* ------------------------------------------------------------
   SECTION 14: MULTIPLE REGRESSION WITH MULTICOLLINEARITY CHECKS
   ------------------------------------------------------------ */

/* PROC REG is a standard OLS multiple regression procedure.
   VIF (Variance Inflation Factor) and TOL (Tolerance) are
   requested to diagnose multicollinearity among predictors.
   VIF > 10 (or TOL < 0.1) suggests a problematic predictor.
   Note: categorical variables cannot be used in PROC REG —
   GarageType_Clean is intentionally excluded here.           */
proc reg data=housing_clean plots=diagnostics;
    model SoldPrice =
        LivingArea_sm
        Garage_sm
        Bedroom
        Bathroom
        HouseAge
        YearSold
        / vif tol;
run;
quit;


/* ------------------------------------------------------------
   SECTION 15: LOG TRANSFORMATION OF RESPONSE VARIABLE
   ------------------------------------------------------------ */

/* If residual plots suggest right-skew or heteroscedasticity,
   a log transformation of SoldPrice can stabilise variance.
   LOG() in SAS computes the natural logarithm (base e).      */
data housing_clean;
    set housing_clean;
    LogSoldPrice = log(SoldPrice);
run;


/* ------------------------------------------------------------
   SECTION 16: GLM ON LOG-TRANSFORMED PRICE (NUMERIC PREDICTORS)
   ------------------------------------------------------------ */

/* Refit the model using LogSoldPrice as the outcome.
   Note: GarageType_Clean is declared in CLASS but then omitted
   from the MODEL statement — this is likely an oversight in
   the original code. To include it, add GarageType_Clean to
   the MODEL statement.                                        */
proc glm data=housing_clean;
    class GarageType_Clean;
    model LogSoldPrice =
        LivingArea_sm Garage_sm Bedroom Bathroom HouseAge YearSold;
run;
quit;


/* ------------------------------------------------------------
   SECTION 17: FINAL GLM MODEL WITH DIAGNOSTIC OUTPUT DATASET
   ------------------------------------------------------------ */

/* Refit the full model on the original SoldPrice scale with
   GarageType_Clean included as a CLASS (categorical) variable.
   OUTPUT statement saves model diagnostics to a new dataset
   called DIAG for further inspection:
     P=Predicted         → fitted values (y-hat)
     R=Residual          → raw residuals (y - y-hat)
     STUDENT=Student_Residual → internally studentised residuals
     H=Leverage          → hat matrix diagonal (influence measure)
     COOKD=Cooks_D       → Cook's D (overall influence measure)  */
proc glm data=housing_clean;
    class GarageType_Clean;
    model SoldPrice =
        LivingArea_sm
        Garage_sm
        GarageType_Clean
        Bedroom
        Bathroom
        HouseAge
        YearSold;
    output out=diag
           p=Predicted
           r=Residual
           student=Student_Residual
           h=Leverage
           cookd=Cooks_D;
run;
quit;

/* ============================================================
   END OF PROGRAM
   ============================================================ */