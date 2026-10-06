USE [MF67ava.steimle]
GO

CREATE OR ALTER PROCEDURE [dbo].[F26_spAddNewGuest]
	@FirstName nvarchar(50), @LastName nvarchar(50), @Email varchar(100), @PhoneNumber varchar(20)

AS
BEGIN

DECLARE @BegNumGuests int
DECLARE @EndNumGuests int

-- validate unique email
IF EXISTS (SELECT * FROM [dbo].[F26_Guests] WHERE [Email] = @Email)
	BEGIN 
		PRINT 'A guest with that email already exists. Please enter a unique email.'
		RETURN
	END

-- once email have been validated begin insert
	BEGIN
		SET @BegNumGuests = (SELECT COUNT(*) FROM [dbo].[F26_Guests])

			INSERT [dbo].[F26_Guests]
			([FirstName], [LastName], [Email], [PhoneNumber])

			VALUES 
			(@FirstName, @LastName, @Email, @PhoneNumber)

		SET @EndNumGuests = (SELECT COUNT(*) FROM [dbo].[F26_Guests])

	IF @EndNumGuests > @BegNumGuests
			BEGIN
				PRINT 'New guest added' + char(13) + 'New total # guests ='
				+ CONVERT(NVARCHAR(4), @EndNumGuests)
			END
	ELSE 
			BEGIN
				PRINT 'Something went wrong. Guest was not added successfully.'
			END
	END 
END 
