# PAN Card Number Validation (SQL & Python)

This project is a technical demonstration of data cleaning and validation on a raw dataset of PAN (Permanent Account Number) cards. The same complex validation logic was applied using two different tools: **SQL** and **Python**.

### [View the Problem Statement](PAN%20Number%20Validation%20-%20Problem%20Statement.pdf)

---

## 1. Project Objective
The goal was to clean a "dirty" dataset of PAN numbers and validate each entry against a set of complex rules defined in the problem statement.

### Validation Rules:
A PAN is "Valid" only if it passes ALL of the following rules:
1.  **Length:** Exactly 10 characters.
2.  **Format:** Must be in the `AAAAA1234A` format (5 letters, 4 numbers, 1 letter).
3.  **Case:** All letters must be uppercase.
4.  **No Adjacent Repeats:** Characters next to each other cannot be the same (e.g., `AABCD` is invalid).
5.  **No Sequences:** The 5-letter and 4-number parts cannot be sequential (e.g., `ABCDE` or `1234` are invalid).

---

## 2. Tools & Approach
To showcase versatility, the validation was performed in two separate environments:

### 1. SQL Approach
* **File:** [`Pan Number Validation by me.sql`](Pan%20Number%20Validation%20by%20me.sql)
* **Process:**
    * Cleaned the data using `UPPER()`, `TRIM()`, and `DISTINCT`.
    * Created custom SQL functions (`fun_check_adjacent_characters`, `fn_check_strict_sequence`) to check for the complex rules.
    * Used `REGEXP` for format validation and a `VIEW` to categorize all PANs.
    * Generated a final summary report using `COUNT(*)` and `CASE` statements.

### 2. Python Approach
* **File:** [PAN_Number_Validation(by me).ipynb](PAN_Validation_by_me.ipynb)
* **Process:**
    * Cleaned the data using **Pandas** (`.str.strip()`, `.str.upper()`, `.drop_duplicates()`, `.dropna()`).
    * Used the **`re` (RegEx)** library to validate the `AAAAA1234A` format.
    * Created custom Python functions (`has_adjacent_repitition`, `is_sequencial`) to check for complex rules.
    * Used the `.apply()` method to create a new "Status" column and generated a final summary.

---

## 3. Final Summary Report
Both methods produced the same final summary, validating the accuracy of the logic.

| Category | Count |
| :--- | :--- |
| Total Records Processed | 10000 |
| Total Valid PANs | 3186 |
| Total Invalid PANs | 5840 |
| Total Missing/Incomplete | 974 |
