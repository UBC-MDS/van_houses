library(shinytest2)

test_that("{shinytest2} recording: launch_test", {
  app <- AppDriver$new(name = "launch_test", height = 736, width = 1169)
  app$set_inputs(DataTables_Table_0_length = "10")
  app$expect_values(output = "avg_price")
})


test_that("{shinytest2} recording: slider_button_test", {
  app <- AppDriver$new(name = "slider_button_test", height = 736, width = 1169)
  app$set_inputs(DataTables_Table_0_length = "10")
  app$set_inputs(reportyear = "2020")
  app$set_inputs(priceslider = c(3e+05, 3760000))
  app$set_inputs(yearslider = c(1975, 1994))
  app$expect_values(output = "num_houses")
  app$expect_values(output = "avg_price")
})


test_that("{shinytest2} recording: testing_selection_box", {
  app <- AppDriver$new(name = "testing_selection_box", height = 736, width = 1169)
  app$set_inputs(DataTables_Table_0_length = "10")
  app$set_inputs(select_all_zoning = TRUE)
  app$set_inputs(community = c("Shaughnessy", "Kerrisdale", "Downtown", "Marpole"))
  app$expect_values(output = "avg_price")
  app$expect_values(output = "num_houses")
})
