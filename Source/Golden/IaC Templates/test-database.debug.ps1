invoke-sqlcmd `
    -ServerInstance 'sqlserver-erwinaz-dev-001.privatelink.database.windows.net' `
    -Database 'sql-erwinaz-mdb-dev-001'`
    -Username 'erwinazadmin' `
    -Password 'erwin@123' `
    -Query 'Select * from Information_schema.tables'

