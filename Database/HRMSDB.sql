CREATE DATABASE HRMSDB;
GO
USE HRMSDB;
GO

-----------------------------------------------------------
-- 1. TABLES CREATION
-----------------------------------------------------------

-- Departments
CREATE TABLE Dept (
    DeptID INT PRIMARY KEY IDENTITY(1,1),
    DeptName NVARCHAR(100) NOT NULL,
    IsActive BIT DEFAULT 1
);

-- Designations
CREATE TABLE Designation (
    DesigID INT PRIMARY KEY IDENTITY(1,1),
    DeptID INT FOREIGN KEY REFERENCES Dept(DeptID),
    DesigName NVARCHAR(100) NOT NULL,
    IsActive BIT DEFAULT 1
);

-- Roles
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL,
    IsActive BIT DEFAULT 1
);

-- Employees
CREATE TABLE Employee (
    EmpID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Contact NVARCHAR(20),
    Address NVARCHAR(250),
    Password NVARCHAR(100) NOT NULL,
    DeptID INT FOREIGN KEY REFERENCES Dept(DeptID),
    DesigID INT FOREIGN KEY REFERENCES Designation(DesigID),
    RoleID INT FOREIGN KEY REFERENCES Roles(RoleID),
    ManagerID INT NULL, 
    ProfilePhotoPath NVARCHAR(MAX),
    IsActive BIT DEFAULT 1
);

-- Events (For Calendar)
CREATE TABLE Events (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    EventName NVARCHAR(100) NOT NULL,
    EventColor NVARCHAR(20),
    IsActive BIT DEFAULT 1
);

-- Holidays
CREATE TABLE Holiday (
    HolidayID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT FOREIGN KEY REFERENCES Events(EventID),
    HolidayName NVARCHAR(100) NOT NULL,
    HolidayDate DATE NOT NULL,
    IsActive BIT DEFAULT 1
);

-- Leave Types
CREATE TABLE LeaveType (
    LeaveTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(50) NOT NULL,
    IsActive BIT DEFAULT 1
);

-- Leaves
CREATE TABLE Leaves (
    LeaveID INT PRIMARY KEY IDENTITY(1,1),
    EmpID INT FOREIGN KEY REFERENCES Employee(EmpID),
    LeaveTypeID INT FOREIGN KEY REFERENCES LeaveType(LeaveTypeID),
    FromDate DATE NOT NULL,
    ToDate DATE NOT NULL,
    Reason NVARCHAR(MAX),
    Status NVARCHAR(20) DEFAULT 'Pending' -- Pending, Approved, Rejected
);
GO

-----------------------------------------------------------
-- 2. STORED PROCEDURES (CRUD)
-----------------------------------------------------------

-- =============================================
-- Department Module
-- =============================================
CREATE PROCEDURE sp_InsertDept @DeptName NVARCHAR(100), @IsActive BIT
AS BEGIN INSERT INTO Dept (DeptName, IsActive) VALUES (@DeptName, @IsActive); END;
GO
CREATE PROCEDURE sp_GetDept AS BEGIN SELECT * FROM Dept; END;
GO
CREATE PROCEDURE sp_UpdateDept @DeptID INT, @DeptName NVARCHAR(100), @IsActive BIT
AS BEGIN UPDATE Dept SET DeptName=@DeptName, IsActive=@IsActive WHERE DeptID=@DeptID; END;
GO
CREATE PROCEDURE sp_DeleteDept @DeptID INT AS BEGIN DELETE FROM Dept WHERE DeptID=@DeptID; END;
GO

-- =============================================
-- Designation Module
-- =============================================
CREATE PROCEDURE sp_InsertDesig @DeptID INT, @DesigName NVARCHAR(100), @IsActive BIT
AS BEGIN INSERT INTO Designation (DeptID, DesigName, IsActive) VALUES (@DeptID, @DesigName, @IsActive); END;
GO
CREATE PROCEDURE sp_GetDesig 
AS BEGIN 
    SELECT d.DesigID, d.DeptID, dep.DeptName, d.DesigName, d.IsActive 
    FROM Designation d 
    INNER JOIN Dept dep ON d.DeptID = dep.DeptID; 
