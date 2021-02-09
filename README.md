# IDPPlanner

## An Iterative Dynamic Programming Query Planning Library

### Description

This is a Swift implementation of the Kossmann and Stocker *Iterative Dynamic Programming* query planning
algorithm. It is generic, and can be used with any system with types conforming to two protocols:

1. a query plan provider, with methods such as `accessPlans` and `joinPlans`
2. a cost estimator which can produce a `Cost` type for a plan, and compare two cost values

### References

Kossmann, Donald, and Konrad Stocker. "Iterative dynamic programming: a new class of query optimization algorithms." ACM Transactions on Database Systems (TODS) 25.1 (2000): 43-82.
