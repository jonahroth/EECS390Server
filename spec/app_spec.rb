require File.expand_path '../spec_helper.rb', __FILE__

describe "basic functionality" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  it "should allow read and write the database" do
    expect(User.all.to_a).to be_empty
    test_user = User.create(:username => "test_user")
    expect(User.first.username).to eq "test_user"
  end
end
