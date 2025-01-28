# README

## Overview
A data-driven model-free and parameter-free method to account for the
factors influencing an algorithm; for instance, the crosstalk between
algorithm realization, compilation and hardware implementation. This can
be used to guide code optimization and to gain algorithmic maximum
efficiency for specific hardware, programming language or compiler. The
values of ETC in function of an input variable form a curve that offers a
visual representation of how an algorithm scale with input size. When the
ETC curves of different versions of an algorithm are reported together
with the theoretical time complexity curve, their comparison allows to
select what versions are closer to the theoretical complexity.

In this repository, we provide Matlab and Python code for obtaining ETC results for an algorithm function.

## article
The original article introducing the ACscore metric is "Empirical time complexity for assessing the algorithm computational consumption on a hardware".

Matlab codes for reproducing figures in the article are under the figure/ folder.
Matlab requirements: Matlab 2021b or before; Bioinfomatics Toolbox.