--****************************************************************************
--**                 Examples of a SQL Backup that uses Encryption      
--****************************************************************************
--
--  note you may have to change your filename directories if they dont exist
--
--****************************************************************************



Backup Database [EncryptionTest2] 
	to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\EncryptionTest2_2024_10_17_141512_0000000.bak'				
	WITH COMPRESSION, 
		 ENCRYPTION 	
			(ALGORITHM          = aes_256, 
			 SERVER CERTIFICATE = EncryptionCertificateBackup2 )--
