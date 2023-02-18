# Vancouver Housing Market Dashboard

-   Authors: Morris Zhao, Hanchen Wang, Ziyi Chen, Ken Wang

## Summary

Our R-based dashboard application gives an easy way for people to explore housing prices in Vancouver city. More details can be found [here](reports/proposal.md).

## Visualizations

-   **Map**: An interactive map that allows user to choose a certain area. Based on the area selection all other components will update in real time.
-   **Histogram**: Property price distribution. The range of price shown here is subject to the `Price` slide bar on the left. Price range and percentage show up when you hover over any bucket in the histogram. Optionally you can also change price range by drag-selecting areas within the current plot.
-   **Bar Chart**: You can either type in or use check boxes to select up to 5 area codes. Then the bar chart will show average property price for each region of interest.
-   **Data Table**: In addition to above visualizations, we also plan to include a `Data Source` component, where users can query and download the raw data as csv a file.

Ideally all the interactive features in these 4 visualizations are linked together. When you make a selection on one chart, all the other 3 will update accordingly as well.

## Navigation Pane

On the left hand side there are drop down menus, check boxes and slide bars to let you select data points under certain criteria. Currently our design is to let you filter by `community`, `property type`, `price` and `year built`. These filters will apply to all the 4 visualizations on the right. <br> <br> <img src="docs/images/app_sketch.jpg"/>

# License

Licensed under the terms of the MIT license.
