# Statistical Analysis Programs - COBOL Implementation

Two complementary COBOL programs for statistical analysis of numerical data, demonstrating comprehensive statistical calculations and old-school structured programming techniques.

## Files Overview

### Source Code
- **`src/statmeasure.cob`** - Comprehensive statistical measures program
- **`src/statmold.cob`** - Traditional mean and standard deviation calculator
- **`src/reflection report..pdf`** - Technical analysis and implementation report
- **`3190_A3_1211414.zip`** - Complete project archive

## Programs Description

### STATMEASURE - Advanced Statistical Calculator

A comprehensive statistical analysis program that calculates multiple statistical measures from numerical data files.

#### Features
- **Basic Statistics**: Min, Max, Range, Mean, Median, Standard Deviation
- **Advanced Statistics**: Geometric Mean, Harmonic Mean, Root Mean Square (RMS)
- **Data Quality**: Coefficient of Variation, comprehensive error handling
- **Robust Processing**: Handles up to 10,000 data points with dynamic allocation

#### Statistical Measures Calculated
1. **Arithmetic Mean**: Average of all values
2. **Median**: Middle value when data is sorted
3. **Standard Deviation**: Measure of data spread
4. **Root Mean Square (RMS)**: Square root of mean of squares
5. **Geometric Mean**: nth root of product of n values (positive values only)
6. **Harmonic Mean**: Reciprocal of arithmetic mean of reciprocals (non-zero values only)
7. **Coefficient of Variation**: Relative measure of variability
8. **Range**: Difference between maximum and minimum values

### STATMOLD - Traditional Statistical Calculator

A classic COBOL implementation focused on fundamental statistical calculations with formatted output display.

#### Features
- **Core Statistics**: Mean and Standard Deviation calculation
- **Formatted Output**: Professional display with column headers and underlines
- **Array Processing**: Handles up to 1,000 data points
- **Traditional Structure**: Classic COBOL programming style with numbered paragraphs

## Usage

### Compilation
```bash
# Using GnuCOBOL (OpenCOBOL)
cobc -x -o statmeasure src/statmeasure.cob
cobc -x -o statmold src/statmold.cob

# Using IBM COBOL (if available)
cob2 -o statmeasure src/statmeasure.cob
cob2 -o statmold src/statmold.cob
```

### Running the Programs
```bash
# Advanced statistical analysis
./statmeasure
# Enter filename when prompted

# Basic statistical analysis
./statmold
# Enter filename when prompted
```

### Input Format
Both programs expect text files with numerical data:
- One number per line
- Decimal values supported (format: ±XXXXXX.XX)
- Example input file (`data.txt`):
```
12.50
-5.75
23.00
8.25
-1.50
```

## Program Comparison

| Feature | STATMEASURE | STATMOLD |
|---------|-------------|----------|
| **Data Capacity** | 10,000 values | 1,000 values |
| **Statistics** | 8+ measures | 2 measures |
| **Error Handling** | Comprehensive | Basic |
| **Output Format** | Detailed reports | Formatted tables |
| **Median Calculation** | Yes (with sorting) | No |
| **Advanced Means** | Geometric, Harmonic | Arithmetic only |
| **Memory Management** | Dynamic allocation | Fixed arrays |

## Technical Implementation

### Data Structures

#### STATMEASURE
```cobol
01  WS-STATS.
    05  WS-SUM            PIC S9(12)V9(6)
    05  WS-MEAN           PIC S9(9)V9(6)
    05  WS-VARIANCE       PIC S9(9)V9(6)
    05  WS-STD-DEV        PIC S9(9)V9(6)
    05  WS-RMS            PIC S9(9)V9(6)
    05  WS-GEO-MEAN       PIC S9(9)V9(6)
    05  WS-HARM-MEAN      PIC S9(9)V9(6)
```

#### STATMOLD
```cobol
01  WS-STATS.
    05  WS-SUM-OF-X       PIC S9(10)V9(2)
    05  WS-MEAN           PIC S9(6)V9(2)
    05  WS-STD-DEV        PIC S9(6)V9(2)
```

### Algorithms

#### Median Calculation (STATMEASURE)
- **Bubble Sort**: Simple O(n²) sorting algorithm
- **Position Logic**: Handles both odd and even number of elements
- **Memory Efficient**: In-place sorting with temporary variables

#### Standard Deviation
- **STATMEASURE**: Population standard deviation using sum of squares
- **STATMOLD**: Sample standard deviation using deviation from mean

#### Error Handling
- **File Operations**: Comprehensive file existence and access checking
- **Data Conversion**: Robust handling of non-numeric data
- **Mathematical Operations**: Size error handling for overflows
- **Special Cases**: Zero division protection, negative logarithms

## Mathematical Formulas

### Basic Statistics
- **Mean**: μ = Σx / n
- **Standard Deviation**: σ = √(Σ(x - μ)² / n)
- **Variance**: σ² = Σ(x - μ)² / n

### Advanced Statistics
- **RMS**: √(Σx² / n)
- **Geometric Mean**: ⁿ√(x₁ × x₂ × ... × xₙ) = exp(Σln(x) / n)
- **Harmonic Mean**: n / Σ(1/x)
- **Coefficient of Variation**: (σ / μ) × 100%

## Output Examples

### STATMEASURE Output
```
STATISTICAL ANALYSIS RESULTS:
============================
Input file: data.txt
Number of values processed: 5

BASIC STATISTICS:
   Min: -5.75
   Max: 23.00
   Range: 28.75
   Mean: 7.30
   Median: 8.25
   Standard Deviation: 9.86
   Root Mean Square (RMS): 12.14

ADVANCED STATISTICS:
   Geometric Mean: Could not calculate - negative values in dataset
   Harmonic Mean: 2.45
```

### STATMOLD Output
```
 MEAN AND STANDARD DEVIATION
----------------------------
          DATA VALUES
----------------------------
            12.50
            -5.75
            23.00
             8.25
            -1.50
----------------------------
 MEAN=      7.30
 STD DEV=   9.86
```

## Error Handling Features

### Data Validation
- **File Existence**: Checks if input file exists before processing
- **Numeric Conversion**: Validates each line as numeric data
- **Range Checking**: Prevents array bounds violations
- **Size Constraints**: Handles maximum data limits gracefully

### Mathematical Safety
- **Division by Zero**: Protects harmonic mean calculations
- **Logarithm Domain**: Validates positive values for geometric mean
- **Overflow Protection**: Handles large number calculations
- **Precision Maintenance**: Appropriate decimal precision for results

## Programming Style

### COBOL Structure
- **Identification Division**: Program metadata
- **Environment Division**: File handling configuration
- **Data Division**: Variable and file declarations
- **Procedure Division**: Program logic and flow control

### Modern COBOL Features
- **Intrinsic Functions**: LOG, EXP, SQRT, NUMVAL, MOD
- **Structured Programming**: Proper paragraph organization
- **Error Handling**: Comprehensive exception management
- **Dynamic Variables**: DEPENDING ON clauses for flexible arrays

## Academic Context

- **Course**: COMP 3190 - Programming Language Concepts
- **Assignment**: A3 - COBOL Programming Implementation
- **Focus**: Statistical computing in business-oriented language
- **Learning Objectives**: Legacy system programming, numerical computation

## Author
Rajin Uddin

## Technical Notes

- **Language**: COBOL-85/2002 Standard
- **Compiler**: GnuCOBOL (OpenCOBOL) recommended
- **Portability**: Standard COBOL features for cross-platform compatibility
- **Performance**: Optimized for batch processing of large datasets