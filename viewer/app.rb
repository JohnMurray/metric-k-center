require 'sinatra/base'
require 'haml'
require 'json'

require_relative 'db/init'

class ViewerApp < Sinatra::Base

  configure do
    set :run, $0 == __FILE__
  end


  # display the main page
  get '/'do
    @results = Result.select(:run_id).uniq.to_a

    first_run_id = @results.first.run_id
    @runs = Result.select(:k).where(run_id: first_run_id).uniq.to_a

    first_k = @runs.first.k
    @gen_numbers = Run.select(:generation_num).where(run_id: first_run_id, k: first_k).uniq.to_a

    haml :index
  end


  # return the list of k-values for a particular run given
  # the run-id
  post '/runs' do
    run_id = params[:run_id]

    runs = Result.select(:k).where(run_id: run_id).uniq.to_a
    json = runs.map { |r| r.k }
    json = { ks: json }

    json.to_json
  end


  # return teh list of generation number for a particular
  # run given the run_id and the k-value
  post '/gen-numbers' do
    run_id = params[:run_id]
    k = params[:k].to_i

    gen_numbers = Run.select(:generation_num).where(run_id: run_id, k: k).uniq.to_a
    json = gen_numbers.map { |gn| gn.generation_num }
    json = { generation_numbers: json }
      
    json.to_json
  end


  # return the run-json for rendering given the particular
  # run_id and k-value
  post '/run-data' do
    run_id = params[:run_id]
    k = params[:k].to_i
    generation = params[:generation]

    puts params

    runs = Run.where(run_id: run_id, k: k, generation_num: generation)
    runs = runs.uniq

    run = runs.first
    run.result_json
  end

  # run with built-in server if need be
  run! if $0 == __FILE__
end
