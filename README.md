# Housework Task Manager

## Overview
The **Housework Task Manager** is a web application built with Flask that simplifies tracking household tasks. It provides two key features:

1.  Adding individual task records through a user-friendly form.
2.  Uploading bulk task records via a CSV file for streamlined data entry.

The application uses a PostgreSQL database to store data about tasks, people, and their associated task records, enabling efficient management and tracking of household chores.

## Features
**1. Task Record Management**
  * Add individual task records with fields such as:
      * Date of the task
      * Person responsible
      * Task name
      * Task duration (in minutes)
  * All fields are validated to ensure data integrity.

**2. Bulk CSV Upload**
  * Upload a CSV file containing multiple task records at once.
  * Automatically maps names of people and tasks to their corresponding database IDs.
  * Validates the CSV file format and contents before inserting records into the database.
  * Provides detailed feedback about invalid rows or missing mappings.

**3. Feedback Notifications**
  * Displays success and error messages using Bootstrap alerts.
  * Alerts automatically fade out after 3 seconds for a seamless user experience.

**4. Daily Task Aggregation**
  * The application includes a script for aggregating daily housework tasks and updating a summary table. This ensures efficient reporting and minimizes redundant calculations during analysis.


## CSV Upload Format
Ensure the CSV file adheres to the following structure:
| Date       | Person     | Task           | Task Duration Minutes |
|------------|------------|----------------|-----------------------|
| 2023-12-10 | John Smith | Cooking        | 30                    |
| 2023-12-11 | Jane Doe   | Cleaning       | 60                    |
| 2023-12-11 | John Smith | Bath The Child | 10                    |

* **Date**: Format YYYY-MM-DD.
* **Person**: Name of the person (must exist in dim_person table).
* **Task**: Name of the task (must exist in dim_task table).
* **Task Duration Minutes**: Positive integer.

## Project Structure
**Backend**
  * Built using Flask.
  * Implements data validation with Flask-WTF and CSRF protection.
  * Uses SQLAlchemy for database interaction with PostgreSQL.

**Frontend**
  * HTML templates styled with Bootstrap.
  * Two forms:
    * Task Record Form for individual entries.
    * CSV Upload Form for bulk entries.

## Database Schema
The application uses three tables:

1. **dim_person**
     * Stores the names of people.
     * Columns:
       * id: Primary key.
       * name: Name of the person.

2. **dim_task**
     * Stores the names of tasks.
     * Columns:
       * id: Primary key.
       * name: Task name (e.g., Folding Laundry, Cooking, Bath The Child).
       * category: Task category (e.g., Household, Child Care).

3. **fact_housework_tasks**
     * Stores task records.
     * Columns:
       * id: Primary key.
       * date: Date the task was performed.
       * person_id: Foreign key referencing dim_person.
       * task_id: Foreign key referencing dim_task.
       * task_duration_minutes: Duration of the task in minutes.
       * create_time_utc: Timestamp of the first creation.
       * update_time_utc: Timestamp of the last update.
      
## Backfill Aggregation Script
The SQL script aggregates daily task data and inserts or updates the agg_daily_housework_tasks table. It calculates key metrics such as the number of tasks and the total task duration (in hours) per person, task, and category.
1. **Data Aggregation**:
   * Groups data from fact_housework_tasks by date, person, task, and task category.
   * Calculates the number of tasks performed and total task duration in hours.
2. **Inserting or Updating Records:**
   * Inserts the aggregated data into agg_daily_housework_tasks.
   * Uses the ON CONFLICT clause to update existing records if there are changes in task category, number of tasks, or task duration.
3. **Efficient Conflict Resolution:**
   * Ensures the summary table reflects the latest data without duplicating entries.
