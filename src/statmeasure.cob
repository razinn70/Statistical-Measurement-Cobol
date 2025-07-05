IDENTIFICATION DIVISION.
PROGRAM-ID. STATMEASURE.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT INPUT-FILE ASSIGN TO DYNAMIC WS-FILENAME
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD  INPUT-FILE.
01  INPUT-RECORD          PIC X(20).

WORKING-STORAGE SECTION.
01  WS-FILENAME           PIC X(100).
01  WS-INPUT-VALUE        PIC S9(6)V99.
01  WS-TEMP-RECORD        PIC X(20).
01  WS-EOF-FLAG           PIC 9 VALUE 0.
    88  END-OF-FILE       VALUE 1.

01  WS-COUNTERS.
    05  WS-DATA-COUNT     PIC 9(5) VALUE ZERO.
    05  WS-POS-COUNT      PIC 9(5) VALUE ZERO.
    05  WS-NON-ZERO-COUNT PIC 9(5) VALUE ZERO.

01  WS-STATS.
    05  WS-SUM            PIC S9(12)V9(6) VALUE ZERO.
    05  WS-MEAN           PIC S9(9)V9(6) VALUE ZERO.
    05  WS-SQUARED-SUM    PIC S9(18)V9(6) VALUE ZERO.
    05  WS-VARIANCE       PIC S9(9)V9(6) VALUE ZERO.
    05  WS-STD-DEV        PIC S9(9)V9(6) VALUE ZERO.
    05  WS-RMS            PIC S9(9)V9(6) VALUE ZERO.
    05  WS-LOG-SUM        PIC S9(12)V9(6) VALUE ZERO.
    05  WS-GEO-MEAN       PIC S9(9)V9(6) VALUE ZERO.
    05  WS-RECIPROCAL-SUM PIC S9(12)V9(12) VALUE ZERO.
    05  WS-HARM-MEAN      PIC S9(9)V9(6) VALUE ZERO.
    05  WS-CALC-TEMP      PIC S9(12)V9(6) VALUE ZERO.
    05  WS-VARIANCE-TEMP  PIC S9(12)V9(6) VALUE ZERO.

01  WS-ERROR-FLAGS.
    05  WS-GEO-MEAN-ERROR PIC 9 VALUE 0.
        88  GEO-MEAN-ERROR VALUE 1.
    05  WS-HARM-MEAN-ERROR PIC 9 VALUE 0.
        88  HARM-MEAN-ERROR VALUE 1.

*> Added for error tracking
01  WS-CONVERSION-ERROR   PIC 9 VALUE 0.
    88  CONVERSION-ERROR  VALUE 1.

01  WS-ADDITIONAL-STATS.
    05  WS-MIN-VALUE      PIC S9(6)V99 VALUE 999999.99.
    05  WS-MAX-VALUE      PIC S9(6)V99 VALUE -999999.99.
    05  WS-RANGE          PIC S9(6)V99 VALUE ZERO.
    05  WS-COEF-VAR       PIC 9(3)V99 VALUE ZERO.
    05  WS-MEDIAN         PIC S9(6)V99 VALUE ZERO.

*> For median calculation 
01  WS-DATA-ARRAY.
    05  WS-X              PIC S9(6)V99 OCCURS 1 TO 10000 TIMES
                          DEPENDING ON WS-DATA-COUNT.
01  WS-SORT-VARS.
    05  WS-I              PIC 9(5) VALUE ZERO.
    05  WS-J              PIC 9(5) VALUE ZERO.
    05  WS-SORT-TEMP      PIC S9(6)V99 VALUE ZERO.

*> Add debug variables
01  WS-DEBUG.
    05  WS-DEBUG-FLAG     PIC 9 VALUE 0.
        88  DEBUG-MODE    VALUE 1.

PROCEDURE DIVISION.
MAIN-LOGIC.
    PERFORM INITIALIZATION.
    PERFORM PROCESS-DATA.
    PERFORM CALCULATE-STATISTICS.
    PERFORM CALCULATE-ADDITIONAL-STATS.
    PERFORM DISPLAY-RESULTS.
    STOP RUN.

INITIALIZATION.
    DISPLAY "STATISTICAL MEASURES PROGRAM".
    DISPLAY "============================".
    DISPLAY "Enter the input file name: " WITH NO ADVANCING.
    ACCEPT WS-FILENAME.
    
    OPEN INPUT INPUT-FILE.
    IF RETURN-CODE NOT = 0
        DISPLAY "Error opening file: " WS-FILENAME
        STOP RUN
    END-IF.

