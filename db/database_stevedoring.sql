-- 1. Master Data Kapal
CREATE TABLE STEV_Vessel (
    STEV_Vessel_ID NUMERIC(10) PRIMARY KEY,
    AD_Client_ID NUMERIC(10) NOT NULL,
    AD_Org_ID NUMERIC(10) NOT NULL,
    IsActive CHAR(1) DEFAULT 'Y' CHECK (IsActive IN ('Y','N')),
    Created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CreatedBy NUMERIC(10) NOT NULL,
    Updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy NUMERIC(10) NOT NULL,
    Value VARCHAR(40) NOT NULL,
    Name VARCHAR(255) NOT NULL,
    VesselType VARCHAR(20) CHECK (VesselType IN ('BULK', 'CONTAINER', 'GENERAL')),
    GRT NUMERIC,
    LOA NUMERIC
);

-- 2. Schedule & Header Transaksi Kapal
CREATE TABLE STEV_VesselSchedule (
    STEV_VesselSchedule_ID NUMERIC(10) PRIMARY KEY,
    AD_Client_ID NUMERIC(10) NOT NULL,
    AD_Org_ID NUMERIC(10) NOT NULL,
    IsActive CHAR(1) DEFAULT 'Y',
    Created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CreatedBy NUMERIC(10) NOT NULL,
    Updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy NUMERIC(10) NOT NULL,
    STEV_Vessel_ID NUMERIC(10) REFERENCES STEV_Vessel(STEV_Vessel_ID),
    C_BPartner_ID NUMERIC(10) REFERENCES C_BPartner(C_BPartner_ID), -- Shipping Agent / Customer
    C_Order_ID NUMERIC(10) REFERENCES C_Order(C_Order_ID), -- Sales Order Ref (Opsi 3)
    ETA TIMESTAMP,
    ETB TIMESTAMP,
    ETD TIMESTAMP,
    DocStatus CHAR(2) DEFAULT 'DR' -- DR: Draft, CO: Completed, CL: Closed
);

-- 3. Header Realisasi Tally Field
CREATE TABLE STEV_TallySheet (
    STEV_TallySheet_ID NUMERIC(10) PRIMARY KEY,
    AD_Client_ID NUMERIC(10) NOT NULL,
    AD_Org_ID NUMERIC(10) NOT NULL,
    IsActive CHAR(1) DEFAULT 'Y',
    Created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CreatedBy NUMERIC(10) NOT NULL,
    Updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy NUMERIC(10) NOT NULL,
    STEV_VesselSchedule_ID NUMERIC(10) REFERENCES STEV_VesselSchedule(STEV_VesselSchedule_ID),
    HatchNo INT NOT NULL,
    Shift INT CHECK (Shift IN (1, 2, 3)),
    TallyDate DATE NOT NULL
);

-- 4. Detail Line Tally Field
CREATE TABLE STEV_TallyLine (
    STEV_TallyLine_ID NUMERIC(10) PRIMARY KEY,
    AD_Client_ID NUMERIC(10) NOT NULL,
    AD_Org_ID NUMERIC(10) NOT NULL,
    IsActive CHAR(1) DEFAULT 'Y',
    Created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CreatedBy NUMERIC(10) NOT NULL,
    Updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy NUMERIC(10) NOT NULL,
    STEV_TallySheet_ID NUMERIC(10) REFERENCES STEV_TallySheet(STEV_TallySheet_ID),
    M_Product_ID NUMERIC(10) REFERENCES M_Product(M_Product_ID),
    QtyHandled NUMERIC DEFAULT 0 NOT NULL,
    DamageQty NUMERIC DEFAULT 0,
    TimeLog TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    OfflineUUID VARCHAR(36) UNIQUE -- Untuk Sync Offline-First React
);

-- 5. Statement of Facts (SoF) & Approval
CREATE TABLE STEV_StatementOfFact (
    STEV_StatementOfFact_ID NUMERIC(10) PRIMARY KEY,
    AD_Client_ID NUMERIC(10) NOT NULL,
    AD_Org_ID NUMERIC(10) NOT NULL,
    IsActive CHAR(1) DEFAULT 'Y',
    Created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CreatedBy NUMERIC(10) NOT NULL,
    Updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy NUMERIC(10) NOT NULL,
    STEV_VesselSchedule_ID NUMERIC(10) REFERENCES STEV_VesselSchedule(STEV_VesselSchedule_ID),
    TotalQtyHandled NUMERIC NOT NULL,
    MasterName VARCHAR(100),
    SignatureBase64 TEXT, -- Menampung data TTD Wet Sign dari React
    GPSLocation VARCHAR(100),
    ApprovedTime TIMESTAMP,
    DocStatus CHAR(2) DEFAULT 'DR'
);
