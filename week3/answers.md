# INFOMAN1 — Week 3 Lab Answers

## Task 1 — Classify Attributes and Identify Weak Entities

| Classification Type | Attributes | Justification |
|---|---|---|
| Composite Attributes | `full_name` (Pet Owner & Veterinarian) | Contains multiple atomic components (`first_name` and `last_name`) that must be split into distinct columns for relational normalization. |
| Multivalued Attributes | `vaccination history` | A pet can receive zero, one, or multiple vaccinations over time; cannot be stored in a single column in normalized schemas. |
| Simple / Atomic Attributes | `owner_id`, `phone_number`, `pet_id`, `name`, `species`, `age`, `appointment_id`, `appointment_date`, `reason_for_visit`, `vet_id`, `specialization`, `vaccine_name`, `vaccination_date` | Single-valued, indivisible data values. |
| Derived Attributes | None | No derived attributes are explicitly specified in the scenario. |

## Task 2 — Specify Participation Constraints

| Relationship (verb phrase) | Between | Cardinality & Participation | Checked both directions? |
|---|---|---|---|
| owns | Owner ↔ Pet | 1:N (Optional Many `O<` at Pet, Mandatory One `||` at Owner) | Yes — An owner is not required to have pets on file, but every pet must belong to exactly one owner. |
| schedules | Pet ↔ Appointment | 1:N (Optional Many `O<` at Appointment, Mandatory One `||` at Pet) | Yes — A pet can exist before having appointments or have multiple appointments over time, but every appointment must specify exactly one pet. |
| conducts | Veterinarian ↔ Appointment | 1:N (Optional Many `O<` at Appointment, Mandatory One `||` at Veterinarian) | Yes — A veterinarian can conduct multiple appointments or none at all, but every appointment must specify exactly one veterinarian. |
| receives | Pet ↔ Vaccination Record | 1:N (Optional Many `O<` at Vaccination Record, Mandatory One `||` at Pet) | Yes — A pet can have zero, one, or several vaccination records, and each vaccination record only exists in relation to a specific pet. |


## Task 3 — Build the Logical ERD

![Conceptual ERD](erd-diagram.png)

## Task 4 — Translate to Relational Schema Notation

`owners`(`owner_id`, `first_name`, `last_name`, `phone_number`)

`pets`(`pet_id`, `name`, `species`, `age`, `owner_id`*)  
*Note: `owner_id` references `owners(owner_id)`*

`veterinarians`(`vet_id`, `first_name`, `last_name`, `specialization`)

`appointments`(`appointment_id`, `appointment_date`, `reason_for_visit`, `pet_id`*, `vet_id`*)  
*Note: `pet_id` references `pets(pet_id)`*  
*Note: `vet_id` references `veterinarians(vet_id)`*

`vaccination_records`(`pet_id`*, `vaccine_name`, `vaccination_date`)  
*Note: `pet_id` references `pets(pet_id)`*  
*Note: Primary Key is composite (`pet_id`, `vaccine_name`, `vaccination_date`)*

## Task 5 — Key Justification & Schema Validation

### Primary Key Justifications
- **`owners` & `pets` (Surrogate Keys):** Auto-incrementing integer IDs (`owner_id`, `pet_id`) were chosen as surrogate primary keys. Natural attributes like `phone_number` or pet `name` are mutable or non-unique, making surrogate keys essential for referential integrity.
- **`vaccination_records` (Composite Key):** A composite primary key (`pet_id`, `vaccine_name`, `vaccination_date`) was selected because `Vaccination Record` is a weak entity. This uniquely identifies vaccination events per pet without introducing an unnecessary surrogate ID.

### Schema Validation

| Scenario Requirement Statement | Schema Representation | Status |
|---|---|---|
| "A pet owner, identified by an owner ID, full name (first name, last name), and phone number..." | `owners(owner_id, first_name, last_name, phone_number)` | Verified |
| "...not required to have any pets, but every pet must belong to exactly one owner." | `pets(owner_id*)` FK references `owners(owner_id)` | Verified |
| "A pet has a pet ID, name, species, and age." | `pets(pet_id, name, species, age)` | Verified |
| "Every appointment tracks an appointment ID, date, and reason for visit..." | `appointments(appointment_id, appointment_date, reason_for_visit)` | Verified |
| "...must specify exactly one veterinarian and exactly one pet..." | `appointments(pet_id*, vet_id*)` non-null foreign keys | Verified |
| "A veterinarian, identified by vet ID, full name, and specialization..." | `veterinarians(vet_id, first_name, last_name, specialization)` | Verified |
| "...tracks each pet's vaccination history (vaccine name, vaccination date)..." | `vaccination_records(pet_id*, vaccine_name, vaccination_date)` composite PK | Verified |

## Self-Check

- [X] All tasks committed with individual, meaningful commit messages
- [X] All files placed inside `week3/`
- [X] This file completed `answers.md`
- [X] Repository link pasted into Moodle (no files uploaded)