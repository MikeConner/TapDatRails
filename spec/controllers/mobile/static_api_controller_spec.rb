describe Mobile::V1::StaticApiController, :type => :controller do
  it "should respond to ping" do
    get :ping, :version => 1
    
    expect(response.status).to eq(200)
    
    result = JSON.parse(response.body)

    expect(result['response']).to eq("Pong")
  end
end
