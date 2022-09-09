# Build a Logical Enterprise Data Warehouse using Azure Data Lake Storage Gen 2 and Synapse Serverless SQL pools

## Overview 
A common pattern in Modern Data Warehouse architecture is to land your source data in its existing format into a data lake followed by transforming and loading it into an Enterprise Data Warehouse (EDW) for reporting and analytics.  In Microsoft Azure, this translates to loading data into Azure Data Lake Storage Gen2 (ADLS), transforming data with Synapse or Azure Data Factory Pipelines, storing data in an Azure Synapse Dedicated Pool database or other Azure relational data store, and building reports over that data in Power BI, Excel, or other reporting tools. Typically, the EDW data is stored in a Star Schema, the optimal design for many reporting and analytical tools like Power BI.  This is a great practice for enterprise reporting requirements but has some pitfalls: 

Traditional transformation and load of data to the final EDW data store can be time consuming
Ingress and storage costs increase when transforming and loading from the landing zone to the final data store for reporting 
Additionally, if your Power BI dataset imports the data from your EDW, this data is stored in a 3rd location, the Power BI Dataset in the Power BI service. That’s a lot of data storage and movement! But: 

 - What if your data was transformed and ready for reporting as soon as it is landed in the cloud?  
 - What if you could eliminate that time consuming ETL process? 
 - How about not incurring additional costs for moving, transforming and storing data in another location?  
 - How about doing this all within T-SQL? 
 
Then [Synapse Serverless SQL pools](https://docs.microsoft.com/en-us/azure/synapse-analytics/sql/on-demand-workspace-overview) in Azure Synapse Analytics may be the answer for you!
![image](https://user-images.githubusercontent.com/57195527/189446878-42145e84-db3f-4e4a-ba24-9876115580bb.png)