PROCESS-DATA.
    PERFORM UNTIL END-OF-FILE
        READ INPUT-FILE INTO WS-TEMP-RECORD
            AT END
                SET END-OF-FILE TO TRUE
            NOT AT END
                MOVE WS-TEMP-RECORD TO INPUT-RECORD
                PERFORM PROCESS-RECORD
        END-READ
    END-PERFORM.
    CLOSE INPUT-FILE.

PROCESS-RECORD.
    *> Direct computation with error handling
    COMPUTE WS-INPUT-VALUE = FUNCTION NUMVAL(INPUT-RECORD)
    ON SIZE ERROR
        DISPLAY "Error converting value: " INPUT-RECORD
        SET CONVERSION-ERROR TO TRUE
        EXIT PARAGRAPH
    END-COMPUTE.
    
    ADD 1 TO WS-DATA-COUNT.
    ADD WS-INPUT-VALUE TO WS-SUM.
    
    COMPUTE WS-SQUARED-SUM = WS-SQUARED-SUM + 
            (WS-INPUT-VALUE * WS-INPUT-VALUE)
    ON SIZE ERROR
        DISPLAY "Overflow in squared sum calculation"
    END-COMPUTE.
    
    *> Validate before processing for geometric mean
    IF WS-INPUT-VALUE > 0
        ADD 1 TO WS-POS-COUNT
        COMPUTE WS-LOG-SUM = WS-LOG-SUM + 
                FUNCTION LOG(WS-INPUT-VALUE)
        ON SIZE ERROR
            DISPLAY "Error calculating logarithm for: " WS-INPUT-VALUE
        END-COMPUTE
    ELSE
        SET GEO-MEAN-ERROR TO TRUE
    END-IF.
    
    *> Validate before processing for harmonic mean
    IF WS-INPUT-VALUE NOT = 0
        ADD 1 TO WS-NON-ZERO-COUNT
        *> Fix reciprocal calculation for harmonic mean
        COMPUTE WS-CALC-TEMP = 1 / WS-INPUT-VALUE
        ON SIZE ERROR
            DISPLAY "Error calculating reciprocal for: " WS-INPUT-VALUE
            SET HARM-MEAN-ERROR TO TRUE
        NOT ON SIZE ERROR
            ADD WS-CALC-TEMP TO WS-RECIPROCAL-SUM
        END-COMPUTE
    ELSE
        SET HARM-MEAN-ERROR TO TRUE
    END-IF.

    *> Track min/max values
    IF WS-DATA-COUNT = 1
        MOVE WS-INPUT-VALUE TO WS-MIN-VALUE
        MOVE WS-INPUT-VALUE TO WS-MAX-VALUE
    ELSE
        IF WS-INPUT-VALUE < WS-MIN-VALUE
            MOVE WS-INPUT-VALUE TO WS-MIN-VALUE
        END-IF
        IF WS-INPUT-VALUE > WS-MAX-VALUE
            MOVE WS-INPUT-VALUE TO WS-MAX-VALUE
        END-IF
    END-IF
    
    *> Store in array for median calculation
    MOVE WS-INPUT-VALUE TO WS-X(WS-DATA-COUNT).

CALCULATE-STATISTICS.
    IF WS-DATA-COUNT > 0
        PERFORM CALCULATE-MEAN
        PERFORM CALCULATE-STD-DEV-SIMPLE
        PERFORM CALCULATE-RMS
        PERFORM CALCULATE-GEO-MEAN
        PERFORM CALCULATE-HARM-MEAN
    END-IF.

CALCULATE-MEAN.
    COMPUTE WS-MEAN = WS-SUM / WS-DATA-COUNT.

*> Simpler standard deviation calculation
CALCULATE-STD-DEV-SIMPLE.
    COMPUTE WS-VARIANCE = (WS-SQUARED-SUM / WS-DATA-COUNT) - 
                          (WS-MEAN * WS-MEAN).
    COMPUTE WS-STD-DEV = FUNCTION SQRT(WS-VARIANCE).

CALCULATE-RMS.
    COMPUTE WS-RMS = FUNCTION SQRT(WS-SQUARED-SUM / WS-DATA-COUNT).

CALCULATE-GEO-MEAN.
    IF GEO-MEAN-ERROR OR WS-POS-COUNT = 0
        MOVE 0 TO WS-GEO-MEAN
    ELSE
        COMPUTE WS-GEO-MEAN = FUNCTION EXP(WS-LOG-SUM / WS-POS-COUNT)
    END-IF.

