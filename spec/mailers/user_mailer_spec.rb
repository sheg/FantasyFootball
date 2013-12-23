require "spec_helper"

describe UserMailer do
  describe "signup_success" do
    let(:mail) { UserMailer.signup_success }

    it "renders the headers" do
      mail.subject.should eq("Signup success")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
