# Metric k-Center

This is my solution to the NP-Complete problem, metric k-center. A full
description of the problem can be found on [wikipedia][1].

I'm currently working on two separate peices, the _runner_ and the
_viewer_. The _runner_ is a comand-line program that will do the actual
hard work of solving the problem (or estimating a solution, to be more
exact) and the _viewer_ will display the resutls of each iteration in a
graphical format. I've described the struture a little more regarding
each component below.

## Runner
The runner is written in JRuby and is operated from the command line. This
simplifies the model greatly (not having to deal with a UI). Furthermore,
I am using JRuby because of the benefits of threading (REAL threading) over
the MRI or REE VMs. Since the goal of the problem is to minimize _k_, this
allows us to solve for multiple _k_'s simultaneously. 

## Viewer
You can imagine that if we are solving for multiple values of _k_ and
performing M evolutions in our genetic algorithm (where M can be upwards
of 1,000) that we will have lots of intermediary solutions. As such, it
may not be a great idea to generate visual representations for each of
these as we go along. It might be better to view these, selectively, after
the _runner_ as completed.

Well, that is exactly what we're going to do. The _runner_ will store each intermediary result in the DB in a textual format. The _viewer_ is a web
app that allows you to select a run and a particular point in the run
and then you can visualize the results via JavaScript rendering in-browser.

## Test Generator
Obviously, there needs to be some test data to ensure that the program
is running as expected. As such, the _lib/_ directory contains a simple
command-line utility that can generate some test data of any specified
size. Some pre-built test files have already been generated and stored
under the _runner/test_ directory.


  [1]: https://en.wikipedia.org/wiki/Metric_k-center