library(shinytest2)

test_that("{shinytest2} recording: launch_test", {
  app <- AppDriver$new(name = "launch_test", height = 736, width = 1169)
  app$set_inputs(DataTables_Table_0_length = "10")
  app$expect_values(output = "avg_price")
})
