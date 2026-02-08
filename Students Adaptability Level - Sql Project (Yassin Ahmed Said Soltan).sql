-- Creat Database & Tables

CREATE DATABASE StudentAdaptabilityDB;
GO
USE StudentAdaptabilityDB;
GO

CREATE TABLE students (
    student_id INT IDENTITY(1,1) PRIMARY KEY,
    gender VARCHAR(10),
    age VARCHAR(20),
    education_level VARCHAR(50),
    institution_type VARCHAR(50),
    it_student VARCHAR(10),
    location VARCHAR(10),
    load_shedding VARCHAR(10),
    financial_condition VARCHAR(20),
    self_lms VARCHAR(10),
    adaptivity_level VARCHAR(20)
);


CREATE TABLE learning_environment (
    env_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT,
    internet_type VARCHAR(50),
    network_type VARCHAR(50),
    class_duration VARCHAR(20),
    device VARCHAR(50),
    CONSTRAINT fk_students
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
);

-- Students Data

INSERT INTO students (
    gender,
    age,
    education_level,
    institution_type,
    it_student,
    location,
    load_shedding,
    financial_condition,
    self_lms,
    adaptivity_level
)
SELECT
    Gender,
    Age,
    [Education Level],
    [Institution Type],
    [IT Student],
    Location,
    [Load-shedding],
    [Financial Condition],
    [Self Lms],
    [Adaptivity Level]
FROM Excel_Students
ORDER BY (SELECT NULL);

-- learning environment data

WITH ExcelCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM Excel_Students
),
StudentsCTE AS (
    SELECT student_id,
           ROW_NUMBER() OVER (ORDER BY student_id) AS rn
    FROM students
)
INSERT INTO learning_environment (
    student_id,
    internet_type,
    network_type,
    class_duration,
    device
)
SELECT
    s.student_id,
    e.[Internet Type],
    e.[Network Type],
    e.[Class Duration],
    e.Device
FROM ExcelCTE e
INNER JOIN StudentsCTE s
    ON e.rn = s.rn;

    -- Confirm the data

    SELECT COUNT(*) FROM Excel_Students;
SELECT COUNT(*) FROM students;
SELECT COUNT(*) FROM learning_environment;


-- Q1: Write a query to display gender, age, education level, and internet type for all students.

SELECT
    s.gender,
    s.age,
    s.education_level,
    le.internet_type
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id;

-- Q2: Display all students who use Wifi and have Moderate adaptivity level. Show gender, education level, and device.

SELECT
    s.gender,
    s.education_level,
    le.device
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
WHERE le.internet_type = 'Wifi'
  AND s.adaptivity_level = 'Moderate';

  -- Q3: Show all school students who use Mobile Data and have Low adaptivity level. Display gender, age, and network type

  SELECT
    s.gender,
    s.age,
    le.network_type
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
WHERE s.education_level = 'School'
  AND le.internet_type = 'Mobile Data'
  AND s.adaptivity_level = 'Low';

  -- Q4: Display the number of students for each internet type and network type

  SELECT
    le.internet_type,
    le.network_type,
    COUNT(*) AS number_of_students
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
GROUP BY
    le.internet_type,
    le.network_type;

-- Q5: Show education level, device, and number of students. Include only students who have Poor OR Mid financial condition.

SELECT
    s.education_level,
    le.device,
    COUNT(*) AS number_of_students
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
WHERE s.financial_condition IN ('Poor', 'Mid')
GROUP BY
    s.education_level,
    le.device;

-- Q6: Display education level and the average class duration for each education level. Only show education levels where the average class duration is greater than 1 hour

SELECT
    s.education_level,
    AVG(
        CASE
            WHEN le.class_duration = '0-1' THEN 0.5
            WHEN le.class_duration = '1-3' THEN 2
            WHEN le.class_duration = '3-6' THEN 4.5
        END
    ) AS avg_class_duration
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
GROUP BY
    s.education_level
HAVING
    AVG(
        CASE
            WHEN le.class_duration = '0-1' THEN 0.5
            WHEN le.class_duration = '1-3' THEN 2
            WHEN le.class_duration = '3-6' THEN 4.5
        END
    ) > 1;

-- Q7: Display device and the count of students. Only include devices that are used by more than one student.

SELECT
    le.device,
    COUNT(*) AS number_of_students
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
GROUP BY
    le.device
HAVING COUNT(*) > 1;

-- Q8: Write a query using CASE to create a new column called Internet_Quality:
--     • If Internet Type is Wifi and Network Type is 4G, show Good
--     • Otherwise, show Limited
-- Display gender, education level, internet type, network type, and Internet_Quality.

SELECT
    s.gender,
    s.education_level,
    le.internet_type,
    le.network_type,
    CASE
        WHEN le.internet_type = 'Wifi'
         AND le.network_type = '4G'
        THEN 'Good'
        ELSE 'Limited'
    END AS Internet_Quality
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id;

-- Q9: Create a VIEW called connected_students that includes students who:
--    • Have Location = Yes
--    • AND use Wifi
-- Then display all records from the view ordered by Adaptivity Level.

CREATE VIEW connected_students AS
SELECT
    s.*,
    le.internet_type,
    le.network_type,
    le.device,
    le.class_duration
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
WHERE s.location = 'Yes'
  AND le.internet_type = 'Wifi';

-- Display data after (connected_students)

  SELECT *
FROM connected_students
ORDER BY adaptivity_level;

-- Q10: For each education level, display:
--  • Total number of students
--  • Number of students with Low adaptivity level
-- Only show education levels where more than 30% of students have Low adaptivity level.

SELECT
    s.education_level,
    COUNT(*) AS total_students,
    SUM(
        CASE
            WHEN s.adaptivity_level = 'Low' THEN 1
            ELSE 0
        END
    ) AS low_adaptivity_students
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
GROUP BY
    s.education_level
HAVING
    SUM(
        CASE
            WHEN s.adaptivity_level = 'Low' THEN 1
            ELSE 0
        END
    ) * 1.0 / COUNT(*) > 0.3;