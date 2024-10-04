# Pipelines and pipes
<!-- vim: set tw=80 : -->


The main concepts of Plumbery are *requests*, *pipelines* and *pipes*.

Pipe is a function taking a struct called a request and returning that struct,
potentially modifying it. Request is normally a `Plumbery.Request` struct.

Pipeline is a function taking a request struct and returning that struct,
potentially modifying it. Note that is the exact description of a pipe, so a
pipeline is also a pipe. What makes it different is that pipelines are composed
of pipes and call them sequentially, passing the return value of each pipe to
the next pipe. That looks like what Elixir's pipe operator `|>` does. But there
is a difference: the pipeline checks the return value of each pipe and returns
early if there is an error or if the pipe explicitly requested pipeline 
processing to be stopped.

The fact that a pipeline is a pipe makes it possible to create reusable
pipelines that can be used as building blocks in other pipelines.

