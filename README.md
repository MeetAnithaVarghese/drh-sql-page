
# Surveilr DRH Data Transformation

## Overview

  The `drh-deidentification.sql` performs the deidentification of the columns in the data converted tables.The `drh-sqlpage-views.sql` craetes the database views which shall be used in sqlpage preview.The `orchestrate-drh-vv.sql` shall perform the verification and validation on the tables.
## Getting Started

1. **Prepare the Study Files:**

   - Prepare the study files in the format mentioned in [‘Getting Started’](https://drh.diabetestechnology.org/getting-started/) on the DRH website.
   - Ensure the study files are as mentioned in the above link.

2. **Download Surveilr:**

   - Follow the installation instructions at [Surveilr Installation Guide](https://docs.opsfolio.com/surveilr/how-to/installation-guide).
   - Move the downloaded software to the study files folder.

3. **Data conversion steps**

   3.1 **Provide a valid name for the target database and initialize it.**

   **Note:**
   - Expected naming format: `DRH.<studyname>.sqlite.db`
   - Study name must be in small letters with no space in between

   **Command:**
   - Command: `surveilr admin init -d <databasename>`
   - Example: `surveilr admin init -d DRH.glucostudy1.sqlite.db`

   In the above example, the database name is `DRH.glucostudy1.sqlite.db`.


   3.2 **Ingest the files**

   **Command:**
   - Command: `surveilr ingest files -d <databasename>`
   - Example: `surveilr ingest files -d DRH.glucostudy1.sqlite.db`



3.3 **Transform the files**

    **Command:**
    - Command: `surveilr transform -d <databasename> csv`
    - Example: `surveilr transform -d DRH.glucostudy1.sqlite.db csv`

3.4 **Verify the transformed data**

    - Type the command `ls` to list the files.

    - You can also check the folder directly to see the transformed database.


4. **De-Identification**

   **Note:** 
   - The De-identification is an optional step and DRH doesnt have any PHI columns in any CSV in the current situation.
   - If De-identification is to be performed ,please refer the steps below.
   - The Sql script will require changes from time to time.


   **Steps for De-identification:**


   **Command:**
   - Command: `surveilr anonymize --sql <sqlfilename> -d <databasename>`
   - Example: `surveilr anonymize --sql De-Identification.sql -d DRH.glucostudy1.sqlite.db`



5. **Apply the study database views  to preview the SQLPAGE**

   ```bash
   curl -L https://raw.githubusercontent.com/MeetAnithaVarghese/drh-sql-page/stateless-drh-surveilr.sql | sqlite3 resource-surveillance.sqlite.db   
   ```

6. **Preview content with SQLPage (requires `deno` v1.40 or above):**

   ```bash
   deno run https://raw.githubusercontent.com/MeetAnithaVarghese/drh-sql-page/ux.sql.ts | sqlite3 resource-surveillance.sqlite.db
   surveilr sqlpage --port 9000
   ```

   Then, open a browser and navigate to [http://localhost:9000/drh/index.sql](http://localhost:9000/drh/index.sql).