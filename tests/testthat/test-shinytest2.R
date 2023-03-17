library(shinytest2)

test_that("{shinytest2} recording: launch_test", {
  app <- AppDriver$new(name = "launch_test", height = 736, width = 1169)
  app$set_inputs(DataTables_Table_0_length = "10")
  app$set_inputs(reportyear = "2020")
  app$expect_values(output = "avg_price")
  app$expect_values(output = "num_houses")
  app$set_inputs(reportyear = "2021")
  app$set_inputs(yearslider = c(2008, 2016))
  app$expect_values(output = "avg_price")
  app$expect_values(output = "histogram_land_value")
})


test_that("{shinytest2} recording: dark_mode_test", {
  app <- AppDriver$new(variant = platform_variant(), name = "dark_mode_test", height = 736, width = 1169)
  app$set_inputs(DataTables_Table_0_length = "10")
  app$set_window_size(width = 1169, height = 737)
  app$set_inputs(priceslider = c(2824000, 5e+06))
  app$set_inputs(yearslider = c(2007, 2016))
  app$set_inputs(toggle_theme = TRUE)
  app$set_inputs(DataTables_Table_5_length = "10")
  app$expect_screenshot()
})