END;
GO
CREATE PROCEDURE sp_UpdateDesig @DesigID INT, @DeptID INT, @DesigName NVARCHAR(100), @IsActive BIT
AS BEGIN UPDATE Designation SET DeptID=@DeptID, DesigName=@DesigName, IsActive=@IsActive WHERE DesigID=@DesigID; END;
GO
CREATE PROCEDURE sp_DeleteDesig @DesigID INT AS BEGIN DELETE FROM Designation WHERE DesigID=@DesigID; END;
GO

-- =============================================
-- Role Module
-- =============================================
CREATE PROCEDURE sp_InsertRole @RoleName NVARCHAR(50), @IsActive BIT
AS BEGIN INSERT INTO Roles (RoleName, IsActive) VALUES (@RoleName, @IsActive); END;
GO
CREATE PROCEDURE sp_GetRole AS BEGIN SELECT * FROM Roles; END;
GO
CREATE PROCEDURE sp_UpdateRole @RoleID INT, @RoleName NVARCHAR(50), @IsActive BIT
AS BEGIN UPDATE Roles SET RoleName=@RoleName, IsActive=@IsActive WHERE RoleID=@RoleID; END;
GO
CREATE PROCEDURE sp_DeleteRole @RoleID INT AS BEGIN DELETE FROM Roles WHERE RoleID=@RoleID; END;
GO

-- =============================================
-- Employee Module
-- =============================================
CREATE PROCEDURE sp_InsertEmp 
    @Name NVARCHAR(100), @Email NVARCHAR(100), @Contact NVARCHAR(20), @Address NVARCHAR(250), 
    @Password NVARCHAR(100), @DeptID INT, @DesigID INT, @RoleID INT, @ManagerID INT, @Photo NVARCHAR(MAX), @IsActive BIT
AS BEGIN 
    INSERT INTO Employee (Name, Email, Contact, Address, Password, DeptID, DesigID, RoleID, ManagerID, ProfilePhotoPath, IsActive) 
    VALUES (@Name, @Email, @Contact, @Address, @Password, @DeptID, @DesigID, @RoleID, @ManagerID, @Photo, @IsActive); 
END;
GO
CREATE PROCEDURE sp_GetEmp 
AS BEGIN 
    SELECT e.EmpID, e.Name, e.Email, e.Contact, e.Address, e.DeptID, dep.DeptName, 
           e.DesigID, des.DesigName, e.RoleID, r.RoleName, e.ManagerID, m.Name AS ManagerName, 
           e.ProfilePhotoPath, e.IsActive
    FROM Employee e
    LEFT JOIN Dept dep ON e.DeptID = dep.DeptID
    LEFT JOIN Designation des ON e.DesigID = des.DesigID
    LEFT JOIN Roles r ON e.RoleID = r.RoleID
    LEFT JOIN Employee m ON e.ManagerID = m.EmpID;
END;
GO
CREATE PROCEDURE sp_UpdateEmp 
    @EmpID INT, @Name NVARCHAR(100), @Email NVARCHAR(100), @Contact NVARCHAR(20), 
    @Address NVARCHAR(250), @DeptID INT, @DesigID INT, @RoleID INT, @ManagerID INT, @Photo NVARCHAR(MAX), @IsActive BIT
AS BEGIN 
    UPDATE Employee 
    SET Name=@Name, Email=@Email, Contact=@Contact, Address=@Address, 
        DeptID=@DeptID, DesigID=@DesigID, RoleID=@RoleID, ManagerID=@ManagerID, ProfilePhotoPath=@Photo, IsActive=@IsActive
    WHERE EmpID=@EmpID;
END;
GO
CREATE PROCEDURE sp_DeleteEmp @EmpID INT AS BEGIN DELETE FROM Employee WHERE EmpID=@EmpID; END;
GO

