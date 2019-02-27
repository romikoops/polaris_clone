# frozen_string_literal: true

module IteratorHelpers
  def nested_each_with_times(*args, &block)
    nested_each_with_times_argument_errors(args)
    recursion_for_nested_each_with_times(args: args, &block)
  end

  def recursion_for_nested_each_with_times(args_and_params = {}, &block)
    args   = args_and_params[:args]
    params = args_and_params[:params] || []

    array, num_times = *args.first(2)

    array.each_with_times(num_times) do |new_elem|
      new_args   = args[2..-1]
      new_params = [*params, new_elem]

      if new_args.empty?
        yield(*new_params)
      else
        recursion_for_nested_each_with_times(args: new_args, params: new_params, &block)
      end
    end
  end

  def nested_each_with_times_argument_errors(args)
    message = "
      Arguments passed to this method must follow the following pattern:
      Array, Integer/Float/Range, Array, Integer/Float/Range, ...
    "
    raise ArgumentError, message unless args.size.even? && args.each_with_index.all? do |arg, i|
      i.odd? ? (arg.is_a?(Integer) || arg.is_a?(Float) || arg.is_a?(Range)) : arg.is_a?(Array)
    end
  end
end
