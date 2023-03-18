[![shiny-deploy](https://github.com/UBC-MDS/van_houses/actions/workflows/deploy-app.yaml/badge.svg)](https://github.com/UBC-MDS/van_houses/actions/workflows/deploy-app.yaml) [![Test app w/ {renv}](https://github.com/UBC-MDS/van_houses/actions/workflows/testing.yaml/badge.svg)](https://github.com/UBC-MDS/van_houses/actions/workflows/testing.yaml)

# Vancouver Housing Market Dashboard <img src="img/logo.png" align="right" height="139"/>

-   Authors: Morris Zhao, HanChen Wang, Ziyi Chen, Ken Wang

You can open our app via this [link](https://hcwang24.shinyapps.io/van_houses/)

## Welcome

Thank you for being interested in our Vancouver Housing Market App!

Our app is designed to provide an interactive and informative way to explore the Vancouver housing market. Whether you're a real estate professional, a data analyst, or simply curious about the housing price trends in Vancouver, our app has something for you.

You may find information about the app in this README file. To learn more about the features of our app, jump to the sections below:

-   [What is this all about?](#motivation-and-purpose)
-   [About us](#who-are-we)
-   [Description](#description)
-   [Installation](#installation)
-   [Interested in contributing?](#contributing)
-   [Keep in touch](#contact-us)
-   [Data Source](#data-source)
-   [License](#license)

We hope you find our app useful and informative. Happy exploring!

## Motivation and purpose {#motivation-and-purpose}

The housing market in Vancouver has been one of the most active and competitive in North America in recent years, with prices fluctuating dramatically and demand consistently outstripping supply. As a result, real estate professionals, home buyers, sellers, researchers, policymakers, etc. all need access to up-to-date information on housing prices and trends.

The purpose of our app is to provide a user-friendly, interactive, and informative tool for monitoring Vancouver's housing market. The app aggregates data on housing prices from the City of Vancouver Open Data Portal and presents it in an engaging format, allowing users to gain insights into trends and patterns over time.

The motivation for developing this app was to create a comprehensive and informative app that can serve as a valuable resource for anyone interested in understanding Vancouver's housing market. The app is designed to be user-friendly and interactive, with a range of visualizations that help users make sense of the presented information. Ultimately, the goal is to help users stay informed about the state of the market and make better-informed decisions.

More details can be found [here](reports/proposal.md).

## Who are we {#who-are-we}

We are a team of data scientists at [UBC MDS](https://masterdatascience.ubc.ca) who are passionate about coming up with original, useful solutions to challenges. Our team is ideally suited to take on challenging tasks in the field of data analysis because of the wide range of expertise in data science, programming, and statistics that we have.

The development of this app for Vancouver's housing market was a collaborative effort that brought together our team's expertise in data collection, analysis, and visualization.

### Meet the team

-   Morris Zhao
-   HanChen Wang
-   Ziyi Chen
-   Ken Wang

## Description {#description}

-   **Statistics Boxes**: Four key statistics for your chosen population of houses. These include the number of houses meeting your criteria, their average price, year of construction, and year of major improvements.
-   **Map**: An interactive map that allows user to choose a certain area. Based on the area selection all other components will update in real time.
-   **Histogram**: Property price distribution. The range of price shown here is subject to the `Price` slide bar on the left. Price range and percentage show up when you hover over any bucket in the histogram. Optionally you can also change price range by drag-selecting areas within the current plot.
-   **Data Table**: In addition to above visualizations, we also plan to include a `Data Source` component, where users can query and download the raw data as csv a file.

Ideally all the interactive features in these 3 visualizations are linked together. When you make a selection on the left sidebar, all visualizaitons will update accordingly as well.

On the left hand side there are drop down menus, check boxes and slide bars to let you select data points under certain criteria. Currently our design is to let you filter by `community`, `property type`, `price` and `year built`. These filters will apply to all the 3 visualizations on the right.

<img src="img/new gif.gif" width="1000" height="500"/>

## Installation {#installation}

To install `van_houses` locally, you must have R and RStudio installed on your computer. Once you have these tools, you may install and run the app by following these instructions:

1.  Clone this repository locally.
2.  Open RStudio and navigate to the directory where you downloaded this repository.
3.  Open the app.R file in RStudio.
4.  Use the console to run the following command to install the required packages:

```{r}
install.packages(c("shiny", "bslib", "thematic", "plotly", "tidyverse", "leaflet", "shinyWidgets", "shinycssloaders"))
```

5.  Run the app by clicking the "Run App" button in the top right corner of the RStudio window or use the console to run the app:

```{r}
RScript app.R
```

Your web browser should now open the app in a new window or tab. You may interact with the app and explore information about the housing market in Vancouver.

## Contributing {#contributing}

We welcome anyone who is interested in contributing to our app for Vancouver's housing market. Our project is open-source, which means that anyone can view and contribute to the code on our GitHub repository.

If you are interested in getting involved, check out the [contributing guidelines](CONTRIBUTING.md). Please note that this project is released with a [Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## Contact us {#contact-us}

If you have any questions, feedback, or suggestions about our Vancouver Housing Market app, we would love to hear from you! You can contact our team by visiting our GitHub repository and creating a new issue. This is the best way to reach us if you have technical questions or issues with the app.

Alternatively, you can contact us via email by sending a message to the address listed [here](https://github.com/UBC-MDS/van_houses/blob/main/CONTRIBUTING.md). We welcome any inquiries about the project or our team and are happy to answer any questions you may have.

## Data Source {#data-source}

The data on housing prices are retrieved from the [City of Vancouver Open Data Portal](https://opendata.vancouver.ca/explore/dataset/property-tax-report/table/?sort=-tax_assessment_year).

## License {#license}

Licensed under the terms of the MIT license.
