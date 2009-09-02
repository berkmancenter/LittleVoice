### 
# This fix is intended to permit additional conditions for find_with_ferret to be specified as a hash.
# Previously, an array or string was presumed.
module ActsAsFerret
  module ClassMethods
        
    def retrieve_records(id_arrays, find_options = {})
         result = []
         # get objects for each model
         id_arrays.each do |model, id_array|
           next if id_array.empty?
           begin
             model = model.constantize
           rescue
             raise "Please use ':store_class_name => true' if you want to use multi_search.\n#{$!}"
           end
   
           # merge conditions
           conditions = combine_conditions([ "#{model.table_name}.#{model.primary_key} in (?)", id_array.keys ], find_options[:conditions], model)
   
           # check for include association that might only exist on some models in case of multi_search
           filtered_include_options = []
           if include_options = find_options[:include]
             include_options = [ include_options ] unless include_options.respond_to?(:each)
             include_options.each do |include_option|
               filtered_include_options << include_option if model.reflections.has_key?(include_option.is_a?(Hash) ? include_option.keys[0].to_sym : include_option.to_sym)
             end
           end
           filtered_include_options = nil if filtered_include_options.empty?
   
           # fetch
           tmp_result = model.find(:all, find_options.merge(:conditions => conditions, :include => filtered_include_options))
   
           # set scores and rank
           tmp_result.each do |record|
             record.ferret_rank, record.ferret_score = id_array[record.id.to_s]
           end
           # merge with result array
           result.concat tmp_result
         end
        
         # order results as they were found by ferret, unless an AR :order
         # option was given
         result.sort! { |a, b| a.ferret_rank <=> b.ferret_rank } unless find_options[:order]
         return result
       end
   
   def count_records(id_arrays, find_options = {})
         count_options = find_options.dup
         count_options.delete :limit
         count_options.delete :offset
         count = 0
         id_arrays.each do |model, id_array|
           next if id_array.empty?
           begin
             model = model.constantize
             # merge conditions
             conditions = combine_conditions([ "#{model.table_name}.#{model.primary_key} in (?)", id_array.keys ], find_options[:conditions], model)
             opts = find_options.merge :conditions => conditions
             opts.delete :limit; opts.delete :offset
             count += model.count opts
           rescue TypeError
             raise "#{model} must use :store_class_name option if you want to use multi_search against it.\n#{$!}"
           end
         end
         count
       end
   
    def combine_conditions(conditions, additional_conditions = [], model = nil)
      returning conditions do
        if additional_conditions && additional_conditions.any?
          if additional_conditions.is_a?(Array) 
            cust_opts = additional_comments.dup
          elsif additional_conditions.is_a?(Hash)
            cust_opts = [ model.sanitize_sql_hash_for_conditions(additional_conditions) ] 
          else
            cust_opts = [ additional_conditions ]
          end
          conditions.first << " and " << cust_opts.shift
          conditions.concat(cust_opts)
        end
      end
    end
    
  end
end