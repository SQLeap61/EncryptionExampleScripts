--************************************************************************************************************
--  Section two of presentation    Transparent Data Encryption
--************************************************************************************************************
--
--  Drop Database [EncryptionTDE]
--
Create Database EncryptionTDE

--  Setup some data

select * 
  into EncryptionTDE.dbo.Customer
  from [EncryptionTest].[dbo].[Customer]

--************************************************************************************************************
--             Create the certificate
--************************************************************************************************************
--
-- Drop Certificate CertificateTDEDatabaseEncryption2


CREATE CERTIFICATE CertificateTDEDatabaseEncryption2
WITH SUBJECT='Cert for TDE DB Encryption' ,
EXPIRY_DATE = '20341114';
GO


--*************************************************************************************************************
--                    Backup that certificate
--*************************************************************************************************************
--
--  Create a directory c:\storedcerts

BACKUP CERTIFICATE CertificateTDEDatabaseEncryption2
   TO FILE = 'c:\storedcerts\CertificateTDEDatabaseEncryption2b.BAK'  
WITH PRIVATE KEY 
( FILE = 'c:\storedcerts\CertificateTDEDatabaseEncryption2b.PKK' ,   
  ENCRYPTION BY PASSWORD 
      = '>Save This P@$$word in y0ur Password VaulT') ;  
GO 


--************************************************************************************************************
--  Encrypt the database
--************************************************************************************************************
USE EncryptionTDE 
GO

CREATE DATABASE ENCRYPTION KEY
  WITH ALGORITHM = AES_256
 ENCRYPTION BY SERVER CERTIFICATE CertificateTDEDatabaseEncryption2;
GO

ALTER DATABASE EncryptionTDE 
SET ENCRYPTION ON;
GO


