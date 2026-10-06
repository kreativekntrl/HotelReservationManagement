CREATE TABLE [dbo].[F26_Invoices]
(
	[InvoiceID] [int] IDENTITY(1, 1) PRIMARY KEY,	
	[PaymentDate] [datetime] NULL,
	[SubTotal] [numeric](10, 2) NOT NULL DEFAULT 0,
	[TaxAmount] [numeric](10, 2) NOT NULL DEFAULT 0,
	[InvoiceTotal] [numeric](10, 2) NOT NULL DEFAULT 0,
	[PaymentStatus] [varchar](20) NOT NULL DEFAULT 'Pending',

	[ReservationID] [int] NOT NULL FOREIGN KEY
		REFERENCES [dbo].[F26_Reservations](ReservationID)
)