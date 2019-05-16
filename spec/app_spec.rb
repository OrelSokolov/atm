require 'spec_helper'
require 'rack/app/test'

describe App do

  include Rack::App::Test

  rack_app described_class

  let(:json_headers) { { "CONTENT_TYPE" => "application/json" } }


  before(:each) do
    ATM.new(true).empty!
  end

  after(:each) do
    ATM.new(true).empty!
  end

  describe 'Empty ATM' do
    subject { delete(url: '/empty', headers: json_headers) }

    it { expect(subject.status).to eq 200 }

    it { expect(subject.body).to include({balance: 0}.to_json)}
  end

  describe 'Load infinite money to Empty ATM' do
    subject { put(url: '/put_infinite_money', headers: json_headers) }

    it { expect(subject.status).to eq 200 }

    it { expect(subject.body).to include({balance: 930000}.to_json)}
  end

  # describe 'Fast search for infinite money' do
  #   subject do
  #     ATM.new(true).put_infinite_money!
  #     get url: "/fast_search",  headers: json_headers, payload: {"sum": 200 }.to_json
  #   end
  #
  #   it { expect(subject.status).to eq 200 }
  #
  #   it { expect(subject.body).to include({balance: 930000}.to_json)}
  # end

end