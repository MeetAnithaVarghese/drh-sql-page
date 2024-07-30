
# Surveilr DRH Data Transformation

## Overview

  The `drh-deidentification.sql` performs the deidentification of the columns in the studydata converted tables.The `drh-sqlpage-views.sql` creates the database views which shall be used in sqlpage preview.The `orchestrate-drh-vv.sql` shall perform the verification and validation on the study data tables.
## Getting Started

1. **Prepare the Study Files:**

   - Prepare the study files in the format mentioned in [‘Getting Started’](https://drh.diabetestechnology.org/getting-started/) on the DRH website.
   - Ensure the study files are as mentioned in the above link.

2. **Download Surveilr:**

   - Follow the installation instructions at [Surveilr Installation Guide](https://docs.opsfolio.com/surveilr/how-to/installation-guide).
   - Move the downloaded software to the study files folder.
   - Example: 'DRH_STUDY_DATA' folder containing a sub folder 'STUDY1'.Move the downloaded software to the 'DRH_STUDY_DATA'

3. **Data conversion steps**
  
  - Open the command prompt and change to the directory containing the study CSV files.
  - Command: `çd <folderpath>`
  - Example: `cd D:/workfiles/DRH_STUDY_DATA`

   **Verify the tool version**
   - Input the command `surveilr --version`.
   - If the tool is available, it will show the version number.

  3.1 **Ingest the files**

   **Command:**
   - Command: `surveilr ingest files -r <foldername>/`
   - Example: `surveilr ingest files -r STUDY1/`

    **Note**: Here 'STUDY1' is the folder name containing a specific study csv files.

  3.2 **Transform the files**

    **Command:**
    - Command: `surveilr transform csv`    

  3.3 **Verify the transformed data**

    - Type the command `ls` to list the files.
    - You can also check the folder directly to see the transformed database.

4. **De-Identification**

   **Note:** 
   - The De-identification is an optional step and DRH doesnt have any PHI columns in any CSV in the current situation.
   - If De-identification is to be performed ,please refer the steps below.
   - The Sql script will require changes from time to time.
    
   **Steps for De-identification:**

   4.1 Download the SQL file
   ```bash
    $ curl -L -o De-Identification.sql https://raw.githubusercontent.com/MeetAnithaVarghese/drh-sql-page/main/drh-deidentification.sql
   ```

   4.2 Execute the de-identification process
   surveilr anonymize --sql De-Identification.sql 

5. **Apply the study database views  to preview the SQLPAGE**

   ```bash
   curl -L https://raw.githubusercontent.com/MeetAnithaVarghese/drh-sql-page/stateless-drh-surveilr.sql | sqlite3 resource-surveillance.sqlite.db   
   ```

6. **Preview content with SQLPage (requires `deno` v1.40 or above):**

   ```bash
   deno run https://raw.githubusercontent.com/MeetAnithaVarghese/drh-sql-page/ux.sql.ts | sqlite3 resource-surveillance.sqlite.db
   surveilr sqlpage --port 9000   ```

   Then, open a browser and navigate to [http://localhost:9000/drh/index.sql](http://localhost:9000/drh/index.sql).