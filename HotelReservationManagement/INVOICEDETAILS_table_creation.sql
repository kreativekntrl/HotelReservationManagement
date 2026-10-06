CREATE TABLE [dbo].[F26_InvoiceDetails]
(
	[InvoiceDetailID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[ItemDesc] [nvarchar](100) NOT NULL,
	[ItemAmount] [numeric](10, 2) NOT NULL,

	[InvoiceID] [int] NOT NULL FOREIGN KEY
		REFERENCES [dbo].[F26_Invoices](InvoiceID)
)