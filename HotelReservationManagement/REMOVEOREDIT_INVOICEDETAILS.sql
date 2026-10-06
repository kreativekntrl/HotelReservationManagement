USE [MF67ava.steimle]
GO

CREATE OR ALTER PROCEDURE [dbo].[F26_spRemoveOrEditInvoiceLineItems]
	@TAType nvarchar(12),
	@InvoiceID int,
	@InvoiceDetailID int,
	@TaxRate numeric(5, 4) = 0.07,
	@NewAmount numeric(10, 2) = NULL --OPTIONAL for delete 

AS 
BEGIN 

DECLARE @InvoicePaymentSatus varchar(20)
DECLARE @NewSubTotal numeric(10, 2)

	BEGIN -- ERROR CHECKING 

		-- Confirm action type is valid
		IF UPPER(@TAType) NOT IN ('ADJUST', 'DELETE')
			BEGIN
				RAISERROR('TAType must be Adjust or Delete. Please rectify', 16, 1)
				RETURN
			END

		-- Confirm InvoiceID exists for the line item 
		IF NOT EXISTS(SELECT * FROM [dbo].[F26_InvoiceDetails] WHERE [InvoiceID] = @InvoiceID AND [InvoiceDetailID] = @InvoiceDetailID)
			BEGIN
				RAISERROR('Invalid line item or invoice. Try again.' , 16, 1)
				RETURN
			END 

		-- Confirm positive amount
		IF UPPER(@TAType) = 'ADJUST' AND (@NewAmount IS NULL OR @NewAmount <= 0)
			BEGIN 
				RAISERROR('Amount must be greater than 0. Use DELETE to remove the item.', 16, 1)
				RETURN
			END

		-- Make sure invoice is not paid 
		SELECT @InvoicePaymentSatus = [PaymentStatus]
		FROM [dbo].[F26_Invoices]
		WHERE [InvoiceID] = @InvoiceID;

		IF UPPER(@InvoicePaymentSatus) = 'PAID'
			BEGIN
				RAISERROR('Invoice has been paid. Cannot edit.', 16, 1)
				RETURN
			END

	END -- ERRORCHECKING 

	BEGIN -- UPDATES
		IF UPPER(@TAType) = 'ADJUST'
			BEGIN
				-- update the new amount on the specified line item
				UPDATE [dbo].[F26_InvoiceDetails]
				SET [ItemAmount] = @NewAmount
				WHERE [InvoiceDetailID] = @InvoiceDetailID
			END

		ELSE IF UPPER(@TAType) = 'DELETE'
			BEGIN 
				-- delete the line item 
				DELETE FROM [dbo].[F26_InvoiceDetails] 
				WHERE [InvoiceDetailID] = @InvoiceDetailID AND [InvoiceID] = @InvoiceID
			END

		-- calculate new sub total of the invoice
		SELECT @NewSubTotal = ISNULL(SUM([ItemAmount]), 0)
		FROM [dbo].[F26_InvoiceDetails]
		WHERE [InvoiceID] = @InvoiceID;

		-- update the invoice
		UPDATE [dbo].[F26_Invoices]
		SET [SubTotal] = @NewSubTotal,
			[TaxAmount] = ROUND(@NewSubTotal * @TaxRate, 2)
		WHERE [InvoiceID] = @InvoiceID
	END -- UPDATES
END