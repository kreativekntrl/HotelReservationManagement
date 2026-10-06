USE [MF67ava.steimle]
GO

CREATE OR ALTER PROCEDURE [dbo].[F26_spProcessCheckIn]
	@ReservationID int

AS 
BEGIN

DECLARE @RoomID int;
DECLARE @BaseRate numeric(10, 2);
DECLARE @NewInvoiceID int;

	BEGIN -- ERROR CHECKING  

	-- Confirm reservation ID exists 
	IF NOT EXISTS(SELECT * FROM [dbo].[F26_Reservations] WHERE [ReservationID] = @ReservationID)
		BEGIN
			RAISERROR('Reservation does not exist.', 16, 1)
			RETURN
		END 

	-- Check is check in has been completed 
	IF EXISTS (SELECT * FROM [dbo].[F26_Reservations] WHERE [ReservationID] = @ReservationID AND [ReservationStatus] = 'Checked-In')
		BEGIN
			RAISERROR('Reservation is already checked in.', 16, 1)
			RETURN
		END

	-- Check to see if the reservation was cancelled
	IF EXISTS (SELECT * FROM [dbo].[F26_Reservations] WHERE [ReservationID] = @ReservationID AND [ReservationStatus] = 'Cancelled')
		BEGIN
			RAISERROR('Reservation was cancelled.', 16, 1)
			RETURN
		END

	END --END ERROR CHECKING 

	BEGIN -- Updates and Insert

		-- Retrieve base rate and room id via JOIN
		SELECT 
			@RoomID = res.[RoomID],
			@BaseRate = rm.[BaseRate]
		FROM [dbo].[F26_Reservations] res
		JOIN [dbo].[F26_Rooms] rm 
		ON res.[RoomID] = rm.[RoomID]
		WHERE res.[ReservationID] = @ReservationID;

		-- Update reservation status 
		UPDATE [dbo].[F26_Reservations] 
		SET [ReservationStatus] = 'Checked-In'
		WHERE [ReservationID] = @ReservationID

		-- Update room status
		UPDATE [dbo].[F26_Rooms]
		SET [RoomStatus] = 'Occupied'
		WHERE [RoomID] = @RoomID

		-- create new invoice 
		INSERT INTO [dbo].[F26_Invoices] 
		([ReservationID], [SubTotal], [PaymentStatus])

		VALUES 
		(@ReservationID, @BaseRate, 'Pending')

		-- capture the invoice ID for the invoice just created
		SET @NewInvoiceID = SCOPE_IDENTITY();

       	-- Add the base rate line item to the invoice
		EXECUTE [dbo].[F26_spAddInvoiceLineItem] 
			@InvoiceID = @NewInvoiceID,
			@Desc = 'Room Base Rate Charge',
			@Amount = @BaseRate

		PRINT 'Your invoice for reservation: ' + CONVERT(varchar(20), @ReservationID) + ' has been created and your guests are checked in.' 

	END -- end update/insert
END