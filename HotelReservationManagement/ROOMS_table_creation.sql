CREATE TABLE [dbo].[F26_Rooms]
(
	[RoomID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[RoomNumber] [varchar](10) NOT NULL,
	[RoomType] [nvarchar](50) NOT NULL,
	[BaseRate] [numeric](10, 2) NOT NULL,
	[RoomStatus] [nvarchar](20) NOT NULL DEFAULT 'Available'
)