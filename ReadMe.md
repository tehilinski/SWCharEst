SWCharEst
=========

SWCharEst is an implementation of an algorithm that estimates soil
hydrological parameters from soil text and organic matter content
using the method of Saxton and Rawls (2006).

The implementations are in four programming languages:

* C++
* Fortran90
* Python3
* R

All implementations are in object-oriented form as a class,
or in the case of Fortran90, as a module. Each has an
accompanying test program that demonstrates the class use.
The name of each class is **SWCharEst**.

Source code for the classes are in the ``src`` directory.
Source code for the test programs are in the ``tests`` directory.
At the top of each file is an explanation with usage examples.

| Language  | Class File      | Test File          |
| --------- | --------------- | ------------------ |
| C++	    | SWCharEst.cpp/h | Test_SWCharEst.cpp |
| Fortran90 | SWCharEst.f90   | Test_SWCharEst.f90 |
| Python3   | SWCharEst.py    | Test_SWCharEst.py  |
| R         | SWCharEst.R     | Test_SWCharEst.R   |


# Calculating the soil hydrologic parameters

Input:

| value                 | units                        |
| --------------------- | ---------------------------  |
| sand weight fraction  | fraction in range 0-1        |
| clay weight fraction  | fraction in range 0-1        |
| soil organic matter   | weight percent (70% maximum) |

Results:

| variable | description                      | units          |
| -------- | -------------------------------- | -------------- |
| WP       | wilting point                    | volume percent |
| FC       | field capacity                   | volume percent |
| thetaS   | saturated water content          | volume percent |
| Ks       | saturated hydraulic conductivity | cm/sec         |

Each class implementation has two public methods.
**Usage** displays the use of the class.
**Get** returns a vector (or array or list)
containing the results of the calculations:
WP, FC, thetaS, Ks, in that order.


# Citation

K. E. Saxton and W. J. Rawls, 2006.
Soil Water Characteristic Estimates by Texture and Organic Matter
for Hydrologic Solutions.
Soil Sci. Soc. Am. J. 70:1569–1578.

# Copyright and License

Package SWCharEst: Copyright 2020 Thomas E. Hilinski. All rights reserved.

Copyright 2020 Thomas E. Hilinski. All rights reserved.
This software including source code and documentation,
is licensed under the Apache License version 2.0.
See the file "LICENSE.md" for more information.
