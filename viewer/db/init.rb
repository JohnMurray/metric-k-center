gem 'activerecord', '=3.2.8'
require 'active_record'
require 'composite_primary_keys'


CONNECT_POOL_SIZE =   100



ActiveRecord::Base.establish_connection({
  adapter: 'jdbcmysql', #'mysql2',
  host: 'localhost',
  database: 'uofl_ai',
  username: 'root',
  password: '',
  pool: CONNECT_POOL_SIZE
})


require_relative 'run'
require_relative 'result'