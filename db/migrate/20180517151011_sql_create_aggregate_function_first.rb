class SqlCreateAggregateFunctionFirst < ActiveRecord::Migration[5.1]
  def up
    execute "
      -- Create a function that always returns the first non-NULL item
      CREATE OR REPLACE FUNCTION public.first_agg ( anyelement, anyelement )
      RETURNS anyelement LANGUAGE SQL IMMUTABLE STRICT AS $$
        SELECT $1;
      $$;
 
      -- And then wrap an aggregate around it
      CREATE AGGREGATE public.FIRST (
        sfunc    = public.first_agg,
        basetype = anyelement,
        stype    = anyelement
      );
    "
  end
end
