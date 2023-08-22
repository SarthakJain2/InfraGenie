﻿CREATE TABLE [dbo].[Document]
(
	[Id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
	[TenantId] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [FKEY_Document_ProgramId_Program_Id] FOREIGN KEY REFERENCES [Tenant]([Id]),
	[LinkedId] UNIQUEIDENTIFIER NOT NULL,
	[LinkType] VARCHAR(15) NOT NULL,
	[Location] NVARCHAR(MAX) NOT NULL
)