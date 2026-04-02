PRAGMA foreign_keys = ON;

#Client & staff
CREATE TABLE client (
    clientId INTEGER PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    whatFor TEXT,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    phoneNumber TEXT,
    clientType TEXT NOT NULL CHECK (clientType IN ('individual', 'group', 'organization'))
);

CREATE TABLE staff (
    staffId INTEGER PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    jobType TEXT NOT NULL
);

# Infrastructure
CREATE TABLE cloud_region (
    regionId INTEGER PRIMARY KEY,
    cloudRegionName TEXT NOT NULL UNIQUE
);

CREATE TABLE data_center (
    dataCenterId INTEGER PRIMARY KEY,
    regionId INTEGER NOT NULL,
    dataCenterName TEXT NOT NULL,
    FOREIGN KEY (regionId) REFERENCES cloud_region(regionId),
);

CREATE TABLE availability_zone (
    zoneId INTEGER PRIMARY KEY,
    dataCenterId INTEGER NOT NULL,
    zoneName TEXT NOT NULL,
    zoneStatus TEXT NOT NULL CHECK (zoneStatus IN ('active', 'degraded', 'offline')),
    FOREIGN KEY (dataCenterId) REFERENCES data_center(dataCenterId),
);

CREATE TABLE resource_type (
    resourceTypeId INTEGER PRIMARY KEY,
    typeName TEXT NOT NULL UNIQUE,
    performanceTier TEXT NOT NULL,
    capacityRating TEXT,
);

CREATE TABLE resource (
    resourceId INTEGER PRIMARY KEY,
    resourceTypeId INTEGER NOT NULL,
    zoneId INTEGER NOT NULL,
    resourceLabel TEXT NOT NULL UNIQUE,
    currentStatus TEXT NOT NULL CHECK (currentStatus IN ('available', 'in_use', 'maintenance', 'retired')),
    FOREIGN KEY (resourceTypeId) REFERENCES resource_type(resourceTypeId),
    FOREIGN KEY (zoneId) REFERENCES availability_zone(zoneId)
);

CREATE TABLE resource_capacity (
    capacityId INTEGER PRIMARY KEY,
    resourceId INTEGER NOT NULL,
    capacityName TEXT NOT NULL,
    capacityValue REAL NOT NULL CHECK (capacityValue >= 0),
    capacityUnit TEXT NOT NULL,
    FOREIGN KEY (resourceId) REFERENCES resource(resourceId),
);

CREATE TABLE resource_availability_event (
    availabilityEventId INTEGER PRIMARY KEY,
    resourceId INTEGER NOT NULL,
    eventType TEXT NOT NULL CHECK (eventType IN ('maintenance', 'outage', 'repair')),
    startTime TEXT NOT NULL,
    endTime TEXT,
    note TEXT
    FOREIGN KEY (resourceId) REFERENCES resource(resourceId),
    CHECK (endTime IS NULL OR startTime < endTime)
);

#Reservation & Scheduling
CREATE TABLE reservation (
    reservationId INTEGER PRIMARY KEY,
    clientId INTEGER NOT NULL,
    staffId INTEGER NOT NULL,
    regionId INTEGER,
    requestStartTime TEXT NOT NULL,
    requestEndTime TEXT NOT NULL,
    reservationType TEXT NOT NULL,
    status TEXT NOT NULL,
    emergencyLevel INTEGER NOT NULL DEFAULT 1 CHECK (emergencyLevel BETWEEN 1 AND 5),
    FOREIGN KEY (clientId) REFERENCES client(clientId),
    FOREIGN KEY (staffId) REFERENCES staff(staffId),
    FOREIGN KEY (regionId) REFERENCES cloud_region(regionId),
    CHECK (requestStartTime < requestEndTime)
);

CREATE TABLE need (
    needId INTEGER PRIMARY KEY,
    reservationId INTEGER NOT NULL,
    resourceTypeId INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    capacityRequirement TEXT,
    flexibilityLevel TEXT NOT NULL CHECK (flexibilityLevel IN ('strict', 'flexible')),
    note TEXT,
    FOREIGN KEY (reservationId) REFERENCES reservation(reservationId),
    FOREIGN KEY (resourceTypeId) REFERENCES resource_type(resourceTypeId)
);

