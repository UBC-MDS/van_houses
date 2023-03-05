# reflection-milestone2

A large dataset can be a challenge to work with, especially when it comes to loading and processing the data. We have to write a downloader and preprocessor code to save the pre-loaded variable instead of the entire dataset. Otherwise of page will load for 5 minutes. To further improve, we can use a downloader to retrieve only the necessary data instead of the entire dataset. Additionally, because of the large data set (houses), it is very hard to fit into a small panel. The map looks not so good at the beginning. We resolved this by using the "markerClusterOptions".

The quality of the data utilised to construct the dashboard is vital since it defines its accuracy and use. In our scenario, several columns of the data we're using are missing values, which might influence the authenticity of the visualisations and tables. For example, NA in communities for houses, which doesn't make sense. This has to do with the incompleteness of the data collection. To remedy this problem, further imputation work must be performed on the data to make the graphs and tables more usable and informative.

We also noticed difficulties with imbalanced data, in addition to the missing numbers. When selecting classes with few data points, for instance, the visualisations may not be particularly informative. This might lead to distorted findings and insights. Hence, it is essential to verify that the data utilised to fill the dashboard is indicative of the whole dataset and balanced.

In addition, we are not directly taking data from the website. This might provide issues in terms of data accuracy and freshness. We may try utilising an API to retrieve data straight from the source to circumvent this issue. This would guarantee that the data is correct and up-to-date, which is necessary for making educated judgements.

In conclusion, the dashboard's accuracy and use rely heavily on the quality of the data used to create it. To improve the dashboard's usefulness, we must solve the problem of missing values and imbalanced data. In addition, we may consider utilising an API to get data directly from the source in order to guarantee its freshness and correctness.
