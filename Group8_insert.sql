# =======Deployment Section1=======
# deployment
INSERT INTO deployment (
    deploymentId,
    reservationId,
    deploymentName,
    statusId,
    startTime,
    endTime
) VALUES
(1, 1, 'North America Analytics Cluster', 3, '2026-03-01 08:00:00', '2026-03-10 18:00:00'),
(2, 2, 'EU Backup Storage Rollout', 2, '2026-03-02 09:30:00', '2026-03-15 12:00:00'),
(3, 3, 'Realtime Fraud Detection Service', 3, '2026-03-03 07:00:00', '2026-03-12 20:00:00'),
(4, 4, 'Internal Test Environment', 3, '2026-03-05 10:00:00', '2026-03-08 16:30:00');


# deployment_resource
INSERT INTO deployment_resource (
    deploymentResourceId,
    deploymentId,
    resourceId,
    assignedAt,
    releasedAt,
    roleInDeployment,
    assignmentStatus
) VALUES
(1, 1, 101, '2026-03-01 08:00:00', '2026-03-07 14:20:00', 'primary_compute', 'released'),
(2, 1, 102, '2026-03-01 08:05:00', '2026-03-10 18:00:00', 'shared_storage', 'released'),
(3, 2, 103, '2026-03-02 09:30:00', '2026-03-15 12:00:00', 'backup_storage', 'released'),
(4, 3, 104, '2026-03-07 14:20:00', '2026-03-12 20:00:00', 'primary_compute', 'released'),
(5, 4, 105, '2026-03-05 10:00:00', '2026-03-08 16:30:00', 'monitoring', 'released');


# deployment_priority_history
INSERT INTO deployment_priority_history (
    priorityHistoryId,
    deploymentId,
    priorityLevelId,
    startTime,
    endTime
) VALUES
(1, 1, 3, '2026-03-01 08:00:00', '2026-03-10 18:00:00'),
(2, 2, 2, '2026-03-02 09:30:00', '2026-03-15 12:00:00'),
(3, 3, 4, '2026-03-03 07:00:00', '2026-03-12 20:00:00'),
(4, 4, 1, '2026-03-05 10:00:00', '2026-03-08 16:30:00');


# deployment_event
INSERT INTO deployment_event (
    eventId,
    deploymentId,
    eventType,
    eventTime,
    staffId,
    clientId,
    resourceId,
    fromResourceId,
    toResourceId,
    oldValue,
    newValue,
    reason,
    notes
) VALUES
(1, 1, 'created', '2026-03-01 08:00:00', 1, 1, 101, NULL, NULL, 'requested', 'created', 'new deployment request accepted', 'Deployment record created by scheduler'),
(2, 1, 'started', '2026-03-01 08:15:00', 1, 1, 101, NULL, NULL, 'planned', 'active', 'resources assigned and service started', 'Analytics cluster started successfully'),
(3, 2, 'scaled_up', '2026-03-04 11:00:00', 2, 2, 103, NULL, NULL, '1 backup node', 'expanded backup allocation', 'client requested higher backup capacity', 'Capacity increased within same deployment'),
(4, 3, 'migrated', '2026-03-07 14:20:00', 3, 1, 104, 101, 104, 'resource 101', 'resource 104', 'resource 101 entered maintenance window', 'Workload moved to replacement compute node'),
(5, 4, 'terminated', '2026-03-08 16:30:00', 2, 3, 105, NULL, NULL, 'active', 'completed', 'test period ended normally', 'Internal test deployment finished');


# usage_record
INSERT INTO usage_record (
    usageRecordId,
    deploymentId,
    resourceId,
    usageType,
    quantity,
    unit,
    startTime,
    endTime,
    isFinal
) VALUES
(1, 1, 101, 'compute', 48, 'hours', '2026-03-01 08:00:00', '2026-03-03 08:00:00', 1),
(2, 1, 102, 'storage', 1200, 'GB', '2026-03-01 08:00:00', '2026-03-10 18:00:00', 1),
(3, 2, 103, 'backup', 800, 'GB', '2026-03-02 09:30:00', '2026-03-06 09:30:00', 0),
(4, 3, 104, 'compute', 72, 'hours', '2026-03-07 14:20:00', '2026-03-10 14:20:00', 1),
(5, 4, 105, 'monitoring', 78.5, 'hours', '2026-03-05 10:00:00', '2026-03-08 16:30:00', 1);


# =======Schema=======
PRAGMA foreign_keys = ON;

# client
INSERT INTO client (
    clientId,
    firstName,
    lastName,
    whatFor,
    email,
    password,
    phoneNumber,
    clientType
) VALUES
(1, 'Alice', 'Chen', 'analytics workloads', 'alicechen53@gmail.com', 'alice123', '6461234567', 'individual'),
(2, 'Brian', 'Patel', 'backup storage project', 'brianpatel01@gmail.com', 'brian456', '3109876543', 'group'),
(3, 'GreenLeaf', 'Labs', 'internal testing and monitoring', 'ops@greenleaflabs.com', '3327778888', '2015551003', 'organization');


