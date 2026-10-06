CREATE TABLE [dbo].[F26_Reservations]
(
	[ReservationID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[CheckInDate] [date] NOT NULL,
	[CheckOutDate] [date] NOT NULL,
	[ReservationStatus] [varchar](20) NOT NULL DEFAULT 'Confirmed',

	[RoomID] [int] NOT NULL FOREIGN KEY
		REFERENCES [dbo].[F26_Rooms](RoomID),

	[GuestID] [int] NOT NULL FOREIGN KEY 
		REFERENCES [dbo].[F26_Guests](GuestID)
)