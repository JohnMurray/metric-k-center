class Result < ActiveRecord::Base
  self.table_name = 'results'
  self.primary_keys = :run_id, :k
end