describe "UserMailer" do
  TEST_EMAIL = 'endymionjkb@gmail.com'
  
  describe "Welcome email" do
    let(:user) { FactoryGirl.create(:user) }
    let(:msg) { UserMailer.welcome_email(user, 'Fish83') }
        
    it "should return a message object" do
      expect(msg).to_not be_nil
    end
  
    it "should have the right sender" do
      expect(msg.from.to_s).to match(ApplicationHelper::MAILER_FROM_ADDRESS)
    end
    
    describe "Send the message" do
      before { msg.deliver }
        
      it "should get queued" do
        expect(ActionMailer::Base.deliveries).to_not be_empty
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
      
      # msg.to is a Mail::AddressContainer object, not a string
      # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
      it "should be sent to the right user" do
        expect(msg.to.to_s).to match(user.email)
      end
      
      it "should have the right subject" do
        expect(msg.subject).to eq(UserMailer::WELCOME_MESSAGE)
      end
      
      it "should have the right content" do
        expect(msg.body.encoded).to match('Welcome')
        expect(msg.body.encoded).to match('Fish83')
      
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end
  end  
end
