Scaffold-DbContext -Connection Name=ConnectionStrings:PrimaryDatabase -Provider Microsoft.EntityFrameworkCore.SqlServer -OutputDir . -Force
Scaffold-DbContext -Connection "Data Source=(localdb)\ProjectModels;Initial Catalog=EIL;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Connect Timeout=60;Encrypt=False;TrustServerCertificate=False" -Provider Microsoft.EntityFrameworkCore.SqlServer -OutputDir . -Force


Scaffold-DbContext -Connection "Data Source=SSTDEVLT001;Initial Catalog=Genie;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Connect Timeout=60;Encrypt=False;TrustServerCertificate=False" -Provider Microsoft.EntityFrameworkCore.SqlServer -OutputDir . -Force