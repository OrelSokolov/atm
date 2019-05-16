# frozen_string_literal: true

require 'bundler'
require 'json'
require_relative 'lib/atm'

Bundler.require
Loader.autoload

# This is Rack app
class App < Rack::App
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Expose-Headers' => 'X-My-Custom-Header, X-Another-Custom-Header'

  serializer(&:to_json)

  desc 'Display current balance as Integer'
  get '/balance' do
    balance
  end

  desc 'Get bruteforce balance'
  get '/brute_force' do
    atm.br(params_hash['sum'].to_i)
  end

  desc 'Fast search'
  get '/fast_search' do
    atm.fast_search(params_hash['sum'].to_i)
  end

  desc 'Give money by :sum param'
  post '/give_money' do
    atm.auto_get_money!(params_hash['sum'].to_i)
  end

  desc 'Add infinite money'
  put '/put_infinite_money' do
    atm.put_infinite_money!
    balance
  end

  desc 'Empty ATM'
  delete '/empty' do
    atm.empty!
    balance
  end

  desc 'Add money as hash'
  post '/add_money' do
    atm.add_money!(json_params)
    balance
  end

  error Exception, StandardError, NoMethodError do |ex|
    { error: ex.message }
  end

  root '/hello'

  private

  def atm
    @atm ||= ATM.new(true)
    @atm
  end

  def balance
    { balance: atm.reload.balance }
  end

  def json_params
    request.env['rack.input'].read
  end

  def params_hash
    JSON.parse(request.env['rack.input'].read).to_h
  end
end
