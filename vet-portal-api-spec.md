# Vet Portal & Digital Prescriptions API Specification

## Overview
This document outlines the API specifications for a comprehensive Vet Portal & Digital Prescriptions system that enables veterinarians to create, sign, and manage digital prescriptions with cryptographic security and audit trails.

## Table of Contents
1. [Database Schema](#database-schema)
2. [Authentication & Authorization](#authentication--authorization)
3. [Cryptographic Signature System](#cryptographic-signature-system)
4. [API Endpoints](#api-endpoints)
5. [Error Handling](#error-handling)
6. [Security Considerations](#security-considerations)

## Database Schema

### 1. Prescriptions Table
```sql
CREATE TABLE prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prescription_id VARCHAR(50) UNIQUE NOT NULL,
    vet_id VARCHAR(50) NOT NULL,
    farmer_id VARCHAR(50) NOT NULL,
    animal_id VARCHAR(50) NOT NULL,

    -- Prescription Details
    medicine_name VARCHAR(255) NOT NULL,
    dosage_mg_per_kg DECIMAL(10,2) NOT NULL,
    withdrawal_days INTEGER NOT NULL,
    product_type VARCHAR(20) NOT NULL, -- 'milk', 'meat', 'eggs'

    -- Digital Signature
    signature_data TEXT NOT NULL,
    signature_algorithm VARCHAR(50) NOT NULL DEFAULT 'RSA-SHA256',
    signature_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    signature_valid BOOLEAN NOT NULL DEFAULT TRUE,

    -- Status & Validity
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- 'active', 'revoked', 'expired'
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    revoked_at TIMESTAMP WITH TIME ZONE,
    revocation_reason TEXT,

    -- Metadata
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Foreign Keys
    FOREIGN KEY (vet_id) REFERENCES vets(vet_id),
    FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id)
);

-- Indexes
CREATE INDEX idx_prescriptions_vet_id ON prescriptions(vet_id);
CREATE INDEX idx_prescriptions_farmer_id ON prescriptions(farmer_id);
CREATE INDEX idx_prescriptions_animal_id ON prescriptions(animal_id);
CREATE INDEX idx_prescriptions_status ON prescriptions(status);
CREATE INDEX idx_prescriptions_issued_at ON prescriptions(issued_at);
```

### 2. Audit Events Table
```sql
CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- 'prescription', 'vet', 'farmer'
    entity_id VARCHAR(50) NOT NULL,

    -- Event Details
    action VARCHAR(50) NOT NULL, -- 'create', 'update', 'revoke', 'verify'
    old_values JSONB,
    new_values JSONB,
    changes JSONB,

    -- Context
    user_id VARCHAR(50) NOT NULL,
    user_type VARCHAR(20) NOT NULL, -- 'vet', 'farmer', 'system'
    ip_address INET,
    user_agent TEXT,

    -- Metadata
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    session_id VARCHAR(255),
    request_id VARCHAR(255)
);

-- Indexes
CREATE INDEX idx_audit_events_entity ON audit_events(entity_type, entity_id);
CREATE INDEX idx_audit_events_timestamp ON audit_events(timestamp);
CREATE INDEX idx_audit_events_user ON audit_events(user_id, user_type);
```

### 3. Vet Ratings Table
```sql
CREATE TABLE vet_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vet_id VARCHAR(50) NOT NULL,
    farmer_id VARCHAR(50) NOT NULL,

    -- Rating Details
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    prescription_id VARCHAR(50),

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    -- Constraints
    UNIQUE(vet_id, farmer_id, prescription_id),
    FOREIGN KEY (vet_id) REFERENCES vets(vet_id),
    FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id),
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id)
);

-- Indexes
CREATE INDEX idx_vet_ratings_vet_id ON vet_ratings(vet_id);
CREATE INDEX idx_vet_ratings_rating ON vet_ratings(rating);
```

### 4. Vet Statistics View
```sql
CREATE VIEW vet_statistics AS
SELECT
    v.vet_id,
    v.username,
    v.full_name,
    COUNT(p.id) as total_prescriptions,
    COUNT(CASE WHEN p.status = 'active' THEN 1 END) as active_prescriptions,
    AVG(r.rating) as average_rating,
    COUNT(r.id) as total_ratings,
    MAX(p.issued_at) as last_prescription_date
FROM vets v
LEFT JOIN prescriptions p ON v.vet_id = p.vet_id
LEFT JOIN vet_ratings r ON v.vet_id = r.vet_id
GROUP BY v.vet_id, v.username, v.full_name;
```

## Authentication & Authorization

### JWT Token Structure
```json
{
  "sub": "vet_12345",
  "type": "vet",
  "permissions": ["prescription:create", "prescription:revoke", "audit:read"],
  "iat": 1638360000,
  "exp": 1638363600,
  "iss": "vet-portal-api",
  "aud": "vet-portal"
}
```

### Permission Levels
- **Vet**: `prescription:create`, `prescription:read`, `prescription:revoke`, `audit:read`
- **Farmer**: `prescription:read`, `rating:create`, `rating:read`
- **Admin**: All permissions including system management

## Cryptographic Signature System

### Signature Generation Process

#### 1. Prescription Data Canonicalization
```javascript
function canonicalizePrescription(prescription) {
    const canonical = {
        prescription_id: prescription.prescription_id,
        vet_id: prescription.vet_id,
        farmer_id: prescription.farmer_id,
        animal_id: prescription.animal_id,
        medicine_name: prescription.medicine_name,
        dosage_mg_per_kg: prescription.dosage_mg_per_kg,
        withdrawal_days: prescription.withdrawal_days,
        product_type: prescription.product_type,
        issued_at: prescription.issued_at,
        expires_at: prescription.expires_at
    };

    return JSON.stringify(canonical, Object.keys(canonical).sort());
}
```

#### 2. Digital Signature Creation
```javascript
async function generatePrescriptionSignature(prescription, privateKey) {
    const canonicalData = canonicalizePrescription(prescription);
    const signature = await crypto.sign('RSA-SHA256', canonicalData, privateKey);

    return {
        data: signature.toString('base64'),
        algorithm: 'RSA-SHA256',
        timestamp: new Date().toISOString(),
        public_key_fingerprint: generateKeyFingerprint(publicKey)
    };
}
```

#### 3. Signature Verification
```javascript
async function verifyPrescriptionSignature(prescription, signature) {
    const canonicalData = canonicalizePrescription(prescription);
    const publicKey = await getVetPublicKey(prescription.vet_id);

    return await crypto.verify(
        signature.algorithm,
        canonicalData,
        signature.data,
        publicKey
    );
}
```

### HSM Integration (Optional)
```javascript
class HSMSignatureService {
    async sign(data, keyId) {
        // HSM-specific implementation
        const response = await hsmClient.sign({
            keyId: keyId,
            algorithm: 'RSA-PSS',
            data: data,
            padding: 'PSS'
        });

        return {
            signature: response.signature,
            certificate: response.certificate,
            timestamp: response.timestamp
        };
    }
}
```

## API Endpoints

### 1. Prescription Management

#### POST /api/v1/prescriptions
Create a new digital prescription with cryptographic signature.

**Authentication:** Required (Vet JWT)
**Authorization:** `prescription:create`

**Request Body:**
```json
{
  "farmer_id": "F-123456789",
  "animal_id": "A-987654321",
  "medicine_name": "Amoxicillin",
  "dosage_mg_per_kg": 10.5,
  "withdrawal_days": 7,
  "product_type": "milk",
  "expires_at": "2024-12-31T23:59:59Z",
  "notes": "Administer orally twice daily"
}
```

**Response (201):**
```json
{
  "prescription_id": "PRE-2024-001",
  "status": "active",
  "signature": {
    "data": "base64-encoded-signature",
    "algorithm": "RSA-SHA256",
    "timestamp": "2024-01-15T10:30:00Z",
    "valid": true
  },
  "issued_at": "2024-01-15T10:30:00Z",
  "expires_at": "2024-12-31T23:59:59Z"
}
```

**Error Responses:**
- `400`: Invalid prescription data
- `401`: Unauthorized
- `403`: Insufficient permissions
- `409`: Prescription ID already exists

#### GET /api/v1/prescriptions
Retrieve prescriptions with filtering options.

**Authentication:** Required
**Authorization:** `prescription:read`

**Query Parameters:**
- `vet_id`: Filter by veterinarian
- `farmer_id`: Filter by farmer
- `animal_id`: Filter by animal
- `status`: Filter by status (active, revoked, expired)
- `from_date`: Filter from date
- `to_date`: Filter to date
- `limit`: Maximum results (default: 50, max: 100)
- `offset`: Pagination offset

**Response (200):**
```json
{
  "prescriptions": [
    {
      "prescription_id": "PRE-2024-001",
      "vet_id": "VET-123",
      "farmer_id": "F-123456789",
      "animal_id": "A-987654321",
      "medicine_name": "Amoxicillin",
      "dosage_mg_per_kg": 10.5,
      "withdrawal_days": 7,
      "product_type": "milk",
      "status": "active",
      "issued_at": "2024-01-15T10:30:00Z",
      "signature": {
        "valid": true,
        "algorithm": "RSA-SHA256",
        "timestamp": "2024-01-15T10:30:00Z"
      }
    }
  ],
  "total": 1,
  "limit": 50,
  "offset": 0
}
```

#### GET /api/v1/prescriptions/{prescription_id}
Retrieve a specific prescription with full details.

**Authentication:** Required
**Authorization:** `prescription:read`

**Response (200):**
```json
{
  "prescription_id": "PRE-2024-001",
  "vet_id": "VET-123",
  "farmer_id": "F-123456789",
  "animal_id": "A-987654321",
  "medicine_name": "Amoxicillin",
  "dosage_mg_per_kg": 10.5,
  "withdrawal_days": 7,
  "product_type": "milk",
  "status": "active",
  "issued_at": "2024-01-15T10:30:00Z",
  "expires_at": "2024-12-31T23:59:59Z",
  "signature": {
    "data": "base64-encoded-signature",
    "algorithm": "RSA-SHA256",
    "timestamp": "2024-01-15T10:30:00Z",
    "valid": true
  },
  "notes": "Administer orally twice daily"
}
```

#### PUT /api/v1/prescriptions/{prescription_id}/revoke
Revoke a prescription.

**Authentication:** Required (Vet JWT)
**Authorization:** `prescription:revoke`

**Request Body:**
```json
{
  "reason": "Incorrect dosage prescribed",
  "notes": "Patient showed adverse reaction"
}
```

**Response (200):**
```json
{
  "prescription_id": "PRE-2024-001",
  "status": "revoked",
  "revoked_at": "2024-01-16T14:30:00Z",
  "revocation_reason": "Incorrect dosage prescribed"
}
```

#### POST /api/v1/prescriptions/{prescription_id}/verify
Verify prescription signature integrity.

**Authentication:** Optional
**Authorization:** None required for verification

**Response (200):**
```json
{
  "prescription_id": "PRE-2024-001",
  "signature_valid": true,
  "signature_algorithm": "RSA-SHA256",
  "verified_at": "2024-01-16T10:00:00Z",
  "vet_public_key_fingerprint": "sha256:abc123..."
}
```

### 2. Vet Rating System

#### POST /api/v1/vets/{vet_id}/ratings
Submit a rating for a veterinarian.

**Authentication:** Required (Farmer JWT)
**Authorization:** `rating:create`

**Request Body:**
```json
{
  "rating": 5,
  "review_text": "Excellent service and very knowledgeable",
  "prescription_id": "PRE-2024-001"
}
```

**Response (201):**
```json
{
  "rating_id": "rating-uuid",
  "vet_id": "VET-123",
  "farmer_id": "F-123456789",
  "rating": 5,
  "review_text": "Excellent service and very knowledgeable",
  "created_at": "2024-01-16T10:00:00Z"
}
```

#### GET /api/v1/vets/{vet_id}/ratings
Get ratings for a specific veterinarian.

**Authentication:** Optional
**Authorization:** None required

**Query Parameters:**
- `limit`: Maximum results (default: 20)
- `offset`: Pagination offset
- `min_rating`: Minimum rating filter

**Response (200):**
```json
{
  "vet_id": "VET-123",
  "average_rating": 4.7,
  "total_ratings": 25,
  "ratings": [
    {
      "rating_id": "rating-uuid",
      "farmer_id": "F-123456789",
      "rating": 5,
      "review_text": "Excellent service",
      "prescription_id": "PRE-2024-001",
      "created_at": "2024-01-16T10:00:00Z"
    }
  ]
}
```

#### GET /api/v1/vets/{vet_id}/statistics
Get comprehensive statistics for a veterinarian.

**Authentication:** Optional
**Authorization:** None required

**Response (200):**
```json
{
  "vet_id": "VET-123",
  "username": "dr.smith",
  "full_name": "Dr. John Smith",
  "statistics": {
    "total_prescriptions": 150,
    "active_prescriptions": 45,
    "average_rating": 4.7,
    "total_ratings": 25,
    "last_prescription_date": "2024-01-15T10:30:00Z"
  },
  "rating_distribution": {
    "5": 15,
    "4": 7,
    "3": 2,
    "2": 1,
    "1": 0
  }
}
```

### 3. Audit & Compliance

#### GET /api/v1/audit/events
Retrieve audit events with filtering.

**Authentication:** Required
**Authorization:** `audit:read`

**Query Parameters:**
- `entity_type`: Filter by entity type
- `entity_id`: Filter by entity ID
- `user_id`: Filter by user ID
- `event_type`: Filter by event type
- `from_date`: Filter from date
- `to_date`: Filter to date
- `limit`: Maximum results (default: 50)

**Response (200):**
```json
{
  "events": [
    {
      "id": "audit-uuid",
      "event_type": "prescription_created",
      "entity_type": "prescription",
      "entity_id": "PRE-2024-001",
      "action": "create",
      "user_id": "VET-123",
      "user_type": "vet",
      "timestamp": "2024-01-15T10:30:00Z",
      "changes": {
        "status": { "old": null, "new": "active" }
      }
    }
  ],
  "total": 1
}
```

## Error Handling

### Standard Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid prescription data provided",
    "details": {
      "field": "dosage_mg_per_kg",
      "issue": "Must be a positive number"
    },
    "request_id": "req-12345",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Error Codes
- `VALIDATION_ERROR`: Invalid input data
- `AUTHENTICATION_ERROR`: Invalid or missing credentials
- `AUTHORIZATION_ERROR`: Insufficient permissions
- `NOT_FOUND_ERROR`: Resource not found
- `CONFLICT_ERROR`: Resource conflict (e.g., duplicate)
- `SIGNATURE_ERROR`: Cryptographic signature issues
- `INTERNAL_ERROR`: Server internal error

## Security Considerations

### 1. Transport Security
- All API endpoints must use HTTPS/TLS 1.3
- HSTS headers required
- Certificate pinning recommended for mobile clients

### 2. Data Protection
- Prescription data encrypted at rest using AES-256-GCM
- Sensitive audit data encrypted
- Database backups encrypted

### 3. Key Management
- Vet private keys stored in HSM when available
- Key rotation every 90 days
- Compromised key revocation process

### 4. Rate Limiting
- API rate limits: 100 requests/minute per IP
- Prescription creation: 10 per hour per vet
- Authentication attempts: 5 per minute per IP

### 5. Audit & Compliance
- All prescription operations logged
- Immutable audit trail
- Regular security audits
- GDPR compliance for data handling

## Implementation Notes

### Background Workers
```javascript
// Signature Generation Worker
class PrescriptionSignatureWorker {
  async process(job) {
    const { prescriptionId } = job.data;

    // Generate signature
    const signature = await this.generateSignature(prescriptionId);

    // Update prescription with signature
    await this.updatePrescriptionSignature(prescriptionId, signature);

    // Log audit event
    await this.logAuditEvent('prescription_signed', prescriptionId);
  }
}
```

### Monitoring & Alerting
- Signature verification failures
- Unusual prescription patterns
- Failed authentication attempts
- System performance metrics

This specification provides a comprehensive foundation for implementing a secure, auditable digital prescription system for veterinary medicine management.