CREATE TABLE actual_assignment (
    assignmentId INTEGER PRIMARY KEY,
    reservationId INTEGER NOT NULL,
    regionId INTEGER NOT NULL,
    eventStartTime TEXT NOT NULL,
    eventEndTime TEXT,
    satisfactionScore INTEGER CHECK (satisfactionScore BETWEEN 1 AND 5),
    reason TEXT,
    FOREIGN KEY (reservationId) REFERENCES reservation(reservationId),
    FOREIGN KEY (regionId) REFERENCES cloud_region(regionId),
    CHECK (eventEndTime IS NULL OR eventStartTime < eventEndTime)
);
#Deployment & Usage
CREATE TABLE deployment_status (
    statusId INTEGER PRIMARY KEY,
    statusName TEXT NOT NULL UNIQUE
);

CREATE TABLE priority_level (
    priorityLevelId INTEGER PRIMARY KEY,
    priorityName TEXT NOT NULL UNIQUE,
    rankValue INTEGER NOT NULL UNIQUE CHECK (rankValue >= 1)
);

CREATE TABLE deployment (
    deploymentId INTEGER PRIMARY KEY,
    reservationId INTEGER NOT NULL,
    deploymentName TEXT NOT NULL,
    statusId INTEGER NOT NULL,
    startTime TEXT NOT NULL,
    endTime TEXT,
 
    FOREIGN KEY (reservationId) REFERENCES reservation(reservationId),
    FOREIGN KEY (statusId) REFERENCES deployment_status(statusId),

    CHECK (endTime IS NULL OR endTime >= startTime)
);

CREATE TABLE deployment_resource (
    deploymentResourceId INTEGER PRIMARY KEY,
    deploymentId INTEGER NOT NULL,
    resourceId INTEGER NOT NULL,
    assignedAt TEXT NOT NULL,
    releasedAt TEXT,
    roleInDeployment TEXT,
    assignmentStatus TEXT,
    
    FOREIGN KEY (deploymentId) REFERENCES deployment(deploymentId),
    FOREIGN KEY (resourceId) REFERENCES resource(resourceId),
    
    CHECK (releasedAt IS NULL OR releasedAt >= assignedAt),
    CHECK (assignmentStatus IN ('assigned', 'released', 'pending'))
);

CREATE TABLE deployment_priority_history (
    priorityHistoryId INTEGER PRIMARY KEY,
    deploymentId INTEGER NOT NULL,
    priorityLevelId INTEGER NOT NULL,
    startTime TEXT NOT NULL,
    endTime TEXT,

    FOREIGN KEY (deploymentId) REFERENCES deployment(deploymentId),
    FOREIGN KEY (priorityLevelId) REFERENCES priority_level(priorityLevelId),
    CHECK (endTime IS NULL OR startTime < endTime)
);

CREATE TABLE deployment_event (
    eventId INTEGER PRIMARY KEY,
    deploymentId INTEGER NOT NULL,
    eventType TEXT NOT NULL,
    eventTime TEXT NOT NULL,
    staffId INTEGER,
    clientId INTEGER,
    resourceId INTEGER,
    fromResourceId INTEGER,
    toResourceId INTEGER,
    oldValue TEXT,
    newValue TEXT,
    reason TEXT,
    notes TEXT,

    FOREIGN KEY (deploymentId) REFERENCES deployment(deploymentId),
    FOREIGN KEY (staffId) REFERENCES staff(staffId),
    FOREIGN KEY (clientId) REFERENCES client(clientId),
    FOREIGN KEY (resourceId) REFERENCES resource(resourceId),
    FOREIGN KEY (fromResourceId) REFERENCES resource(resourceId),
    FOREIGN KEY (toResourceId) REFERENCES resource(resourceId),
 
    CHECK (fromResourceId IS NULL OR toResourceId IS NULL OR fromResourceId <> toResourceId)
        CHECK (
        eventType IN (
            'created',
            'started',
            'paused',
            'resumed',
            'scaled_up',
            'scaled_down',
            'migrated',
            'terminated',
            'reassigned',
            'manual_adjustment'
        )
    )
);

CREATE TABLE usage_record (
    usageRecordId INTEGER PRIMARY KEY,
    deploymentId INTEGER NOT NULL,
    resourceId INTEGER NOT NULL,
    usageType TEXT NOT NULL CHECK (
        usageType IN ('compute', 'storage', 'network', 'support', 'backup', 'monitoring')
    ),
    quantity REAL NOT NULL CHECK (quantity >= 0),
    unit TEXT NOT NULL,
    startTime TEXT NOT NULL,
    endTime TEXT NOT NULL,
    isFinal INTEGER NOT NULL DEFAULT 1 CHECK (isFinal IN (0, 1)),

    FOREIGN KEY (deploymentId) REFERENCES deployment(deploymentId),
    FOREIGN KEY (resourceId) REFERENCES resource(resourceId),
    
    CHECK (startTime < endTime)
);

