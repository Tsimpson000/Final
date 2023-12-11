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

