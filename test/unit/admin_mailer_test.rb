require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase
  test "contact_us_email" do
    @expected.subject = 'AdminMailer#contact_us_email'
    @expected.body    = read_fixture('contact_us_email')
    @expected.date    = Time.now

    assert_equal @expected.encoded, AdminMailer.create_contact_us_email(@expected.date).encoded
  end

end
