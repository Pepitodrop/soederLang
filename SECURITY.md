# Security Policy

## Supported versions

Security fixes are provided for the latest major release.

## Reporting

Please report vulnerabilities privately through GitHub Security Advisories rather than public issues. Include a minimal reproduction, affected version, impact, and suggested mitigation when available.

## Runtime boundaries

SöderLang does not evaluate arbitrary JavaScript. Browser capabilities are supplied explicitly through host adapters. Backend hosts should configure authentication, origin policy, rate limiting, schema validation, timeouts, and an appropriate `maxBodyBytes` value. Do not expose untrusted programs with unrestricted host adapters.
