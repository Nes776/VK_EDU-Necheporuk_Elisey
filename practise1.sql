CREATE SCHEMA bronze.q16;

CREATE TABLE bronze.q16.raw_part AS
SELECT * FROM tpch.sf1.part;

CREATE TABLE bronze.q16.raw_partsupp AS
SELECT * FROM tpch.sf1.partsupp;

CREATE TABLE bronze.q16.raw_supplier AS
SELECT * FROM tpch.sf1.supplier;

SELECT 'part' AS t, count(*) FROM bronze.q16.raw_part
UNION ALL SELECT 'partsupp', count(*) FROM bronze.q16.raw_partsupp
UNION ALL SELECT 'supplier', count(*) FROM bronze.q16.raw_supplier;


CREATE SCHEMA silver.q16;

CREATE TABLE silver.q16.clean_supplier AS
SELECT suppkey
FROM bronze.q16.raw_supplier
WHERE comment NOT LIKE '%Customer%Complaints%';
CREATE TABLE silver.q16.enriched_partsupp AS
SELECT
    p.partkey,
    p.brand,
    p.type,
    p.size,
    ps.suppkey
FROM bronze.q16.raw_part p
JOIN bronze.q16.raw_partsupp ps ON p.partkey = ps.partkey
JOIN silver.q16.clean_supplier cs ON ps.suppkey = cs.suppkey
WHERE p.brand <> 'Brand#45'
  AND p.type NOT LIKE 'MEDIUM POLISHED%'
  AND p.size IN (49, 14, 23, 45, 19, 3, 36, 9);

SELECT count(*) FROM silver.q16.enriched_partsupp;


CREATE SCHEMA gold.q16;

CREATE TABLE gold.q16.supplier_count AS
SELECT
    brand,
    type,
    size,
    count(DISTINCT suppkey) AS supplier_cnt
FROM silver.q16.enriched_partsupp
GROUP BY brand, type, size;

SELECT * FROM gold.q16.supplier_count
ORDER BY supplier_cnt DESC, brand, type, size
LIMIT 20;

SELECT 'raw_part' AS t, sum(file_size_in_bytes) AS bytes FROM bronze.q16."raw_part$files"
UNION ALL SELECT 'raw_partsupp', sum(file_size_in_bytes) FROM bronze.q16."raw_partsupp$files"
UNION ALL SELECT 'raw_supplier', sum(file_size_in_bytes) FROM bronze.q16."raw_supplier$files"
UNION ALL SELECT 'clean_supplier', sum(file_size_in_bytes) FROM silver.q16."clean_supplier$files"
UNION ALL SELECT 'enriched_partsupp', sum(file_size_in_bytes) FROM silver.q16."enriched_partsupp$files"
UNION ALL SELECT 'supplier_count', sum(file_size_in_bytes) FROM gold.q16."supplier_count$files";

SELECT brand, type, size, count(DISTINCT suppkey) AS supplier_cnt
FROM silver.q16.enriched_partsupp
GROUP BY brand, type, size
ORDER BY supplier_cnt DESC, brand, type, size;
-- GZIP Сжатие


DROP TABLE silver.q16.enriched_partsupp;
DROP TABLE silver.q16.clean_supplier;
DROP TABLE gold.q16.supplier_count;
DROP TABLE bronze.q16.raw_partsupp;
DROP TABLE bronze.q16.raw_part;
DROP TABLE bronze.q16.raw_supplier;


SET SESSION bronze.compression_codec = 'GZIP';

CREATE TABLE bronze.q16.raw_part WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.part;
CREATE TABLE bronze.q16.raw_partsupp WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.partsupp;
CREATE TABLE bronze.q16.raw_supplier WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.supplier;


CREATE TABLE silver.q16.clean_supplier AS
SELECT suppkey FROM bronze.q16.raw_supplier
WHERE comment NOT LIKE '%Customer%Complaints%';

CREATE TABLE silver.q16.enriched_partsupp AS
SELECT p.partkey, p.brand, p.type, p.size, ps.suppkey
FROM bronze.q16.raw_part p
JOIN bronze.q16.raw_partsupp ps ON p.partkey = ps.partkey
JOIN silver.q16.clean_supplier cs ON ps.suppkey = cs.suppkey
WHERE p.brand <> 'Brand#45'
  AND p.type NOT LIKE 'MEDIUM POLISHED%'
  AND p.size IN (49, 14, 23, 45, 19, 3, 36, 9);

CREATE TABLE gold.q16.supplier_count AS
SELECT brand, type, size, count(DISTINCT suppkey) AS supplier_cnt
FROM silver.q16.enriched_partsupp
GROUP BY brand, type, size;

SELECT 'raw_part' AS t, sum(file_size_in_bytes) AS bytes FROM bronze.q16."raw_part$files"
UNION ALL SELECT 'raw_partsupp', sum(file_size_in_bytes) FROM bronze.q16."raw_partsupp$files"
UNION ALL SELECT 'raw_supplier', sum(file_size_in_bytes) FROM bronze.q16."raw_supplier$files";

SELECT brand, type, size, count(DISTINCT suppkey) AS supplier_cnt
FROM silver.q16.enriched_partsupp
GROUP BY brand, type, size
ORDER BY supplier_cnt DESC, brand, type, size;

--- ZSTD Сжатие

DROP TABLE silver.q16.enriched_partsupp;
DROP TABLE silver.q16.clean_supplier;
DROP TABLE gold.q16.supplier_count;
DROP TABLE bronze.q16.raw_partsupp;
DROP TABLE bronze.q16.raw_part;
DROP TABLE bronze.q16.raw_supplier;

SET SESSION bronze.compression_codec = 'ZSTD';

CREATE TABLE bronze.q16.raw_part WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.part;
CREATE TABLE bronze.q16.raw_partsupp WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.partsupp;
CREATE TABLE bronze.q16.raw_supplier WITH (format = 'PARQUET') AS SELECT * FROM tpch.sf1.supplier;


CREATE TABLE silver.q16.clean_supplier AS
SELECT suppkey FROM bronze.q16.raw_supplier
WHERE comment NOT LIKE '%Customer%Complaints%';

CREATE TABLE silver.q16.enriched_partsupp AS
SELECT p.partkey, p.brand, p.type, p.size, ps.suppkey
FROM bronze.q16.raw_part p
JOIN bronze.q16.raw_partsupp ps ON p.partkey = ps.partkey
JOIN silver.q16.clean_supplier cs ON ps.suppkey = cs.suppkey
WHERE p.brand <> 'Brand#45'
  AND p.type NOT LIKE 'MEDIUM POLISHED%'
  AND p.size IN (49, 14, 23, 45, 19, 3, 36, 9);

CREATE TABLE gold.q16.supplier_count AS
SELECT brand, type, size, count(DISTINCT suppkey) AS supplier_cnt
FROM silver.q16.enriched_partsupp
GROUP BY brand, type, size;

SELECT 'raw_part' AS t, sum(file_size_in_bytes) AS bytes FROM bronze.q16."raw_part$files"
UNION ALL SELECT 'raw_partsupp', sum(file_size_in_bytes) FROM bronze.q16."raw_partsupp$files"
UNION ALL SELECT 'raw_supplier', sum(file_size_in_bytes) FROM bronze.q16."raw_supplier$files";

SELECT brand, type, size, count(DISTINCT suppkey) AS supplier_cnt
FROM silver.q16.enriched_partsupp
GROUP BY brand, type, size
ORDER BY supplier_cnt DESC, brand, type, size;