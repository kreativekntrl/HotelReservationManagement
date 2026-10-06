CREATE TABLE [dbo].[F26_Guests]
(
	[GuestID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[FullName] AS CONCAT([LastName], ', ', [FirstName]) PERSISTED,
	[Email] [varchar](100) NOT NULL UNIQUE,
	[PhoneNumber] [varchar](20) NOT NULL
)