INSTALL iceberg;
        
LOAD iceberg;
  
CREATE SECRET iceberg_secret (
    TYPE ICEBERG,
    CLIENT_ID 'root',
    CLIENT_SECRET 'secret',
    OAUTH2_SERVER_URI 'http://polaris:8181/api/catalog/v1/oauth/tokens',
    OAUTH2_SCOPE 'PRINCIPAL_ROLE:ALL',
    OAUTH2_GRANT_TYPE 'client_credentials'
);
       
ATTACH 'polariscatalog' AS iceberg_catalog (
   TYPE iceberg,
   SECRET iceberg_secret,
   ENDPOINT 'http://polaris:8181/api/catalog'
);
       
USE iceberg_catalog.db;
    
SET s3_endpoint='minio:9000';
SET s3_use_ssl='false';
SET s3_access_key_id='admin' ;
SET s3_secret_access_key='password';
SET s3_region='dummy-region';
SET s3_url_style='path';