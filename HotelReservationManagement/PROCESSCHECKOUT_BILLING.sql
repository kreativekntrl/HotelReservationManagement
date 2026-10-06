USE [MF67ava.steimle]
GO 

CREATE OR ALTER PROCEDURE [dbo].[F26_spProcessCheckOutAndBilling]
	@ReservationID int

AS 
BEGIN

DECLARE @RoomID int  

	BEGIN -- ERROR CHECKING 

	-- Confirm reservation ID exists
	IF NOT EXISTS(SELECT * FROM [dbo].[F26_Reservations] WHERE [ReservationID] = @ReservationID)
		BEGIN
			RAISERROR('Reservation does not exist.', 16, 1)
			RETURN
		END

	-- Check is check out has been completed 
	IF EXISTS (SELECT * FROM [dbo].[F26_Reservations] WHERE [ReservationID] = @ReservationID AND [ReservationStatus] = 'Completed')
		BEGIN
			RAISERROR('Reservation has already beeen completed. No need to check out', 16, 1)
			RETURN
		END

	-- Confirm an associated invoice exists
	IF NOT EXISTS (SELECT 1 FROM [dbo].[F26_Invoices] WHERE [ReservationID] = @ReservationID)
		BEGIN
			DECLARE @ErrMsg nvarchar(100) = 
					'No invoice found for Reservation: ' 
					+ CONVERT(nvarchar(10), @ReservationID) 
					+ '. Cannot complete check-out.'
			RAISERROR(@ErrMsg, 16, 1);
			RETURN
		END

	END -- END ERROR CHECKING 

	BEGIN -- UPDATES

	-- Retrieves the room ID and assigns it to the local room id variable 
	SELECT @RoomID = [RoomID]
	FROM [dbo].[F26_Reservations]
	WHERE [ReservationID] = @ReservationID;

	-- update room status 'needs cleaning'
	UPDATE [dbo].[F26_Rooms]
	SET [RoomStatus] = 'Needs Cleaning'
	WHERE [RoomID] = @RoomID
	
	-- update reservation status 'completed'
	UPDATE [dbo].[F26_Reservations]
	SET [ReservationStatus] = 'Completed'
	WHERE [ReservationID] = @ReservationID

	-- update invoice status 'paid' 
	UPDATE [dbo].[F26_Invoices]
	SET [PaymentDate] = GETDATE(),
		[PaymentStatus] = 'Paid'
	WHERE [ReservationID] = @ReservationID

	END 
END 