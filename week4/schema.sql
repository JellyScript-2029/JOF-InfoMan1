-- Step 1: Create Database
CREATE DATABASE infoman1_vetclinic;
USE infoman1_vetclinic;

-- Step 2: Create Tables

-- Owner Table 
CREATE TABLE Owner (
    owner_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) NOT NULL
);

-- Pet Table 
CREATE TABLE Pet (
    pet_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(50) NOT NULL,
    age INT,
    owner_id INT NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES Owner(owner_id)
);

-- Veterinarian Table 
CREATE TABLE Veterinarian (
    veterinarian_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(50) NOT NULL
);

-- Appointment Table 
CREATE TABLE Appointment (
    appointment_id INT PRIMARY KEY,
    appointment_date DATE NOT NULL,
    reason_for_visit TEXT NOT NULL,
    pet_id INT NOT NULL,
    veterinarian_id INT NOT NULL,
    FOREIGN KEY (pet_id) REFERENCES Pet(pet_id),
    FOREIGN KEY (veterinarian_id) REFERENCES Veterinarian(veterinarian_id)
);

-- Vaccination_Record Table
CREATE TABLE Vaccination_Record (
    pet_id INT NOT NULL,
    vaccine_name VARCHAR(50) NOT NULL,
    vaccination_date DATE NOT NULL,
    PRIMARY KEY (pet_id, vaccine_name, vaccination_date),
    FOREIGN KEY (pet_id) REFERENCES Pet(pet_id)
);