require "test_helper"

class AdminOrderBatchSalesReportTest < ActiveSupport::TestCase
  test "report" do
    order_batch = order_batches(:fulfilled)
    rows = AdminOrderBatchSalesReport.new(order_batch).rows
    assert rows.length > 0

    row = rows.first
    assert_not_nil row
    assert_not_nil row.color

    assert row.quantity > 0
    assert row.item_amount > 0
    assert row.platform_earnings_amount > 0
    assert row.marketer_earnings_amount > 0
  end
end
