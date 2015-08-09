:x


equire "test_helper"

class AdminMailingsSummaryReportTest < ActiveSupport::TestCase
  test "daily mailings summary" do
    report = AdminMailingsSummaryReport::Daily.new
    assert report.rows.count > 0
  end

  test "weekly mailings summary" do
    report = AdminMailingsSummaryReport::Weekly.new
    assert report.rows.count > 0
  end

  test "monthly mailings summary" do
    report = AdminMailingsSummaryReport::Monthly.new
    assert report.rows.count > 0
  end
  
  test “” do
  end

  test "My new test" do
end


