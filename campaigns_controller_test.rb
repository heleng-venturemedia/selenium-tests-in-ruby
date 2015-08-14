require "test_helper"

class CampaignsControllerTest < ActionController::TestCase
  include AlphaIdHelper

  test "unknown campaign raises error" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, slug: "this-campaign-does-not-exist"
    end
  end

  test "non visible campaigns are not visible" do
    campaign = campaigns(:active)
    campaign.update_attributes(is_visible: false)
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, slug: campaign.slug
    end
  end

  test "anybody can view started campaign" do
    campaign = campaigns(:active_with_created_order_batch)
    get :show, slug: campaign.slug
    assert_response :success
    assert_match "#{campaign.item_quantity} sold!", response.body
  end

  test "only marketer can see link to campaign details" do
    # non-signed in user should not see link
    campaign = campaigns(:active)
    get :show, slug: campaign.slug
    assert_select "a[href=?]", marketer_account_campaign_path(campaign.marketer_account, campaign), count: 0

    # signed in user that doesn't own campaign
    sign_in_user(users(:bob))
    get :show, slug: campaign.slug
    assert_select "a[href=?]", marketer_account_campaign_path(campaign.marketer_account, campaign), count: 0

    # marketer that owns campaign
    sign_in_user(campaign.marketer_account.users.first)
    get :show, slug: campaign.slug
    assert_select "a[href=?]", marketer_account_campaign_path(campaign.marketer_account, campaign), count: 1
  end

  test "show facebook audience pixels from marketer account" do
    campaign = campaigns(:active)
    campaign.marketer_account.update_attributes(facebook_audience_pixel_ids: "456 999")
    get :show, slug: campaign.slug

    assert_response :success
    assert_match "fbq('init', '456');", response.body
    assert_match "fbq('init', '999');", response.body
    assert_match "fbq('track', 'ViewContent', {", response.body
  end

  test "show facebook audience pixels from setting" do
    Setting.create(name: "facebook_audience_pixel_ids", value: " 1111  4444 ")
    controller.expire_all_settings
    campaign = campaigns(:active)
    get :show, slug: campaign.slug

    assert_response :success
    assert_match "fbq('init', '1111');", response.body
    assert_match "fbq('init', '4444');", response.body
    assert_match "fbq('track', 'ViewContent', {", response.body
  end

  test "set referral code with r parameter" do
    campaign = campaigns(:active)
    get :show, slug: campaign.slug, r: "xyz"
    assert_response :success
    assert_equal("xyz", assigns(:order).referral_code)
  end

  test "find mailing" do
    campaign = campaigns(:active)
    mailing = mailings(:delivered)
    get :show, slug: campaign.slug, m: id_to_alpha_id(mailing.id)
    assert_response :success
    assert_equal mailing, assigns(:mailing)
  end
end
