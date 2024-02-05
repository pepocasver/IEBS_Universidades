#!/bin/bash

function createIEBS() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/IEBS.universidades.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/IEBS.universidades.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-IEBS --tls.certfiles "${PWD}/organizations/fabric-ca/IEBS/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-IEBS.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-IEBS.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-IEBS.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-IEBS.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/msp/config.yaml"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-IEBS --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/IEBS/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-IEBS --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/IEBS/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-IEBS --id.name IEBSadmin --id.secret IEBSadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/IEBS/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-IEBS -M "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/msp" --csr.hosts peer0.IEBS.universidades.com --tls.certfiles "${PWD}/organizations/fabric-ca/IEBS/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-IEBS -M "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls" --enrollment.profile tls --csr.hosts peer0.IEBS.universidades.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/IEBS/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/tlsca/tlsca.IEBS.universidades.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/ca"
  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/ca/ca.IEBS.universidades.com-cert.pem"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-IEBS -M "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/users/User1@IEBS.universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/IEBS/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/users/User1@IEBS.universidades.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://IEBSadmin:IEBSadminpw@localhost:7054 --caname ca-IEBS -M "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/users/Admin@IEBS.universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/IEBS/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/IEBS.universidades.com/users/Admin@IEBS.universidades.com/msp/config.yaml"
}

function createUNAM() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/UNAM.universidades.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/UNAM.universidades.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-UNAM --tls.certfiles "${PWD}/organizations/fabric-ca/UNAM/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-UNAM.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-UNAM.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-UNAM.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-UNAM.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/msp/config.yaml"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-UNAM --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/UNAM/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-UNAM --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/UNAM/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-UNAM --id.name UNAMadmin --id.secret UNAMadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/UNAM/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-UNAM -M "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/msp" --csr.hosts peer0.UNAM.universidades.com --tls.certfiles "${PWD}/organizations/fabric-ca/UNAM/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-UNAM -M "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls" --enrollment.profile tls --csr.hosts peer0.UNAM.universidades.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/UNAM/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/tlsca/tlsca.UNAM.universidades.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/ca"
  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/ca/ca.UNAM.universidades.com-cert.pem"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-UNAM -M "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/users/User1@UNAM.universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/UNAM/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/users/User1@UNAM.universidades.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://UNAMadmin:UNAMadminpw@localhost:8054 --caname ca-UNAM -M "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/users/Admin@UNAM.universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/UNAM/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/UNAM.universidades.com/users/Admin@UNAM.universidades.com/msp/config.yaml"
}

function createOrderer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/universidades.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/universidades.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/universidades.com/msp/config.yaml"

  echo "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp" --csr.hosts orderer.universidades.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/universidades.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/config.yaml"

  echo "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls" --enrollment.profile tls --csr.hosts orderer.universidades.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/universidades.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem"

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/universidades.com/users/Admin@universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/universidades.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/universidades.com/users/Admin@universidades.com/msp/config.yaml"
}
