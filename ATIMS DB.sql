CREATE DATABASE ATIMS_FDB;

USE ATIMS_FDB;

-- User Table
CREATE TABLE [User] (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    [role] VARCHAR(20) NOT NULL CHECK ([role] IN ('akeray', 'tekeray', 'town_office_admin', 'system_admin')),
    id_verified BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    last_login DATETIME NULL,
    is_active BIT DEFAULT 1
);


CREATE TABLE IDDocument (
    document_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL FOREIGN KEY REFERENCES [User](user_id),
    document_type VARCHAR(30) CHECK (document_type IN ('national_id', 'passport', 'kebele_id', 'driver_license')),
    id_number VARCHAR(50) NOT NULL,
    front_image_path VARCHAR(255) NOT NULL,
    back_image_path VARCHAR(255) NULL,
    upload_date DATETIME DEFAULT GETDATE(),
    expiry_date DATE NULL,
    verified_by INT NULL FOREIGN KEY REFERENCES [User](user_id),
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected', 'expired')),
    verification_date DATETIME NULL,
    rejection_reason TEXT NULL
);


CREATE TABLE Akeray (
    akeray_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT UNIQUE NOT NULL FOREIGN KEY REFERENCES [User](user_id),
    tin_number VARCHAR(50) NULL,
    id_document_id INT NULL FOREIGN KEY REFERENCES IDDocument(document_id),
    registration_date DATETIME DEFAULT GETDATE()
);


CREATE TABLE Tekeray (
    tekeray_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT UNIQUE NOT NULL FOREIGN KEY REFERENCES [User](user_id),
    national_id VARCHAR(50) NOT NULL,
    [address] VARCHAR(200) NOT NULL,
    id_document_id INT NULL FOREIGN KEY REFERENCES IDDocument(document_id),
    emergency_contact VARCHAR(20) NULL
);


CREATE TABLE Property (
    property_id INT PRIMARY KEY IDENTITY(1,1),
    akeray_id INT NOT NULL FOREIGN KEY REFERENCES Akeray(akeray_id),
    kebele VARCHAR(50) NOT NULL,
    house_number VARCHAR(50) NOT NULL,
    [type] VARCHAR(10) NOT NULL CHECK ([type] IN ('room', 'house')),
    rent_amount DECIMAL(10,2) NOT NULL CHECK (rent_amount > 0),
    deposit_amount DECIMAL(10,2) DEFAULT 0,
    [status] VARCHAR(20) DEFAULT 'available' CHECK ([status] IN ('available', 'occupied')),
    [description] TEXT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    last_updated DATETIME DEFAULT GETDATE()
);


CREATE TABLE Lease (
    lease_id INT PRIMARY KEY IDENTITY(1,1),
    property_id INT NOT NULL FOREIGN KEY REFERENCES Property(property_id),
    tekeray_id INT NOT NULL FOREIGN KEY REFERENCES Tekeray(tekeray_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    advance_months INT DEFAULT 0 CHECK (advance_months >= 0),
    monthly_rent DECIMAL(10,2) NOT NULL,
    deposit_paid DECIMAL(10,2) DEFAULT 0,
    [status] VARCHAR(20) DEFAULT 'draft' CHECK ([status] IN ('draft', 'submitted', 'approved', 'active', 'expired', 'rejected')),
    created_at DATETIME DEFAULT GETDATE(),
    submitted_at DATETIME NULL,
    CONSTRAINT CHK_Lease_Dates CHECK (end_date > start_date)
);


CREATE TABLE Payment (
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    lease_id INT NOT NULL FOREIGN KEY REFERENCES Lease(lease_id),
    tekeray_id INT NOT NULL FOREIGN KEY REFERENCES Tekeray(tekeray_id),
    akeray_id INT NOT NULL FOREIGN KEY REFERENCES Akeray(akeray_id),
    ref_no VARCHAR(100) NOT NULL,
    date_paid DATE NOT NULL,
    [month] INT NOT NULL CHECK ([month] BETWEEN 1 AND 12),
    [year] INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(20) CHECK (payment_method IN ('cash', 'bank_transfer', 'check')),
    proof_path VARCHAR(255) NULL,
    [status] VARCHAR(20) DEFAULT 'pending' CHECK ([status] IN ('pending', 'approved', 'rejected')),
    notes TEXT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    approved_at DATETIME NULL
);


CREATE TABLE MaintenanceRequest (
    request_id INT PRIMARY KEY IDENTITY(1,1),
    tekeray_id INT NOT NULL FOREIGN KEY REFERENCES Tekeray(tekeray_id),
    property_id INT NOT NULL FOREIGN KEY REFERENCES Property(property_id),
    [description] TEXT NOT NULL,
    image_path VARCHAR(255) NULL,
    [status] VARCHAR(20) DEFAULT 'pending' CHECK ([status] IN ('pending', 'in_progress', 'resolved')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    notes TEXT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    resolved_at DATETIME NULL
);


CREATE TABLE TownOfficeVerification (
    verification_id INT PRIMARY KEY IDENTITY(1,1),
    lease_id INT UNIQUE NOT NULL FOREIGN KEY REFERENCES Lease(lease_id),
    officer_id INT NOT NULL FOREIGN KEY REFERENCES [User](user_id),
    decision VARCHAR(20) NOT NULL CHECK (decision IN ('approved', 'rejected')),
    comments TEXT NULL,
    date_verified DATETIME DEFAULT GETDATE()
);