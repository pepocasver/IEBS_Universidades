##  IEBS - Hyperledger
##  Proyecto: Instalación de Hyperledger Fabric, herramientas y archivos
##  Alumno: Jose Luis Castro Vera
##  Script para automatizar la creación de Universidades IEBS y UNAM

#git clone https://github.com/pepocasver/IEBS_Universidades/

#cd ~/IEBS_Universidades

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker volume prune --all -f
docker network prune -f

rm -rf organizations/peerOrganizations
rm -rf organizations/ordererOrganizations
rm -rf channel-artifacts/
mkdir channel-artifacts

docker-compose -f docker/docker-compose-ca.yaml up -d

export PATH=${PWD}/bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx

. ./organizations/fabric-ca/registerEnroll.sh && createIEBS
. ./organizations/fabric-ca/registerEnroll.sh && createUNAM
. ./organizations/fabric-ca/registerEnroll.sh && createOrderer

docker-compose -f docker/docker-compose-universidades.yaml up -d

#--Orderer
configtxgen -profile UniversidadesGenesis -outputBlock ./channel-artifacts/universidadeschannel.block -channelID universidadeschannel

export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.key

osnadmin channel join --channelID universidadeschannel --config-block ./channel-artifacts/universidadeschannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"

#-- Universidad IEBS
export CORE_PEER_TLS_ENABLED=true
export PEER0_IEBS_CA=${PWD}/organizations/peerOrganizations/IEBS.universidades.com/peers/peer0.IEBS.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="IEBSMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_IEBS_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/IEBS.universidades.com/users/Admin@IEBS.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:7051
peer channel join -b ./channel-artifacts/universidadeschannel.block

#-- Universidad UNAM
export PEER0_UNAM_CA=${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="UNAMMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_UNAM_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/UNAM.universidades.com/users/Admin@UNAM.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer channel join -b ./channel-artifacts/universidadeschannel.block