# staff
INSERT INTO staff (
    staffId,
    firstName,
    lastName,
    jobType
) VALUES
(1, 'Maya', 'Lopez', 'scheduler'),
(2, 'Ethan', 'Brooks', 'operations'),
(3, 'Nina', 'Park', 'support');


# cloud_region
INSERT INTO cloud_region (
    regionId,
    cloudRegionName
) VALUES
(1, 'us-east'),
(2, 'eu-central'),
(3, 'ap-south');


# data_center
INSERT INTO data_center (
    dataCenterId,
    regionId,
    dataCenterName
) VALUES
(1, 1, 'US East DC 1'),
(2, 1, 'US East DC 2'),
(3, 2, 'EU Central DC 1'),
(4, 3, 'AP South DC 1');


# availability_zone
INSERT INTO availability_zone (
    zoneId,
    dataCenterId,
    zoneName,
    zoneStatus
) VALUES
(1, 1, 'us-east-1a', 'active'),
(2, 2, 'us-east-1b', 'active'),
(3, 3, 'eu-central-1a', 'active'),
(4, 4, 'ap-south-1a', 'degraded');


# =======Resource Section=======
# resource_type
INSERT INTO resource_type (
    resourceTypeId,
    typeName,
    performanceTier,
    capacityRating
) VALUES
(1, 'compute_vm', 'high', '16 vCPU'),
(2, 'storage_volume', 'standard', '2 TB'),
(3, 'backup_node', 'standard', '5 TB'),
(4, 'monitoring_node', 'enterprise', '10 Gbps');


# resource
INSERT INTO resource (
    resourceId,
    resourceTypeId,
    zoneId,
    resourceLabel,
    currentStatus
) VALUES
(101, 1, 1, 'comp-us-101', 'maintenance'),
(102, 2, 2, 'stor-us-102', 'available'),
(103, 3, 3, 'back-eu-103', 'in_use'),
(104, 1, 2, 'comp-us-104', 'in_use'),
(105, 4, 4, 'mon-ap-105', 'available');


# resource_capacity
INSERT INTO resource_capacity (
    capacityId,
    resourceId,
    capacityName,
    capacityValue,
    capacityUnit
) VALUES
(1, 101, 'cpu_cores', 16, 'cores'),
(2, 102, 'storage_space', 2000, 'GB'),
(3, 103, 'backup_space', 5000, 'GB'),
(4, 104, 'cpu_cores', 16, 'cores'),
(5, 105, 'network_bandwidth', 10, 'Gbps');


-- resource_availability_event
INSERT INTO resource_availability_event (
    availabilityEventId,
    resourceId,
    eventType,
    startTime,
    endTime,
    note
) VALUES
(1, 101, 'maintenance', '2026-03-07 12:00:00', '2026-03-09 09:00:00', 'Scheduled maintenance that triggered workload migration'),
(2, 102, 'repair', '2026-02-20 10:00:00', '2026-02-20 18:00:00', 'Minor storage controller repair completed same day'),
(3, 105, 'outage', '2026-02-28 02:00:00', '2026-02-28 03:30:00', 'Short monitoring outage caused by network switch issue');

# =======Reservation Section======= 
# reservation
INSERT INTO reservation (
    reservationId,
    clientId,
    staffId,
    regionId,
    requestStartTime,
    requestEndTime,
    reservationType,
    status,
    emergencyLevel
) VALUES
(1, 1, 1, 1, '2026-03-01 08:00:00', '2026-03-10 18:00:00', 'analytics_cluster', 'completed', 3),
(2, 2, 2, 2, '2026-03-02 09:30:00', '2026-03-15 12:00:00', 'backup_rollout', 'active', 2),
(3, 1, 3, 1, '2026-03-03 07:00:00', '2026-03-12 20:00:00', 'fraud_detection', 'completed', 5),
(4, 3, 2, 1, '2026-03-05 10:00:00', '2026-03-08 16:30:00', 'internal_test', 'completed', 1);


# need
INSERT INTO need (
    needId,
    reservationId,
    resourceTypeId,
    quantity,
    capacityRequirement,
    flexibilityLevel,
    note
) VALUES
(1, 1, 1, 2, '16 vCPU each', 'strict', 'Main compute nodes for analytics run'),
(2, 1, 2, 1, 'at least 1 TB', 'strict', 'Shared storage for analytics data'),
(3, 2, 3, 1, 'minimum 5 TB', 'flexible', 'Backup storage can scale if demand grows'),
(4, 3, 1, 1, '16 vCPU and low latency', 'strict', 'Realtime detection service'),
(5, 4, 4, 1, 'basic monitoring coverage', 'flexible', 'Monitoring only for internal testing');

