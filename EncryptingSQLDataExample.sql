--************************************************************************************************************
--  Encrypt the database Data
--************************************************************************************************************


CREATE CERTIFICATE SSNCertWithPW   
   ENCRYPTION BY PASSWORD = 'CertPa$$word12345!!' -- In production the DBA will create this with an randomly generated PW.  The password will be locked in the password vault.   
   WITH SUBJECT = 'SSN Encryption Certificate w/PW' 
GO  


CREATE SYMMETRIC KEY SSNSymetric_keyWithPW 
WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE SSNCertWithPW;
GO



CREATE TABLE dbo.PatientsUnencrypted 
	(PatientId		INT IDENTITY(1, 1),
    SSN				NVARCHAR(11) COLLATE Latin1_General_BIN2,
					--ENCRYPTED WITH (ENCRYPTION_TYPE = DETERMINISTIC,
     --                   ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256',
     --                   COLUMN_ENCRYPTION_KEY = AETestColKey) NOT NULL,
    FirstName		NVARCHAR(50) NULL,
    LastName		NVARCHAR(50) NULL,
    MiddleName		NVARCHAR(50) NULL,
    StreetAddress	NVARCHAR(50) NULL,
    City			NVARCHAR(50) NULL,
    ZipCode			INT NULL,
    State			NVARCHAR(50) NULL,
    BirthDate		DATETIME2,
        --ENCRYPTED WITH (ENCRYPTION_TYPE = RANDOMIZED,
        --                ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256',
        --                COLUMN_ENCRYPTION_KEY = AETestColKey) NOT NULL
        PRIMARY KEY CLUSTERED (PatientId ASC) ON [PRIMARY]);


--****************************  View Data *************************************
select * from dbo.PatientsUnencrypted 

--****************************  View Certificates *************************************

SELECT name CertName, 
    certificate_id CertID, 
    pvt_key_encryption_type_desc EncryptType, 
    issuer_name Issuer
FROM sys.certificates;

SELECT name KeyName, 
    symmetric_key_id KeyID, 
    key_length KeyLength, 
    algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;

--****************************   Example w PW *********************************
--   Drop table TestPatient
---  Create test encryption table

Select * 
into TestPatient
from  dbo.PatientsUnencrypted 

ALTER TABLE dbo.TestPatient 
ADD SSNEncrypted VARBINARY(MAX)

SELECT * FROM dbo.TestPatient 

OPEN SYMMETRIC KEY SSNSymetric_keyWithPW
        DECRYPTION BY CERTIFICATE SSNCertWithPW
		WITH PASSWORD = 'CertPa$$word12345!!'

UPDATE dbo.TestPatient
        SET SSNEncrypted = EncryptByKey (Key_GUID('SSNSymetric_keyWithPW'), SSN)
        FROM dbo.TestPatient
        GO

CLOSE SYMMETRIC KEY [SSNSymetric_keyWithPW]
            GO

SELECT patientId, LastName, FirstName, SSN, SSNEncrypted 
FROM dbo.TestPatient

ALTER TABLE dbo.TestPatient
DROP COLUMN SSN


--   Select * from TestPaitent

OPEN SYMMETRIC KEY SSNSymetric_keyWithPW
        DECRYPTION BY CERTIFICATE SSNCertWithPW
		WITH PASSWORD = 'CertPa$$word12345!!'


SELECT	patientId, LastName, FirstName,  SSNEncrypted, 
		CONVERT(NVARCHAR, DECRYPTBYKEY(SSNEncrypted)) AS 'SSN'
FROM dbo.TestPatient

CLOSE SYMMETRIC KEY SSNSymetric_keyWithPW
            GO

--************************************************   Example 2   *********************************************
--  drop table TestPatient
--  Drop Table TestPatientPW


SELECT * 
 INTO TestPatient
 FROM dbo.PatientsUnencrypted

SELECT * 
 INTO TestPatientPW
 FROM dbo.PatientsUnencrypted


ALTER TABLE dbo.TestPatient
ADD SSNEncrypted VARBINARY(MAX)

SELECT * FROM dbo.TestPatient

OPEN SYMMETRIC KEY SSNSymetric_key   ---WithPW
        DECRYPTION BY CERTIFICATE SSNCertWithPW

UPDATE dbo.TestPatient
        SET SSNEncrypted = EncryptByKey (Key_GUID('SSNSymetric_key'), SSN)
        FROM dbo.TestPatient
        GO

CLOSE SYMMETRIC KEY [SSNSymetric_key]
            GO

SELECT patientId, LastName, FirstName, SSN, SSNEncrypted 
FROM dbo.TestPatient

ALTER TABLE dbo.TestPatient
DROP COLUMN SSN


OPEN SYMMETRIC KEY SSNSymetric_key
        DECRYPTION BY CERTIFICATE SSNCertificate

SELECT	patientId, LastName, FirstName,  SSNEncrypted, 
		CONVERT(NVARCHAR, DECRYPTBYKEY(SSNEncrypted)) AS 'SSN'
FROM dbo.TestPatient

CLOSE SYMMETRIC KEY [SSNSymetric_key]
            GO


