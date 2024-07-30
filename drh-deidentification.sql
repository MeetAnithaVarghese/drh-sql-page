INSERT INTO orchestration_nature (
    orchestration_nature_id, 
    nature, 
    elaboration, 
    created_by, 
    updated_at, 
    updated_by, 
    deleted_at, 
    deleted_by, 
    activity_log
)
VALUES (
    'ORCNATDEID-' || hex(randomblob(16)),
    'De-identification',
    NULL,  -- elaboration
    NULL,  -- created_by
    NULL,  -- updated_at
    NULL,  -- updated_by
    NULL,  -- deleted_at
    NULL,  -- deleted_by
    NULL
);

-- Retrieve the device ID
WITH device_info AS (
    SELECT device_id FROM device LIMIT 1
),
orch_nature_info AS (
    SELECT orchestration_nature_id FROM orchestration_nature WHERE nature = 'De-identification' LIMIT 1
)
INSERT INTO orchestration_session (orchestration_session_id, device_id, orchestration_nature_id, version, args_json, diagnostics_json, diagnostics_md)
SELECT
    'ORCSESSIONDEID-' || hex(randomblob(16)) AS orchestration_session_id,
    d.device_id,
    o.orchestration_nature_id,
    '1.0',
    '{"parameters": "de-identification"}',
    '{"status": "started"}',
    'Started de-identification process'
FROM device_info d, orch_nature_info o;


-- Retrieve the new session ID
WITH session_info AS (
    SELECT orchestration_session_id FROM orchestration_session LIMIT 1
)
INSERT INTO orchestration_session_entry (orchestration_session_entry_id, session_id, ingest_src, ingest_table_name, elaboration)
SELECT
    'ORCSESENDEID-' || hex(randomblob(16)) AS orchestration_session_entry_id,
    orchestration_session_id,
    'de-identification',
    NULL,
    '{"description": "Processing de-identification"}'
FROM session_info;

-- Begin a transaction
BEGIN;

-- Attempt to de-identify data
UPDATE uniform_resource_investigator
SET email = anonymize_email(email);

-- Check for errors and log them
INSERT INTO orchestration_session_exec (orchestration_session_exec_id, exec_nature, session_id, exec_code, exec_status, input_text, output_text, exec_error_text, narrative_md)
SELECT
    'ORCHSESSEXECDEID-' || hex(randomblob(16)),
    'De-identification',
    (SELECT orchestration_session_id FROM orchestration_session LIMIT 1),
    'anonymize uniform_resource_investigator executed',
    CASE 
        WHEN (SELECT changes() = 0) THEN 1 
        ELSE 0 
    END,
    'email from uniform_resource_investigator',
    'De-identification completed',
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated' 
        ELSE NULL 
    END,
    'username in email is masked'
;

UPDATE uniform_resource_author
SET email = anonymize_email(email);

-- Check for errors and log them
INSERT INTO orchestration_session_exec (orchestration_session_exec_id, exec_nature, session_id, exec_code, exec_status, input_text, output_text, exec_error_text, narrative_md)
SELECT
    'ORCHSESSEXECDEID-' || hex(randomblob(16)),
    'De-identification',
    (SELECT orchestration_session_id FROM orchestration_session LIMIT 1),
    'anonymize uniform_resource_author executed',
    CASE 
        WHEN (SELECT changes() = 0) THEN 1 
        ELSE 0 
    END,
    'email from uniform_resource_author',
    'De-identification completed',
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated' 
        ELSE NULL 
    END,
    'username in email is masked'
;

UPDATE uniform_resource_participant
SET age = generalize_age(CAST(age AS INTEGER));

-- Check for errors and log them
INSERT INTO orchestration_session_exec (orchestration_session_exec_id, exec_nature, session_id, exec_code, exec_status, input_text, output_text, exec_error_text, narrative_md)
SELECT
    'ORCHSESSEXECDEID-' || hex(randomblob(16)),
    'De-identification',
    (SELECT orchestration_session_id FROM orchestration_session LIMIT 1),
    'Anonymize uniform_resource_participant executed',
    CASE 
        WHEN (SELECT changes() = 0) THEN 1 
        ELSE 0 
    END,
    'AGE in uniform_resource_participant',
    'De-identification completed',
    CASE 
        WHEN (SELECT changes() = 0) THEN 'No rows updated' 
        ELSE NULL 
    END,
    'Age converted to age range'
;

-- Commit the transaction
COMMIT;

-- Handle exceptions if any in an external mechanism(not possible through SQLITE)

-- Optionally, you can handle the rollback and error insert in a separate block
-- For example:
-- ROLLBACK;
-- INSERT INTO orchestration_session_exec (orchestration_session_exec_id, exec_nature, session_id, exec_code, exec_status, input_text, output_text, exec_error_text, narrative_md)
-- VALUES (
--     'orc-exec-id-' || hex(randomblob(16)),
--     'De-identification',
--     (SELECT orchestration_session_id FROM orchestration_session LIMIT 1),
--     'UPDATE commands executed',
--     1,
--     'Data from uniform_resource_investigator, uniform_resource_author, and uniform_resource_participant tables',
--     'Error occurred during de-identification',
--     'Detailed error message here',
--     'Error during update'
-- );
