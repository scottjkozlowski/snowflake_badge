-- This is your Cortex Project.
-----------------------------------------------------------
-- SETUP
-----------------------------------------------------------
use role SYSADMIN;
use warehouse ML_WH;
use database CAMILLAS_DB;
use schema CLASSIFICATION;

-- Inspect the first 10 rows of your training data. This is the data we'll
-- use to create your model.
select * from TRAIN_PLAYER_POSITION limit 10;

-- Inspect the first 10 rows of your prediction data. This is the data the model
-- will use to generate predictions.
select * from UNCLASSIFIED_PLAYER_POSITIONS limit 10;

-----------------------------------------------------------
-- CREATE PREDICTIONS
-----------------------------------------------------------
-- Create your model.
CREATE OR REPLACE SNOWFLAKE.ML.CLASSIFICATION player_position_classification(
    INPUT_DATA => SYSTEM$REFERENCE('TABLE', 'TRAIN_PLAYER_POSITION'),
    TARGET_COLNAME => 'POSITION_CODE',
    CONFIG_OBJECT => { 'ON_ERROR': 'SKIP' }
);

-- Inspect your logs to ensure training completed successfully. 
CALL player_position_classification!SHOW_TRAINING_LOGS();

-- Generate predictions as new columns in to your prediction table.
CREATE TABLE my_player_pos_code_classifs AS SELECT
    *, 
    player_position_classification!PREDICT(
        OBJECT_CONSTRUCT(*),
        -- This option alows the prediction process to complete even if individual rows must be skipped.
        {'ON_ERROR': 'SKIP'}
    ) as predictions
from UNCLASSIFIED_PLAYER_POSITIONS;

-- View your predictions.
SELECT * FROM my_player_pos_code_classifs;

-- Parse the prediction results into separate columns. 
-- Note: This is a just an example. Be sure to update this to reflect 
-- the classes in your dataset.
SELECT * EXCLUDE predictions,
        predictions:class AS class,
        round(predictions['probability'][class], 3) as probability
FROM my_player_pos_code_classifs;

-----------------------------------------------------------
-- INSPECT RESULTS
-----------------------------------------------------------

-- Inspect your model's evaluation metrics.
CALL player_position_classification!SHOW_EVALUATION_METRICS();
CALL player_position_classification!SHOW_GLOBAL_EVALUATION_METRICS();
CALL player_position_classification!SHOW_CONFUSION_MATRIX();

-- Inspect the relative importance of your features, including auto-generated features.  
CALL player_position_classification!SHOW_FEATURE_IMPORTANCE();
