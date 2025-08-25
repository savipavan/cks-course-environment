# Supply Chain Security
Implement Deployment Security
- Pod security policies
- Network policies
- Role-Based Access Control(RBAC)

Benefits
- Early detection of vulnerabilities
- Better resource Management
- Improved compliance
- Efficient incident response
- Enhanced security posture

Risks of inadequate supply chain management
- Cyber Attacks
- Operational Disruptions
- Financial Losses
- Regulatory and Legal Consequences
- Competitive Disadvantage

SBOM benefits
Software Bill of materials
- Software Components
- Supplier Details
- Software Composition
- Security Vulnerabilities
- Licenses
- Versions
- Patch Status

Benefits
- Transparency
- Incident Response
- Dependency Management
- Security
- Compliance

## Minimize Base image footprint
- Do not build images with multiple compoments like web, db, backend
- build moduler image
- Store data in external
- Slim /  Minimal Images
  - Create a slim / minimal images
  - Find an official minimal image that exists
  - Only install necessary packages
    - Remove Shells/Package Managers/Tools
  - Maintain different images for different environments:
    - Development - debug tools
    - Production - lean

Distroless Docker Images
- Contains:
  - Application
  - Runtime dependencies
- Doesn't contain:
  - package managers
  - Shells
  - Network tools
  - Text editors
  - other unwanted programs

Vulnerability Scanning:

SBOM Format:

## Image Security
## Secure your supply chain
## Use static analysis of workloads
## Scan images for known vulnerabilities