--billing
CREATE TABLE paying_party (
    paying_partyId INT PRIMARY KEY,
    party_name TEXT NOT NULL,
    FOREIGN KEY (paying_partyId) REFERENCES client(clientId)
);

CREATE TABLE billing_address (
    paying_partyId INT NOT NULL,
    addressType TEXT CHECK (addressType IN ('billing','fulfillment')),
    addressLine1 TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    zipCode VARCHAR(10) NOT NULL, --international zip codes are 5-10 digits long
    country VARCHAR(100) NOT NULL,
    FOREIGN KEY (paying_partyId) REFERENCES paying_party (paying_partyId),
    PRIMARY KEY (paying_partyId, addressType)
);

CREATE TABLE payment_method (
    paymentMethodId INT PRIMARY KEY,
    paying_partyId INT NOT NULL,
    bankAccountName TEXT, --QOL to be easier to remember ie. Jane Doe Inc. Company Card
    routingNumber VARCHAR(50) NOT NULL,
    accountNumber VARCHAR(50) NOT NULL,--IBAN 34 char max, +16 for future proofing
    FOREIGN KEY (paying_partyId) REFERENCES paying_party (paying_partyId)
); --cannot be int because leading zeroes are dropped, cannot be char because different countries have different lengths

--beneficiary uses service, which the paying party pays for
CREATE TABLE beneficiary (
    beneficiaryId INT PRIMARY KEY, 
    paying_partyId INT NOT NULL, --allows beneficiaries to be under multiple paying parties, allowing for more than one person to pay?
    beneficiary_name TEXT NOT NULL,
    clientId INT NOT NULL,
    FOREIGN KEY (paying_partyId) REFERENCES paying_party (paying_partyId),
    FOREIGN KEY (clientId) REFERENCES client (clientId)
);

CREATE TABLE payment (
    paymentId INT PRIMARY KEY,
    billId INT NOT NULL,
    paymentMethodId INT NOT NULL,
    dateFulfilled DATETIME,
    paymentType TEXT CHECK (paymentType IN ('deposit', 'installment', 'full', 'partial')),
    FOREIGN KEY (billId) REFERENCES bill_header (billId),
    FOREIGN KEY (paymentMethodId) REFERENCES payment_method (paymentMethodId)
);

CREATE TABLE bill_header (
    billId INT PRIMARY KEY,
    billStatus TEXT CHECK (billStatus IN ('unpaid','paid','pending','overdue')),
    issueDate DATETIME,
    dueDate DATETIME
);

CREATE TABLE bill_adjustment (
    billId INT PRIMARY KEY,
    deposit DECIMAL(10,2) DEFAULT 0 CHECK (deposit >= 0),
    depositDueDate DATETIME,
    accountCredit DECIMAL(10,2) DEFAULT 0 CHECK (accountCredit>=0),
    refund DECIMAL(10,2) DEFAULT 0 ,
    surcharge DECIMAL(10,2) DEFAULT 0 CHECK (surcharge>=0),
    emergencyFee DECIMAL(10,2) DEFAULT 0 CHECK (emergencyFee >=0),
    discount DECIMAL(10,2) DEFAULT 0 CHECK (discount >=0),
    approvedByStaffId INT NOT NULL,
    createdAt DATE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (billId) REFERENCES bill_header(billId)
);

CREATE TABLE bill_item (
    billItemId INT PRIMARY KEY,
    billId INT NOT NULL,
    usageRecordId INT NOT NULL,
    beneficiaryId INT NOT NULL,
    Duration INT NOT NULL,
    FOREIGN KEY (beneficiaryId) REFERENCES beneficiary(beneficiaryId),
    FOREIGN KEY (billId) REFERENCES bill_header(billId),
    FOREIGN KEY (usageRecordId) REFERENCES usage_record(usageRecordId)
);

CREATE TABLE pricing (
    usageRecordId INT PRIMARY KEY, --can be used to query resource id, resource name(type), client id (name), usage_record.duration, usage_record.unit
    pricePerUnitSold DECIMAL(10,2), --price per unit at the time of billing ""
    FOREIGN KEY (usageRecordId) REFERENCES usage_record(usageRecordId)
);
