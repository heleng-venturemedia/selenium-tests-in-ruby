require "test_helper"

class Marketers::CampaignsEditor::ApprovalsControllerTest < ActionController::TestCase
  setup do
    @user = users(:matt)
    sign_in_user(@user)
  end

  test "show" do
    campaign = campaigns(:draft)
    design = designs(:licensed_tshirt)
    campaign.update!(design: design)
    get :show, marketer_account_id: campaign.marketer_account.id, campaign_id: campaign.id
    assert_response :success
  end

  test "should require an uploaded design" do
    campaign = campaigns(:draft)
    design = designs(:draft)
    design.update!(license: licenses(:baylor))
    campaign.update(design: design)

    get :show,
      marketer_account_id: campaign.marketer_account.id,
      campaign_id: campaign.id
    assert_redirected_to marketer_account_campaign_editor_root_url(campaign.marketer_account.id, campaign)
    assert_equal I18n.translate("models.campaign_editor.design_required"), flash[:alert]
  end

  test "should require a licensed design" do
    campaign = campaigns(:draft)
    campaign.update!(design: designs(:papa_knows_best))
    refute campaign.licensed?
    get :show, marketer_account_id: campaign.marketer_account.id, campaign_id: campaign.id
    assert_redirected_to marketer_account_campaign_editor_root_path(campaign.marketer_account, campaign)
    assert_equal I18n.translate("models.campaign_editor.licensed_design_required"), flash[:alert]
  end

  test "license color restrictions" do
    campaign = campaigns(:draft)
    campaign.update!(design: designs(:licensed_tshirt))
    license = licenses(:baylor)
    license.update!(description: "[#FF0000]")
    get :license_restrictions,
      marketer_account_id: campaign.marketer_account.id,
      campaign_id: campaign.id,
      license_id: license.id,
      xhr: true

    assert_response(:success)
    assert_match(expected_restrictions_html, response.body)
  end

  private

  def expected_restrictions_html
    <<-HTML.strip_heredoc
      <h5>Baylor Bears Color Restrictions</h5>
      <p><span class=\"color-swatch color-swatch-sm\" style=\"background-color: #FF0000\"></span></p>
    HTML
  end
end