CALCULATE-HARM-MEAN.
    *> Debug output to verify values
    IF DEBUG-MODE
        DISPLAY "DEBUG: NON-ZERO-COUNT = " WS-NON-ZERO-COUNT
        DISPLAY "DEBUG: RECIPROCAL-SUM = " WS-RECIPROCAL-SUM
    END-IF.
    
    IF HARM-MEAN-ERROR OR WS-NON-ZERO-COUNT = 0
        MOVE 0 TO WS-HARM-MEAN
    ELSE
        *> Ensure we avoid division by zero
        IF WS-RECIPROCAL-SUM = 0
            SET HARM-MEAN-ERROR TO TRUE
            MOVE 0 TO WS-HARM-MEAN
        ELSE
            COMPUTE WS-HARM-MEAN = WS-NON-ZERO-COUNT / WS-RECIPROCAL-SUM
            ON SIZE ERROR
                DISPLAY "Error calculating harmonic mean"
                SET HARM-MEAN-ERROR TO TRUE
                MOVE 0 TO WS-HARM-MEAN
            END-COMPUTE
        END-IF
    END-IF.

CALCULATE-ADDITIONAL-STATS.
    *> Calculate range
    COMPUTE WS-RANGE = WS-MAX-VALUE - WS-MIN-VALUE.
    
    *> Calculate coefficient of variation (if mean is not zero)
    IF WS-MEAN NOT = 0
        COMPUTE WS-COEF-VAR = (WS-STD-DEV / WS-MEAN) * 100
    END-IF.
    
    *> Calculate median
    PERFORM SORT-DATA-ARRAY.
    PERFORM CALCULATE-MEDIAN.

SORT-DATA-ARRAY.
    *> Simple bubble sort
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-DATA-COUNT - 1
        PERFORM VARYING WS-J FROM 1 BY 1 
                UNTIL WS-J > WS-DATA-COUNT - WS-I
            IF WS-X(WS-J) > WS-X(WS-J + 1)
                MOVE WS-X(WS-J) TO WS-SORT-TEMP
                MOVE WS-X(WS-J + 1) TO WS-X(WS-J)
                MOVE WS-SORT-TEMP TO WS-X(WS-J + 1)
            END-IF
        END-PERFORM
    END-PERFORM.

CALCULATE-MEDIAN.
    IF FUNCTION MOD(WS-DATA-COUNT, 2) = 1
        *> Odd number of elements
        COMPUTE WS-I = (WS-DATA-COUNT + 1) / 2
        MOVE WS-X(WS-I) TO WS-MEDIAN
    ELSE
        *> Even number of elements
        COMPUTE WS-I = WS-DATA-COUNT / 2
        COMPUTE WS-MEDIAN = (WS-X(WS-I) + WS-X(WS-I + 1)) / 2
    END-IF.

DISPLAY-RESULTS.
    DISPLAY " ".
    DISPLAY "STATISTICAL ANALYSIS RESULTS:".
    DISPLAY "============================".
    DISPLAY "Input file: " WS-FILENAME.
    DISPLAY "Number of values processed: " WS-DATA-COUNT.
    
    IF WS-DATA-COUNT > 0
        DISPLAY " "
        DISPLAY "BASIC STATISTICS:"
        IF CONVERSION-ERROR
            DISPLAY "   Warning: Some values could not be processed correctly"
        END-IF
        DISPLAY "   Min: " WS-MIN-VALUE
        DISPLAY "   Max: " WS-MAX-VALUE
        DISPLAY "   Range: " WS-RANGE
        DISPLAY "   Mean: " WS-MEAN
        DISPLAY "   Median: " WS-MEDIAN
        DISPLAY "   Standard Deviation: " WS-STD-DEV
        DISPLAY "   Root Mean Square (RMS): " WS-RMS
        
        DISPLAY " "
        DISPLAY "ADVANCED STATISTICS:"
        
        IF GEO-MEAN-ERROR
            DISPLAY "   Geometric Mean: Could not calculate - " 
                    "negative or zero values in dataset"
        ELSE
            DISPLAY "   Geometric Mean: " WS-GEO-MEAN
        END-IF
        
        IF HARM-MEAN-ERROR
            DISPLAY "   Harmonic Mean: Could not calculate - " 
                    "zero values in dataset"
        ELSE
            DISPLAY "   Harmonic Mean: " WS-HARM-MEAN
        END-IF
    ELSE
        DISPLAY "No data was processed."
    END-IF. 
