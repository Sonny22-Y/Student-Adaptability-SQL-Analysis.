# Student Adaptability Level Analysis  
### SQL Server Project

**Author:** Yassin Ahmed Said Soltan  

**Tools Used:**  
- Microsoft SQL Server  
- Jupyter Notebook  

---

## 📌 Introduction

This project analyzes students' adaptability levels in online learning environments.

The dataset was originally provided in an Excel file and then imported into Microsoft SQL Server.  
The main objective of this project is to design a relational database and extract meaningful insights using SQL queries.

---

## 📊 Dataset Description

The dataset contains demographic, academic, and technical information about students, including:

- Gender and Age  
- Education Level  
- Financial Condition  
- Internet Type and Network Type  
- Device used for learning  
- Adaptivity Level  

The original dataset did not contain a primary key; therefore, a `student_id` column was generated automatically in SQL Server.

---

## 🗄️ Database Design

The database was normalized into two related tables.

### 1️⃣ students table
- `student_id` (Primary Key)  
- `gender`  
- `age`  
- `education_level`  
- `financial_condition`  
- `adaptivity_level`  
- `location`  

### 2️⃣ learning_environment table
- `env_id` (Primary Key)  
- `student_id` (Foreign Key)  
- `internet_type`  
- `network_type`  
- `device`  
- `class_duration`  

The two tables are connected using an **INNER JOIN** on `student_id`.

---

## 🔍 SQL Analysis Queries

### Q1: Display gender, age, education level, and internet type for all students
```sql
SELECT
    s.gender,
    s.age,
    s.education_level,
    le.internet_type
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id;

Explanation:
This query joins the students and learning_environment tables and displays basic demographic and internet information for all students.

---

Q2: Students using Wifi with Moderate adaptivity level

SELECT
    s.gender,
    s.education_level,
    le.device
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
WHERE le.internet_type = 'Wifi'
  AND s.adaptivity_level = 'Moderate';

Explanation:

The WHERE clause filters students who use Wifi and have a Moderate adaptability level.

---

Q3: School students using Mobile Data with Low adaptivity level

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

Explanation:

This query filters students based on education level, internet type, and adaptability level.

---

Q4: Number of students for each internet type and network type

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

Explanation:

COUNT and GROUP BY are used to calculate the number of students for each internet and network type.

---

Q5: Education level, device, and number of students (Poor or Mid financial condition)

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

Explanation:

This query filters students based on financial condition and groups the results by education level and device.

---

Q6: Average class duration per education level (greater than 1 hour)

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

Explanation:

CASE is used to convert text ranges into numeric values before calculating the average.

---

Q7: Devices used by more than one student

SELECT
    le.device,
    COUNT(*) AS number_of_students
FROM students s
INNER JOIN learning_environment le
    ON s.student_id = le.student_id
GROUP BY
    le.device
HAVING COUNT(*) > 1;

Explanation:

HAVING is used to filter aggregated results.

---

Q8: Internet Quality classification using CASE

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

Explanation:

A CASE statement is used to create a calculated column describing internet quality.

---

Q9: View of connected students

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

Explanation:

A view is created to store frequently used query logic.

---

Q10: Education levels with more than 30% Low adaptability

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

Explanation:

This query calculates the percentage of students with low adaptability per education level.

---

✅ Conclusion

This project demonstrates the use of SQL Server to design a relational database and perform analytical queries.

Key SQL concepts such as JOINs, GROUP BY, HAVING, CASE statements, and Views were successfully applied to analyze student adaptability levels.