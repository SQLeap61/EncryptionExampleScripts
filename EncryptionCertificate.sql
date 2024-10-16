
--****************************************************************************
--**                 Encryption Strategys for SQL Server                           
--****************************************************************************
--  The following scripts go with a presentation and demonstrates the 
--  setup and creation of ,master keys, certificates, encrypted backups, 
--  Transparen Data Encryption (TDE Database) and encrypting columns of data.   
--  These scripts are for training purposes only.   
--  Have a wonderful day
--  Eric Peterson
--
--****************************************************************************
--**                 Create a master Key                                    
--****************************************************************************
--
--	DROP MASTER KEY  -- Execute this the second time demonstrating the scripts
--

USE master
GO
 
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
BEGIN
 PRINT 'Creating Database Master Key'
 CREATE MASTER KEY 
  ENCRYPTION BY PASSWORD = 'T0t0, I Dont Th!nk WE @re in Kansas anymore!';
END
	ELSE
	  PRINT 'Master Key Already Exists'




	  
--****************************************************************************
--                  Create a certificate(s)
--****************************************************************************
--
--  Drop certificate EncryptionCertificateSystem
--  Drop certificate EncryptionCertificateSystem1
--  Drop certificate EncryptionCertificateBackup1 
--  Drop certificate EncryptionCertificateBackup2 
--
CREATE CERTIFICATE EncryptionCertificateSystem   
  ENCRYPTION BY PASSWORD = 't0 Be or ! TO BE, That 1S the Question.'
  WITH SUBJECT = 'SQL Server System Encryption Certificate'   

--   SELECT * from sys.certificates   -- Note the expiration date
   
CREATE CERTIFICATE CertificateTDEDatabaseEncryption
	WITH SUBJECT='Certificate for TDE Database Encryption' ,
	EXPIRY_DATE = '20341114';
GO
--   

CREATE CERTIFICATE EncryptionCertificateBackup1 
  ENCRYPTION BY PASSWORD = 'A R@nd0m1y G3nerated Pa$$w0rd'
	WITH SUBJECT = 'SQL Server Backup Encryption Certificate',   
	EXPIRY_DATE = '20311114';


CREATE CERTIFICATE EncryptionCertificateBackup2 
 -- ENCRYPTION BY PASSWORD = 'No Password on this one'
	WITH SUBJECT = 'SQL Server Backup Encryption Certificate2',   
	EXPIRY_DATE = '20251114';

--****************************************************************************
--                    Backup that certificate
--****************************************************************************
--
--  Create a directory c:\storedcerts

BACKUP CERTIFICATE EncryptionCertificateSystem 
   TO FILE = 'c:\storedcerts\System1EncCert.BAK'  
WITH PRIVATE KEY 
( FILE = 'c:\storedcerts\System1EncCert.PKK' ,   
  ENCRYPTION BY PASSWORD 
      = '>Save This P@$$word in y0ur Password VaulT') ;  
GO 

--BACKUP CERTIFICATE EncryptionCertificateBackup1			
--TO FILE = 'c:\storedcerts\EncryptionCertificateBackup1.BAK'			
--WITH PRIVATE KEY (	DECRYPTION BY PASSWORD = 'A R@nd0m1y G3nerated Pa$$w0rd' ,
--					FILE = 'c:\storedcerts\EncryptionCertificateBackup1.PKK' ,     
--					ENCRYPTION BY PASSWORD = '>Save This P@$$word in y0ur Password VaulT' 	);  

BACKUP CERTIFICATE EncryptionCertificateBackup2 
TO FILE = 'c:\storedcerts\EncryptionCertificateBackup2_20241015.BAK'
WITH PRIVATE KEY
(    FILE = 'c:\storedcerts\EncryptionCertificateBackup2_20241015.PKK',
     ENCRYPTION BY PASSWORD = '>@nother P@$$word to $ave in y0ur Password VaulT');
---DECRYPTION BY PASSWORD 'A R@nd0m1y G3nerated Pa$$w0rd' );  

--BACKUP CERTIFICATE EncryptionCertificateSystem 
--TO FILE = 'c:\storedcerts\EncryptionCertificateSystem.BAK'
--WITH PRIVATE KEY
--(   FILE = 'c:\storedcerts\EncryptionCertificateSystem.PKK',
--    ENCRYPTION BY PASSWORD = '>Save This P@$$word in y0ur Password VaulT'
--);

BACKUP CERTIFICATE CertificateTDEDatabaseEncryption 
TO FILE = 'c:\storedcerts\CertificateTDEDatabaseEncryption.BAK'
WITH PRIVATE KEY
(   FILE = 'c:\storedcerts\CertificateTDEDatabaseEncryption.PKK',
    ENCRYPTION BY PASSWORD = '>Save This P@$$word in y0ur Password VaulT T00'
);
GO
-- *****************************************************************************
-- If your system fails or you need to restore the backup to another system
-- you need to create(restore) the backup encryption certificate first
--
-- *****************************************************************************
-- ****************  Creating a CERTIFICATE FROM A BACKUP   ********************
-- *****************************************************************************
--
--  Drop certificate EncryptionCertificateBackup2 

CREATE CERTIFICATE EncryptionCertificateBackup2 
 FROM FILE = 'c:\storedcerts\EncryptionCertificateBackup2_20241015.bak' 
 WITH PRIVATE KEY (FILE = 'c:\storedcerts\EncryptionCertificateBackup2_20241015.PKK' ,
					DECRYPTION BY PASSWORD 
					      = '>@nother P@$$word to $ave in y0ur Password VaulT');