-- =============================================
-- Events Module
-- =============================================
CREATE PROCEDURE sp_InsertEvent @EventName NVARCHAR(100), @EventColor NVARCHAR(20), @IsActive BIT
AS BEGIN INSERT INTO Events (EventName, EventColor, IsActive) VALUES (@EventName, @EventColor, @IsActive); END;
GO
CREATE PROCEDURE sp_GetEvent AS BEGIN SELECT * FROM Events; END;
GO
CREATE PROCEDURE sp_UpdateEvent @EventID INT, @EventName NVARCHAR(100), @EventColor NVARCHAR(20), @IsActive BIT
AS BEGIN UPDATE Events SET EventName=@EventName, EventColor=@EventColor, IsActive=@IsActive WHERE EventID=@EventID; END;
GO
CREATE PROCEDURE sp_DeleteEvent @EventID INT AS BEGIN DELETE FROM Events WHERE EventID=@EventID; END;
GO

-- =============================================
-- Holiday Module
-- =============================================
CREATE PROCEDURE sp_InsertHoliday @EventID INT, @HolidayName NVARCHAR(100), @HolidayDate DATE, @IsActive BIT
AS BEGIN INSERT INTO Holiday (EventID, HolidayName, HolidayDate, IsActive) VALUES (@EventID, @HolidayName, @HolidayDate, @IsActive); END;
GO
CREATE PROCEDURE sp_GetHoliday 
AS BEGIN 
    SELECT h.HolidayID, h.EventID, e.EventName, e.EventColor, h.HolidayName, h.HolidayDate, h.IsActive
    FROM Holiday h
    INNER JOIN Events e ON h.EventID = e.EventID;
END;
GO
CREATE PROCEDURE sp_UpdateHoliday @HolidayID INT, @EventID INT, @HolidayName NVARCHAR(100), @HolidayDate DATE, @IsActive BIT
AS BEGIN UPDATE Holiday SET EventID=@EventID, HolidayName=@HolidayName, HolidayDate=@HolidayDate, IsActive=@IsActive WHERE HolidayID=@HolidayID; END;
GO
CREATE PROCEDURE sp_DeleteHoliday @HolidayID INT AS BEGIN DELETE FROM Holiday WHERE HolidayID=@HolidayID; END;
GO

-- =============================================
-- Leave Type Module
-- =============================================
CREATE PROCEDURE sp_InsertLeaveType @TypeName NVARCHAR(50), @IsActive BIT
AS BEGIN INSERT INTO LeaveType (TypeName, IsActive) VALUES (@TypeName, @IsActive); END;
GO
CREATE PROCEDURE sp_GetLeaveType AS BEGIN SELECT * FROM LeaveType; END;
GO
CREATE PROCEDURE sp_UpdateLeaveType @LeaveTypeID INT, @TypeName NVARCHAR(50), @IsActive BIT
AS BEGIN UPDATE LeaveType SET TypeName=@TypeName, IsActive=@IsActive WHERE LeaveTypeID=@LeaveTypeID; END;
GO
CREATE PROCEDURE sp_DeleteLeaveType @LeaveTypeID INT AS BEGIN DELETE FROM LeaveType WHERE LeaveTypeID=@LeaveTypeID; END;
GO

-- =============================================
-- Leave Module
-- =============================================
CREATE PROCEDURE sp_InsertLeave @EmpID INT, @LeaveTypeID INT, @FromDate DATE, @ToDate DATE, @Reason NVARCHAR(MAX)
AS BEGIN INSERT INTO Leaves (EmpID, LeaveTypeID, FromDate, ToDate, Reason) VALUES (@EmpID, @LeaveTypeID, @FromDate, @ToDate, @Reason); END;
GO
CREATE PROCEDURE sp_GetLeaves 
AS BEGIN 
    SELECT l.LeaveID, l.EmpID, e.Name AS EmpName, l.LeaveTypeID, lt.TypeName, l.FromDate, l.ToDate, l.Reason, l.Status
    FROM Leaves l
    INNER JOIN Employee e ON l.EmpID = e.EmpID
    INNER JOIN LeaveType lt ON l.LeaveTypeID = lt.LeaveTypeID;
END;
GO
CREATE PROCEDURE sp_UpdateLeaveStatus @LeaveID INT, @Status NVARCHAR(20)
AS BEGIN UPDATE Leaves SET Status=@Status WHERE LeaveID=@LeaveID; END;
GO
CREATE PROCEDURE sp_DeleteLeave @LeaveID INT AS BEGIN DELETE FROM Leaves WHERE LeaveID=@LeaveID; END;
GO