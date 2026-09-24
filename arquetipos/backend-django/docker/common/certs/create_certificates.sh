#!/bin/bash

set -e

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
DEFAULT_CERT_DIR="."  # Current directory
DAYS_VALID=3650
DEFAULT_CN="localhost"
CA_NAME="LocalDevCA"
WATERMARK="-dev"

# ------------------------------------------------------------
# Colors (warning only)
# ------------------------------------------------------------
RED="\033[0;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# ------------------------------------------------------------
# Usage / Help
# ------------------------------------------------------------
usage() {
cat <<EOF
Usage: $0 [OPTIONS] [CERT_DIR]

Options:
    --name NAME        (REQUIRED) Base name for the certificate files (e.g., redis)
                       Supports '=' or space syntax: --name=redis or --name redis
    --cn CN            (optional) Common Name for the certificate. Default: localhost
                       Supports '=' or space syntax
    CERT_DIR           (optional) Directory to store certificates. Default: current directory
    -h, --help         Show this help message and exit

Examples:
    $0 --name=redis
    $0 --name redis --cn=redis.local
    $0 --name redis /tmp/mycerts
    $0 --name redis --cn=redis.local /tmp/mycerts

Description:
    Generates local development TLS certificates with a watermark '-dev' applied to
    the CN and SANs to prevent accidental production use. Creates a local Certificate
    Authority (CA) if not already present, and generates server certificates with
    SANs for DNS and IP addresses suitable for local development and testing.
EOF
}

# ------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------
CERT_NAME=""
RAW_CN="$DEFAULT_CN"
CERT_DIR="$DEFAULT_CERT_DIR"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name=*)
      CERT_NAME="${1#*=}"
      shift
      ;;
    --name)
      CERT_NAME="$2"
      shift 2
      ;;
    --cn=*)
      RAW_CN="${1#*=}"
      shift
      ;;
    --cn)
      RAW_CN="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      # If it's the last argument, treat as optional cert_dir
      if [[ $# -eq 1 ]]; then
        CERT_DIR="$1"
        shift
      else
        echo "Error: unknown option '$1'"
        usage
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$CERT_NAME" ]]; then
  echo "Error: --name is required"
  usage
  exit 1
fi

CERT_CN="${RAW_CN}${WATERMARK}"

# ------------------------------------------------------------
# Warning
# ------------------------------------------------------------
echo -e "${RED}============================================================${RESET}"
echo -e "${RED}  WARNING: LOCAL DEVELOPMENT CERTIFICATES ONLY${RESET}"
echo -e "${YELLOW}  These certificates must NOT be used in production.${RESET}"
echo -e "${YELLOW}  Watermark applied to CN and SANs: ${CERT_CN}${RESET}"
echo -e "${RED}============================================================${RESET}"
echo ""

# ------------------------------------------------------------
# Prepare directories
# ------------------------------------------------------------
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# ------------------------------------------------------------
# Certificate Authority
# ------------------------------------------------------------
if [[ -f ca.key && -f ca.crt ]]; then
  echo "Using existing CA"
else
  echo "Creating local CA"
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -nodes \
    -key ca.key \
    -sha256 \
    -days "$DAYS_VALID" \
    -out ca.crt \
    -subj "/CN=${CA_NAME}"
fi

# ------------------------------------------------------------
# File names
# ------------------------------------------------------------
KEY_FILE="${CERT_NAME}.key"
CSR_FILE="${CERT_NAME}.csr"
CRT_FILE="${CERT_NAME}.crt"
PEM_FILE="${CERT_NAME}.pem"

echo "Generating certificate: ${CERT_NAME}"
echo "CN: ${CERT_CN}"
echo "Directory: ${CERT_DIR}"

# ------------------------------------------------------------
# Private key
# ------------------------------------------------------------
openssl genrsa -out "$KEY_FILE" 2048

# ------------------------------------------------------------
# Temporary OpenSSL config with SANs
# ------------------------------------------------------------
SAN_CONFIG=$(mktemp)
cat > "$SAN_CONFIG" <<EOF
[ req ]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[ req_distinguished_name ]
CN = ${CERT_CN}

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${CERT_CN}
DNS.2 = localhost${WATERMARK}
IP.1  = 127.0.0.1
IP.2  = ::1
EOF

# ------------------------------------------------------------
# CSR with SANs
# ------------------------------------------------------------
openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" -config "$SAN_CONFIG"

# ------------------------------------------------------------
# Sign certificate with SANs
# ------------------------------------------------------------
openssl x509 -req \
  -in "$CSR_FILE" \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out "$CRT_FILE" \
  -days "$DAYS_VALID" \
  -sha256 \
  -extensions v3_req \
  -extfile "$SAN_CONFIG"

# ------------------------------------------------------------
# Combined PEM
# ------------------------------------------------------------
cat "$CRT_FILE" "$KEY_FILE" > "$PEM_FILE"

# Clean up temporary config
rm -f "$SAN_CONFIG"

echo "Done"
echo "Files:"
echo "  $CERT_DIR/$KEY_FILE"
echo "  $CERT_DIR/$CRT_FILE"
echo "  $CERT_DIR/$PEM_FILE"