# =======Deployment=======
# actual_assignment
INSERT INTO actual_assignment (
    assignmentId,
    reservationId,
    regionId,
    eventStartTime,
    eventEndTime,
    satisfactionScore,
    reason
) VALUES
(1, 1, 1, '2026-03-01 08:00:00', '2026-03-10 18:00:00', 4, 'Assigned to requested region and completed successfully'),
(2, 2, 2, '2026-03-02 09:30:00', '2026-03-15 12:00:00', 5, 'Backup capacity available in preferred region'),
(3, 3, 1, '2026-03-03 07:00:00', '2026-03-12 20:00:00', 4, 'Stayed in requested region after migration to another local resource'),
(4, 4, 1, '2026-03-05 10:00:00', '2026-03-08 16:30:00', 3, 'Used spare resources for internal testing');


# deployment_status
INSERT INTO deployment_status (
    statusId,
    statusName
) VALUES
(1, 'planned'),
(2, 'active'),
(3, 'completed'),
(4, 'paused');


# priority_level
INSERT INTO priority_level (
    priorityLevelId,
    priorityName,
    rankValue
) VALUES
(1, 'low', 1),
(2, 'medium', 2),
(3, 'high', 3),
(4, 'emergent', 4);


# deployment_priority_history
INSERT INTO deployment_priority_history (
    priorityHistoryId,
    deploymentId,
    priorityLevelId,
    startTime,
    endTime
) VALUES
(1, 1, 3, '2026-03-01 08:00:00', '2026-03-10 18:00:00'),
(2, 2, 2, '2026-03-02 09:30:00', '2026-03-15 12:00:00'),
(3, 3, 4, '2026-03-03 07:00:00', '2026-03-12 20:00:00'),
(4, 4, 1, '2026-03-05 10:00:00', '2026-03-08 16:30:00');


# Billing
INSERT INTO paying_party (paying_partyId, party_name) VALUES
(1, 'Alice Personal Account'),
(2, 'Patel Backup Team Account'),
(3, 'GreenLeaf Organization Account');


INSERT INTO beneficiary (
    beneficiaryId,
    paying_partyId,
    beneficiary_name,
    clientId
) VALUES
(1, 1, 'Alice Johnson', 1),
(2, 2, 'Raj Patel', 2),
(3, 3, 'GreenLeaf Ops', 3);


# billing_address
INSERT INTO billing_address (
    paying_partyId,
    addressType,
    addressLine1,
    city,
    zipCode,
    country
) VALUES
(1, 'billing', '12 Hudson St', 'Hoboken', '07030', 'USA'),
(2, 'billing', '85 Market Ave', 'Jersey City', '07302', 'USA'),
(3, 'billing', '400 Research Park Rd', 'Newark', '07102', 'USA');

INSERT INTO bill_header (
    billId,
    billStatus,
    issueDate,
    dueDate
) VALUES
(1, 'pending', '2026-04-01 09:00:00', '2026-04-15 23:59:59'),
(2, 'paid', '2026-04-01 09:00:00', '2026-04-15 23:59:59'),
(3, 'paid', '2026-04-01 09:00:00', '2026-04-15 23:59:59');

INSERT INTO bill_item (
    billItemId,
    billId,
    usageRecordId,
    beneficiaryId,
    Duration
) VALUES
(1, 1, 1, 1, 48),
(2, 2, 2, 2, 800),
(3, 3, 3, 3, 78);

INSERT INTO bill_adjustment (
    billId,
    deposit,
    depositDueDate,
    accountCredit,
    refund,
    surcharge,
    emergencyFee,
    discount,
    approvedByStaffId,
    createdAt
) VALUES
(1, 50.00, '2026-04-05 00:00:00', 0.00, 0.00, 0.00, 50.00, 0.00, 3, '2026-04-01'),
(2, 0.00, NULL, 5.00, 0.00, 0.00, 0.00, 0.00, 2, '2026-04-01'),
(3, 0.00, NULL, 0.00, 0.00, 0.00, 0.00, 10.00, 1, '2026-04-01');

INSERT INTO payment (
    paymentId,
    billId,
    paymentMethodId,
    dateFulfilled,
    paymentType
) VALUES
(1, 1, 1, '2026-04-05 13:00:00', 'partial'),
(2, 2, 2, '2026-04-03 11:00:00', 'full'),
(3, 3, 3, '2026-04-04 15:30:00', 'full');

INSERT INTO pricing (
    usageRecordId,
    pricePerUnitSold
) VALUES
(1, 2.50),
(2, 0.08),
(3, 2.00);
