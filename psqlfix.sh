cd /etc/postgresql/9.3/main/

#Bind to all interfaces
echo "listen_addresses='*'" >>postgresql.conf;

#Allow password connection on all interfaces
cat >pg_hba.conf <<PG_HBA
local   all             postgres                                peer
local   all             all                                     md5
host    all             all             0.0.0.0/0               md5
PG_HBA
