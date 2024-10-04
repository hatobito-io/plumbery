# Creating a pipeline
<!-- vim: set tw=80 : -->

To create a pipeline, use `Plumbery` in a module, and use `pipeline` DSL keyword
to declare your pipeline. 

!elixir examples/first_pipeline_1.exs

This example is very basic, but it demonstrates the main ideas of Plumbery.
Let's see what the code does.

First, the `Plumbery` module is used. This makes available the DSL. Next,
functions from `Plumbery.Pipeline` are imported. This adds, among others, 
`error` and `success` functions. These functions are used to set the result of
pipe execution. `assign` function is used to set shared data that can be used in
subsequent pipes.

Next a couple of functions is defined. They will become pipes – the building
blocks of pipeline.

Finally, a pipeline with two pipes is created. As you can see from the first
call example, the pipeline is compiled into a function that call the pipes in
order and passes the request, potentially modifying it. But the second call
example is actually more interesting – if any pipe returns an error, the
pipeline does not call any more pipes downstream and returns immediately. This
is the default behaviour, and it can be modified like many other aspects of
pipeline processing. Read the rest of the guides to learn more.
