require 'composite_primary_keys'
class Run < ActiveRecord::Base
  self.table_name = 'runs'
  self.primary_keys = :run_id, :k, :generation_num
end