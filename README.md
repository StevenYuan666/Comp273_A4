# Matrix Multiplication and Cache Friendly Code
Code to multiply two square n × n matrices of single precision floating point numbers, and then optimize the code to exploit a memory cache. All the functions respect register conventions and work for different sizes of square matrices.

Implement step by step as the following helper functions:

**Substract**

Implement a function that subtracts two square n × n matrices A and B, and stores the result in matrix C. That is, Cij ←Aij −Bij.

**Frobeneous Norm**

Implement a function that computes the Frobeneous norm of a matrix,

![image](https://user-images.githubusercontent.com/68981504/148159452-441661dd-24eb-4865-8ed1-519f7b2ea3c6.png)

**Check**

Implement a function that prints the Frobeneous norm of the difference of two matrices. 

**MADD1**

Write MIPS code to multiply two square n × n matrices A and B, and add the result to matrix C. That is,

![image](https://user-images.githubusercontent.com/68981504/148159570-59c2e1c1-d312-453f-93a7-fbdbb6831b3f.png)

Note that this is a cache unfriendly implementation because we load and store C[i][j] on every iteration of our inner loop. It would be better to compute the sum of the inner loop in a register, and then add it to C[i][j] after the inner loop is complete. Moreover, the memory access patterns in this naive implementation poorly exploits cached memory.

**MADD2**

A cache friendly optimized version of the multiply and add function. Breaking up the nested loops and changing the order will take advantage of matrix entries that are already in the cache.
