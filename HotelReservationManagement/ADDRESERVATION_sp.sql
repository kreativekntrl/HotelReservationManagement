USE [MF67ava.steimle]
GO

CREATE OR ALTER PROCEDURE [dbo].[F26_spAddNewReservation]
	@GuestEmail varchar(100), 
	@RoomNumber varchar(10), 
	@CheckIn date, 
	@CheckOut date, 
	@Status varchar(20) = 'Confirmed'

AS 
BEGIN 

-- Local variables
DECLARE @RoomID int 
DECLARE @GuestID int
DECLARE @RoomStatus VARCHAR(20)
DECLARE @BegNumReservations int
DECLARE @EndNumReservations int

BEGIN --ERROR CHECKING 
	
	-- Retrieve the guest id from the guest table and assign is to local variable
	SELECT @GuestID = [GuestID]
	FROM [dbo].[F26_Guests]
	WHERE [Email] = @GuestEmail;

	-- Validate the guest email exists
	IF @GuestID IS NULL
		BEGIN 
			RAISERROR('We do not have a guest with that email. Please add new guest first.', 16, 1)
			RETURN
		END 

	-- Retrieve the room id from the rooms table and assign it to local variable 
	SELECT @RoomID = [RoomID], @RoomStatus = [RoomStatus]
	FROM [dbo].[F26_Rooms] 
	WHERE [RoomNumber] = @RoomNumber;

	-- Validate the room number exists 
	IF @RoomID IS NULL
		BEGIN 
			RAISERROR('Invalid room number. Check and try again.', 16, 1)
			RETURN
		END 

	-- Check if room is decommissioned 
	IF @RoomStatus IN ('Decommissioned', 'Out of Order', 'Inactive')
		BEGIN
			DECLARE @ErrMsg1 varchar(200) = 'Error: Room ' + @RoomNumber + ' is currently ' + @RoomStatus + ' and cannot be reserved.' 
			RAISERROR(@ErrMsg1, 16, 1)
			RETURN
		END

	-- Validate the check in date is either today or in the future 
	IF @CheckIn < CONVERT(DATE, GETDATE())
		BEGIN
			RAISERROR('Error: Check-in date cannot be in the past.', 16, 1)
			RETURN
		END

	-- Validate the check out date is after the check-in date
	IF @CheckOut <= @CheckIn
		BEGIN
			RAISERROR('Error: Check-out date must be at least one day after check-in date.', 16, 1)
			RETURN
		END

	-- Validate the dates for this room do not overlap any existing reservations (duplicate prevention)
	IF EXISTS (SELECT * FROM [dbo].[F26_Reservations]  
				WHERE [RoomID] = @RoomID
				AND [ReservationStatus] <> 'Cancelled' -- not cancelled  
				AND [CheckInDate] < @CheckOut -- cannot be between the dates entered
				AND [CheckOutDate] > @CheckIn)
		BEGIN
			DECLARE @ErrMsg2 varchar(200) = 'Error: Room ' + @RoomNumber + ' is already booked for those dates.'
			RAISERROR(@ErrMsg2, 16, 1)
			RETURN
		END
END -- END ERROR CHECKING 

BEGIN -- INSERT

	-- assign beginning number of reservation local variable
	SET @BegNumReservations = (SELECT COUNT(*) FROM [dbo].[F26_Reservations])
		
		-- Insert the new row 
		INSERT [dbo].[F26_Reservations]
		([CheckInDate], [CheckOutDate], [ReservationStatus], [RoomID], [GuestID])

		VALUES
		(@CheckIn, @CheckOut, @Status, @RoomID, @GuestID)

	-- assign the ending numbe of reservations local variable
	SET @EndNumReservations = (SELECT COUNT(*) FROM [dbo].[F26_Reservations])
	-- compare to make sure that the ending is greater than the beginning
	IF @EndNumReservations > @BegNumReservations
		BEGIN
			PRINT 'New reservation added'
			RETURN
		END 
	ELSE 
		BEGIN 
			PRINT 'Something went wrong. Reservation was not added successfully.'
		END 
	END -- END INSERT 
END 
