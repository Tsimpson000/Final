CREATE SCHEMA Venue;

CREATE TABLE [Venue].[EventOrganizer] (
  [ID] int,
  [Email] varchar,
  [PhoneNumber] varchar,
  PRIMARY KEY ([ID])
);

CREATE TABLE [Venue].[BookingManager] (
  [ID] int,
  [FirstName] varchar,
  [LastName] varchar,
  [Email] varchar,
  [PhoneNumber] varchar,
  PRIMARY KEY ([ID])
);

CREATE TABLE [Venue].[Events] (
  [ID] int,
  [EventOrganizerID] int,
  [BookingManagerID] int,
  [EventName] varchar,
  [EventDate] date,
  PRIMARY KEY ([ID]),
  CONSTRAINT [FK_Events.EventOrganizerID]
    FOREIGN KEY ([EventOrganizerID])
      REFERENCES [Venue].[EventOrganizer]([ID]),
  CONSTRAINT [FK_Events.BookingManagerID]
    FOREIGN KEY ([BookingManagerID])
      REFERENCES [Venue].[BookingManager]([ID])
);

CREATE TABLE [Venue].[Artists] (
  [ID] int,
  [EventOrganizerID] int,
  [BookingManagerID] int,
  [ArtistName] varchar,
  PRIMARY KEY ([ID]),
  CONSTRAINT [FK_Artists.EventOrganizerID]
    FOREIGN KEY ([EventOrganizerID])
      REFERENCES [Venue].[EventOrganizer]([ID]),
  CONSTRAINT [FK_Artists.BookingManagerID]
    FOREIGN KEY ([BookingManagerID])
      REFERENCES [Venue].[BookingManager]([ID])
);

CREATE TABLE [Venue].[EventArtists] (
  [ID] int,
  [EventsID] int,
  [ArtistsID] int,
  PRIMARY KEY ([ID]),
  CONSTRAINT [FK_EventArtists.EventsID]
    FOREIGN KEY ([EventsID])
      REFERENCES [Venue].[Events]([ID]),
  CONSTRAINT [FK_EventArtists.ArtistsID]
    FOREIGN KEY ([ArtistsID])
      REFERENCES [Venue].[Artists]([ID])
);

CREATE TABLE [Venue].[RiderRequests] (
  [ID] int,
  [Item] varchar,
  [Cost] money,
  PRIMARY KEY ([ID])
);

CREATE TABLE [ArtistsRiderRequests] (
  [ID] int,
  [ArtistsID] int,
  [RiderRequestsID] int,
  PRIMARY KEY ([ID]),
  CONSTRAINT [FK_ArtistsRiderRequests.ArtistsID]
    FOREIGN KEY ([ArtistsID])
      REFERENCES [Venue].[Artists]([ID]),
  CONSTRAINT [FK_ArtistsRiderRequests.RiderRequestsID]
    FOREIGN KEY ([RiderRequestsID])
      REFERENCES [Venue].[RiderRequests]([ID])
);

CREATE PROCEDURE GetEventsAndArtistsByDate (@SearchDate DATE)
AS
BEGIN
    SELECT E.EventName, A.ArtistName
    FROM Venue.Events E
    JOIN Venue.EventArtists EA ON E.ID = EA.EventsID
    JOIN Venue.Artists A ON EA.ArtistsID = A.ID
    WHERE E.EventDate = @SearchDate;
END;

CREATE PROCEDURE GetManagersByArtistName (@SearchArtistName VARCHAR(255))
AS
BEGIN
    SELECT BM.*, EO.*
    FROM Venue.Artists A
    JOIN Venue.BookingManager BM ON A.BookingManagerID = BM.ID
    JOIN Venue.EventOrganizer EO ON A.EventOrganizerID = EO.ID
    WHERE A.ArtistName = @SearchArtistName;
END;

CREATE PROCEDURE GetRiderRequestsByArtistName(@SearchArtistName VARCHAR(255))
AS
BEGIN
    SELECT RR.*
    FROM Venue.Artists A
    JOIN Venue.ArtistsRiderRequests ARR ON A.ID = ARR.ArtistsID
    JOIN Venue.RiderRequests RR ON ARR.RiderRequestsID = RR.ID
    WHERE A.ArtistName = @SearchArtistName;
END;

CREATE PROCEDURE GetArtistsAndRiderRequestsByEventName (@SearchEventName VARCHAR(255))
AS
BEGIN
    SELECT A.ArtistName, RR.*
    FROM Venue.Events E
    JOIN Venue.EventArtists EA ON E.ID = EA.EventsID
    JOIN Venue.Artists A ON EA.ArtistsID = A.ID
    JOIN Venue.ArtistsRiderRequests ARR ON A.ID = ARR.ArtistsID
    JOIN Venue.RiderRequests RR ON ARR.RiderRequestsID = RR.ID
    WHERE E.EventName = @SearchEventName;
END;

CREATE TABLE [Venue].[History] (
    [ID] INT PRIMARY KEY IDENTITY(1,1),
    [TableName] VARCHAR(255),
    [RecordID] INT,
    [OperationType] VARCHAR(10),
    [UpdatedColumns] VARCHAR(MAX),
    [Timestamp] DATETIME
);

CREATE TRIGGER UpdateHistory
ON [Venue].[Artists]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Venue].[History] (TableName, RecordID, OperationType, UpdatedColumns, Timestamp)
    SELECT 'Artists', ID, 'UPDATE', 
           (SELECT TOP 1 [ArtistName] FROM INSERTED) + ' updated',
           GETDATE()
    FROM INSERTED;
END;

CREATE TRIGGER tr_DeleteHistory
ON [Venue].[Artists]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Venue].[History] (TableName, RecordID, OperationType, UpdatedColumns, Timestamp)
    SELECT 'Artists', ID, 'DELETE', 'Record deleted', GETDATE()
    FROM DELETED;
END;

CREATE LOGIN VenueOwner WITH PASSWORD = 'abc@123456';

CREATE USER VenueOwner FOR LOGIN VenueOwner;

GRANT SELECT, INSERT, UPDATE, DELETE ON [Venue].[Artists] TO VenueOwner;
GRANT SELECT, INSERT, UPDATE, DELETE ON [Venue].[EventOrganizer] TO VenueOwner;
GRANT SELECT, INSERT, UPDATE, DELETE ON [Venue].[BookingManager] TO VenueOwner;
GRANT SELECT, INSERT, UPDATE, DELETE ON [Venue].[Events] TO VenueOwner;
GRANT SELECT, INSERT, UPDATE, DELETE ON [Venue].[RiderRequests] TO VenueOwner;
GRANT SELECT, INSERT, UPDATE, DELETE ON [Venue].[ArtistsRiderRequests] TO VenueOwner;

GRANT EXECUTE ON GetEventsAndArtistsByDate TO VenueOwner;
GRANT EXECUTE ON GetManagersByArtistName TO VenueOwner;
GRANT EXECUTE ON GetArtistsAndRiderRequestsByEventName TO VenueOwner;
GRANT EXECUTE ON GetRiderRequestsByEventName TO VenueOwner;
GRANT EXECUTE ON GetRiderRequestsByArtistName TO VenueOwner;