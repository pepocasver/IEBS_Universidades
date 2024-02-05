##  IEBS - Hyperledger
##  Strpint 3: Instalación de Hyperledger Fabric, herramientas y archivos
##  Alumno: Jose Luis Castro Vera
##  Script para automatizar la creación de Universidades

git clone https://gitlab.com/STorres17/soluciones-blockchain.git

cd ~/soluciones-blockchain/universidades

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker volume prune
docker network prune

rm -rf organizations/peerOrganizations
rm -rf organizations/ordererOrganizations
rm -rf channel-artifacts/
mkdir channel-artifacts

docker-compose -f docker/docker-compose-ca.yaml up -d

export PATH=${PWD}/../bin:${PWD}:$PATH
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
export PEER0_BOGOTA_CA=${PWD}/organizations/peerOrganizations/UNAM.universidades.com/peers/peer0.UNAM.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="UNAMMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BOGOTA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/UNAM.universidades.com/users/Admin@UNAM.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer channel join -b ./channel-artifacts/universidadeschannel.block


#---------------------------- CREACIÒN DE PARA UNIVERSIDAD BERLIN --------------------------

#---------- Esto generará el crypto material  (archivo similar a docker-compose-ca.yaml hecho con la info de Universidad Berlin).
docker-compose -f docker/docker-compose-ca-berlin.yaml up -d

     # --------- CARGADO BARINO EN PATH --------------------------
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config

    #---------- Necesario primero confirmar que se ha modificado registerEnroll.sh para agregar la funcion de createBerlin de forma similar a CreateMadrir o CreateBogota
. ./organizations/fabric-ca/registerEnroll.sh && createBerlin

#---------- Agregando la universidad Berlin --------------------------

docker-compose -f docker/docker-compose-berlin.yaml up -d


# --------- Con un Fetch desde el peer Madrid, se traerá el último bloque de configuración de la red


export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
export CORE_PEER_TLS_ENABLED=true
export PEER0_MADRID_CA=${PWD}/organizations/peerOrganizations/madrid.universidades.com/peers/peer0.madrid.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="MadridMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MADRID_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/madrid.universidades.com/users/Admin@madrid.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:051
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com -c universidadeschannel --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem
cd channel-artifacts

    #-- Los siguientes pasos toman el binario del ultimo bloque de configuración, lo decodifica en un json, le inlcuyen la info de la nueva universidad berlin, 
    #-- el json se escribe en el binario con la nueva uni berlin, lo decofifica y lo pone de vuelta para que esté en el bloque al cual se le hizo el fetch.
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
  -- este jey query pone la config de la nueva uni, berlin.
jq .data.data[0].payload.data.config config_block.json > config.json
   -- se agrega el msp
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"BerlinMSP":.[1]}}}}}' config.json ../organizations/peerOrganizations/berlin.universidades.com/berlin.json > modified_config.json
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id universidadeschannel --original config.pb --updated modified_config.pb --output berlin_update.pb
configtxlator proto_decode --input berlin_update.pb --type common.ConfigUpdate --output berlin_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'universidadeschannel'", "type":2}},"data":{"config_update":'$(cat berlin_update.json)'}}}' | jq . > berlin_update_in_envelope.json
configtxlator proto_encode --input berlin_update_in_envelope.json --type common.Envelope --output berlin_update_in_envelope.pb

cd ..
    #------ Firma la transacción con uni de madrid
peer channel signconfigtx -f channel-artifacts/berlin_update_in_envelope.pb

    #------ Ahora se  Conectará con uni de bogotá
export PEER0_BOGOTA_CA=${PWD}/organizations/peerOrganizations/bogota.universidades.com/peers/peer0.bogota.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="BogotaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BOGOTA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bogota.universidades.com/users/Admin@bogota.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:9051
    #-- y se firma la transacciòn con uni bogota
peer channel update -f channel-artifacts/berlin_update_in_envelope.pb -c universidadeschannel -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem



#---------- Conectando ahora a la universidad Berlin para conectar al canal--------------------------


export CORE_PEER_TLS_ENABLED=true
export PEER0_BERLIN_CA=${PWD}/organizations/peerOrganizations/berlin.universidades.com/peers/peer0.berlin.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="BerlinMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BERLIN_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/berlin.universidades.com/users/Admin@berlin.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:2051
peer channel join -b ./channel-artifacts/universidadeschannel.block

