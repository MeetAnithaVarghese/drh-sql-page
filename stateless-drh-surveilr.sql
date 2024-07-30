DROP View IF EXISTS device_data;
Create view  device_data As
select device_id ,name ,created_at from device d ;


DROP View IF EXISTS number_of_files_converted;
Create view  number_of_files_converted
As
select count(*) from uniform_resource where content_digest != '-' ;;

DROP View IF EXISTS converted_files_list;
Create View  converted_files_list As
select file_basename from ur_ingest_session_fs_path_entry where file_extn !='sql' and file_extn !='db';



DROP View IF EXISTS converted_table_list ;
Create View  converted_table_list As
SELECT tbl_name As 'table_name'
FROM sqlite_master 
WHERE type = 'table' 
  AND name LIKE 'uniform_resource%' 
  AND name != 'uniform_resource_transform' 
  And name != 'uniform_resource';
 
 
DROP View IF EXISTS uniform_resource_study_nature ;
Create View  uniform_resource_study_nature As 
SELECT 
    json_extract(elaboration , '$.uniform_resource_id') AS uniform_resource_id,
    json_extract(elaboration, '$.new_table') AS new_table,
    json_extract(elaboration, '$.from_nature') AS from_nature,
    json_extract(elaboration, '$.to_nature') AS to_nature  
FROM uniform_resource_study;


DROP View IF EXISTS uniform_resource_study_cached_data ;
Create View  uniform_resource_study_cached_data As 
SELECT study_id, study_name, 'start_date', end_date, treatment_modalities, funding_source, nct_number, study_description FROM uniform_resource_study limit 10;

DROP View IF EXISTS uniform_resource_cgm_file_cached_data ;
Create View  uniform_resource_cgm_file_cached_data As 
SELECT metadata_id, devicename, device_id, source_platform, patient_id, file_name, 'file_format', file_upload_date, data_start_date, data_end_date, study_id FROM uniform_resource_cgm_file_metadata limit 10;




