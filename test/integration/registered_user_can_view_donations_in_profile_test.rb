require 'test_helper'

class RegisteredUserCanViewDonationsInProfileTest < ActionDispatch::IntegrationTest
  test "registered user can view donation history in user show" do
    user = users(:carl)
    category = categories(:tech)
    cause = causes(:colonize_moon)

    log_in(user)
    visit user_cause_path(cause.user, cause)

    within '#amount-raised' do
      assert page.has_content?("0")
    end

    fill_in "Amount", with: 159
    click_on "Fund This Dream"
    within '#amount-raised' do
      assert page.has_content?("159")
    end
    assert_equal user_cause_path(cause.user, cause), current_path
    assert page.has_content?("Thank you for making this dream come true!")

    visit user_path(user)

    within '#causes-supported' do
      assert page.has_content?("159")
    end
  end
end