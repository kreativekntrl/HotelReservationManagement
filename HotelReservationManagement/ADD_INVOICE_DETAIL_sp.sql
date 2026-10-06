USE [MF67ava.steimle]
GO

CREATE OR ALTER PROCEDURE [dbo].[F26_spAddInvoiceLineItem]
	@InvoiceID int,
	@Desc nvarchar(100),
	@Amount numeric(10, 2),
	@TaxRate numeric(5, 4) = 0.07 -- DEFAULT TAX AMOUNT

AS
BEGIN

-- Declare local variables
DECLARE @NewSubTotal numeric(10, 2);

	BEGIN -- ERROR CHECKING

		-- checks to make sure invoiceID exists
		IF NOT EXISTS(SELECT * FROM [dbo].[F26_Invoices] WHERE [InvoiceID] = @InvoiceID)
			BEGIN 
				RAISERROR('The invoiceID does not match any existing invoices. Please try again', 16, 1)
				RETURN
			END 

		-- checks to make sure @Amount is not null or 0
		IF @Amount IS NULL OR @AMOUNT <= 0
			BEGIN 
				RAISERROR('The amount entered must be greater than 0.', 16, 1)
				RETURN 
			END

	END -- END ERROR CHECKING 

	BEGIN --INSERT/UPDATE 

		-- INSERTS new line item into InvoiceDetails
		INSERT [dbo].[F26_InvoiceDetails]
		([InvoiceID], [ItemDesc], [ItemAmount])

		VALUES
		(@InvoiceID, @Desc, @Amount)

		-- Calculates the new subtotal based on the sum off all the line item sub totals for the invoice 
		SELECT @NewSubTotal = ISNULL(SUM([ItemAmount]), 0)
		FROM [dbo].[F26_InvoiceDetails]
		WHERE [InvoiceID] = @InvoiceID;

		-- Update SubTotal and TaxAmount in F26_Invoices
		UPDATE [dbo].[F26_Invoices]
		SET [SubTotal] = @NewSubTotal,
			[TaxAmount] = ROUND(@NewSubTotal * @TaxRate, 2)
		WHERE [InvoiceID] = @InvoiceID;

	END
END
